`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/03/01 14:49:27
// Design Name: 
// Module Name: master_spi
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


module master_spi(
  input  wire       rst_n,
  input  wire       clk_i,
  input  wire       spi_en_i,
  input  wire [7:0] spi_cmd_i,
  input  wire [7:0] spi_wdaddr_i,
  input  wire [7:0] spi_wdata_i,
  input  wire [6:0] spi_num_i,
  
  input  wire       spi_miso_i,
  output wire       spi_mosi_o,
  output wire       spi_csn_o,
  output wire       spi_clk_o,
  output wire [7:0] spi_rdata_o,
  output wire       spi_rdone_o,
  output wire       spi_sign_over_o
  );
  
  parameter CPOL = 1'b0,  // scl idle level
              CPHA = 1'b1;  // data capture 0:rsing 1:fall
  localparam SYS_CLK = 50_000_000,
             SPI_CLK = 1_000_000,
             CNT_NUM = SYS_CLK / SPI_CLK / 2 - 1;
  localparam STA_IDLE = 5'b00000,
             STA_STAR = 5'b00001,
             STA_CMD  = 5'b00010,
             STA_ADDR = 5'b00100,
             STA_DATA = 5'b01000,
             STA_STOP = 5'b10000;        
  
  reg  [4:0] spi_sta;
  reg  [7:0] div_cnt;
  wire       div_pulse;
  wire       div_judge;
  reg        spi_csn;
  reg        spi_clk;
  reg        spi_mosi;
  reg  [3:0] div_pulse_cnt;
  wire       byte_over;
  wire       byte_judge;
  reg  [6:0] opt_data_num;
  reg  [6:0] byte_cnt;
  reg  [7:0] wr_data;
  reg  [7:0] rx_data;
  reg        spi_miso_s0;
  reg        spi_miso_s1;
  wire       data_over;
  reg  [7:0] spi_rx_data;
  
  assign spi_csn_o = spi_csn;
  assign spi_clk_o = spi_clk;
  assign spi_mosi_o = spi_mosi;
  assign spi_sign_over_o = data_over;
  assign spi_rdata_o = spi_rx_data;
  assign spi_rdone_o = byte_over;
  
  always@(posedge clk_i or negedge rst_n)begin
    if(!rst_n)
      spi_sta <= STA_IDLE;
    else begin
      case(spi_sta)
        STA_IDLE:begin
          if(spi_en_i == 1'b1)
            spi_sta <= STA_STAR;
          else
            spi_sta <= spi_sta;
        end
    
        STA_STAR:begin
          if(div_pulse)
            spi_sta <= STA_CMD;
          else
            spi_sta <= spi_sta;
        end
        
        STA_CMD:begin
          if(byte_over)
            spi_sta <= STA_ADDR;
          else
            spi_sta <= spi_sta;
        end
        
        STA_ADDR:begin
          if(byte_judge && (byte_cnt >= opt_data_num))
            spi_sta <= STA_STOP;
          else if(byte_over)
            spi_sta <= STA_DATA;
          else
            spi_sta <= spi_sta;
        end
    
      STA_DATA:begin
        if(byte_judge && (byte_cnt >= opt_data_num))
          spi_sta <= STA_STOP;
        else
          spi_sta <= spi_sta;
      end
      
      STA_STOP:begin
        if(div_pulse && !div_pulse_cnt[0])
          spi_sta <= STA_IDLE;
        else
          spi_sta <= spi_sta;
      end    
      endcase
    end  
  end
  
  always@(posedge clk_i or negedge rst_n)begin
    if(!rst_n)begin
      spi_miso_s0 <= 1'b1;
      spi_miso_s1 <= 1'b0;
    end
    else begin
      spi_miso_s0 <= spi_miso_i;
      spi_miso_s1 <= spi_miso_s0;
    end
  end
  
  always@(posedge clk_i or negedge rst_n)begin
    if(!rst_n)
      spi_csn <= 1'b1;
    else if(spi_en_i == 1'b1)
      spi_csn <= 1'b0;
    else if(div_pulse && (spi_sta == STA_STOP) && !div_pulse_cnt[0])
      spi_csn <= 1'b1;
    else
      spi_csn <= spi_csn;
  end
  
  always@(posedge clk_i or negedge rst_n)begin
    if(!rst_n)
      div_cnt <= 8'd0;
    else if(spi_csn == 1'b1)
      div_cnt <= 8'b0;
    else if(div_cnt >= CNT_NUM)
      div_cnt <= 8'd0;
    else
      div_cnt <= div_cnt + 8'd1;
  end
  
  assign div_pulse = (div_cnt >= CNT_NUM);
  assign div_judge = (div_cnt == (CNT_NUM - 8'd1));
  assign byte_over = (div_pulse && (div_pulse_cnt == 4'd15));
  assign byte_judge= (div_judge && (div_pulse_cnt == 4'd15));
  assign data_over = (byte_judge && (spi_sta == STA_DATA));
  
  always@(posedge clk_i or negedge rst_n)begin
    if(!rst_n)
      byte_cnt <= 7'd0;
    else if(spi_sta == STA_IDLE)
      byte_cnt <= 7'd0;
    else if(byte_over)
      byte_cnt <= byte_cnt + 7'd1;
    else
      byte_cnt <= byte_cnt; 
  end
  
  always@(posedge clk_i or negedge rst_n)begin
    if(!rst_n)
      opt_data_num <= 7'd0;
    else if(spi_en_i == 1'b1)
      opt_data_num <= spi_num_i + 7'd1;
    else
      opt_data_num <= opt_data_num;
  end
  
  always@(posedge clk_i or negedge rst_n)begin
    if(!rst_n)
      spi_clk <= CPOL;
    else begin
      case(spi_sta)
        STA_IDLE:spi_clk <= CPOL;
        STA_STAR:begin
          if(CPHA && !CPOL && div_pulse)
            spi_clk <= !spi_clk;
          else
            spi_clk <= CPOL;
        end
        STA_CMD,STA_ADDR,STA_DATA:begin
          if(div_pulse)
            spi_clk <= !spi_clk;
          else
            spi_clk <= spi_clk;
        end
        STA_STOP:spi_clk <= CPOL;
        default:spi_clk <= CPOL;
      endcase
    end
  end
  
  always@(posedge clk_i or negedge rst_n)begin
    if(!rst_n)
      div_pulse_cnt <= 4'd0;
    else if((spi_sta != STA_ADDR) && (spi_sta != STA_DATA) && (spi_sta != STA_CMD))
      div_pulse_cnt <= 4'd0;
    else if(div_pulse)
      div_pulse_cnt <= div_pulse_cnt + 4'd1;
    else
      div_pulse_cnt <= div_pulse_cnt;
  end
  
  always@(posedge clk_i or negedge rst_n)begin
    if(!rst_n)
      wr_data <= 8'h00;
    else if(spi_en_i == 1'b1)
      wr_data <= spi_cmd_i;
    else if(byte_over && (spi_sta == STA_CMD))
      wr_data <= spi_wdaddr_i;
    else if(byte_over)
      wr_data <= spi_wdata_i;
    else if(div_pulse && div_pulse_cnt[0])
      wr_data <= {wr_data[6:0],1'b0};
    else
      wr_data <= wr_data;
  end
  
  always@(posedge clk_i or negedge rst_n)begin
    if(!rst_n)
      rx_data <= 8'h00;
    else if(div_pulse && !div_pulse_cnt[0])
      rx_data <= {rx_data[6:0],spi_miso_s1};
    else
      rx_data <= rx_data;
  end
  
  always@(posedge clk_i or negedge rst_n)begin
    if(!rst_n)
      spi_rx_data <= 8'h00;
    else if(byte_judge)
      spi_rx_data <= rx_data;
    else
      spi_rx_data <= spi_rx_data;
  end
  
  always@(posedge clk_i or negedge rst_n)begin
    if(!rst_n)
      spi_mosi <= 1'b0;
    else
      spi_mosi <= wr_data[7];
  end
    
endmodule
