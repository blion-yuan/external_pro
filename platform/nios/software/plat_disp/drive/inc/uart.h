/*
 * uart.h
 *
 *  Created on: 2022-4-1
 *      Author: blion
 */

#ifndef UART_H_
#define UART_H_

#include "system.h"
#include "alt_types.h"

#define SEND_CMD	1
#define SEND_DATA	0

void uart0_isr(void*context);
void uart0_init(void);
void uart1_init(void);
void uart1_isr(void*context);

void oled_init(void);
void oled_fill(alt_u8 fill_Data);//È«ÆÁÌî³ä


#endif /* UART_H_ */
