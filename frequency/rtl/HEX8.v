module HEX8(Clk,Rst_n,En,disp_data,sel,seg);

	input Clk;	//50M
	input Rst_n;
	input En;	//数码管显示使能，1使能，0关闭
	
	input [31:0]disp_data;
	
	output [7:0] sel;//数码管位选（选择当前要显示的数码管）
	output reg [6:0] seg;//数码管段选（当前要显示的内容）
	
	reg [14:0]divider_cnt;//25000-1
	
	reg clk_1K;
	reg [7:0]sel_r;
	
	reg [3:0]data_tmp;//数据缓存

//	分频计数器计数模块
	always@(posedge Clk or negedge Rst_n)
	if(!Rst_n)
		divider_cnt <= 15'd0;
	else if(!En)
		divider_cnt <= 15'd0;
	else if(divider_cnt == 24999)
		divider_cnt <= 15'd0;
	else
		divider_cnt <= divider_cnt + 1'b1;

//1K扫描时钟生成模块		
	always@(posedge Clk or negedge Rst_n)
	if(!Rst_n)
		clk_1K <= 1'b0;
	else if(divider_cnt == 24999)
		clk_1K <= ~clk_1K;
	else
		clk_1K <= clk_1K;
		
//8位循环移位寄存器
	always@(posedge clk_1K or negedge Rst_n)
	if(!Rst_n)
		sel_r <= 8'b0000_0001;
	else if(sel_r == 8'b1000_0000)
		sel_r <= 8'b0000_0001;
	else
		sel_r <=  sel_r << 1;
		
	always@(*)
		case(sel_r)
			8'b0000_0001:data_tmp = disp_data[3:0];
			8'b0000_0010:data_tmp = disp_data[7:4];
			8'b0000_0100:data_tmp = disp_data[11:8];
			8'b0000_1000:data_tmp = disp_data[15:12];
			8'b0001_0000:data_tmp = disp_data[19:16];
			8'b0010_0000:data_tmp = disp_data[23:20];
			8'b0100_0000:data_tmp = disp_data[27:24];
			8'b1000_0000:data_tmp = disp_data[31:28];
			default:data_tmp = 4'b0000;
		endcase
		
	always@(*)
		case(data_tmp)
			4'h0:seg = 7'b1000000;	/*0*/
			4'h1:seg = 7'b1111001;	/*1*/
			4'h2:seg = 7'b0100100;	/*2*/
			4'h3:seg = 7'b0110000;	/*3*/
			4'h4:seg = 7'b0011001;	/*4*/
			4'h5:seg = 7'b0010010;	/*5*/
			4'h6:seg = 7'b0000010;	/*6*/
			4'h7:seg = 7'b1111000;	/*7*/
			4'h8:seg = 7'b0000000;	/*8*/
			4'h9:seg = 7'b0010000;	/*9*/
			4'ha:seg = 7'b0001000;	/*a*/
			4'hb:seg = 7'b0000011;	/*b*/
			4'hc:seg = 7'b1000110;	/*C*/
			4'hd:seg = 7'b0001001;	/*H*/
			4'he:seg = 7'b1111111;	/*不显示*/
			4'hf:seg = 7'b0001110;	/*f*/
		endcase
		
	assign sel = (En)?sel_r:8'b0000_0000;

endmodule
