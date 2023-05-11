`timescale 1ns/1ns

module testbench();
    
    reg clk_50, clk_25, reset;
    
    reg [31:0] index;
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
    // always @ (posedge clk_50) begin
    //     index  <= index + 32'd1;
    // end

    //Instantiation of Device Under Test
    // hook up the sine wave generators

    wire [9:0] testbench_xout;
    wire [9:0] testbench_yout;
    wire testbench_valid;

    logic ack = 0;
    logic [3:0] state = 1;
    always @ (posedge clk_50) begin
        if (state == 0) begin 
            state <= 1;
            ack <= 0; // sanity
        end 
        else if (state == 1) begin 
            state <= 2;
        end 
        else if (state == 2) begin
            state <= 3;
            ack <= 0;
        end 
        else if (state == 3) begin 
            state <= 0;
            ack <= 1;
        end 
    end 

bresenham DUT   (.clk(clk_50), 
                .reset(reset),
                .x0(9'd0),
                .y0(9'd0),
                .x1(9'd100),
                .y1(9'd100),
                .x(testbench_xout),
                .y(testbench_yout),
                .valid(testbench_valid),
                .ack(ack)
                );
    
endmodule

