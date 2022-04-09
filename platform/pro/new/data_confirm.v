`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/03/01 17:03:35
// Design Name: 
// Module Name: data_confirm
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


module data_confirm(
  input  wire       rst_n,
  input  wire       clk_i,
  input  wire [1:0] con_bit_i,
  input  wire [7:0] uart_rdata_i,
  input  wire       uart_rdone_i,
  input  wire [7:0] i2c_rdata_i,
  input  wire       i2c_rdone_i,
  input  wire [7:0] spi_rdata_i,
  input  wire       spi_rdone_i,
  
  output wire [7:0] div_data_o,
  output wire       div_en_o  
  );
  
  reg  [7:0]  div_data;
  reg         div_en;
  
  assign div_en_o = div_en;
  assign div_data_o = div_data;
  
  always@(posedge clk_i or negedge rst_n)begin
    if(!rst_n)
      div_en <= 1'b0;
    else if(con_bit_i == 2'b00)
      div_en <= uart_rdone_i;
    else if(con_bit_i != 2'b11)
      div_en <= i2c_rdone_i;
    else
      div_en <= spi_rdone_i;    
  end
  
  always@(posedge clk_i or negedge rst_n)begin
    if(!rst_n)
      div_data <= 8'h01;
    else if(con_bit_i == 2'b00)
      div_data <= uart_rdata_i;
   else if(con_bit_i != 2'b11) 
      div_data <= i2c_rdata_i;
    else
      div_data <= spi_rdata_i;
  end
  
endmodule
