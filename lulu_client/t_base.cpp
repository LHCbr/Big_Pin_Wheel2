#include "t_base.h"

#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <stdarg.h>
#include <time.h>

#ifdef DEBUG_ON 
int dbgprintf(unsigned int handle, char* pszfmt, ...)
{
	
	va_list struAp;
	time_t now;
	struct tm tm_now;
	int ret;
	char* format= NULL;
	
	if(pszfmt == NULL)
	{
		return -1;
	}

	format = (char*)calloc(strlen(pszfmt) + 3, 1);
	
	if(format == NULL)
	{
		return -2;
	}
	
	strcpy(format,pszfmt);
	
	if(format[strlen(pszfmt) - 1]=='\n')
	{
		format[strlen(pszfmt)] = format[strlen(pszfmt) - 2] == '\r' ?  '\0' : '\r';
	}
	else if(format[strlen(pszfmt) - 1] == '\r')
	{
		format[strlen(pszfmt)] = format[strlen(pszfmt)-2]=='\n' ? '\0' : '\n';
	}
	else
	{
		format[strlen(pszfmt)] = '\r';
		format[strlen(pszfmt) + 1] = '\n';
	}
	
	now = time(&now);
	
	#if 0 //加入时区后，时间值差时区值
	ptm_now = gmtime(&now);
	#else
	localtime_r(&now, &tm_now);
	#endif
	
	if(0 == handle)
	{ 	
		printf(YELLOW"[%04d/%02d/%02d %02d:%02d:%02d %d %lu]"NORMAL,
			    tm_now.tm_year + 1900,
			    tm_now.tm_mon + 1,
			    tm_now.tm_mday,
			    (tm_now.tm_hour) % 24,
			    tm_now.tm_min,
			    tm_now.tm_sec,
			    getpid(),
			    pthread_self());

		va_start(struAp, pszfmt);
		ret = vprintf(format, struAp);
		va_end(struAp);
		
	}
	else if(1 == handle)
	{ 	
		printf(GREEN"[%04d/%02d/%02d %02d:%02d:%02d %d %lu]"NORMAL,
			    tm_now.tm_year + 1900,
			    tm_now.tm_mon + 1,
			    tm_now.tm_mday,
			    (tm_now.tm_hour) % 24,
			    tm_now.tm_min,
			    tm_now.tm_sec,
			    getpid(),
			    pthread_self());

		va_start(struAp, pszfmt);
		ret = vprintf(format, struAp);
		va_end(struAp);
		
	}
	else if(2 == handle)
	{
		printf(RED"[%04d/%02d/%02d %02d:%02d:%02d %d %lu]"NORMAL,
			    tm_now.tm_year + 1900,
			    tm_now.tm_mon + 1,
			    tm_now.tm_mday,
			    (tm_now.tm_hour) % 24,
			    tm_now.tm_min,
			    tm_now.tm_sec,
			    getpid(),
			    pthread_self());

		va_start(struAp, pszfmt);
		ret = vprintf(format, struAp);
		va_end(struAp);	
	}
	else if(3 == handle)
	{
		printf(BLUE"[%04d/%02d/%02d %02d:%02d:%02d %d %lu]"NORMAL,
			    tm_now.tm_year + 1900,
			    tm_now.tm_mon + 1,
			    tm_now.tm_mday,
			    (tm_now.tm_hour) % 24,
			    tm_now.tm_min,
			    tm_now.tm_sec,
			    getpid(),
			    pthread_self());

		va_start(struAp, pszfmt);
		ret = vprintf(format, struAp);
		va_end(struAp);	
	}
	else
	{
		FILE *file;  
		file = fopen("printf.txt", "a+");
		
		fprintf(file,"[%04d/%02d/%02d %02d:%02d:%02d]",
				tm_now.tm_year + 1900,
				tm_now.tm_mon + 1,
				tm_now.tm_mday,
				(tm_now.tm_hour) % 24,
				tm_now.tm_min,
				tm_now.tm_sec);
	      
		va_start(struAp, pszfmt);
		ret = vfprintf(file, format, struAp);
		va_end(struAp);
		fclose(file);
	}
#if IM_LOG_DEBUG
	char pcMsg[1024] = {0};
	va_start(struAp, pszfmt);
	vsnprintf(pcMsg, sizeof(pcMsg), pszfmt, struAp);
	va_end(struAp); 
	log2_Write(pcMsg);
#endif
	free(format);
	return ret;
}

void hexprint(const char* _string, int _len)
{
	int i = 0;
	
	if (NULL == _string || _len <= 0)
	{
		return;
	}
	
	for (i = 0; i < _len; i++)
	{
		printf("%02x%s", _string[i], (i + 1) % 16 == 0 ? "\n" : " ");
	}

	printf("\n");
	
	return;
}


#endif



