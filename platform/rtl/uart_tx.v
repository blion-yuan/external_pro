`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/02/16 11:41:01
// Design Name: 
// Module Name: uart_tx
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


module uart_tx(
	input  wire 		rst_n,
	input  wire 		clk_i,
	input  wire 		tx_en_i,
	input  wire [7:0]	tx_data_i,
	output wire 		uart_tx_o,
	output wire 		tx_done_o
    );
	
	// 1/9600  = 104166.67ns/ 20ns  = 5208
	// 1/19200 = 52083.33ns / 20ns  = 2604
	// 1/38400 = 26041.20ns / 20ns  = 1302
	// 1/57600 = 17361.11ns / 20ns  = 868
	// 1/115200= 8680.55ns  / 20ns  = 434
	
	localparam	BUAD_9600	= 13'd5208 - 13'd1,
				BUAD_19200	= 13'd2604 - 13'd1,
				BUAD_38400	= 13'd1302 - 13'd1,
				BUAD_57600	= 13'd868  - 13'd1,
				BUAD_115200	= 13'd434  - 13'd1;
	
	parameter	BUAD_SET	= 3'd5;
	
	
	reg	 [12:0]	buad_load_num;
	reg	 [12:0]	buad_cnt;
	reg	 		tx_opt;
	reg	 [3:0]	uart_send_bit;
	reg	 [7:0]	uart_send_data;
	reg	 		uart_send_over;
	reg	 		uart_txd;
	
	assign uart_tx_o = uart_txd;
	assign tx_done_o = uart_send_over;
	
	always@(posedge clk_i or negedge rst_n)begin
		if(!rst_n)
			buad_load_num <= BUAD_9600;
		else if(BUAD_SET == 3'd1)
			buad_load_num <= BUAD_9600;
		else if(BUAD_SET == 3'd2)
			buad_load_num <= BUAD_19200;
		else if(BUAD_SET == 3'd3)
			buad_load_num <= BUAD_38400;
		else if(BUAD_SET == 3'd4)
			buad_load_num <= BUAD_57600;
		else
			buad_load_num <= BUAD_115200;
	end
	
	always@(posedge clk_i or negedge rst_n)begin
		if(!rst_n)
			buad_cnt <= buad_load_num;
		else if(buad_cnt == 13'd0)
			buad_cnt <= buad_load_num;
		else if(tx_opt == 1'b1)
			buad_cnt <= buad_cnt - 13'd1;
		else
			buad_cnt <= buad_load_num;
	end
	
	always@(posedge clk_i or negedge rst_n)begin
		if(!rst_n)
			tx_opt <= 1'b0;
		else if(tx_en_i == 1'b1)
			tx_opt <= 1'b1;
		else if((buad_cnt == 13'd0) && (uart_send_bit == 4'd9))
			tx_opt <= 1'b0;
		else
			tx_opt <= tx_opt;
	end
	
	always@(posedge clk_i or negedge rst_n)begin
		if(!rst_n)
			uart_send_bit <= 4'd0;
		else if((uart_send_bit == 4'd9) && (buad_cnt == 13'd0))
			uart_send_bit <= 4'd0;
		else if(buad_cnt == 13'd0)
			uart_send_bit <= uart_send_bit + 4'd1;
		else
			uart_send_bit <= uart_send_bit;
	end
	
	always@(posedge clk_i or negedge rst_n)begin
		if(!rst_n)
			uart_send_data <= 8'h00;
		else if(tx_opt == 1'b1)
			uart_send_data <= uart_send_data;
		else if(tx_en_i == 1'b1)
			uart_send_data <= tx_data_i;
		else
			uart_send_data <= 8'h00;
	end
	
	always@(posedge clk_i or negedge rst_n)begin
		if(!rst_n)
			uart_send_over <= 1'b0;
		else if((uart_send_bit == 4'd9) && (buad_cnt == 13'd0))
			uart_send_over <= 1'b1;
		else
			uart_send_over <= 1'b0;
	end
	
	always@(posedge clk_i or negedge rst_n)begin
		if(!rst_n)
			uart_txd <= 1'b1;
		else if(tx_opt == 1'b0)
			uart_txd <= 1'b1;
		else if(uart_send_bit == 4'd0)
			uart_txd <= 1'b0;
		else if(uart_send_bit == 4'd9)
			uart_txd <= 1'b1;
		else
			uart_txd <= uart_send_data[uart_send_bit - 1];
	end
	
	
endmodule
