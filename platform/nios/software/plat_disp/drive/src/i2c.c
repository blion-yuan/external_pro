/*
 * i2c.c
 *
 *  Created on: 2022-4-10
 *      Author: blion
 */

#include <stdbool.h>
#include "system.h"
#include "../inc/i2c.h"
#include "altera_avalon_pio_regs.h"
#include <unistd.h>

void i2c_star(void)
{
    /*    _____
     *SDA      \_____________
     *    __________
     *SCL           \________
     */

	IOWR_ALTERA_AVALON_PIO_DATA(GPIO1_BASE,0x03);
	usleep(20);
	IOWR_ALTERA_AVALON_PIO_DATA(GPIO1_BASE,0x01);
	usleep(10);
	IOWR_ALTERA_AVALON_PIO_DATA(GPIO1_BASE,0x00);
	usleep(10);
}

void i2c_stop(void)
{
    /*               _______
     *SDA __________/
     *          ____________
     *SCL _____/
     */
	IOWR_ALTERA_AVALON_PIO_DATA(GPIO1_BASE,0x00);
	usleep(10);
	IOWR_ALTERA_AVALON_PIO_DATA(GPIO1_BASE,0x01);
	usleep(10);
	IOWR_ALTERA_AVALON_PIO_DATA(GPIO1_BASE,0x03);
	usleep(20);
}

void i2c_send_byte(alt_u8 data)
{
    alt_u8 i;
    alt_u8 gpio_sta;

    for(i = 0; i < 8; i++)
    {
        if(data & 0x80)
        {
        	gpio_sta = 0x02;

        }
        else
        {
        	gpio_sta = 0x00;

        }
        IOWR_ALTERA_AVALON_PIO_DATA(GPIO1_BASE,gpio_sta);
        usleep(10);
        gpio_sta = gpio_sta | 0x01;
        IOWR_ALTERA_AVALON_PIO_DATA(GPIO1_BASE,gpio_sta);
        usleep(20);
        gpio_sta = gpio_sta & 0x0e;
        IOWR_ALTERA_AVALON_PIO_DATA(GPIO1_BASE,gpio_sta);
        data <<= 1;
        usleep(10);
    }

    IOWR_ALTERA_AVALON_PIO_DATA(GPIO1_BASE,0x02);
    usleep(10);
    IOWR_ALTERA_AVALON_PIO_DATA(GPIO1_BASE,0x03);
    usleep(20);
    IOWR_ALTERA_AVALON_PIO_DATA(GPIO1_BASE,0x02);
    usleep(10);
}

