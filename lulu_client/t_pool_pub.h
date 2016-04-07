#ifndef _T_POOL_PUB_H_
#define _T_POOL_PUB_H_

#include <pthread.h>

// Pool容量策略
enum
{
	POOL_SIZE_FIXED,		// 固定的，有可能获取资源失败
	POOL_SIZE_GROWTH		// 保证获取资源成功，当资源不够时，自动增长
};

typedef int(* FPoolInit)(void *_ptPoolNode);

#endif
