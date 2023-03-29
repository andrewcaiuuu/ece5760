///////////////////////////////////////
/// 640x480 version! 16-bit color
/// This code will segfault the original
/// DE1 computer
/// compile with
/// gcc push_out_init_vals.c -o drum -O2 -lm
///

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
#include <stdio.h>
#include <pthread.h>
#include <semaphore.h>
#include <stdlib.h>

// characters
#define FPGA_CHAR_BASE        0xC9000000
#define FPGA_CHAR_END         0xC9001FFF
#define FPGA_CHAR_SPAN        0x00002000
/* Cyclone V FPGA devices */
#define HW_REGS_BASE          0xff200000
//#define HW_REGS_SPAN        0x00200000
#define HW_REGS_SPAN          0x00005000
#define FIXED_CONSTANT        131072

float center_peak = 0.75;
int rows = 30;
int cols = 30;
int damping = 11;
int tension = 4;
int incr = 0xDA;

// ODE solver PIO base addresses
#define FPGA_CENTER_PEAK              0x00000000
#define FPGA_COLS                     0x00000010
#define FPGA_ROWS                     0x00000020
#define FPGA_DAMPING                  0x00000030
#define FPGA_TENSION                  0x00000040
#define FPGA_INCR                     0x00000050
void *h2p_lw_virtual_base;
int fd;
// character buffer
volatile unsigned int * vga_char_ptr = NULL ;
void *vga_char_virtual_base;
volatile unsigned int * center_peak_ptr = NULL ;
volatile unsigned int * col_ptr         = NULL ;
volatile unsigned int * row_ptr         = NULL ;
volatile unsigned int * damping_ptr     = NULL ;
volatile unsigned int * tension_ptr     = NULL ;
volatile unsigned int * incr_ptr        = NULL ;

int recompute_incr()
{
    float intermediate = center_peak / rows;
    float result = intermediate / cols;
    int new_incr = result * FIXED_CONSTANT;
    incr = new_incr;
    return 0;
}
int initPtrs(){
    // === need to mmap: =======================
        // FPGA_CHAR_BASE
        // FPGA_ONCHIP_BASE
        // HW_REGS_BASE

        // === get FPGA addresses ==================
    // Open /dev/mem
        if( ( fd = open( "/dev/mem", ( O_RDWR | O_SYNC ) ) ) == -1 )    {
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

    center_peak_ptr   = (unsigned int * ) (h2p_lw_virtual_base + FPGA_CENTER_PEAK);
    col_ptr           = (unsigned int * ) (h2p_lw_virtual_base + FPGA_COLS);
    row_ptr           = (unsigned int * ) (h2p_lw_virtual_base + FPGA_ROWS);
    damping_ptr       = (unsigned int * ) (h2p_lw_virtual_base + FPGA_DAMPING);
    tension_ptr       = (unsigned int * ) (h2p_lw_virtual_base + FPGA_TENSION);
    incr_ptr          = (unsigned int * ) (h2p_lw_virtual_base + FPGA_INCR);

}

int main()
{
    initPtrs();
    char input;
    while(1){
        printf("change params: \n p for peak value, r for rows, c for cols, d for damping, g for tension\n");
        if (scanf("%c", &input)){
            if (input == 'p'){
                float new_center_peak;
                printf("enter center peak: \n");
                if (scanf("%f", &new_center_peak)){
                    center_peak = new_center_peak;
                    recompute_incr();
                }
                else{
                    printf("error reading input");
                }
            } else if (input == 'r'){
                int new_rows;
                printf("enter rows: \n");
                if (scanf("%d", &new_rows)){
                    rows = new_rows;
                }
                else{
                    printf("error reading input");
                }
            } else if (input == 'c'){
                int new_cols;
                printf("enter cols: \n");
                if (scanf("%d", &new_cols)){
                    cols = new_cols;
                }
                else{
                    printf("error reading input");
                }
            }
            else if (input == 'd'){
                int new_damping;
                printf("enter damping: \n");
                if (scanf("%d", &new_damping)){
                    damping = new_damping;
                }
                else{
                    printf("error reading input");
                }
            }
            else if (input == 'g'){
                int new_tension;
                printf("enter tension: \n");
                if (scanf("%d", &new_tension)){
                    tension = new_tension;
                }
                else{
                    printf("error reading input");
                }
            }

        }
        else{
            printf("error reading input");
        }
        *(center_peak_ptr) = (int) (center_peak);
        *(col_ptr) = cols;
        *(row_ptr) = rows;
        *(damping_ptr) = damping;
        *(tension_ptr) = tension;
        *(incr_ptr) = incr;
        printf("wrote out increment of %x \n", incr);
    }
    return 0;
}
