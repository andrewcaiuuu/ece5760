module solvers(
    input clk, reset,

    input arm_val,
    input arm_ack,
    input [31:0] arm_data,
    input [31:0] arm_data2,

    input [19:0] image_mem_data, // 239 image mems

    output logic fpga_val,
    output logic fpga_ack,
    output logic [31:0] fpga_data,

    output logic [9:0] image_mem_addr,
    output logic [9:0] which_mem,
    output logic we,
    output logic [19:0] image_mem_writeout,
    output logic [7:0] debug_count
);

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

logic [15:0] total_norms [0:39];
logic signed [15:0] total_reductions [0:39];
logic signed [15:0] reductions [0:39];
logic signed [8:0] image_readouts [0:39];

always_comb begin 
    integer ir;
    for (ir=0;ir<40; ir=ir+1) begin: image_readouts_comb
        if (ys[ir][0]) begin 
            image_readouts[ir] = image_mem_data[8:0];
        end 
        else begin 
            image_readouts[ir] = image_mem_data[17:9];
        end 
    end 
end 


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
            .ack(ack_bs)
        );
    end
endgenerate

genvar j;
generate 
    for (j=0; j<40; j=j+1) begin: reductionGen
        reduction_calculator rc(
            .image_data(image_readouts[j]),
            .weight_data(0),
            .reduction(reductions[j])
        );
    end 
endgenerate

// logic [9:0] image_mem_data_idx [0:39]; // variable to keep track of where we should be reading from

logic [7:0] state;
logic [7:0] read_index;
logic [7:0] read_counter;


// logic all_last;
logic group_last;
logic group_first;
logic is_last;

logic have_valid;
integer rr, ii, jj, rrr;

assign debug_count = state;

always @(posedge clk) begin 
    if (reset) begin 
        we <= 0;
        which_mem <= 0;
        state <= 0;
        read_index <= 0;
        group_first <= 1;
        ack_bs <= 0;
        read_counter <= 0;

        // generate:
        for (rr=0; rr<40; rr=rr+1) begin : reset_loop
            total_reductions[rr] <= 0;
            total_norms[rr] <= 0;
        end
        // endgenerate
    end 
    else if (state == 0) begin // wait asynch read of endpoint data from arm
        state <= 0;
        if (arm_val) begin 
            state <= 1;
            fpga_ack <= 1;
            // all_last <= arm_data[31];
            group_last <= arm_data[31];
            group_first <= 0;
            if (group_first) begin 
                x0 <= arm_data[8:0];
                y0 <= arm_data[17:9];
            end 
            else begin 
                x1s[read_index] <= arm_data[8:0];
                y1s[read_index] <= arm_data[17:9];
                read_index <= read_index + 1;
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
        for (ii=0; ii<40; ii=ii+1) begin // set address as first valid bresenham output
            if (valids[ii]) begin 
                state <= 9;
                image_mem_addr <= xs[ii];
                which_mem <= ys[ii>>1];
            end 
        end
    end 
    else if (state == 7) begin // memory latency
        state <= 8;
        ack_bs <= 1; 
    end 
    else if (state == 8) begin // this cycle ack_bs is 1, next cycle we will have next valid
        state <= 6;
        ack_bs <= 0;
        for (jj=0; jj<40; jj=jj+1) begin 
            if (valids[jj]) begin 
                total_norms[jj] <= total_norms[jj] + 1;
                total_reductions[jj] <= total_reductions[jj] + reductions[jj];
            end 
        end
    end 
    else if (state == 9) begin // nothing was valid, send values to arm
        state <= 10;
        fpga_val <= 1;
        fpga_data <= {total_norms[read_counter], total_reductions[read_counter]};
    end 
    else if (state == 10) begin 
        state <= 10;
        if (arm_ack) begin 
            state <= 11;
            fpga_val <= 0;
            fpga_ack <= 1;
        end 
    end 
    else if (state == 11) begin 
        state <= 11;
        if (~arm_ack) begin 
            state <= 12;
            fpga_ack <= 0;
        end
    end 
    else if (state == 12) begin 
        read_counter <= read_counter + 1;
        state <= 9;
        if (read_counter == 39) begin // done writing everything to arm
            state <= 13;
        end 
    end  
    else if (state == 13) begin // read write requests from arm
        state <= 13;
        if (arm_val) begin 
            we <=  1;
            image_mem_writeout <= arm_data[19:0];
            image_mem_addr <= arm_data2[15:0];
            which_mem <= arm_data2[31:16];
            state <= 14;
            is_last <= arm_data[31];
            fpga_ack <= 1;
        end 
    end 
    else if (state == 14) begin 
        state <= 14;
        if (arm_ack) begin 
            state <= 15;
            fpga_ack <= 0;
        end
    end 
    else if (state == 15) begin 
        state <= 15;
        if (~arm_ack) begin 
            state <= 16;
        end
    end 
    else if (state == 16) begin 
        if ( is_last ) begin 
            we <= 0;
            which_mem <= 0;
            state <= 0;
            read_index <= 0;
            group_first <= 1;
            ack_bs <= 0;
            read_counter <= 0;
            // integer rrr;
            for (rrr=0; rrr<40; rrr=rrr+1) begin 
                total_reductions[rrr] <= 0;
                total_norms[rrr] <= 0;
            end

        end 
        else begin 
            state <= 13;    
        end 
    end 
end 

endmodule