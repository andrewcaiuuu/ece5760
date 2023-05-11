// ============================================================================
// Module that writes to M10k memory using data from HPS
//=============================================================================

module mem_writer(
    input clk,

    // arm interface
    input [31:0] arm_data,
    input arm_val,
    input arm_ack,
    input reset,

    // fpga interface
    output logic fpga_ack,

    // for memories
    output signed [19:0] d,
    output logic [9:0] addr,
    output logic we,
    output logic [9:0] which_mem,

    output logic done,
    // for debug
    output logic [31:0] count // for debugging
);
    
// assign which_mem = arm_data[31:16];
logic is_last;
logic [3:0] state;
assign state_debug = state;
assign d = arm_data;

assign count = state;

always@(posedge clk) begin 
    if (reset) begin 
        done <= 0;
        fpga_ack <= 0;
        addr <= 0;
        which_mem <= 0;
        state <= 0;
        // count <= 0;
    end
    else if (state == 0) begin 
        state <= 0;
        if (arm_val) begin // have a valid request
            we <= 1;
            state <= 1;
            is_last <= arm_data[31];
            fpga_ack <= 1; // ack the request
        end 
    end 
    else if (state == 1) begin 
        state <= 1; // stay in this state until we get a clear ack
        if (arm_ack) begin 
            state <= 2; // increment state
            fpga_ack <= 0; // clear ack
        end 
    end 
    else if (state == 2) begin 
        state <= 2; // stay in this state until we get a clear ack
        if ( ~arm_ack) begin 
            state <= 3;
        end 
    end 
    else if (state == 3) begin 
        addr <= addr + 1;
        // count <= count + 1;
        if (addr == 479) begin 
            addr <= 0;
            which_mem <= which_mem + 1;
        end 
        if ( is_last ) begin 
            done <= 1;
            state <= 4;
        end 
        else begin 
            state <= 0;
        end
    end 
end

endmodule