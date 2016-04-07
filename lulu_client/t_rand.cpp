#include "t_rand.h"

//#include "t_base.h"

#include <sys/time.h>
#include <stddef.h>

int rand_GetInt(int _iMin, int _iMax)
{
#if 1
	struct timeval dwNow;

	gettimeofday(&dwNow, NULL); 

	return (dwNow.tv_usec % (_iMax - _iMin + 1)) + _iMin;
#else
	return (rand() % (_iMax - _iMin + 1)) + _iMin;
#endif
}

char* rand_GetString(int _iMode, char *_pcOut, int _iMaxLen)
{
	if(NULL == _pcOut) return NULL;

	char pcNum[] = "0123456789";
	char pcLChar[] = "abcdefghijklmnopqrstuvwxyz";
	char pcUChar[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";

	int iModeSum = 0;
	char *pcPoint[3] = {NULL, NULL, NULL};
	int iNum[3] = {0, 0, 0};

	char *pcOutString = _pcOut;

	if(RAND_MODE_NUM & _iMode)
	{
		pcPoint[iModeSum] = pcNum;
		iNum[iModeSum] = sizeof(pcNum) - 2; // sizeof(pcNum) 等于11
		iModeSum++;
	}

	if(RAND_MODE_L_CHAR & _iMode)
	{
		pcPoint[iModeSum] = pcLChar;
		iNum[iModeSum] = sizeof(pcLChar) - 2;
		iModeSum++;
	}

	if(RAND_MODE_U_CHAR & _iMode)
	{
		pcPoint[iModeSum] = pcUChar;
		iNum[iModeSum] = sizeof(pcUChar) - 2;
		iModeSum++;
	}

	iModeSum--;

	if(iModeSum < 0 || iModeSum >= 3) return NULL;

	int iType = 0;
	int Index = 0;

	while(--_iMaxLen)
	{
		if(iModeSum > 1)
		{
			iType = rand_GetInt(0, iModeSum);
		}
		else
		{
			iType = 0;
		}

	/*	dbgint(iType);
		dbgx(_pcOut);
		dbgx(pcOutString);*/

		Index = rand_GetInt(0, iNum[iType]);

	/*	dbgint(iNum[iType]);
		dbgint(Index);

		dbgx(pcPoint[iType][Index]);*/
		
		*pcOutString++ = pcPoint[iType][Index];

	//	dbgint(_iMaxLen);
	}

	*pcOutString = 0;

//	dbgprintf(0, "rand_GetString:%s", _pcOut);

	return _pcOut;
}

