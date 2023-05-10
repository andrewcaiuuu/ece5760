///////////////////////////////////////
/// 640x480 version! 16-bit color
/// This code will segfault the original
/// DE1 computer
/// compile with
/// gcc graphics_video_16bit.c -o gr -O2 -lm
/// gcc fpga_thread_art.c -o gr -O2 -lm -std=c99 -pthread
///////////////////////////////////////
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/ipc.h> 
#include <sys/shm.h> 
#include <sys/mman.h>
#include <sys/time.h> 
#include <math.h>
#include <stdint.h>
#include <pthread.h>
// #include "address_map_arm_brl4.h"

// video display
#define SDRAM_BASE            0xC0000000
#define SDRAM_END             0xC3FFFFFF
#define SDRAM_SPAN			  0x04000000
// characters
#define FPGA_CHAR_BASE        0xC9000000 
#define FPGA_CHAR_END         0xC9001FFF
#define FPGA_CHAR_SPAN        0x00002000
/* Cyclone V FPGA devices */
#define HW_REGS_BASE          0xff200000
//#define HW_REGS_SPAN        0x00200000 
#define HW_REGS_SPAN          0x00005000

// PIO BASE ADDRESSES
#define ARM_DATA_BASE   0x00000000
#define ARM_VAL_BASE    0x00000010
#define ARM_RDY_BASE    0x00000020

#define FPGA_DATA_BASE  0x00000030
#define FPGA_VAL_BASE   0x00000040
#define FPGA_RDY_BASE   0x00000050

#define PIO_RESET_BASE  0x00000060

#define ARM_ACK_BASE     0x00000070
#define FPGA_ACK_BASE    0x00000080

// IMAGE CONSTANTS
#define WHEEL_PIXEL_SIZE 480
#define N_HOOKS 160 // needs to be divisible by 2
#define HOOK_PIXEL_SIZE 3
#define ROWS 480
#define COLS 480
#define N_LINES 360
#define SPACE_SAVER 40 // defined as terms to actually consider

#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif

// PIO POINTERS
volatile unsigned int * arm_data_ptr  =  NULL;
volatile unsigned int * arm_val_ptr   =  NULL;
volatile unsigned int * arm_rdy_ptr   =  NULL;
volatile unsigned int * fpga_data_ptr =  NULL;
volatile unsigned int * fpga_val_ptr  =  NULL;
volatile unsigned int * fpga_rdy_ptr  =  NULL;
volatile unsigned int * pio_reset_ptr =  NULL;

volatile unsigned int * arm_ack_ptr   = NULL;
volatile unsigned int * fpga_ack_ptr  = NULL;


// HELPER STUFF
struct Tuple {
	int x;
	int y;
};

struct Node {
	struct Tuple data;
	struct Node *next;
};

struct LinkedList {
	struct Node *head;
	struct Node *tail;
};

struct LinkedList *initLinkedList() {
	struct LinkedList *list = (struct LinkedList *)malloc(sizeof(struct LinkedList));
	list->head = NULL;
	list->tail = NULL;
	return list;
}

void freeList(struct LinkedList *list) {
	struct Node *current = list->head;
	while (current != NULL)
	{
		struct Node *temp = current;
		current = current->next;
		free(temp);
	}
	free(list);
}

void append(struct LinkedList *list, struct Tuple data) {
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

void generate_hooks_with_size(struct Tuple *xy)
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

// NEW STUFF


void read_array(int *array, char *path) {
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

void *RESET()
{ // Reset Thread
	for (;;)
	{
		if (*(pio_reset_ptr))
		{
			*(arm_val_ptr) = 0;
			*(arm_rdy_ptr) = 0;
			*(arm_data_ptr) = 0;
			*(arm_ack_ptr) = 0;
			// printf("RESET HIT\n");
		}
	}
}

void *SERVICE_VERIFY(){
	int *ah_monochrome = malloc((ROWS * COLS) * sizeof(int));
	read_array(ah_monochrome, "ah_monochrome.txt");
	int count = 0;
	int mismatch_count = 0;
	for (int i = 0; i < ROWS/2; i++)
	{
		for (int j = 0; j < COLS; j++)
		{
			*(arm_ack_ptr) = 0;
			while ( ! *(fpga_val_ptr)) { // wait for valid data from FPGA
			}
			// printf("got: %d, expected: %d \n", *(fpga_data_ptr), ah_monochrome[i * COLS + j]);
			// printf("count: %d\n", count);
			uint32_t both = *(fpga_data_ptr);
			uint32_t bottom = both >> 10;
			uint32_t top = both & 0x00001FF; //9 bits
			if (top != ah_monochrome[i * COLS + j]){
				mismatch_count ++;
				printf("expected top: %d, got: %d\n", ah_monochrome[(i + 1) * COLS + j], bottom);
			}
			if (bottom != ah_monochrome[(i+1)*COLS + j]){
				mismatch_count ++;
				printf("expected bottom: %d, got: %d\n", ah_monochrome[(i+1)*COLS + j], bottom);
			}
			count ++;
			*(arm_ack_ptr) = 1; // ack the data
			while (! *(fpga_ack_ptr)) { // wait for FPGA to read ack
			}
			*(arm_ack_ptr) = 0; // reset ack
			while (*(fpga_ack_ptr )){ // wait for FPGA to reset ack
			}
		}
	}
	printf("MISMATCHES: %d\n", mismatch_count);
	free(ah_monochrome);
}

void *SERVICE_WRITE()
{
	int *ah_monochrome = malloc((ROWS * COLS) * sizeof(int));
	read_array(ah_monochrome, "ah_monochrome.txt");
	int count = 0;
	for (int i = 0; i < ROWS/2; i++)
	{
		for (int j = 0; j < COLS; j++)
		{
			// printf("count: %d\n", count);
			*(arm_val_ptr) = 0;
			uint16_t cur_top = (uint16_t)ah_monochrome[i * COLS + j];
			uint16_t cur_bot = (uint16_t)ah_monochrome[ (i + 1) * COLS + j];
			uint32_t is_last = (i == ROWS/2 - 1 && j == COLS - 1) << 31;
			uint32_t combined;
			combined = (((uint32_t)cur_bot << 10) | cur_top ) | is_last;
			// printf("is last %d\n", is_last);
			*(fpga_data_ptr) = combined;
			count++;


			*(arm_val_ptr) = 1; // try to transfer
			while ( !*(fpga_ack_ptr) ) { // wait for fpga to ack
			}
			*(arm_val_ptr) = 0; // clear our val

			// once acked, send clear flag, through the form of return ack
			*(arm_ack_ptr) = 1;
			while ( *(fpga_ack_ptr) ) { // wait for fpga to clear ack
			}
			*(arm_ack_ptr) = 0; // clear our ack and move onto next transfer
		}
	}
	printf("DONE WRITING MEM\n");
	free(ah_monochrome);
}

// void *SERVICE_CALC()
// {
// 	*(arm_val_ptr) = 0; // sanity check
// 	*(arm_ack_ptr) = 0; // sanity check
// 	struct Tuple *line_list = (struct Tuple *)malloc(N_LINES * sizeof(struct Tuple) * 2);
// 	struct Tuple *xy = (struct Tuple *)malloc(N_HOOKS * sizeof(struct Tuple));
// 	generate_hooks_with_size(xy);

// 	int prev_edge = rand() % N_HOOKS;
// 	for (int i = 0; i < N_LINES; i++){
// 		starting_edge = prev_edge;
// 		int *chosen = (int *)malloc(SPACE_SAVER * sizeof(int));
// 		generate_unique_random_numbers(0, N_HOOKS - 1, starting_edge, SPACE_SAVER, chosen);
		
// 		// have the randomly chosen indices to consider, transfer to fpga

// 		// FIRST TRANSFER THE STARTING POINT===============================
// 		*(arm_val_ptr) = 0;

// 		int is_last_line = i == N_LINES - 1;
// 		uint32_t combined;
// 		uint16_t x = (uint16_t)xy[starting_edge].x;
// 		uint16_t y = (uint16_t)xy[starting_edge].y;
// 		combined = ((uint32_t)is_last_line << 31) | (( (uint32_t) y << 16) | x); // bit 31 is is_last, bits 30-16 is y, bits 15-0 is x
// 		*(fpga_data_ptr) = combined;

// 		*(arm_val_ptr) = 1; // try to transfer
// 		while (!*(fpga_ack_ptr))
// 		{ // wait for fpga to ack
// 		}
// 		*(arm_val_ptr) = 0; // clear our val

// 		// once acked, send clear flag, through the form of return ack
// 		*(arm_ack_ptr) = 1;
// 		while (*(fpga_ack_ptr))
// 		{ // wait for fpga to clear ack
// 		}
// 		*(arm_ack_ptr) = 0; // clear our ack and move onto next transfer
// 		// FIRST TRANSFER THE STARTING POINT===============================

// 		for (int j = 0; j < SPACE_SAVER; j++){
// 			*(arm_val_ptr) = 0;
// 			int ending_edge = chosen[j];

// 			uint32_t is_last_chosen = j == SPACE_SAVER - 1;
// 			uint32_t combined_last = ((uint32_t)is_last_line << 31) | ((uint32_t)is_last_chosen << 15); 

// 			uint32_t combined;
// 			uint16_t x = (uint16_t)xy[ending_edge].x;
// 			uint16_t y = (uint16_t)xy[ending_edge].y;

// 			combined = combined_last | (( (uint32_t) y << 16) | x); // bit 31 is is_last, bits 30-16 is y, bit 15 is is_last, bits 14-0 is x
// 			*(fpga_data_ptr) = combined;
// 			*(arm_val_ptr) = 1; // try to transfer
// 			while (!*(fpga_ack_ptr))
// 			{ // wait for fpga to ack
// 			}
// 			*(arm_val_ptr) = 0; // clear our val

// 			// once acked, send clear flag, through the form of return ack
// 			*(arm_ack_ptr) = 1;
// 			while (*(fpga_ack_ptr))
// 			{ // wait for fpga to clear ack
// 			}
// 			*(arm_ack_ptr) = 0; // clear our ack and move onto next transfer
// 		}

// 		// values have been transferred, now wait for fpga to calculate
// 		*(arm_ack_ptr) = 0; // sanity check
// 		while (!*(fpga_val_ptr)) { // wait for valid data from FPGA
// 		}
// 		// update the values
// 		int best_edge = *(fpga_data_ptr);
// 		line_list[i * 2] = xy[starting_edge];
// 		line_list[i * 2 + 1] = xy[best_edge];

// 		*(arm_ack_ptr) = 1; // ack the data
// 		while (!*(fpga_ack_ptr))
// 		{ // wait for FPGA to read ack
// 		}
// 		*(arm_ack_ptr) = 0; // reset ack
// 		while (*(fpga_ack_ptr))
// 		{ // wait for FPGA to reset ack
// 		}
// 	}
// 	printf("DONE CALCULATING\n");


// 	// Open the file for writing
// 	printf("WRITING OUTPUT FILE\n");
// 	FILE *file = fopen("fpga_output.txt", "w");
// 	if (file == NULL)
// 	{
// 		printf("Error opening the file.\n");
// 		return 1;
// 	}
// 	// Write the array elements to the file
// 	for (int i = 0; i < N_LINES; i++)
// 	{
// 		fprintf(file, "%d", line_list[i * 2].x);
// 		fprintf(file, " %d", line_list[i * 2].y);
// 		fprintf(file, " %d", line_list[i * 2 + 1].x);
// 		fprintf(file, " %d", line_list[i * 2 + 1].y);
// 		// Use a newline character instead of a comma to separate elements
// 		if (i < N_LINES - 1)
// 		{
// 			fprintf(file, "\n");
// 		}
// 	}
// 	// Close the file
// 	fclose(file);

// 	printf("DONE WRITING\n");

// 	free(xy);
// 	free(line_list);
// }

// graphics primitives
void VGA_text (int, int, char *);
void VGA_text_clear();
void VGA_box (int, int, int, int, short);
void VGA_rect (int, int, int, int, short);
void VGA_line(int, int, int, int, short) ;
void VGA_Vline(int, int, int, short) ;
void VGA_Hline(int, int, int, short) ;
void VGA_disc (int, int, int, short);
void VGA_circle (int, int, int, int);
// 16-bit primary colors
#define red  (0+(0<<5)+(31<<11))
#define dark_red (0+(0<<5)+(15<<11))
#define green (0+(63<<5)+(0<<11))
#define dark_green (0+(31<<5)+(0<<11))
#define blue (31+(0<<5)+(0<<11))
#define dark_blue (15+(0<<5)+(0<<11))
#define yellow (0+(63<<5)+(31<<11))
#define cyan (31+(63<<5)+(0<<11))
#define magenta (31+(0<<5)+(31<<11))
#define black (0x0000)
#define gray (15+(31<<5)+(51<<11))
#define white (0xffff)
int colors[] = {red, dark_red, green, dark_green, blue, dark_blue, 
		yellow, cyan, magenta, gray, black, white};

// pixel macro
#define VGA_PIXEL(x,y,color) do{\
	int  *pixel_ptr ;\
	pixel_ptr = (int*)((char *)vga_pixel_ptr + (((y)*640+(x))<<1)) ; \
	*(short *)pixel_ptr = (color);\
} while(0)

// the light weight buss base
void *h2p_lw_virtual_base;

// pixel buffer
volatile unsigned int * vga_pixel_ptr = NULL ;
void *vga_pixel_virtual_base;

// character buffer
volatile unsigned int * vga_char_ptr = NULL ;
void *vga_char_virtual_base;

// /dev/mem file id
int fd;

// measure time
struct timeval t1, t2;
double elapsedTime;
	
int main(void)
{
  	
	// === need to mmap: =======================
	// FPGA_CHAR_BASE
	// FPGA_ONCHIP_BASE      
	// HW_REGS_BASE        
  
	// === get FPGA addresses ==================
    // Open /dev/mem
	if( ( fd = open( "/dev/mem", ( O_RDWR | O_SYNC ) ) ) == -1 ) 	{
		printf( "ERROR: could not open \"/dev/mem\"...\n" );
		return( 1 );
	}
    
    // get virtual addr that maps to physical
	h2p_lw_virtual_base = mmap( NULL, HW_REGS_SPAN, ( PROT_READ | PROT_WRITE ), MAP_SHARED, fd, HW_REGS_BASE );	
	if( h2p_lw_virtual_base == MAP_FAILED ) {
		printf( "ERROR: mmap1() failed...\n" );
		close( fd );
		return(1);
	}
    
	// map PIO
	arm_data_ptr =(unsigned int *)(h2p_lw_virtual_base + ARM_DATA_BASE);
	arm_val_ptr =(unsigned int *)(h2p_lw_virtual_base + ARM_VAL_BASE);
	arm_rdy_ptr =(unsigned int *)(h2p_lw_virtual_base + ARM_RDY_BASE);
	fpga_data_ptr =(unsigned int *)(h2p_lw_virtual_base + FPGA_DATA_BASE);
	fpga_val_ptr =(unsigned int *)(h2p_lw_virtual_base + FPGA_VAL_BASE);
	fpga_rdy_ptr =(unsigned int *)(h2p_lw_virtual_base + FPGA_RDY_BASE);
	pio_reset_ptr =(unsigned int *)(h2p_lw_virtual_base + PIO_RESET_BASE);

	arm_ack_ptr = (unsigned int *)(h2p_lw_virtual_base + ARM_ACK_BASE);
	fpga_ack_ptr = (unsigned int *)(h2p_lw_virtual_base + FPGA_ACK_BASE);
	// === get VGA char addr =====================
	// get virtual addr that maps to physical
	vga_char_virtual_base = mmap( NULL, FPGA_CHAR_SPAN, ( 	PROT_READ | PROT_WRITE ), MAP_SHARED, fd, FPGA_CHAR_BASE );	
	if( vga_char_virtual_base == MAP_FAILED ) {
		printf( "ERROR: mmap2() failed...\n" );
		close( fd );
		return(1);
	}
    
    // Get the address that maps to the FPGA LED control 
	vga_char_ptr =(unsigned int *)(vga_char_virtual_base);

	// === get VGA pixel addr ====================
	// get virtual addr that maps to physical
	vga_pixel_virtual_base = mmap( NULL, SDRAM_SPAN, ( PROT_READ | PROT_WRITE ), MAP_SHARED, fd, SDRAM_BASE);	
	if( vga_pixel_virtual_base == MAP_FAILED ) {
		printf( "ERROR: mmap3() failed...\n" );
		close( fd );
		return(1);
	}
    
    // Get the address that maps to the FPGA pixel buffer
	vga_pixel_ptr =(unsigned int *)(vga_pixel_virtual_base);

	// ===========================================

	/* create a message to be displayed on the VGA 
          and LCD displays */
	
	// position of disk primitive
	int disc_x = 0;
	// position of circle primitive
	int circle_x = 0 ;
	// position of box primitive
	int box_x = 5 ;
	// position of vertical line primitive
	int Vline_x = 350;
	// position of horizontal line primitive
	int Hline_y = 250;

	// clear the screen
	VGA_box (0, 0, 639, 479, 0x0000);
	// clear the text
	VGA_text_clear();
	
	// R bits 11-15 mask 0xf800
	// G bits 5-10  mask 0x07e0
	// B bits 0-4   mask 0x001f
	// so color = B+(G<<5)+(R<<11);

	pthread_t thread_reset;

	pthread_create(&thread_reset, NULL, RESET, NULL);

	

	while(1) 
	{
		*(arm_val_ptr) = 0;
		*(arm_rdy_ptr) = 0;
		*(arm_data_ptr) = 0;
		*(arm_ack_ptr) = 0;
		printf("press w to write FPGA memory, v to verify FPGA memory \n");
		char input;
		if (scanf("%c", &input))
		{
			if (input == 'v'){
				pthread_t service_verify;
				pthread_create(&service_verify, NULL, SERVICE_VERIFY, NULL);
				pthread_join(service_verify, NULL);

			}

			if (input == 'w'){
				pthread_t service_write;
				pthread_create(&service_write, NULL, SERVICE_WRITE, NULL);
				pthread_join(service_write, NULL);
			}
		}

	} // end while(1)

	pthread_join(thread_reset, NULL);
} // end main

/****************************************************************************************
 * Subroutine to send a string of text to the VGA monitor 
****************************************************************************************/
void VGA_text(int x, int y, char * text_ptr)
{
  	volatile char * character_buffer = (char *) vga_char_ptr ;	// VGA character buffer
	int offset;
	/* assume that the text string fits on one line */
	offset = (y << 7) + x;
	while ( *(text_ptr) )
	{
		// write to the character buffer
		*(character_buffer + offset) = *(text_ptr);	
		++text_ptr;
		++offset;
	}
}

/****************************************************************************************
 * Subroutine to clear text to the VGA monitor 
****************************************************************************************/
void VGA_text_clear()
{
  	volatile char * character_buffer = (char *) vga_char_ptr ;	// VGA character buffer
	int offset, x, y;
	for (x=0; x<79; x++){
		for (y=0; y<59; y++){
	/* assume that the text string fits on one line */
			offset = (y << 7) + x;
			// write to the character buffer
			*(character_buffer + offset) = ' ';		
		}
	}
}

/****************************************************************************************
 * Draw a filled rectangle on the VGA monitor 
****************************************************************************************/
#define SWAP(X,Y) do{int temp=X; X=Y; Y=temp;}while(0) 

void VGA_box(int x1, int y1, int x2, int y2, short pixel_color)
{
	char  *pixel_ptr ; 
	int row, col;

	/* check and fix box coordinates to be valid */
	if (x1>639) x1 = 639;
	if (y1>479) y1 = 479;
	if (x2>639) x2 = 639;
	if (y2>479) y2 = 479;
	if (x1<0) x1 = 0;
	if (y1<0) y1 = 0;
	if (x2<0) x2 = 0;
	if (y2<0) y2 = 0;
	if (x1>x2) SWAP(x1,x2);
	if (y1>y2) SWAP(y1,y2);
	for (row = y1; row <= y2; row++)
		for (col = x1; col <= x2; ++col)
		{
			//640x480
			//pixel_ptr = (char *)vga_pixel_ptr + (row<<10)    + col ;
			// set pixel color
			//*(char *)pixel_ptr = pixel_color;	
			VGA_PIXEL(col,row,pixel_color);	
		}
}

/****************************************************************************************
 * Draw a outline rectangle on the VGA monitor 
****************************************************************************************/
#define SWAP(X,Y) do{int temp=X; X=Y; Y=temp;}while(0) 

void VGA_rect(int x1, int y1, int x2, int y2, short pixel_color)
{
	char  *pixel_ptr ; 
	int row, col;

	/* check and fix box coordinates to be valid */
	if (x1>639) x1 = 639;
	if (y1>479) y1 = 479;
	if (x2>639) x2 = 639;
	if (y2>479) y2 = 479;
	if (x1<0) x1 = 0;
	if (y1<0) y1 = 0;
	if (x2<0) x2 = 0;
	if (y2<0) y2 = 0;
	if (x1>x2) SWAP(x1,x2);
	if (y1>y2) SWAP(y1,y2);
	// left edge
	col = x1;
	for (row = y1; row <= y2; row++){
		//640x480
		//pixel_ptr = (char *)vga_pixel_ptr + (row<<10)    + col ;
		// set pixel color
		//*(char *)pixel_ptr = pixel_color;	
		VGA_PIXEL(col,row,pixel_color);		
	}
		
	// right edge
	col = x2;
	for (row = y1; row <= y2; row++){
		//640x480
		//pixel_ptr = (char *)vga_pixel_ptr + (row<<10)    + col ;
		// set pixel color
		//*(char *)pixel_ptr = pixel_color;	
		VGA_PIXEL(col,row,pixel_color);		
	}
	
	// top edge
	row = y1;
	for (col = x1; col <= x2; ++col){
		//640x480
		//pixel_ptr = (char *)vga_pixel_ptr + (row<<10)    + col ;
		// set pixel color
		//*(char *)pixel_ptr = pixel_color;	
		VGA_PIXEL(col,row,pixel_color);
	}
	
	// bottom edge
	row = y2;
	for (col = x1; col <= x2; ++col){
		//640x480
		//pixel_ptr = (char *)vga_pixel_ptr + (row<<10)    + col ;
		// set pixel color
		//*(char *)pixel_ptr = pixel_color;
		VGA_PIXEL(col,row,pixel_color);
	}
}

/****************************************************************************************
 * Draw a horixontal line on the VGA monitor 
****************************************************************************************/
#define SWAP(X,Y) do{int temp=X; X=Y; Y=temp;}while(0) 

void VGA_Hline(int x1, int y1, int x2, short pixel_color)
{
	char  *pixel_ptr ; 
	int row, col;

	/* check and fix box coordinates to be valid */
	if (x1>639) x1 = 639;
	if (y1>479) y1 = 479;
	if (x2>639) x2 = 639;
	if (x1<0) x1 = 0;
	if (y1<0) y1 = 0;
	if (x2<0) x2 = 0;
	if (x1>x2) SWAP(x1,x2);
	// line
	row = y1;
	for (col = x1; col <= x2; ++col){
		//640x480
		//pixel_ptr = (char *)vga_pixel_ptr + (row<<10)    + col ;
		// set pixel color
		//*(char *)pixel_ptr = pixel_color;	
		VGA_PIXEL(col,row,pixel_color);		
	}
}

/****************************************************************************************
 * Draw a vertical line on the VGA monitor 
****************************************************************************************/
#define SWAP(X,Y) do{int temp=X; X=Y; Y=temp;}while(0) 

void VGA_Vline(int x1, int y1, int y2, short pixel_color)
{
	char  *pixel_ptr ; 
	int row, col;

	/* check and fix box coordinates to be valid */
	if (x1>639) x1 = 639;
	if (y1>479) y1 = 479;
	if (y2>479) y2 = 479;
	if (x1<0) x1 = 0;
	if (y1<0) y1 = 0;
	if (y2<0) y2 = 0;
	if (y1>y2) SWAP(y1,y2);
	// line
	col = x1;
	for (row = y1; row <= y2; row++){
		//640x480
		//pixel_ptr = (char *)vga_pixel_ptr + (row<<10)    + col ;
		// set pixel color
		//*(char *)pixel_ptr = pixel_color;	
		VGA_PIXEL(col,row,pixel_color);			
	}
}


/****************************************************************************************
 * Draw a filled circle on the VGA monitor 
****************************************************************************************/

void VGA_disc(int x, int y, int r, short pixel_color)
{
	char  *pixel_ptr ; 
	int row, col, rsqr, xc, yc;
	
	rsqr = r*r;
	
	for (yc = -r; yc <= r; yc++)
		for (xc = -r; xc <= r; xc++)
		{
			col = xc;
			row = yc;
			// add the r to make the edge smoother
			if(col*col+row*row <= rsqr+r){
				col += x; // add the center point
				row += y; // add the center point
				//check for valid 640x480
				if (col>639) col = 639;
				if (row>479) row = 479;
				if (col<0) col = 0;
				if (row<0) row = 0;
				//pixel_ptr = (char *)vga_pixel_ptr + (row<<10) + col ;
				// set pixel color
				//*(char *)pixel_ptr = pixel_color;
				VGA_PIXEL(col,row,pixel_color);	
			}
					
		}
}

/****************************************************************************************
 * Draw a  circle on the VGA monitor 
****************************************************************************************/

void VGA_circle(int x, int y, int r, int pixel_color)
{
	char  *pixel_ptr ; 
	int row, col, rsqr, xc, yc;
	int col1, row1;
	rsqr = r*r;
	
	for (yc = -r; yc <= r; yc++){
		//row = yc;
		col1 = (int)sqrt((float)(rsqr + r - yc*yc));
		// right edge
		col = col1 + x; // add the center point
		row = yc + y; // add the center point
		//check for valid 640x480
		if (col>639) col = 639;
		if (row>479) row = 479;
		if (col<0) col = 0;
		if (row<0) row = 0;
		//pixel_ptr = (char *)vga_pixel_ptr + (row<<10) + col ;
		// set pixel color
		//*(char *)pixel_ptr = pixel_color;
		VGA_PIXEL(col,row,pixel_color);	
		// left edge
		col = -col1 + x; // add the center point
		//check for valid 640x480
		if (col>639) col = 639;
		if (row>479) row = 479;
		if (col<0) col = 0;
		if (row<0) row = 0;
		//pixel_ptr = (char *)vga_pixel_ptr + (row<<10) + col ;
		// set pixel color
		//*(char *)pixel_ptr = pixel_color;
		VGA_PIXEL(col,row,pixel_color);	
	}
	for (xc = -r; xc <= r; xc++){
		//row = yc;
		row1 = (int)sqrt((float)(rsqr + r - xc*xc));
		// right edge
		col = xc + x; // add the center point
		row = row1 + y; // add the center point
		//check for valid 640x480
		if (col>639) col = 639;
		if (row>479) row = 479;
		if (col<0) col = 0;
		if (row<0) row = 0;
		//pixel_ptr = (char *)vga_pixel_ptr + (row<<10) + col ;
		// set pixel color
		//*(char *)pixel_ptr = pixel_color;
		VGA_PIXEL(col,row,pixel_color);	
		// left edge
		row = -row1 + y; // add the center point
		//check for valid 640x480
		if (col>639) col = 639;
		if (row>479) row = 479;
		if (col<0) col = 0;
		if (row<0) row = 0;
		//pixel_ptr = (char *)vga_pixel_ptr + (row<<10) + col ;
		// set pixel color
		//*(char *)pixel_ptr = pixel_color;
		VGA_PIXEL(col,row,pixel_color);	
	}
}

// =============================================
// === Draw a line
// =============================================
//plot a line 
//at x1,y1 to x2,y2 with color 
//Code is from David Rodgers,
//"Procedural Elements of Computer Graphics",1985
void VGA_line(int x1, int y1, int x2, int y2, short c) {
	int e;
	signed int dx,dy,j, temp;
	signed int s1,s2, xchange;
     signed int x,y;
	char *pixel_ptr ;
	
	/* check and fix line coordinates to be valid */
	if (x1>639) x1 = 639;
	if (y1>479) y1 = 479;
	if (x2>639) x2 = 639;
	if (y2>479) y2 = 479;
	if (x1<0) x1 = 0;
	if (y1<0) y1 = 0;
	if (x2<0) x2 = 0;
	if (y2<0) y2 = 0;
        
	x = x1;
	y = y1;
	
	//take absolute value
	if (x2 < x1) {
		dx = x1 - x2;
		s1 = -1;
	}

	else if (x2 == x1) {
		dx = 0;
		s1 = 0;
	}

	else {
		dx = x2 - x1;
		s1 = 1;
	}

	if (y2 < y1) {
		dy = y1 - y2;
		s2 = -1;
	}

	else if (y2 == y1) {
		dy = 0;
		s2 = 0;
	}

	else {
		dy = y2 - y1;
		s2 = 1;
	}

	xchange = 0;   

	if (dy>dx) {
		temp = dx;
		dx = dy;
		dy = temp;
		xchange = 1;
	} 

	e = ((int)dy<<1) - dx;  
	 
	for (j=0; j<=dx; j++) {
		//video_pt(x,y,c); //640x480
		//pixel_ptr = (char *)vga_pixel_ptr + (y<<10)+ x; 
		// set pixel color
		//*(char *)pixel_ptr = c;
		VGA_PIXEL(x,y,c);			
		 
		if (e>=0) {
			if (xchange==1) x = x + s1;
			else y = y + s2;
			e = e - ((int)dx<<1);
		}

		if (xchange==1) y = y + s2;
		else x = x + s1;

		e = e + ((int)dy<<1);
	}
}
// BOTTOM