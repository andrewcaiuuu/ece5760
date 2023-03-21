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

function automatic [17:0] times_rho(input [17:0] uij_left, uij_right, uij_down, uij_up, uij);
logic [35:0] temp, uij_times_four, times_rho_ext;
begin 
    uij_times_four = {{18{uij[17]}}, uij} << 2;
    temp = {{18{uij_left[17]}}, uij_left} + 
            {{18{uij_right[17]}}, uij_right} + {{18{uij_down[17]}}, uij_down} + 
            {{18{uij_up[17]}}, uij_up} - uij_times_four;
    
    times_rho_ext = temp >>> 4;
    times_rho = times_rho_ext[17:0];
end
endfunction

function automatic [17:0] damping(input [17:0] uij_prev, uij, times_rho);
logic [35:0] damping_ext, uij_times_two;
begin 
    uij_times_two = {{18{uij[17]}}, uij} << 1;
    damping_ext =  {{18{times_rho[17]}}, times_rho} + uij_times_two - ( {{18{uij_prev[17]}}, uij_prev} - {{18{uij_prev[17]}}, uij_prev}>>>12);
    damping = damping_ext[17:0];
end
endfunction

assign new_drum_temp_1 = times_rho(uij_left, uij_right, uij_down, uij_up, uij); 
assign new_drum_temp_2 = damping(uij_prev, uij, new_drum_temp_1);
assign uij_next = new_drum_temp_2 - (new_drum_temp_2>>>13);

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