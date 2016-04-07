#ifndef LOG_2_H_
#define LOG_2_H_

// 日志模块全局变量初始化
int log2_Init();

// 获得日志文件的句柄
int log2_Write(char *_pcMsg);

int log2_WriteEx(char* pszfmt, ...);

// 关闭
int log2_Exit();

#endif
