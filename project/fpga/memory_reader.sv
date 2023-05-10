// ============================================================================
// Module that reads M10k memory back to HPS for testing
//=============================================================================

module mem_reader( // FPGA ACTING AS PRODUCER
    input clk,

    // arm interface
    input arm_ack,

    input [8:0] image_mem_data,
    input reset,

    output logic fpga_val,
    output logic fpga_ack,
    output logic [31:0] fpga_data,

    output logic [9:0] addr,
    output logic [9:0] which_mem,
    output logic done,

    output logic [31:0] count // for debugging
);

assign fpga_data = image_mem_data;

logic [3:0] state;
assign count = state;

always@(posedge clk) begin 
    if (reset) begin 
        addr <= 0;
        which_mem <= 0;
        state <= 0;
        fpga_val <= 0;
        fpga_ack <= 0;
        done <= 0;
    end 
    else if (state == 0) begin // memory latency
        state <= 1;
    end 
    else if (state == 1) begin 
        state <= 2;
        fpga_val <= 1;
    end 
    else if (state == 2) begin // wait for arm ack
        state <= 2;
        if (arm_ack) begin //if got ack, go to next state
            state <= 3;
            fpga_val <= 0; // deassert val
            fpga_ack <= 1;
        end
    end 
    else if (state == 3) begin // wait for arm to deassert ack
        state <= 3;
        if(~arm_ack) begin // if arm deasserted ack, go to next state
            state <= 4;
            fpga_ack <= 0;
        end 
    end 
    else if (state == 4) begin 
        addr <= addr + 1;
        state <= 0;
        // count <= count + 1;
        if (addr == 959) begin 
            addr <= 0;
            which_mem <= which_mem + 1;
            if (which_mem == 239) begin 
                done <= 1;
                state <= 5;
            end 
        end
    end 
end 


endmodule