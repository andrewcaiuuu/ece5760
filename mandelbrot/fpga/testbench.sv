`timescale 1ns/1ns

module testbench();
	
	reg clk_50, clk_25, reset;
	
	reg [31:0] index;

	wire signed [26:0] testbench_ci;
	wire signed [26:0] testbench_cr;
    wire [31:0] testbench_max_iterations = 32'h32000000;
    wire [31:0] testbench_iterations;
    wire testbench_done;

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
		reset  = 1'b0;
		#10 
		reset  = 1'b1;
		#30
		reset  = 1'b0;
	end
	
	//Increment 
	always @ (posedge clk_50) begin
		index  <= index + 32'd1;
	end
	//assign testbench_ci = 27'b11001100110011001100;
	//assign testbench_cr = 27'b001100110011001100110011;


	//assign testbench_ci = 27'h400000;
	//assign testbench_cr = 27'hffc00000;

	assign testbench_ci = 27'hffc00000;
	assign testbench_cr =  27'h400000;
	//Instantiation of Device Under Test
	// hook up the sine wave generators
iterator DUT   (.clk(clk_50), 
				.rst(reset),
                .ci(testbench_ci),
                .cr(testbench_cr),
                .max_iterations(testbench_max_iterations),
                .iterations(testbench_iterations),
                .done(testbench_done)
				);
	
endmodule

