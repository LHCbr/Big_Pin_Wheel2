#include "t_num.h"

//#include "t_base.h"

#include <ctype.h>
#include <string.h>
#include <stdio.h>
#include <math.h>

typedef union
{
	int m_iInt;
	float m_fFloat;
}TIntFloat;

typedef union
{
	int m_iInt;
	void* m_ptPointer;
}TIntVoid;


char* num_itoa(unsigned int value, char *string, int maxlen)
{
	if(value < 10)
	{
		string[0] = value + '0';
		string[1] = 0;
		return string;
	}

	unsigned int 	m=value;
	unsigned int 	n = 0;
	unsigned int 	k=0;
	int i;
	char cTmp[16];

	memset(cTmp, 0, 16);

	while(m/10>0)
	{
        n = m - m / 10 * 10;
        cTmp[k] = n +'0';
        m /= 10;
		
        if(m < 10)
        {
            cTmp[k + 1] = m + '0';
        }
		
        k++;

	if(k >= 16)
	{
		break;
	}
	
	}

	if(k > maxlen - 2)
	{
		k = maxlen - 2;
	}
    
	for(i=k; i >= 0; i--)
	{
		string[i]=cTmp[k -i];
	}
	
	string[k + 1] = 0;

	return string;
}

int num_atoi(const char* p)
{
	if(NULL == p)
	{
		return 0;
	}
	
	int neg_flag = 0;// 符号标记
	int res = 0;// 结果 
	if(p[0] == '+' || p[0] == '-')
	{
		neg_flag = (*p++ != '+');
	}
	
	while(isdigit(*p))
	{
		res = res * 10 + (*p++ - '0');
	}
	
	return neg_flag ? 0 - res : res;
}

int num_ahtoi(const char* p)
{
	if(NULL == p)
	{
		return 0;
	}
	
	int neg_flag = 0;// 符号标记
	int res = 0;// 结果 
	if(p[0] == '+' || p[0] == '-')
	{
		neg_flag = (*p++ != '+');
	}
	
	while((*p >= '0' && *p <= '9') || (*p >= 'a' && *p <= 'f') || (*p >= 'A' && *p <= 'F'))
	{
		if(*p >= 'a' && *p <= 'f')
		{
			res = res * 16 + (*p++ - 'a' + 10);
		}
		else if(*p >= 'A' && *p <= 'F')
		{
			res = res * 16 + (*p++ - 'A' + 10);
		}
		else
		{
			res = res * 16 + (*p++ - '0');
		}
	}
	
	return neg_flag ? 0 - res : res;
}

int64_t num_atoll(const char* p)
{
	if(NULL == p)
	{
		return 0;
	}
	
	int neg_flag = 0;// 符号标记
	int64_t res = 0;// 结果 
	if(p[0] == '+' || p[0] == '-')
	{
		neg_flag = (*p++ != '+');
	}
	
	while(isdigit(*p))
	{
		res = res * 10 + (*p++ - '0');
	}
	
	return neg_flag ? 0 - res : res;
}

uint64_t num_atouint64(const char* p)
{
	if(NULL == p)
	{
		return 0;
	}
	uint64_t res = 0;// 结果
	while(isdigit(*p))
	{
		res = res * 10 + (*p++ - '0');
	}

	return res;
}

int num_FloatToInt(float _Value)
{
	TIntFloat pTmp;

	pTmp.m_fFloat= _Value;

	return pTmp.m_iInt;
}

float num_IntToFloat(int _Value)
{
	TIntFloat pTmp;

	pTmp.m_iInt = _Value;

	return pTmp.m_fFloat;
}

int num_PointerToInt(void *_ptData)
{
	TIntVoid pTmp;

	pTmp.m_ptPointer = _ptData;

	return pTmp.m_iInt;
}

void* num_IntToPointer(int _iData)
{
	TIntVoid pTmp;

	pTmp.m_iInt = _iData;

	return pTmp.m_ptPointer;
}

double num_GetAngle(double _J1, double _W1, double _J2, double _W2)
{
	double dRotateAngle = atan2(TABS(_J1 - _J2), TABS(_W1 - _W2));

	//printf("0 %f\n", dRotateAngle);

	if (_J2 >= _J1)
	{
		if (_W2 >= _W1)
		{
			//printf("1 %f\n", dRotateAngle);			  
		}
		else
		{
			dRotateAngle = TPI - dRotateAngle;
			//printf("2 %f\n", dRotateAngle);
		}
	}
	else
	{
		if (_W2 >= _W1)
		{
			dRotateAngle = 2 * TPI - dRotateAngle;
			//printf("3 %f\n", dRotateAngle);
		}
		else
		{
			dRotateAngle = TPI + dRotateAngle;
			//printf("4 %f\n", dRotateAngle);
		}
	}

	dRotateAngle = dRotateAngle * 180 / TPI;

	//printf("9 %f\n", dRotateAngle);

	return dRotateAngle;
}

