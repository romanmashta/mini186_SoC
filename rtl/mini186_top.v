`timescale 1ns / 1ps
module mini186_top
	(
		input CLK_50,

	    output [3:0] tmds_out_p,
	    output [3:0] tmds_out_n,

		output SDRAM_CLK,
		output SDRAM_CKE,
		output SDRAM_nCAS,
		output SDRAM_nRAS,
		output SDRAM_nCS,
		output SDRAM_nWE,
		output [1:0]SDRAM_BA,
		output [12:0]SDRAM_ADDR,
		inout [15:0]SDRAM_DATA,
		output SDRAM_DQML,
		output SDRAM_DQMH,
		output [7:0]LED,
		input BTN_SOUTH,
		input BTN_WEST,
		output AUDIO_L,
		output AUDIO_R,
		inout PS2CLKA,
		inout PS2CLKB,
		inout PS2DATA,
		inout PS2DATB,
		output SD_nCS,
		output SD_DI,
		output SD_CK,
		input SD_DO
	);

	wire RX_EXT;
	wire TX_EXT;

	wire RX;
	wire TX;

	wire VGA_HSYNC;
	wire VGA_VSYNC;

	wire [5:0]VGA_R;
	wire [5:0]VGA_G;
	wire [5:0]VGA_B;

	assign SDRAM_CKE = 1'b1;
	wire SDR_CLK;
	wire [3:0]GPIO;

   ODDR2 #(
      .DDR_ALIGNMENT("NONE"), // Sets output alignment to "NONE", "C0" or "C1" 
      .INIT(1'b0),    // Sets initial state of the Q output to 1'b0 or 1'b1
      .SRTYPE("SYNC") // Specifies "SYNC" or "ASYNC" set/reset
   ) ODDR2_inst 
	(
      .Q(SDRAM_CLK), // 1-bit DDR output data
      .C0(SDR_CLK),  // 1-bit clock input
      .C1(!SDR_CLK), // 1-bit clock input
      .CE(1'b1), 		// 1-bit clock enable input
      .D0(1'b1), 		// 1-bit data input (associated with C0)
      .D1(1'b0), 		// 1-bit data input (associated with C1)
      .R(1'b0),   	// 1-bit reset input
      .S(1'b0)    	// 1-bit set input
   );

	 wire clk_25_o;
	 wire clk_50_o;
	 wire clk_250_o;
	 wire de;
	 wire pll_locked_o;


	 assign LED = {1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, de, pll_locked_o};
	//assign LED[2] = 1'b0[0];
	//assign LED[3] = TMDS[3];

	system sys_inst
	(
		.CLK_50(CLK_50),
		.VGA_R(VGA_R),
		.VGA_G(VGA_G),
		.VGA_B(VGA_B),
		.VGA_HSYNC(VGA_HSYNC),
		.VGA_VSYNC(VGA_VSYNC),
		.sdr_CLK_out(SDR_CLK),
		.sdr_n_CS_WE_RAS_CAS({SDRAM_nCS, SDRAM_nWE, SDRAM_nRAS, SDRAM_nCAS}),
		.sdr_BA(SDRAM_BA),
		.sdr_ADDR(SDRAM_ADDR),
		.sdr_DATA(SDRAM_DATA),
		.sdr_DQM({SDRAM_DQMH, SDRAM_DQML}),
		//.LED(LED),
		.BTN_RESET(!BTN_SOUTH),
		.BTN_NMI(BTN_WEST),
		.RS232_DCE_RXD(RX),
		.RS232_DCE_TXD(TX),
		.SD_n_CS(SD_nCS),
		.SD_DI(SD_DI),
		.SD_CK(SD_CK),
		.SD_DO(SD_DO),
		.AUD_L(AUDIO_L),
		.AUD_R(AUDIO_R),
	 	.PS2_CLK1(PS2CLKA),
		.PS2_CLK2(PS2CLKB),
		.PS2_DATA1(PS2DATA),
		.PS2_DATA2(PS2DATB),
		.RS232_EXT_RXD(RX_EXT),
		.RS232_EXT_TXD(TX_EXT),
		.RS232_HOST_RXD(),
		.RS232_HOST_TXD(),
		.RS232_HOST_RST(),
		.GPIO(GPIO),

		.clk_50_o(clk_50_o),
		.de(de)
	);

	wire pixel_clock;
	dvid_serdes u_dvid_serdes(
	    .clk50(clk_50_o),
	    .pixel_clock(pixel_clock),
	    .tmds_out_p(tmds_out_p),
	    .tmds_out_n(tmds_out_n),
	    .btns(btns),
		.r({VGA_R, 2'b00}),
		.g({VGA_G, 2'b00}),
		.b({VGA_B, 2'b00}),
		 .hsync_t(VGA_HSYNC),
		 .vsync_t(VGA_VSYNC),
		 .blank_t(!de)
	);	

endmodule
