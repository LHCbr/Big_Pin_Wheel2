#ifndef _T_FILE_H_
#define _T_FILE_H_

#include <stdio.h>

// 得到一个不重复文件路径
char* file_GetNotRepeat(char *_pcHomeDir, char* _pcSuffix, char *_pcOutFilePath, int _iMaxLen);

void* file_OpenForWrite(char *_pcFileName);
int file_Write(void *_ptFp, char *_pcData, int _iLen);
int file_Close(void *_ptFp);

// 保存至指定目录,并返回文件名
// _pcData 保存数据
// _iLen 数据长度
// _pcDir 路径名
// _pcSuffix 后缀名
// _pcOutFileName 返回文件名
// _iFileNameMaxLen 返回文件名的最大长度
int file_Save(char *_pcData, int _iLen, char *_pcDir, char *_pcSuffix, 
			char* _pcOutFileName, int _iFileNameMaxLen);

// 刷新
int file_Flush(void *_ptFile);

// 读取文件内容
// _pcFileName 文件路径名
// _pcData 存放返回的数据
// _iMaxLen 读取的最大长度
int file_ReadAll(char *_pcFileName, char *_pcData, int _iMaxLen);

// 为读取打开文件
void* file_OpenForRead(char *_pcFileName);

// 读取文件
int file_Read(void *_ptFile, char *_pcData, int _iMaxLen);

// 偏移文件
int file_Seek(void *_ptFile, long int _lOffset, int _iWhence);

// 获取文件大小
int file_GetSize(char *_pcFile);

// 删除文件
int file_Remove(char *_pcFileName);



#endif
