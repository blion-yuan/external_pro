/*
 * uart.c
 *
 *  Created on: 2022-4-1
 *      Author: blion
 */

#include <unistd.h>
#include "../inc/uart.h"
#include "altera_avalon_uart_regs.h"
#include "altera_avalon_pio_regs.h"
#include "sys/alt_irq.h"
#include <stdbool.h>
#include <unistd.h>


extern alt_u8 g_rx_num;
extern bool g_rx_bit;
extern alt_u8 rx_table[4];
alt_u8 g_rx_data;
void uart0_isr(void*context)
{
	alt_u16 rx_sta;
//	alt_u8 rx_data;

	rx_sta = IORD_ALTERA_AVALON_UART_STATUS(UART0_BASE);
	if(rx_sta & ALTERA_AVALON_UART_STATUS_RRDY_MSK)
	{
		g_rx_bit = 0;
		g_rx_data = IORD_ALTERA_AVALON_UART_RXDATA(UART0_BASE);
//		rx_table[g_rx_num]=rx_data;
//		g_rx_num ++;
//		if(g_rx_num == 4)
//			g_rx_num =0;
	}
	IOWR_ALTERA_AVALON_UART_STATUS(UART0_BASE,0);
}


void uart0_init()
{
	IOWR_ALTERA_AVALON_UART_STATUS(UART0_BASE,0);	//清状态
	IOWR_ALTERA_AVALON_UART_CONTROL(UART0_BASE,0); //清中断
	IOWR_ALTERA_AVALON_UART_CONTROL(UART0_BASE,ALTERA_AVALON_UART_CONTROL_RRDY_MSK); //开接收中断
	IOWR_ALTERA_AVALON_UART_DIVISOR(UART0_BASE,UART0_FREQ/(UART0_BAUD + 1));
	alt_ic_isr_register(UART0_IRQ_INTERRUPT_CONTROLLER_ID, //中断注册
						UART0_IRQ,
						uart0_isr,
						NULL,
						0x0);
}



