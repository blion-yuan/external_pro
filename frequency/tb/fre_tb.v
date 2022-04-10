`timescale 1ns/1ns
`define clock_period 20
`define lclk_period 2000

module fre_tb();

	reg 		sys_clk;
	reg 		rst;
	reg [1:0]	fre_hz;
	
	initial sys_clk = 1'b1;
	always #(`clock_period/2) sys_clk = ~sys_clk;	//时钟
	
	reg [23:0] rang_hz;
   
   fre_top u_fre_top(
		.rst_n(rst),
		.clk_i(sys_clk),
		.frehz_i(fre_hz),
	
		.SH_CP(),
		.ST_CP(),
		.DS()
	);
   
	initial begin
		rst = 1'b0;
		fre_hz[1:0] = 2'b00;
		repeat(100) @(posedge sys_clk);	
		rst = 1'b1;
		repeat(100) @(posedge sys_clk);	
		rang_hz = 480;//{$random}%500; 
		repeat(60)begin
			repeat(rang_hz) @(posedge sys_clk);
			fre_hz[1:0] = 2'b00;
			repeat(rang_hz) @(posedge sys_clk);
			fre_hz[1:0] = 2'b11;
		end
		repeat(10)begin
			repeat(55000) @(posedge sys_clk);
			fre_hz[1:0] = 2'b00;
			repeat(55000) @(posedge sys_clk);
			fre_hz[1:0] = 2'b11;
		end
//		rang_hz = {$random}%500; 
//		repeat(60)begin
//			repeat(rang_hz) @(posedge sys_clk);
//			fre_hz[1:0] = 2'b00;
//			repeat(rang_hz) @(posedge sys_clk);
//			fre_hz[1:0] = 2'b11;
//		end
//		rang_hz = {$random}%500; 
//		repeat(70)begin
//			repeat(rang_hz) @(posedge sys_clk);
//			fre_hz[1:0] = 2'b00;
//			repeat(rang_hz) @(posedge sys_clk);
//			fre_hz[1:0] = 2'b11;
//		end
		repeat(100) @(posedge sys_clk);
		$stop;
	end
	


endmodule
