`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/03/01 11:22:47
// Design Name: 
// Module Name: mi2c_drive
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


module mi2c_drive(
  input  wire       rst_n,
  input  wire       clk_i,
  input  wire       cmd_en_i,
  input  wire [5:0] cmd_sta_i,
  input  wire [7:0] tx_data_i,
  input  wire       rd_over_i,
  
  output wire       slave_ack_o,
  output wire       cmd_done_o,
  output wire [7:0] rd_data_o,
  output wire       i2c_scl_o,
  inout  wire       i2c_sda_io
  );
  
  localparam STA_IDLE = 6'b000_000,
             STA_STAR = 6'b000_001,
             STA_WR   = 6'b000_010,
             STA_GACK = 6'b000_100,
             STA_RD   = 6'b001_000,
             STA_OACK = 6'b010_000,
             STA_STOP = 6'b100_000;
  localparam STAR_NUM = 5'd3,
             WRD_NUM  = 5'd31;
  parameter SYS_CLK = 50_000_000,
              I2C_CLK = 400_00,
              CNT_NUM = SYS_CLK / I2C_CLK /4 - 8'd1;         
  
  reg        sda_aoe;
  reg        sda_tmp_exp;
  reg        scl_exp;
  reg  [4:0] div_load_num;
  reg  [7:0] scl_div_cnt;
  wire       div_pulse;
  wire       div_difpulse;
  reg        scl_cnt_en;
  reg  [4:0] div_load_cnt;
  reg        cmd_done;
  reg  [7:0] tx_data;
  reg        slave_ack;
  reg  [7:0] i2c_mrdata;
  
  assign cmd_done_o = cmd_done;
  assign slave_ack_o = slave_ack;
  assign rd_data_o = i2c_mrdata;
  assign i2c_scl_o = scl_exp;
  assign i2c_sda_io = sda_aoe?(sda_tmp_exp?1'bz:1'b0):1'bz;
  
  always@(posedge clk_i or negedge rst_n)begin
    if(!rst_n)
      div_load_num <= STAR_NUM;
    else if(cmd_en_i == 1'b0)
      div_load_num <= div_load_num;
    else begin
      case(cmd_sta_i)
        STA_WR,STA_RD:div_load_num <= WRD_NUM;
        default:div_load_num <= STAR_NUM;
      endcase
    end
  end
  
  always@(posedge clk_i or negedge rst_n)begin
    if(!rst_n)
      sda_aoe <= 1'b0;
    else begin
      case(cmd_sta_i)
        STA_IDLE,STA_GACK,STA_RD:sda_aoe <= 1'b0;
        default:sda_aoe <= 1'b1;
      endcase
    end
  end
  
  always@(posedge clk_i or negedge rst_n)begin
    if(!rst_n)
      sda_tmp_exp <= 1'b1;
    else begin
      case(cmd_sta_i)
        STA_IDLE: sda_tmp_exp <= 1'b1;
        STA_STAR:begin
          if(div_load_cnt <= 5'd1)
            sda_tmp_exp <= 1'b1;
          else
            sda_tmp_exp <= 1'b0;
        end
        
        STA_WR:begin
          sda_tmp_exp <= tx_data[7];
        end
        
        STA_OACK:begin
          sda_tmp_exp <= rd_over_i;
        end
        
        STA_STOP:begin
          if(div_load_cnt <= 5'd2)
            sda_tmp_exp <= 1'b0;
          else
            sda_tmp_exp <= 1'b1;
        end
        default:sda_tmp_exp <= sda_tmp_exp;
      endcase
    end
  end
  
  always@(posedge clk_i or negedge rst_n)begin
    if(!rst_n)
      i2c_mrdata <= 8'b0;
    else if(cmd_sta_i != STA_RD)
      i2c_mrdata <= i2c_mrdata;
    else if(div_pulse == 1'b0)
      i2c_mrdata <= i2c_mrdata;
    else if(div_load_cnt == (div_load_cnt[4:2] << 2) + 5'd1)
      i2c_mrdata <= {i2c_mrdata[6:0],i2c_sda_io};
    else
      i2c_mrdata <= i2c_mrdata;
  end
  
  always@(posedge clk_i or negedge rst_n)begin
    if(!rst_n)
      slave_ack <= 1'b0;
    else if((sda_aoe == 1'b0) && (div_load_cnt == 5'd1))
      slave_ack <= i2c_sda_io;
    else
      slave_ack <= slave_ack;
  end
  
  always@(posedge clk_i or negedge rst_n)begin
    if(!rst_n)
      scl_exp <= 1'b1;
    else begin
      case(cmd_sta_i)
        STA_IDLE: scl_exp <= 1'b1;
        STA_STAR: begin
          if(div_load_cnt <= 5'd2)
            scl_exp <= 1'b1;
          else
            scl_exp <= 1'b0;
        end
        
        STA_WR,STA_RD:begin
          if(div_load_cnt == 5'd0)
            scl_exp <= 1'b0;
          else if(div_load_cnt == (div_load_cnt[4:2]  << 2) + 5'd3)
            scl_exp <= 1'b0;
          else if(div_load_cnt == (div_load_cnt[4:2]  << 2) + 5'd1)
            scl_exp <= 1'b1;
          else
            scl_exp <= scl_exp; 
        end
        
        STA_OACK,STA_GACK:begin
          if(div_load_cnt == 5'd0)
            scl_exp <= 1'b0;
          else if(div_load_cnt == div_load_num)
            scl_exp <= 1'b0;
          else
            scl_exp <= 1'b1;
        end
        
        STA_STOP:begin
          if(div_load_cnt == 5'd0)
            scl_exp <= 1'b0;
          else
             scl_exp <= 1'b1;
        end
        default:scl_exp <= scl_exp;
      endcase
    end
  end
  
  always@(posedge clk_i or negedge rst_n)begin
    if(!rst_n)
      scl_div_cnt <= 8'd0;
    else if(scl_cnt_en == 1'b0)
      scl_div_cnt <= 8'd0;
    else if(scl_div_cnt == CNT_NUM)
      scl_div_cnt <= 8'd0;
    else
      scl_div_cnt <= scl_div_cnt + 8'd1;
  end
  
  assign div_pulse = (scl_div_cnt == CNT_NUM)?1'b1:1'b0;
  assign div_difpulse = (scl_div_cnt == (CNT_NUM - 8'd1))?1'b1:1'b0;
  
  always@(posedge clk_i or negedge rst_n)begin
    if(!rst_n)
      scl_cnt_en <= 1'b0;
    else if(cmd_en_i == 1'b1)
      scl_cnt_en <= 1'b1;
    else if((div_load_cnt == div_load_num) && div_pulse)
      scl_cnt_en <= 1'b0;
    else
      scl_cnt_en <= scl_cnt_en;
  end
  
  always@(posedge clk_i or negedge rst_n)begin
    if(!rst_n)
      cmd_done <= 1'b0;
    else if((div_load_cnt == div_load_num) && div_difpulse)
      cmd_done <= 1'b1;
    else
      cmd_done <= 1'b0;
  end
  
  always@(posedge clk_i or negedge rst_n)begin
    if(!rst_n)
      div_load_cnt <= 5'd0;
    else if(scl_cnt_en == 1'b0)
      div_load_cnt <= 5'd0;
    else if(div_pulse == 1'b0)
      div_load_cnt <= div_load_cnt;
    else if(div_load_cnt == div_load_num)
      div_load_cnt <= 5'd0;
    else
      div_load_cnt <= div_load_cnt + 5'd1;
  end
  
  always@(posedge clk_i or negedge rst_n)begin
    if(!rst_n)
      tx_data <= 8'b0;
    else if(cmd_done == 1'b1)
      tx_data <= tx_data_i;
    else if(div_pulse == 1'b0)
      tx_data <= tx_data;
    else if((div_load_cnt == (div_load_cnt[4:2] << 2) + 5'd3))
      tx_data <= {tx_data[6:0],1'b0};
    else
      tx_data <= tx_data;
  end
  
endmodule
