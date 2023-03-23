module init_values_LUT (
    output reg [17:0] node_value_out,
    input wire [4:0] address
);

reg [17:0] node_values [0:29];

initial
begin
    node_values[0] = 18'h00000;
    node_values[1] = 18'h00924;
    node_values[2] = 18'h01249;
    node_values[3] = 18'h01B6D;
    node_values[4] = 18'h02492;
    node_values[5] = 18'h02DB6;
    node_values[6] = 18'h036DB;
    node_values[7] = 18'h04000;
    node_values[8] = 18'h04924;
    node_values[9] = 18'h05249;
    node_values[10] = 18'h05B6D;
    node_values[11] = 18'h06492;
    node_values[12] = 18'h06DB6;
    node_values[13] = 18'h076DB;
    node_values[14] = 18'h08000;
    node_values[15] = 18'h08000;
    node_values[16] = 18'h076DB;
    node_values[17] = 18'h06DB6;
    node_values[18] = 18'h06492;
    node_values[19] = 18'h05B6D;
    node_values[20] = 18'h05249;
    node_values[21] = 18'h04924;
    node_values[22] = 18'h04000;
    node_values[23] = 18'h036DB;
    node_values[24] = 18'h02DB6;
    node_values[25] = 18'h02492;
    node_values[26] = 18'h01B6D;
    node_values[27] = 18'h01249;
    node_values[28] = 18'h00924;
    node_values[29] = 18'h00000;
end

always @(address)
begin
    if (address < 30)
        node_value_out = node_values[address];
    else
        node_value_out = 18'h00000;
end

endmodule