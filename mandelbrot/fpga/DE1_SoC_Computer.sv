

module DE1_SoC_Computer (
	////////////////////////////////////
	// FPGA Pins
	////////////////////////////////////

	// Clock pins
	CLOCK_50,
	CLOCK2_50,
	CLOCK3_50,
	CLOCK4_50,

	// ADC
	ADC_CS_N,
	ADC_DIN,
	ADC_DOUT,
	ADC_SCLK,

	// Audio
	AUD_ADCDAT,
	AUD_ADCLRCK,
	AUD_BCLK,
	AUD_DACDAT,
	AUD_DACLRCK,
	AUD_XCK,

	// SDRAM
	DRAM_ADDR,
	DRAM_BA,
	DRAM_CAS_N,
	DRAM_CKE,
	DRAM_CLK,
	DRAM_CS_N,
	DRAM_DQ,
	DRAM_LDQM,
	DRAM_RAS_N,
	DRAM_UDQM,
	DRAM_WE_N,

	// I2C Bus for Configuration of the Audio and Video-In Chips
	FPGA_I2C_SCLK,
	FPGA_I2C_SDAT,

	// 40-Pin Headers
	GPIO_0,
	GPIO_1,
	
	// Seven Segment Displays
	HEX0,
	HEX1,
	HEX2,
	HEX3,
	HEX4,
	HEX5,

	// IR
	IRDA_RXD,
	IRDA_TXD,

	// Pushbuttons
	KEY,

	// LEDs
	LEDR,

	// PS2 Ports
	PS2_CLK,
	PS2_DAT,
	
	PS2_CLK2,
	PS2_DAT2,

	// Slider Switches
	SW,

	// Video-In
	TD_CLK27,
	TD_DATA,
	TD_HS,
	TD_RESET_N,
	TD_VS,

	// VGA
	VGA_B,
	VGA_BLANK_N,
	VGA_CLK,
	VGA_G,
	VGA_HS,
	VGA_R,
	VGA_SYNC_N,
	VGA_VS,

	////////////////////////////////////
	// HPS Pins
	////////////////////////////////////
	
	// DDR3 SDRAM
	HPS_DDR3_ADDR,
	HPS_DDR3_BA,
	HPS_DDR3_CAS_N,
	HPS_DDR3_CKE,
	HPS_DDR3_CK_N,
	HPS_DDR3_CK_P,
	HPS_DDR3_CS_N,
	HPS_DDR3_DM,
	HPS_DDR3_DQ,
	HPS_DDR3_DQS_N,
	HPS_DDR3_DQS_P,
	HPS_DDR3_ODT,
	HPS_DDR3_RAS_N,
	HPS_DDR3_RESET_N,
	HPS_DDR3_RZQ,
	HPS_DDR3_WE_N,

	// Ethernet
	HPS_ENET_GTX_CLK,
	HPS_ENET_INT_N,
	HPS_ENET_MDC,
	HPS_ENET_MDIO,
	HPS_ENET_RX_CLK,
	HPS_ENET_RX_DATA,
	HPS_ENET_RX_DV,
	HPS_ENET_TX_DATA,
	HPS_ENET_TX_EN,

	// Flash
	HPS_FLASH_DATA,
	HPS_FLASH_DCLK,
	HPS_FLASH_NCSO,

	// Accelerometer
	HPS_GSENSOR_INT,
		
	// General Purpose I/O
	HPS_GPIO,
		
	// I2C
	HPS_I2C_CONTROL,
	HPS_I2C1_SCLK,
	HPS_I2C1_SDAT,
	HPS_I2C2_SCLK,
	HPS_I2C2_SDAT,

	// Pushbutton
	HPS_KEY,

	// LED
	HPS_LED,
		
	// SD Card
	HPS_SD_CLK,
	HPS_SD_CMD,
	HPS_SD_DATA,

	// SPI
	HPS_SPIM_CLK,
	HPS_SPIM_MISO,
	HPS_SPIM_MOSI,
	HPS_SPIM_SS,

	// UART
	HPS_UART_RX,
	HPS_UART_TX,

	// USB
	HPS_CONV_USB_N,
	HPS_USB_CLKOUT,
	HPS_USB_DATA,
	HPS_USB_DIR,
	HPS_USB_NXT,
	HPS_USB_STP
);

//=======================================================
//  PARAMETER declarations
//=======================================================


//=======================================================
//  PORT declarations
//=======================================================

////////////////////////////////////
// FPGA Pins
////////////////////////////////////

// Clock pins
input						CLOCK_50;
input						CLOCK2_50;
input						CLOCK3_50;
input						CLOCK4_50;

// ADC
inout						ADC_CS_N;
output					ADC_DIN;
input						ADC_DOUT;
output					ADC_SCLK;

// Audio
input						AUD_ADCDAT;
inout						AUD_ADCLRCK;
inout						AUD_BCLK;
output					AUD_DACDAT;
inout						AUD_DACLRCK;
output					AUD_XCK;

// SDRAM
output 		[12: 0]	DRAM_ADDR;
output		[ 1: 0]	DRAM_BA;
output					DRAM_CAS_N;
output					DRAM_CKE;
output					DRAM_CLK;
output					DRAM_CS_N;
inout			[15: 0]	DRAM_DQ;
output					DRAM_LDQM;
output					DRAM_RAS_N;
output					DRAM_UDQM;
output					DRAM_WE_N;

// I2C Bus for Configuration of the Audio and Video-In Chips
output					FPGA_I2C_SCLK;
inout						FPGA_I2C_SDAT;

// 40-pin headers
inout			[35: 0]	GPIO_0;
inout			[35: 0]	GPIO_1;

// Seven Segment Displays
output		[ 6: 0]	HEX0;
output		[ 6: 0]	HEX1;
output		[ 6: 0]	HEX2;
output		[ 6: 0]	HEX3;
output		[ 6: 0]	HEX4;
output		[ 6: 0]	HEX5;

// IR
input						IRDA_RXD;
output					IRDA_TXD;

// Pushbuttons
input			[ 3: 0]	KEY;

// LEDs
output		[ 9: 0]	LEDR;

// PS2 Ports
inout						PS2_CLK;
inout						PS2_DAT;

inout						PS2_CLK2;
inout						PS2_DAT2;

// Slider Switches
input			[ 9: 0]	SW;

// Video-In
input						TD_CLK27;
input			[ 7: 0]	TD_DATA;
input						TD_HS;
output					TD_RESET_N;
input						TD_VS;

// VGA
output		[ 7: 0]	VGA_B;
output					VGA_BLANK_N;
output					VGA_CLK;
output		[ 7: 0]	VGA_G;
output					VGA_HS;
output		[ 7: 0]	VGA_R;
output					VGA_SYNC_N;
output					VGA_VS;



////////////////////////////////////
// HPS Pins
////////////////////////////////////
	
// DDR3 SDRAM
output		[14: 0]	HPS_DDR3_ADDR;
output		[ 2: 0]  HPS_DDR3_BA;
output					HPS_DDR3_CAS_N;
output					HPS_DDR3_CKE;
output					HPS_DDR3_CK_N;
output					HPS_DDR3_CK_P;
output					HPS_DDR3_CS_N;
output		[ 3: 0]	HPS_DDR3_DM;
inout			[31: 0]	HPS_DDR3_DQ;
inout			[ 3: 0]	HPS_DDR3_DQS_N;
inout			[ 3: 0]	HPS_DDR3_DQS_P;
output					HPS_DDR3_ODT;
output					HPS_DDR3_RAS_N;
output					HPS_DDR3_RESET_N;
input						HPS_DDR3_RZQ;
output					HPS_DDR3_WE_N;

// Ethernet
output					HPS_ENET_GTX_CLK;
inout						HPS_ENET_INT_N;
output					HPS_ENET_MDC;
inout						HPS_ENET_MDIO;
input						HPS_ENET_RX_CLK;
input			[ 3: 0]	HPS_ENET_RX_DATA;
input						HPS_ENET_RX_DV;
output		[ 3: 0]	HPS_ENET_TX_DATA;
output					HPS_ENET_TX_EN;

// Flash
inout			[ 3: 0]	HPS_FLASH_DATA;
output					HPS_FLASH_DCLK;
output					HPS_FLASH_NCSO;

// Accelerometer
inout						HPS_GSENSOR_INT;

// General Purpose I/O
inout			[ 1: 0]	HPS_GPIO;

// I2C
inout						HPS_I2C_CONTROL;
inout						HPS_I2C1_SCLK;
inout						HPS_I2C1_SDAT;
inout						HPS_I2C2_SCLK;
inout						HPS_I2C2_SDAT;

// Pushbutton
inout						HPS_KEY;

// LED
inout						HPS_LED;

// SD Card
output					HPS_SD_CLK;
inout						HPS_SD_CMD;
inout			[ 3: 0]	HPS_SD_DATA;

// SPI
output					HPS_SPIM_CLK;
input						HPS_SPIM_MISO;
output					HPS_SPIM_MOSI;
inout						HPS_SPIM_SS;

// UART
input						HPS_UART_RX;
output					HPS_UART_TX;

// USB
inout						HPS_CONV_USB_N;
input						HPS_USB_CLKOUT;
inout			[ 7: 0]	HPS_USB_DATA;
input						HPS_USB_DIR;
input						HPS_USB_NXT;
output					HPS_USB_STP;

//=======================================================
//  REG/WIRE declarations
//=======================================================

wire			[15: 0]	hex3_hex0;
//wire			[15: 0]	hex5_hex4;

//assign HEX0 = ~hex3_hex0[ 6: 0]; // hex3_hex0[ 6: 0]; 
//assign HEX1 = ~hex3_hex0[14: 8];
//assign HEX2 = ~hex3_hex0[22:16];
//assign HEX3 = ~hex3_hex0[30:24];
assign HEX4 = 7'b1111111;
assign HEX5 = 7'b1111111;

HexDigit Digit0(HEX0, hex3_hex0[3:0]);
HexDigit Digit1(HEX1, hex3_hex0[7:4]);
HexDigit Digit2(HEX2, hex3_hex0[11:8]);
HexDigit Digit3(HEX3, hex3_hex0[15:12]);

// VGA clock and reset lines
wire vga_pll_lock ;
wire vga_pll ;
reg  vga_reset ;

// M10k memory control and data
wire 		[7:0] 	M10k_outs[0:9];
reg 		[7:0] 	M10k_out;

/*
reg 		[7:0] 	write_data, write_data1, write_data2 ;
reg 		[18:0] 	write_address, write_address1, next_write_address1, write_address2, next_write_address2 ;
reg 		[18:0] 	read_address ;
reg 					write_enable, write_enable1, write_enable2 ;
*/

reg 		[18:0] 	read_address ;


// M10k memory clock
wire 					M10k_pll ;
wire 					M10k_pll_locked ;

// Memory writing control registers
//reg 		[7:0] 	arbiter_state ;
//reg 		[9:0] 	x_coord ;
//reg 		[9:0] 	y_coord ;

// Wires for connecting VGA driver to memory
wire 		[9:0]		next_x ;
wire 		[9:0] 	next_y ;


wire[3:0] zoom;

wire[26:0] init_ci_global;
wire[26:0] init_cr_global;



/*

reg state1, state2;
always@(posedge M10k_pll) begin
	// Zero everything in reset
	if (~KEY[0]) begin
		arbiter_state <= 8'd_0 ;
		// vga_reset <= 1'b_1 ;
		x_coord <= 10'd_0 ;
		y_coord <= 10'd_0 ;
		state1 <= 8'd0 ;
		write_address1 <= 8'd0;
		next_write_address1 <= 8'd0;
	end
	// Otherwiser repeatedly write a large checkerboard to memory
	else begin
		if ( all_done1 ) begin 
			// vga_reset <= 1'b_0;
			write_enable1 <= 1'b0;
		end
		else begin 
			if (state1 == 8'd0) begin 
				state1 <= 8'd1;
				if ( done1 ) begin 
					write_enable1 <= 1'b1;
					// compute address
					handshake1 <= 1'b1;
					write_address1 <= next_write_address1; 
					next_write_address1 <= write_address1 + 1;
					// data
					write_data1 <= color_reg(iterations1);
				end 
			end 
			if (state1 == 8'd1) begin 
				handshake1 <= 1'b0;
				write_enable1 <= 1'b0;
				state1  <= 8'd0 ;
			end
		end 
	end
end
// for second iterator
always@(posedge M10k_pll) begin 
	// Zero everything in reset
	if (~KEY[0]) begin
		state2 <= 8'd0 ;
		write_address2 <= 8'd0;
		next_write_address2 <= 8'd0;
	end
	// Otherwiser repeatedly write a large checkerboard to memory
	else begin
		if ( all_done2 ) begin 
			// vga_reset <= 1'b_0;
			write_enable2 <= 1'b0;
		end
		else begin 
			if (state2 == 8'd0) begin 
				state2 <= 8'd1;
				if ( done2 ) begin 
					write_enable2 <= 1'b1;
					// compute address
					handshake2 <= 1'b1;
					write_address2 <= next_write_address2; 
					next_write_address2 <= write_address2 + 1;
					// data
					write_data2 <= color_reg(iterations2);
				end 
			end 
			if (state2 == 8'd1) begin 
				handshake2 <= 1'b0;
				write_enable2 <= 1'b0;
				state2  <= 8'd0 ;
			end
		end 
	end

end 

*/
reg [9:0] arbiter_state [0:9];
reg [9:0] x_coord [0:9];
reg [9:0] y_coord [0:9];
reg [7:0] state [0:9];
reg 		[18:0] write_address [0:9];
reg 		[18:0] next_write_address [0:9];
reg [7:0] write_data [0:9];
reg     [9:0]   which_memblock = 0; //new
reg [9:0] switch_values [0:9] = '{9'd_0, 9'd_48, 9'd_96, 9'd_144, 9'd_192, 9'd_240, 9'd_288, 9'd_336, 9'd_384, 9'd_432};

// always@(posedge M10k_pll) begin 
// 	// output which_memblock for one hot decoding later
// 	if (next_y == switch_values[0]) begin 
// 		switch_values[0:8] <= switch_values[1:9];
// 		switch_values[9] <= -9'sd1; // put in negative 1 so it never matches again
// 		which_memblock <= (which_memblock >> 1 ) | 9'b1;
// 	end 
// 	else begin 
// 		which_memblock <= which_memblock;
// 		switch_values <= switch_values;
// 	end 

// end 

always@(*) begin 
	// default vga driver is outputting next_y, next_x,
	// i was lazy so just using this for now to calculate true range
	// then do muxing on this value
	if (( (19'd_640*next_y) + next_x ) > 19'd_276471) begin 
		which_memblock = 10'd_9;
	end 
	else if (( (19'd_640*next_y) + next_x ) > 19'd_245752) begin 
		which_memblock = 10'd_8;
	end 
	else if (( (19'd_640*next_y) + next_x ) > 19'd_215033) begin 
		which_memblock = 10'd_7;
	end 
	else if (( (19'd_640*next_y) + next_x ) > 19'd_184314) begin 
		which_memblock = 10'd_6;
	end 
	else if (( (19'd_640*next_y) + next_x ) > 19'd_153595) begin 
		which_memblock = 10'd_5;
	end 
	else if (( (19'd_640*next_y) + next_x ) > 19'd_122876) begin 
		which_memblock = 10'd_4;
	end 
	else if (( (19'd_640*next_y) + next_x ) > 19'd_92157) begin 
		which_memblock = 10'd_3;
	end 
	else if (( (19'd_640*next_y) + next_x ) > 19'd_61438) begin 
		which_memblock = 10'd_2;
	end 
	else if (( (19'd_640*next_y) + next_x ) > 19'd_30719) begin 
		which_memblock = 10'd_1;
	end 
	else begin 
		which_memblock = 0;
	end
end



// Instantiate Iterator
wire [31:0] max_iterations = 32'd100;
wire done[0:9];
wire all_done[0:9];
reg handshake[0:9];
wire [31:0] iterations[0:9];

reg write_enable[0:9];
 
// reg[26:0] ci_init[0:9] = '{27'sh0800000, 27'sh0666666, 27'sh04ccccd, 27'sh0333333, 27'sh019999a, 27'sh0000000, 27'sh7e66666, 27'sh7cccccd, 27'sh7b33333, 27'sh799999a}; //double check
// reg[26:0] cr_init[0:9] = '{27'sh7000000, 27'sh7000000, 27'sh7000000, 27'sh7000000, 27'sh7000000, 27'sh7000000, 27'sh7000000, 27'sh7000000, 27'sh7000000, 27'sh7000000}; //double check

reg[26:0] cur_ci[0:9];
reg[26:0] cur_cr[0:9];

// instantiate state machines for each m10k block
genvar i;
generate
    for (i = 0; i < 10; i= i+1) begin : block_gen
        always@(posedge M10k_pll) begin
            // Zero everything in reset
            if (~KEY[0]) begin
                // arbiter_state[i] <= 10'd_0 ;
                // x_coord[i] <= 10'd_0 ;
                // y_coord[i] <= 10'd_0 ;
				// cur_ci <= '{27'sh0800000, 27'sh0666666, 27'sh04ccccd, 27'sh0333333, 27'sh019999a, 27'sh0000000, 27'sh7e66666, 27'sh7cccccd, 27'sh7b33333, 27'sh799999a}; //double check
                // cur_cr <= '{27'sh7000000, 27'sh7000000, 27'sh7000000, 27'sh7000000, 27'sh7000000, 27'sh7000000, 27'sh7000000, 27'sh7000000, 27'sh7000000, 27'sh7000000}; //double check
				state[i] <= 8'd0 ;
                write_address[i] <= 0;
                next_write_address[i] <= 0;
            end
            // Otherwiser repeatedly write a large checkerboard to memory
            else begin
                if (all_done[i]) begin 
                    write_enable[i] <= 1'b0;
                end
                else begin 
                    if (state[i] == 8'd0) begin 
                        state[i] <= 8'd1;
                        if (done[i]) begin 
                            write_enable[i] <= 1'b1;
                            // compute address
                            handshake[i] <= 1'b1;
                            write_address[i] <= next_write_address[i]; 
                            next_write_address[i] <= write_address[i] + 1;
                            // data
                            write_data[i] <= color_reg(iterations[i]);
                        end 
                    end 
                    if (state[i] == 8'd1) begin 
                        handshake[i] <= 1'b0;
                        write_enable[i] <= 1'b0;
                        state[i]  <= 8'd0 ;
                    end
                end 
            end
        end
	end
endgenerate








// MUXING LOGIC OUTSIDE OF VGA STATE MACHINE
// KINDA SHIT 

reg all_done_flag;
// reg signed [26:0] cur_incr;
reg iter_rst;
reg signed [26:0] zoom_center_ci = 0;
reg signed [26:0] zoom_center_cr = 0;
reg signed [26:0] cr_incr, ci_incr, cr_stop, cr_reset;
integer ii, jj;
reg[26:0] numSteps[0:9] = '{27'sh0, 27'sh7800, 27'shf000, 27'sh16800, 27'sh1e000, 27'sh25800, 27'sh2d000, 27'sh34800, 27'sh3c000, 27'sh43800};


always@(posedge M10k_pll) begin 
	LEDR <= 10'd0;
	iter_rst <= 1'b_0;
	if (~KEY[0]) begin 
		iter_rst <= 1'b1;
		// cur_incr <= 27'sh19999A
		cur_ci[0] = init_ci_global;
		cur_cr[0] = init_cr_global;
		// cur_ci[0] <= 27'sh0800000;
		// cur_cr[0] <= 27'sh7000000;
		for(jj=1; jj<10; jj=jj+1) begin 
			cur_ci[jj] <= init_ci_global - ((27'sh88a4>>zoom) * jj * 10'd48);
			// for(ii=0;ii<48;ii=ii+1) begin
			// 	cur_ci[jj] <= cur_ci[jj] + 27'sh88a4>>1;
			// end
			cur_cr[jj] <= cur_cr[0];
		end
		
		
		// cur_ci <= '{27'sh0800000, 27'sh0666666, 27'sh04ccccd, 27'sh0333333, 27'sh019999a, 27'sh0000000, 27'sh7e66666, 27'sh7cccccd, 27'sh7b33333, 27'sh799999a}; //double check
        // cur_cr <= '{27'sh7000000, 27'sh7000000, 27'sh7000000, 27'sh7000000, 27'sh7000000, 27'sh7000000, 27'sh7000000, 27'sh7000000, 27'sh7000000, 27'sh7000000}; //double check
		vga_reset <= 1'b_1 ;
		// cr_incr <= 27'sh999a>>1;
		// ci_incr <= 27'sh88a4>>1;
		cr_incr <= 27'sh999a >> zoom;
		ci_incr <= 27'sh88a4 >> zoom;
		// cr_stop <= 27'sh800000;
		cr_reset <= init_cr_global;
		// cr_reset <=  27'sh7000000;

	end 
	else begin 
		// when all of the iterators are done we write the display
		if ( all_done_flag ) begin
			//LEDR <= 10'd0;
			vga_reset <= 1'b_0 ;
			// KEY 1 is for zoom out
				
		end
	end 
end 


// function reg [26:0] update_ci(
//     input reg [26:0] numSteps,
//     input reg [26:0] init_ci,
//     input reg [26:0] ci_incr
// );
// 	begin
// 		reg [8:0] div = divSixForty(numSteps);
// 		reg [26:0] new_ci = init_ci - (ci_incr * div);
// 		return new_ci;
// 	end
// endfunction

// function reg[26:0] divSixForty(input reg[26:0] val);
// 	begin
// 		reg[26:0] remainder = val;
// 		reg[8:0] res = 9'b0;
// 		reg [9:0] count = 0; //verilog terminbate
// 		while((count < 10'd50) && (remainder >= 27'd640)) begin
// 			remainder = remainder - 27'd640;
// 			res = res+1;
// 			count = count + 1;
// 		end 
// 		return res;
// 	end
// endfunction


// function reg [26:0] update_cr(
//     input reg [26:0] numSteps,
//     input reg [26:0] init_cr,
//     input reg [26:0] cr_incr
// );
// 	begin 
// 		 reg [26:0] new_cr=init_cr + (cr_incr * (numSteps % 640));
// 		 return new_cr;
// 	end
// endfunction



integer x;
always_comb begin
	all_done_flag = 1'b1;
	for(x=0; x < 10; x=x+1)  begin 
		all_done_flag = all_done_flag & all_done[x];
	end
end






// always@(*) begin 
// 	// default vga driver is outputting next_y, next_x,
// 	// i was lazy so just using this for now to calculate true range
// 	// then do muxing on this value
// 	if (( (19'd_640*next_y) + next_x ) > 19'd153599) begin 
// 		which_memblock = 1;
// 	end 
// 	else begin 
// 		which_memblock = 0;
// 	end
// end

always@(*) begin
	// does parallel muxing using casez statement
	case ( which_memblock )
	10'd0: begin
		//LEDR = 10'd10;
		M10k_out = M10k_outs[0];
		read_address = (19'd_640*next_y) + next_x;
	end
	10'd1: begin
		//LEDR = 10'd2;
		M10k_out = M10k_outs[1];
		read_address = (19'd_640*next_y) + next_x - 19'd30720;
	end
	10'd2: begin
		//LEDR = 10'd3;
		M10k_out = M10k_outs[2];
		read_address = (19'd_640*next_y) + next_x - 19'd61440;
	end
	10'd3: begin
		//LEDR = 10'd4;
		M10k_out = M10k_outs[3];
		read_address = (19'd_640*next_y) + next_x - 19'd92160;
	end
	10'd4: begin
		//LEDR = 10'd5;
		M10k_out = M10k_outs[4];
		read_address = (19'd_640*next_y) + next_x - 19'd122880;
	end
	10'd5: begin
		//LEDR = 10'd6;
		M10k_out = M10k_outs[5];
		read_address = (19'd_640*next_y) + next_x - 19'd153600;
	end
	10'd6: begin
		//LEDR = 10'd7;
		M10k_out = M10k_outs[6];
		read_address = (19'd_640*next_y) + next_x - 19'd184320;
	end
	10'd7: begin
		//LEDR = 10'd8;
		M10k_out = M10k_outs[7];
		read_address = (19'd_640*next_y) + next_x - 19'd215040;
	end
	10'd8: begin
		//LEDR = 10'd8;
		M10k_out = M10k_outs[8];
		read_address = (19'd_640*next_y) + next_x - 19'd245760;
	end
	10'd9: begin
		//LEDR = 10'd10;
		M10k_out = M10k_outs[9];
		read_address = (19'd_640*next_y) + next_x - 19'd276480;
	end
	default: begin
		//LEDR = 10'd0;
		M10k_out = M10k_outs[0];
		read_address = (19'd_640*next_y) + next_x;
	end
	endcase
end


// always@(*) begin
// 	// does parallel muxing using casez statement
// 	casez ( which_memblock )
// 	9'b_?_????_???1: begin
// 		LEDR = 10'd1;
// 		M10k_out = M10k_outs[0];
// 		read_address = (19'd_640*next_y) + next_x;
// 	end
// 	9'b_?_????_??1?: begin
// 		LEDR = 10'd2;
// 		M10k_out = M10k_outs[1];
// 		read_address = (19'd_640*next_y) + next_x - 19'd30720;

// 	end
// 	9'b_?_????_?1??: begin
// 		LEDR = 10'd3;
// 		M10k_out = M10k_outs[2];
// 		read_address = (19'd_640*next_y) + next_x - 19'd61440;
// 	end
// 	9'b_?_????_?1??: begin
// 		LEDR = 10'd4;
// 		M10k_out = M10k_outs[3];
// 		read_address = (19'd_640*next_y) + next_x - 19'd92160;
// 	end
// 	9'b_?_????_1???: begin
// 		LEDR = 10'd5;
// 		M10k_out = M10k_outs[4];
// 		read_address = (19'd_640*next_y) + next_x - 19'd122880;
// 	end
// 	9'b_?_???1_????: begin
// 		LEDR = 10'd6;
// 		M10k_out = M10k_outs[5];
// 		read_address = (19'd_640*next_y) + next_x - 19'd153600;
// 	end
// 	9'b_?_??1?_????: begin
// 		LEDR = 10'd7;
// 		M10k_out = M10k_outs[6];
// 		read_address = (19'd_640*next_y) + next_x - 19'd184320;
// 	end
// 	9'b_?_?1??_????: begin
// 		LEDR = 10'd8;
// 		M10k_out = M10k_outs[7];
// 		read_address = (19'd_640*next_y) + next_x - 19'd215040;
// 	end
// 	9'b_?_1???_????: begin
// 		LEDR = 10'd8;
// 		M10k_out = M10k_outs[8];
// 		read_address = (19'd_640*next_y) + next_x - 19'd245760;
// 	end
// 	9'b_1_????_????: begin
// 		LEDR = 10'd10;
// 		M10k_out = M10k_outs[9];
// 		read_address = (19'd_640*next_y) + next_x - 19'd276480;
// 	end
// 	default: begin
// 		LEDR = 10'd0;
// 		M10k_out = M10k_outs[0];
// 		read_address = (19'd_640*next_y) + next_x;
// 	end
// 	endcase
// end


// Instantiate memory
genvar j;
generate
  for (j = 0; j < 10; j=j+1) begin : M10K_instance
    M10K_1000_8 pixel_data (
      .q({M10k_outs[j]}),
      .d({write_data[j]}),
      .write_address({write_address[j]}),
      .read_address(read_address),
      .we({write_enable[j]}),
      .clk(M10k_pll)
    );
  end
endgenerate
// wire [9:0] which_memblock;
// Instantiate VGA driver					
vga_driver DUT   (	.clock(vga_pll), 
							.reset(vga_reset),
							.color_in(M10k_out),	// Pixel color (8-bit) from memory
							.next_x(next_x),		// This (and next_y) used to specify memory read address
							.next_y(next_y),		// This (and next_x) used to specify memory read address
							.hsync(VGA_HS),
							.vsync(VGA_VS),
							.red(VGA_R),
							.green(VGA_G),
							.blue(VGA_B),
							.sync(VGA_SYNC_N),
							.clk(VGA_CLK),
							.blank(VGA_BLANK_N)
);

function [7:0] color_reg(input [31:0] iterations);
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

// function [26:0] calculate_ci_zoom_in[0:9](input [26:0] center);
// 	begin
// 		integer calc_ci;
// 		for(calc_ci=0; calc_ci<10;calc_ci=calc_ci+1) begin 
// 			calculate_ci_zoom_in[i] = cur_ci[0] << 1;
// 		end
// 	end
// endfunction

// function [26:0] calculate_cr_zoom_in[0:9](input [26:0] center);
// 	begin
// 		integer calc_cr;
// 		for(calc_cr=0; calc_cr<10;calc_cr=calc_cr+1) begin 
// 			calculate_cr_zoom_in[i] = cur_cr[0] << 1;
// 		end
// 	end
// endfunction



//reg[26:0] ci_init[0:9] = '{27'sh0800000, 27'sh0666666, 27'sh04CCCCC, 27'sh0333333, 27'sh0199999, 27'sh0000000, 27'sh7E66667, 27'sh7CCCCCD, 27'sh7B33334, 27'sh799999A}; //double check

genvar z;
generate 
	for (z = 0; z < 10; z=z+1) begin : iterator_instance
		iterator iter 
		(
			// input
			.clk(M10k_pll),
			.rst(iter_rst),
			.ci_init(cur_ci[z]),
			.cr_init(cur_cr[z]),
			.max_iterations(max_iterations),
			.range(32'd30720),
			.handshake(handshake[z]),
			.cr_incr(cr_incr),
			.ci_incr(ci_incr),
			.cr_stop(cr_stop),
			.cr_reset(cr_reset),
			// output
			.iterations(iterations[z]),
			.done(done[z]),
			.all_done(all_done[z])
		);
	end
endgenerate



/*
iterator iter1 
(
	// input
	.clk(M10k_pll),
	.rst(~KEY[0]),
	.ci_init(27'sh0800000),
	.cr_init(27'sh7000000),
	.max_iterations(max_iterations),
	.range(32'd153600),
	.handshake(handshake1),
	// output
	.iterations(iterations1),
	.done(done),
	.all_done(all_done)
);

// Instantiate Iterator
wire done2, all_done2;
reg handshake2;
wire [31:0] iterations2;
iterator iter2 
(
	// input
	.clk(M10k_pll),
	.rst(~KEY[0]),
	.ci_init(27'sh0),
	.cr_init(27'sh7000000),
	.max_iterations(max_iterations),
	.range(32'd153600),
	.handshake(handshake2),
	// output
	.iterations(iterations2),
	.done(done2),
	.all_done(all_done2)
);
*/

//=======================================================
//  Structural coding
//=======================================================
// From Qsys

Computer_System The_System (
	////////////////////////////////////
	// FPGA Side
	////////////////////////////////////
	.vga_pio_locked_export			(vga_pll_lock),           //       vga_pio_locked.export
	.vga_pio_outclk0_clk				(vga_pll),              //      vga_pio_outclk0.clk
	.m10k_pll_locked_export			(M10k_pll_locked),          //      m10k_pll_locked.export
	.m10k_pll_outclk0_clk			(M10k_pll),            //     m10k_pll_outclk0.clk

	//HPS init conditions
	.pio_init_ci_external_connection_export(init_ci_global),
	.pio_init_cr_external_connection_export(init_cr_global),
	.pio_init_zoom_external_connection_export(zoom),
	
	
	// Global signals
	.system_pll_ref_clk_clk					(CLOCK_50),
	.system_pll_ref_reset_reset			(1'b0),
	

	////////////////////////////////////
	// HPS Side
	////////////////////////////////////
	// DDR3 SDRAM
	.memory_mem_a			(HPS_DDR3_ADDR),
	.memory_mem_ba			(HPS_DDR3_BA),
	.memory_mem_ck			(HPS_DDR3_CK_P),
	.memory_mem_ck_n		(HPS_DDR3_CK_N),
	.memory_mem_cke		(HPS_DDR3_CKE),
	.memory_mem_cs_n		(HPS_DDR3_CS_N),
	.memory_mem_ras_n		(HPS_DDR3_RAS_N),
	.memory_mem_cas_n		(HPS_DDR3_CAS_N),
	.memory_mem_we_n		(HPS_DDR3_WE_N),
	.memory_mem_reset_n	(HPS_DDR3_RESET_N),
	.memory_mem_dq			(HPS_DDR3_DQ),
	.memory_mem_dqs		(HPS_DDR3_DQS_P),
	.memory_mem_dqs_n		(HPS_DDR3_DQS_N),
	.memory_mem_odt		(HPS_DDR3_ODT),
	.memory_mem_dm			(HPS_DDR3_DM),
	.memory_oct_rzqin		(HPS_DDR3_RZQ),
		  
	// Ethernet
	.hps_io_hps_io_gpio_inst_GPIO35	(HPS_ENET_INT_N),
	.hps_io_hps_io_emac1_inst_TX_CLK	(HPS_ENET_GTX_CLK),
	.hps_io_hps_io_emac1_inst_TXD0	(HPS_ENET_TX_DATA[0]),
	.hps_io_hps_io_emac1_inst_TXD1	(HPS_ENET_TX_DATA[1]),
	.hps_io_hps_io_emac1_inst_TXD2	(HPS_ENET_TX_DATA[2]),
	.hps_io_hps_io_emac1_inst_TXD3	(HPS_ENET_TX_DATA[3]),
	.hps_io_hps_io_emac1_inst_RXD0	(HPS_ENET_RX_DATA[0]),
	.hps_io_hps_io_emac1_inst_MDIO	(HPS_ENET_MDIO),
	.hps_io_hps_io_emac1_inst_MDC		(HPS_ENET_MDC),
	.hps_io_hps_io_emac1_inst_RX_CTL	(HPS_ENET_RX_DV),
	.hps_io_hps_io_emac1_inst_TX_CTL	(HPS_ENET_TX_EN),
	.hps_io_hps_io_emac1_inst_RX_CLK	(HPS_ENET_RX_CLK),
	.hps_io_hps_io_emac1_inst_RXD1	(HPS_ENET_RX_DATA[1]),
	.hps_io_hps_io_emac1_inst_RXD2	(HPS_ENET_RX_DATA[2]),
	.hps_io_hps_io_emac1_inst_RXD3	(HPS_ENET_RX_DATA[3]),

	// Flash
	.hps_io_hps_io_qspi_inst_IO0	(HPS_FLASH_DATA[0]),
	.hps_io_hps_io_qspi_inst_IO1	(HPS_FLASH_DATA[1]),
	.hps_io_hps_io_qspi_inst_IO2	(HPS_FLASH_DATA[2]),
	.hps_io_hps_io_qspi_inst_IO3	(HPS_FLASH_DATA[3]),
	.hps_io_hps_io_qspi_inst_SS0	(HPS_FLASH_NCSO),
	.hps_io_hps_io_qspi_inst_CLK	(HPS_FLASH_DCLK),

	// Accelerometer
	.hps_io_hps_io_gpio_inst_GPIO61	(HPS_GSENSOR_INT),

	//.adc_sclk                        (ADC_SCLK),
	//.adc_cs_n                        (ADC_CS_N),
	//.adc_dout                        (ADC_DOUT),
	//.adc_din                         (ADC_DIN),

	// General Purpose I/O
	.hps_io_hps_io_gpio_inst_GPIO40	(HPS_GPIO[0]),
	.hps_io_hps_io_gpio_inst_GPIO41	(HPS_GPIO[1]),

	// I2C
	.hps_io_hps_io_gpio_inst_GPIO48	(HPS_I2C_CONTROL),
	.hps_io_hps_io_i2c0_inst_SDA		(HPS_I2C1_SDAT),
	.hps_io_hps_io_i2c0_inst_SCL		(HPS_I2C1_SCLK),
	.hps_io_hps_io_i2c1_inst_SDA		(HPS_I2C2_SDAT),
	.hps_io_hps_io_i2c1_inst_SCL		(HPS_I2C2_SCLK),

	// Pushbutton
	.hps_io_hps_io_gpio_inst_GPIO54	(HPS_KEY),

	// LED
	.hps_io_hps_io_gpio_inst_GPIO53	(HPS_LED),

	// SD Card
	.hps_io_hps_io_sdio_inst_CMD	(HPS_SD_CMD),
	.hps_io_hps_io_sdio_inst_D0	(HPS_SD_DATA[0]),
	.hps_io_hps_io_sdio_inst_D1	(HPS_SD_DATA[1]),
	.hps_io_hps_io_sdio_inst_CLK	(HPS_SD_CLK),
	.hps_io_hps_io_sdio_inst_D2	(HPS_SD_DATA[2]),
	.hps_io_hps_io_sdio_inst_D3	(HPS_SD_DATA[3]),

	// SPI
	.hps_io_hps_io_spim1_inst_CLK		(HPS_SPIM_CLK),
	.hps_io_hps_io_spim1_inst_MOSI	(HPS_SPIM_MOSI),
	.hps_io_hps_io_spim1_inst_MISO	(HPS_SPIM_MISO),
	.hps_io_hps_io_spim1_inst_SS0		(HPS_SPIM_SS),

	// UART
	.hps_io_hps_io_uart0_inst_RX	(HPS_UART_RX),
	.hps_io_hps_io_uart0_inst_TX	(HPS_UART_TX),

	// USB
	.hps_io_hps_io_gpio_inst_GPIO09	(HPS_CONV_USB_N),
	.hps_io_hps_io_usb1_inst_D0		(HPS_USB_DATA[0]),
	.hps_io_hps_io_usb1_inst_D1		(HPS_USB_DATA[1]),
	.hps_io_hps_io_usb1_inst_D2		(HPS_USB_DATA[2]),
	.hps_io_hps_io_usb1_inst_D3		(HPS_USB_DATA[3]),
	.hps_io_hps_io_usb1_inst_D4		(HPS_USB_DATA[4]),
	.hps_io_hps_io_usb1_inst_D5		(HPS_USB_DATA[5]),
	.hps_io_hps_io_usb1_inst_D6		(HPS_USB_DATA[6]),
	.hps_io_hps_io_usb1_inst_D7		(HPS_USB_DATA[7]),
	.hps_io_hps_io_usb1_inst_CLK		(HPS_USB_CLKOUT),
	.hps_io_hps_io_usb1_inst_STP		(HPS_USB_STP),
	.hps_io_hps_io_usb1_inst_DIR		(HPS_USB_DIR),
	.hps_io_hps_io_usb1_inst_NXT		(HPS_USB_NXT)
);
endmodule // end top level



// Declaration of module, include width and signedness of each input/output
module vga_driver (
	input wire clock,
	input wire reset,
	input [7:0] color_in,
	// input [9:0] switch_values [0:9], //staring y value for each memblock
	output [9:0] next_x,
	output [9:0] next_y,
	output wire hsync,
	output wire vsync,
	output [7:0] red,
	output [7:0] green,
	output [7:0] blue,
	output sync,
	output clk,
	output blank
	// output [9:0] which_memblock //new 
	
);
	
	// Horizontal parameters (measured in clock cycles)
	parameter [9:0] H_ACTIVE  	=  10'd_639 ;
	parameter [9:0] H_FRONT 	=  10'd_15 ;
	parameter [9:0] H_PULSE		=  10'd_95 ;
	parameter [9:0] H_BACK 		=  10'd_47 ;

	// Vertical parameters (measured in lines)
	parameter [9:0] V_ACTIVE  	=  10'd_479 ;
	parameter [9:0] V_FRONT 	=  10'd_9 ;
	parameter [9:0] V_PULSE		=  10'd_1 ;
	parameter [9:0] V_BACK 		=  10'd_32 ;

//	// Horizontal parameters (measured in clock cycles)
//	parameter [9:0] H_ACTIVE  	=  10'd_9 ;
//	parameter [9:0] H_FRONT 	=  10'd_4 ;
//	parameter [9:0] H_PULSE		=  10'd_4 ;
//	parameter [9:0] H_BACK 		=  10'd_4 ;
//	parameter [9:0] H_TOTAL 	=  10'd_799 ;
//
//	// Vertical parameters (measured in lines)
//	parameter [9:0] V_ACTIVE  	=  10'd_1 ;
//	parameter [9:0] V_FRONT 	=  10'd_1 ;
//	parameter [9:0] V_PULSE		=  10'd_1 ;
//	parameter [9:0] V_BACK 		=  10'd_1 ;

	// Parameters for readability
	parameter 	LOW 	= 1'b_0 ;
	parameter 	HIGH	= 1'b_1 ;

	// States (more readable)
	parameter 	[7:0]	H_ACTIVE_STATE 		= 8'd_0 ;
	parameter 	[7:0] 	H_FRONT_STATE		= 8'd_1 ;
	parameter 	[7:0] 	H_PULSE_STATE 		= 8'd_2 ;
	parameter 	[7:0] 	H_BACK_STATE 		= 8'd_3 ;

	parameter 	[7:0]	V_ACTIVE_STATE 		= 8'd_0 ;
	parameter 	[7:0] 	V_FRONT_STATE		= 8'd_1 ;
	parameter 	[7:0] 	V_PULSE_STATE 		= 8'd_2 ;
	parameter 	[7:0] 	V_BACK_STATE 		= 8'd_3 ;

	// Clocked registers
	reg 		hysnc_reg ;
	reg 		vsync_reg ;
	reg 	[7:0]	red_reg ;
	reg 	[7:0]	green_reg ;
	reg 	[7:0]	blue_reg ;
	reg 		line_done ;

	// Control registers
	reg 	[9:0] 	h_counter ;
	reg 	[9:0] 	v_counter ;

	reg 	[7:0]	h_state ;
	reg 	[7:0]	v_state ;

	// reg     [9:0]   which_memblock_reg; //new
	// reg     [9:0]   switch_values_reg[0:9]; //new

	// State machine
	always@(posedge clock) begin
		// At reset . . .
  		if (reset) begin
			// Zero the counters
			h_counter 	<= 10'd_0 ;
			v_counter 	<= 10'd_0 ;
			// States to ACTIVE
			h_state 	<= H_ACTIVE_STATE  ;
			v_state 	<= V_ACTIVE_STATE  ;
			// Deassert line done
			line_done 	<= LOW ;
  		end
  		else begin
			
			//////////////////////////////////////////////////////////////////////////
			///////////////////////// HORIZONTAL /////////////////////////////////////
			//////////////////////////////////////////////////////////////////////////
			if (h_state == H_ACTIVE_STATE) begin
				// Iterate horizontal counter, zero at end of ACTIVE mode
				h_counter <= (h_counter==H_ACTIVE)?10'd_0:(h_counter + 10'd_1) ;
				// Set hsync
				hysnc_reg <= HIGH ;
				// Deassert line done
				line_done <= LOW ;
				// State transition
				h_state <= (h_counter == H_ACTIVE)?H_FRONT_STATE:H_ACTIVE_STATE ;
			end
			// Assert done flag, wait here for reset
			if (h_state == H_FRONT_STATE) begin
				// Iterate horizontal counter, zero at end of H_FRONT mode
				h_counter <= (h_counter==H_FRONT)?10'd_0:(h_counter + 10'd_1) ;
				// Set hsync
				hysnc_reg <= HIGH ;
				// State transition
				h_state <= (h_counter == H_FRONT)?H_PULSE_STATE:H_FRONT_STATE ;
			end
			if (h_state == H_PULSE_STATE) begin
				// Iterate horizontal counter, zero at end of H_FRONT mode
				h_counter <= (h_counter==H_PULSE)?10'd_0:(h_counter + 10'd_1) ;
				// Set hsync
				hysnc_reg <= LOW ;
				// State transition
				h_state <= (h_counter == H_PULSE)?H_BACK_STATE:H_PULSE_STATE ;
			end
			if (h_state == H_BACK_STATE) begin
				// Iterate horizontal counter, zero at end of H_FRONT mode
				h_counter <= (h_counter==H_BACK)?10'd_0:(h_counter + 10'd_1) ;
				// Set hsync
				hysnc_reg <= HIGH ;
				// State transition
				h_state <= (h_counter == H_BACK)?H_ACTIVE_STATE:H_BACK_STATE ;
				// Signal line complete at state transition (offset by 1 for synchronous state transition)
				line_done <= (h_counter == (H_BACK-1))?HIGH:LOW ;
			end
			//////////////////////////////////////////////////////////////////////////
			///////////////////////// VERTICAL ///////////////////////////////////////
			//////////////////////////////////////////////////////////////////////////
			if (v_state == V_ACTIVE_STATE) begin
				// increment vertical counter at end of line, zero on state transition
				v_counter <= (line_done==HIGH)?((v_counter==V_ACTIVE)?10'd_0:(v_counter + 10'd_1)):v_counter ;
				// set vsync in active mode
				vsync_reg <= HIGH ;
				// state transition - only on end of lines
				v_state <= (line_done==HIGH)?((v_counter==V_ACTIVE)?V_FRONT_STATE:V_ACTIVE_STATE):V_ACTIVE_STATE ;
			end
			if (v_state == V_FRONT_STATE) begin
				// increment vertical counter at end of line, zero on state transition
				v_counter <= (line_done==HIGH)?((v_counter==V_FRONT)?10'd_0:(v_counter + 10'd_1)):v_counter ;
				// set vsync in front porch
				vsync_reg <= HIGH ;
				// state transition
				v_state <= (line_done==HIGH)?((v_counter==V_FRONT)?V_PULSE_STATE:V_FRONT_STATE):V_FRONT_STATE ;
			end
			if (v_state == V_PULSE_STATE) begin
				// increment vertical counter at end of line, zero on state transition
				v_counter <= (line_done==HIGH)?((v_counter==V_PULSE)?10'd_0:(v_counter + 10'd_1)):v_counter ;
				// clear vsync in pulse
				vsync_reg <= LOW ;
				// state transition
				v_state <= (line_done==HIGH)?((v_counter==V_PULSE)?V_BACK_STATE:V_PULSE_STATE):V_PULSE_STATE ;
			end
			if (v_state == V_BACK_STATE) begin
				// increment vertical counter at end of line, zero on state transition
				v_counter <= (line_done==HIGH)?((v_counter==V_BACK)?10'd_0:(v_counter + 10'd_1)):v_counter ;
				// set vsync in back porch
				vsync_reg <= HIGH ;
				// state transition
				v_state <= (line_done==HIGH)?((v_counter==V_BACK)?V_ACTIVE_STATE:V_BACK_STATE):V_BACK_STATE ;
			end

			//////////////////////////////////////////////////////////////////////////
			//////////////////////////////// COLOR OUT ///////////////////////////////
			//////////////////////////////////////////////////////////////////////////
			red_reg 		<= (h_state==H_ACTIVE_STATE)?((v_state==V_ACTIVE_STATE)?{color_in[7:5],5'd_0}:8'd_0):8'd_0 ;
			green_reg 	<= (h_state==H_ACTIVE_STATE)?((v_state==V_ACTIVE_STATE)?{color_in[4:2],5'd_0}:8'd_0):8'd_0 ;
			blue_reg 	<= (h_state==H_ACTIVE_STATE)?((v_state==V_ACTIVE_STATE)?{color_in[1:0],6'd_0}:8'd_0):8'd_0 ;
			
 	 	end
	end

	// Assign output values
	assign hsync = hysnc_reg ;
	assign vsync = vsync_reg ;
	assign red = red_reg ;
	assign green = green_reg ;
	assign blue = blue_reg ;
	assign clk = clock ;
	assign sync = 1'b_0 ;
	assign blank = hysnc_reg & vsync_reg ;
	// The x/y coordinates that should be available on the NEXT cycle
	assign next_x = (h_state==H_ACTIVE_STATE)?h_counter:10'd_0 ;
	assign next_y = (v_state==V_ACTIVE_STATE)?v_counter:10'd_0 ;
	//assign which_memblock = which_memblock_reg;

endmodule




//============================================================
// M10K module for testing
//============================================================
// See example 12-16 in 
// http://people.ece.cornell.edu/land/courses/ece5760/DE1_SOC/HDL_style_qts_qii51007.pdf
//============================================================

module M10K_1000_8( 
    output reg [7:0] q,
    input [7:0] d,
    input [18:0] write_address, read_address,
    input we, clk
);
	 // force M10K ram style
	 // 307200 words of 8 bits
    reg [7:0] mem [30720:0]  /* synthesis ramstyle = "no_rw_check, M10K" */;
	 
    always @ (posedge clk) begin
        if (we) begin
            mem[write_address] <= d;
		  end
        q <= mem[read_address]; // q doesn't get d in this clock cycle
    end
endmodule