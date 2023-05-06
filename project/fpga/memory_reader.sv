// ============================================================================
// Module that reads M10k memory back to HPS for testing
//=============================================================================

module mem_writer(
    input clk,
    input arm_val,
    input arm_rdy,
    input signed [31:0] arm_data,

    output logic fpga_val,
    output logic fpga_rdy,
    output logic signed [8:0] d,
    output logic [9:0] addr,
    output logic we,
    output logic [15:0] which_mem
    
);
assign which_mem = arm_data[31:16];

always@(posedge clk) begin 
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


endmodule
```