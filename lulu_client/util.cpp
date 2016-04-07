

#include "util.h"
#include <stdlib.h>
#include <vector>
#include <stdio.h>
#include <stdarg.h>
#include <algorithm>
#include <math.h>
#include <time.h>
#include <sys/time.h>

#define  ArbitraryStrWildcard "(*)"

int _vscprintf (const char * format, va_list pargs) 
{ 
	int retval; 
	va_list argcopy; 
	va_copy(argcopy, pargs); 
	retval = vsnprintf(NULL, 0, format, argcopy); 
	//retval = vprintf(format, argcopy); 
	va_end(argcopy); 
	return retval; 
}

int _vscwprintf(const wchar_t *format, va_list pargs)
{
	int retval; 
	va_list argcopy; 
	va_copy(argcopy, pargs); 
	//retval = vswprintf(NULL, 0, format, argcopy); 
	retval = vwprintf(format, argcopy); 
	
	va_end(argcopy); 
	return retval;
}

unsigned int GetRandInt(unsigned int nMin, unsigned int nMax)
{
	//return nMin + rand() % (nMax - nMin + 1);
	return (nMin == nMax) ? nMax : (nMin + rand() % (nMax - nMin + 1));
}

char GetRandHexChar(bool bLower)
{
	return IntToHexChar(GetRandInt(0,15),bLower);
}

char GetRandChar(bool bLower)
{
	return IntToChar(GetRandInt(0,25),bLower);
}

char IntToHexChar(unsigned int nValue, bool bLower)
{
	if(nValue > 15) return '0';

	if(nValue < 10) return '0' + nValue;
	return (bLower ? 'a' : 'A') + nValue - 10;
}

char IntToChar(unsigned int ncValue, bool bLower)
{
	char cFst = bLower ? 'a' : 'A';
	if(ncValue > 25) return cFst;
	return cFst + ncValue;
}

//从pos开始查找strFind在strSrc的位置，这个位置是strFind结束的位置，strFind可以包含通配符(*),通配符不能在开始或者结束的位置
std::string::size_type FindStrEndPos(const std::string &strSrc, const std::string::size_type pos, const std::string strFind)
{
	std::string::size_type posRet = std::string::npos;
	std::string::size_type posFind = 0;
	std::string strLeft = GetMidStr(strFind,posFind,ArbitraryStrWildcard);//分解通配符
	while(strLeft.length() > 0)
	{
		std::string::size_type posTmp = strSrc.find(strLeft,((posRet == std::string::npos) ? pos : posRet));
		if (posTmp == std::string::npos)
		{
			posRet = std::string::npos;
			break;
		}
		posRet = posTmp + strLeft.length();
		strLeft = GetMidStr(strFind,posFind,ArbitraryStrWildcard);
	}
	return posRet;
}

std::string GetMidStr(const std::string &strSrc, std::string::size_type &pos, const std::string strFind)
{
	if (pos == std::string::npos) return std::string();
	std::string strRet = "";
	std::string::size_type nPosFile = strSrc.find(strFind, pos);
	if(nPosFile != std::string::npos)
	{
		strRet = strSrc.substr(pos,nPosFile - pos);
		pos = nPosFile + strFind.length();
	}
	else
	{
		strRet = strSrc.substr(pos);
		pos = std::string::npos;
	}
	return strRet;
}

std::string GetSubStr(const std::string strSrc, std::string::size_type &pos,const std::string strBegin, const std::string strEnd)
{
	std::string::size_type nPosBegin = FindStrEndPos(strSrc,pos,strBegin);
	if (nPosBegin == std::string::npos) return std::string();

	int nPosEnd = strSrc.find(strEnd,nPosBegin);
	if (nPosEnd == std::string::npos) return std::string();

	std::string strRet = strSrc.substr(nPosBegin,nPosEnd - nPosBegin);
	pos = nPosEnd + strEnd.length();

	return strRet;
}

std::string GetLRStr(const std::string strSrc, const std::string strFind, bool bRight, bool bReverse)
{
	int nPos = bReverse?strSrc.rfind(strFind):strSrc.find(strFind);
	if (nPos == std::string::npos) return "";

	return bRight?strSrc.substr(nPos + strFind.length()):strSrc.substr(0,nPos);
}

std::string TrimStr(std::string strSrc)
{
	while (!strSrc.empty())
	{
		if (strSrc[0] == ' ' || strSrc[0] == '\t' || strSrc[0] == '\r' || strSrc[0] == '\n')
		{
			strSrc.erase(0, 1);
			continue;
		}
		break;
	}
	std::string::size_type nLastPost;
	while (!strSrc.empty())
	{
		nLastPost = strSrc.size() - 1;
		if (strSrc[nLastPost] == ' ' || strSrc[nLastPost] == '\t' || strSrc[nLastPost] == '\r' || strSrc[nLastPost] == '\n')
		{
			strSrc.erase(nLastPost, 1);
			continue;
		}
		break;
	}
	return strSrc;
}

bool StrReplaceAll( std::string &strSrc, const std::string strReplaceSrc, const std::string strReplaceDst )
{
	bool bRet = false;
	std::string strReallyReplaceSrc;
	std::string::size_type posTmp = strReplaceSrc.find(ArbitraryStrWildcard);
	if (posTmp == std::string::npos)
	{
		strReallyReplaceSrc = strReplaceSrc;
	}
	else
	{
		strReallyReplaceSrc = GetReallyContent(strSrc, strReplaceSrc);
	}

	std::string::size_type pos = 0;
	std::string::size_type srclen = strReallyReplaceSrc.size();
	std::string::size_type dstlen = strReplaceDst.size();
	if (0 == srclen) return bRet;

	while( (pos=strSrc.find(strReallyReplaceSrc, pos)) != std::string::npos )
	{
		strSrc.replace( pos, srclen, strReplaceDst );
		pos += dstlen;
		bRet = true;
		if (posTmp != std::string::npos)
		{
			strReallyReplaceSrc = GetReallyContent(strSrc, strReplaceSrc,pos);
			srclen = strReallyReplaceSrc.size();
			if(srclen == 0) break;
		}
	}
	return bRet;
} 

bool StrReplaceOnce( std::string &strSrc, const std::string strReplaceSrc, const std::string strReplaceDst, const std::string::size_type bgPos )
{
	bool bRet = false;
	std::string strReallyReplaceSrc;
	std::string::size_type posTmp = strReplaceSrc.find(ArbitraryStrWildcard);
	if (posTmp == std::string::npos)
	{
		strReallyReplaceSrc = strReplaceSrc;
	}
	else
	{
		strReallyReplaceSrc = GetReallyContent(strSrc, strReplaceSrc, bgPos);
	}
	
	std::string::size_type pos = bgPos;
	std::string::size_type srclen = strReallyReplaceSrc.size();
	if (0 == srclen) return bRet;

	if( (pos=strSrc.find(strReallyReplaceSrc, pos)) != std::string::npos )
	{
		strSrc.replace( pos, srclen, strReplaceDst );
		bRet = true;
	}
	return bRet;
} 

std::string GetReallyContent(const std::string &strSource, const std::string &strFind, const std::string::size_type bgPos)
{
	std::string::size_type nPosRet = std::string::npos,nPosBegin = std::string::npos;
	std::string::size_type nFildPos = 0;
	std::string strRet = "";
	std::string strLeft = GetMidStr(strFind,nFildPos,ArbitraryStrWildcard);//分解通配符
	while(strLeft.length() > 0)
	{
		std::string::size_type nPos = strSource.find(strLeft,((nPosRet == std::string::npos) ? bgPos : nPosRet));
		if (nPos == std::string::npos)
		{
			nPosRet = std::string::npos;
			break;
		}
		if(std::string::npos == nPosBegin) nPosBegin = nPos;
		nPosRet = nPos + strLeft.length();
		strLeft = GetMidStr(strFind,nFildPos,ArbitraryStrWildcard);
	}
	if (std::string::npos != nPosRet)
		strRet = strSource.substr(nPosBegin,nPosRet - nPosBegin);

	return strRet;
}

//字符串格式化函数
std::string StrFormatA(const char *fmt, ...) 
{ 
	std::string strResult="";
	if (NULL == fmt) return strResult;
	
	va_list marker ;
	va_start(marker, fmt); 
	size_t nLength = _vscprintf(fmt, marker) + 1;
	if (nLength == 0) return strResult;

	strResult.resize(nLength);
	vsnprintf((char*)strResult.c_str(), strResult.length(), fmt, marker);
	va_end(marker);
	
	return strResult; 
}
//字符串格式化函数
std::wstring StrFormatW(const wchar_t *fmt, ...) 
{ 
	std::wstring strResult=L"";
	if (NULL == fmt) return strResult;
	
	va_list marker;            
	va_start(marker, fmt);
	size_t nLength = _vscwprintf(fmt, marker) + 1;
	if (nLength == 0) return strResult;

	strResult.resize(nLength);
	vswprintf((wchar_t*)strResult.c_str(), strResult.length(), fmt, marker); 
	va_end(marker);
	
	return strResult; 
} 

char * GetCharset(const char *str)
{
	if (!str || !*str) return 0; 
	char *p = 0;
	p =STRDUP( str );
	//_strlwr_s( p ,strlen(p) ) ;
	std::string temp( p );
	spiderfree(p);
	ToLower(temp);
	std::string::size_type i;

	str = temp.c_str();
	if ((i =  temp.rfind("charset")) == std::string::npos) 
	{		
		if ((i =  temp.rfind("encoding")) == std::string::npos) 
		{
			if ((i =  temp.rfind("chatset")) == std::string::npos  ) 
			{
				if ((i =  temp.rfind("gb2312")) == std::string::npos  ) 
				{
					return 0;
				}else
				{
					return STRDUP( "gbk" );
				}
			}
			else 
			{
				str += (7 + i);			
			}
		}
		else 
		{
			str += (8 + i);
		}
	}
	else
	{
		str += (7 + i);
	}	
	return FormatCharset( str );	
}

char * FormatCharset( const char * str )
{
	if ( !str || !*str) return 0;	
	const char *start,*end;
	for ( start=str;
		*start&& (!ISALNUM(*start) || *start == '-' || *start== '_');
		start++);

	for ( end = start;
		*end && (ISALNUM(*end) || *end == '-' || *end == '_' );
		end++);
	int len = end - start;

	if (!*start || !len ) 
		return 0;

	char *encoding = (char *)malloc( len + 2 );
	encoding[len] = 0;
	memcpy( encoding ,start, len );
	return encoding;
}
/*
char* GetCurDir(char * szPath,int len)
{
	::GetModuleFileNameA(NULL,szPath,len);
	char* lpstr = szPath;
	while ( strstr(lpstr,"\\") ) lpstr = strstr(lpstr,"\\") + 1;
	if ( lpstr ) lpstr[0] = 0;
	return szPath;
}
*/

void ToLower( std::string& str )
{
	std::transform(str.begin(),str.end(),str.begin(),tolower);
}

void ToUpper( std::string& str )
{
	std::transform(str.begin(),str.end(),str.begin(),toupper);
}
#if 0
////////////把16进制转成正常文本////////////

int MChar2Hex(char ch)  
{  
    if('0' <= ch && ch <= '9') return (ch - '0');
	if('A' <= ch && ch <= 'F') return (ch - 'A' + 10);
	if('a' <= ch && ch <= 'f') return (ch - 'a' + 10);
	return -1; 
}  

char* MHexToStr(const char* szIn)
{
	int nLen = STRLEN(szIn);
	if(nLen < 1) return NULL;
	
	int nNewLen = nLen / 2 + 1;//(nLen < 2 || nLen % 2 != 0) ? (nLen + 1) : (nLen / 2 + 1);
	char* szOut = (char *)malloc(nNewLen * sizeof(char));
	if(NULL == szOut) return NULL;
	
	memset(szOut,0,nNewLen * sizeof(char));
	
	int i = 0;
	for (; i < nLen - 1; i += 2) 
	{
		unsigned int anInt = MChar2Hex(szIn[i]) * 16 + MChar2Hex(szIn[i+1]);
		szOut[i / 2] = anInt;
	}
	return szOut;
}

char* MStrToHex(const char* szIn)
{
    int nLen = STRLEN(szIn);
	if(nLen < 1) return NULL;
	
	int nNewLen = nLen * 2 + 1;
	char* szOut = (char *)malloc(nNewLen * sizeof(char));
	if(NULL == szOut) return NULL;

	memset(szOut,0,nNewLen * sizeof(char));

	char strTmp[3] = {0};
	int i = 0;
    for(; i < nLen; i++)  
    {
        snprintf(strTmp,3,"%02X", szIn[i]&0xff);
        strcat(szOut, strTmp);
    }
    
	return szOut;
}

////////////END 把16进制转成正常文本////////////



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

long long num_atoll(const char* p)
{
	if(NULL == p)
	{
		return 0;
	}

	int neg_flag = 0;// 符号标记
	long long res = 0;// 结果 
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

	if (_J2 >= _J1)
	{
		if (_W2 < _W1)
		{
			dRotateAngle = TPI - dRotateAngle;
		}
	}
	else
	{
		if (_W2 >= _W1)
		{
			dRotateAngle = 2 * TPI - dRotateAngle;
		}
		else
		{
			dRotateAngle = TPI + dRotateAngle;
		}
	}

	dRotateAngle = dRotateAngle * 180 / TPI;
	return dRotateAngle;
}

unsigned int GetSecSince1970()
{
	return time(NULL);
}

unsigned int GetCurrentMicrosec()
{
	struct timeval dwNow;

	gettimeofday(&dwNow, NULL); 

	return dwNow.tv_usec;
}

bool TimeToStruct(unsigned int _uTime, int *_piYear, int *_piMon, int *_piDay, 
				  int *_piHour, int *_piMin, int *_piSec)
{
	time_t lTime = _uTime;
	struct tm *ptNow = localtime(&lTime);

	if(NULL == ptNow) return false;

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
	return true;
}

int GetCurrentTime(int *_piYear, int *_piMon, int *_piDay, 
					int *_piHour, int *_piMin, int *_piSec)
{
	return TimeToStruct(time(NULL), _piYear, _piMon, _piDay, _piHour, _piMin, _piSec);
}

int GetCurrentDay()
{
	int nYear=0,nMon=0,nDay=0;
	GetCurrentTime(&nYear,&nMon,&nDay,NULL,NULL,NULL);
	return nYear * 10000 + nMon * 100 + nDay;
}
#endif
