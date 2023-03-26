module fake_lut #(parameter R= 10'd30)
(address, node_value_out, incr)
input signed [17:0] incr;
input [9:0] address;
output signed [17:0] node_value_out;

assign node_value_out = (address < (R>>1)) ? (address * incr) : ((R - address - '1) * incr);
endmodule