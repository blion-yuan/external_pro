/*
 * oled.h
 *
 *  Created on: 2022-4-10
 *      Author: blion
 */

#ifndef OLED_H_
#define OLED_H_

#include "alt_types.h"

void oled_set_point(alt_u8 x, alt_u8 y);
void oled_fill(alt_u8 bmp_dat);
void oled_clr(void);
void oled_init(void);

void oled_show_string16(alt_u8 x, alt_u8 y,char ch[]);
void oled_show_num16(alt_u8 x, alt_u8 y,alt_u8 data_num);

#endif /* OLED_H_ */
