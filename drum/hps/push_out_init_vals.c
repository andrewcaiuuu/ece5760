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
#define FIXED_CONSTANT = 131072

float center_peak = 0.75;
int rows = 30;
int cols = 30;
int damping = 9;
int tension = 4;

// ODE solver PIO base addresses
#define FPGA_CENTER_PEAK              0x00000000
#define FPGA_COLS                     0x00000010
#define FPGA_ROWS                     0x00000020
#define FPGA_DAMPING                  0x00000010
#define FPGA_TENSION                  0x00000020
#define FPGA_INCR                     0x00000030
void *h2p_lw_virtual_base;

// character buffer
volatile unsigned int * vga_char_ptr = NULL ;
void *vga_char_virtual_base;
volatile unsigned int * fpga_ack_ptr = NULL ;
volatile unsigned int * fpga_rdy_ptr = NULL ;
volatile unsigned int * fpga_out_ptr = NULL ;
volatile unsigned int * fpga_rows_ptr = NULL ;
volatile unsigned int * fpga_rho_gain_ptr = NULL;

void initPtrs(){
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
    fpga_ack_ptr      = (unsigned int * ) (h2p_lw_virtual_base + FPGA_ACK); //add offset to base address to get ACK PTR
    fpga_rdy_ptr      = (unsigned int * ) (h2p_lw_virtual_base + FPGA_RDY); 
    fpga_out_ptr      = (unsigned int * ) (h2p_lw_virtual_base + FPGA_OUT); 
    fpga_rows_ptr     = (unsigned int * ) (h2p_lw_virtual_base + FPGA_ROWS); 
    fpga_rho_gain_ptr = (unsigned int * ) (h2p_lw_virtual_base + FPGA_RHO_GAIN); 

}

void generateIncr()

int main()
{
    initPtrs();
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

