/*
 * sys_task.h
 *
 *  Created on: 2022-4-1
 *      Author: blion
 */

#ifndef SYS_TASK_H_
#define SYS_TASK_H_

void led_polling(void);
void car_polling(void);
void speed_polling(void);
void sure_polling(void);

#define CP_L IOWR_ALTERA_AVALON_PIO_DATA(CP_BASE,0)
#define CP_H IOWR_ALTERA_AVALON_PIO_DATA(CP_BASE,1)


#endif /* SYS_TASK_H_ */
