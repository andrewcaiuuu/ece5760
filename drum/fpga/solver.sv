module solver(
    uij_left,
    uij_right,
    uij_up,
    uij_down,
    uij_prev,
    uij,
    uij_next);

input clk;
input rst;
input signed [17:0] uij_left, uij_right, uij_up, uij_down, uij_prev, uij;
output signed [17:0] uij_next;

logic signed [17:0] new_drum_temp_1;
logic signed [17:0] new_drum_temp_2;

assign new_drum_temp_1 = (uij_left + uij_right + uij_up + uij_down - (uij<<2))>>5;
assign new_drum_temp_2 = new_drum_temp_1 + (uij - (uij>>13)) - (uij_prev - (uij_prev>>12));
assign uij_next = new_drum_temp_2 - (new_drum_temp_2>>13);

endmodule