module Binary_to_BCD(Clk,Rst_n,Do_Translate,Bin,Bcd,Done_Sig);

	input Clk;
	input Rst_n;
	input Do_Translate;
	input [19:0] Bin;
	
	output [27:0] Bcd;
	output reg Done_Sig;
	
	//20bit_bin+7*4bit_BCD 
	reg [47:0] shift_reg;	
	wire [47:0] shift_reg_out;
	wire [47:0]tmp;
	reg [47:0]bcd_tmp;
	
	//输入二进制数有几位即需要移位几次
	reg [4:0] cnt = 5'b0;
	
	//将输出的二进制数扩展到48bit
	assign tmp = {28'b0,Bin};
	
	//将输入二进制数进行移位且判断是否需要+3处理，并输出最终数据
	always@(posedge Clk or negedge Rst_n)
	begin
		if(!Rst_n)
			begin
				Done_Sig <= 1'b0;
				cnt <= 5'd0;
				shift_reg <= 48'd0;			
			end
		else
		begin
			case(cnt)
				0:begin
						Done_Sig <= 1'b0;
						if(Do_Translate)
							begin
								cnt <= cnt + 1'b1;
								shift_reg <= tmp<<1;
							end
						else
							cnt <= 1'b0;
					end
					
				1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18:
					begin
						shift_reg <= (shift_reg_out<<1);
						cnt <= cnt + 1'b1;
					end
				
				19:
					begin
						bcd_tmp <= shift_reg_out<<1;
						Done_Sig <= 1;
						cnt <= 5'b0;
					end
				default :cnt <= 5'b0;
			endcase	
		end
	end

	assign Bcd = bcd_tmp[47:20];
	
	bcd_modify bcd_modify
	(
		.data_in(shift_reg),
		.data_out(shift_reg_out)
	);
	
endmodule

`timescale 1ns/1ns

module bcd_modify(data_in, data_out);

	input [47:0] data_in;
	output [47:0] data_out;

	bcd_single_modify bcd6(.bcd_in(data_in[47:44]), .bcd_out(data_out[47:44]));
	bcd_single_modify bcd5(.bcd_in(data_in[43:40]), .bcd_out(data_out[43:40]));
	bcd_single_modify bcd4(.bcd_in(data_in[39:36]), .bcd_out(data_out[39:36]));
	bcd_single_modify bcd3(.bcd_in(data_in[35:32]), .bcd_out(data_out[35:32]));
	bcd_single_modify bcd2(.bcd_in(data_in[31:28]), .bcd_out(data_out[31:28]));
	bcd_single_modify bcd1(.bcd_in(data_in[27:24]), .bcd_out(data_out[27:24]));
	bcd_single_modify bcd0(.bcd_in(data_in[23:20]), .bcd_out(data_out[23:20]));
	assign data_out[19:0] = data_in[19:0];

endmodule

`timescale 1ns/1ns

module bcd_single_modify(bcd_in,bcd_out);

	input [3:0] bcd_in;
	output [3:0] bcd_out;

	reg [3:0] bcd_out;
	
	always @ (bcd_in)
	begin
		if (bcd_in > 4)
			bcd_out = bcd_in + 2'd3;
		else
			bcd_out = bcd_in;
	end

endmodule
