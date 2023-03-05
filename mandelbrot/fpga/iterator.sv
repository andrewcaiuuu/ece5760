module iterator(clk, rst, ci_init, 
cr_init, max_iterations, range,  handshake, 
iterations, final_zi, final_zr, done, all_done);
    input clk;
    input rst;

    input signed [26:0] ci_init;
    input signed [26:0] cr_init;
    input [31:0] max_iterations;
    input [31:0] range;
    input handshake;

    output [31:0] iterations;
    output signed [26:0] final_zi;
    output signed [26:0] final_zr;

    output done; // one iter
    output all_done; // all iters

    logic [26:0] cr_incr = 27'sh9999;
    logic [26:0] ci_incr = 27'sh8888;

    logic [31:0] cur_iterations, cur_iterations_in;
    logic signed [26:0] ci, ci_in;
    logic signed [26:0] cr, cr_in;
    logic [31:0] cur_range, cur_range_in;

    // zi zr and zi2 zr2 
    logic signed [26:0] temp_zi, temp_zi_in;
    logic signed [26:0] temp_zr, temp_zr_in;

    logic signed [26:0] zi;
    logic signed [26:0] zr;

    logic signed [26:0] temp_zi_2, temp_zi_2_in;
    logic signed [26:0] temp_zr_2, temp_zr_2_in;

    logic signed [26:0] zi_2;
    logic signed [26:0] zr_2;

    // zi * zr
    logic signed [26:0] zr_times_zi;
    
    logic [31:0] c_iterations;
    logic signed [26:0] c_final_zi;
    logic signed [26:0] c_final_zr;
    logic c_done; // one iter
    logic c_all_done; // all iters

    assign iterations = c_iterations;
    assign final_zi = c_final_zi;
    assign final_zr = c_final_zr;
    assign done = c_done;
    assign all_done = c_all_done;



    // adder stuffs
    assign zr = (temp_zr_2 - temp_zi_2) + cr;
    assign zi = ((zr_times_zi) << 1) + ci;

    typedef enum {S_RESET, S_DO_ITER, S_WAIT_HANDSHAKE, S_DONE} state_t;
    state_t scurr, snext;

    always_comb begin 
        case (scurr)
            S_RESET: begin 
                if (~rst )
                    snext = S_DO_ITER;
                else 
                    snext = S_RESET;
                cur_iterations_in = 0;
                temp_zi_in = 0;
                temp_zr_in = 0;
                temp_zi_2_in = 0;
                temp_zr_2_in = 0;
                ci_in = ci_init;
                cr_in = cr_init;
                cur_range_in = range;
            end 

            S_DO_ITER: begin 
                if(cur_iterations == max_iterations) begin
                    snext = S_WAIT_HANDSHAKE;
                end
                else begin 

                    cur_iterations_in = cur_iterations + 1;
                    // fixed point 4
                    
                    if( (zi >= 27'sh1000000) || (zr >= 27'sh1000000) || (zi <= -27'sh1000000) || (zr <= -27'sh1000000)) begin
                        snext = S_WAIT_HANDSHAKE;
                    end

                    else if ( (zi_2 + zr_2) > 32'sb0010000000000000000000000000 )begin
                        snext = S_WAIT_HANDSHAKE;
                    end
                    
                    else begin 
                        temp_zi_in = zi;
                        temp_zr_in = zr;
                        temp_zi_2_in = zi_2;
                        temp_zr_2_in = zr_2;
                        snext = S_DO_ITER;
                    end
                end
            end 

            S_WAIT_HANDSHAKE: begin 
                if ( handshake ) begin 
                    cur_iterations_in = '0;
                    if ( cur_range != 32'b1 ) begin 
                        cur_range_in = cur_range - 1;
                        if ( (cr + cr_incr) > 27'sh800000 ) begin 
                            if ( (ci + ci_incr) > 27'sh800000 ) begin 
                                ci_in = ci + ci_incr;
                                cr_in = 27'shff000000;
                            end 
                        end

                        else begin 
                            cr_in = cr + cr_incr;
                        end 
                        snext = S_DO_ITER;
                    end 
                   
                    else begin
                        snext = S_DONE;
                    end
                end  
                else begin
                    snext = S_WAIT_HANDSHAKE;
                end
            end 

            S_DONE: begin 
                if ( rst )
                    snext = S_RESET;
                else
                    snext = S_DONE;
            end 
        endcase 
    end 

    always_comb begin 
        case (scurr) 
            S_RESET: begin 
                c_all_done = '0;
                c_final_zi = '0;
                c_done = 0;
                c_final_zr = '0; 
                c_iterations = '0;
            end 

            S_DO_ITER: begin
                c_all_done = '0;
                c_done = '0;
                c_final_zi = '0;
                c_final_zr = '0; 
                c_iterations = '0;
            end

            S_WAIT_HANDSHAKE: begin 
                c_done = 1;
                c_all_done = 0;
                c_final_zi = zi;
                c_final_zr = zr; 
                c_iterations = cur_iterations;
            end 

            S_DONE: begin 
                c_all_done = '1;
                c_done = '0;
                c_final_zi = '0;
                c_final_zr = '0; 
                c_iterations = '0;
            end 
        endcase 
    end 

    always@(posedge clk) begin 
        if ( rst ) begin 
            scurr <= S_RESET;
        end 
        else begin 
            scurr <=  snext;
            cur_iterations <= cur_iterations_in;
            temp_zi <= temp_zi_in;
            temp_zr <= temp_zr_in;
            temp_zi_2 <= temp_zi_2_in;
            temp_zr_2 <= temp_zr_2_in;
            cur_range <= cur_range_in;
            ci <= ci_in;
            cr <= cr_in;
        end 
    end 

    signed_mult zr_zi_multiplier
    (
        .out(zr_times_zi),
        .a(temp_zi),
        .b(temp_zr)
    );

    signed_mult zi_squarer
    (
        .out(zi_2),
        .a(zi),
        .b(zi)
    );

    signed_mult zr_squarer
    (
        .out(zr_2),
        .a(zr),
        .b(zr)
    );

endmodule 