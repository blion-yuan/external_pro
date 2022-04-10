module fre_sure(
	input  wire rst_n,
	input  wire clk_i,
	input  wire fre_hz_i,
	
	output wire low_fre_sign_o,
	output wire [19:0] prob_khz_o
	);
	
	reg fre_hz_s0,fre_hz_s1;
	reg fre_hz_tmp0,fre_hz_tmp1;
	wire fre_rsing,fre_fall;
	

	reg  [25:0]	unit_cnt;
	wire			unit_stop;
	wire 			unit_overflow;
	reg [3:0] 	main_sta;
	reg 	  		low_fre_detection;
	reg [19:0] 	prob_khz;
	reg 			low_fre_sign;
	reg [19:0] 	pulse_cnt;
	
	wire [25:0] prob_hz;
	
	reg [3:0] cal_cnt;
	wire cal_over;
	reg [25:0] low_hz;
	
	assign prob_khz_o = low_fre_sign?low_hz[19:0]:prob_khz;
	assign low_fre_sign_o = low_fre_sign;
	
	always@(posedge clk_i or negedge rst_n)begin
		if(!rst_n)begin
			fre_hz_s0 <= 1'b0;
			fre_hz_s1 <= 1'b0;
			fre_hz_tmp0 <= 1'b0;
			fre_hz_tmp1 <= 1'b0;
		end
		else begin
			fre_hz_s0 <= fre_hz_i;
			fre_hz_s1 <= fre_hz_s0;
			fre_hz_tmp0 <= fre_hz_s1;
			fre_hz_tmp1 <= fre_hz_tmp0;
		end
	end
	
	assign fre_rsing = fre_hz_tmp0 & !fre_hz_tmp1;
	assign fre_fall  = !fre_hz_tmp0 & fre_hz_tmp1;
	
	localparam  IDLE  = 4'b0000,
			    UNIT  = 4'b0001,
				PERID = 4'b0010,
				CALC  = 4'b0100;
				
	
	
	always@(posedge clk_i or negedge rst_n)begin
	  if(!rst_n)
		main_sta <= IDLE;
	  else begin
	    case(main_sta)
		  IDLE:begin
		    if(fre_rsing)
			  main_sta <= UNIT;
			else
		      main_sta <= IDLE;
		  end
	  
		  UNIT:begin
		    if(!unit_stop)
			  main_sta <= UNIT;
			else if(pulse_cnt == 12'd0)
		      main_sta <= PERID;
			else
		      main_sta <= CALC;
		  end
		  
		  PERID:begin
		    if(fre_rsing | unit_overflow)
		      main_sta <= CALC;
			else
			  main_sta <= PERID;
		  end
		  
		  CALC:begin
		    if(cal_over)
				main_sta <= IDLE;
			 else
				main_sta <= CALC;
		  end
	  
	      default: main_sta <= IDLE;
		endcase
	  end
	end
	
	
	always@(posedge clk_i or negedge rst_n)begin
		if(!rst_n)
			cal_cnt <= 4'd0;
		else if(main_sta == CALC)
			cal_cnt <= cal_cnt + 4'd1;
		else
			cal_cnt <= 4'd0;
	end
	
	assign cal_over = cal_cnt == 4'd14;
	
	always@(posedge clk_i or negedge rst_n)begin
	  if(!rst_n)
	    prob_khz <= 20'd0;
	  else if(!cal_over)
	    prob_khz <= prob_khz;
	  else if(!low_fre_detection)
	    prob_khz <= pulse_cnt;	//频率 khz
//	  else if(unit_overflow == 1'b1)
//	    prob_khz <= 20'd0;		//超范围 小于1hz
	  else 
	    prob_khz <= 20'd0;//20'd50_000_000/unit_cnt; //频率 hz
	end
	
	wire [25:0] diver;
	assign diver = 26'd50_000_000; 
	
	div u_div(
		.aclr(~rst_n),
		.clken(1'b1),
		.clock(clk_i),
		.denom(unit_cnt),
		.numer(diver),
		.quotient(prob_hz),
		.remain()
	);
	
	always@(posedge clk_i or negedge rst_n)begin
		if(!rst_n)
			low_hz <= 26'd0;
		else if(cal_over)
			low_hz <= prob_hz;
		else
			low_hz <= low_hz;
	end
	

	
	always@(posedge clk_i or negedge rst_n)begin
		if(!rst_n)
			low_fre_sign <= 1'b0;
		else if(main_sta != CALC)
			low_fre_sign <= low_fre_sign;
		else 
			low_fre_sign <= low_fre_detection;
	end
	
	always@(posedge clk_i or negedge rst_n)begin
		if(!rst_n)
		  unit_cnt <= 26'd1;
		else if(main_sta == IDLE)
		  unit_cnt <= 26'd1;
		else if(main_sta == CALC)
		  unit_cnt <= unit_cnt;
		else
		  unit_cnt <= unit_cnt + 26'd1;
	end
	
	assign unit_stop = unit_cnt == 26'd50_000;
	assign unit_overflow = unit_cnt >= 26'd50_000_000;
	
	always@(posedge clk_i or negedge rst_n)begin
	  if(!rst_n)
		pulse_cnt <= 20'd0;
	  else if(main_sta == IDLE)
		pulse_cnt <= 20'd0;
	  else if(fre_rsing)
	    pulse_cnt <= pulse_cnt + 20'd1;
	  else
	    pulse_cnt <= pulse_cnt;
	end

	always@(posedge clk_i or negedge rst_n)begin
	  if(!rst_n)
	    low_fre_detection <= 1'b0;
	  else if(main_sta == PERID)
	    low_fre_detection <= 1'b1;
	  else if(main_sta == IDLE)
	    low_fre_detection <= 1'b0;
	  else
	    low_fre_detection <= low_fre_detection;
	end
	
endmodule
