module single_column(
    clk, rst, center_node);

input clk, rst;
output signed [17:0] center_node;

typedef enum {S_LOAD_REG, S_LOAD_MEM, 
S_CALC_READ_MEM, S_CALC_WAIT_MEM,  S_CALC_COMPUTE, S_CALC_DO_INCR, 
S_DONE} state_t;

state_t state, next_state;

// VARIOUS COUNTERS
logic [4:0] load_index;
logic [4:0] calc_index;
// ____________________

// M10K CUR TIMESTEP SIGNALS
logic [18:0] write_address, read_address;
logic write_enable;
logic signed [17:0] write_data, M10k_out;
// ____________________

// M10K PREV TIMESTEP SIGNALS
logic [18:0] write_address_1, read_address_1;
logic write_enable_1;
logic signed [17:0] write_data_1, M10k_out_1;
// ____________________

// REGISTERS FOR BOTTOM ROW
logic signed [17:0] u_bottom_reg, uij_reg, uij_down_reg;
// ____________________

// LUT SIGNALS
logic [4:0] lut_addr;
logic [17:0] lut_out;
// ____________________

// SOLVER SIGNALS
logic signed [17:0] solver_uij_left, solver_uij_right, solver_uij_up, solver_uij_down, solver_uij_prev_in, solver_uij_in, solver_uij_next;
// ____________________

// CONTROL SIGNALS FOR POSITION
logic at_bottom, at_top;
//____________________  

// HARDWIRED SIGNALS (SINGLE COLUMN)
assign solver_uij_left = 0;
assign solver_uij_right = 0;

// ASSIGN POSITION CONTROL SIGNALS
assign at_bottom = (calc_index == 0);
assign at_top = (calc_index == 5'd_29);

logic signed [17:0] reg_center_node;
assign center_node = reg_center_node;
// State machine: moves from top to bottom of column
always @(posedge clk) begin
    if (rst) begin
        state <= S_LOAD_REG;
        load_index <= 0;
        calc_index <= 0;
    end
    else begin
        state <= next_state;
        case (state) 
            S_LOAD_REG: begin
                u_bottom_reg <= lut_out;
                load_index <= load_index + 1;
            end

            S_LOAD_MEM: begin 
                load_index <= load_index + 1;
            end
            S_CALC_COMPUTE: begin 
                if (at_bottom) begin 
                    u_bottom_reg <= solver_uij_next;
                    uij_down_reg <= u_bottom_reg;
                    uij_reg <= M10k_out;
                end
                else if (~at_top) begin 
                    uij_down_reg <= uij_reg;
                    uij_reg <= M10k_out;
                end
            end
            S_CALC_DO_INCR: begin
                if (calc_index < 5'd_29) begin 
                    calc_index <= calc_index + 1;
                    if (calc_index == 5'd_15) begin 
                        reg_center_node <= uij_reg;
                    end
                end
                else begin 
                    calc_index <= 0;
                end 
            end
            default:  begin
                load_index <= load_index;
                calc_index <= calc_index;
            end
        endcase
    end
end

// State transition logic
always_comb begin
    case (state)
        S_LOAD_REG: begin
            next_state = S_LOAD_MEM;
        end

        S_LOAD_MEM: begin
            next_state = S_LOAD_MEM;
            if (load_index > 28) begin 
                next_state = S_CALC_READ_MEM;
            end
        end

        S_CALC_READ_MEM: begin 
            next_state = S_CALC_WAIT_MEM;
        end 

        S_CALC_WAIT_MEM: begin 
            next_state = S_CALC_COMPUTE;
        end

        S_CALC_COMPUTE: begin 
            next_state = S_CALC_DO_INCR;
        end

        S_CALC_DO_INCR: begin 
            next_state = S_CALC_READ_MEM;
        end

        S_DONE: begin
            next_state = S_DONE;
        end
        default: begin
            next_state = S_DONE;
        end
    endcase
end

// State output logic 
always_comb begin 
    case (state)
        S_LOAD_REG: begin
            // LUT
            lut_addr          = load_index;

            // M10K CUR TIMESTEP
            write_enable      = 0;
            write_address     = 0;
            read_address      = 0;
            write_data        = 0;

            // M10K PREV TIMESTEP
            write_enable_1    = 1;
            write_address_1   = load_index;
            read_address_1    = 0;
            write_data_1      = lut_out;

            // SOLVER
            solver_uij_up      = 0;
            solver_uij_down    = 0;

            solver_uij_in      = 0;
            solver_uij_prev_in = 0;   

        end

        S_LOAD_MEM: begin
            // LUT
            lut_addr          = load_index;

            // M10K CUR TIMESTEP
            write_enable      = 1;
            write_address     = load_index;
            read_address      = 0;
            write_data        = lut_out;

            // M10K PREV TIMESTEP
            write_enable_1    = 1;
            write_address_1   = load_index;
            read_address_1    = 0;
            write_data_1      = lut_out;

            // SOLVER
            solver_uij_up      = 0;
            solver_uij_down    = 0;

            solver_uij_in      = 0;
            solver_uij_prev_in = 0;

        end

        S_CALC_READ_MEM: begin
            // LUT
            lut_addr          = 0;

            // M10K CUR TIMESTEP
            write_enable      = 0;
            write_address     = 0;
            read_address      = calc_index + 1;
            write_data        = 0;

            // M10K PREV TIMESTEP
            write_enable_1    = 0;
            write_address_1   = 0;
            read_address_1    = calc_index;
            write_data_1      = 0;

            // SOLVER
            solver_uij_up      = 0;
            solver_uij_down    = 0;

            solver_uij_in      = 0;
            solver_uij_prev_in = 0;

        end

        S_CALC_WAIT_MEM: begin 
            // LUT
            lut_addr          = 0;

            // M10K CUR TIMESTEP
            write_enable      = 0;
            write_address     = 0;
            read_address      = calc_index + 1;
            write_data        = 0;

            // M10K PREV TIMESTEP
            write_enable_1    = 0;
            write_address_1   = 0;
            read_address_1    = calc_index;
            write_data_1      = 0;

            // SOLVER
            solver_uij_up      = 0;
            solver_uij_down    = 0;

            solver_uij_in      = 0;
            solver_uij_prev_in = 0;
        end

        S_CALC_COMPUTE: begin 
            // LUT
            lut_addr          = 0;

            // M10K CUR TIMESTEP
            write_enable      = at_bottom ? 0 : 1;
            write_address     = calc_index;
            read_address      = calc_index + 1;
            write_data        = solver_uij_next;

            // M10K PREV TIMESTEP
            write_enable_1    = 1;
            write_address_1   = calc_index;
            read_address_1    = calc_index + 1;
            write_data_1      = at_bottom ? u_bottom_reg : uij_reg;

            // SOLVER
            solver_uij_up      = at_top    ? 0            : M10k_out;
            solver_uij_down    = at_bottom ? 0            : uij_down_reg;

            solver_uij_in      = at_bottom ? u_bottom_reg : uij_reg;
            solver_uij_prev_in = M10k_out_1;
        end

        S_CALC_DO_INCR: begin 

            // LUT
            lut_addr          = 0;

            // M10K CUR TIMESTEP
            write_enable      = 0;
            write_address     = calc_index;
            read_address      = calc_index + 1;
            write_data        = at_bottom ? M10k_out : solver_uij_next;

            // M10K PREV TIMESTEP
            write_enable_1    = 0;
            write_address_1   = calc_index;
            read_address_1    = calc_index + 1;
            write_data_1      = at_bottom ? u_bottom_reg : uij_reg;

            // SOLVER
            solver_uij_up      = at_top    ? 0            : M10k_out;
            solver_uij_down    = at_bottom ? 0            : uij_down_reg;

            solver_uij_in      = at_bottom ? u_bottom_reg : uij_reg;
            solver_uij_prev_in = M10k_out_1;
        end 

        default: begin
            // LUT
            lut_addr          = load_index;

            // M10K CUR TIMESTEP
            write_enable      = 0;
            write_address     = 0;
            read_address      = 0;
            write_data        = 0;

            // M10K PREV TIMESTEP
            write_enable_1    = 0;
            write_address_1   = 0;
            read_address_1    = 0;
            write_data_1      = 0;

            // SOLVER
            solver_uij_up      = 0;
            solver_uij_down    = 0;

            solver_uij_in      = 0;
            solver_uij_prev_in = 0;
        end
    endcase
end
init_values_LUT LUT 
(
    .address(lut_addr),
    .node_value_out(lut_out)
);

M10K_1000_8 uij_mem (
    .q(M10k_out),
    .d(write_data),
    .write_address(write_address),
    .read_address(read_address),
    .we(write_enable),
    .clk(clk)
);

M10K_1000_8 uij_prev_mem (
    .q(M10k_out_1),
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

