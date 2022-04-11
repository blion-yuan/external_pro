#include "gpio_led.h"
#include <stdarg.h>

void gpio_led_init()
{
	GPIO_InitTypeDef  GPIO_InitStructure;
	
	RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOC, ENABLE);	    //使能PC端口时钟
  GPIO_InitStructure.GPIO_Pin = GPIO_Pin_13;			    //LED0-->PC.13 端口配置
  GPIO_InitStructure.GPIO_Mode = GPIO_Mode_Out_PP; 	 //推挽输出
  GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;	 //IO口速度为50MHz
  GPIO_Init(GPIOC, &GPIO_InitStructure);			     //初始化GPIOC.13
  GPIO_SetBits(GPIOC,GPIO_Pin_13);					
	
}

void car_num_init()
{
	GPIO_InitTypeDef  GPIO_InitStructure;
	
	RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOC, ENABLE);	    //使能PC端口时钟
  GPIO_InitStructure.GPIO_Pin =   GPIO_Pin_14;     //返回电平引脚 PA4
    GPIO_InitStructure.GPIO_Mode = GPIO_Mode_IPD;//浮空输入
    GPIO_Init(GPIOC, &GPIO_InitStructure);
    GPIO_ResetBits(GPIOC, GPIO_Pin_14);
}

void us015_init(void)
{
	GPIO_InitTypeDef GPIO_InitStructure;
	RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOB, ENABLE);
	//IO初始化
    GPIO_InitStructure.GPIO_Pin = US015_TRIG;      //发送电平引脚 PB7
    GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
    GPIO_InitStructure.GPIO_Mode = GPIO_Mode_Out_PP;//推挽输出
    GPIO_Init(US015_PORT, &GPIO_InitStructure);
    GPIO_ResetBits(US015_PORT, US015_TRIG);

    GPIO_InitStructure.GPIO_Pin =   US015_ECHO;     //返回电平引脚 PA12
    GPIO_InitStructure.GPIO_Mode = GPIO_Mode_IN_FLOATING;//浮空输入
    GPIO_Init(US015_PORT, &GPIO_InitStructure);
    GPIO_ResetBits(US015_PORT, US015_ECHO);
}

