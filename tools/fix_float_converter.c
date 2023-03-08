// Online C compiler to run C program online
#include <stdio.h>
#define SCALE_CONST 8388608
int main() {
    // Write C code here
    // printf("Hello world");
    int fixed_input =  0x3233;
    // sign extend 
    fixed_input = ((fixed_input << 5) >> 5);
    float float_input =  ( (float) fixed_input / SCALE_CONST);
    int sanity = 20;
    printf("%.10f\n", float_input);
    printf("sanity: %x\n", sanity);
    
    return 0;
}