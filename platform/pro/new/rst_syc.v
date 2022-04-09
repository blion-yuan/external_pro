`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/02/16 10:14:48
// Design Name: 
// Module Name: rst_syc
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


module rst_syc(
	input  wire 	rst_n,
	input  wire 	clk_i,
	output wire 	rst_syc_o
    );
	
	reg 	rst_1;
	reg 	rst_2;
	
	assign rst_syc_o = rst_2;
	
	
	always@(posedge clk_i or negedge rst_n)begin
		if(!rst_n)begin
			rst_1 <= 1'b0;
			rst_2 <= 1'b0;
		end
		else begin
			rst_1 <= 1'b1;
			rst_2 <= rst_1;
		end
	end
	
endmodule
