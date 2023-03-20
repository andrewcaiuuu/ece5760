module solver(
    clk, rst,
    uij_left,
    uij_right,
    uij_up,
    uij_down,
    uij_prev_in,
    uij_in,
    uij_next);

input clk, rst;
input signed [17:0] uij_left, uij_right, uij_up, uij_down, uij_prev_in, uij_in;
output signed [17:0] uij_next;

logic signed [17:0] new_drum_temp_1;
logic signed [17:0] new_drum_temp_2;

logic signed [17:0] uij, uij_prev;

assign new_drum_temp_1 = (uij_left + uij_right + uij_up + uij_down - (uij<<2))>>5;
assign new_drum_temp_2 = new_drum_temp_1 + (uij - (uij>>13)) - (uij_prev - (uij_prev>>12));
assign uij_next = new_drum_temp_2 - (new_drum_temp_2>>13);

always@(posedge clk) begin 
    if (rst) begin 
        uij <= uij_in;
        uij_prev <= uij_prev_in;
    end
    else begin 
        uij <= uij_next;
        uij_prev <= uij;
    end
end

endmodule