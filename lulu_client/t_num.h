#ifndef _T_NUM_H_
#define _T_NUM_H_

#include <stdint.h>

#define TMIN(X,Y) 	(((X) < (Y)) ? (X) : (Y))
#define TMAX(X,Y) 	(((X) > (Y)) ? (X) : (Y))
#define TABS(X)		((X) < 0 ? (-(X)) : (X))

#define TPI			3.141592653

/**************************************************************************
*功能：将整型数转换为字符串
*		此函数执行效率要比sprintf(string,"%d",value) 高的多
**************************************************************************/
char* num_itoa(unsigned int value, char *string, int maxlen);

// 字符串转化为int
int num_atoi(const char* p);

// 16进制表示的字符串转化为int
int num_ahtoi(const char* p);

// 字符串转化为longlong
int64_t num_atoll(const char* p);
uint64_t num_atouint64(const char* p);

int num_FloatToInt(float _Value);
float num_IntToFloat(int _Value);

int num_PointerToInt(void *_ptData);
void* num_IntToPointer(int _iData);


// 求2点之间的角度
double num_GetAngle(double _J1, double _W1, double _J2, double _W2);

#endif
