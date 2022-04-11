#include "sys_call.h"
#include "timer.h"
#include <stdarg.h>


static t_CYC_CALL_INFO m_cyc_func[CYC_CALL_FUNC_MAX];

_Bool cyc_call_cfg(u8 idx, u16 cycle, p_cycle_call_cb p_func)
{
	if ((idx >= CYC_CALL_FUNC_MAX)||(p_func == NULL) ) {
		return FALSE;
	}
	m_cyc_func[idx].is_open = FALSE;
	m_cyc_func[idx].last_mb_stamp = 0;
	m_cyc_func[idx].cycle_cnt = cycle;
	m_cyc_func[idx].p_cyc_call = p_func;
	m_cyc_func[idx].is_open = TRUE;
	return TRUE;
}

_Bool cyc_call_chk(t_CYC_CALL_INFO * p_cyc)
{
	if ( (p_cyc == NULL)||(p_cyc->p_cyc_call == NULL) ) {
		return FALSE;
	}
	if (get_tim_delta(p_cyc->last_mb_stamp, get_tick_stamp()) >= p_cyc->cycle_cnt){/*更改条件为大于等于*/
		p_cyc->last_mb_stamp = get_tick_stamp();
		if (p_cyc->is_open == TRUE){
			p_cyc->p_cyc_call();
		}
	}

	return TRUE;
}

void cyc_call_poll(void)
{
	u8 idx;
	for (idx = 0; idx < CYC_CALL_FUNC_MAX; idx++)
	{
		cyc_call_chk(&m_cyc_func[idx]);
	}
}

