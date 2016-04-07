#ifndef _T_POOL_H_
#define _T_POOL_H_

#include "t_pool_pub.h"

// pool中可以不保存使用列表
#define POOL_USING_LIST		0

typedef void TPool;

// _iSize 池中数据块的大小
// _iMaxSum 池中数据块的数目
// _fInit 数据块的初始化回调函数
TPool* pool_Create(int _iNodeSize, int _iInitSum, FPoolInit _fInit, int _iType, int _iGrowthSum);
int pool_GetSum(TPool *_ptPool);
int pool_GetUsingSum(TPool *_ptPool);
int pool_GetFreeSum(TPool *_ptPool);

void *pool_New(TPool *_ptPool);
int pool_Delete(TPool *_ptPool, void *_ptPoolNode);

int pool_Destroy(TPool *_ptPool);

#endif
