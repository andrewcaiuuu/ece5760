module iterator(clk, rst, ci_init, 
cr_init, max_iterations, range,  handshake, 
iterations, done, all_done, cr_incr, ci_incr, 
cr_stop, cr_reset
);
    input clk;
    input rst;

    input signed [26:0] ci_init;
    input signed [26:0] cr_init;
    input [31:0] max_iterations;
    input signed [31:0] range;
    input handshake;
    input signed [26:0] cr_incr;
    input signed [26:0] ci_incr;
    input signed [26:0] cr_stop;
    input signed [26:0] cr_reset;

    output [31:0] iterations;
    output done; // one iter
    output all_done; // all iters

    logic signed [26:0] next_ci, next_cr; 
    logic signed [31:0] cur_range;
    // logic signed [26:0] cr_incr = 27'sh9999;
    // logic signed [26:0] ci_incr = 27'sh8888;

    // I AM RIGHT
    // logic signed [26:0] cr_incr = 27'sh999a;
    // logic signed [26:0] ci_incr = 27'sh88a4;
    logic signed [9:0] counter_640;
    logic c_all_done;
    logic iterblock_rst;
    assign all_done = c_all_done;
    typedef enum {S_START, S_DO_CALC, S_WAIT_HANDSHAKE, S_INCREMENT, S_DONE} state_t;

    state_t state, next_state;

    always @(posedge clk) begin 
        if (rst) begin 
            state <= S_START;
            cur_range <= range;
            next_ci <= ci_init;
            next_cr <= cr_init;
            counter_640 <= 10'd640;
        end 
        else begin 
            state <= next_state;
            if (state == S_START) begin 
                iterblock_rst <= 1;
            end 
            else if (state == S_DO_CALC) begin 
                iterblock_rst <= 0;
            end 
            else if (state == S_INCREMENT) begin 
                iterblock_rst <= 1;
                cur_range <= cur_range - 1;

                if ( counter_640 == 1 ) begin  
                    counter_640 <= 10'd640;
                    next_ci <= next_ci - ci_incr;
                    next_cr <= cr_reset;
                end
                else begin 
                    next_cr <= next_cr + cr_incr;
                    counter_640 <= counter_640 - 1;
                end 
                // if ( (next_cr + cr_incr) > 27'sh800000 ) begin  
                //      next_ci <= next_ci - ci_incr;
                //      next_cr <= 27'sh7000000;
                // end
                // else begin 
                //     next_cr <= next_cr + cr_incr;
                //     counter_639 <= counter_639 - 1;
                // end 
            end 
        end 
    end

    // state transition logic
    always_comb begin 
        case (state)
            S_START: begin 
                next_state = S_START;
                if (~rst)
                    next_state = S_DO_CALC;
            end 
            S_DO_CALC: begin 
                next_state = S_DO_CALC;
                if (done)
                    next_state = S_WAIT_HANDSHAKE;
            end 
            S_WAIT_HANDSHAKE: begin 
                next_state = S_WAIT_HANDSHAKE;
                if (handshake)
                    next_state = S_INCREMENT;
            end 
            S_INCREMENT: begin 
                if (cur_range > 1) 
                    next_state = S_DO_CALC;
                else
                    next_state = S_DONE;
            end 
            S_DONE: begin 
                next_state = S_DONE;
                if (rst) 
                    next_state = S_START;
            end 
            default: begin 
                next_state = S_START;
            end
        endcase 
    end 

    // state outputs 
    always_comb begin 
        case (state)
            S_START: begin 
                // iterblock_rst = 1;
                c_all_done = 0;
            end 
            S_DO_CALC: begin 
                // iterblock_rst = 0;
                c_all_done = 0;
            end 
            S_WAIT_HANDSHAKE: begin 
                // iterblock_rst = 0;
                c_all_done = 0;
            end
            S_INCREMENT: begin 
                // iterblock_rst = 1;
                c_all_done = 0;
            end 
            S_DONE: begin 
                // iterblock_rst = 0;
                c_all_done = 1;
            end 
            default: begin 
                //  iterblock_rst = 0;
                c_all_done = 0;
            end
        endcase
    end 

    iterblock iterblock1
    (
    .clk(clk), //in
    .rst(iterblock_rst), //in 
    .ci(next_ci), //in
    .cr(next_cr), //in 
    .max_iterations(max_iterations), //in
    .iterations(iterations), //out
    .done(done) //out
    );

endmodule 
