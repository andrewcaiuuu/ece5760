module odesolver( clk, reset,
initial_x, initial_y, initial_z,
 x_out, y_out, z_out, rho, beta, sigma
);
	input clk;
	input reset;
	
	input signed [26:0] initial_x;
	input signed [26:0] initial_y;
	input signed [26:0] initial_z;
	input signed [26:0] rho;
	input signed [26:0] beta;
	//input signed [21:0] sigma;
	input signed [26:0] sigma;
	
	logic signed [26:0] sign_extend_sigma;
	assign sign_extend_sigma = sigma;
	//assign sign_extend_sigma = sigma << 5;

	output signed [26:0] x_out;
	output signed [26:0] y_out;
	output signed [26:0] z_out;
	
	logic signed [26:0] difference_1;
	logic signed [26:0] difference_2;
	logic signed [26:0] difference_3;
	logic signed [26:0] difference_4;
	
	logic signed [26:0] x_z_rho_multiplier_out;
	logic signed [26:0] x_y_multiplier_out;
	logic signed [26:0] beta_multiplier_out;
	logic signed [26:0] sigma_multiplier_out;
	
	assign difference_1 = y_out - x_out;
	assign difference_2 = rho - z_out;
	assign difference_3 = x_z_rho_multiplier_out - (y_out>>>8);
	assign difference_4 = x_y_multiplier_out - beta_multiplier_out;

	integrator xintegrator 
	(
		.out(x_out),
		.funct(sigma_multiplier_out),
		.InitialOut(initial_x),
		.clk(clk),
		.reset(reset)
	);
	
	integrator yintegrator
	(
		.out(y_out),
		.funct(difference_3),
		.InitialOut(initial_y),
		.clk(clk),
		.reset(reset)
	);
	
	integrator zintegrator 
	(
		.out(z_out),
		.funct(difference_4),
		.InitialOut(initial_z),
		.clk(clk),
		.reset(reset)
	);
	
	
	signed_mult sigma_multiplier
	(
		.out(sigma_multiplier_out),
		.a(sign_extend_sigma>>>8),
		.b(difference_1)
	);
	
	
	signed_mult x_z_rho_multiplier
	(
		.out(x_z_rho_multiplier_out),
		.a(difference_2),
		.b(x_out>>>8)
	);
	
	
	signed_mult beta_multiplier
	(
		.out(beta_multiplier_out),
		.a(beta>>>8),
		.b(z_out)
	);
	
	
	signed_mult x_y_multiplier
	(
		.out(x_y_multiplier_out),
		.a(x_out>>>8),
		.b(y_out)
	);
	
	
endmodule

