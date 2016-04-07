#include "t_pool.h"
#include "t_base.h"
#include "t_list.h"

#include <stdlib.h>
#include <string.h>

typedef struct PoolMsg
{
	int m_iType;			// 类型
	int m_iNodeSize;		// 节点大小
	int m_iGrowthSum;		// 节点不够时，自动增加的节点个数
	FPoolInit m_fInitNode;	// 节点初始化函数
	#if POOL_USING_LIST	
	TList* m_ptListUsing;	// 使用中的列表
	#endif
	TList* m_ptListFree;	// 没使用的列表
	
}TPoolMsg;

/** @brief    创建节点并添加到链表中
  * @param[out]  _ptList	链表
  * @param[in]  _iNodeSize	节点大小
  * @param[in]  _iSum		要创建的节点数
  * @param[in]  _fInit		节点初始化函数
  * @return  成功返回OK,失败返回ERR
  */
static int CreateNodeToList(TList *_ptList, int _iNodeSize, int _iSum, FPoolInit _fInit)
{
	if(NULL == _ptList)
	{
		dbg();
		return ERR;
	}

	int i = 0;
	char *pcOneNode = NULL;

//	dbgprintf(0, "CreateNodeToList%x %d x %d", _ptList, _iNodeSize, _iSum);
	
	char *NodeList = (char *)malloc(_iNodeSize  * _iSum);

	if(NULL == NodeList)
	{
		dbg();
		goto CREATE_ERR;
	}


	for(i = 0; i < _iSum; i++)
	{
		pcOneNode = NodeList + (i * _iNodeSize);
		
		if(_fInit)
		{
			_fInit(pcOneNode);
		}

		list_PushEnd(_ptList, pcOneNode);
	}

	return OK;
	
CREATE_ERR:
	if(NodeList)
	{
		free(NodeList);
	}
	
	return ERR;
}

/** @brief    创建内存池
  * @param[in]  _iNodeSize	节点大小
  * @param[in]  _iInitSum	首次创建节点个数
  * @param[in]  _fInit		节点初始化函数
  * @param[in]  _iType		内存池类型，固定大小或自动增长
  * @param[in]  _iGrowthSum	节点不够时增长节点个数
  */
TPool* pool_Create(int _iNodeSize, int _iInitSum, FPoolInit _fInit, int _iType, int _iGrowthSum)
{
	TPoolMsg *ptPoolMsg = (TPoolMsg *)malloc(sizeof(TPoolMsg));

	if(NULL == ptPoolMsg)
	{
		dbg();
		goto CREATE_ERR;
	}

	memset(ptPoolMsg, 0, sizeof(TPoolMsg));

	ptPoolMsg->m_iType = _iType;
	ptPoolMsg->m_iNodeSize = _iNodeSize;
	ptPoolMsg->m_iGrowthSum = _iGrowthSum;
	ptPoolMsg->m_fInitNode = _fInit;
	#if POOL_USING_LIST
	ptPoolMsg->m_ptListUsing = list_Create();
	#endif
	ptPoolMsg->m_ptListFree = list_Create();

	#if POOL_USING_LIST
	if(NULL == ptPoolMsg->m_ptListUsing || NULL == ptPoolMsg->m_ptListFree)
	#else
	if(NULL == ptPoolMsg->m_ptListFree)
	#endif
	{
		dbg();
		goto CREATE_ERR;
	}

	CreateNodeToList(ptPoolMsg->m_ptListFree, ptPoolMsg->m_iNodeSize, _iInitSum, ptPoolMsg->m_fInitNode);

	return (TPool *)ptPoolMsg;

CREATE_ERR:
	
	if(ptPoolMsg)
	{
		#if POOL_USING_LIST
		if(ptPoolMsg->m_ptListUsing)
		{
			list_Destroy(ptPoolMsg->m_ptListUsing);
		}
		#endif

		if(ptPoolMsg->m_ptListFree)
		{
			list_Destroy(ptPoolMsg->m_ptListFree);
		}
		
		free(ptPoolMsg);
	}
	
	return NULL;
}

int pool_GetSum(TPool *_ptPool)
{
	TPoolMsg *ptPoolMsg = (TPoolMsg *)(_ptPool);

	if(NULL == ptPoolMsg)
	{
		dbg();
		return 0;
	}

	#if POOL_USING_LIST
	return list_Sum(ptPoolMsg->m_ptListUsing) + list_Sum(ptPoolMsg->m_ptListFree);
	#else
	return list_Sum(ptPoolMsg->m_ptListFree);
	#endif
}

int pool_GetUsingSum(TPool *_ptPool)
{
	TPoolMsg *ptPoolMsg = (TPoolMsg *)(_ptPool);

	if(NULL == ptPoolMsg)
	{
		dbg();
		return 0;
	}

	#if POOL_USING_LIST
	return list_Sum(ptPoolMsg->m_ptListUsing);
	#else
	return 0;
	#endif
}

int pool_GetFreeSum(TPool *_ptPool)
{
	TPoolMsg *ptPoolMsg = (TPoolMsg *)(_ptPool);

	if(NULL == ptPoolMsg)
	{
		dbg();
		return 0;
	}

	return list_Sum(ptPoolMsg->m_ptListFree);
}
	
/** @brief    从内存池中获取一个内存节点
  * @param[in]  _ptPool	内存池
  */
void *pool_New(TPool *_ptPool)
{
	TPoolMsg *ptPoolMsg = (TPoolMsg *)(_ptPool);

	if(NULL == ptPoolMsg)
	{
		dbg();
		return NULL;
	}

	//dbgint(list_Sum(ptPoolMsg->m_ptListFree));

	if(POOL_SIZE_GROWTH == ptPoolMsg->m_iType
		&& list_Sum(ptPoolMsg->m_ptListFree) <= 0)
	{
		CreateNodeToList(ptPoolMsg->m_ptListFree, 
						ptPoolMsg->m_iNodeSize, 
						ptPoolMsg->m_iGrowthSum, 
						ptPoolMsg->m_fInitNode);
	}

	void* ptNode = list_PopHead(ptPoolMsg->m_ptListFree);

	#if POOL_USING_LIST
	if(ptNode)
	{
		list_PushEnd(ptPoolMsg->m_ptListUsing, ptNode);
	}
	#endif
	//dbgx(ptNode);

	//dbgint(list_Sum(ptPoolMsg->m_ptListFree));

	return ptNode;
}

/** @brief    将一个节点重新加入内存池，节点数据没有清空
  * @param[in]  _ptPool			内存池
  * @param[in]  _ptPoolNode		内存节点
  */
int pool_Delete(TPool *_ptPool, void *_ptPoolNode)
{
	TPoolMsg *ptPoolMsg = (TPoolMsg *)(_ptPool);
	TStlHead *ptPoolNode = (TStlHead *)_ptPoolNode;

	if(NULL == ptPoolMsg || NULL == ptPoolNode)
	{
		dbg();
		return ERR;
	}

	//dbgint(list_Sum(ptPoolMsg->m_ptListFree));
	
	#if POOL_USING_LIST
	list_RemoveOne(ptPoolMsg->m_ptListUsing, ptPoolNode);
	#endif
	
	list_PushEnd(ptPoolMsg->m_ptListFree, ptPoolNode);

	//dbgint(list_Sum(ptPoolMsg->m_ptListFree));

	return OK;
}

/** @brief    清空所有节点，但是节点内存和自身结构都没有删除，还在内存中
  */
int pool_Destroy(TPool *_ptPool)
{
	TPoolMsg *ptPoolMsg = (TPoolMsg *)(_ptPool);

	if(NULL == ptPoolMsg)
	{
		dbg();
		return ERR;
	}

	#if POOL_USING_LIST
	list_Clear(ptPoolMsg->m_ptListUsing);
	#endif
	
	list_Clear(ptPoolMsg->m_ptListFree);

	return OK;
}

