// ============================================================================
// Module that writes to M10k memory using data from HPS
//=============================================================================

module mem_writer(
    input clk,
    input arm_val,
    input arm_rdy,
    input signed [31:0] arm_data,
    input reset,

    output logic fpga_val,
    output logic fpga_rdy,
    output logic signed [8:0] d,
    output logic [9:0] addr,
    output logic we,
    output logic done,
    output logic [15:0] which_mem
    
);
assign which_mem = arm_data[31:16];
logic [3:0] state = 0;
logic [9:0] addr_counter = 0;
always_comb begin 
    if ( state == 1) begin 
        done = 1;
    end 
    else begin 
        done = 0;
    end 
end 

always@(posedge clk) begin 
    if (state == 0) begin 
        addr_counter <= addr_counter + 1;
        if (addr_counter == 959 && which_mem == 239) begin 
            addr_counter <= 0;
            state <= 1;
        end
        else if (addr_counter == 959) begin 
            addr_counter <= 0;
        end

        if (arm_val) begin 
            fpga_val <= 1;
            fpga_rdy <= 0;
            d <= arm_data;
        end 
        if (fpga_val) begin 
            we <= 1;
            fpga_rdy <= 1;
        end 
    end 

    if (state == 1) begin 
        state <= 1;
        if (reset) begin 
            state <= 0;
        end 
        we <= 0;
    end 

end

endmodule
```