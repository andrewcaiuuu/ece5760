`timescale 1ns/1ns

module testbench();
	
	reg clk_50, clk_25, reset;
	
	reg [31:0] index;

    wire [31:0] testbench_max_iterations = 32'd10;
    wire [31:0] testbench_iterations;
    wire testbench_done;
	reg [31:0] count, count_in;
	
	typedef enum {START, ASSERT_HANDSHAKE} state_type;
	state_type state, next_state;

	//Initialize clocks and index
	initial begin
		clk_50 = 1'b0;
		clk_25 = 1'b0;
		index  = 32'd0;
		count = 32'd0;
		state = START;
		//testbench_out = 15'd0 ;
	end
	
	//Toggle the clocks
	always begin
		#10
		clk_50  = !clk_50;
	end
	
	always begin
		#20
		clk_25  = !clk_25;
	end

	`define NULL 0  
	
	//Intialize and drive signals
	initial begin
		reset  = 1'b0;
		#10 
		reset  = 1'b1;
		#30
		reset  = 1'b0;
		
    end
    

logic signed [17:0] testbench_uij_next;
	
	//Instantiation of Device Under Test
	// hook up the sine wave generators
solver DUT   (.clk(clk_50), 
				.rst(reset),
                .uij_left(0),
                .uij_right(0),
                .uij_up(0),
                .uij_down(0),
                .uij_prev(0),
                .uij(1),
                .uij_next(testbench_uij_next)
				);
endmodule

