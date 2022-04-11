#include "vl53l0x_it.h"

#include "delay.h"

//上下限距离值 单位:mm
#define Thresh_Low  60
#define Thresh_High 150

//中断模式参数结构体
typedef struct 
{
     const int VL53L0X_Mode;//模式
	 uint32_t ThreshLow;    //下限值
	 uint32_t ThreshHigh;   //上限值
}AlrmMode_t; 

AlrmMode_t AlarmModes ={
	
     VL53L0X_GPIOFUNCTIONALITY_THRESHOLD_CROSSED_OUT,// value < thresh_low OR value > thresh_high
	 Thresh_Low<<16,
	 Thresh_High<<16
};

//中断配置初始化
static void exti_init(void)
{
	GPIO_InitTypeDef GPIO_InitStructure;
	EXTI_InitTypeDef EXTI_InitStructure;
 	NVIC_InitTypeDef NVIC_InitStructure;
	
	RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOA,ENABLE);//使能PORTA时钟
	RCC_APB2PeriphClockCmd(RCC_APB2Periph_AFIO,ENABLE);	//使能复用功能时钟
	
	GPIO_InitStructure.GPIO_Pin  = GPIO_Pin_4;
	GPIO_InitStructure.GPIO_Mode = GPIO_Mode_IPU; //设置成上拉输入
 	GPIO_Init(GPIOA, &GPIO_InitStructure);

    GPIO_EXTILineConfig(GPIO_PortSourceGPIOA,GPIO_PinSource4);
	EXTI_InitStructure.EXTI_Line = EXTI_Line4; 
	EXTI_InitStructure.EXTI_Mode = EXTI_Mode_Interrupt;
	EXTI_InitStructure.EXTI_Trigger = EXTI_Trigger_Falling;//下降沿触发
	EXTI_InitStructure.EXTI_LineCmd = ENABLE;
	EXTI_Init(&EXTI_InitStructure);	 	//根据EXTI_InitStruct中指定的参数初始化外设EXTI寄存器
	
    NVIC_InitStructure.NVIC_IRQChannel = EXTI4_IRQn;			    //使能按键WK_UP所在的外部中断通道
  	NVIC_InitStructure.NVIC_IRQChannelPreemptionPriority = 0x02;	//抢占优先级2， 
  	NVIC_InitStructure.NVIC_IRQChannelSubPriority = 0x03;		    //子优先级3
  	NVIC_InitStructure.NVIC_IRQChannelCmd = ENABLE;				    //使能外部中断通道
  	NVIC_Init(&NVIC_InitStructure); 
	
}

//警报标志位 alarm_flag 
//1:有警报
//0：无
u8 alarm_flag=0;

//外部中断服务函数
void EXTI4_IRQHandler(void)
{
	alarm_flag=1;//标志
	EXTI_ClearITPendingBit(EXTI_Line4);  //清除LINE4上的中断标志位 
}

extern uint8_t AjustOK;
extern mode_data Mode_data[];

//vl53l0x中断测量模式测试
//dev:设备I2C参数结构体
//mode: 0:默认;1:高精度;2:长距离;3:高速
void vl53l0x_interrupt_start(VL53L0X_Dev_t *dev,uint8_t mode)
{
	 uint8_t VhvSettings;
	 uint8_t PhaseCal;
	 uint32_t refSpadCount;
	 uint8_t isApertureSpads;
	 VL53L0X_RangingMeasurementData_t RangingMeasurementData;
//	 static char buf[VL53L0X_MAX_STRING_LENGTH];//测试模式字符串字符缓冲区
	 VL53L0X_Error status=VL53L0X_ERROR_NONE;//工作状态


	 exti_init();//中断初始化

//	 mode_string(mode,buf);//显示当前配置的模式


	 
     vl53l0x_reset(dev);//复位vl53l0x(频繁切换工作模式容易导致采集距离数据不准，需加上这一代码)
	 status = VL53L0X_StaticInit(dev);
	 if(status!=VL53L0X_ERROR_NONE) goto error;

	 if(AjustOK!=0)//已校准好了,写入校准值
	 {
		status= VL53L0X_SetReferenceSpads(dev,Vl53l0x_data.refSpadCount,Vl53l0x_data.isApertureSpads);//设定Spads校准值
		if(status!=VL53L0X_ERROR_NONE) goto error;
        delay_ms(2);		 
		status= VL53L0X_SetRefCalibration(dev,Vl53l0x_data.VhvSettings,Vl53l0x_data.PhaseCal);//设定Ref校准值
		if(status!=VL53L0X_ERROR_NONE) goto error;
		delay_ms(2);
		status=VL53L0X_SetOffsetCalibrationDataMicroMeter(dev,Vl53l0x_data.OffsetMicroMeter);//设定偏移校准值
		if(status!=VL53L0X_ERROR_NONE) goto error;
		delay_ms(2);
		status=VL53L0X_SetXTalkCompensationRateMegaCps(dev,Vl53l0x_data.XTalkCompensationRateMegaCps);//设定串扰校准值
		if(status!=VL53L0X_ERROR_NONE) goto error; 
	 }else
	 {
	 	status = VL53L0X_PerformRefCalibration(dev, &VhvSettings, &PhaseCal);//Ref参考校准
		if(status!=VL53L0X_ERROR_NONE) goto error;
		delay_ms(2);
		status = VL53L0X_PerformRefSpadManagement(dev, &refSpadCount, &isApertureSpads);//执行参考SPAD管理
		if(status!=VL53L0X_ERROR_NONE) goto error;
        delay_ms(2);		 
	 }
	 status = VL53L0X_SetDeviceMode(dev,VL53L0X_DEVICEMODE_CONTINUOUS_RANGING);//使能连续测量模式
	 if(status!=VL53L0X_ERROR_NONE) goto error;
	 delay_ms(2);
	 status = VL53L0X_SetInterMeasurementPeriodMilliSeconds(dev,Mode_data[mode].timingBudget);//设置内部周期测量时间
	 if(status!=VL53L0X_ERROR_NONE) goto error;
	 delay_ms(2);
	 status = VL53L0X_SetLimitCheckEnable(dev,VL53L0X_CHECKENABLE_SIGMA_FINAL_RANGE,1);//使能SIGMA范围检查
	 if(status!=VL53L0X_ERROR_NONE) goto error;
	 delay_ms(2);
	 status = VL53L0X_SetLimitCheckEnable(dev,VL53L0X_CHECKENABLE_SIGNAL_RATE_FINAL_RANGE,1);//使能信号速率范围检查
	 if(status!=VL53L0X_ERROR_NONE) goto error;
	 delay_ms(2);
	 status = VL53L0X_SetLimitCheckValue(dev,VL53L0X_CHECKENABLE_SIGMA_FINAL_RANGE,Mode_data[mode].sigmaLimit);//设定SIGMA范围
	 if(status!=VL53L0X_ERROR_NONE) goto error;
	 delay_ms(2); 
	 status = VL53L0X_SetLimitCheckValue(dev,VL53L0X_CHECKENABLE_SIGNAL_RATE_FINAL_RANGE,Mode_data[mode].signalLimit);//设定信号速率范围范围
	 if(status!=VL53L0X_ERROR_NONE) goto error; 
	 delay_ms(2);
	 status = VL53L0X_SetMeasurementTimingBudgetMicroSeconds(dev,Mode_data[mode].timingBudget);//设定完整测距最长时间
	 if(status!=VL53L0X_ERROR_NONE) goto error;
	 delay_ms(2); 
	 status = VL53L0X_SetVcselPulsePeriod(dev, VL53L0X_VCSEL_PERIOD_PRE_RANGE, Mode_data[mode].preRangeVcselPeriod);//设定VCSEL脉冲周期
	 if(status!=VL53L0X_ERROR_NONE) goto error;
	 delay_ms(2);
	 status = VL53L0X_SetVcselPulsePeriod(dev, VL53L0X_VCSEL_PERIOD_FINAL_RANGE, Mode_data[mode].finalRangeVcselPeriod);//设定VCSEL脉冲周期范围
	 if(status!=VL53L0X_ERROR_NONE) goto error;
	 delay_ms(2);
	 status = VL53L0X_StopMeasurement(dev);//停止测量
	 if(status!=VL53L0X_ERROR_NONE) goto error;
	 delay_ms(2);
	 status = VL53L0X_SetInterruptThresholds(dev,VL53L0X_DEVICEMODE_CONTINUOUS_RANGING,AlarmModes.ThreshLow, AlarmModes.ThreshHigh);//设定触发中断上、下限值
	 if(status!=VL53L0X_ERROR_NONE) goto error;
	 delay_ms(2);
	 status = VL53L0X_SetGpioConfig(dev,0,VL53L0X_DEVICEMODE_CONTINUOUS_RANGING,AlarmModes.VL53L0X_Mode,VL53L0X_INTERRUPTPOLARITY_LOW);//设定触发中断模式 下降沿
	 if(status!=VL53L0X_ERROR_NONE) goto error;
	 delay_ms(2);
	 status = VL53L0X_ClearInterruptMask(dev,0);//清除VL53L0X中断标志位
	 
	 error://错误信息
	 if(status!=VL53L0X_ERROR_NONE)
	 {
		print_pal_error(status);
		return ;
	 }

	 alarm_flag = 0;
	 VL53L0X_StartMeasurement(dev);//启动测量
	 while(1)
	 {   
//		key = KEY_Scan(0);
//		if(key==WKUP_PRES)
//		{
//			VL53L0X_ClearInterruptMask(dev,0);//清除VL53L0X中断标志位
//			status = VL53L0X_StopMeasurement(dev); //停止测量
//			LED1=1;
//			break;//返回上一菜单
//		}			
		if(alarm_flag==1)//触发中断
		{
			alarm_flag=0;
			VL53L0X_GetRangingMeasurementData(dev,&RangingMeasurementData);//获取测量距离,并且显示距离
			printf("d: %3d mm\r\n",RangingMeasurementData.RangeMilliMeter);

			delay_ms(70);
			VL53L0X_ClearInterruptMask(dev,0);//清除VL53L0X中断标志位 
			
		}
		delay_ms(30);


	 }
		
}



//vl53l0x中断测量模式测试
//dev:设备I2C参数结构体
void vl53l0x_interrupt_test(VL53L0X_Dev_t *dev)
{
	u8 mode=0;

	while(1)
	{
		vl53l0x_interrupt_start(dev,mode);
	   
			mode=0;

		delay_ms(50);
	}
	
}
