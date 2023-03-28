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

int main()
{
    char input;
    while(1){
        printf("c to change params, p to play drum: \n");
        scanf("%c", &input);
        if (input == 'c'){
            float new_center_peak;
            printf("enter center peak: \n");
            scanf("%f", &new_center_peak);
            center_peak = new_center_peak;
            
            int new_rows;
            printf("enter rows: \n");
            scanf("%d", &new_rows);
            rows = new_rows;
            
            int new_cols;
            printf("enter cols: \n");
            scanf("%d", &new_cols);
            cols = new_cols;
        }
        else if (input == 'p'){
            printf("DO PLAY with row = %d, col = %d, peak = %f \n", rows, cols, center_peak);
        }
    }
    return 0;
}

