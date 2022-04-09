`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/03/01 13:41:43
// Design Name: 
// Module Name: slave_i2c
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


module slave_i2c(
  input  wire       rst_n,
  input  wire       clk_i,
  input  wire       i2c_scl_i,
  inout  wire       i2c_sda_io,
  output wire [7:0] rx_data_o,
  output wire       rx_done_o
  );
  
  localparam SLAVE_WID = 8'ha0,
             SLAVE_RID = 8'ha1;
  localparam STA_IDLE = 6'b000_000,
             STA_GID  = 6'b000_001,
             STA_GADDR= 6'b000_010,
             STA_GDATA= 6'b000_100,
             STA_ODATA= 6'b001_000;
             
  localparam CNT_JUD_NUM = 4'd8,
             CNT_CH_NUM  = 4'd9;
  
  reg       i2c_scl_s0;
  reg       i2c_scl_s1;
  reg       i2c_scl_tmp0;
  reg       i2c_scl_tmp1;
  wire      i2c_scl_rsing;
  wire      i2c_scl_fall;
  
  reg        i2c_sda_s0;   
  reg        i2c_sda_s1;
  reg        i2c_sda_tmp0;
  reg        i2c_sda_tmp1;
  wire       i2c_sda_rsing;
  wire       i2c_sda_fall;
  
  reg        sda_oen;
  reg        sda_exp;
  
  wire       star_sign;
  wire       stop_sign;
  reg  [5:0] slave_sta;
  reg  [7:0] slave_rx_data;
  reg  [7:0] slave_tx_data;
  reg  [3:0] scl_rcnt;
  wire       judge_sign;
  wire       change_sign;
  reg        judge_sign_s0;
  reg        change_sign_s0;
  reg  [1:0] scl_wrrd;
  reg  [7:0] ctrl_addr;
  reg  [7:0] memoryblock[0:255];
  reg  [7:0] wr_data;
  reg  [7:0] i2c_rxdata;
  wire [7:0] opt_addr;
  reg        i2c_opt;
  reg  [7:0] addr_offset;
  reg        master_ack;
  reg  [7:0] speed_load;
  reg  [7:0] speed_cnt;
  integer   i;
  
  assign i2c_sda_io = sda_oen?(sda_exp?1'bz:1'b0):1'bz;
  assign rx_data_o  = i2c_rxdata;
  assign rx_done_o  = stop_sign;
  
  always@(posedge clk_i or negedge rst_n)begin
    if(!rst_n)begin
      i2c_scl_s0 <= 1'b1;
      i2c_scl_s1 <= 1'b1;
      i2c_scl_tmp0 <= 1'b1;
      i2c_scl_tmp1 <= 1'b1;
    end
    else begin
      i2c_scl_s0 <= i2c_scl_i;
      i2c_scl_s1 <= i2c_scl_s0;
      i2c_scl_tmp0 <= i2c_scl_s1;
      i2c_scl_tmp1 <= i2c_scl_tmp0;
    end
  end
  
  assign i2c_scl_rsing = i2c_scl_tmp0 & !i2c_scl_tmp1;
  assign i2c_scl_fall  = !i2c_scl_tmp0 & i2c_scl_tmp1;
  
  always@(posedge clk_i or negedge rst_n)begin
    if(!rst_n)begin
      i2c_sda_s0 <= 1'b1;
      i2c_sda_s1 <= 1'b1;
      i2c_sda_tmp0 <= 1'b1;
      i2c_sda_tmp1 <= 1'b1;
    end
    else begin
      i2c_sda_s0 <= i2c_sda_io;
      i2c_sda_s1 <= i2c_sda_s0;
      i2c_sda_tmp0 <= i2c_sda_s1;
      i2c_sda_tmp1 <= i2c_sda_tmp0;
    end
  end
  
  assign i2c_sda_rsing = i2c_sda_tmp0 & !i2c_sda_tmp1;
  assign i2c_sda_fall  = !i2c_sda_tmp0 & i2c_sda_tmp1;
  
  assign star_sign = i2c_scl_s1 & i2c_sda_fall;
  assign stop_sign = i2c_scl_s1 & i2c_sda_rsing;
  
  always@(posedge clk_i or negedge rst_n)begin
    if(!rst_n)
      i2c_opt <= 1'b0;
    else if(stop_sign == 1'b1)
      i2c_opt <= 1'b0;
    else if(star_sign == 1'b1)
      i2c_opt <= 1'b1;
    else
      i2c_opt <= i2c_opt;
  end
  
  always@(posedge clk_i or negedge rst_n)begin
    if(!rst_n)
      slave_rx_data <= 8'h00;
    else if(i2c_scl_rsing)
      slave_rx_data <= {slave_rx_data[6:0],i2c_sda_s1};
    else
      slave_rx_data <= slave_rx_data;
  end
  
  always@(posedge clk_i or negedge rst_n)begin
    if(!rst_n)
      scl_rcnt <= 4'd0;
    else if(stop_sign | star_sign)
      scl_rcnt <= 4'd0;
    else if((scl_rcnt == CNT_CH_NUM) && i2c_scl_fall)
      scl_rcnt <= 4'd0;
    else if(i2c_scl_rsing)
      scl_rcnt <= scl_rcnt + 4'd1;
    else
      scl_rcnt <= scl_rcnt;
  end
  
  assign judge_sign = (scl_rcnt == CNT_JUD_NUM)?i2c_scl_fall:1'b0;
  assign change_sign = (scl_rcnt == CNT_CH_NUM)?i2c_scl_fall:1'b0;
  
  always@(posedge clk_i or negedge rst_n)begin
    if(!rst_n)begin
      judge_sign_s0 <= 1'b0;
      change_sign_s0 <= 1'b0;
    end
    else begin
      judge_sign_s0 <= judge_sign;
      change_sign_s0 <= change_sign;
    end
  end
  
  always@(posedge clk_i or negedge rst_n)begin
    if(!rst_n)
      slave_sta <= STA_IDLE;
    else begin
      case(slave_sta)
        STA_IDLE:begin
          if(star_sign == 1'b1)
            slave_sta <= STA_GID;
          else
            slave_sta <= slave_sta;
        end
        
        STA_GID:begin
          if(stop_sign == 1'b1)
            slave_sta <= STA_IDLE;
          else if(change_sign && (scl_wrrd == 2'b10))
            slave_sta <= STA_ODATA;
          else if(change_sign && (scl_wrrd == 2'b00))
            slave_sta <= STA_GADDR;
          else
            slave_sta <= slave_sta;
        end
        
        STA_GADDR:begin
          if(stop_sign == 1'b1)
            slave_sta <= STA_IDLE;
          else if(change_sign == 1'b1)
            slave_sta <= STA_GDATA;
          else
            slave_sta <= slave_sta;
        end
        
        STA_GDATA:begin
          if(stop_sign == 1'b1)
            slave_sta <= STA_IDLE;
          else if(star_sign == 1'b1)
            slave_sta <= STA_GID;
          else
            slave_sta <= slave_sta;
        end
        
        STA_ODATA:begin
          if(stop_sign == 1'b1)
            slave_sta <= STA_IDLE;
          else if(speed_cnt >= (speed_load + 8'd2))
            slave_sta <= STA_IDLE;
          else if(change_sign && master_ack)
            slave_sta <= STA_IDLE;
          else
            slave_sta <= slave_sta;
        end
        default: slave_sta <= slave_sta;
      endcase
    end
  end
  
  always@(posedge clk_i or negedge rst_n)begin
    if(!rst_n)
      addr_offset <= 8'd0;
    else if(star_sign | stop_sign)
      addr_offset <= 8'd0;
    else if(judge_sign && (slave_sta == STA_ODATA))
      addr_offset <= addr_offset + 8'd1;
    else if(judge_sign && (slave_sta == STA_GDATA))
      addr_offset <= addr_offset + 8'd1;
    else
      addr_offset <= addr_offset;
  end
  
  always@(posedge clk_i or negedge rst_n)begin
    if(!rst_n)
      scl_wrrd <= 2'b11;
    else if(star_sign | stop_sign)
      scl_wrrd <= 2'b11;
    else if(slave_sta != STA_GID)
      scl_wrrd <= scl_wrrd;
    else if(judge_sign == 1'b0)
      scl_wrrd <= scl_wrrd;
    else if(slave_rx_data == SLAVE_WID)
      scl_wrrd <= 2'b00;
    else if(slave_rx_data == SLAVE_RID)
      scl_wrrd <= 2'b10;
    else
      scl_wrrd <= 2'b11;
  end
  
  always@(posedge clk_i or negedge rst_n)begin
    if(!rst_n)
      ctrl_addr <= 8'b0;
    else if(stop_sign)
      ctrl_addr <= 8'b0;
    else if(judge_sign && (slave_sta == STA_GADDR))
      ctrl_addr <= slave_rx_data;
    else
      ctrl_addr <= ctrl_addr;
  end
  
  always@(posedge clk_i or negedge rst_n)begin
    if(!rst_n)
      wr_data <= 8'b0;
    else if(judge_sign && (slave_sta == STA_GDATA))
      wr_data <= slave_rx_data;
    else
      wr_data <= wr_data;
  end
  
  assign opt_addr = ctrl_addr + addr_offset;
  
  always@(posedge clk_i or negedge rst_n)begin
    if(!rst_n)begin
      for(i = 0; i <= 255; i = i+1)
        memoryblock[i] = 8'h00;
    end
    else if((slave_sta == STA_GDATA) && judge_sign)
      memoryblock[opt_addr] <= slave_rx_data;      
  end
  
  always@(posedge clk_i or negedge rst_n)begin
    if(!rst_n)
      i2c_rxdata <= 8'h00;
    else if((slave_sta == STA_GDATA) && judge_sign)
      i2c_rxdata <= slave_rx_data;
    else
      i2c_rxdata <= i2c_rxdata;
  end
  
  always@(posedge clk_i or negedge rst_n)begin
    if(!rst_n)
      master_ack <= 1'b1;
    else if(star_sign | stop_sign)
      master_ack <= 1'b1;
    else if(i2c_scl_rsing && (scl_rcnt == 4'd8))
      master_ack <= i2c_sda_io;
    else
      master_ack <= master_ack;
  end
  
  always@(posedge clk_i or negedge rst_n)begin
    if(!rst_n)
      sda_oen <= 1'b0;
    else if(star_sign | stop_sign)
      sda_oen <= 1'b0;
    else begin
      case(slave_sta)
        STA_ODATA:begin
          if(change_sign_s0)
            sda_oen <= 1'b1;
          else if(judge_sign)
            sda_oen <= 1'b0;
          else
            sda_oen <= sda_oen;
        end
        
        STA_IDLE: sda_oen <= 1'b0;
        default:begin
          if(judge_sign)
            sda_oen <= 1'b1;
          else if(scl_rcnt == 4'd0)
            sda_oen <= 1'b0;
          else
            sda_oen <= sda_oen;
        end
      endcase
    end
  end
  
  always@(posedge clk_i or negedge rst_n)begin
    if(!rst_n)
      sda_exp <= 1'b1;
    else if(judge_sign_s0 && (scl_wrrd[0] == 1'b1))
      sda_exp <= 1'b1;
    else if(judge_sign_s0 && (scl_wrrd[0] == 1'b0))
      sda_exp <= 1'b0;
    else if(change_sign_s0 && (slave_sta == STA_ODATA))
      sda_exp <= slave_tx_data[7];
    else if(i2c_scl_fall && (slave_sta == STA_ODATA))
      sda_exp <= slave_tx_data[7];
    else
      sda_exp <= sda_exp;
  end
  
  always@(posedge clk_i or negedge rst_n)begin
    if(!rst_n)
      slave_tx_data <= 8'h00;
    else if(scl_rcnt == CNT_CH_NUM)
      slave_tx_data <= memoryblock[opt_addr];
    else if(i2c_scl_rsing && (slave_sta == STA_ODATA))
      slave_tx_data <= {slave_tx_data[6:0],1'b0};
    else
      slave_tx_data <= slave_tx_data;
  end
  
  always@(posedge clk_i or negedge rst_n)begin
    if(!rst_n)
      speed_load <= 8'd0;
    else if(star_sign | stop_sign)
      speed_load <= 8'd0;
    else if(i2c_scl_rsing && (slave_sta == STA_GID))
      speed_load <= speed_cnt;
    else
      speed_load <= speed_load;
  end
  
 always@(posedge clk_i or negedge rst_n)begin
    if(!rst_n)
      speed_cnt <= 8'd0;
    else if(i2c_opt == 1'b0)
      speed_cnt <= 8'd0;
    else if(i2c_scl_rsing)
      speed_cnt <= 8'd0;
    else
      speed_cnt <= speed_cnt + 8'd1; 
  end 
  
endmodule
