// ============================================================================
// Module that reads M10k memory back to HPS for testing
//=============================================================================

module mem_reader( // FPGA ACTING AS PRODUCER
    input clk,
    input reset,

    // arm interface
    input arm_rdy,
    input arm_ack,

    // for memories
    input [8:0] image_mem_data,

    // fpga interface
    output logic fpga_val,
    output logic [31:0] fpga_data,

    // for memories
    output logic [9:0] addr,
    output logic [9:0] which_mem,

    output logic done,
    //for debug
    output logic [31:0] count // for debugging
);

// logic [9:0] image_mem_data_pipe [0:1];

logic [9:0] next_addr;
logic [9:0] next_which_mem;
// assign fpga_data = image_mem_data;

logic [3:0] state;
logic prev_ack;

assign fpga_data = image_mem_data;

always@(posedge clk) begin 
    if (reset) begin 
        addr <= 0;
        which_mem <= 0;
        state <= 0;
        fpga_val <= 0;
        prev_ack <= 0;
        count <= 0;
        done <= 0;
    end 
    else if (state == 0) begin // assemble the read request
        fpga_val <= 0;
        state <= 1;
        // prev_ack <= arm_ack;
    end 
    else if (state == 1) begin // read request valid after two cycles
        fpga_val <= 1;
        state <= 1;
    end 
    else if (state == 2) begin // hold value until acked by HPS
        if ( arm_ack != prev_ack ) begin 
            count <= count + 1;
            addr <= addr + 1;
            if ( addr == 959 ) begin 
                which_mem <= which_mem + 1;
                addr <= 0;
            end 
            fpga_val <= 0;
            state <= 0;
            prev_ack <= arm_ack;
            if (count == 230399) begin 
                state <= 3;
                done <= 1;
            end 
        end
        else begin 
            state <= 2;
        end 
    end 
end 


endmodule