#include "log2.h"
#include "t_file.h"
#include "t_dir.h"
#include "t_time.h"

#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <stdarg.h>
#include <time.h>


// 不能引入t_base.h，否则会循环引入，因为t_base.h对该文件有引用

#define LOG2_SUM_MAX		(1000 * 1000)
#define LOG2_DIR			"log/"

static int g_iSum = 0;	// 当前文件记录的条数
static void *g_File = NULL;

int log2_Init()
{
	g_iSum = LOG2_SUM_MAX;
	g_File = NULL;
	
	dir_CreateTree(LOG2_DIR);

	return 0;
}

int log2_Write(char *_pcMsg)
{
	if(g_iSum < 0)//防一下多线程多次关闭
	{
		return -1;
	}
	if(g_iSum++ >= LOG2_SUM_MAX)
	{
		g_iSum = -1;//防一下多线程多次关闭
		
		if(g_File)
		{
			file_Close(g_File);
			g_File = NULL;
		}

		char pcFileName[256] = {0};

		snprintf(pcFileName, sizeof(pcFileName), "%s%u.log", LOG2_DIR, time_GetSecSince1970());

		g_File = file_OpenForWrite(pcFileName);

		g_iSum = 0;
	}

	if(NULL == g_File)
	{
		return -1;
	}

	time_t now;
	struct tm tm_now;

	now = time(&now);
	
	#if 0 //加入时区后，时间值差时区值
	ptm_now = gmtime(&now);
	#else
	localtime_r(&now, &tm_now);
	#endif

	char pcText[256];
	
	snprintf(pcText, sizeof(pcText), "[%04d/%02d/%02d %02d:%02d:%02d]%s\n",
			    tm_now.tm_year + 1900,
			    tm_now.tm_mon + 1,
			    tm_now.tm_mday,
			    (tm_now.tm_hour) % 24,
			    tm_now.tm_min,
			    tm_now.tm_sec,
			    _pcMsg);

	file_Write(g_File, pcText, strlen(pcText));
	file_Flush(g_File);

	return 0;
}

int log2_WriteEx(char* pszfmt, ...)
{
	va_list struAp;
	
	char pcMsg[256];
	
	if(pszfmt == NULL)
	{
		return -1;
	}

	va_start(struAp, pszfmt);
	vsnprintf(pcMsg, sizeof(pcMsg), pszfmt, struAp);
	va_end(struAp);	
	
	return log2_Write(pcMsg);
}

int log2_Exit()
{
	if(g_File)
	{
		file_Close(g_File);
	}

	return 0;
}

