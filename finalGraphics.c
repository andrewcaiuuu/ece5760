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


//#include "address_map_arm_brl4.h"

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

// ODE solver PIO base addresses
#define FPGA_XOUT_BASE        0x00000000
#define FPGA_YOUT_BASE        0x00000010
#define FPGA_ZOUT_BASE        0x00000020
#define FPGA_CLK_BASE         0x00000030
#define FPGA_RESET_BASE       0x00000040

#define FPGA_INIT_X_BASE      0x00000050
#define FPGA_INIT_Y_BASE      0x00000060
#define FPGA_INIT_Z_BASE      0x00000070
#define FPGA_RHO_BASE    0x00000080
#define FPGA_BETA_BASE   0x00000090
#define FPGA_SIGMA_BASE  0x000000a0

#define DIVISION_CONST        1048576

// graphics primitives
void VGA_text (int, int, char *);
void VGA_text_clear();
void VGA_box (int, int, int, int, short);
void VGA_sine (double, short);
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

// ode stuff
volatile unsigned int * fpga_x_ptr = NULL ;
volatile unsigned int * fpga_y_ptr = NULL ;
volatile unsigned int * fpga_z_ptr = NULL ;
volatile unsigned int * fpga_reset_ptr = NULL;
volatile unsigned int * fpga_clk_ptr = NULL;

volatile unsigned int * fpga_initial_x_ptr = NULL;
volatile unsigned int * fpga_initial_y_ptr = NULL;
volatile unsigned int * fpga_initial_z_ptr = NULL;
volatile unsigned int * fpga_sigma_ptr = NULL;
volatile unsigned int * fpga_rho_ptr = NULL;
volatile unsigned int * fpga_beta_ptr = NULL;

volatile int reset_lock = 1;

volatile int pause_lock = 1;

int draw_speed = 1;

//Define values for saving state during pause
int last_raw_xvalue; 
int last_raw_yvalue; 
int last_raw_zvalue; 

sem_t reset_done; // tells draw that reset is done
sem_t draw_cycle_done; // tells reset that one draw cycle done

// /dev/mem file id
int fd;

// measure time
struct timeval t1, t2;
double elapsedTime;


void * RESET() //Reset Thread
{
	while (1){
		if (!reset_lock){
			//printf("im resetting");
			
			// clear the screen
			VGA_box (0, 0, 639, 479, 0x0000);
			//set default values

			*(fpga_reset_ptr) = 0; //Aquire the lock
			//usleep(1700);
			while (*(fpga_clk_ptr) != 1){ //wait until reset behavior has completed
			}
			*(fpga_reset_ptr) = 1;
			

			reset_lock = 1;
		}
	}

}

//Draw Thread
void * DO_DRAW()
{
	while(1) 
	{

		if(pause_lock){

			*(fpga_clk_ptr) = 1;
			*(fpga_clk_ptr) = 0;

			/* NEW STUFF HERE*/

			int raw_xvalue = (*(fpga_x_ptr));
			int raw_yvalue = (*(fpga_y_ptr));
			int raw_zvalue = (*(fpga_z_ptr));

			int xvalue = (float) (raw_xvalue * 3) / DIVISION_CONST;
			int yvalue = (float) (raw_yvalue * 3) / DIVISION_CONST;
			int zvalue = (float) (raw_zvalue * 3) / DIVISION_CONST;

			//Ensure all coordinates in screen range to avoid seg faults
			if((106+xvalue)<640 && (119+yvalue)<480 && (106+xvalue)>=0 && (119+yvalue)>=0) 
				VGA_PIXEL(106+xvalue, 119+yvalue, red);
			if((532+yvalue)<640 && (119+zvalue) < 480 && (532+yvalue)>=0 && (119+zvalue)>=0)
				VGA_PIXEL(532+yvalue, 119+zvalue, blue);
			if((319+xvalue)<640 && (300+zvalue) < 480 && (319+xvalue)>=0 && (300+zvalue)>=0)
				VGA_PIXEL(319+xvalue, 300+zvalue, green);


			gettimeofday(&t1, NULL);


			gettimeofday(&t2, NULL);
			elapsedTime = (t2.tv_sec - t1.tv_sec) * 1000000.0;      // sec to us
			elapsedTime += (t2.tv_usec - t1.tv_usec) ;   // us 

			usleep((int)17000 / draw_speed);
		} // end while(1)
	}
}

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
	fpga_clk_ptr = (unsigned int * ) (h2p_lw_virtual_base + FPGA_CLK_BASE); //add offset to base address to get CLK PTR
	fpga_reset_ptr = (unsigned int * ) (h2p_lw_virtual_base + FPGA_RESET_BASE); //add RESET_BASE
	fpga_x_ptr = (unsigned int * ) (h2p_lw_virtual_base + FPGA_XOUT_BASE); //Ptr for X register
	fpga_y_ptr = (unsigned int * ) (h2p_lw_virtual_base + FPGA_YOUT_BASE); //
	fpga_z_ptr = (unsigned int * ) (h2p_lw_virtual_base + FPGA_ZOUT_BASE);

	fpga_initial_x_ptr = (unsigned int * ) (h2p_lw_virtual_base + FPGA_INIT_X_BASE); //Ptr to input for initial_x
	fpga_initial_y_ptr = (unsigned int * ) (h2p_lw_virtual_base + FPGA_INIT_Y_BASE); //Ptr to input for initial_y
	fpga_initial_z_ptr = (unsigned int * ) (h2p_lw_virtual_base + FPGA_INIT_Z_BASE); //Ptr to input for initial_z
	fpga_sigma_ptr = (unsigned int * ) (h2p_lw_virtual_base + FPGA_SIGMA_BASE); //Ptr to address to input sigma 
	fpga_beta_ptr = (unsigned int * ) (h2p_lw_virtual_base + FPGA_BETA_BASE); // Ptr to beta input address
	fpga_rho_ptr = (unsigned int * ) (h2p_lw_virtual_base + FPGA_RHO_BASE); //Ptr to Rho input address


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
}	
int main(void)
{
    initPtrs();// Initialize all ptrs

  	//Declare values to be inputted
    float x;
    float y;
    float z;
    int fixed_x;
    int fixed_y;
    int fixed_z;
    float rho;
    float beta;
    float sigma;
    int fixed_rho;
    int fixed_beta; 
    int fixed_sigma; 

//Initilize values to display rho, beta, sigma values 
    int new_rho;
    int new_beta;
    int new_sigma;
    char rho_str[20];
    char beta_str[20];
    char sigma_str[20];




	/* create a message to be displayed on the VGA 
          and LCD displays */


	char num_string[20], time_string[20] ; //Creates char arrays to store text
	char color_index = 0 ;
	int color_counter = 0 ;
	
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

	//VGA_text (34, 1, text_top_row);
	//VGA_text (34, 2, text_bottom_row);
	// clear the screen
	VGA_box (0, 0, 639, 479, 0x0000);
	// clear the text
	VGA_text_clear(); 

	char input;
	reset_lock = 1;
	pthread_t thread_reset, thread_draw;
	//reset is ready at init time
	sem_init(&reset_done, 0, 0);
	sem_init(&draw_cycle_done, 0, 1);
	//pthread_create(&thread_reset, NULL, RESET, NULL);

	pthread_create(&thread_draw, NULL, DO_DRAW, NULL);
	pthread_create(&thread_reset, NULL, RESET, NULL);

	VGA_box (0, 0, 639, 479, 0x0000);

	while(1){
		printf("enter r for reset, c for change params, p for pause, s for resume, d for speed\n");
		scanf("%c", &input);
		if (input == 'r'){
			pause_lock = 0;
			VGA_box (0, 0, 639, 479, 0x0000);


			printf("enter initial x: \n");
			scanf("%f", &x);
			fixed_x = (int) x * DIVISION_CONST;
			*(fpga_initial_x_ptr) = fixed_x;

			printf("enter initial y: \n");
			scanf("%f", &y);
			fixed_y = (int) y * DIVISION_CONST;
			*(fpga_initial_y_ptr) = fixed_y;
			
			printf("enter initial z: \n");
			scanf("%f", &z);
			fixed_z = (int) z * DIVISION_CONST;
			*(fpga_initial_z_ptr) = fixed_z;

			printf("enter rho: \n");
			scanf("%f", &rho);
			fixed_rho = (int) rho * DIVISION_CONST;
			*(fpga_rho_ptr) = fixed_rho;

			printf("enter beta: \n");
			scanf("%f", &beta);
			fixed_beta = (int) beta * DIVISION_CONST;
			*(fpga_beta_ptr) = fixed_beta;

			printf("enter sigma: \n");
			scanf("%f", &sigma);
			fixed_sigma = (int) sigma * DIVISION_CONST;
			*(fpga_sigma_ptr) = fixed_sigma;
			pause_lock = 1;
			reset_lock = 0;

			new_rho = (int) *(fpga_rho_ptr) / DIVISION_CONST;
			new_beta = (int) * (fpga_beta_ptr) / DIVISION_CONST;
			new_sigma = (int) * (fpga_sigma_ptr) / DIVISION_CONST;

			sprintf(rho_str, "rho = %d\0", new_rho);
			sprintf(beta_str, "beta = %d\0", new_beta);
			sprintf(sigma_str, "sigma = %d\0", new_sigma);

			VGA_text_clear();
			// write text
			VGA_text (10, 1, rho_str);
			VGA_text (10, 2, sigma_str);
			VGA_text (10, 3, beta_str);
		}
		else if (input =='c'){

			printf("enter rho: \n");
			scanf("%f", &rho);
			fixed_rho = (int) rho * DIVISION_CONST;
			*(fpga_rho_ptr) = fixed_rho;

			printf("enter beta: \n");
			scanf("%f", &beta);
			fixed_beta = (int) beta * DIVISION_CONST;
			*(fpga_beta_ptr) = fixed_beta;

			printf("enter sigma: \n");
			scanf("%f", &sigma);
			fixed_sigma = (int) sigma * DIVISION_CONST;
			*(fpga_sigma_ptr) = fixed_sigma;

			new_rho = (int) *(fpga_rho_ptr) / DIVISION_CONST;
			new_beta = (int) * (fpga_beta_ptr) / DIVISION_CONST;
			new_sigma = (int) * (fpga_sigma_ptr) / DIVISION_CONST;
								
			sprintf(rho_str, "rho = %d\0", new_rho);
			sprintf(beta_str, "beta = %d\0", new_beta);
			sprintf(sigma_str, "sigma = %d\0", new_sigma);

			VGA_text_clear();
			// write text
			VGA_text (10, 1, rho_str);
			VGA_text (10, 2, sigma_str);
			VGA_text (10, 3, beta_str);
		}
		else if (input == 'd'){
			int new_draw_speed;

			printf("enter draw speed: \n");
			scanf("%d", &new_draw_speed);
			draw_speed = new_draw_speed;
		}
		else if(input == 'p'){
			pause_lock = 0;
			//DOUBLE CHECK SAVING OF THESE VALS
			last_raw_xvalue = (*(fpga_x_ptr));
			last_raw_yvalue = (*(fpga_y_ptr));
			last_raw_zvalue = (*(fpga_z_ptr));

		}
		else if(input == 's'){
			*(fpga_initial_x_ptr) = last_raw_xvalue;
			*(fpga_initial_y_ptr) = last_raw_yvalue;
			*(fpga_initial_z_ptr) = last_raw_zvalue;
			pause_lock = 1;
		}
	}
	pthread_join(thread_reset, NULL);
	pthread_join(thread_draw, NULL);
	return 0;
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
 * Subroutine to clear text to the VGA monitor 
****************************************************************************************/
#define SWAP(X,Y) do{int temp=X; X=Y; Y=temp;}while(0) 
void VGA_sine(double t, short pixel_color)
{
	int col = (int) (t*64);
	int row = (int) (50*sin(t)+239);
	// printf("sine value %d", row);
	// printf("x value %d", col);
	VGA_PIXEL(col, row, pixel_color);
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