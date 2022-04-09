`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/03/01 09:32:04
// Design Name: 
// Module Name: mi2c_ctrl
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


module mi2c_ctrl(
 input  wire       rst_n,
 input  wire       clk_i,
 input  wire       i2c_wren_i,
 input  wire       i2c_rden_i,
 input  wire [7:0] chip_id_i,
 input  wire [7:0] i2c_wdata_i,
 input  wire [15:0]i2c_waddr_i,
 input  wire       addr_len_i,
 input  wire [6:0] wrrd_num_i,
 
 output wire       sign_done_o,
 output wire       i2c_done_o,
 output wire [7:0] i2c_rdata_o,
 output wire       i2c_scl_o,
 inout  wire       i2c_sda_io
 );
 
 localparam CMD_IDLE = 6'b000_000,
            CMD_STAR = 6'b000_001,
            CMD_WR   = 6'b000_010,
            CMD_GACK = 6'b000_100,
            CMD_RD   = 6'b001_000,
            CMD_OACK = 6'b010_000,
            CMD_STOP = 6'b100_000;
 parameter SYS_CLK = 50_000_000,
            I2C_CLK = 400_000;
 localparam CHIP_WIP = 3'b000,
            CHIP_RIP = 3'b001,
            OP_LADDR = 3'b010,
            OP_HADDR = 3'b011,
            OP_WDATA = 3'b100;
  reg  [5:0]  cmd_sta;
  reg         cmd_en;
  wire        cmd_done;
  reg  [7:0]  wr_data;
  reg  [7:0]  sta_load_num;
  reg  [7:0]  wr_cnt;
  reg         wr_rd_sign;
  reg         i2c_over;
  wire       slave_ack;
  reg        sign_done;
  reg        rd_over;
  wire [7:0] i2c_rdata;
  reg  [7:0] i2c_mrdata;

  assign i2c_done_o = i2c_over;
  assign sign_done_o = sign_done;
  assign i2c_rdata_o = i2c_mrdata;

  always@(posedge clk_i or negedge rst_n)begin
    if(!rst_n)
      sta_load_num <= 8'd3;
    else if((i2c_wren_i == 1'b1) && !addr_len_i)
      sta_load_num <= 8'd2 + wrrd_num_i;
    else if((i2c_wren_i == 1'b1) && addr_len_i)
      sta_load_num <= 8'd3 + wrrd_num_i;
    else if((i2c_rden_i == 1'b1) && !addr_len_i)
      sta_load_num <= 8'd3 + wrrd_num_i;
    else if((i2c_rden_i == 1'b1) && addr_len_i)
      sta_load_num <= 8'd4 + wrrd_num_i;
    else
      sta_load_num <= sta_load_num;
  end
 
  always@(posedge clk_i or negedge rst_n)begin
    if(!rst_n)
      cmd_sta <= CMD_IDLE;
    else begin
      case(cmd_sta)
        CMD_IDLE:begin
          if(i2c_wren_i | i2c_rden_i)
            cmd_sta <= CMD_STAR;
          else
            cmd_sta <= cmd_sta;
        end
  
        CMD_STAR:begin
          if(cmd_done)
            cmd_sta <= CMD_WR;
          else
            cmd_sta <= cmd_sta;
        end
      
        CMD_WR:begin
          if(cmd_done)
            cmd_sta <= CMD_GACK;
          else
            cmd_sta <= cmd_sta;
        end
        
        CMD_GACK:begin
          if(!cmd_done)
            cmd_sta <= cmd_sta;
          else if(slave_ack == 1'b1)
            cmd_sta <= CMD_STOP;
          else if(wr_cnt == sta_load_num)
            cmd_sta <= CMD_STOP;
          else if(!addr_len_i && (wr_cnt == 8'd2) && wr_rd_sign)
            cmd_sta <= CMD_STAR;
          else if(!addr_len_i && (wr_cnt == 8'd3) && wr_rd_sign)
            cmd_sta <= CMD_RD;
          else
            cmd_sta <= CMD_WR;
        end
        
        CMD_RD:begin
          if(cmd_done)
            cmd_sta <= CMD_OACK;
          else
            cmd_sta <= cmd_sta;
        end
      
        CMD_OACK:begin
          if(!cmd_done)
            cmd_sta <= cmd_sta;
          else if(wr_cnt <= (sta_load_num - 8'd1))
            cmd_sta <= CMD_RD;
          else
            cmd_sta <= CMD_STOP;
        end
        
        CMD_STOP:begin
          if(!cmd_done)
            cmd_sta <= cmd_sta;
          else
            cmd_sta <= CMD_IDLE;
        end
        default:cmd_sta <= cmd_sta;
      endcase
    end
  end
 
  always@(posedge clk_i or negedge rst_n)begin
    if(!rst_n)
      wr_rd_sign <= 1'b0;
    else if(i2c_wren_i == 1'b1)
      wr_rd_sign <= 1'b0;
    else if(i2c_wren_i == 1'b1)
      wr_rd_sign <= 1'b1;
    else
      wr_rd_sign <= wr_rd_sign;
  end
  
  always@(posedge clk_i or negedge rst_n)begin
    if(!rst_n)
      wr_cnt <= 8'd0;
    else if(cmd_sta == CMD_IDLE)
      wr_cnt <= 8'd0;
    else if((cmd_done == 1'b1) && (cmd_sta == CMD_WR))
      wr_cnt <= wr_cnt + 8'd1;
    else if((cmd_done == 1'b1) && (cmd_sta == CMD_RD))
      wr_cnt <= wr_cnt + 8'd1;
    else
      wr_cnt <= wr_cnt;
  end
 
 always@(posedge clk_i or negedge rst_n)begin
    if(!rst_n)
      sign_done <= 1'b0;
    else if((cmd_sta != CMD_WR) && (cmd_sta != CMD_RD))
      sign_done <= 1'b0;
    else if(wr_cnt <= 8'd1)
      sign_done <= 1'b0;
    else if(!wr_rd_sign && !addr_len_i && (wr_cnt >= 8'd2))
      sign_done <= cmd_done;
    else if(!wr_rd_sign && addr_len_i && (wr_cnt >= 8'd3))
      sign_done <= cmd_done;
    else if(wr_rd_sign && !addr_len_i && (wr_cnt >= 8'd3))
      sign_done <= cmd_done;
    else if(wr_rd_sign && addr_len_i && (wr_cnt >= 8'd3))
      sign_done <= cmd_done; 
    else
      sign_done <= 1'b0;
  end
  
  always@(posedge clk_i or negedge rst_n)begin
    if(!rst_n)
      cmd_en <= 1'b0;
    else if(i2c_wren_i | i2c_rden_i)
      cmd_en <= 1'b1;
    else if(cmd_done && (cmd_sta != CMD_STOP))
      cmd_en <= 1'b1;
    else
      cmd_en <= 1'b0;
  end
  
  defparam U_mi2c_drive.SYS_CLK = SYS_CLK;
  defparam U_mi2c_drive.I2C_CLK = I2C_CLK;
  
 mi2c_drive U_mi2c_drive(
   .rst_n(rst_n),
   .clk_i(clk_i),
   .cmd_en_i(cmd_en),
   .cmd_sta_i(cmd_sta),
   .tx_data_i(wr_data),
   .rd_over_i(rd_over),
   
   .slave_ack_o(slave_ack),
   .cmd_done_o(cmd_done),
   .rd_data_o(i2c_rdata),
   .i2c_scl_o(i2c_scl_o),
   .i2c_sda_io(i2c_sda_io)
 );
 always@(posedge clk_i or negedge rst_n)begin
   if(!rst_n)
      wr_data <= chip_id_i;
   else begin
     case(wr_cnt)
       0:wr_data <= chip_id_i;
       1:begin
         if(addr_len_i)
           wr_data <= i2c_waddr_i[15:8];
         else
           wr_data <= i2c_waddr_i[7:0];
       end
       2:begin
         if(addr_len_i)
           wr_data <= i2c_waddr_i[7:0];
         else if(wr_rd_sign == 1'b1)
           wr_data <= {chip_id_i[7:1],1'b1};
         else
           wr_data <= i2c_wdata_i;
       end
       default:wr_data <= i2c_wdata_i;
     endcase
   end
 end   
   
 always@(posedge clk_i or negedge rst_n)begin
    if(!rst_n)
      i2c_over <= 1'b0;
    else if(cmd_done && (cmd_sta == CMD_STOP))
      i2c_over <= 1'b1;
    else
      i2c_over <= 1'b0;
  end
  
  always@(posedge clk_i or negedge rst_n)begin
    if(!rst_n)
      rd_over <= 1'b0;
    else if(wr_cnt >= sta_load_num)
      rd_over <= 1'b1;
    else
      rd_over <= 1'b0;
  end
  
  always@(posedge clk_i or negedge rst_n)begin
    if(!rst_n)
      i2c_mrdata <= 8'd0;
    else if(cmd_done && (cmd_sta == CMD_RD))
      i2c_mrdata <= i2c_rdata;
    else
      i2c_mrdata <= i2c_mrdata;
  end
  
endmodule
