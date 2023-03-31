module fake_lut
(address, node_value_out, incr, pio_rows);
input signed [17:0] incr;
input [9:0] address;
input [31:0] pio_rows;
logic [9:0] pio_rows_sliced;
output signed [17:0] node_value_out;

assign pio_rows_sliced = pio_rows[9:0];
assign node_value_out = (address < (pio_rows_sliced>>1)) ? (address * incr) : ((pio_rows_sliced - address - '1) * incr);
endmodule