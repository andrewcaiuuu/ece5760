/******************************************************************************

                            Online C Compiler.
                Code, Compile, Run and Debug C program online.
Write your code in this editor and press "Run" button to compile and execute it.

*******************************************************************************/

#include <stdio.h>

#define FIXED_CONSTANT = 131072

float center_peak = 0.75;
int rows = 30;
int cols = 30;
int damping = 9;
int tension = 4;

int main()
{
    char input;
    while(1){
        printf("change params: \n p for peak value, r for rows, c for cols, d for damping, g for tension\n");
        scanf("%c", &input);
        if (input == 'p'){
            float new_center_peak;
            printf("enter center peak: \n");
            scanf("%f", &new_center_peak);
            center_peak = new_center_peak;
        
        } else if (input == 'r'){
            int new_rows;
            printf("enter rows: \n");
            scanf("%d", &new_rows);
            rows = new_rows;
            
        } else if (input == 'c'){
            int new_cols;
            printf("enter cols: \n");
            scanf("%d", &new_cols);
            cols = new_cols;
        }
        else if (input == 'd'){
            int new_damping;
            printf("enter damping: \n");
            scanf("%f", &new_damping);
            damping = new_damping;
        }
        else if (input == 'g'){
            int new_tension;
            printf("enter tension: \n");
            scanf("%f", &new_tension);
            tension = new_tension;
        }
    }
    return 0;
}

