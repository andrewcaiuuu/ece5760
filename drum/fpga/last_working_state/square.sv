module square#(parameter C = 10'd_30, 
    parameter R = 10'd_30)(
    clk, rst, top_output_node, shoot, 
    //pio stuffs
    pio_incr, pio_tension, pio_damping, pio_rows, pio_cols
    );

input clk, rst, shoot;
// PIO 
input [31:0] pio_incr, pio_tension, pio_damping, pio_rows, pio_cols;

logic signed [17:0] incr;
assign incr = pio_incr[17:0];

output signed [17:0] top_output_node;
// output top_output_ready;

// M10K CUR TIMESTEP SIGNALS
logic [18:0] write_address [C];
logic [18:0] read_address [C];
logic write_enable [C];
logic signed [17:0] write_data [C]; 
logic signed [17:0] M10k_out [C];
// ____________________

// M10K PREV TIMESTEP SIGNALS
logic [18:0] write_address_1 [C];
logic [18:0] read_address_1 [C];
logic write_enable_1 [C];
logic signed [17:0] write_data_1 [C]; 
logic signed [17:0] M10k_out_1 [C];
// ____________________


// SOLVER SIGNALS
logic signed [17:0] solver_uij_left [C];
logic signed [17:0] solver_uij_right [C]; 
logic signed [17:0] solver_uij_up [C];
logic signed [17:0] solver_uij_down [C]; 
logic signed [17:0] solver_uij_prev_in [C]; 
logic signed [17:0] solver_uij_in [C];
logic signed [17:0] solver_uij_next [C];
// ____________________

logic signed [17:0] me [C];
logic signed [17:0] output_node [C];
logic signed [17:0] output_ready [C];
assign top_output_node = output_node[C>>1];

// FAKE LUT STUFF
logic [9:0] lut_addr [C];
logic signed [17:0] lut_out;

// // assign top_output_ready = output_ready[C>>1];
// always_comb begin 
//     integer j;
//     top_output_ready = 1'b1;
//     for (j = 0; j < C; j++) begin : ready_output_reduction 
//         top_output_ready = top_output_ready & output_ready[j];
//     end 
// end

// M10k block and Solver generate
genvar i;
generate 
    for (i = 0; i < C; i ++) begin : generate_block_identifier

        M10K_1000_8 #(.C(C)) uij_mem (
        .q(M10k_out[i]),
        .d(write_data[i]),
        .write_address(write_address[i]),
        .read_address(read_address[i]),
        .we(write_enable[i]),
        .clk(clk)
        );

        M10K_1000_8  #(.C(C)) uij_prev_mem (
        .q(M10k_out_1[i]),
        .d(write_data_1[i]),
        .write_address(write_address_1[i]),
        .read_address(read_address_1[i]),
        .we(write_enable_1[i]),
        .clk(clk)
        );
        solver DUT (
        .uij_left(solver_uij_left[i]),
        .uij_right(solver_uij_right[i]),
        .uij_up(solver_uij_up[i]),
        .uij_down(solver_uij_down[i]),
        .uij_prev_in(solver_uij_prev_in[i]),
        .uij_in(solver_uij_in[i]),
        .uij_next(solver_uij_next[i]),
        .pio_damping(pio_damping),
        .pio_tension(pio_tension)
        );

        col_state_machine_integrated_lut #(.R(R)) col_state (
        //new stuff
        .incr(i < (C>>1) ? (i * incr) : ((C-i-'1) * incr)),
        // .lut_addr(lut_addr[i]),
        // .lut_out(lut_out),
        .clk(clk),
        .rst(rst),
        .shoot(shoot),
        .M10k_out(M10k_out[i]),
        .M10k_out_1(M10k_out_1[i]),
        .left_column((i == 0) ? 18'b0 : me[i-1]),
        .right_column((i == (C-1)) ? 18'b0 : me[i+1]),
        // .left_column((i == 0) ? me[i] : me[i-1]),
        // .right_column((i == (C-1)) ? me[i] : me[i+1]),
        .solver_uij_left(solver_uij_left[i]),
        .solver_uij_right(solver_uij_right[i]),
        .solver_uij_up(solver_uij_up[i]),
        .solver_uij_down(solver_uij_down[i]),
        .solver_uij_prev_in(solver_uij_prev_in[i]),
        .solver_uij_in(solver_uij_in[i]),
        .solver_uij_next(solver_uij_next[i]),

        .write_data(write_data[i]),
        .write_data_1(write_data_1[i]),
        .write_address(write_address[i]),
        .write_address_1(write_address_1[i]),
        .write_enable(write_enable[i]),
        .write_enable_1(write_enable_1[i]),
        .read_address(read_address[i]),
        .read_address_1(read_address_1[i]),
        .me(me[i]),
        .output_node(output_node[i])
        // .output_ready(output_ready[i])
        );
    end 
endgenerate 

// fake_lut #(.R(R))LUT 
// (
//     .address(lut_addr[0]),
//     .node_value_out(lut_out),
//     .incr(incr)
// );

endmodule
//============================================================
// M10K module for testing
//============================================================
// See example 12-16 in 
// http://people.ece.cornell.edu/land/courses/ece5760/DE1_SOC/HDL_style_qts_qii51007.pdf
//============================================================

module M10K_1000_8 #(parameter C = 10'd_30) ( 
    output reg [17:0] q,
    input [17:0] d,
    input [18:0] write_address, read_address,
    input we, clk
);
	 // force M10K ram style
	 // 30 words of 18 bits
    reg [17:0] mem [C-1:0]  /* synthesis ramstyle = "no_rw_check, M10K" */;
	 
    always @ (posedge clk) begin
        if (we) begin
            mem[write_address] <= d;
		  end
        q <= mem[read_address]; // q doesn't get d in this clock cycle
    end
endmodule
