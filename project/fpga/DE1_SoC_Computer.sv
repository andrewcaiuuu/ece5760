

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

// PIO signals
wire [31:0] arm_data; // arm output
wire [31:0] arm_data2; // arm output
wire arm_val; // arm output
wire arm_rdy; // arm output 
wire arm_ack;
wire fpga_ack;
wire [31:0] fpga_data; // arm input
wire fpga_val; // arm input
wire fpga_rdy; // arm input


// M10k memory clock
wire 					M10k_pll ;
wire 					M10k_pll_locked ;

// Instantiate Image memory
wire  [9:0] image_write_address [0:239];
wire  [9:0] image_read_address  [0:239];
wire  image_we                  [0:239];
wire  [19:0] image_readout       [0:239];
wire   [19:0] image_writein       [0:239];
genvar i;
generate
    for (i=0; i<240; i=i+1) begin: imageMemGen
        M10K_1000_18 mem(
            .clk(CLOCK_50),
            .d(image_writein[i]),
            .write_address(image_write_address[i]),
            .read_address(image_read_address[i]),
            .we(image_we[i]),
            .q(image_readout[i])
        );
    end
endgenerate

// Instantiate Weight memory
// wire  [9:0] weight_write_address [0:239];
// wire  [9:0] weight_read_address  [0:239];
// wire  weight_we                  [0:239];
// wire  [7:0] weight_readout       [0:239];
// wire   [7:0] weight_writein       [0:239];
// genvar j;
// generate
//     for (j=0; j<240; j=j+1) begin: weightMemGen
//         M10K_1000_4 mem(
//             .clk(CLOCK_50),
//             .d(weight_writein[j]),
//             .write_address(weight_write_address[j]),
//             .read_address(weight_read_address[j]),
//             .we(weight_we[j]),
//             .q(weight_readout[j])
//         );
//     end
// endgenerate

logic mr_fpga_ack, mr_fpga_val, mr_fpga_rdy;
logic mw_fpga_ack, mw_fpga_val, mw_fpga_rdy;
logic sv_fpga_ack, sv_fpga_val, sv_fpga_rdy;
logic [31:0] mr_fpga_data, mw_fpga_data, sv_fpga_data;


logic sv_reset;
logic [9:0] sv_addr, sv_which;
logic sv_we;
logic [17:0] sv_image_mem_data, sv_image_mem_writeout;
logic [31:0] sv_arm_data;
logic [7:0] sv_debug_count;

solvers svs (
	.clk(CLOCK_50),
	.reset(sv_reset),

	.arm_val(arm_val),
	.arm_ack(arm_ack),
	.arm_data(arm_data),
	.arm_data2(arm_data2),

	.image_mem_data(sv_image_mem_data),

	.fpga_val(sv_fpga_val),
	.fpga_ack(sv_fpga_ack),
	.fpga_data(sv_fpga_data),

	.image_mem_addr(sv_addr),
	.which_mem(sv_which),
	.we(sv_we),
	.image_mem_writeout(sv_image_mem_writeout),
	.debug_count(sv_debug_count)
);


reg mw_reset;
wire mw_done, mw_we;

wire [19:0] mw_d;
wire [9:0] mw_which_mem;
wire [9:0] mw_addr;
wire [31:0] mw_count;
logic [31:0] mw_arm_data;

mem_writer m_w (
	.clk(CLOCK_50),

	.arm_data(arm_data),
	.arm_val(arm_val),
	.arm_ack(arm_ack),
	.reset(mw_reset),

	.fpga_ack(mw_fpga_ack),

	.d(mw_d),
	.addr(mw_addr),
	.we(mw_we),
	.which_mem(mw_which_mem),

	.done(mw_done),
	.count(mw_count)
);

reg mr_reset;
wire mr_done;

wire [19:0] mr_image_data;
wire [9:0] mr_addr;
wire [9:0] mr_which_mem;
wire [31:0] mr_count;
mem_reader m_r (
	.clk(CLOCK_50),

	.arm_ack(arm_ack),
	
	.image_mem_data(mr_image_data),
	.reset(mr_reset),

	.fpga_val(mr_fpga_val),
	.fpga_ack(mr_fpga_ack),
	.fpga_data(mr_fpga_data),

	.addr(mr_addr),
	.which_mem(mr_which_mem),
	.done(mr_done),
	.count(mr_count)
);


// synthesize 240 comparators
genvar k;
generate
	for (k = 0; k < 240; k=k+1) begin : gen_assignments
		assign image_write_address[k] = (state > 6) ? ( (k == sv_which) ? sv_addr : 0 ) : ( (k == mw_which_mem) ? mw_addr : 0);
		assign image_writein[k] = (state > 6) ? ( (k == sv_which) ? sv_image_mem_writeout : 0 ) : ( (k == mw_which_mem) ? mw_d : 0);
		assign image_we[k] = (state > 6) ? ( (k == sv_which) ? sv_we : 0 ) : ( (k == mw_which_mem) ? mw_we : 0 );

		assign image_read_address[k] = (state > 6) ? ( (k == sv_which) ? sv_addr : 0) : ( (k == mr_which_mem) ? mr_addr : 0);
	end
endgenerate

assign mr_image_data = image_readout[mr_which_mem];
assign sv_image_mem_data = image_readout[sv_which];

// assign fpga_rdy = mw_fpga_rdy;
// assign fpga_val = mr_fpga_val;
// assign fpga_data = mr_fpga_data;

// assign fpga_rdy = mr_fpga_rdy;
// assign fpga_val = mr_fpga_val;
// assign fpga_data = mr_fpga_data;

assign LEDR[0] = KEY[0] ? 0 : 1;
assign LEDR[1] = fpga_ack ? 1 : 0;
// assign hex3_hex0 = 16'd2;
assign pio_reset = ~KEY[0];
reg [3:0] state;
assign fpga_rdy =  (state < 5 ) ? ( (state > 6 ) ? sv_fpga_rdy  : mw_fpga_rdy  ): mr_fpga_rdy;
assign fpga_val =  (state < 5 ) ? ( (state > 6 ) ? sv_fpga_val  : mw_fpga_val  ): mr_fpga_val;
assign fpga_data = (state < 5 ) ? ( (state > 6 ) ? sv_fpga_data : mw_fpga_data ): mr_fpga_data;
assign fpga_ack =  (state < 5 ) ? ( (state > 6 ) ? sv_fpga_ack  : mw_fpga_ack  ): mr_fpga_ack;


// assign hex3_hex0 = mr_count;

assign hex3_hex0[3:0] = state;
// assign hex3_hex0[7:4] = mw_count[3:0];
// assign hex3_hex0[11:8] = mr_count[3:0];
assign hex3_hex0[11:4] = sv_debug_count;


// assign sv_arm_data = state > 6 ? arm_data : 0;
// assign mw_arm_data = state <= 6 ? arm_data : 0;

always@(posedge CLOCK_50) begin 
	if (~KEY[0])  begin 
		state <= 0;
	end 
	else if (state == 0) begin 
		sv_reset <= 1;
		mw_reset <= 1;
		mr_reset <= 1;
		state <= 1;
	end 
	else if (state == 1) begin 
		mw_reset <= 0;
		state <= 2;
	end 
	else if (state == 2) begin 
		state <= 2;
		if (mw_done == 1) begin 
			state <= 3;
		end 
	end 
	else if (state == 3) begin //starting the verification
		state <= 4;
	end 
	else if (state == 4) begin 
		mr_reset <= 0;
		state <= 5;
	end 
	else if (state == 5) begin 
		state <= 5;
		if (mr_done == 1) begin
			state <= 6;
		end 
	end 
	else if (state == 6) begin //starting the solvers
		mr_reset <= 1;
		mw_reset <= 1;
		sv_reset <= 0;
		state <= 7;
	end
	else if (state == 7) begin //let solvers work
		state <= 7;
	end 
end 

//=======================================================
//  Structural coding
//=======================================================

Computer_System The_System (
	////////////////////////////////////
	// FPGA Side
	////////////////////////////////////

	// PLL
	.m10k_pll_locked_export			(M10k_pll_locked),          //      m10k_pll_locked.export
	.m10k_pll_outclk0_clk			(M10k_pll),            //     m10k_pll_outclk0.clk

	// PIO
	.arm_data_external_connection_export			(arm_data),
	.arm_data2_external_connection_export			(arm_data2),
	.arm_val_external_connection_export			    (arm_val),
	.arm_rdy_external_connection_export			    (arm_rdy),
	.arm_ack_external_connection_export	            (arm_ack),

	.fpga_data_external_connection_export			(fpga_data),
	.fpga_val_external_connection_export			(fpga_val),
	.fpga_rdy_external_connection_export			(fpga_rdy),
	.pio_reset_external_connection_export			(pio_reset),
	.fpga_ack_external_connection_export	        (fpga_ack),

	// Global signals
	.system_pll_ref_clk_clk					(CLOCK_50),
	.system_pll_ref_reset_reset			(1'b0),

	// AV Config
	.av_config_SCLK							(FPGA_I2C_SCLK),
	.av_config_SDAT							(FPGA_I2C_SDAT),

	// VGA Subsystem
	.vga_pll_ref_clk_clk 					(CLOCK2_50),
	.vga_pll_ref_reset_reset				(1'b0),
	.vga_CLK										(VGA_CLK),
	.vga_BLANK									(VGA_BLANK_N),
	.vga_SYNC									(VGA_SYNC_N),
	.vga_HS										(VGA_HS),
	.vga_VS										(VGA_VS),
	.vga_R										(VGA_R),
	.vga_G										(VGA_G),
	.vga_B										(VGA_B),
	
	// SDRAM
	.sdram_clk_clk								(DRAM_CLK),
   .sdram_addr									(DRAM_ADDR),
	.sdram_ba									(DRAM_BA),
	.sdram_cas_n								(DRAM_CAS_N),
	.sdram_cke									(DRAM_CKE),
	.sdram_cs_n									(DRAM_CS_N),
	.sdram_dq									(DRAM_DQ),
	.sdram_dqm									({DRAM_UDQM,DRAM_LDQM}),
	.sdram_ras_n								(DRAM_RAS_N),
	.sdram_we_n									(DRAM_WE_N),
	
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


endmodule

module M10K_1000_18( 
    output reg [19:0] q,
    input [19:0] d,
    input [9:0] write_address, read_address,
    input we, clk
);
	 // force M10K ram style
	 // 480 words of 18 bits representing 2 rows of 480 pixels, MSB is the second row
    reg [19:0] mem [479:0]  /* synthesis ramstyle = "no_rw_check, M10K" */;
	 
    always @ (posedge clk) begin
        if (we) begin
            mem[write_address] <= d;
		  end
        q <= mem[read_address]; // q doesn't get d in this clock cycle
    end
endmodule

// module M10K_1000_8( 
//     output reg [7:0] q,
//     input [7:0] d,
//     input [9:0] write_address, read_address,
//     input we, clk
// );
// 	 // force M10K ram style
// 	 // 960 words of 8 bits representing 2 rows of 480 pixels
//     reg [7:0] mem [959:0]  /* synthesis ramstyle = "no_rw_check, M10K" */;
	 
//     always @ (posedge clk) begin
//         if (we) begin
//             mem[write_address] <= d;
// 		  end
//         q <= mem[read_address]; // q doesn't get d in this clock cycle
//     end
// endmodule
