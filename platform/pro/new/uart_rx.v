`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/02/16 10:25:06
// Design Name: 
// Module Name: uart_rx
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


module uart_rx(
	input  wire 		rst_n,
	input  wire 		clk_i,
	input  wire 		uart_rx_i,
	
	output wire [7:0]	rx_data_o,
	output wire 		rx_done_o,
	output wire 		rx_error_o
    );
	
	// 1/9600  = 104166.67ns/ 20ns /16 = 325
	// 1/19200 = 52083.33ns / 20ns /16 = 162
	// 1/38400 = 26041.20ns / 20ns /16 = 81
	// 1/57600 = 17361.11ns / 20ns /16 = 54
	// 1/115200= 8680.55ns  / 20ns /16 = 27
	
	localparam	BUAD_9600	= 9'd325 - 9'd1,
				BUAD_19200	= 9'd162 - 9'd1,
				BUAD_38400	= 9'd81 - 9'd1,
				BUAD_57600	= 9'd54 - 9'd1,
				BUAD_115200	= 9'd27 - 9'd1;
				
	parameter	BUAD_SET	= 3'd5;
	
	localparam	IDLE	= 2'b00,
				STAR	= 2'b01,
				READ	= 2'b10,
				STOP	= 2'b11;
				
				
	reg 		uart_rx_s0;
	reg 		uart_rx_s1;
	reg 		uart_rx_tmp0;
	reg 		uart_rx_tmp1;
	wire		uart_rx_rsing;
	wire		uart_rx_fall;
	
	reg  [8:0]	buad_load_num;
	reg  [8:0]	buad_cnt;
	reg  		buad_cnt_en;
	wire 		buad_cnt_pluse;
	reg  [7:0]	buad_div_cnt;

	reg			uart_get_over;
	reg			uart_rx_over;
	reg			uart_rx_error;
	reg  [1:0]	uart_state;
	reg  [2:0]	value_cnt;
	reg  [7:0]	uart_get_data;
	reg  [7:0]	uart_rx_data;
	
	assign rx_data_o = uart_rx_data;
	assign rx_done_o = uart_rx_over;
	assign rx_error_o= uart_rx_error;

	always@(posedge clk_i or negedge rst_n)begin
		if(!rst_n)begin
			uart_rx_s0 <= 1'b1;
			uart_rx_s1 <= 1'b1;
		end
		else begin
			uart_rx_s0 <= uart_rx_i;
			uart_rx_s1 <= uart_rx_s0;
		end
	end
	
	always@(posedge clk_i or negedge rst_n)begin
		if(!rst_n)begin
			uart_rx_tmp0 <= 1'b1;
			uart_rx_tmp1 <= 1'b1;
		end
		else begin
			uart_rx_tmp0 <= uart_rx_s1;
			uart_rx_tmp1 <= uart_rx_tmp0;
		end	
	end
	
	assign uart_rx_rsing = uart_rx_tmp0 & !uart_rx_tmp1;
	assign uart_rx_fall  = !uart_rx_tmp0 & uart_rx_tmp1;
	
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
			buad_cnt_en <= 1'b0;
		else if(uart_get_over == 1'b1)
			buad_cnt_en <= 1'b0;
		else if(uart_rx_error == 1'b1)
			buad_cnt_en <= 1'b0;
		else if(uart_rx_fall == 1'b1)
			buad_cnt_en <= 1'b1;
		else
			buad_cnt_en <= buad_cnt_en;
	end
	
	always@(posedge clk_i or negedge rst_n)begin
		if(!rst_n)
			buad_cnt <= buad_load_num;
		else if(buad_cnt == 9'd0)
			buad_cnt <= buad_load_num;
		else if(buad_cnt_en == 1'b1)
			buad_cnt <= buad_cnt - 9'd1;
		else
			buad_cnt <= buad_load_num;
	end
	
	assign buad_cnt_pluse = (buad_cnt == 9'd0)?1'b1:1'b0;
	
	always@(posedge clk_i or negedge rst_n)begin
		if(!rst_n)
			buad_div_cnt <= 8'd159;
		else if(uart_state == IDLE)
			buad_div_cnt <= 8'd159;
		else if(buad_cnt_pluse == 1'b1)
			buad_div_cnt <= buad_div_cnt - 8'd1;
		else
			buad_div_cnt <= buad_div_cnt;	
	end
	
	always@(posedge clk_i or negedge rst_n)begin
		if(!rst_n)
			uart_get_over <= 1'b0;
		else if(uart_state != IDLE)
			uart_get_over <= 1'b0;
		else if(buad_div_cnt == 8'd0)
			uart_get_over <= 1'b1;
		else
			uart_get_over <= 1'b0;
	end
	
	always@(posedge clk_i or negedge rst_n)begin
		if(!rst_n)begin
			uart_rx_error <= 1'b0;
			uart_state <= IDLE;
		end
		else begin
			case(uart_state)
				IDLE:begin
					if(uart_rx_fall == 1'b1)
						uart_state <= STAR;
					else begin
						uart_state <= IDLE;
						uart_rx_error <= 1'b0;
					end
				end
				
				STAR:begin
					if((uart_rx_rsing && (buad_div_cnt > 8'd149)))begin
						uart_state <= IDLE;
						uart_rx_error <= 1'b1;
					end
					else if(buad_div_cnt == 8'd143)
						uart_state <= READ;
					else
						uart_state <= STAR;
				end
				
				READ:begin
					if(buad_div_cnt == 8'd15)
						uart_state <= STOP;
					else begin
						case(buad_div_cnt)
							129,113,97,81,65,49,33,17:begin
								if(value_cnt == 3'd3)begin
									uart_state <= IDLE;
									uart_rx_error <= 1'b1;
								end
								else
									uart_state <= READ;
							end
							default: uart_state <= READ;
						endcase
					end
				end
				
				STOP:begin
					if(buad_div_cnt == 8'd0)
						uart_state <= IDLE;
					else
						uart_state <= STOP;
				end			
			endcase
		end
	end
	
	
	always@(posedge clk_i or negedge rst_n)begin
		if(!rst_n)
			value_cnt <= 3'd0;
		else if(uart_state != READ)
			value_cnt <= 3'd0;
		else if(buad_cnt_pluse == 1'b0)
			value_cnt <= value_cnt;
		else begin
			case(buad_div_cnt)
				138,137,136,135,134,133:begin
					value_cnt <= value_cnt + uart_rx_s1;
				end
				
				122,121,120,119,118,117:begin
					value_cnt <= value_cnt + uart_rx_s1;
				end
				
				106,105,104,103,102,101:begin
					value_cnt <= value_cnt + uart_rx_s1;
				end
				
				90,89,88,87,86,85:begin
					value_cnt <= value_cnt + uart_rx_s1;
				end
				
				74,73,72,71,70,69:begin
					value_cnt <= value_cnt + uart_rx_s1;
				end
				
				58,57,56,55,54,53:begin
					value_cnt <= value_cnt + uart_rx_s1;
				end
				
				42,41,40,39,38,37:begin
					value_cnt <= value_cnt + uart_rx_s1;
				end
				
				26,25,24,23,22,21:begin
					value_cnt <= value_cnt + uart_rx_s1;
				end
				
				159,126,110,94,78,62,46,30:begin
					value_cnt <= 3'd0;
				end
				default:value_cnt <= value_cnt;
			endcase
		end
	end
	
	always@(posedge clk_i or negedge rst_n)begin
		if(!rst_n)
			uart_get_data <= 8'h00;
		else if(uart_state == STAR)
			uart_get_data <= 8'h00;
		else if(buad_cnt_pluse == 1'b0)
			uart_get_data <= uart_get_data;
		else begin
			case(buad_div_cnt)
				128: uart_get_data[0] <= value_cnt[2];
				112: uart_get_data[1] <= value_cnt[2];
				96 : uart_get_data[2] <= value_cnt[2];
				80 : uart_get_data[3] <= value_cnt[2];
				64 : uart_get_data[4] <= value_cnt[2];
				48 : uart_get_data[5] <= value_cnt[2];
				32 : uart_get_data[6] <= value_cnt[2];
				16 : uart_get_data[7] <= value_cnt[2];
				default:uart_get_data<= uart_get_data;
			endcase
		end
	end
	
	always@(posedge clk_i or negedge rst_n)begin
		if(!rst_n)
			uart_rx_data <= 8'h00;
		else
			uart_rx_data <= uart_get_data;
	end
	
	always@(posedge clk_i or negedge rst_n)begin
		if(!rst_n)
			uart_rx_over <= 1'b0;
		else
			uart_rx_over <= uart_get_over;
	end
	
endmodule

	