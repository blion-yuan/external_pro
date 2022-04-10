/*
 * sys_task.c
 *
 *  Created on: 2022-4-1
 *      Author: blion
 */
#include "alt_types.h"
#include "sys_task.h"
#include "system.h"
#include "altera_avalon_pio_regs.h"
//#include "altera_avalon_uart_regs.h"
#include <stdbool.h>
#include "oled.h"

unsigned char code_tab[]={0xc0,0xf9,0xa4,0xb0,0x99,0x92,0x82,0xf8,0x80,0x90,0xff};
alt_u8 rx_table[4]={0x69,0x05,0x00,0x7f};
alt_u8 g_car_num = 0x05;

alt_u8 g_car_speed;


bool g_rx_bit =1;
extern alt_u8 g_rx_data;
static bool show_bit =1;

void led_polling(void)
{
		static bool led = false;

		if(led == false)
		{
			led = true;
		}
		else
		{
			led = false;
		}
		IOWR_ALTERA_AVALON_PIO_DATA(LED_BASE, led);

}

void disp_sel(alt_u8 num,alt_u8 sel_num)
{
	alt_u8 dat,i;
	alt_u32 gpio_sta;
	dat=code_tab[num];
	for(i=0;i<8;i++)
	{
		IOWR_ALTERA_AVALON_PIO_DATA(GPIO1_BASE,0x00);
		if(dat&0x80)
		{
			gpio_sta = 0x02;
		}
		else
		{
			gpio_sta = 0x00;
		}

		IOWR_ALTERA_AVALON_PIO_DATA(GPIO1_BASE,gpio_sta);
		gpio_sta = gpio_sta | 0x01;
		IOWR_ALTERA_AVALON_PIO_DATA(GPIO1_BASE,gpio_sta);
		dat<<=1;
	}
	dat = sel_num;
	for(i=0;i<8;i++)
	{
		IOWR_ALTERA_AVALON_PIO_DATA(GPIO1_BASE,0x00);
		if(dat&0x80)
		{
			gpio_sta = 0x02;
		}
		else
		{
			gpio_sta = 0x00;
		}
		IOWR_ALTERA_AVALON_PIO_DATA(GPIO1_BASE,gpio_sta);
		gpio_sta = gpio_sta | 0x01;
		IOWR_ALTERA_AVALON_PIO_DATA(GPIO1_BASE,gpio_sta);
		dat<<=1;
	}
}


void sure_polling(void)
{
	if(0 == g_rx_bit)
	{
		rx_table[3] = rx_table[2];
		rx_table[2] = rx_table[1];
		rx_table[1] = rx_table[0];
		rx_table[0] = g_rx_data;
		g_rx_bit = 1;
		if((rx_table[0] == 0x7f) && (rx_table[3] == 0x69))
		{
			g_car_num = rx_table[2];
			g_car_speed = rx_table[1];
			show_bit = 1;
		}
	}

}

void speed_polling(void)
{
//	alt_u8 speed_num;
	static alt_u8 num = 0x10;
	if(0x10 == num)
	{
		disp_sel(0,num);
		num = num <<1;
	}
	else if(0x20 == num)
	{
//		speed_num = get_speed_num();
		disp_sel(g_car_speed,num);
		num = num <<1;
	}
	else if(0x40 == num)
	{
		disp_sel(0,num);
		num = num <<1;
	}
	else
	{
//		speed_num = get_speed_num();
		disp_sel(g_car_speed,num);
		num = 0x10;
	}
}


void car_polling(void)
{
	static alt_u8 num = 1;
	if(1 == num)
	{
		disp_sel(2,num);
		num = num <<1;
	}
	else if(2 == num)
	{
		disp_sel(0,num);
		num = num <<1;
	}
	else if(4 == num)
	{
		disp_sel(2,num);
		num = num <<1;
	}
	else
	{
		disp_sel(g_car_num,num);
		num = 1;
	}
}

void car_num_polling(void)
{
	static alt_u8 old_car_num;
	static alt_u8 old_car_speed;
	if(show_bit == 1)
	{
		show_bit = 0;
		if(old_car_num != g_car_num)
		{
			oled_show_string16(104,0,"   ");
			oled_show_num16(104,0,g_car_num);
			old_car_num = g_car_num;
		}

		if(old_car_speed != g_car_speed)
		{
			oled_show_string16(88,2,"   ");
			oled_show_num16(88,2,g_car_speed);
			oled_show_string16(72,4,"   ");
			oled_show_num16(72,4,g_car_speed);
			old_car_speed = g_car_speed;
		}
	}
}

