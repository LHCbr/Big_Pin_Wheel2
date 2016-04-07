#include "im_pub_service.h"
#include "im_pub.h"
#include "recv_pool.h"
#include "t_time.h"
#include "t_num.h"
#include "t_char.h"
#include "t_base.h"


#include <string.h>
#include <stdlib.h>
#include <sys/time.h>


uint32_t im_p_GetIndex()
{
   return ((uint32_t)time_GetSecSince1970() - 1418021259) * 1000 + (uint32_t)time_GetCurrentMs();
}

//随机数 + 秒 + 微秒 + 循环
uint64_t im_p_GetIndexLongLong()
{
    int iRand = 1 + rand()% 90;
    static uint32_t iLoop = 9;
    if(iLoop++ >= 9) iLoop = 0;
  
	struct timeval dwNow;
	gettimeofday(&dwNow, NULL);
    return (uint64_t)iRand * 1e17 + (uint64_t)dwNow.tv_sec * 1e7 + (uint64_t)dwNow.tv_usec * 10 + iLoop;
}

int im_p_RemoveHeadNode(TList *_ptList)
{
	void *ptNode = list_PopHead(_ptList);
	return recv_pool_Delete((TRecvNode*)ptNode);
}

// 拷贝_iLen个字节，返回实际拷贝的字节
char* im_p_GetData(char *_pcArray, TList *_ptList, int _iLen)
{
	if(_iLen < 1)
	{
		dbg();
		return NULL;
	}
	
	TRecvNode *ptNode = NULL;
	int iGetLen = 0;
	int iCopyLen = 0;
//	char *pcData = NULL;	
	int iNodeLen = 0;

	do
	{
		// 要处理的第一包数据
		ptNode = (TRecvNode*)list_GetHead(_ptList);

		if(NULL == ptNode)
		{
			//dbg();
			return NULL;
		}

		iNodeLen = ptNode->m_iSum - ptNode->m_iStart; // 第一包数据

		// 移除没有数据的包
		if(iNodeLen <= 0)
		{
			im_p_RemoveHeadNode(_ptList);
		}
		
	}while(iNodeLen <= 0);
	
	// 第一包数据就足够，则直接返回
	if(iNodeLen >= _iLen)
	{
	//	pcData = ptNode->m_pcData + ptNode->m_iStart;
		iGetLen = iNodeLen;
        memcpy(_pcArray, ptNode->m_pcData + ptNode->m_iStart, _iLen);
	}
	else // 把数据全部复制到数组
	{
		memcpy(_pcArray, ptNode->m_pcData + ptNode->m_iStart, iNodeLen);

		iGetLen = iNodeLen;
		
		do
		{
			ptNode = (TRecvNode*)list_GetNext(NULL, ptNode);

			if(NULL == ptNode)
			{
				break;
			}

			iCopyLen = TMIN(_iLen - iGetLen, ptNode->m_iSum - ptNode->m_iStart);
			
			memcpy(_pcArray + iGetLen, ptNode->m_pcData + ptNode->m_iStart, iCopyLen);

			iGetLen += iCopyLen;
			
		}while(iGetLen < _iLen);

	//	pcData = _pcArray;
	}

	//dbgint(_iLen);

	if(iGetLen >= _iLen)
	{
		return _pcArray;//pcData
	}
	else
	{
		//dbg();
		return NULL;
	}
}

int im_p_RemoveData(TList *_ptList, int _iLen)
{
	int iLen = _iLen;
	int iNodeLen = 0;
	TRecvNode *ptNode = NULL;

	if(iLen < 1)
	{
		dbg();
		return ERR;
	}

	do
	{
		ptNode = (TRecvNode*)list_GetHead(_ptList);

		if(NULL == ptNode)
		{
			dbg();
			return ERR;
		}
		
		iNodeLen = ptNode->m_iSum - ptNode->m_iStart;

		//dbgint(ptNode->m_iSum);
		//dbgint(ptNode->m_iStart);
		//dbgint(iNodeLen);
		//dbgint(iLen);

		if(iNodeLen <= 0)
		{
			im_p_RemoveHeadNode(_ptList);
		}
		else if(iLen >= iNodeLen)
		{
			im_p_RemoveHeadNode(_ptList);
			
			iLen -= iNodeLen;
		}
		else
		{
			ptNode->m_iStart += iLen;
			iLen = 0;

			//dbgint(ptNode->m_iStart);
			//dbgint(ptNode->m_iSum);
		}
	}
	while(iLen > 0);

	return OK;
}


