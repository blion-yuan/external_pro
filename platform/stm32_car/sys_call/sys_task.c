#include "sys_task.h"
#include "gpio_led.h"
#include "uart1.h"
#include "delay.h"
#include "timer.h"

extern u32 g_tim2_overcnt;
u8 send_tab[4]={0x69,0x05,0x00,0x7f};
u8 dis_dta;
void led_polling(void)
{
		static u8 led = 0;
		if(led == 0)
		{
			LED_SET_HIGN;
			led = 1;
		}
		else 
		{
			led = 0;
			LED_SET_LOW;
		}
		
		if(GPIO_ReadInputDataBit(GPIOC,GPIO_Pin_14)==SET)
		{
			send_tab[1] = 0x07;
		}
		else
		{
			send_tab[1] = 0x05;
		}
}


void uart_polling(void)
{
	static u8 i;
	USART_SendData(USART1,send_tab[i]);
	i++;
	if(i == 4)
		i =0;
	
//		u8 i;
//	for(i=0; i<4;i++)
//	{
//		USART_SendData(USART1,send_tab[i]);		//单位
//		delay_ms(10);
//	}
}


void cap_polling(void)
{
		static u8 i;
		static float len_sum;
		float length=0;	
	  u16 tim2_cnt;
		
		TRIG_Send=1; //拉高信号，作为触发信号
		delay_us(20); //高电平信号超过10us
		TRIG_Send=0;
		/*等待回响信号*/
		while(ECHO_Reci==RESET);
		TIM_Cmd(TIM2,ENABLE);//回响信号到来，开启定时器计数
		TIM_SetCounter(TIM2,0);
			
		while(ECHO_Reci==SET);//回响信号消失
		TIM_Cmd(TIM2,DISABLE);//关闭定时器
		tim2_cnt=TIM_GetCounter(TIM2);//获取计TIM2数寄存器中的计数值，一边计算回响信号时间
		length=(tim2_cnt+g_tim2_overcnt*1000)/58.0;//通过回响信号计算距离

		len_sum=length+len_sum;
		TIM2->CNT=0; //将TIM2计数寄存器的计数值清零
		g_tim2_overcnt=0; //中断溢出次数清零
		
		i+=1; //每收到一次回响信号+1，收到5次就计算均值
		if(i == 5)
		{
			i = 0;
			length=len_sum/5;
			len_sum = 0.0f;
//			printf("lenth is %f",length);
			send_tab[2] = (u8)(length / 100);
		}
}
