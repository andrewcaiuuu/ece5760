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

// ODE solver PIO base addresses
#define FPGA_ACK              0x00000000
#define FPGA_RDY              0x00000010
#define FPGA_OUT              0x00000020
#define FPGA_ROWS             0x00000010
#define FPGA_RHO_GAIN         0x00000020

volatile unsigned int * fpga_ack_ptr = NULL ;
volatile unsigned int * fpga_rdy_ptr = NULL ;
volatile unsigned int * fpga_out_ptr = NULL ;
volatile unsigned int * fpga_rows_ptr = NULL ;
volatile unsigned int * fpga_rho_gain_ptr = NULL;


fpga_ack_ptr      = (unsigned int * ) (h2p_lw_virtual_base + FPGA_ACK); //add offset to base address to get ACK PTR
fpga_rdy_ptr      = (unsigned int * ) (h2p_lw_virtual_base + FPGA_RDY); 
fpga_out_ptr      = (unsigned int * ) (h2p_lw_virtual_base + FPGA_OUT); 
fpga_rows_ptr     = (unsigned int * ) (h2p_lw_virtual_base + FPGA_ROWS); 
fpga_rho_gain_ptr = (unsigned int * ) (h2p_lw_virtual_base + FPGA_RHO_GAIN); 
