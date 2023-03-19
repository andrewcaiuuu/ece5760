module solver(
    clk, rst, 
    uij_left,
    uij_right,
    uij_up,
    uij_down,
    uij_prev,
    uij,
    uij_next)

input clk;
input rst;
input signed [17:0] uij_left, uij_right, uij_up, uij_down, uij_prev, uij;
output signed [17:0] uij_next;

logic [17:0] uij_next_reg;

assign rho = 

logic [17:0] rho_squarer_out;
logic signed [17:0] rho_mult_out;
signed_mult rho_mult(
    .out(rho_mult_out),
    .a(uij),
    .b(4'b0001),
);

signed_mult squarer(
    .out(rho_squarer_out),
    .a(rho_mult_out),
    .b(rho_mult_out),
);


assign uij_next = uij_next_reg;

endmodule