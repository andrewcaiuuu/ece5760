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
#define INIT_CLK_ADDR        0x00000030


#define NUMSOLV_ADDR        0x00000040
#define NUMITER_ADDR        0x00000050
#define RANGE_ADDR        0x00000060
#define NUM_CI_INCR        0x00000070
#define RESET_ADDR        0x00000080


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
volatile unsigned int * fpga_counter_ptr = NULL ;

volatile unsigned int * fpga_range_ptr = NULL ;
volatile unsigned int * fpga_max_iterations_ptr = NULL ;
volatile unsigned int * fpga_num_ci_incr_ptr = NULL ;
volatile unsigned int * fpga_num_solvers = NULL ;
volatile unsigned int * fpga_reset = NULL ;


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
    fpga_counter_ptr = (unsigned int * ) (h2p_lw_virtual_base + INIT_CLK_ADDR);


    fpga_range_ptr = (unsigned int * ) (h2p_lw_virtual_base + RANGE_ADDR) ;
    fpga_max_iterations_ptr = (unsigned int * ) (h2p_lw_virtual_base + NUMITER_ADDR) ;
    fpga_num_ci_incr_ptr = (unsigned int * ) (h2p_lw_virtual_base + NUM_CI_INCR) ;
    fpga_num_solvers = (unsigned int * ) (h2p_lw_virtual_base + NUMSOLV_ADDR);
    fpga_reset = (unsigned int * ) (h2p_lw_virtual_base + RESET_ADDR);


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

    int numSolvers = 10;
    int numIncrCI = 48;
    int range = 307200/numSolvers;
    int max_depth = 100;



    //*(fpga_range_ptr) = range;
    *(fpga_max_iterations_ptr) = max_depth;
    // /*(fpga_num_solvers) = numSolvers;
    //*(fpga_num_ci_incr_ptr) = numIncrCI;

    float incrI = 0.25;
    float incrR = 0.5;


	while(1){
        *(fpga_reset) = 0;
		printf("enter z for zoom, i for ci, r for cr, t for time, n to set numIters, l to change depth, WASD arrow to move around\n");
		scanf("%c", &input);
		if (input == 'z'){
            int prevZoom = zoom;
            printf("enter zoom \n");
			scanf("%d", &zoom);
			// fixed_zoom = zooms;
			*(fpga_zoom_ptr) = zoom;
            if(prevZoom < zoom){
                incrI = incrI/(zoom-prevZoom);
                incrR = incrI/(zoom-prevZoom);
            }
            else{
                incrI = incrI*(prevZoom-zoom);
                incrR = incrI*(prevZoom-zoom);
            }
            *(fpga_reset) = 1;
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
        else if (input == 't'){
            int raw_cycles = (*(fpga_counter_ptr));
            printf("cycle count: %d \n", raw_cycles);
            float cycle_time = (float)raw_cycles/50000000;
            printf("cycle time: %1.8f \n", cycle_time);

        }

        else if (input == 'n'){
            printf("input desired num solvers fewer than 10 \n");
			scanf("%d", &numSolvers);
            range = (int)307200/numSolvers;
            numIncrCI = (int)480/numSolvers;
            printf("NumIncrCI %d \n", numIncrCI);
            *(fpga_num_ci_incr_ptr) = numIncrCI;
            *(fpga_num_solvers) = numSolvers;
            *(fpga_range_ptr) = range;


        }

         else if (input == 'l'){
            printf("input desired max solver depth \n");
            scanf("%d", &max_depth);
            *(fpga_max_iterations_ptr) = max_depth;

        }

        else if (input == 'w'){
            *(fpga_reset) = 0;
            printf("Ci is %1.6f \n", ci);
           	//if(ci+incrI <=1.0){
                   ci = ci + incrI;
             //  }
            printf("New Ci is %1.6f \n", ci);

            fixed_ci = (int)ci * DIVISION_CONST;    
            *(fpga_init_ci_ptr) = fixed_ci;		
            *(fpga_reset) = 1;
        }

        else if (input == 's'){
            
            printf("Ci is %1.6f \n", ci);

           // if(ci-incrI >= -1){
                   ci = ci - (float)incrI;
             //  }
            printf("New Ci is %1.6f \n", ci);

            fixed_ci = (int)ci * DIVISION_CONST;    
            *(fpga_init_ci_ptr) = fixed_ci;		
            *(fpga_reset) = 1;
        }

        else if (input == 'a'){
            *(fpga_reset) = 1;
            printf("Cr is %1.6f \n", cr);

 //          	if(cr-incrR >= -2){
               cr = cr - incrR;
   //         }
            printf("new Cr is %1.6f \n", cr);

            fixed_cr = (int)cr * DIVISION_CONST;    
            *(fpga_init_cr_ptr) = fixed_cr;		
            *(fpga_reset) = 1;
        }
        else if (input == 'd'){
            *(fpga_reset) = 1;
           // printf("Cr is %1.6f \n", cr);

           	//if(cr+incrR <=2){
               cr = cr + incrR;
            //}
            printf("New Cr is %1.6f \n", cr);

            fixed_cr = (int)cr * DIVISION_CONST;    
            *(fpga_init_cr_ptr) = fixed_cr;		
            *(fpga_reset) = 1;
        }



	}
	return 0;
} // end main


