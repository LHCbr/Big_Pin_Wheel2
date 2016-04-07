#ifndef _MINES_H_
#define _MINES_H_

#include "im_pub.h"

#define mines_GetSum()		11

// 获得当前时刻的周期序号
int mines_GetCurrentIndex();
int mines_GetIndex(int _iHour, int _iMin);


// 根据周期序号，计算剩余时间，分钟数
int mines_GetRestTime(int _iIndex);

int mines_GetAngle(T_JW_TYPE _MJ, T_JW_TYPE _MW, T_JW_TYPE _UJ, T_JW_TYPE _UW);

int mines_GetLen(T_JW_TYPE _MJ, T_JW_TYPE _MW, T_JW_TYPE _UJ, T_JW_TYPE _UW);

#endif
