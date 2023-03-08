`timescale 1ns/1ns

module testbench();
	
	reg clk_50, clk_25, reset;
	
	reg [31:0] index;

	wire signed [26:0] testbench_ci;
	wire signed [26:0] testbench_cr;
    wire signed [26:0] final_zi;
    wire signed [26:0] final_zr;
    wire all_done;
    reg handshake;

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

	integer               data_file    ; // file handler
	integer               scan_file    ; // file handler
	integer               f			   ; // file handler
	logic   signed [21:0] captured_data;
	`define NULL 0  
	
	//Intialize and drive signals
	initial begin
		f = $fopen("output.txt","w");
		reset  = 1'b0;
		#10 
		reset  = 1'b1;
		#30
		reset  = 1'b0;

		// data_file = $fopen("C:/Users/caian/Desktop/ece5760/data_file.dat", "r");
		// if (data_file == `NULL) begin
		// 	$display("data_file handle was NULL");
		// 	$finish;
		// end
		
	end


	//Increment 
	logic doing_stuff;

	always @ (posedge clk_50) begin
		// index  <= index + 32'd1;
		doing_stuff <= 1'b0;
		state <= next_state;
		if (handshake && testbench_done) begin 
			doing_stuff <= 1'b1;
			$display("iterations: %d", testbench_iterations);
			$fwrite(f,"%d\n",testbench_iterations);
		end 
	end

	always_comb begin 
		case (state) 
			START: begin 
				next_state = START;
				if ( testbench_done ) begin 
					next_state = ASSERT_HANDSHAKE;
				end 
			end 
			ASSERT_HANDSHAKE: begin 
				next_state = START;
			end
			default: begin 
				next_state = START;
			end
		endcase 
	end     

	always_comb begin
		case (state)
			START: begin
				handshake = 1'b0;
			end
			ASSERT_HANDSHAKE: begin
				handshake = 1'b1;
			end
			default: begin
				handshake = 1'b0;
			end
		endcase
	end 
	
    always_comb begin 
		if (all_done) begin 
			$fclose(f);
			$stop; 
		end 
    end 

	//assign testbench_ci = 27'b11001100110011001100;
	//assign testbench_cr = 27'b001100110011001100110011;


	//assign testbench_ci = 27'h400000;
	//assign testbench_cr = 27'hffc00000;

	// assign testbench_ci = 27'hffc00000;
	// assign testbench_cr =  27'h400000;

	// assign testbench_ci = 27'h800000;
	// assign testbench_cr = 27'hff000000;

	assign testbench_ci = 27'sh0800000;
	assign testbench_cr = 27'sh7000000;
	
	//Instantiation of Device Under Test
	// hook up the sine wave generators
iterator DUT   (.clk(clk_50), 
				.rst(reset),
                .ci_init(testbench_ci),
                .cr_init(testbench_cr),
                .max_iterations(testbench_max_iterations),
                .range(32'hfff),
                .handshake(handshake),
                .iterations(testbench_iterations),
                .done(testbench_done),
                .all_done(all_done)
				);
	
endmodule

