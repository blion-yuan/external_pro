/*
 * sys_timer.h
 *
 *  Created on: 2022-4-1
 *      Author: blion
 */

#ifndef SYS_TIMER_H_
#define SYS_TIMER_H_

#include "alt_types.h"

#define SYS_TIMEER_BASE_MS 1

void system_timer_isr(void*context);
void timer_init(void);
alt_u32 get_tick_stamp(void);
alt_u32 get_tim_delta(alt_u32 oldTime, alt_u32 nowTime);

#endif /* SYS_TIMER_H_ */
