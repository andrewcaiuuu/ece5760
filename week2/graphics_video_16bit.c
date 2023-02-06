///////////////////////////////////////
/// 640x480 version! 16-bit color
/// This code will segfault the original
/// DE1 computer
/// compile with
/// gcc graphics_video_16bit.c -o gr -O2 -lm
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

#define FPGA_XOUT_BASE        0x00000000
#define FPGA_XOUT_END         0x0000000F
#define FPGA_XOUT_SPAN        0x00000010

#define FPGA_YOUT_BASE        0x00000010
#define FPGA_YOUT_END         0x0000001F
#define FPGA_YOUT_SPAN        0x00000010

#define FPGA_ZOUT_BASE        0x00000020
#define FPGA_ZOUT_END         0x0000002F
#define FPGA_ZOUT_SPAN        0x00000010

#define FPGA_CLK_BASE         0x00000030
#define FPGA_CLK_END          0x0000003F
#define FPGA_CLK_SPAN         0x00000010

#define FPGA_RESET_BASE       0x00000040
#define FPGA_RESET_END        0x0000004F
#define FPGA_RESET_SPAN       0x00000010

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

// /dev/mem file id
int fd;

// measure time
struct timeval t1, t2;
double elapsedTime;
	
int main(void)
{
  	
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
    
	//ode stuff
	fpga_clk_ptr = (unsigned int * ) (h2p_lw_virtual_base + FPGA_CLK_BASE);
	fpga_reset_ptr = (unsigned int * ) (h2p_lw_virtual_base + FPGA_RESET_BASE);
	fpga_x_ptr = (unsigned int * ) (h2p_lw_virtual_base + FPGA_XOUT_BASE);
	fpga_y_ptr = (unsigned int * ) (h2p_lw_virtual_base + FPGA_YOUT_BASE);
	fpga_z_ptr = (unsigned int * ) (h2p_lw_virtual_base + FPGA_ZOUT_BASE);

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

	/* create a message to be displayed on the VGA 
          and LCD displays */
	char text_top_row[40] = "DE1-SoC ARM/FPGA\0";
	char text_bottom_row[40] = "Cornell ece5760\0";
	char text_next[40] = "Graphics primitives\0";
	char num_string[20], time_string[20] ;
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
	// write text
	VGA_text (10, 1, text_top_row);
	VGA_text (10, 2, text_bottom_row);
	VGA_text (10, 3, text_next);
	
	// R bits 11-15 mask 0xf800
	// G bits 5-10  mask 0x07e0
	// B bits 0-4   mask 0x001f
	// so color = B+(G<<5)+(R<<11);
	
	*(fpga_clk_ptr) = 0;
	*(fpga_reset_ptr) = 0;
	*(fpga_clk_ptr) = 1;
	*(fpga_clk_ptr) = 0;
	*(fpga_reset_ptr) = 1;
	printf( "Initial out value: %d\n", *(fpga_x_ptr)) ;
	double t = 0.0;
	while(1) 
	{
		*(fpga_clk_ptr) = 1;
		*(fpga_clk_ptr) = 0;

		/* NEW STUFF HERE*/

		// unsigned int raw_xvalue = (*(fpga_x_ptr));
		// unsigned int raw_yvalue = (*(fpga_y_ptr));
		// unsigned int raw_zvalue = (*(fpga_z_ptr));


		unsigned int raw_xvalue = (*(fpga_x_ptr)>>20);
		unsigned int raw_yvalue = (*(fpga_y_ptr)>>20);
		unsigned int raw_zvalue = (*(fpga_z_ptr)>>20);
		if (raw_xvalue >> 11){
			raw_xvalue =  (raw_xvalue) | 0xFFFFFF80;
		}
		if (raw_yvalue >> 11){
			raw_yvalue = (raw_yvalue) | 0xFFFFFF80;
		}
		if(raw_zvalue >> 11) {
			raw_zvalue = (raw_zvalue) | 0xFFFFFF80;
		}

		VGA_PIXEL(200 + raw_xvalue*3, 200 + raw_yvalue*3, red);

		VGA_PIXEL(400 + raw_yvalue*3, 200 + raw_zvalue*3, blue);

		VGA_PIXEL(300 + raw_xvalue*3, 350 + raw_zvalue*3, green);

		// unsigned int sevBitMask = 0x07F00000;
		// signed int signed_raw_xvalue = 0;
		// if ((raw_xvalue & sevBitMask)>>20 >= 0x40){
		// 	signed_raw_xvalue = ((raw_xvalue & sevBitMask) >>20) | 0xFFFFFF80;
		// }
		// else{
		// 	signed_raw_xvalue = ((raw_xvalue & sevBitMask) >>20) | 0x00000000;

		// }
		// signed int signed_raw_yvalue = 0;
		// if ((raw_yvalue & sevBitMask)>>20 >= 0x40){
		// 	signed_raw_yvalue = ((raw_yvalue & sevBitMask) >>20) | 0xFFFFFF80;
		// }
		// else{
		// 	signed_raw_yvalue = ((raw_yvalue & sevBitMask) >>20) | 0x00000000;
		// }

		// signed int signed_raw_zvalue = 0;
		// if ((raw_zvalue & sevBitMask)>>20 >= 0x40){
		// 	signed_raw_zvalue = ((raw_zvalue & sevBitMask) >>20) | 0xFFFFFF80;
		// }
		// else{
		// 	signed_raw_zvalue = ((raw_zvalue & sevBitMask) >>20) | 0x00000000;
		// }
		// VGA_PIXEL(signed_raw_xvalue, signed_raw_yvalue, red);
		printf( "new x value: %x\n", raw_xvalue) ;
		printf( "new y value: %x\n", raw_yvalue) ;
		printf( "new z value: %x\n", raw_zvalue) ;

		/* NEW STUFF STOP*/

		// remove sext and decimal points
		// int raw_xvalue = *(fpga_x_ptr) >> 20 & 0x7F;
		// int raw_yvalue = *(fpga_y_ptr) >> 20 & 0x7F;
		// int raw_zvalue = *(fpga_z_ptr) >> 20 & 0x7F;

		// signed int raw_xvalue = (signed int) ((float) *(fpga_x_ptr)) / (DIVISION_CONST*10);
		// signed int raw_yvalue = (signed int) ((float) *(fpga_y_ptr)) / (DIVISION_CONST*10);
		// signed int raw_zvalue = (signed int) ((float) *(fpga_z_ptr)) / (DIVISION_CONST*10);

		// if ( raw_xvalue  & 0x80000000 ){
		// 	raw_xvalue |= 0x80;
		// }
		// if ( raw_yvalue  & 0x80000000 ){
		// 	raw_yvalue |= 0x80;
		// }


		// printf( "new x value: %d\n", raw_xvalue) ;
		// printf( "new y value: %d\n", raw_yvalue) ;
		// printf( "new z value: %d\n", raw_zvalue) ;
		// VGA_PIXEL(106+raw_xvalue, 119+raw_yvalue, red);
		// VGA_PIXEL(532+raw_yvalue, 119+raw_zvalue, blue);
		// VGA_PIXEL(319+raw_xvalue, 359+raw_zvalue, green);
		// VGA_PIXEL(raw_xvalue, raw_yvalue, red);
		// VGA_PIXEL(raw_yvalue, raw_zvalue, blue);
		// VGA_PIXEL(raw_xvalue, raw_zvalue, green);
		//printf( "new z value orig: %d\n", *(fpga_z_ptr));
		// start timer
		gettimeofday(&t1, NULL);
		// VGA_sine(t, blue);
	
		// //VGA_box(int x1, int y1, int x2, int y2, short pixel_color)
		// VGA_box(64, 0, 240, 50, blue); // blue box
		// VGA_box(250, 0, 425, 50, red); // red box
		// VGA_box(435, 0, 600, 50, green); // green box
		if ( t < 639 ) 
			t = t + 1.0/256;
		else
			t = 0.0;
		// printf("tvalue: %d", (int)t);

		// // cycle thru the colors
		// if (color_index++ == 11) color_index = 0;
		
		// //void VGA_disc(int x, int y, int r, short pixel_color)
		// VGA_disc(disc_x, 100, 20, colors[color_index]);
		// disc_x += 35 ;
		// if (disc_x > 640) disc_x = 0;
		
		// //void VGA_circle(int x, int y, int r, short pixel_color)
		// VGA_circle(320, 200, circle_x, colors[color_index]);
		// VGA_circle(320, 200, circle_x+1, colors[color_index]);
		// circle_x += 2 ;
		// if (circle_x > 99) circle_x = 0;
		
		// //void VGA_rect(int x1, int y1, int x2, int y2, short pixel_color)
		// VGA_rect(10, 478, box_x, 478-box_x, rand()&0xffff);
		// box_x += 3 ;
		// if (box_x > 195) box_x = 10;
		
		// //void VGA_line(int x1, int y1, int x2, int y2, short c)
		// VGA_line(210+(rand()&0x7f), 350+(rand()&0x7f), 210+(rand()&0x7f), 
		// 		350+(rand()&0x7f), colors[color_index]);
		
		// // void VGA_Vline(int x1, int y1, int y2, short pixel_color)
		// VGA_Vline(Vline_x, 475, 475-(Vline_x>>2), rand()&0xffff);
		// Vline_x += 2 ;
		// if (Vline_x > 620) Vline_x = 350;
		
		// //void VGA_Hline(int x1, int y1, int x2, short pixel_color)
		// VGA_Hline(400, Hline_y, 550, rand()&0xffff);
		// Hline_y += 2 ;
		// if (Hline_y > 400) Hline_y = 240;
		
		// stop timer
		gettimeofday(&t2, NULL);
		elapsedTime = (t2.tv_sec - t1.tv_sec) * 1000000.0;      // sec to us
		elapsedTime += (t2.tv_usec - t1.tv_usec) ;   // us 
		sprintf(time_string, "T = %6.0f uSec  ", elapsedTime);
		// VGA_text (10, 4, time_string);
		// set frame rate
		//usleep(17000);
		
	} // end while(1)
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