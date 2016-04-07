#ifndef _T_DIR_H_
#define _T_DIR_H_

#include <sys/stat.h>
#include <sys/types.h>

//创建目录
int dir_Create(char* _pcDirName);

// 判断路径是否存在，可能是文件夹也可能是文件
int dir_IsExist(char *_pcDir);

// 判断路径是否是文件夹
int dir_IsDir(char *_pcDir);

// 判断是不是. 或者..这种特殊目录
int dir_IsSpecialDir(char *_pcDir);

// 判断路径是否是文件
int dir_IsFile(char *_pcDir);

// 判断路径是否是链接
int dir_IsLink(char *_pcDir);

// 获取一个路径的上一级路径名，比如/home/file，返回/home
char* dir_DirName(char *_pcInDir, char *_pOutDir, int _iOutLen);

// 创建一串路径
// 若_pcDir为"1/2/" 则创建1和2，若_pcDir为"1/2"则创建1
void dir_CreateTree(char *_pcDir);

// 删除目录
void dir_Delete(char *_pcDir);

#endif
