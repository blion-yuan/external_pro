#ifndef __UART1_H
#define	__UART1_H

#include "stm32f10x.h"
#include <stdio.h>

#define UART1_BRATE		9600
void uart1_cfg(u32 buad_rate);
int fputc(int ch, FILE *f);
void uart1_printf(USART_TypeDef* USARTx, uint8_t *Data,...);

#endif /* __USART1_H */
