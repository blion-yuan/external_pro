module fre_top(
	input  wire  		rst_n,
	input  wire  		clk_i,
	input  wire [1:0]	frehz_i,

	output wire	[1:0]	SH_CP,
	output wire [1:0]	ST_CP,
	output wire [1:0]	DS
	);
	
	wire clk_200m;
	wire clk_lock;
	wire [19:0] pro0_hz;
	wire [19:0] pro1_hz;
	
	wire [27:0]pro0_bcd;
	wire [27:0]pro1_bcd;
	
	wire prob0_low_frq;
	wire prob1_low_frq;
	
	pll u_pll(
		.areset(~rst_n),
		.inclk0(clk_i),
		.c0(clk_200m),
		.locked(clk_lock)
	);
	
	
	fre_sure u_fre0(
		.rst_n(rst_n),
		.clk_i(clk_i),
		.fre_hz_i(frehz_i[0]),
		
		.low_fre_sign_o(prob0_low_frq),
		.prob_khz_o(pro0_hz)
	);
	
	Binary_to_BCD u_bin2bcd0(
		.Clk(clk_i),
		.Rst_n(rst_n),
		.Do_Translate(1'b1),
		.Bin(pro0_hz),
		.Bcd(pro0_bcd),
		.Done_Sig()
	);
	HEX_top HEX_top0(
		.Clk(clk_i),
		.Rst_n(rst_n),
		.disp_data(pro0_bcd),//Voltage_BCD 
		.SH_CP(SH_CP[0]),
		.ST_CP(ST_CP[0]),
		.DS(DS[0])
	);
	
	fre_sure u_fre1(
		.rst_n(rst_n),
		.clk_i(clk_i),
		.fre_hz_i(frehz_i[1]),
		
		.low_fre_sign_o(prob1_low_frq),
		.prob_khz_o(pro1_hz)
	);
	
	Binary_to_BCD u_bin2bcd1(
		.Clk(clk_i),
		.Rst_n(rst_n),
		.Do_Translate(1'b1),
		.Bin(pro1_hz),
		.Bcd(pro1_bcd),
		.Done_Sig()
	);
	HEX_top HEX_top1(
		.Clk(clk_i),
		.Rst_n(rst_n),
		.disp_data(pro1_bcd),//Voltage_BCD 
		.SH_CP(SH_CP[1]),
		.ST_CP(ST_CP[1]),
		.DS(DS[1])
	);
	
	
	
	
endmodule
