#ifndef ___UTIL___HHH___
#define ___UTIL___HHH___

#include <string>
#include <string.h>
#include <ctype.h>

//using namespace std;

#define SPACES 						" \t\r\n"
#define HYPHENP(x)  				(*(x) == '-' && !*((x) + 1))
#define MINVAL(x, y) 				((x) < (y) ? (x) : (y))
#define spiderdelete(p) 			if ((p)) { delete((p));(p) = 0; }
#define spiderfree(p) 				if ((p)) { free((p));(p) = 0; }
#define spiderstrchr(a,b)			strchr(a,b)
#define spiderstrstr(a,b)			strstr(a,b)
#define SIZEOFARRAY(array)			(sizeof(array)/sizeof(*(array)))

#define ISSPACE(x)  				isspace ((unsigned char)(x)) //
#define ISDIGIT(x)  				isdigit ((unsigned char)(x))//当c为数字0-9时，返回非零值
#define ISWDIGIT(x)  				iswdigit ((unsigned short)(x))//当c为数字0-9时，返回非零值
#define ISXDIGIT(x)  				isxdigit ((unsigned char)(x))//当c为A-F,a-f或0-9之间的十六进制数字时，返回非零值，否则返回零。
#define ISALPHA(x)  				isalpha ((unsigned char)(x))//az或AZ
#define ISALNUM(x)  				isalnum ((unsigned char)(x))//否为英文字母或阿拉伯数字 = isalpha(c) || isdigit(c)
#define TOLOWER(x)  				((char)tolower ((unsigned char)(x)))
#define TOUPPER(x) 					((char)toupper ((unsigned char)(x)))
#define IGNORE_SPACE(p) 			for (;*(p)!='\0' && ISSPACE(*(p));(p)++);
#define FIND_SPACE(p) 				for (;*(p)!='\0' && !ISSPACE(*(p));(p)++);

#define STRDUP(src)					strdup((src) ? (src) : "" )
#define ISASCII(x)  				isascii ((unsigned char)(x))
#define STRLEN(src)					((src) ? strlen(src) : 0 )

#ifndef TMIN
#define TMIN(X,Y) 	(((X) < (Y)) ? (X) : (Y))
#endif
#ifndef TMAX
#define TMAX(X,Y) 	(((X) > (Y)) ? (X) : (Y))
#endif
#ifndef TABS
#define TABS(X)		((X) < 0 ? (-(X)) : (X))
#endif
#ifndef TPI
#define TPI			3.141592653
#endif



unsigned int GetRandInt(unsigned int nMin, unsigned int nMax);
char GetRandHexChar(bool bLower=true);
char GetRandChar(bool bLower=true);
char IntToHexChar(unsigned int ucValue, bool bLower=true);
char IntToChar(unsigned int ucValue, bool bLower=true);

//截取strSrc 从pos 到 strFind的内容，如果strFind没有找到，则取pos到结束的内容
std::string GetMidStr(const std::string &strSrc, std::string::size_type &pos, const std::string strFind);
//截取strSrc，从pos位置开始查找strBegin，到strEnd结束，其中strBegin可以带通配符，strEnd不能带通配符
std::string GetSubStr(const std::string strSrc, std::string::size_type &pos,const std::string strBegin, const std::string strEnd);
//获取左/右字符串
std::string GetLRStr(const std::string strSrc, const std::string strFind, bool bRight=false, bool bReverse=false);
std::string TrimStr(std::string strSrc);

//获取带通配符串的真实内容
std::string GetReallyContent(const std::string &strSource, const std::string &strFind, const std::string::size_type bgPos = 0);
//strReplaceSrc支持通配符
bool StrReplaceAll( std::string &strSrc, const std::string strReplaceSrc, const std::string strReplaceDst );
//strReplaceSrc支持通配符
bool StrReplaceOnce( std::string &strSrc, const std::string strReplaceSrc, const std::string strReplaceDst, const std::string::size_type bgPos = 0 );

std::string StrFormatA(const char *fmt, ...);
std::wstring StrFormatW(const wchar_t *fmt, ...);


char * GetCharset(const char *str);		
char * FormatCharset( const char * str );

//char* GetCurDir(char * szPath,int len);

void ToLower( std::string& str );
void ToUpper( std::string& str );

#if 0

char* MHexToStr(const char* szIn);
char* MStrToHex(const char* szIn);



char* num_itoa(unsigned int value, char *string, int maxlen);

// 字符串转化为int
int num_atoi(const char* p);

// 16进制表示的字符串转化为int
int num_ahtoi(const char* p);

// 字符串转化为longlong
long long num_atoll(const char* p);

int num_FloatToInt(float _Value);
float num_IntToFloat(int _Value);

int num_PointerToInt(void *_ptData);
void* num_IntToPointer(int _iData);


// 求2点之间的角度
double num_GetAngle(double _J1, double _W1, double _J2, double _W2);

// 获得当前时间距离1970-1-1的秒数
unsigned int GetSecSince1970();

// 获得当前时间的微秒
unsigned int GetCurrentMicrosec();

// 获取当前日期
int GetCurrentDay();

// 获取当前时间
int GetCurrentTime(int *_piYear, int *_piMon, int *_piDay, 
					int *_piHour, int *_piMin, int *_piSec);

// 将utc时间转变成结构体
bool TimeToStruct(unsigned int _uTime, int *_piYear, int *_piMon, int *_piDay, 
				  int *_piHour, int *_piMin, int *_piSec);
#endif

#endif