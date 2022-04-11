#ifndef __SYS_CALL_H
#define	__SYS_CALL_H

#include "stm32f10x.h"
#include <stdio.h>


#define CYC_CALL_FUNC_MAX		(3)

#define CYC_CALL_CHNNL_0		(0)
#define CYC_CALL_CHNNL_1		(1)
#define CYC_CALL_CHNNL_2		(2)

#define TRUE 1 // true
#define FALSE 0 // false

#define CALL_POLL_100MS		100/SYS_TIMER_BASE_MS
#define CALL_POLL_200MS		200/SYS_TIMER_BASE_MS
#define CALL_POLL_500MS		500/SYS_TIMER_BASE_MS
#define CALL_POLL_1S		1000/SYS_TIMER_BASE_MS

typedef void (* p_cycle_call_cb)(void);

typedef struct _CYC_CALL_INFO
{
	_Bool is_open;
	u16 cycle_cnt;
	volatile u16 last_mb_stamp;
	p_cycle_call_cb p_cyc_call;
}t_CYC_CALL_INFO;


_Bool cyc_call_cfg(u8 idx, u16 cycle, p_cycle_call_cb p_func);
void cyc_call_poll(void);


#endif /* __SYS_CALL_H */

