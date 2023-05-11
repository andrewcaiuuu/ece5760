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

    wire [31:0] testbench_xout;
    wire [31:0] testbench_yout;
    logic done;
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
                .start(1),
                .x0(32'd120),
                .y0(32'd70),
                .x1(32'd0),
                .y1(32'd10),
                .plot(testbench_valid),
                .x(testbench_xout),
                .y(testbench_yout),
                .done(done),
                .enable(ack)
                );
    
endmodule

// bresenham DUT   (.clk(clk_50), 
//                 .reset(reset),
//                 .x0(32'd70),
//                 .y0(32'd70),
//                 .x1(32'd150),
//                 .y1(32'd255),
//                 .x(testbench_xout),
//                 .y(testbench_yout),
//                 .valid(testbench_valid),
//                 .done(done),
//                 .ack(1)
//                 );
    
// endmodule


// bresenham DUT   (.clk(clk_50), 
//                 .reset(reset),
//                 .x0(11'd70),
//                 .y0(11'd70),
//                 .x1(11'd71),
//                 .y1(11'd0),
//                 .x(testbench_xout),
//                 .y(testbench_yout),
//                 .valid(testbench_valid),
//                 .done(done),
//                 .ack(1)
//                 );
    
// endmodule

