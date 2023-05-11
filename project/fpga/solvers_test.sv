`timescale 1ns/1ns

module solvers_testbench();
    
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
    wire testbench_valid;

    logic [31:0] arm_data;

    logic ack = 0;
    logic [7:0] state = 0;


    logic fpga_val, fpga_ack;
    logic [31:0] fpga_data;


    logic arm_val, arm_ack;
    logic [9:0] image_mem_data, which_mem;
    logic we;
    logic [19:0] image_mem_writeout;
    logic [7:0] debug_count;
    logic [7:0] send_40;

    always @ (posedge clk_25) begin
        if (state == 0) begin 
            send_40 <= 40;
            state <= 1;
            arm_val <= 1;
            arm_data <= 0; // next cycle arm is valid, will latch the zero
        end 
        else if (state == 1) begin 
            state <= 2;
            arm_val <= 0;
            arm_ack <= 1;
        end 
        else if (state == 2) begin
            state <= 3;
            arm_ack <= 0;
        end 
        else if (state == 3) begin 
            arm_data[30:0] <= 30'h3FFFF;
            if (send_40 == 1) begin 
                arm_data[31] <= 1; // set as the last item
                
            end 
            arm_val <= 1;
            state <= 4;
            
        end 
        else if (state ==4) begin 
            arm_val <= 0;
            arm_ack <= 1;
            state <= 5;
        end 
        else if (state == 5) begin 
            arm_ack <= 0;
            state<= 3;
            send_40 <= send_40 - 1;
            if (send_40 == 1) begin 
                state <= 6;
            end 
        end 
    end 

    solvers DUT (
        .clk(clk_50),
        .reset(reset),

        .arm_val(arm_val),
        .arm_ack(arm_ack),

        .arm_data(arm_data),
        .arm_data2(0),

        .image_mem_data(150),

        .fpga_val(fpga_val),
        .fpga_ack(fpga_ack),
        .fpga_data(fpga_data),

        .image_mem_addr(image_mem_addr),
        .which_mem(which_mem),

        .we(we),
        .image_mem_writeout(image_mem_writeout),
        .debug_count(debug_count)
    );

    
endmodule

