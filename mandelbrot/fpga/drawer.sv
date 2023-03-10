module drawer(rst)
// VGA clock and reset lines
wire vga_pll_lock ;
wire vga_pll ;
reg  vga_reset ;

// M10k memory control and data
wire 		[7:0] 	M10k_outs[0:9];
reg 		[7:0] 	M10k_out;

/*
reg 		[7:0] 	write_data, write_data1, write_data2 ;
reg 		[18:0] 	write_address, write_address1, next_write_address1, write_address2, next_write_address2 ;
reg 		[18:0] 	read_address ;
reg 					write_enable, write_enable1, write_enable2 ;
*/

reg 		[18:0] 	read_address ;


// M10k memory clock
wire 					M10k_pll ;
wire 					M10k_pll_locked ;

// Memory writing control registers
//reg 		[7:0] 	arbiter_state ;
//reg 		[9:0] 	x_coord ;
//reg 		[9:0] 	y_coord ;

// Wires for connecting VGA driver to memory
wire 		[9:0]		next_x ;
wire 		[9:0] 	next_y ;



/*

reg state1, state2;
always@(posedge M10k_pll) begin
	// Zero everything in reset
	if (~KEY[0]) begin
		arbiter_state <= 8'd_0 ;
		// vga_reset <= 1'b_1 ;
		x_coord <= 10'd_0 ;
		y_coord <= 10'd_0 ;
		state1 <= 8'd0 ;
		write_address1 <= 8'd0;
		next_write_address1 <= 8'd0;
	end
	// Otherwiser repeatedly write a large checkerboard to memory
	else begin
		if ( all_done1 ) begin 
			// vga_reset <= 1'b_0;
			write_enable1 <= 1'b0;
		end
		else begin 
			if (state1 == 8'd0) begin 
				state1 <= 8'd1;
				if ( done1 ) begin 
					write_enable1 <= 1'b1;
					// compute address
					handshake1 <= 1'b1;
					write_address1 <= next_write_address1; 
					next_write_address1 <= write_address1 + 1;
					// data
					write_data1 <= color_reg(iterations1);
				end 
			end 
			if (state1 == 8'd1) begin 
				handshake1 <= 1'b0;
				write_enable1 <= 1'b0;
				state1  <= 8'd0 ;
			end
		end 
	end
end
// for second iterator
always@(posedge M10k_pll) begin 
	// Zero everything in reset
	if (~KEY[0]) begin
		state2 <= 8'd0 ;
		write_address2 <= 8'd0;
		next_write_address2 <= 8'd0;
	end
	// Otherwiser repeatedly write a large checkerboard to memory
	else begin
		if ( all_done2 ) begin 
			// vga_reset <= 1'b_0;
			write_enable2 <= 1'b0;
		end
		else begin 
			if (state2 == 8'd0) begin 
				state2 <= 8'd1;
				if ( done2 ) begin 
					write_enable2 <= 1'b1;
					// compute address
					handshake2 <= 1'b1;
					write_address2 <= next_write_address2; 
					next_write_address2 <= write_address2 + 1;
					// data
					write_data2 <= color_reg(iterations2);
				end 
			end 
			if (state2 == 8'd1) begin 
				handshake2 <= 1'b0;
				write_enable2 <= 1'b0;
				state2  <= 8'd0 ;
			end
		end 
	end

end 

*/
reg [9:0] arbiter_state [0:9];
reg [9:0] x_coord [0:9];
reg [9:0] y_coord [0:9];
reg [7:0] state [0:9];
reg 		[18:0] write_address [0:9];
reg 		[18:0] next_write_address [0:9];
reg [7:0] write_data [0:9];
reg [9:0] which_memblock;



// Instantiate Iterator
wire [31:0] max_iterations = 32'd100;
wire done[0:9];
wire all_done[0:9];
reg handshake[0:9];
wire [31:0] iterations[0:9];

reg write_enable[0:9];
 
// instantiate state machines for each m10k block
genvar i;
generate
    for (i = 0; i < 10; i= i+1) begin : block_gen
        always@(posedge M10k_pll) begin
            // Zero everything in reset
            if (~KEY[0]) begin
                arbiter_state[i] <= 10'd_0 ;
                x_coord[i] <= 10'd_0 ;
                y_coord[i] <= 10'd_0 ;
                state[i] <= 8'd0 ;
                write_address[i] <= 8'd0;
                next_write_address[i] <= 8'd0;
            end
            // Otherwiser repeatedly write a large checkerboard to memory
            else begin
                if (all_done[i]) begin 
                    write_enable[i] <= 1'b0;
                end
                else begin 
                    if (state[i] == 8'd0) begin 
                        state[i] <= 8'd1;
                        if (done[i]) begin 
                            write_enable[i] <= 1'b1;
                            // compute address
                            handshake[i] <= 1'b1;
                            write_address[i] <= next_write_address[i]; 
                            next_write_address[i] <= write_address[i] + 1;
                            // data
                            write_data[i] <= color_reg(iterations[i]);
                        end 
                    end 
                    if (state[i] == 8'd1) begin 
                        handshake[i] <= 1'b0;
                        write_enable[i] <= 1'b0;
                        state[i]  <= 8'd0 ;
                    end
                end 
            end
        end
	end
endgenerate








// MUXING LOGIC OUTSIDE OF VGA STATE MACHINE
// KINDA SHIT 
reg all_done_no_flag;
always@(posedge M10k_pll) begin 
	if (~KEY[0]) begin 
		vga_reset <= 1'b_1 ;
	end 
	else begin 
		// when all of the iterators are done we write the display
		integer i;
		all_done_no_flag = 1'b0;
		for(i=0; i < 10; i=i+1) begin 
			if (all_done[i] == 1'b_0) begin
				all_done_no_flag = 1'b1;	
			end 
			if(i==23 && (!all_done_no_flag)) begin 
				vga_reset <= 1'b_0;
			end	
		end
	end 
end 

// always@(*) begin 
// 	// default vga driver is outputting next_y, next_x,
// 	// i was lazy so just using this for now to calculate true range
// 	// then do muxing on this value
// 	if (( (19'd_640*next_y) + next_x ) > 19'd153599) begin 
// 		which_memblock = 1;
// 	end 
// 	else begin 
// 		which_memblock = 0;
// 	end
// end




always@(*) begin
	// does parallel muxing using casez statement
	casez ( which_memblock )
	9'b_?_????_???1: begin
	M10k_out <= M10k_outs[0];
	read_address <= (19'd_640*next_y) + next_x;
	end
	9'b_?_????_??1?: begin
	M10k_out <= M10k_outs[1];
	read_address <= (19'd_640*next_y) + next_x - 19'd153600;
	end
	9'b_?_????_?1??: begin
	M10k_out <= M10k_outs[2];
	read_address <= (19'd_640*next_y) + next_x - 19'd307200;
	end
	9'b_?_????_?1??: begin
	M10k_out <= M10k_outs[3];
	read_address <= (19'd_640*next_y) + next_x - 19'd460800;
	end
	9'b_?_????_1???: begin
	M10k_out = M10k_outs[4];
	read_address = (19'd_640*next_y) + next_x - 19'd614400;
	end
	9'b_?_???1_????: begin
	M10k_out = M10k_outs[5];
	read_address = (19'd_640*next_y) + next_x - 19'd768000;
	end
	9'b_?_??1?_????: begin
	M10k_out = M10k_outs[6];
	read_address = (19'd_640*next_y) + next_x - 19'd921600;
	end
	9'b_?_?1??_????: begin
	M10k_out = M10k_outs[7];
	read_address = (19'd_640*next_y) + next_x - 19'd1075200;
	end
	9'b_?_1???_????: begin
	M10k_out = M10k_outs[8];
	read_address = (19'd_640*next_y) + next_x - 19'd1228800;
	end
	9'b_1_????_????: begin
	M10k_out = M10k_outs[9];
	read_address = (19'd_640*next_y) + next_x - 19'd1382400;
	end
	default: begin
	M10k_out = M10k_outs[0];
	read_address = (19'd_640*next_y) + next_x;
	end
	endcase
end


// Instantiate memory
genvar j;
generate
  for (j = 0; j < 10; j=j+1) begin : M10K_instance
    M10K_1000_8 pixel_data (
      .q({M10k_outs[j]}),
      .d({write_data[j]}),
      .write_address({write_address[j]}),
      .read_address(read_address),
      .we({write_enable[j]}),
      .clk(M10k_pll)
    );
  end
endgenerate
wire [9:0] switch_values [0:9] = '{9'd_0, 9'd_48, 9'd_96, 9'd_144, 9'd_192, 9'd_240, 9'd_288, 9'd_336, 9'd_384, 9'd_432};
// wire [9:0] which_memblock;
// Instantiate VGA driver					
vga_driver DUT   (	.clock(vga_pll), 
							.reset(vga_reset),
							.color_in(M10k_out),	// Pixel color (8-bit) from memory
							.switch_values(switch_values),
							.next_x(next_x),		// This (and next_y) used to specify memory read address
							.next_y(next_y),		// This (and next_x) used to specify memory read address
							.hsync(VGA_HS),
							.vsync(VGA_VS),
							.red(VGA_R),
							.green(VGA_G),
							.blue(VGA_B),
							.sync(VGA_SYNC_N),
							.clk(VGA_CLK),
							.blank(VGA_BLANK_N),
							.which_memblock(which_memblock)
);

function [7:0] color_reg(input [31:0] iterations);
	begin
		if (iterations >= max_iterations) begin
			color_reg = 8'b_000_000_00 ; // black
		end
		else if (iterations >= (max_iterations >>> 1)) begin
			color_reg = 8'b_011_001_00 ; // white
		end
		else if (iterations >= (max_iterations >>> 2)) begin
			color_reg = 8'b_011_001_00 ;
		end
		else if (iterations >= (max_iterations >>> 3)) begin
			color_reg = 8'b_101_010_01 ;
		end
		else if (iterations >= (max_iterations >>> 4)) begin
			color_reg = 8'b_011_001_01 ;
		end
		else if (iterations >= (max_iterations >>> 5)) begin
			color_reg = 8'b_001_001_01 ;
		end
		else if (iterations >= (max_iterations >>> 6)) begin
			color_reg = 8'b_011_010_10 ;
		end
		else if (iterations >= (max_iterations >>> 7)) begin
			color_reg = 8'b_010_100_10 ;
		end
		else if (iterations >= (max_iterations >>> 8)) begin
			color_reg = 8'b_010_100_10 ;
		end
		else begin
			color_reg = 8'b_010_100_10 ;
		end
	end
endfunction



reg[26:0] ci_init[0:9] = '{27'sh0800000, 27'sh0666666, 27'sh04ccccd, 27'sh0333333, 27'sh019999a, 27'sh0000000, 27'sh7e66666, 27'sh7cccccd, 27'sh7b33333, 27'sh799999a}; //double check
reg[26:0] cr_init[0:9] = '{27'sh7000000, 27'sh7000000, 27'sh7000000, 27'sh7000000, 27'sh7000000, 27'sh7000000, 27'sh7000000, 27'sh7000000, 27'sh7000000, 27'sh7000000}; //double check


genvar z;
generate 
	for (z = 0; z < 10; z=z+1) begin : iterator_instance
		iterator iter 
		(
			// input
			.clk(M10k_pll),
			.rst(~KEY[0]),
			.ci_init(ci_init[z]),
			.cr_init(cr_init[z]),
			.max_iterations(max_iterations),
			.range(32'd30720),
			.handshake(handshake[z]),
			// output
			.iterations(iterations[z]),
			.done(done[z]),
			.all_done(all_done[z])
		);
	end
endgenerate

// please feed me increments divisible by 640 ty

// Declaration of module, include width and signedness of each input/output
module vga_driver (
	input wire clock,
	input wire reset,
	input [7:0] color_in,
	input [9:0] switch_values [0:9], //staring y value for each memblock
	output [9:0] next_x,
	output [9:0] next_y,
	output wire hsync,
	output wire vsync,
	output [7:0] red,
	output [7:0] green,
	output [7:0] blue,
	output sync,
	output clk,
	output blank,
	output [9:0] which_memblock //new 
	
);
	
	// Horizontal parameters (measured in clock cycles)
	parameter [9:0] H_ACTIVE  	=  10'd_639 ;
	parameter [9:0] H_FRONT 	=  10'd_15 ;
	parameter [9:0] H_PULSE		=  10'd_95 ;
	parameter [9:0] H_BACK 		=  10'd_47 ;

	// Vertical parameters (measured in lines)
	parameter [9:0] V_ACTIVE  	=  10'd_479 ;
	parameter [9:0] V_FRONT 	=  10'd_9 ;
	parameter [9:0] V_PULSE		=  10'd_1 ;
	parameter [9:0] V_BACK 		=  10'd_32 ;

//	// Horizontal parameters (measured in clock cycles)
//	parameter [9:0] H_ACTIVE  	=  10'd_9 ;
//	parameter [9:0] H_FRONT 	=  10'd_4 ;
//	parameter [9:0] H_PULSE		=  10'd_4 ;
//	parameter [9:0] H_BACK 		=  10'd_4 ;
//	parameter [9:0] H_TOTAL 	=  10'd_799 ;
//
//	// Vertical parameters (measured in lines)
//	parameter [9:0] V_ACTIVE  	=  10'd_1 ;
//	parameter [9:0] V_FRONT 	=  10'd_1 ;
//	parameter [9:0] V_PULSE		=  10'd_1 ;
//	parameter [9:0] V_BACK 		=  10'd_1 ;

	// Parameters for readability
	parameter 	LOW 	= 1'b_0 ;
	parameter 	HIGH	= 1'b_1 ;

	// States (more readable)
	parameter 	[7:0]	H_ACTIVE_STATE 		= 8'd_0 ;
	parameter 	[7:0] 	H_FRONT_STATE		= 8'd_1 ;
	parameter 	[7:0] 	H_PULSE_STATE 		= 8'd_2 ;
	parameter 	[7:0] 	H_BACK_STATE 		= 8'd_3 ;

	parameter 	[7:0]	V_ACTIVE_STATE 		= 8'd_0 ;
	parameter 	[7:0] 	V_FRONT_STATE		= 8'd_1 ;
	parameter 	[7:0] 	V_PULSE_STATE 		= 8'd_2 ;
	parameter 	[7:0] 	V_BACK_STATE 		= 8'd_3 ;

	// Clocked registers
	reg 		hysnc_reg ;
	reg 		vsync_reg ;
	reg 	[7:0]	red_reg ;
	reg 	[7:0]	green_reg ;
	reg 	[7:0]	blue_reg ;
	reg 		line_done ;

	// Control registers
	reg 	[9:0] 	h_counter ;
	reg 	[9:0] 	v_counter ;

	reg 	[7:0]	h_state ;
	reg 	[7:0]	v_state ;

	reg     [9:0]   which_memblock_reg; //new
	reg     [9:0]   switch_values_reg[0:9]; //new

	// State machine
	always@(posedge clock) begin
		// At reset . . .
  		if (reset) begin
			// Zero the counters
			h_counter 	<= 10'd_0 ;
			v_counter 	<= 10'd_0 ;
			// States to ACTIVE
			h_state 	<= H_ACTIVE_STATE  ;
			v_state 	<= V_ACTIVE_STATE  ;
			// Deassert line done
			line_done 	<= LOW ;
  		end
  		else begin
			//////////////////////////////////////////////////////////////////////////
			///////////////////////// HORIZONTAL /////////////////////////////////////
			//////////////////////////////////////////////////////////////////////////
			if (h_state == H_ACTIVE_STATE) begin
				// Iterate horizontal counter, zero at end of ACTIVE mode
				h_counter <= (h_counter==H_ACTIVE)?10'd_0:(h_counter + 10'd_1) ;
				// Set hsync
				hysnc_reg <= HIGH ;
				// Deassert line done
				line_done <= LOW ;
				// State transition
				h_state <= (h_counter == H_ACTIVE)?H_FRONT_STATE:H_ACTIVE_STATE ;
			end
			// Assert done flag, wait here for reset
			if (h_state == H_FRONT_STATE) begin
				// Iterate horizontal counter, zero at end of H_FRONT mode
				h_counter <= (h_counter==H_FRONT)?10'd_0:(h_counter + 10'd_1) ;
				// Set hsync
				hysnc_reg <= HIGH ;
				// State transition
				h_state <= (h_counter == H_FRONT)?H_PULSE_STATE:H_FRONT_STATE ;
			end
			if (h_state == H_PULSE_STATE) begin
				// Iterate horizontal counter, zero at end of H_FRONT mode
				h_counter <= (h_counter==H_PULSE)?10'd_0:(h_counter + 10'd_1) ;
				// Set hsync
				hysnc_reg <= LOW ;
				// State transition
				h_state <= (h_counter == H_PULSE)?H_BACK_STATE:H_PULSE_STATE ;
			end
			if (h_state == H_BACK_STATE) begin
				// Iterate horizontal counter, zero at end of H_FRONT mode
				h_counter <= (h_counter==H_BACK)?10'd_0:(h_counter + 10'd_1) ;
				// Set hsync
				hysnc_reg <= HIGH ;
				// State transition
				h_state <= (h_counter == H_BACK)?H_ACTIVE_STATE:H_BACK_STATE ;
				// Signal line complete at state transition (offset by 1 for synchronous state transition)
				line_done <= (h_counter == (H_BACK-1))?HIGH:LOW ;
			end
			//////////////////////////////////////////////////////////////////////////
			///////////////////////// VERTICAL ///////////////////////////////////////
			//////////////////////////////////////////////////////////////////////////
			if (v_state == V_ACTIVE_STATE) begin
				// increment vertical counter at end of line, zero on state transition
				v_counter <= (line_done==HIGH)?((v_counter==V_ACTIVE)?10'd_0:(v_counter + 10'd_1)):v_counter ;
				// set vsync in active mode
				vsync_reg <= HIGH ;
				// state transition - only on end of lines
				v_state <= (line_done==HIGH)?((v_counter==V_ACTIVE)?V_FRONT_STATE:V_ACTIVE_STATE):V_ACTIVE_STATE ;
			end
			if (v_state == V_FRONT_STATE) begin
				// increment vertical counter at end of line, zero on state transition
				v_counter <= (line_done==HIGH)?((v_counter==V_FRONT)?10'd_0:(v_counter + 10'd_1)):v_counter ;
				// set vsync in front porch
				vsync_reg <= HIGH ;
				// state transition
				v_state <= (line_done==HIGH)?((v_counter==V_FRONT)?V_PULSE_STATE:V_FRONT_STATE):V_FRONT_STATE ;
			end
			if (v_state == V_PULSE_STATE) begin
				// increment vertical counter at end of line, zero on state transition
				v_counter <= (line_done==HIGH)?((v_counter==V_PULSE)?10'd_0:(v_counter + 10'd_1)):v_counter ;
				// clear vsync in pulse
				vsync_reg <= LOW ;
				// state transition
				v_state <= (line_done==HIGH)?((v_counter==V_PULSE)?V_BACK_STATE:V_PULSE_STATE):V_PULSE_STATE ;
			end
			if (v_state == V_BACK_STATE) begin
				// increment vertical counter at end of line, zero on state transition
				v_counter <= (line_done==HIGH)?((v_counter==V_BACK)?10'd_0:(v_counter + 10'd_1)):v_counter ;
				// set vsync in back porch
				vsync_reg <= HIGH ;
				// state transition
				v_state <= (line_done==HIGH)?((v_counter==V_BACK)?V_ACTIVE_STATE:V_BACK_STATE):V_BACK_STATE ;
			end

			//////////////////////////////////////////////////////////////////////////
			//////////////////////////////// COLOR OUT ///////////////////////////////
			//////////////////////////////////////////////////////////////////////////
			red_reg 		<= (h_state==H_ACTIVE_STATE)?((v_state==V_ACTIVE_STATE)?{color_in[7:5],5'd_0}:8'd_0):8'd_0 ;
			green_reg 	<= (h_state==H_ACTIVE_STATE)?((v_state==V_ACTIVE_STATE)?{color_in[4:2],5'd_0}:8'd_0):8'd_0 ;
			blue_reg 	<= (h_state==H_ACTIVE_STATE)?((v_state==V_ACTIVE_STATE)?{color_in[1:0],6'd_0}:8'd_0):8'd_0 ;
			
 	 	end
	end
	always@(*) begin 
		if ( reset ) begin 
			switch_values_reg = switch_values;
		end 
		// output which_memblock for one hot decoding later
		else if (next_y == switch_values_reg[0]) begin 
			switch_values_reg[0:8] = switch_values_reg[1:9];
			switch_values_reg[9] = -9'sd1; // put in negative 1 so it never matches again
			which_memblock_reg = (which_memblock >> 1 ) | 9'b1;
		end 
	end 

	// Assign output values
	assign hsync = hysnc_reg ;
	assign vsync = vsync_reg ;
	assign red = red_reg ;
	assign green = green_reg ;
	assign blue = blue_reg ;
	assign clk = clock ;
	assign sync = 1'b_0 ;
	assign blank = hysnc_reg & vsync_reg ;
	// The x/y coordinates that should be available on the NEXT cycle
	assign next_x = (h_state==H_ACTIVE_STATE)?h_counter:10'd_0 ;
	assign next_y = (v_state==V_ACTIVE_STATE)?v_counter:10'd_0 ;

endmodule




//============================================================
// M10K module for testing
//============================================================
// See example 12-16 in 
// http://people.ece.cornell.edu/land/courses/ece5760/DE1_SOC/HDL_style_qts_qii51007.pdf
//============================================================

module M10K_1000_8( 
    output reg [7:0] q,
    input [7:0] d,
    input [18:0] write_address, read_address,
    input we, clk
);
	 // force M10K ram style
	 // 307200 words of 8 bits
    reg [7:0] mem [30720:0]  /* synthesis ramstyle = "no_rw_check, M10K" */;
	 
    always @ (posedge clk) begin
        if (we) begin
            mem[write_address] <= d;
		  end
        q <= mem[read_address]; // q doesn't get d in this clock cycle
    end
endmodule

