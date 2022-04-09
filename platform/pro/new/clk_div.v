`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/02/16 11:21:14
// Design Name: 
// Module Name: clk_div
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module clk_div(
	input  wire 		rst_n,
	input  wire 		clk_i,
	input  wire [7:0]	div_data_i,
	input  wire 		div_en_i,
	output wire 		div_clk_o
    );
	
	reg  [7:0]	div_num;
	reg	 [7:0]	div_cnt;
	
	reg [7:0]	ch_num;
	reg 		p_clk;
	reg 		n_clk;
	wire		div_clk;
	
	assign div_clk_o = (div_num <= 8'd1)?clk_i:div_clk;
	
	always@(posedge clk_i or negedge rst_n)begin
		if(!rst_n)
			div_num <= 8'd1;
		else if(div_en_i == 1'b1)
			div_num <= div_data_i;
		else
			div_num <= div_num;
	end
	
	always@(posedge clk_i or negedge rst_n)begin
		if(!rst_n)
			div_cnt <= div_num - 8'd1;
		else if(div_cnt == 8'd0)
			div_cnt <= div_num - 8'd1;
		else
			div_cnt <= div_cnt - 8'd1;
	end
	
	always@(posedge clk_i or negedge rst_n)begin
		if(!rst_n)
			ch_num <= 8'd0;
		else
			ch_num <= (div_num + 1) >> 1;
	end 
	
	always@(posedge clk_i or negedge rst_n)begin
		if(!rst_n)
			p_clk <= 1'b1;
		else if(div_cnt >= ch_num)
			p_clk <= 1'b1;
		else
			p_clk <= 1'b0; 
	end
	
	always@(negedge clk_i or negedge rst_n)begin
		if(!rst_n)
			n_clk <= 1'b1;
		else
			n_clk <= p_clk;
	end
	
	assign div_clk = (div_num[0] == 1'b0)?p_clk :(p_clk | n_clk);

endmodule
