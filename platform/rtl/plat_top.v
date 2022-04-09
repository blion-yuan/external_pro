module plat_top(
	input wire rst_n,
	input wire clk_i,
	
	input  wire uart_rx_i,
	output wire uart_tx_o,
	output wire led_o,
	
	output wire dat_o,
	output wire cp_o
	);
	
	wire [3:0] 	gpio1_out;
	
	assign cp_o = gpio1_out[0];
	assign dat_o =gpio1_out[1];
	
    palt_nios u0 (
        .clk_clk      (clk_i),      //   clk.clk
        .rst_reset_n  (rst_n),  //   rst.reset_n
        .led_export   (led_o),   //   led.export
        .uart_rxd     (uart_rx_i),     //  uart.rxd
        .uart_txd     (uart_tx_o),     //      .txd
        .gpio1_export (gpio1_out)  // gpio1.export
    );
	 
   


endmodule
