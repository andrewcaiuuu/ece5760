module fake_lut
(address, node_value_out, incr, pio_rows);
input signed [17:0] incr;
input [9:0] address;
input [31:0] pio_rows;
output signed [17:0] node_value_out;

assign node_value_out = (address < (pio_rows>>1)) ? (address * incr) : ((pio_rows - address - '1) * incr);
endmodule