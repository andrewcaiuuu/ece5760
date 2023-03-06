module memory_block(clk, rst, ci_init, cr_init, 
    max_iterations, range, base, 
    c_vga_sram_address,   
    c_vga_sram_clken,      
    c_vga_sram_chipselect, 
    c_vga_sram_write,      
    c_vga_sram_writedata,
    done );

    input clk, rst;
    input signed [26:0] ci_init, cr_init;
    input [31:0] max_iterations, range, base;

    output c_vga_sram_write, c_vga_sram_clken, c_vga_sram_chipselect, done;
    output [7:0] c_vga_sram_writedata;
    output [31:0] c_vga_sram_address;

    logic vga_sram_write,  vga_sram_clken, vga_sram_chipselect;
    logic [7:0] vga_sram_writedata;
    logic [31:0] vga_sram_address;


    assign c_vga_sram_write = vga_sram_write;
    assign c_vga_sram_clken = vga_sram_clken;
    assign c_vga_sram_chipselect = vga_sram_chipselect;
    assign c_vga_sram_writedata = vga_sram_writedata;
    assign c_vga_sram_address = vga_sram_address;

    logic [7:0] state;
    reg [7:0] pixel_color ;

    logic handshake, all_done, done;
    
    logic [31:0] iterations;
    logic [26:0] final_zi, final_zr;

    always@(posedge clk) begin 
        // reset state machine and read/write controls
        if (rst) begin
            vga_sram_address <= base;
            state <= '0 ;
            vga_sram_write <= 1'b0 ; // set to on if a write operation to bus
        end

        if (state=='0) begin // && ((timer & 15)==0)
            if(done) begin
                pixel_color = color_reg(iterations);
                vga_sram_write <= 1'b1;
                // compute address
                // vga_sram_address <= vga_sram_address;
                // data
                vga_sram_writedata <= pixel_color;

                handshake <= '1;
                vga_sram_address <= vga_sram_address+1;
            end
            if ( all_done ) state <= 8'd22 ; // ending
            else state  <= '1 ;
        end

        // state to deassert handshake, required to make sure we don't miss values 
        if (state =='1) begin 
            vga_sram_write <= '0;
            handshake <= '0;
            state <= '0;
        end 
        
        // -- finished: --
        // -- set up done flag to Qsys sram 0 ---
        if (state == 8'd22) begin
            // end vga write
            vga_sram_write <= 1'b0;
            done <= '1;
        end  
    end

    iterator iter 
    (
        .clk(clk),
        .rst(rst),
        .ci_init(ci_init),
        .cr_init(cr_init),
        .max_iterations(max_iterations),
        .range(range),
        .handshake(handshake),
        .iterations(iterations),
        .final_zi(final_zi),
        .final_zr(final_zr),
        .done(done),
        .all_done(all_done)
    );
    
    function [7:0] color_reg([31:0] iterations);
        begin
            if (iterations >= max_iterations) begin
                color_reg = 8'b_000_000_00 ; // black
            end
            else if (iterations >= (max_iterations >>> 1)) begin
                color_reg = 8'b_011_001_00 ; // white
            end
            else if (iterations >= (max_iterations >>> 2)) begin
                color_reg = 8'b_011_001_00 ;
            end
            else if (iterations >= (max_iterations >>> 3)) begin
                color_reg = 8'b_101_010_01 ;
            end
            else if (iterations >= (max_iterations >>> 4)) begin
                color_reg = 8'b_011_001_01 ;
            end
            else if (iterations >= (max_iterations >>> 5)) begin
                color_reg = 8'b_001_001_01 ;
            end
            else if (iterations >= (max_iterations >>> 6)) begin
                color_reg = 8'b_011_010_10 ;
            end
            else if (iterations >= (max_iterations >>> 7)) begin
                color_reg = 8'b_010_100_10 ;
            end
            else if (iterations >= (max_iterations >>> 8)) begin
                color_reg = 8'b_010_100_10 ;
            end
            else begin
                color_reg = 8'b_010_100_10 ;
            end
        end
    endfunction

endmodule
