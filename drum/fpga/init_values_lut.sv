module init_values_LUT (
    output reg [31:0] node_value_out,
    input wire [4:0] address
);

reg [31:0] node_values [0:29];

initial
begin
    node_values[0] = 32'h00000;
    node_values[1] = 32'h00924;
    node_values[2] = 32'h01249;
    node_values[3] = 32'h01B6D;
    node_values[4] = 32'h02492;
    node_values[5] = 32'h02DB6;
    node_values[6] = 32'h036DB;
    node_values[7] = 32'h04000;
    node_values[8] = 32'h04924;
    node_values[9] = 32'h05249;
    node_values[10] = 32'h05B6D;
    node_values[11] = 32'h06492;
    node_values[12] = 32'h06DB6;
    node_values[13] = 32'h076DB;
    node_values[14] = 32'h08000;
    node_values[15] = 32'h08000;
    node_values[16] = 32'h076DB;
    node_values[17] = 32'h06DB6;
    node_values[18] = 32'h06492;
    node_values[19] = 32'h05B6D;
    node_values[20] = 32'h05249;
    node_values[21] = 32'h04924;
    node_values[22] = 32'h04000;
    node_values[23] = 32'h036DB;
    node_values[24] = 32'h02DB6;
    node_values[25] = 32'h02492;
    node_values[26] = 32'h01B6D;
    node_values[27] = 32'h01249;
    node_values[28] = 32'h00924;
    node_values[29] = 32'h00000;
end

always @(address)
begin
    if (address < 30)
        node_value_out = node_values[address];
    else
        node_value_out = 32'h00000;
end

endmodule