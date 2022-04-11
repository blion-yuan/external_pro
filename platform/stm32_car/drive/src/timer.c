#include "timer.h"
#include <stdarg.h>
#include "gpio_led.h"


//定时器时间计算公式Tout = ((重装载值+1)*(预分频系数+1))/时钟频率;
//例如：1秒定时，重装载值=9999，预分频系数=7199

u16 g_timer_cnt = 0;
u32 g_tim2_overcnt = 0;

void tim3_init(u16 arr,u16 psc){  //TIM3 初始化 arr重装载值 psc预分频系数
    TIM_TimeBaseInitTypeDef     TIM_TimeBaseInitStrue;
    
    RCC_APB1PeriphClockCmd(RCC_APB1Periph_TIM3,ENABLE);//使能TIM3
    tim3_nvic_init (); //开启TIM3中断向量
	      
    TIM_TimeBaseInitStrue.TIM_Period=arr; //设置自动重装载值
    TIM_TimeBaseInitStrue.TIM_Prescaler=psc; //预分频系数
    TIM_TimeBaseInitStrue.TIM_CounterMode=TIM_CounterMode_Up; //计数器向上溢出
    TIM_TimeBaseInitStrue.TIM_ClockDivision=TIM_CKD_DIV1; //时钟的分频因子，起到了一点点的延时作用，一般设为TIM_CKD_DIV1
    TIM_TimeBaseInit(TIM3,&TIM_TimeBaseInitStrue); //TIM3初始化设置
    TIM_ITConfig(TIM3, TIM_IT_Update, ENABLE);//使能TIM3中断    
    TIM_Cmd(TIM3,ENABLE); //使能TIM3
}

void tim3_nvic_init (void){ //开启TIM3中断向量
	NVIC_InitTypeDef NVIC_InitStructure;
	NVIC_InitStructure.NVIC_IRQChannel = TIM3_IRQn;	
	NVIC_InitStructure.NVIC_IRQChannelPreemptionPriority = 0;	//先占优先级0  
	NVIC_InitStructure.NVIC_IRQChannelSubPriority = 0x3;		//从占优先级
	NVIC_InitStructure.NVIC_IRQChannelCmd = ENABLE;
	NVIC_Init(&NVIC_InitStructure);
}

u16 get_tick_stamp()
{
	return g_timer_cnt;
}

void TIM3_IRQHandler(void){ //TIM3中断处理函数
    if (TIM_GetITStatus(TIM3, TIM_IT_Update) != RESET){	//判断是否是TIM3中断
        TIM_ClearITPendingBit(TIM3, TIM_IT_Update);
				g_timer_cnt ++;
    }
}

u16 get_tim_delta(u16 oldTime, u16 nowTime)
{
	u16 timeDelta = 0;
	timeDelta = (nowTime >= oldTime )? (nowTime -oldTime):(nowTime + (0xffff - oldTime));
	return timeDelta;
}

void tim2_nvic_init(void)
{
		NVIC_InitTypeDef NVIC_InitStructer;
	
		NVIC_InitStructer.NVIC_IRQChannel=TIM2_IRQn;
		NVIC_InitStructer.NVIC_IRQChannelPreemptionPriority=0;
		NVIC_InitStructer.NVIC_IRQChannelSubPriority=0;
		
		NVIC_InitStructer.NVIC_IRQChannelCmd=ENABLE;

		NVIC_Init(&NVIC_InitStructer);
}

void tim2_init()
{  //TIM3 初始化 arr重装载值 psc预分频系数
    TIM_TimeBaseInitTypeDef     TIM_TimeBaseInitStrue;
    
    RCC_APB1PeriphClockCmd(RCC_APB1Periph_TIM2,ENABLE);//使能TIM3
    
	      
    TIM_TimeBaseInitStrue.TIM_Period=999; //设置自动重装载值
    TIM_TimeBaseInitStrue.TIM_Prescaler=71; //预分频系数
    TIM_TimeBaseInitStrue.TIM_CounterMode=TIM_CounterMode_Up; //计数器向上溢出
    TIM_TimeBaseInitStrue.TIM_ClockDivision=TIM_CKD_DIV1; //时钟的分频因子，起到了一点点的延时作用，一般设为TIM_CKD_DIV1
    TIM_TimeBaseInit(TIM2,&TIM_TimeBaseInitStrue); //TIM3初始化设置
    TIM_ITConfig(TIM2, TIM_IT_Update, ENABLE);//使能TIM3中断    
		tim2_nvic_init(); //开启TIM2中断向量
    TIM_Cmd(TIM2,DISABLE); //使能TIM3
}

void TIM2_IRQHandler(void) //中断，当回响信号很长是，计数值溢出后重复计数，用中断来保存溢出次数
{
		if(TIM_GetITStatus(TIM2,TIM_IT_Update)!=RESET)
			{
		    
				TIM_ClearITPendingBit(TIM2,TIM_IT_Update);//清除中断标志
		    g_tim2_overcnt++;

  }
}
