`timescale 1ns/1ns

module testbench();
	
	reg clk_50, clk_25, reset;
	
	reg [31:0] index;
//	wire signed [15:0]  testbench_out;
	wire signed [26:0] testbench_xout;
	wire signed [26:0] testbench_yout;
	wire signed [26:0] testbench_zout;
	//Initialize clocks and index
	initial begin
		clk_50 = 1'b0;
		clk_25 = 1'b0;
		index  = 32'd0;
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
	
	//Intialize and drive signals
	initial begin
		reset  = 1'b1;
		#10 
		reset  = 1'b0;
		#30
		reset  = 1'b1;
	end
	
	//Increment 
	always @ (posedge clk_50) begin
		index  <= index + 32'd1;
	end

	//Instantiation of Device Under Test
	// hook up the sine wave generators
odesolver DUT   (.clk(clk_50), 
				.reset(reset),
				.initial_x(-27'd1048576), 
				.initial_y(27'b0000000001000000000000),
				.initial_z(27'b1100100000000000000000000),
				.x_out(testbench_xout),
				.y_out(testbench_yout),
				.z_out(testbench_zout),
				.rho(27'b1110000000000000000000000),
				.beta(27'b000001011000000000000000000),
				.sigma(27'b101000000000000000000000)
				);
	
endmodule

