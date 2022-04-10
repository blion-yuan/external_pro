// palt_nios.v

// Generated using ACDS version 13.1 162 at 2022.04.10.20:36:18

`timescale 1 ps / 1 ps
module palt_nios (
		input  wire       clk_clk,      //   clk.clk
		input  wire       rst_reset_n,  //   rst.reset_n
		output wire       led_export,   //   led.export
		input  wire       uart_rxd,     //  uart.rxd
		output wire       uart_txd,     //      .txd
		output wire [1:0] gpio1_export  // gpio1.export
	);

	wire  [15:0] mm_interconnect_0_sys_timer_s1_writedata;                 // mm_interconnect_0:sys_timer_s1_writedata -> sys_timer:writedata
	wire   [2:0] mm_interconnect_0_sys_timer_s1_address;                   // mm_interconnect_0:sys_timer_s1_address -> sys_timer:address
	wire         mm_interconnect_0_sys_timer_s1_chipselect;                // mm_interconnect_0:sys_timer_s1_chipselect -> sys_timer:chipselect
	wire         mm_interconnect_0_sys_timer_s1_write;                     // mm_interconnect_0:sys_timer_s1_write -> sys_timer:write_n
	wire  [15:0] mm_interconnect_0_sys_timer_s1_readdata;                  // sys_timer:readdata -> mm_interconnect_0:sys_timer_s1_readdata
	wire  [31:0] mm_interconnect_0_led_s1_writedata;                       // mm_interconnect_0:led_s1_writedata -> led:writedata
	wire   [1:0] mm_interconnect_0_led_s1_address;                         // mm_interconnect_0:led_s1_address -> led:address
	wire         mm_interconnect_0_led_s1_chipselect;                      // mm_interconnect_0:led_s1_chipselect -> led:chipselect
	wire         mm_interconnect_0_led_s1_write;                           // mm_interconnect_0:led_s1_write -> led:write_n
	wire  [31:0] mm_interconnect_0_led_s1_readdata;                        // led:readdata -> mm_interconnect_0:led_s1_readdata
	wire  [31:0] mm_interconnect_0_rom_s1_writedata;                       // mm_interconnect_0:rom_s1_writedata -> rom:writedata
	wire  [10:0] mm_interconnect_0_rom_s1_address;                         // mm_interconnect_0:rom_s1_address -> rom:address
	wire         mm_interconnect_0_rom_s1_chipselect;                      // mm_interconnect_0:rom_s1_chipselect -> rom:chipselect
	wire         mm_interconnect_0_rom_s1_clken;                           // mm_interconnect_0:rom_s1_clken -> rom:clken
	wire         mm_interconnect_0_rom_s1_write;                           // mm_interconnect_0:rom_s1_write -> rom:write
	wire  [31:0] mm_interconnect_0_rom_s1_readdata;                        // rom:readdata -> mm_interconnect_0:rom_s1_readdata
	wire         mm_interconnect_0_rom_s1_debugaccess;                     // mm_interconnect_0:rom_s1_debugaccess -> rom:debugaccess
	wire   [3:0] mm_interconnect_0_rom_s1_byteenable;                      // mm_interconnect_0:rom_s1_byteenable -> rom:byteenable
	wire  [31:0] mm_interconnect_0_ram_s1_writedata;                       // mm_interconnect_0:ram_s1_writedata -> ram:writedata
	wire  [10:0] mm_interconnect_0_ram_s1_address;                         // mm_interconnect_0:ram_s1_address -> ram:address
	wire         mm_interconnect_0_ram_s1_chipselect;                      // mm_interconnect_0:ram_s1_chipselect -> ram:chipselect
	wire         mm_interconnect_0_ram_s1_clken;                           // mm_interconnect_0:ram_s1_clken -> ram:clken
	wire         mm_interconnect_0_ram_s1_write;                           // mm_interconnect_0:ram_s1_write -> ram:write
	wire  [31:0] mm_interconnect_0_ram_s1_readdata;                        // ram:readdata -> mm_interconnect_0:ram_s1_readdata
	wire   [3:0] mm_interconnect_0_ram_s1_byteenable;                      // mm_interconnect_0:ram_s1_byteenable -> ram:byteenable
	wire         mm_interconnect_0_sys_nios_jtag_debug_module_waitrequest; // sys_nios:jtag_debug_module_waitrequest -> mm_interconnect_0:sys_nios_jtag_debug_module_waitrequest
	wire  [31:0] mm_interconnect_0_sys_nios_jtag_debug_module_writedata;   // mm_interconnect_0:sys_nios_jtag_debug_module_writedata -> sys_nios:jtag_debug_module_writedata
	wire   [8:0] mm_interconnect_0_sys_nios_jtag_debug_module_address;     // mm_interconnect_0:sys_nios_jtag_debug_module_address -> sys_nios:jtag_debug_module_address
	wire         mm_interconnect_0_sys_nios_jtag_debug_module_write;       // mm_interconnect_0:sys_nios_jtag_debug_module_write -> sys_nios:jtag_debug_module_write
	wire         mm_interconnect_0_sys_nios_jtag_debug_module_read;        // mm_interconnect_0:sys_nios_jtag_debug_module_read -> sys_nios:jtag_debug_module_read
	wire  [31:0] mm_interconnect_0_sys_nios_jtag_debug_module_readdata;    // sys_nios:jtag_debug_module_readdata -> mm_interconnect_0:sys_nios_jtag_debug_module_readdata
	wire         mm_interconnect_0_sys_nios_jtag_debug_module_debugaccess; // mm_interconnect_0:sys_nios_jtag_debug_module_debugaccess -> sys_nios:jtag_debug_module_debugaccess
	wire   [3:0] mm_interconnect_0_sys_nios_jtag_debug_module_byteenable;  // mm_interconnect_0:sys_nios_jtag_debug_module_byteenable -> sys_nios:jtag_debug_module_byteenable
	wire         sys_nios_data_master_waitrequest;                         // mm_interconnect_0:sys_nios_data_master_waitrequest -> sys_nios:d_waitrequest
	wire  [31:0] sys_nios_data_master_writedata;                           // sys_nios:d_writedata -> mm_interconnect_0:sys_nios_data_master_writedata
	wire  [15:0] sys_nios_data_master_address;                             // sys_nios:d_address -> mm_interconnect_0:sys_nios_data_master_address
	wire         sys_nios_data_master_write;                               // sys_nios:d_write -> mm_interconnect_0:sys_nios_data_master_write
	wire         sys_nios_data_master_read;                                // sys_nios:d_read -> mm_interconnect_0:sys_nios_data_master_read
	wire  [31:0] sys_nios_data_master_readdata;                            // mm_interconnect_0:sys_nios_data_master_readdata -> sys_nios:d_readdata
	wire         sys_nios_data_master_debugaccess;                         // sys_nios:jtag_debug_module_debugaccess_to_roms -> mm_interconnect_0:sys_nios_data_master_debugaccess
	wire   [3:0] sys_nios_data_master_byteenable;                          // sys_nios:d_byteenable -> mm_interconnect_0:sys_nios_data_master_byteenable
	wire  [15:0] mm_interconnect_0_uart0_s1_writedata;                     // mm_interconnect_0:uart0_s1_writedata -> uart0:writedata
	wire   [2:0] mm_interconnect_0_uart0_s1_address;                       // mm_interconnect_0:uart0_s1_address -> uart0:address
	wire         mm_interconnect_0_uart0_s1_chipselect;                    // mm_interconnect_0:uart0_s1_chipselect -> uart0:chipselect
	wire         mm_interconnect_0_uart0_s1_write;                         // mm_interconnect_0:uart0_s1_write -> uart0:write_n
	wire         mm_interconnect_0_uart0_s1_read;                          // mm_interconnect_0:uart0_s1_read -> uart0:read_n
	wire  [15:0] mm_interconnect_0_uart0_s1_readdata;                      // uart0:readdata -> mm_interconnect_0:uart0_s1_readdata
	wire         mm_interconnect_0_uart0_s1_begintransfer;                 // mm_interconnect_0:uart0_s1_begintransfer -> uart0:begintransfer
	wire  [31:0] mm_interconnect_0_gpio1_s1_writedata;                     // mm_interconnect_0:gpio1_s1_writedata -> gpio1:writedata
	wire   [2:0] mm_interconnect_0_gpio1_s1_address;                       // mm_interconnect_0:gpio1_s1_address -> gpio1:address
	wire         mm_interconnect_0_gpio1_s1_chipselect;                    // mm_interconnect_0:gpio1_s1_chipselect -> gpio1:chipselect
	wire         mm_interconnect_0_gpio1_s1_write;                         // mm_interconnect_0:gpio1_s1_write -> gpio1:write_n
	wire  [31:0] mm_interconnect_0_gpio1_s1_readdata;                      // gpio1:readdata -> mm_interconnect_0:gpio1_s1_readdata
	wire         sys_nios_instruction_master_waitrequest;                  // mm_interconnect_0:sys_nios_instruction_master_waitrequest -> sys_nios:i_waitrequest
	wire  [15:0] sys_nios_instruction_master_address;                      // sys_nios:i_address -> mm_interconnect_0:sys_nios_instruction_master_address
	wire         sys_nios_instruction_master_read;                         // sys_nios:i_read -> mm_interconnect_0:sys_nios_instruction_master_read
	wire  [31:0] sys_nios_instruction_master_readdata;                     // mm_interconnect_0:sys_nios_instruction_master_readdata -> sys_nios:i_readdata
	wire         sys_nios_instruction_master_readdatavalid;                // mm_interconnect_0:sys_nios_instruction_master_readdatavalid -> sys_nios:i_readdatavalid
	wire   [0:0] mm_interconnect_0_sysid_control_slave_address;            // mm_interconnect_0:sysid_control_slave_address -> sysid:address
	wire  [31:0] mm_interconnect_0_sysid_control_slave_readdata;           // sysid:readdata -> mm_interconnect_0:sysid_control_slave_readdata
	wire         irq_mapper_receiver0_irq;                                 // sys_timer:irq -> irq_mapper:receiver0_irq
	wire         irq_mapper_receiver1_irq;                                 // uart0:irq -> irq_mapper:receiver1_irq
	wire  [31:0] sys_nios_d_irq_irq;                                       // irq_mapper:sender_irq -> sys_nios:d_irq
	wire         rst_controller_reset_out_reset;                           // rst_controller:reset_out -> [irq_mapper:reset, mm_interconnect_0:sys_nios_reset_n_reset_bridge_in_reset_reset, ram:reset, rom:reset, sys_nios:reset_n]
	wire         rst_controller_reset_out_reset_req;                       // rst_controller:reset_req -> [ram:reset_req, rom:reset_req, rst_translator:reset_req_in, sys_nios:reset_req]
	wire         sys_nios_jtag_debug_module_reset_reset;                   // sys_nios:jtag_debug_module_resetrequest -> rst_controller:reset_in1
	wire         rst_controller_001_reset_out_reset;                       // rst_controller_001:reset_out -> [gpio1:reset_n, led:reset_n, mm_interconnect_0:led_reset_reset_bridge_in_reset_reset, sys_timer:reset_n, sysid:reset_n, uart0:reset_n]

	palt_nios_sys_nios sys_nios (
		.clk                                   (clk_clk),                                                  //                       clk.clk
		.reset_n                               (~rst_controller_reset_out_reset),                          //                   reset_n.reset_n
		.reset_req                             (rst_controller_reset_out_reset_req),                       //                          .reset_req
		.d_address                             (sys_nios_data_master_address),                             //               data_master.address
		.d_byteenable                          (sys_nios_data_master_byteenable),                          //                          .byteenable
		.d_read                                (sys_nios_data_master_read),                                //                          .read
		.d_readdata                            (sys_nios_data_master_readdata),                            //                          .readdata
		.d_waitrequest                         (sys_nios_data_master_waitrequest),                         //                          .waitrequest
		.d_write                               (sys_nios_data_master_write),                               //                          .write
		.d_writedata                           (sys_nios_data_master_writedata),                           //                          .writedata
		.jtag_debug_module_debugaccess_to_roms (sys_nios_data_master_debugaccess),                         //                          .debugaccess
		.i_address                             (sys_nios_instruction_master_address),                      //        instruction_master.address
		.i_read                                (sys_nios_instruction_master_read),                         //                          .read
		.i_readdata                            (sys_nios_instruction_master_readdata),                     //                          .readdata
		.i_waitrequest                         (sys_nios_instruction_master_waitrequest),                  //                          .waitrequest
		.i_readdatavalid                       (sys_nios_instruction_master_readdatavalid),                //                          .readdatavalid
		.d_irq                                 (sys_nios_d_irq_irq),                                       //                     d_irq.irq
		.jtag_debug_module_resetrequest        (sys_nios_jtag_debug_module_reset_reset),                   //   jtag_debug_module_reset.reset
		.jtag_debug_module_address             (mm_interconnect_0_sys_nios_jtag_debug_module_address),     //         jtag_debug_module.address
		.jtag_debug_module_byteenable          (mm_interconnect_0_sys_nios_jtag_debug_module_byteenable),  //                          .byteenable
		.jtag_debug_module_debugaccess         (mm_interconnect_0_sys_nios_jtag_debug_module_debugaccess), //                          .debugaccess
		.jtag_debug_module_read                (mm_interconnect_0_sys_nios_jtag_debug_module_read),        //                          .read
		.jtag_debug_module_readdata            (mm_interconnect_0_sys_nios_jtag_debug_module_readdata),    //                          .readdata
		.jtag_debug_module_waitrequest         (mm_interconnect_0_sys_nios_jtag_debug_module_waitrequest), //                          .waitrequest
		.jtag_debug_module_write               (mm_interconnect_0_sys_nios_jtag_debug_module_write),       //                          .write
		.jtag_debug_module_writedata           (mm_interconnect_0_sys_nios_jtag_debug_module_writedata),   //                          .writedata
		.no_ci_readra                          ()                                                          // custom_instruction_master.readra
	);

	palt_nios_rom rom (
		.clk         (clk_clk),                              //   clk1.clk
		.address     (mm_interconnect_0_rom_s1_address),     //     s1.address
		.debugaccess (mm_interconnect_0_rom_s1_debugaccess), //       .debugaccess
		.clken       (mm_interconnect_0_rom_s1_clken),       //       .clken
		.chipselect  (mm_interconnect_0_rom_s1_chipselect),  //       .chipselect
		.write       (mm_interconnect_0_rom_s1_write),       //       .write
		.readdata    (mm_interconnect_0_rom_s1_readdata),    //       .readdata
		.writedata   (mm_interconnect_0_rom_s1_writedata),   //       .writedata
		.byteenable  (mm_interconnect_0_rom_s1_byteenable),  //       .byteenable
		.reset       (rst_controller_reset_out_reset),       // reset1.reset
		.reset_req   (rst_controller_reset_out_reset_req)    //       .reset_req
	);

	palt_nios_ram ram (
		.clk        (clk_clk),                             //   clk1.clk
		.address    (mm_interconnect_0_ram_s1_address),    //     s1.address
		.clken      (mm_interconnect_0_ram_s1_clken),      //       .clken
		.chipselect (mm_interconnect_0_ram_s1_chipselect), //       .chipselect
		.write      (mm_interconnect_0_ram_s1_write),      //       .write
		.readdata   (mm_interconnect_0_ram_s1_readdata),   //       .readdata
		.writedata  (mm_interconnect_0_ram_s1_writedata),  //       .writedata
		.byteenable (mm_interconnect_0_ram_s1_byteenable), //       .byteenable
		.reset      (rst_controller_reset_out_reset),      // reset1.reset
		.reset_req  (rst_controller_reset_out_reset_req)   //       .reset_req
	);

	palt_nios_led led (
		.clk        (clk_clk),                             //                 clk.clk
		.reset_n    (~rst_controller_001_reset_out_reset), //               reset.reset_n
		.address    (mm_interconnect_0_led_s1_address),    //                  s1.address
		.write_n    (~mm_interconnect_0_led_s1_write),     //                    .write_n
		.writedata  (mm_interconnect_0_led_s1_writedata),  //                    .writedata
		.chipselect (mm_interconnect_0_led_s1_chipselect), //                    .chipselect
		.readdata   (mm_interconnect_0_led_s1_readdata),   //                    .readdata
		.out_port   (led_export)                           // external_connection.export
	);

	palt_nios_sys_timer sys_timer (
		.clk        (clk_clk),                                   //   clk.clk
		.reset_n    (~rst_controller_001_reset_out_reset),       // reset.reset_n
		.address    (mm_interconnect_0_sys_timer_s1_address),    //    s1.address
		.writedata  (mm_interconnect_0_sys_timer_s1_writedata),  //      .writedata
		.readdata   (mm_interconnect_0_sys_timer_s1_readdata),   //      .readdata
		.chipselect (mm_interconnect_0_sys_timer_s1_chipselect), //      .chipselect
		.write_n    (~mm_interconnect_0_sys_timer_s1_write),     //      .write_n
		.irq        (irq_mapper_receiver0_irq)                   //   irq.irq
	);

	palt_nios_sysid sysid (
		.clock    (clk_clk),                                        //           clk.clk
		.reset_n  (~rst_controller_001_reset_out_reset),            //         reset.reset_n
		.readdata (mm_interconnect_0_sysid_control_slave_readdata), // control_slave.readdata
		.address  (mm_interconnect_0_sysid_control_slave_address)   //              .address
	);

	palt_nios_uart0 uart0 (
		.clk           (clk_clk),                                  //                 clk.clk
		.reset_n       (~rst_controller_001_reset_out_reset),      //               reset.reset_n
		.address       (mm_interconnect_0_uart0_s1_address),       //                  s1.address
		.begintransfer (mm_interconnect_0_uart0_s1_begintransfer), //                    .begintransfer
		.chipselect    (mm_interconnect_0_uart0_s1_chipselect),    //                    .chipselect
		.read_n        (~mm_interconnect_0_uart0_s1_read),         //                    .read_n
		.write_n       (~mm_interconnect_0_uart0_s1_write),        //                    .write_n
		.writedata     (mm_interconnect_0_uart0_s1_writedata),     //                    .writedata
		.readdata      (mm_interconnect_0_uart0_s1_readdata),      //                    .readdata
		.dataavailable (),                                         //                    .dataavailable
		.readyfordata  (),                                         //                    .readyfordata
		.rxd           (uart_rxd),                                 // external_connection.export
		.txd           (uart_txd),                                 //                    .export
		.irq           (irq_mapper_receiver1_irq)                  //                 irq.irq
	);

	palt_nios_gpio1 gpio1 (
		.clk        (clk_clk),                               //                 clk.clk
		.reset_n    (~rst_controller_001_reset_out_reset),   //               reset.reset_n
		.address    (mm_interconnect_0_gpio1_s1_address),    //                  s1.address
		.write_n    (~mm_interconnect_0_gpio1_s1_write),     //                    .write_n
		.writedata  (mm_interconnect_0_gpio1_s1_writedata),  //                    .writedata
		.chipselect (mm_interconnect_0_gpio1_s1_chipselect), //                    .chipselect
		.readdata   (mm_interconnect_0_gpio1_s1_readdata),   //                    .readdata
		.out_port   (gpio1_export)                           // external_connection.export
	);

	palt_nios_mm_interconnect_0 mm_interconnect_0 (
		.clk_0_clk_clk                                (clk_clk),                                                  //                              clk_0_clk.clk
		.led_reset_reset_bridge_in_reset_reset        (rst_controller_001_reset_out_reset),                       //        led_reset_reset_bridge_in_reset.reset
		.sys_nios_reset_n_reset_bridge_in_reset_reset (rst_controller_reset_out_reset),                           // sys_nios_reset_n_reset_bridge_in_reset.reset
		.sys_nios_data_master_address                 (sys_nios_data_master_address),                             //                   sys_nios_data_master.address
		.sys_nios_data_master_waitrequest             (sys_nios_data_master_waitrequest),                         //                                       .waitrequest
		.sys_nios_data_master_byteenable              (sys_nios_data_master_byteenable),                          //                                       .byteenable
		.sys_nios_data_master_read                    (sys_nios_data_master_read),                                //                                       .read
		.sys_nios_data_master_readdata                (sys_nios_data_master_readdata),                            //                                       .readdata
		.sys_nios_data_master_write                   (sys_nios_data_master_write),                               //                                       .write
		.sys_nios_data_master_writedata               (sys_nios_data_master_writedata),                           //                                       .writedata
		.sys_nios_data_master_debugaccess             (sys_nios_data_master_debugaccess),                         //                                       .debugaccess
		.sys_nios_instruction_master_address          (sys_nios_instruction_master_address),                      //            sys_nios_instruction_master.address
		.sys_nios_instruction_master_waitrequest      (sys_nios_instruction_master_waitrequest),                  //                                       .waitrequest
		.sys_nios_instruction_master_read             (sys_nios_instruction_master_read),                         //                                       .read
		.sys_nios_instruction_master_readdata         (sys_nios_instruction_master_readdata),                     //                                       .readdata
		.sys_nios_instruction_master_readdatavalid    (sys_nios_instruction_master_readdatavalid),                //                                       .readdatavalid
		.gpio1_s1_address                             (mm_interconnect_0_gpio1_s1_address),                       //                               gpio1_s1.address
		.gpio1_s1_write                               (mm_interconnect_0_gpio1_s1_write),                         //                                       .write
		.gpio1_s1_readdata                            (mm_interconnect_0_gpio1_s1_readdata),                      //                                       .readdata
		.gpio1_s1_writedata                           (mm_interconnect_0_gpio1_s1_writedata),                     //                                       .writedata
		.gpio1_s1_chipselect                          (mm_interconnect_0_gpio1_s1_chipselect),                    //                                       .chipselect
		.led_s1_address                               (mm_interconnect_0_led_s1_address),                         //                                 led_s1.address
		.led_s1_write                                 (mm_interconnect_0_led_s1_write),                           //                                       .write
		.led_s1_readdata                              (mm_interconnect_0_led_s1_readdata),                        //                                       .readdata
		.led_s1_writedata                             (mm_interconnect_0_led_s1_writedata),                       //                                       .writedata
		.led_s1_chipselect                            (mm_interconnect_0_led_s1_chipselect),                      //                                       .chipselect
		.ram_s1_address                               (mm_interconnect_0_ram_s1_address),                         //                                 ram_s1.address
		.ram_s1_write                                 (mm_interconnect_0_ram_s1_write),                           //                                       .write
		.ram_s1_readdata                              (mm_interconnect_0_ram_s1_readdata),                        //                                       .readdata
		.ram_s1_writedata                             (mm_interconnect_0_ram_s1_writedata),                       //                                       .writedata
		.ram_s1_byteenable                            (mm_interconnect_0_ram_s1_byteenable),                      //                                       .byteenable
		.ram_s1_chipselect                            (mm_interconnect_0_ram_s1_chipselect),                      //                                       .chipselect
		.ram_s1_clken                                 (mm_interconnect_0_ram_s1_clken),                           //                                       .clken
		.rom_s1_address                               (mm_interconnect_0_rom_s1_address),                         //                                 rom_s1.address
		.rom_s1_write                                 (mm_interconnect_0_rom_s1_write),                           //                                       .write
		.rom_s1_readdata                              (mm_interconnect_0_rom_s1_readdata),                        //                                       .readdata
		.rom_s1_writedata                             (mm_interconnect_0_rom_s1_writedata),                       //                                       .writedata
		.rom_s1_byteenable                            (mm_interconnect_0_rom_s1_byteenable),                      //                                       .byteenable
		.rom_s1_chipselect                            (mm_interconnect_0_rom_s1_chipselect),                      //                                       .chipselect
		.rom_s1_clken                                 (mm_interconnect_0_rom_s1_clken),                           //                                       .clken
		.rom_s1_debugaccess                           (mm_interconnect_0_rom_s1_debugaccess),                     //                                       .debugaccess
		.sys_nios_jtag_debug_module_address           (mm_interconnect_0_sys_nios_jtag_debug_module_address),     //             sys_nios_jtag_debug_module.address
		.sys_nios_jtag_debug_module_write             (mm_interconnect_0_sys_nios_jtag_debug_module_write),       //                                       .write
		.sys_nios_jtag_debug_module_read              (mm_interconnect_0_sys_nios_jtag_debug_module_read),        //                                       .read
		.sys_nios_jtag_debug_module_readdata          (mm_interconnect_0_sys_nios_jtag_debug_module_readdata),    //                                       .readdata
		.sys_nios_jtag_debug_module_writedata         (mm_interconnect_0_sys_nios_jtag_debug_module_writedata),   //                                       .writedata
		.sys_nios_jtag_debug_module_byteenable        (mm_interconnect_0_sys_nios_jtag_debug_module_byteenable),  //                                       .byteenable
		.sys_nios_jtag_debug_module_waitrequest       (mm_interconnect_0_sys_nios_jtag_debug_module_waitrequest), //                                       .waitrequest
		.sys_nios_jtag_debug_module_debugaccess       (mm_interconnect_0_sys_nios_jtag_debug_module_debugaccess), //                                       .debugaccess
		.sys_timer_s1_address                         (mm_interconnect_0_sys_timer_s1_address),                   //                           sys_timer_s1.address
		.sys_timer_s1_write                           (mm_interconnect_0_sys_timer_s1_write),                     //                                       .write
		.sys_timer_s1_readdata                        (mm_interconnect_0_sys_timer_s1_readdata),                  //                                       .readdata
		.sys_timer_s1_writedata                       (mm_interconnect_0_sys_timer_s1_writedata),                 //                                       .writedata
		.sys_timer_s1_chipselect                      (mm_interconnect_0_sys_timer_s1_chipselect),                //                                       .chipselect
		.sysid_control_slave_address                  (mm_interconnect_0_sysid_control_slave_address),            //                    sysid_control_slave.address
		.sysid_control_slave_readdata                 (mm_interconnect_0_sysid_control_slave_readdata),           //                                       .readdata
		.uart0_s1_address                             (mm_interconnect_0_uart0_s1_address),                       //                               uart0_s1.address
		.uart0_s1_write                               (mm_interconnect_0_uart0_s1_write),                         //                                       .write
		.uart0_s1_read                                (mm_interconnect_0_uart0_s1_read),                          //                                       .read
		.uart0_s1_readdata                            (mm_interconnect_0_uart0_s1_readdata),                      //                                       .readdata
		.uart0_s1_writedata                           (mm_interconnect_0_uart0_s1_writedata),                     //                                       .writedata
		.uart0_s1_begintransfer                       (mm_interconnect_0_uart0_s1_begintransfer),                 //                                       .begintransfer
		.uart0_s1_chipselect                          (mm_interconnect_0_uart0_s1_chipselect)                     //                                       .chipselect
	);

	palt_nios_irq_mapper irq_mapper (
		.clk           (clk_clk),                        //       clk.clk
		.reset         (rst_controller_reset_out_reset), // clk_reset.reset
		.receiver0_irq (irq_mapper_receiver0_irq),       // receiver0.irq
		.receiver1_irq (irq_mapper_receiver1_irq),       // receiver1.irq
		.sender_irq    (sys_nios_d_irq_irq)              //    sender.irq
	);

	altera_reset_controller #(
		.NUM_RESET_INPUTS          (2),
		.OUTPUT_RESET_SYNC_EDGES   ("deassert"),
		.SYNC_DEPTH                (2),
		.RESET_REQUEST_PRESENT     (1),
		.RESET_REQ_WAIT_TIME       (1),
		.MIN_RST_ASSERTION_TIME    (3),
		.RESET_REQ_EARLY_DSRT_TIME (1),
		.USE_RESET_REQUEST_IN0     (0),
		.USE_RESET_REQUEST_IN1     (0),
		.USE_RESET_REQUEST_IN2     (0),
		.USE_RESET_REQUEST_IN3     (0),
		.USE_RESET_REQUEST_IN4     (0),
		.USE_RESET_REQUEST_IN5     (0),
		.USE_RESET_REQUEST_IN6     (0),
		.USE_RESET_REQUEST_IN7     (0),
		.USE_RESET_REQUEST_IN8     (0),
		.USE_RESET_REQUEST_IN9     (0),
		.USE_RESET_REQUEST_IN10    (0),
		.USE_RESET_REQUEST_IN11    (0),
		.USE_RESET_REQUEST_IN12    (0),
		.USE_RESET_REQUEST_IN13    (0),
		.USE_RESET_REQUEST_IN14    (0),
		.USE_RESET_REQUEST_IN15    (0),
		.ADAPT_RESET_REQUEST       (0)
	) rst_controller (
		.reset_in0      (~rst_reset_n),                           // reset_in0.reset
		.reset_in1      (sys_nios_jtag_debug_module_reset_reset), // reset_in1.reset
		.clk            (clk_clk),                                //       clk.clk
		.reset_out      (rst_controller_reset_out_reset),         // reset_out.reset
		.reset_req      (rst_controller_reset_out_reset_req),     //          .reset_req
		.reset_req_in0  (1'b0),                                   // (terminated)
		.reset_req_in1  (1'b0),                                   // (terminated)
		.reset_in2      (1'b0),                                   // (terminated)
		.reset_req_in2  (1'b0),                                   // (terminated)
		.reset_in3      (1'b0),                                   // (terminated)
		.reset_req_in3  (1'b0),                                   // (terminated)
		.reset_in4      (1'b0),                                   // (terminated)
		.reset_req_in4  (1'b0),                                   // (terminated)
		.reset_in5      (1'b0),                                   // (terminated)
		.reset_req_in5  (1'b0),                                   // (terminated)
		.reset_in6      (1'b0),                                   // (terminated)
		.reset_req_in6  (1'b0),                                   // (terminated)
		.reset_in7      (1'b0),                                   // (terminated)
		.reset_req_in7  (1'b0),                                   // (terminated)
		.reset_in8      (1'b0),                                   // (terminated)
		.reset_req_in8  (1'b0),                                   // (terminated)
		.reset_in9      (1'b0),                                   // (terminated)
		.reset_req_in9  (1'b0),                                   // (terminated)
		.reset_in10     (1'b0),                                   // (terminated)
		.reset_req_in10 (1'b0),                                   // (terminated)
		.reset_in11     (1'b0),                                   // (terminated)
		.reset_req_in11 (1'b0),                                   // (terminated)
		.reset_in12     (1'b0),                                   // (terminated)
		.reset_req_in12 (1'b0),                                   // (terminated)
		.reset_in13     (1'b0),                                   // (terminated)
		.reset_req_in13 (1'b0),                                   // (terminated)
		.reset_in14     (1'b0),                                   // (terminated)
		.reset_req_in14 (1'b0),                                   // (terminated)
		.reset_in15     (1'b0),                                   // (terminated)
		.reset_req_in15 (1'b0)                                    // (terminated)
	);

	altera_reset_controller #(
		.NUM_RESET_INPUTS          (1),
		.OUTPUT_RESET_SYNC_EDGES   ("deassert"),
		.SYNC_DEPTH                (2),
		.RESET_REQUEST_PRESENT     (0),
		.RESET_REQ_WAIT_TIME       (1),
		.MIN_RST_ASSERTION_TIME    (3),
		.RESET_REQ_EARLY_DSRT_TIME (1),
		.USE_RESET_REQUEST_IN0     (0),
		.USE_RESET_REQUEST_IN1     (0),
		.USE_RESET_REQUEST_IN2     (0),
		.USE_RESET_REQUEST_IN3     (0),
		.USE_RESET_REQUEST_IN4     (0),
		.USE_RESET_REQUEST_IN5     (0),
		.USE_RESET_REQUEST_IN6     (0),
		.USE_RESET_REQUEST_IN7     (0),
		.USE_RESET_REQUEST_IN8     (0),
		.USE_RESET_REQUEST_IN9     (0),
		.USE_RESET_REQUEST_IN10    (0),
		.USE_RESET_REQUEST_IN11    (0),
		.USE_RESET_REQUEST_IN12    (0),
		.USE_RESET_REQUEST_IN13    (0),
		.USE_RESET_REQUEST_IN14    (0),
		.USE_RESET_REQUEST_IN15    (0),
		.ADAPT_RESET_REQUEST       (0)
	) rst_controller_001 (
		.reset_in0      (~rst_reset_n),                       // reset_in0.reset
		.clk            (clk_clk),                            //       clk.clk
		.reset_out      (rst_controller_001_reset_out_reset), // reset_out.reset
		.reset_req      (),                                   // (terminated)
		.reset_req_in0  (1'b0),                               // (terminated)
		.reset_in1      (1'b0),                               // (terminated)
		.reset_req_in1  (1'b0),                               // (terminated)
		.reset_in2      (1'b0),                               // (terminated)
		.reset_req_in2  (1'b0),                               // (terminated)
		.reset_in3      (1'b0),                               // (terminated)
		.reset_req_in3  (1'b0),                               // (terminated)
		.reset_in4      (1'b0),                               // (terminated)
		.reset_req_in4  (1'b0),                               // (terminated)
		.reset_in5      (1'b0),                               // (terminated)
		.reset_req_in5  (1'b0),                               // (terminated)
		.reset_in6      (1'b0),                               // (terminated)
		.reset_req_in6  (1'b0),                               // (terminated)
		.reset_in7      (1'b0),                               // (terminated)
		.reset_req_in7  (1'b0),                               // (terminated)
		.reset_in8      (1'b0),                               // (terminated)
		.reset_req_in8  (1'b0),                               // (terminated)
		.reset_in9      (1'b0),                               // (terminated)
		.reset_req_in9  (1'b0),                               // (terminated)
		.reset_in10     (1'b0),                               // (terminated)
		.reset_req_in10 (1'b0),                               // (terminated)
		.reset_in11     (1'b0),                               // (terminated)
		.reset_req_in11 (1'b0),                               // (terminated)
		.reset_in12     (1'b0),                               // (terminated)
		.reset_req_in12 (1'b0),                               // (terminated)
		.reset_in13     (1'b0),                               // (terminated)
		.reset_req_in13 (1'b0),                               // (terminated)
		.reset_in14     (1'b0),                               // (terminated)
		.reset_req_in14 (1'b0),                               // (terminated)
		.reset_in15     (1'b0),                               // (terminated)
		.reset_req_in15 (1'b0)                                // (terminated)
	);

endmodule
