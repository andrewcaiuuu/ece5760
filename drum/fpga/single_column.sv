module single_column(
    clk, rst);

input clk, rst;
input signed [17:0] uij_left, uij_right, uij_up, uij_down, uij_prev_in, uij_in;
output signed [17:0] uij_next;

logic next_node, node;
logic init_done;

typedef enum {S_LOAD_REG, S_LOAD_MEM, S_DO_CALC, S_WRITE_MEM, S_INCREMENT, S_DONE} state_t;

state_t state, next_state;

// VARIOUS COUNTERS
logic [4:0] load_index;
logic [4:0] calc_index;
// ____________________

// M10K CUR TIMESTEP SIGNALS
logic [18:0] write_address, read_address;
logic write_enable;
logic signed [17:0] write_data, M10k_outs;
// ____________________

// M10K PREV TIMESTEP SIGNALS
logic [18:0] write_address_1, read_address_1;
logic write_enable_1;
logic signed [17:0] write_data_1, M10k_outs_1;
// ____________________

// REGISTERS FOR BOTTOM ROW
logic signed [17:0] uij, uij_prev
// ____________________

// LUT SIGNALS
logic [4:0] lut_addr;
logic [17:0] lut_out;
// ____________________

// SOLVER SIGNALS
logic signed [17:0] solver_uij_left, solver_uij_right, solver_uij_up, solver_uij_down, solver_uij_prev_in, solver_uij_in, solver_uij_next;
// ____________________

// HARDWIRED SIGNALS (SINGLE COLUMN)
assign solver_uij_left = 0;
assign solver_uij_right = 0;

// State machine: moves from top to bottom of column
always @(posedge clk) begin
    if (rst) begin
        state <= S_LOAD_REG 
        load_index <= 0;
        calc_index <= 0;
    end
    else begin
        state <= next_state;
        case (state)
            S_LOAD_REG: begin
                load_index <= load_index + 1;
                uij <= lut_out;
                uij_prev <= lut_out;
            end

            S_LOAD_MEM: begin
                load_index <= load_index + 1;
            end

            S_DO_CALC: begin
                calc_index <= calc_index + 1;
            end

            S_WRITE_MEM: begin
                // write mem
            end

            S_INCREMENT: begin
                // increment
            end

            S_DONE: begin
                // do nothing
            end
        endcase
    end
end

// State transition logic
always_comb begin
    case (state)
        S_LOAD_REG: begin
            next_state = S_INIT;
        end

        S_LOAD_MEM: begin
            next_state = S_LOAD_MEM;
            if (load_index > 28) begin 
                next_state = S_DO_CALC;
            end
        end

        S_DO_CALC: begin
            next_state = S_WRITE_MEM;
            if (write_mem_done)
                next_state = S_INCREMENT
        end

        S_INCREMENT: begin
            next_state = S_INCREMENT;
            if (next_node > 30)
                next_state = S_DONE;
            else if (incr_done)
                next_state= S_DO_CALC;
        end

        S_DONE: begin
        end
    endcase
end

// State output logic 
always_comb begin 
    case (state): 
        S_LOAD_REG: begin
            // LUT
            lut_addr          = load_index;

            // M10K CUR TIMESTEP
            write_enable      = 0;
            write_address     = x;
            read_address      = x;
            write_data        = x;

            // M10K PREV TIMESTEP
            write_enable_1    = 1;
            write_address_1   = load_index;
            read_address_1    = x;
            write_data_1      = lut_out;

        end

        S_LOAD_MEM: begin
            // LUT
            lut_addr          = load_index;

            // M10K CUR TIMESTEP
            write_enable      = 1;
            write_address     = load_index;
            read_address      = x;
            write_data        = lut_out;

            // M10K PREV TIMESTEP
            write_enable_1    = 1;
            write_address_1   = load_index;
            read_address_1    = x;
            write_data_1      = lut_out;
        end

        S_DO_CALC: begin
            // LUT
            lut_addr          = x;

            // M10K CUR TIMESTEP
            write_enable      = 0;
            write_address     = x;
            read_address      = calc_index;
            write_data        = x;

            // M10K PREV TIMESTEP
            write_enable_1    = 1;
            write_address_1   = load_index;
            read_address_1    = calc_index;
            write_data_1      = lut_out;


        end

        S_WRITE_MEM: begin
            // do nothing
        end

        S_INCREMENT: begin
            // do nothing
        end

        S_DONE: begin
            // do nothing
        end
        default: begin
            // do nothing
        end
    endcase
end
init_values_LUT LUT 
(
    .address(lut_addr),
    .node_value_out(lut_out)
);

M10K_1000_8 uij_mem (
    .q(M10k_outs),
    .d(write_data),
    .write_address(write_address),
    .read_address(read_address),
    .we(write_enable),
    .clk(clk)
);

M10K_1000_8 uij_prev_mem (
    .q(M10k_outs_1),
    .d(write_data_1),
    .write_address(write_address_1),
    .read_address(read_address_1),
    .we(write_enable_1),
    .clk(clk)
);

solver DUT (
    .uij_left(solver_uij_left),
    .uij_right(solver_uij_right),
    .uij_up(solver_uij_up),
    .uij_down(solver_uij_down),
    .uij_prev_in(solver_uij_prev_in),
    .uij_in(solver_uij_in),
    .uij_next(solver_uij_next)
);

endmodule
//============================================================
// M10K module for testing
//============================================================
// See example 12-16 in 
// http://people.ece.cornell.edu/land/courses/ece5760/DE1_SOC/HDL_style_qts_qii51007.pdf
//============================================================

module M10K_1000_8( 
    output reg [17:0] q,
    input [17:0] d,
    input [18:0] write_address, read_address,
    input we, clk
);
	 // force M10K ram style
	 // 30 words of 18 bits
    reg [17:0] mem [29:0]  /* synthesis ramstyle = "no_rw_check, M10K" */;
	 
    always @ (posedge clk) begin
        if (we) begin
            mem[write_address] <= d;
		  end
        q <= mem[read_address]; // q doesn't get d in this clock cycle
    end
endmodule

