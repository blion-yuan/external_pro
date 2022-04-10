/*
 * sys_call.h
 *
 *  Created on: 2022-4-1
 *      Author: blion
 */

#ifndef SYS_CALL_H_
#define SYS_CALL_H_

#include "alt_types.h"
#include <stdbool.h>


#define CYC_CALL_FUNC_MAX		(6)

#define CYC_CALL_CHNNL_0		(0)
#define CYC_CALL_CHNNL_1		(1)
#define CYC_CALL_CHNNL_2		(2)
#define CYC_CALL_CHNNL_3		(3)
#define CYC_CALL_CHNNL_4		(4)

#define CALL_POLL_5MS		2/SYS_TIMEER_BASE_MS
#define CALL_POLL_10MS		10/SYS_TIMEER_BASE_MS
#define CALL_POLL_20MS		20/SYS_TIMEER_BASE_MS
#define CALL_POLL_100MS		100/SYS_TIMEER_BASE_MS
#define CALL_POLL_200MS		200/SYS_TIMEER_BASE_MS
#define CALL_POLL_500MS		500/SYS_TIMEER_BASE_MS
#define CALL_POLL_1S		1000/SYS_TIMEER_BASE_MS

typedef void (* p_cycle_call_cb)(void);

typedef struct _CYC_CALL_INFO
{
	bool is_open;
	alt_u32 cycle_cnt;
	volatile alt_u32 last_mb_stamp;
	p_cycle_call_cb p_cyc_call;
}t_CYC_CALL_INFO;


bool cyc_call_cfg(alt_u8 idx, alt_u32 cycle, p_cycle_call_cb p_func);
void cyc_call_poll(void);

#endif /* SYS_CALL_H_ */
