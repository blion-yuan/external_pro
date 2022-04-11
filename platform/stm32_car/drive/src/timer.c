#include "timer.h"
#include <stdarg.h>
#include "gpio_led.h"


//��ʱ��ʱ����㹫ʽTout = ((��װ��ֵ+1)*(Ԥ��Ƶϵ��+1))/ʱ��Ƶ��;
//���磺1�붨ʱ����װ��ֵ=9999��Ԥ��Ƶϵ��=7199

u16 g_timer_cnt = 0;
u32 g_tim2_overcnt = 0;

void tim3_init(u16 arr,u16 psc){  //TIM3 ��ʼ�� arr��װ��ֵ pscԤ��Ƶϵ��
    TIM_TimeBaseInitTypeDef     TIM_TimeBaseInitStrue;
    
    RCC_APB1PeriphClockCmd(RCC_APB1Periph_TIM3,ENABLE);//ʹ��TIM3
    tim3_nvic_init (); //����TIM3�ж�����
	      
    TIM_TimeBaseInitStrue.TIM_Period=arr; //�����Զ���װ��ֵ
    TIM_TimeBaseInitStrue.TIM_Prescaler=psc; //Ԥ��Ƶϵ��
    TIM_TimeBaseInitStrue.TIM_CounterMode=TIM_CounterMode_Up; //�������������
    TIM_TimeBaseInitStrue.TIM_ClockDivision=TIM_CKD_DIV1; //ʱ�ӵķ�Ƶ���ӣ�����һ������ʱ���ã�һ����ΪTIM_CKD_DIV1
    TIM_TimeBaseInit(TIM3,&TIM_TimeBaseInitStrue); //TIM3��ʼ������
    TIM_ITConfig(TIM3, TIM_IT_Update, ENABLE);//ʹ��TIM3�ж�    
    TIM_Cmd(TIM3,ENABLE); //ʹ��TIM3
}

void tim3_nvic_init (void){ //����TIM3�ж�����
	NVIC_InitTypeDef NVIC_InitStructure;
	NVIC_InitStructure.NVIC_IRQChannel = TIM3_IRQn;	
	NVIC_InitStructure.NVIC_IRQChannelPreemptionPriority = 0;	//��ռ���ȼ�0  
	NVIC_InitStructure.NVIC_IRQChannelSubPriority = 0x3;		//��ռ���ȼ�
	NVIC_InitStructure.NVIC_IRQChannelCmd = ENABLE;
	NVIC_Init(&NVIC_InitStructure);
}

u16 get_tick_stamp()
{
	return g_timer_cnt;
}

void TIM3_IRQHandler(void){ //TIM3�жϴ�����
    if (TIM_GetITStatus(TIM3, TIM_IT_Update) != RESET){	//�ж��Ƿ���TIM3�ж�
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
{  //TIM3 ��ʼ�� arr��װ��ֵ pscԤ��Ƶϵ��
    TIM_TimeBaseInitTypeDef     TIM_TimeBaseInitStrue;
    
    RCC_APB1PeriphClockCmd(RCC_APB1Periph_TIM2,ENABLE);//ʹ��TIM3
    
	      
    TIM_TimeBaseInitStrue.TIM_Period=999; //�����Զ���װ��ֵ
    TIM_TimeBaseInitStrue.TIM_Prescaler=71; //Ԥ��Ƶϵ��
    TIM_TimeBaseInitStrue.TIM_CounterMode=TIM_CounterMode_Up; //�������������
    TIM_TimeBaseInitStrue.TIM_ClockDivision=TIM_CKD_DIV1; //ʱ�ӵķ�Ƶ���ӣ�����һ������ʱ���ã�һ����ΪTIM_CKD_DIV1
    TIM_TimeBaseInit(TIM2,&TIM_TimeBaseInitStrue); //TIM3��ʼ������
    TIM_ITConfig(TIM2, TIM_IT_Update, ENABLE);//ʹ��TIM3�ж�    
		tim2_nvic_init(); //����TIM2�ж�����
    TIM_Cmd(TIM2,DISABLE); //ʹ��TIM3
}

void TIM2_IRQHandler(void) //�жϣ��������źźܳ��ǣ�����ֵ������ظ����������ж��������������
{
		if(TIM_GetITStatus(TIM2,TIM_IT_Update)!=RESET)
			{
		    
				TIM_ClearITPendingBit(TIM2,TIM_IT_Update);//����жϱ�־
		    g_tim2_overcnt++;

  }
}
