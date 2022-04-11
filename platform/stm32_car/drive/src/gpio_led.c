#include "gpio_led.h"
#include <stdarg.h>

void gpio_led_init()
{
	GPIO_InitTypeDef  GPIO_InitStructure;
	
	RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOC, ENABLE);	    //ʹ��PC�˿�ʱ��
  GPIO_InitStructure.GPIO_Pin = GPIO_Pin_13;			    //LED0-->PC.13 �˿�����
  GPIO_InitStructure.GPIO_Mode = GPIO_Mode_Out_PP; 	 //�������
  GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;	 //IO���ٶ�Ϊ50MHz
  GPIO_Init(GPIOC, &GPIO_InitStructure);			     //��ʼ��GPIOC.13
  GPIO_SetBits(GPIOC,GPIO_Pin_13);					
	
}

void car_num_init()
{
	GPIO_InitTypeDef  GPIO_InitStructure;
	
	RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOC, ENABLE);	    //ʹ��PC�˿�ʱ��
  GPIO_InitStructure.GPIO_Pin =   GPIO_Pin_14;     //���ص�ƽ���� PA4
    GPIO_InitStructure.GPIO_Mode = GPIO_Mode_IPD;//��������
    GPIO_Init(GPIOC, &GPIO_InitStructure);
    GPIO_ResetBits(GPIOC, GPIO_Pin_14);
}

void us015_init(void)
{
	GPIO_InitTypeDef GPIO_InitStructure;
	RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOB, ENABLE);
	//IO��ʼ��
    GPIO_InitStructure.GPIO_Pin = US015_TRIG;      //���͵�ƽ���� PB7
    GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
    GPIO_InitStructure.GPIO_Mode = GPIO_Mode_Out_PP;//�������
    GPIO_Init(US015_PORT, &GPIO_InitStructure);
    GPIO_ResetBits(US015_PORT, US015_TRIG);

    GPIO_InitStructure.GPIO_Pin =   US015_ECHO;     //���ص�ƽ���� PA12
    GPIO_InitStructure.GPIO_Mode = GPIO_Mode_IN_FLOATING;//��������
    GPIO_Init(US015_PORT, &GPIO_InitStructure);
    GPIO_ResetBits(US015_PORT, US015_ECHO);
}

