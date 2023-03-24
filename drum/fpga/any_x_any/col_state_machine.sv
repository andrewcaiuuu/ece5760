module col_state_machine #(parameter R = 5'd_30)(clk, 
rst,
shoot,
// M10K INPUTS
M10k_out,
M10k_out_1,
//____________________

// LEFT AND RIGHT
left_column,
right_column,
//____________________

// SOLVER OUTPUTS
solver_uij_left,
solver_uij_right, 
solver_uij_up,
solver_uij_down, 
solver_uij_prev_in, 
solver_uij_in,
solver_uij_next,
//____________________

// M10K OUTPUTS
write_data,
write_data_1,
write_enable,
write_enable_1,
read_address,
read_address_1,
write_address,
write_address_1,
//____________________
me,
output_node,
output_ready

);

input clk, rst, shoot;
input signed [17:0] solver_uij_next, M10k_out, M10k_out_1, left_column, right_column;
output signed [17:0] solver_uij_down, solver_uij_up, solver_uij_left, solver_uij_right, solver_uij_prev_in, solver_uij_in;
output signed [17:0] write_data, write_data_1;
output write_enable, write_enable_1;
output [18:0] read_address, read_address_1, write_address, write_address_1;
output [17:0] me, output_node;
output output_ready;

typedef enum {S_LOAD_REG, S_LOAD_MEM, 
S_CALC_READ_MEM, S_CALC_WAIT_MEM,  S_CALC_COMPUTE, S_CALC_DO_INCR, S_WAIT_SHOOT} 
state_t;

state_t state, next_state;

// CONTROL SIGNALS FOR POSITION
logic at_bottom, at_top;
//____________________  

// REGISTERS
logic signed [17:0] u_bottom_reg;
logic signed [17:0] uij_reg; 
logic signed [17:0] uij_down_reg;
// ____________________

// LUT SIGNALS
logic [4:0] lut_addr;
logic [17:0] lut_out;
// ____________________

// VARIOUS COUNTERS
logic [4:0] load_index;
logic [4:0] calc_index;
// ____________________

// ASSIGN POSITION CONTROL SIGNALS
assign at_bottom = (calc_index == 0);
assign at_top = (calc_index == (R - 1));

assign solver_uij_left = left_column;
assign solver_uij_right = right_column;
assign me = at_bottom ? u_bottom_reg : uij_reg;

logic reg_write_enable, reg_write_enable_1;
logic [18:0] reg_write_address, reg_read_address, reg_write_address_1, reg_read_address_1;

logic signed [17:0] reg_write_data, reg_write_data_1, reg_solver_uij_up , reg_solver_uij_down, reg_solver_uij_in, reg_solver_uij_prev_in;
logic reg_output_ready;

assign write_data = reg_write_data;
assign write_data_1 = reg_write_data_1;
assign write_enable = reg_write_enable;
assign write_enable_1 = reg_write_enable_1;
assign write_address = reg_write_address;
assign write_address_1 = reg_write_address_1;
assign read_address = reg_read_address;
assign read_address_1 = reg_read_address_1;
assign solver_uij_up = reg_solver_uij_up;
assign solver_uij_down = reg_solver_uij_down;
assign solver_uij_in = reg_solver_uij_in;
assign solver_uij_prev_in = reg_solver_uij_prev_in;
assign output_ready = reg_output_ready;

assign output_node = (output_ready) ? M10k_out : output_node;

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
                if (calc_index < (R - 1)) begin 
                    calc_index <= calc_index + 1;
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
            if (load_index > (R - 2)) begin 
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
            if (calc_index >= (R - 1)) begin 
                next_state = S_WAIT_SHOOT;
            end
        end

        S_WAIT_SHOOT: begin 
            next_state = S_WAIT_SHOOT;
            if (shoot) begin 
                next_state = S_CALC_READ_MEM;
            end
        end

        default: begin
            next_state = S_LOAD_REG;
        end
    endcase
end

// State output logic 
always_comb begin 
    case (state)
        S_LOAD_REG: begin
            reg_output_ready          = 0;            
            // LUT
            lut_addr          = load_index;

            // M10K CUR TIMESTEP
            reg_write_enable      = 0;
            reg_write_address     = 0;
            reg_read_address      = 0;
            reg_write_data        = 0;

            // M10K PREV TIMESTEP
            reg_write_enable_1    = 1;
            reg_write_address_1   = load_index;
            reg_read_address_1    = 0;
            reg_write_data_1      = lut_out;

            // SOLVER
            reg_solver_uij_up      = 0;
            reg_solver_uij_down    = 0;

            reg_solver_uij_in      = 0;
            reg_solver_uij_prev_in = 0;  


        end

        S_LOAD_MEM: begin
            reg_output_ready          = 0;            
            // LUT
            lut_addr          = load_index;

            // M10K CUR TIMESTEP
            reg_write_enable      = 1;
            reg_write_address     = load_index;
            reg_read_address      = 0;
            reg_write_data        = lut_out;

            // M10K PREV TIMESTEP
            reg_write_enable_1    = 1;
            reg_write_address_1   = load_index;
            reg_read_address_1    = 0;
            reg_write_data_1      = lut_out;

            // SOLVER
            reg_solver_uij_up      = 0;
            reg_solver_uij_down    = 0;

            reg_solver_uij_in      = 0;
            reg_solver_uij_prev_in = 0;
       

        end

        S_CALC_READ_MEM: begin
            reg_output_ready          = 0;            
            // LUT
            lut_addr          = 0;

            // M10K CUR TIMESTEP
            reg_write_enable      = 0;
            reg_write_address     = 0;
            reg_read_address      = calc_index + 1;
            reg_write_data        = 0;

            // M10K PREV TIMESTEP
            reg_write_enable_1    = 0;
            reg_write_address_1   = 0;
            reg_read_address_1    = calc_index;
            reg_write_data_1      = 0;

            // SOLVER
            reg_solver_uij_up      = 0;
            reg_solver_uij_down    = 0;

            reg_solver_uij_in      = 0;
            reg_solver_uij_prev_in = 0;
        

        end

        S_CALC_WAIT_MEM: begin 
            reg_output_ready          = 0;            
            // LUT
            lut_addr          = 0;

            // M10K CUR TIMESTEP
            reg_write_enable      = 0;
            reg_write_address     = 0;
            reg_read_address      = calc_index + 1;
            reg_write_data        = 0;

            // M10K PREV TIMESTEP
            reg_write_enable_1    = 0;
            reg_write_address_1   = 0;
            reg_read_address_1    = calc_index;
            reg_write_data_1      = 0;

            // SOLVER
            reg_solver_uij_up      = 0;
            reg_solver_uij_down    = 0;

            reg_solver_uij_in      = 0;
            reg_solver_uij_prev_in = 0;


        end

        S_CALC_COMPUTE: begin 
            reg_output_ready          = 0;            
            // LUT
            lut_addr          = 0;

            // M10K CUR TIMESTEP
            reg_write_enable      = at_bottom ? 0 : 1;
            reg_write_address     = calc_index;
            reg_read_address      = R >> 1; // read out the center
            reg_write_data        = solver_uij_next;

            // M10K PREV TIMESTEP
            reg_write_enable_1    = 1;
            reg_write_address_1   = calc_index;
            reg_read_address_1    = 0;
            reg_write_data_1      = at_bottom ? u_bottom_reg : uij_reg;

            // SOLVER
            reg_solver_uij_up      = at_top    ? 0            : M10k_out;
            reg_solver_uij_down    = at_bottom ? 0            : uij_down_reg;

            reg_solver_uij_in      = at_bottom ? u_bottom_reg : uij_reg;
            reg_solver_uij_prev_in = M10k_out_1;


        end

        S_CALC_DO_INCR: begin 
            reg_output_ready          = 0;
            // LUT
            lut_addr          = 0;

            // M10K CUR TIMESTEP
            reg_write_enable      = 0;
            reg_write_address     = 0;
            reg_read_address      = R >> 1; // read out the center
            reg_write_data        = 0;

            // M10K PREV TIMESTEP
            reg_write_enable_1    = 0;
            reg_write_address_1   = 0;
            reg_read_address_1    = 0;
            reg_write_data_1      = 0;

            // SOLVER
            reg_solver_uij_up      = 0;
            reg_solver_uij_down    = 0;

            reg_solver_uij_in      = 0;
            reg_solver_uij_prev_in = 0;


        end 

        S_WAIT_SHOOT: begin
            reg_output_ready          = 1;
            // LUT
            lut_addr          = load_index;

            // M10K CUR TIMESTEP
            reg_write_enable      = 0;
            reg_write_address     = 0;
            reg_read_address      = R >> 1; // read out the center
            reg_write_data        = 0;

            // M10K PREV TIMESTEP
            reg_write_enable_1    = 0;
            reg_write_address_1   = 0;
            reg_read_address_1    = 0;
            reg_write_data_1      = 0;

            // SOLVER
            reg_solver_uij_up      = 0;
            reg_solver_uij_down    = 0;

            reg_solver_uij_in      = 0;
            reg_solver_uij_prev_in = 0;
        end

        default: begin
            reg_output_ready          = 0;
            // LUT
            lut_addr          = load_index;

            // M10K CUR TIMESTEP
            reg_write_enable      = 0;
            reg_write_address     = 0;
            reg_read_address      = 0;
            reg_write_data        = 0;

            // M10K PREV TIMESTEP
            reg_write_enable_1    = 0;
            reg_write_address_1   = 0;
            reg_read_address_1    = 0;
            reg_write_data_1      = 0;

            // SOLVER
            reg_solver_uij_up      = 0;
            reg_solver_uij_down    = 0;

            reg_solver_uij_in      = 0;
            reg_solver_uij_prev_in = 0;


        end
    endcase
end

init_values_LUT LUT 
(
    .address(lut_addr),
    .node_value_out(lut_out)
);

endmodule