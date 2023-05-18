``` {linenos=inline}
// compile with gcc thread_art.c -o out -O2 -lm -std=c99
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>

#define WHEEL_PIXEL_SIZE 1600
#define N_HOOKS 160 // needs to be divisible by 2
#define HOOK_PIXEL_SIZE 3
#define ROWS 1600
#define COLS 1600
#define N_LINES 800
#define LIGHTNESS_PENALTY 1 // defined in terms of right shifts
#define DARKNESS 800
#define TIME_SAVER 40 // defined as terms to actually consider
#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif
#ifndef INT_MIN
#define INT_MIN -2147483648
#endif

// HELPER STUFF
struct Tuple
{
    int x;
    int y;
};

struct Node
{
    struct Tuple data;
    struct Node *next;
};

struct LinkedList
{
    struct Node *head;
    struct Node *tail;
};

struct LinkedList *initLinkedList()
{
    struct LinkedList *list = (struct LinkedList *)malloc(sizeof(struct LinkedList));
    list->head = NULL;
    list->tail = NULL;
    return list;
}

void freeList(struct LinkedList *list)
{
    struct Node *current = list->head;
    while (current != NULL)
    {
        struct Node *temp = current;
        current = current->next;
        free(temp);
    }
    free(list);
}

void append(struct LinkedList *list, struct Tuple data)
{
    // allocate memory for the new node
    struct Node *new_node = (struct Node *)malloc(sizeof(struct Node));

    // set the data of the new node
    new_node->data = data;

    // set the next pointer of the new node to NULL
    new_node->next = NULL;

    // if the list is empty, set the new node as the head and tail of the list
    if (list->head == NULL)
    {
        list->head = new_node;
        list->tail = new_node;
    }
    // otherwise, append the new node to the tail of the list
    else
    {
        list->tail->next = new_node;
        list->tail = new_node;
    }
}

void print_list(struct LinkedList *list)
{
    struct Node *current = list->head;
    int idx = 0;
    while (current != NULL)
    {
        printf("idx %d: (%d, %d)\n", idx, current->data.x, current->data.y);
        idx++;
        current = current->next;
    }
}

// END HELPER STUFF

void read_array(int *array, char *path)
{
    // open the input file
    FILE *fp = fopen(path, "r");
    if (fp == NULL)
    {
        printf("Failed to open file \n");
    }
    int count = 0;
    // read the integers from the file into the array
    for (int i = 0; i < ROWS; i++)
    {
        for (int j = 0; j < COLS; j++)
        {
            int cur;
            if (!fscanf(fp, "%d", &cur))
            {
                printf("FAIL");
            }
            count++;
            array[i * COLS + j] = cur;
        }
    }

    // close the input file
    fclose(fp);
    printf("count: %d\n", count);
}

void generate_hooks_with_size(struct Tuple *xy) // generates points along a circle
{
    double r = (WHEEL_PIXEL_SIZE / 2.0) - 1.0;
    double *theta = (double *)malloc((N_HOOKS) * sizeof(double));
    double epsilon = asin(HOOK_PIXEL_SIZE / WHEEL_PIXEL_SIZE);
    for (int i = 0; i < (N_HOOKS >> 1); i++)
    {
        double angle = (double)i / (double)(N_HOOKS >> 1) * (2.0 * M_PI);
        theta[i * 2] = angle - epsilon;
        theta[i * 2 + 1] = angle + epsilon;
    }
    for (int j = 0; j < N_HOOKS; j++)
    {
        struct Tuple point;
        point.x = r * (1.0 + cos(theta[j])) + 0.5;
        point.y = r * (1.0 + sin(theta[j])) + 0.5;
        xy[j] = point;
    }
    free(theta);
}

void through_pixels(struct Tuple p0, struct Tuple p1, struct LinkedList *pixels) 
{
    int x0 = p0.x;
    int y0 = p0.y;
    int x1 = p1.x;
    int y1 = p1.y;
    int dx = abs(x1 - x0);
    int dy = abs(y1 - y0);

    int sx = (x0 < x1) ? 1 : -1;
    int sy = (y0 < y1) ? 1 : -1;

    int err = dx - dy;

    while (1)
    {
        struct Tuple point;
        point.x = x0;
        point.y = y0;
        append(pixels, point);

        if (x0 == x1 && y0 == y1)
        {
            return;
        }

        int e2 = 2 * err;

        if (e2 > -dy)
        {
            err -= dy;
            x0 += sx;
        }

        if (e2 < dx)
        {
            err += dx;
            y0 += sy;
        }
        else if (e2 == dx)
        { // Handle cases with slope 1 or -1
            err -= dy;
            x0 += sx;
            err += dx;
            y0 += sy;
        }
    }
}

// takes image assuming it has been preprocessed for weights
int calculate_penalty(int cur, int weight)
{
    if (cur < 0)
    {
        // // DEBUG______________________________
        // return (weight < 0) ? 0 : ((int)(-cur * 0.25) >> weight);
        // // DEBUG______________________________
        return (weight < 0) ? 0 : -((cur >> LIGHTNESS_PENALTY) >> weight);
    }
    else
    {
        return (weight < 0) ? 0 : (cur >> weight);
    }
}

void generate_unique_random_numbers(int min, int max, int exclude, int N, int *result)
{
    int range = max - min + 1;
    int adjusted_range = range - (exclude >= min && exclude <= max);
    if (N > adjusted_range)
    {
        printf("Error: Cannot generate %d unique random numbers in the given range.\n", N);
        return;
    }

    int *flags = (int *)calloc(range, sizeof(int));
    flags[exclude - min] = 1;

    for (int i = 0; i < N; i++)
    {
        int rand_num;
        do
        {
            rand_num = rand() % range + min;
        } while (flags[rand_num - min]);

        flags[rand_num - min] = 1;
        result[i] = rand_num;
    }

    free(flags);
}

void optimise_fitness(int *image, int *weight, int *previous_edge, struct Tuple *xy)
{
    int starting_edge = *previous_edge;
    int count = 0;
    // randomly chose a subset of endpoints
    int *chosen = (int *)malloc(TIME_SAVER * sizeof(int));
    generate_unique_random_numbers(0, N_HOOKS - 1, starting_edge, TIME_SAVER, chosen);

    // // DEBUG______________________________
    // for (int ii = 0; ii < TIME_SAVER; ii ++){
    //     printf("el %d: %d \n", ii, chosen[ii]);
    // }
    // // DEBUG______________________________

    int best_endpoint = -1;
    int best_reduction = INT_MIN;
    for (int i = 0; i < TIME_SAVER; i++)
    {
        int ending_edge = chosen[i];
        struct LinkedList *pixels = initLinkedList();
        int penalty_without = 0;
        int penalty_with = 0;
        int reduction;
        through_pixels(xy[starting_edge], xy[ending_edge], pixels);
        int norm = 0;
        struct Node *current = pixels->head;
        while (current != NULL)
        {
            norm++;
            struct Node *temp = current;
            int image_data = image[temp->data.x + (temp->data.y) * COLS];
            int weight_data;
            if (temp->data.y % 2 == 0) {
                weight_data = weight[temp->data.x + (temp->data.y) * COLS];
            }
            else {
                weight_data = weight[temp->data.x + (temp->data.y - 1) * COLS];
            }
            
            int cur_penalty_without = calculate_penalty(image_data, weight_data);
            int cur_penalty_with = calculate_penalty(image_data - DARKNESS, weight_data);
            penalty_with = cur_penalty_with + penalty_with;
            penalty_without = cur_penalty_without + penalty_without;
            current = current->next;
            free(temp);
        }
        free(pixels);
        reduction = (penalty_without - penalty_with) / norm;
        if (reduction > best_reduction)
        {
            best_reduction = reduction;
            best_endpoint = ending_edge;
        }
    }
    free(chosen);
    *previous_edge = best_endpoint;
}

void update_image(int *image, struct Tuple *xy, int start, int end)
{
    struct LinkedList *pixels = initLinkedList();
    through_pixels(xy[start], xy[end], pixels);
    struct Node *current = pixels->head;
    while (current != NULL)
    {
        struct Node *temp = current;
        image[temp->data.x + (temp->data.y) * COLS] = image[temp->data.x + (temp->data.y) * COLS] - DARKNESS;
        current = current->next;
        free(temp);
    }
    free(pixels);
}

void find_lines(int *image, int *weight, struct Tuple *xy, struct Tuple *line_list)
{
    int next_edge_value = rand() % N_HOOKS;
    int *next_edge = &next_edge_value;
    for (int i = 0; i < N_LINES; i++)
    {
        int previous_edge = *next_edge;
        optimise_fitness(image, weight, next_edge, xy);
        update_image(image, xy, previous_edge, *next_edge);
        line_list[i * 2] = xy[previous_edge];
        line_list[i * 2 + 1] = xy[*next_edge];
    }
}

void p_t(struct Tuple point)
{
    printf("%d, %d", point.x, point.y);
}

int main()
{
    // static seed for testing
    srand(42);

    clock_t start, end;
    double cpu_time_used;
    start = clock();
    printf("Generating Hooks\n");

    struct Tuple *xy = (struct Tuple *)malloc(N_HOOKS * sizeof(struct Tuple));

    generate_hooks_with_size(xy);

    printf("Reading Image Data\n");
    int *ah_monochrome = malloc((ROWS * COLS) * sizeof(int));
    read_array(ah_monochrome, "monalisa.txt");

    printf("Reading Weight Data\n");
    int *ah_weights = malloc((ROWS * COLS) * sizeof(int));
    read_array(ah_weights, "ah_wpos.txt");

    // COMMENT WHEN USING WEIGHTS
    // for (int j = 0; j < ROWS; j++){
    //     for (int k = 0; k < COLS; k++){
    //         ah_weights[j*COLS+k] = 0;
    //     }
    // }

    printf("Allocating connections list and running optimizer\n");
    struct Tuple *line_list = (struct Tuple *)malloc(N_LINES * sizeof(struct Tuple) * 2);
    find_lines(ah_monochrome, ah_weights, xy, line_list);

    // Open the file for writing
    printf("Done, writing output file\n");
    FILE *file = fopen("output.txt", "w");
    if (file == NULL)
    {
        printf("Error opening the file.\n");
        return 1;
    }

    // Write the array elements to the file
    for (int i = 0; i < N_LINES; i++)
    {
        fprintf(file, "%d", line_list[i * 2].x);
        fprintf(file, " %d", line_list[i * 2].y);
        fprintf(file, " %d", line_list[i * 2 + 1].x);
        fprintf(file, " %d", line_list[i * 2 + 1].y);
        // Use a newline character instead of a comma to separate elements
        if (i < N_LINES - 1)
        {
            fprintf(file, "\n");
        }
    }

    // Close the file
    fclose(file);

    printf("Array written to the output.txt file.\n");

    free(line_list);
    free(xy);
    free(ah_monochrome);
    free(ah_weights);

    end = clock();
    cpu_time_used = ((double)(end - start)) / CLOCKS_PER_SEC;

    printf("Memory freed, used %f CPU time\n", cpu_time_used);
    return 0;
}
```
