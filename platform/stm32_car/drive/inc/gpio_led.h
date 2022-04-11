#ifndef __GPIO_LED_H
#define	__GPIO_LED_H

#include "stm32f10x.h"
#include "system.h"

#include <stdio.h>

#define LED_SET_HIGN	GPIO_SetBits(GPIOC,GPIO_Pin_13)
#define LED_SET_LOW	GPIO_ResetBits(GPIOC,GPIO_Pin_13)

#define US015_PORT     GPIOB
#define US015_TRIG     GPIO_Pin_7
#define US015_ECHO     GPIO_Pin_8

#define TRIG_Send  PBout(7) 
#define ECHO_Reci  PBin(8)

void gpio_led_init(void);
void us015_init(void);
void car_num_init(void);
	
#endif /* __GPIO_LED_H */

