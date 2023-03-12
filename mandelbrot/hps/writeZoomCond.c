///////////////////////////////////////
/// 640x480 version! 16-bit color
/// This code will segfault the original
/// DE1 computer
/// compile with
/// gcc finalGraphics.c -o final -O2 -lm
///
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
#include <stdio.h>
#include <pthread.h>
#include <semaphore.h>
#include <stdlib.h>


/* Cyclone V FPGA devices */
#define HW_REGS_BASE          0xff200000
//#define HW_REGS_SPAN        0x00200000 
#define HW_REGS_SPAN          0x00005000 

// ODE solver PIO base addresses
#define ZOOM_ADDR        0x00000000
#define INIT_CR_ADDR        0x00000010
#define INIT_CI_ADDR        0x00000020



#define DIVISION_CONST        8388608


// the light weight buss base
void *h2p_lw_virtual_base;

// character buffer
volatile unsigned int * vga_char_ptr = NULL ;
void *vga_char_virtual_base;

// ode stuff
volatile unsigned int * fpga_zoom_ptr = NULL ;
volatile unsigned int * fpga_init_cr_ptr = NULL ;
volatile unsigned int * fpga_init_ci_ptr = NULL ;


int fd;

// measure time
struct timeval t1, t2;
double elapsedTime;


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
    
    
	//Sets PTRS based on HPS memory map

	fpga_zoom_ptr = (unsigned int * ) (h2p_lw_virtual_base + ZOOM_ADDR); //Ptr for X register
	fpga_init_cr_ptr = (unsigned int * ) (h2p_lw_virtual_base + INIT_CR_ADDR); //
	fpga_init_ci_ptr = (unsigned int * ) (h2p_lw_virtual_base + INIT_CI_ADDR);

}	
int main(void)
{
    initPtrs();// Initialize all ptrs

  	//Declare values to be inputted

    int fixed_zoom;
    int fixed_cr;
    int fixed_ci;


    int zoom;
    float cr;
    float ci;
	char input;




	while(1){
		printf("enter z for zoom, i for ci, r for cr \n");
		scanf("%c", &input);
		if (input == 'z'){
            printf("enter zoom \n");
			scanf("%d", &zoom);
			// fixed_zoom = zooms;
			*(fpga_zoom_ptr) = zoom;
		
		}
		else if (input == 'i'){
            printf("enter ci \n");
			scanf("%f", &ci);
            fixed_ci = (int)ci * DIVISION_CONST;    
            *(fpga_init_ci_ptr) = fixed_ci;		
        }
		else if (input == 'r'){
            printf("enter cr \n");
			scanf("%f", &cr);
            fixed_cr = (int)cr * DIVISION_CONST;    
            *(fpga_init_cr_ptr) = fixed_cr;		
        }

	}
	return 0;
} // end main



