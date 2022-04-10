/*
 * sys_timer.c
 *
 *  Created on: 2022-4-1
 *      Author: blion
 */

#include <unistd.h>
#include "system.h"
#include "../inc/sys_timer.h"
#include "altera_avalon_timer_regs.h"
#include "sys/alt_irq.h"



#include "alt_types.h"
alt_u32 g_timer_cnt = 0;

void system_timer_isr(void*context)
{
	g_timer_cnt ++;

	IOWR_ALTERA_AVALON_TIMER_STATUS(SYS_TIMER_BASE,0x00);
}

alt_u32 get_tick_stamp()
{
	return g_timer_cnt;
}

void timer_init()
{
	IOWR_ALTERA_AVALON_TIMER_STATUS(SYS_TIMER_BASE,0);	//清中断
	IOWR_ALTERA_AVALON_TIMER_PERIODL(SYS_TIMER_BASE,SYS_TIMER_LOAD_VALUE);
	IOWR_ALTERA_AVALON_TIMER_PERIODH(SYS_TIMER_BASE,SYS_TIMER_LOAD_VALUE >> 16);
	IOWR_ALTERA_AVALON_TIMER_CONTROL(SYS_TIMER_BASE,ALTERA_AVALON_TIMER_CONTROL_ITO_MSK |	//开中断
													ALTERA_AVALON_TIMER_CONTROL_CONT_MSK |  //循环模式
													ALTERA_AVALON_TIMER_CONTROL_START_MSK); //开定时器
	alt_ic_isr_register(SYS_TIMER_IRQ_INTERRUPT_CONTROLLER_ID,	//中断注册
						SYS_TIMER_IRQ,
						system_timer_isr,
						NULL,
						0x00);
}

alt_u32 get_tim_delta(alt_u32 oldTime, alt_u32 nowTime)
{
	alt_u32 timeDelta = 0;
	timeDelta = (nowTime >= oldTime )? (nowTime -oldTime):(nowTime + (0xffffffff - oldTime));
	return timeDelta;
}

void delay_ms(alt_u16 ms)
{
	alt_u32 time;
	alt_u32 diff;
	time = get_tick_stamp();

	do
	{
		diff = get_tim_delta(time,get_tick_stamp());
		usleep(10);
	}while(diff < ms);
}
