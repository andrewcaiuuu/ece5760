module single_column(
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

logic next_node, node;
logic init_done;

typedef enum {S_START, S_INIT, S_DO_CALC, S_WRITE_MEM, S_INCREMENT, S_DONE} state_t;

state_t state, next_state;

// State machine: moves from top to bottom of column
always @(posedge clk) begin
    if (rst) begin
        state <= S_START //do we need a starting state? probably

    end
    else begin
        state <= next_state;
        if (state == S_INIT) begin
            // initialize values for memory, nodes
        end

        else if (state == S_DO_CALC) begin
            // use solver, store and solve new values
        end

        else if (state == S_WRITE_MEM) begin
            // update values for nodes above, registers for left, right, (down)
        end

        else (state == S_INCREMENT) begin
            // something with node = node + 1;
        end 

// State transition logic
always_comb begin
    case (state)
        S_START: begin
            next_state = S_START;
            if (~rst)
        end 

        S_INIT: begin
            next_state = S_INIT;
            if (init_done)
                next_state = S_DO_CALC;
        end

        S_DO_CALC: begin
            next_state = S_DO_CALC;
            if (calc_done)
                next_state = S_INCREMENT;
        end

        S_WRITE_MEM: begin
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


