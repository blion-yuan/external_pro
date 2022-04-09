`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/03/01 16:08:46
// Design Name: 
// Module Name: slave_spi
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


module slave_spi(
  input  wire       rst_n,
  input  wire       clk_i,
  input  wire       spi_csn_i,
  input  wire       spi_clk_i,
  input  wire       spi_mosi_i,
  output wire       spi_miso_o,
  output wire [7:0] spi_rdata_o,
  output wire       spi_rdone_o
  );
  
  parameter CPOL = 1'b0,  // scl idle level
              CPHA = 1'b1;  // data capture 0:rsing 1:fall
  localparam  STA_IDLE = 3'b000,
              STA_GCMD = 3'b001,
              STA_ADDR = 3'b010,
              STA_GDATA= 3'b011,
              STA_ODATA= 3'b100,
              STA_ERROR= 3'b101;
   localparam SPI_CMD_WR = 8'h80,
              SPI_CMD_RD = 8'h08,
              SPI_CMD_CLR= 8'h55;
   localparam CMD_IDLE = 2'b00,
              CMD_WRDA = 2'b01,
              CMD_RDDA = 2'b10,
              CMD_CLRC = 2'b11;
              
  reg       spi_csn_s0;
  reg       spi_csn_s1;
  reg       spi_csn_tmp0;
  reg       spi_csn_tmp1;
  wire      spi_csn_rsing;
  wire      spi_csn_fall;
  
  reg       spi_clk_s0; 
  reg       spi_clk_s1;
  reg       spi_clk_tmp0;
  reg       spi_clk_tmp1;
  wire      spi_clk_rsing;
  wire      spi_clk_fall;
  
  reg       spi_mosi_s0;
  reg       spi_mosi_s1;
  
  wire      star_sign;
  wire      stop_sign;
  
  reg  [7:0] spi_rx_data;
  reg  [2:0] slave_spi_sta;
  reg  [2:0] bit_cnt;
  wire       bit7_pulse;
  wire       bit_clr;
  reg        bit_pulse;
  reg        bit_pulse_s0;
  reg  [1:0] get_cmd;
  reg  [7:0] get_addr;
  reg  [7:0] memory[0:255];
  reg  [6:0] addr_offset;
  wire [7:0] opt_addr;
  wire       spi_miso;
  reg  [7:0] spi_tx_data;
  integer    i;
  reg  [7:0] rx_data;
  reg        rx_done;
    
  assign spi_miso_o = spi_miso;
  assign spi_rdata_o = rx_data;
  assign spi_rdone_o = stop_sign;
    
  always@(posedge clk_i or negedge rst_n)begin
    if(!rst_n)begin
      spi_csn_s0 <= 1'b1;
      spi_csn_s1 <= 1'b1;
      spi_csn_tmp0 <= 1'b1;
      spi_csn_tmp1 <= 1'b1;
    end
    else begin
      spi_csn_s0 <= spi_csn_i;
      spi_csn_s1 <= spi_csn_s0;
      spi_csn_tmp0 <= spi_csn_s1;
      spi_csn_tmp1 <= spi_csn_tmp0;
    end      
  end     
  
  assign spi_csn_rsing = spi_csn_tmp0 & !spi_csn_tmp1;
  assign spi_csn_fall  = !spi_csn_tmp0 & spi_csn_tmp1;
  
  assign star_sign = spi_csn_fall;
  assign stop_sign = spi_csn_rsing;
  
  always@(posedge clk_i or negedge rst_n)begin
    if(!rst_n)begin
      spi_clk_s0 <= 1'b1;
      spi_clk_s1 <= 1'b1;
      spi_clk_tmp0 <= 1'b1;
      spi_clk_tmp1 <= 1'b1;
    end
    else begin
      spi_clk_s0 <= spi_clk_i;
      spi_clk_s1 <= spi_clk_s0;
      spi_clk_tmp0 <= spi_clk_s1;
      spi_clk_tmp1 <= spi_clk_tmp0;
    end      
  end
  
  assign spi_clk_rsing = spi_clk_tmp0 & !spi_clk_tmp1;
  assign spi_clk_fall  = !spi_clk_tmp0 & spi_clk_tmp1;
  
  always@(posedge clk_i or negedge rst_n)begin
    if(!rst_n)begin
      spi_mosi_s0 <= 1'b1;
      spi_mosi_s1 <= 1'b1;
    end
    else begin
      spi_mosi_s0 <= spi_mosi_i;
      spi_mosi_s1 <= spi_mosi_s0;
    end      
  end
  
  always@(posedge clk_i or negedge rst_n)begin
    if(!rst_n)
      spi_rx_data <= 8'h00;
    else if(CPHA && spi_clk_fall)
      spi_rx_data <= {spi_rx_data[6:0],spi_mosi_s1};
    else if(!CPHA && spi_clk_rsing)
      spi_rx_data <= {spi_rx_data[6:0],spi_mosi_s1};
    else
      spi_rx_data <= spi_rx_data;
  end
  
  always@(posedge clk_i or negedge rst_n)begin
    if(!rst_n)
      slave_spi_sta <= STA_IDLE;
    else begin
      case(slave_spi_sta)
        STA_IDLE:begin
          if(star_sign)
           slave_spi_sta <= STA_GCMD;
         else
           slave_spi_sta <= slave_spi_sta;
        end
        STA_GCMD:begin
          if(stop_sign)
            slave_spi_sta <= STA_IDLE;
          else if(bit_pulse_s0 == 1'b1)
            slave_spi_sta <= STA_ADDR;
          else
            slave_spi_sta <= slave_spi_sta;
        end
        STA_ADDR:begin
          if(stop_sign)
            slave_spi_sta <= STA_IDLE;
          else if(bit_pulse_s0 && (get_cmd == CMD_WRDA))
            slave_spi_sta <= STA_GDATA;
          else if(bit_pulse_s0 && (get_cmd == CMD_RDDA))
            slave_spi_sta <= STA_ODATA;
          else
            slave_spi_sta <= slave_spi_sta;
        end
        STA_GDATA,STA_ODATA:begin
          if(stop_sign)
            slave_spi_sta <= STA_IDLE;
          else
            slave_spi_sta <= slave_spi_sta;
        end
      endcase
    end
  end
  
  always@(posedge clk_i or negedge rst_n)begin
    if(!rst_n)
      bit_cnt <= 3'd0;
    else if(stop_sign | star_sign)
      bit_cnt <= 3'd0;
    else if(CPHA && spi_clk_fall)
      bit_cnt <= bit_cnt + 3'd1;
    else if(!CPHA && spi_clk_rsing)
      bit_cnt <= bit_cnt + 3'd1;
    else
      bit_cnt <= bit_cnt;
  end
  
  assign bit7_pulse = (bit_cnt == 3'd7);
  assign bit_clr = bit7_pulse && ((CPHA && spi_clk_fall) | (!CPHA && spi_clk_rsing));
  
  always@(posedge clk_i or negedge rst_n)begin
    if(!rst_n)begin
      bit_pulse <= 1'b0;
      bit_pulse_s0 <= 1'b0;
    end
    else begin
      bit_pulse <= bit_clr;
      bit_pulse_s0 <= bit_pulse;
    end
  end
  
  always@(posedge clk_i or negedge rst_n)begin
    if(!rst_n)
      get_cmd <= CMD_IDLE;
    else if(star_sign | stop_sign)
      get_cmd <= CMD_IDLE;
    else if(slave_spi_sta != STA_GCMD)
      get_cmd <= get_cmd;
    else if(bit_pulse && (spi_rx_data == SPI_CMD_WR))
      get_cmd <= CMD_WRDA;
    else if(bit_pulse && (spi_rx_data == SPI_CMD_RD))
      get_cmd <= CMD_RDDA;
    else if(bit_pulse && (spi_rx_data == SPI_CMD_CLR))
      get_cmd <= CMD_CLRC;
    else
      get_cmd <= get_cmd;
  end
  
  always@(posedge clk_i or negedge rst_n)begin
    if(!rst_n)
      get_addr <= 8'h00;
    else if(star_sign | stop_sign)
      get_addr <= 8'd0;
    else if((slave_spi_sta == STA_ADDR) && bit_pulse)
      get_addr <= spi_rx_data;
    else
      get_addr <= get_addr;
  end
  
  always@(posedge clk_i or negedge rst_n)begin
    if(!rst_n)
      addr_offset <= 7'd0;
    else if(star_sign | stop_sign)
      addr_offset <= 7'd0;
    else if(bit_pulse && (slave_spi_sta == STA_GDATA))
      addr_offset <= addr_offset + 7'd1;
    else if(bit_pulse && (slave_spi_sta == STA_ODATA))
      addr_offset <= addr_offset + 7'd1;
    else
      addr_offset <= addr_offset;
  end
  
  assign opt_addr = get_addr + addr_offset;
  
  always@(posedge clk_i or negedge rst_n)begin
    if(!rst_n)begin
      for(i = 0; i <= 255;i= i+ 1)
        memory[i] = 8'h00;
    end
    else if(bit_pulse && (slave_spi_sta == STA_GDATA))
      memory[opt_addr] <= spi_rx_data;
  end
  
  always@(posedge clk_i or negedge rst_n)begin
    if(!rst_n)
      spi_tx_data <= 8'h00;
    else if(bit_pulse_s0)
      spi_tx_data <= memory[opt_addr];
    else if(CPHA && spi_clk_rsing && (bit_cnt >= 3'd1))
      spi_tx_data <= {spi_tx_data[6:0],1'b0};
    else if(!CPHA && spi_clk_fall && (bit_cnt >= 3'd1))
      spi_tx_data <= {spi_tx_data[6:0],1'b0};
    else
      spi_tx_data <= spi_tx_data;
  end
  
  assign spi_miso = spi_tx_data[7];
  
  always@(posedge clk_i or negedge rst_n)begin
    if(!rst_n)
      rx_done <= 1'b0;
    else if((slave_spi_sta == STA_GDATA) && bit_pulse)
      rx_done <= 1'b1;
    else
      rx_done <= 1'b0;
  end
  
  always@(posedge clk_i or negedge rst_n)begin
    if(!rst_n)
      rx_data <= 8'b0;
    else if(bit_pulse_s0 && (slave_spi_sta == STA_GDATA))
      rx_data <= spi_rx_data;
    else
      rx_data <= rx_data;
  end
  
endmodule
