#include "t_time.h"

//#include "t_base.h"

#include <time.h>
#include <sys/time.h>
#include <stddef.h>

unsigned int time_GetSecSince1970()
{
	return time(NULL);
}

unsigned int time_GetCurrentMs()
{
	struct timeval dwNow;

	gettimeofday(&dwNow, NULL); 

	return dwNow.tv_usec;
}

int time_ToStruct(unsigned int _uTime, int *_piYear, int *_piMon, int *_piDay, 
						int *_piHour, int *_piMin, int *_piSec)
{
	time_t lTime = _uTime;

	struct tm *ptNow = localtime(&lTime);

	if(NULL == ptNow) return -1;

	if(_piYear)
	{
		*_piYear = ptNow->tm_year + 1900;  //年
	}

	if(_piMon)
	{
		*_piMon = ptNow->tm_mon + 1;
	}

	if(_piDay)
	{
		*_piDay = ptNow->tm_mday;
	}

	if(_piHour)
	{
		*_piHour = ptNow->tm_hour;
	}

	if(_piMin)
	{
		*_piMin = ptNow->tm_min;
	}

	if(_piSec)
	{
		*_piSec = ptNow->tm_sec;
	}

	return 0;
}

int time_GetCurrent(int *_piYear, int *_piMon, int *_piDay, 
						int *_piHour, int *_piMin, int *_piSec)
{
	return time_ToStruct(time(NULL), _piYear, _piMon, _piDay, _piHour, _piMin, _piSec);
}

int time_GetCurrentDay()
{
	int nYear=0,nMon=0,nDay=0;
	time_GetCurrent(&nYear,&nMon,&nDay,NULL,NULL,NULL);
	return nYear * 10000 + nMon * 100 + nDay;
}


