module solvers(
    input clk, reset

    input arm_val,
    input arm_ack,
    input [31:0] arm_data,
    output fpga_ack,

    input signed [17:0] image_mem_data [0:239], // 239 image mems
    output logic [8:0] best_endpoint,
    output logic done,

    output logic [9:0] image_mem_addr
);

endmodule

logic [8:0] x0, y0;
logic [8:0] x1s [0:39];
logic [8:0] y1s [0:39];

logic [8:0] xs [0:39];
logic [8:0] ys [0:39];
logic [39:0] valids;
logic [39:0] dones;
logic ack_bs;

// logic signed [7:0] with [0:89];
// logic signed [7:0] without [0:89];

logic signed [9:0] reduction [0:39];

logic br_reset;

genvar i;
generate
    for (i=0; i<40; i=i+1) begin: imageMemGen
        bresenham br(
            .clk(clk),
            .reset(br_reset),
            .x0(x0),
            .y0(y0),
            .x1(x1s[i]),
            .y1(y1s[i]),
            .x(xs[i]),
            .y(ys[i]),
            .valid(valids[i]),
            .done(dones[i]),
            .ack(1)
        );
    end
endgenerate

// logic [9:0] image_mem_data_idx [0:39]; // variable to keep track of where we should be reading from

logic [3:0] state;
logic [7:0] count;
logic all_last;
logic group_last;
logic group_first;

logic have_valid;

always @ posedge(clk) begin 
    if (reset) begin 
        state <= 0;
        count <= 0;
        group_first <= 1;
        ack_bs <= 0;
        done <= 0;
        // integer rr;
        // for (rr=0; rr<40; rr=rr+1) begin 
        //     image_mem_data_idx[rr] <= 0;
        // end
    end 
    else if (state == 0) begin // wait asynch read of endpoint data from arm
        state <= 0;
        if (arm_val) begin 
            state <= 1;
            fpga_ack <= 1;
            all_last <= arm_data[31];
            group_last <= arm_data[15];
            group_first <= 0;
            if (group_first) begin 
                x0 <= arm_data[8:0];
                y0 <= arm_data[17:9];
            end 
            else begin 
                x1s[count] <= arm_data[8:0];
                y1s[count] <= arm_data[17:9];
                count <= count + 1;
            end 
        end
    end 
    // 2 HANDSHAKE ================================================
    else if (state == 1) begin 
        state <= 1;
        if (arm_ack) begin 
            state <= 2;
            fpga_ack <= 0;
        end
    end 
    else if (state == 2) begin 
        state <= 2;
        if (~arm_ack) begin 
            state <= 3;
        end 
    end 
    // 2 HANDSHAKE ================================================

    else if (state == 3) begin 
        if ( group_last ) begin 
            state <= 4;
        end 
        else begin 
            state <= 0;
        end 
    end 

    else if (state == 4) begin // RESET THE BRESENHAM SOLVERS, START COMPUTATIONS
        br_reset <= 1;
        state <= 5;
    end 

    else if (state == 5) begin 
        br_reset <= 0;
        state <= 6;
    end 
    else if (state == 6) begin // HAVE VALID BRESENHAM OUTPUT
        state <= 7;
        integer ii;
        for (ii=0; ii<40; ii=ii+1) begin // set address as first valid bresenham output
            if (valids[ii]) begin 
                state <= 6;
                image_mem_addr <= xs[ii];
            end 
        end
    end 
end 
