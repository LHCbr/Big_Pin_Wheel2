#include "mines.h"
#include "t_num.h"
#include "t_time.h"
#include "t_base.h"

#include <math.h>

int mines_GetCurrentIndex()
{
	int iHour = 0;
	int iMin = 0;

	time_GetCurrent(NULL, NULL, NULL, &iHour, &iMin, NULL);

	return mines_GetIndex(iHour, iMin);
}

int mines_GetIndex(int _iHour, int _iMin)
{
	_iMin += (_iHour * 60);

	#if 1
	if(_iMin > 1 * 60 + 0 && _iMin <= 7 * 60 + 0)
	{
		return 0;
	}
	else if(_iMin > 7 * 60 + 0 && _iMin <= 8 * 60 + 0)
	{
		return 1;
	}
	else if(_iMin > 8 * 60 + 0 && _iMin <= 10 * 60 + 0)
	{
		return 2;
	}
	else if(_iMin > 10 * 60 + 0 && _iMin <= 12 * 60 + 0)
	{
		return 3;
	}
	else if(_iMin > 12 * 60 + 0 && _iMin <= 13 * 60 + 0)
	{
		return 4;
	}
	else if(_iMin > 13 * 60 + 0 && _iMin <= 15 * 60 + 0)
	{
		return 5;
	}
	else if(_iMin > 15 * 60 + 0 && _iMin <= 17 * 60 + 0)
	{
		return 6;
	}
	else if(_iMin > 17 * 60 + 0 && _iMin <= 19 * 60 + 0)
	{
		return 7;
	}
	else if(_iMin > 19 * 60 + 0 && _iMin <= 21 * 60 + 0)
	{
		return 8;
	}
	else if(_iMin > 21 * 60 + 0 && _iMin <= 23 * 60 + 0)
	{
		return 9;
	}
	else
	{
		return 10;
	}
	#else
	if(iMin >= 6 * 60 + 30 && iMin < 9 * 60 + 30)
	{
		return 0;
	}
	else if(iMin >= 9 * 60 + 30 && iMin < 11 * 60 + 30)
	{
		return 1;
	}
	else if(iMin >= 11 * 60 + 30 && iMin < 14 * 60 + 0)
	{
		return 2;
	}
	else if(iMin >= 14 * 60 + 0 && iMin < 17 * 60 + 0)
	{
		return 3;
	}
	else if(iMin >= 17 * 60 + 0 && iMin < 19 * 60 + 30)
	{
		return 4;
	}
	else if(iMin >= 19 * 60 + 30 && iMin < 22 * 60 + 30)
	{
		return 5;
	}
	else
	{
		return 6;
	}
	#endif
}


int mines_GetRestTime(int _iIndex)
{
	int iHour = 0;
	int iMin = 0;

	time_GetCurrent(NULL, NULL, NULL, &iHour, &iMin, NULL);

	iMin += (iHour * 60);

	int iRest = 0;

	#if 1
	switch(_iIndex)
	{
		case 0:
			iRest = 7 * 60 + 0;
			break;

		case 1:
			iRest = 8 * 60 + 0;
			break;

		case 2:
			iRest = 10 * 60 + 0;
			break;

		case 3:
			iRest = 12 * 60 + 0;
			break;

		case 4:
			iRest = 13 * 60 + 0;
			break;

		case 5:
			iRest = 15 * 60 + 0;
			break;

		case 6:
			iRest = 17 * 60 + 0;
			break;

		case 7:
			iRest = 19 * 60 + 0;
			break;

		case 8:
			iRest = 21 * 60 + 0;
			break;
			
		case 9:
			iRest = 23 * 60 + 0;
			break;
			
		case 10:
			iRest = 1 * 60 + 0 + 24 * 60;
			break;

		default:
			iRest = iMin;
			break;
	}
	#else
	switch(_iIndex)
	{
		case 0:
			iRest = 9 * 60 + 30;
			break;

		case 1:
			iRest = 11 * 60 + 30;
			break;

		case 2:
			iRest = 14 * 60 + 0;
			break;

		case 3:
			iRest = 17 * 60 + 0;
			break;

		case 4:
			iRest = 19 * 60 + 30;
			break;

		case 5:
			iRest = 22 * 60 + 30;
			break;

		case 6:
			iRest = 6 * 60 + 30 + 24 * 60;
			break;

		default:
			iRest = iMin;
			break;
	}
	#endif

	iRest -= iMin;

	if(iRest < 0)
	{
		// 3分钟之内显示0分钟，等待服务器处理
		if(iRest > -3)
		{
			iRest = 0;
		}
		else
		{
			// 若3分钟之内，还没有处理，则这是第二天时间段的一个雷
			iRest += (24 * 60);
		}
	}

	return iRest;
}

#if 1
int mines_GetAngle(T_JW_TYPE _MJ, T_JW_TYPE _MW, T_JW_TYPE _UJ, T_JW_TYPE _UW)
{
	return num_GetAngle((double)_MJ / (double)IM_JW_RATE,
						(double)_MW / (double)IM_JW_RATE,
						(double)_UJ / (double)IM_JW_RATE,
						(double)_UW/ (double)IM_JW_RATE);
}
#else
static int GetAngle(T_JW_TYPE _MJ, T_JW_TYPE _MW, T_JW_TYPE _UJ, T_JW_TYPE _UW)
{
	T_JW_TYPE Dj =	_UJ - _MJ;
	T_JW_TYPE Dw =	_UW - _MW;

	// 处理坐标轴上的点
	if(0 == Dj && Dw >= 0)
	{
		return 0;
	}
	else if(0 == Dj && Dw > 0)
	{
		return 90;
	}
	else if(0 == Dj && Dw < 0)
	{
		return 270;
	}
	else if(0 == Dw && Dj < 0)
	{
		return 180;
	}

	double Dx = Dj * Dj;
	double Dy = Dw * Dw;

	double dAngle = asin((double)Dx / (double)(Dx + Dy));

	int iAngle = dAngle / 3.141592653 * 180;

	// 处理其他点
	if(Dj < 0 && Dw > 0) // 二象限
	{
		iAngle = 180 - iAngle;
	}
	else if(Dj < 0 && Dw < 0) // 三象限
	{
		iAngle = 180 + iAngle;
	}
	else if(Dj > 0 && Dw < 0) // 四象限
	{
		iAngle = 360 - iAngle;
	}

	return iAngle;
}
#endif

int mines_GetLen(T_JW_TYPE _MJ, T_JW_TYPE _MW, T_JW_TYPE _UJ, T_JW_TYPE _UW)
{
	T_JW_TYPE Dj =	_UJ - _MJ;
	T_JW_TYPE Dw =	_UW - _MW;

	return sqrt((float)(Dj * Dj + Dw * Dw));
}


