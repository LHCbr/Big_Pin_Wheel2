#ifndef _IM_PUB_SERVICE_H_
#define _IM_PUB_SERVICE_H_

#include <stdint.h>
#include "t_list.h"


uint32_t im_p_GetIndex();
uint64_t im_p_GetIndexLongLong();


int im_p_RemoveHeadNode(TList *_ptList);

// 拷贝_iLen个字节，返回实际拷贝的字节
char* im_p_GetData(char *_pcArray, TList *_ptList, int _iLen);

// 移除_iLen个字节
int im_p_RemoveData(TList *_ptList, int _iLen);


#endif

