module solver(
    uij_left,
    uij_right,
    uij_up,
    uij_down,
    uij_prev_in,
    uij_in,
    uij_next);

input signed [17:0] uij_left, uij_right, uij_up, uij_down, uij_prev_in, uij_in;
output signed [17:0] uij_next;

logic signed [17:0] new_drum_temp_0, new_drum_temp_1, new_drum_temp_2;

logic signed [17:0] uij, uij_prev;

logic signed [17:0] g_times_u_center, g_times_u_center_2, rho_eff, pos_rho_eff;

function automatic [17:0] times_rho(input [17:0] uij_left, uij_right, uij_down, uij_up, uij);
logic [35:0] temp, uij_times_four, times_rho_ext;
begin 
    uij_times_four = {{18{uij[17]}}, uij} << 2;
    temp = {{18{uij_left[17]}}, uij_left} + 
            {{18{uij_right[17]}}, uij_right} + {{18{uij_down[17]}}, uij_down} + 
            {{18{uij_up[17]}}, uij_up} - uij_times_four;
    
    times_rho = temp[17:0];
    // times_rho_ext = temp >>> 4;
    // times_rho = times_rho_ext[17:0];
end
endfunction

function automatic [17:0] damping(input [17:0] uij_prev, uij, times_rho);
logic [35:0] damping_ext, uij_times_two;
begin 
    uij_times_two = {{18{uij[17]}}, uij} << 1;
    damping_ext =  {{18{times_rho[17]}}, times_rho} + uij_times_two - ({{18{uij_prev[17]}}, uij_prev}) + ({{18{uij_prev[17]}}, uij_prev}>>>9);
    damping = damping_ext[17:0];
end
endfunction

assign uij = uij_in;
assign uij_prev = uij_prev_in;

assign new_drum_temp_0 = (times_rho(uij_left, uij_right, uij_down, uij_up, uij)); 
assign new_drum_temp_2 = damping(uij_prev, uij, new_drum_temp_1);
assign uij_next = new_drum_temp_2 - (new_drum_temp_2>>>10);



assign rho_eff = (18'sh_7D70 > pos_rho_eff) ? pos_rho_eff : 18'sh_7D70;
assign g_times_u_center = uij >>> 3; // G = 2^-4
assign pos_rho_eff = 18'sh_4000 + g_times_u_center_2; // 0.25 + g_times_u_center^2


signed_mult squarer(
    .out(g_times_u_center_2),
    .a(g_times_u_center),
    .b(g_times_u_center)
);

signed_mult rho_eff_multiplier(
    .out(new_drum_temp_1),
    .a(new_drum_temp_0),
    .b(rho_eff)
);

endmodule
