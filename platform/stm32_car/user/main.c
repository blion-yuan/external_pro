#include "stm32f10x.h"
#include "uart1.h"
#include "gpio_led.h"
#include "timer.h"
#include "sys.h"
#include "delay.h"

#include "sys_call.h"
#include "sys_task.h"
#include "vl53l0x.h"


 int main(void)
 {	
	 RCC_Configuration();
	 delay_init();
	 gpio_led_init();
	 car_num_init();
	 NVIC_PriorityGroupConfig(NVIC_PriorityGroup_2);  //中断优先级分组 分2组
	 uart1_cfg(UART1_BRATE);
	 us015_init();
	 tim2_init();
	 tim3_init(SYS_TIMER_INIT,MCU_TIME_BASE);
  
	 cyc_call_cfg(CYC_CALL_CHNNL_0, CALL_POLL_1S, led_polling);  
   cyc_call_cfg(CYC_CALL_CHNNL_1, CALL_POLL_500MS, uart_polling);
	 cyc_call_cfg(CYC_CALL_CHNNL_2, CALL_POLL_100MS, cap_polling);
	 
  while(1)
	{
		cyc_call_poll();
	}
 }
