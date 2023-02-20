module iterator(clk, rst, ci, cr, max_iterations, iterations, done);
    input clk;
    input rst;
    input signed [26:0] ci;
    input signed [26:0] cr;
    input [31:0] max_iterations;

    output reg [31:0] iterations;
    output reg done;

    // zi zr and zi2 zr2 
    logic signed [26:0] temp_zi;
    logic signed [26:0] temp_zr;

    logic signed [26:0] zi;
    logic signed [26:0] zr;

    logic signed [26:0] temp_zi_2;
    logic signed [26:0] temp_zr_2;

    logic signed [26:0] zi_2;
    logic signed [26:0] zr_2;

    // zi * zr
    logic signed [26:0] zr_times_zi;
    
    // adder stuffs
    assign zr = (temp_zr_2 - temp_zi_2) + cr;
    assign zi = ((zr_times_zi) << 1) + ci;

    always@(posedge clk) begin 
        // active high reset
        if (rst) begin
            iterations <= 0;
            temp_zi <= 0;
            temp_zr <= 0;
            temp_zi_2 <= 0;
            temp_zr_2 <= 0;
            done <= 0;
        end
        else begin
            iterations <= iterations + 1;
            // fixed point 4
            if ( (zi_2 + zr_2) > 32'b0010000000000000000000000000 )begin
                done <= 1;
            end
            else begin 
                temp_zi <= zi;
                temp_zr <= zr;
                temp_zi_2 <= zi_2;
                temp_zr_2 <= zr_2;
            end
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