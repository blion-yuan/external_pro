/*
 * i2c.h
 *
 *  Created on: 2022-4-10
 *      Author: blion
 */

#ifndef I2C_H_
#define I2C_H_

#include "alt_types.h"

void i2c_star(void);
void i2c_stop(void);
void i2c_send_byte(alt_u8 data);

#endif /* I2C_H_ */
