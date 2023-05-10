

module bresenham (
    input clk, 
    input reset,
    input [7:0] x0, y0, x1, y1,
    output [7:0] x, y,
    output logic valid,
    output logic done
);

logic signed [7:0] reg_x, reg_y;
logic signed [7:0] dx, dy, sx, sy, err, e2;

assign x = reg_x;
assign y = reg_y;

always_comb begin 
    dx = (x0 < x1) ? (x1 - x0) : (x0 - x1);
    dy = (y0 < y1) ? (y1 - y0) : (y0 - y1);
    e2 = err << 1;
end 

always_ff @(posedge clk) begin
    if (reset) begin 
        valid <= 0;
        done <= 0;
    end
    else if ( ~valid && ~done) begin 
        reg_x <= x0;
        reg_y <= y0;
        sx <= (x0 < x1) ? 1: -1;
        sy <= (y0 < y1) ? 1: -1;
        err <= dx - dy;
        valid <= 1'b1;
    end else if ( valid ) begin 
        if ( e2 > -dy ) begin 
            err <= err - dy;
            reg_x <= reg_x + sx;
        end
        if ( e2 < dx ) begin 
            err <= err + dx;
            reg_y <= reg_y + sy;
        end
        else begin 
            err <= err - dy + dx;
            reg_x <= reg_x + sx;
            reg_y <= reg_y + sy;
        end 
        if (reg_x == x1 && reg_y == y1) begin 
            valid <= 0;
            done <= 1;
        end 
    end 
end


endmodule