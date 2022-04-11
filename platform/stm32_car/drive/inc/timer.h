#ifndef __TIMER_H
#define	__TIMER_H

#include "stm32f10x.h"
#include <stdio.h>

#define SYS_TIMER_BASE_MS 10
#define SYS_TIMER_INIT		99
#define MCU_TIME_BASE			7199

void tim3_init(u16 arr,u16 psc);
void tim3_nvic_init (void);

u16 get_tick_stamp(void);
u16 get_tim_delta(u16 oldTime, u16 nowTime);
void tim2_init(void);


#endif /* __TIMER_H */
