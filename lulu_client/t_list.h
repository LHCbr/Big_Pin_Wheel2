#ifndef _T_LIST_H_
#define _T_LIST_H_

#include "t_stl.h"

#include <pthread.h>

typedef void TList;

// 创建
TList *list_Create();

// 节点数
int list_Sum(TList *_ptList);

// 清空
int list_Clear(TList *_ptList);

// 插入头
int list_PushHead(TList *_ptList, void *_ptNode);

// 插入尾
int list_PushEnd(TList *_ptList, void *_ptNode);

// 查看某个元素
void* list_At(TList *_ptList, int _iIndex);

// 查看头，不移除
void* list_GetHead(TList *_ptList);

// 查看尾，不移除
void* list_GetEnd(TList *_ptList);

// 获取下一个元素
void* list_GetNext(TList *_ptList, void *_ptNode);

// 获取上一个元素
void* list_GetPrevious(TList *_ptList, void *_ptNode);

// 移除某个元素
int list_RemoveOne(TList *_ptList, void *_ptNode);

// 取出头
void* list_PopHead(TList *_ptList);

// 取出尾
void* list_PopEnd(TList *_ptList);

// 销毁
int list_Destroy(TList *_ptList);

#endif
