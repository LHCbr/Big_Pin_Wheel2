#ifndef _T_BASE_H_
#define _T_BASE_H_

#include <stdio.h>
#include <unistd.h>
#include <time.h>
#include <pthread.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/syscall.h>

//#ifndef DEBUG_ON
#include "log2.h"
//#endif

//调试日志
#define		IM_LOG_DEBUG			1 


#define TTRUE			(1)
#define TFALSE			(0)

// 函数返回值
enum
{	
	HASH_ERR = -8,			//HASH获取失败
	RETURN_ERR = -7,		//发送return失败
	LOGIN_DATA_NOT_EXIST=-6,//获取LOGINDATA数据结构失败
	CONNECT_ERR		= -5,	//连接错误
	USER_NOT_EXIST = -4,	//用户不存在
	PASSWD_ERR	= -3,		//密码错误
	ERR_NEXT	= -2,		// 可以重试的错误
	ERR 		= -1,		// 不可恢复的错误
	OK 			= 0,		// 正确返回
	OK_IDLE,			// 不需要执行核心业务，空闲状态
	OK_WAIT,			// 缺乏某种条件，未执行核心业务，等待重试
	OK_FINISH,			// 完成了该类处理，可以进入下一类处理
};

#define INVALID_SOCKET 		(-1)		// 无效的网络套接字
#define NO_USE(x)			((void *)(x))

#define		CRE 	"^M^[[K"                                                                    
#define 		NORMAL	"[0;39m"                                                               
#define		RED		"[1;31m"                                                                  
#define		GREEN	"[1;32m"                                                                
#define		YELLOW	"[1;33m"                                                               
#define		BLUE	"[1;34m"                                                                 
#define		MAGENTA	"[1;35m"                                                              
#define		CYAN	"[1;36m"                                                                 
#define		WHITE	"[1;37m"

#ifdef DEBUG_ON

int dbgprintf(unsigned int handle, char* pszfmt, ...);
void hexprint(const char* _string, int _len);

#if 1
#define dbg() \
				do{\
					dbgprintf(2, "%s,%s,LINE:%d err", __FILE__, __func__, __LINE__);\
					log2_WriteEx("%s,%s,LINE:%d err", __FILE__, __func__, __LINE__);\
				}while(0)
#else
#define dbg() dbgprintf(2, "%s,%s,LINE:%d err", __FILE__, __func__, __LINE__)
#endif

#define dbgx(i) dbgprintf(0, "%s,%s,%d "#i" = 0x%x", __FILE__, __func__, __LINE__, i)
//#define dbgl(l) dbgprintf(0, "%s,%s,%d "#l" = %ld", __FILE__, __func__, __LINE__, l)
#define dbgll(ll) dbgprintf(0, "%s,%s,%d "#ll" = %lld", __FILE__, __func__, __LINE__, ll)
#define dbgint(i) dbgprintf(0, "%s,%s,%d "#i" = %d", __FILE__, __func__, __LINE__, i)
#define dbgstr(s) dbgprintf(0, "%s,%s,%d "#s" = %s", __FILE__, __func__, __LINE__, s)


#define func_info()\
	do{\
		time_t tUniqueName = time(NULL);\
		printf(BLUE"---------------------------------------------------------------------------------\r\n"NORMAL);\
		printf(BLUE"%s"NORMAL, ctime(&tUniqueName));\
		printf(BLUE"PID = %d, PPID = %d, Thread ID = %lu, Thread Name: %s\r\n"NORMAL, getpid(),getppid(), pthread_self(), __func__);\
		printf(BLUE"Created at line %d, file %s\r\n"NORMAL, __LINE__, __FILE__);\
		printf(BLUE"=================================================================================\r\n\r\n"NORMAL);\
	}while(0)

#define func_exit()\
	do{\
		time_t tUniqueName = time(NULL);\
		printf(RED"---------------------------------------------------------------------------------\r\n"NORMAL);\
		printf(RED"%s"NORMAL, ctime(&tUniqueName));\
		printf(RED"PID = %d, PPID = %d, Thread ID = %lu, Thread Name: %s\r\n"NORMAL, getpid(),getppid(), pthread_self(), __func__);\
		printf(RED"Exit at line %d, file %s\r\n"NORMAL, __LINE__, __FILE__);\
		printf(RED"=================================================================================\r\n\r\n"NORMAL);\
	}while(0)


#else
#define dbgprintf(a,b,...)
#define func_info()
#define func_exit()
#define hexprint(a,...)
#define dbgint(i)
#define dbgx(i)
//#define dbgl(l)
#define dbgll(ll)
#define dbgstr(s)
#define dbg()
#endif

#endif

