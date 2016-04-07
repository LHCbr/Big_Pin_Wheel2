#ifndef _T_TIME_H_
#define _T_TIME_H_

// 获得当前时间距离1970-1-1的秒数
unsigned int time_GetSecSince1970();

// 获得当前时间的毫秒
unsigned int time_GetCurrentMs();

// 获取当前日期
int time_GetCurrentDay();

// 获取当前时间
int time_GetCurrent(int *_piYear, int *_piMon, int *_piDay, 
						int *_piHour, int *_piMin, int *_piSec);

// 将utc时间转变成结构体
int time_ToStruct(unsigned int _uTime, int *_piYear, int *_piMon, int *_piDay, 
						int *_piHour, int *_piMin, int *_piSec);


#endif
