`timescale 1ns/1ns

module testbench();
	
	reg clk_50, clk_25, reset;
	
	reg [31:0] index;

    wire [31:0] testbench_max_iterations = 32'd10;
    wire [31:0] testbench_iterations;
    wire testbench_done;
	reg [31:0] count, count_in;
	

	//Initialize clocks and index
	initial begin
		clk_50 = 1'b0;
		clk_25 = 1'b0;
		index  = 32'd0;
		count = 32'd0;
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
	
	//Instantiation of Device Under Test
	// hook up the sine wave generators
wire signed [17:0] testbench_output_node;
reg signed [17:0] reg_testbench_output_node;
wire testbench_output_ready;
reg testbench_shoot;
square #(.C(32'd_60), .R(32'd_60)) DUT  (.clk(clk_50), 
	.rst(reset), 
	.shoot('1),
	.top_output_node(testbench_output_node),
	.pio_incr(32'sh_147),
	.pio_tension(32'd_3),
	.pio_damping(32'd_11),
	.pio_rows(32'd_10)
	// .top_output_ready(testbench_output_ready)
);

endmodule
