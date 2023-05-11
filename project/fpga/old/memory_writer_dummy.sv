// ============================================================================
// Module that writes to M10k memory using data from HPS
//=============================================================================

module mem_writer_dummy(
    input clk,
    input arm_val,
    input arm_rdy,
    input [31:0] arm_data,
    input reset,

    output logic fpga_val,
    output logic fpga_rdy,
    output logic signed [8:0] d,
    output logic [9:0] addr,
    output logic we,
    output logic done,
    output logic [9:0] which_mem,
    output logic [3:0] state_debug // for debugging
);
    
// assign which_mem = arm_data[31:16];
logic is_last;

logic [3:0] state;
assign state_debug = state;

always@(posedge clk) begin 
    if (reset) begin 
        done <= 0;
        // which_mem <= 0;
        fpga_rdy <= 0;
        we <= 0;
        d <= 0;
        state <= 0;
        addr <= 0;
        which_mem <= 0;
    end
    else if (state == 0) begin 
        state <= 0;
        fpga_rdy <= 1;
        if (arm_val) begin 
            d <= arm_data;
            we <= 1;
            state <= 1;
            fpga_rdy <= 0;
            is_last <= arm_data[16];
        end 
    end 
    else if (state == 1) begin 
        addr <= addr + 1;
        state <= 0;
        we <= 0;
        fpga_rdy <= 1;
        if (addr == 959) begin 
            // which_mem <= which_mem + 1;
            addr <= 0;
            which_mem <= which_mem + 1;
        end
        if (is_last) begin 
            state <= 2;
            done <= 1;
        end 
    end 
    else if (state == 2) begin 
        fpga_rdy <= 1;
        // if (reset) begin 
        //     state <= 0;
        // end 
    end 

end

endmodule