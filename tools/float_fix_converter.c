// Online C compiler to run C program online
#include <stdio.h>
#define SCALE_CONST 8388608
int main() {
    // Write C code here
    // printf("Hello world");
    float float_input =  0.4;
    int fixed_input = (int) (float_input * SCALE_CONST);
    int sanity = 20;
    printf("%x\n", fixed_input);
    printf("sanity: %x\n", sanity);
    
    return 0;
}