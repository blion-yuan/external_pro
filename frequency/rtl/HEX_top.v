module HEX_top(
	Clk,
	Rst_n,
	disp_data,
	SH_CP,
	ST_CP,
	DS
);

	input Clk;	//50M
	input Rst_n;
	
	output SH_CP;	//shift clock
	output ST_CP;	//latch data clock
	output DS;	//shift serial data
	
	input [31:0]disp_data;
	wire [7:0] sel;//数码管位选（选择当前要显示的数码管）
	wire [6:0] seg;//数码管段选（当前要显示的内容）	


	wire  [31:0] disp_data;
	
	HEX8 HEX8(
		.Clk(Clk),
		.Rst_n(Rst_n),
		.En(1'b1),
		.disp_data(disp_data),
		.sel(sel),
		.seg(seg)
	);
	
	
	HC595_Driver HC595_Driver(
		.Clk(Clk),
		.Rst_n(Rst_n),
		.Data({1'b1,seg,sel}),
		.S_EN(1'b1),
		.SH_CP(SH_CP),
		.ST_CP(ST_CP),
		.DS(DS)
	);
	
endmodule
