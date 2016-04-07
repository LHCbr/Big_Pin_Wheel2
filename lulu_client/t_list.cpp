#include "t_list.h"
#include "t_base.h"
#include "t_pub.h"

#include <stdlib.h>
#include <string.h>

typedef struct ListMsg
{
	unsigned int m_iSum;						// 当前节点数
	TStlHead *m_ptNodeHead;		// 头
	TStlHead *m_ptNodeEnd;			// 尾
	
	pthread_mutex_t m_Mux;
	
}TListMsg;

TList *list_Create()
{
	TListMsg *ptListMsg = (TListMsg *)malloc(sizeof(TListMsg));

	if(NULL == ptListMsg)
	{
		dbg();
		return NULL;
	}

	ptListMsg->m_iSum			= 0;
	ptListMsg->m_ptNodeHead	= NULL;
	ptListMsg->m_ptNodeEnd		= NULL;
	
	pthread_mutex_init(&ptListMsg->m_Mux, NULL);

	return (TList *)ptListMsg;
}

int list_Sum(TList *_ptList)
{
	TListMsg *ptListMsg = (TListMsg *)_ptList;

	if(NULL == ptListMsg)
	{
		dbg();
		return 0;
	}
	int iRet = 0;	
	LockMx(ptListMsg->m_Mux);
	iRet = ptListMsg->m_iSum;
	UnLockMx(ptListMsg->m_Mux);
	return iRet;
}

int list_PushHead(TList *_ptList, void *_ptNode)
{
	TListMsg* ptListMsg = (TListMsg *)_ptList;
	TStlHead *ptListNode = (TStlHead *)_ptNode;
	
	if(NULL == ptListMsg || NULL == ptListNode)
	{
		dbg();
		return ERR;
	}

	LockMx(ptListMsg->m_Mux);

	#if LIST_TWO_WAY_LINKED
	ptListNode->m_Previous = NULL;
	#endif

	if(NULL == ptListMsg->m_ptNodeHead)
	{
		ptListNode->m_Next = NULL;
		
		ptListMsg->m_ptNodeHead = ptListNode;
		ptListMsg->m_ptNodeEnd = ptListNode;
	}
	else
	{
		#if LIST_TWO_WAY_LINKED
		ptListMsg->m_ptNodeHead->m_Previous = ptListNode;
		#endif
		ptListNode->m_Next = ptListMsg->m_ptNodeHead;
		
		ptListMsg->m_ptNodeHead = ptListNode;
	}
	
	ptListMsg->m_iSum++;

	UnLockMx(ptListMsg->m_Mux);

	return OK;
}

int list_PushEnd(TList *_ptList, void *_ptNode)
{
	TListMsg* ptListMsg = (TListMsg *)_ptList;
	TStlHead *ptListNode = (TStlHead *)_ptNode;
	
	if(NULL == ptListMsg || NULL == ptListNode)
	{
		dbg();
		dbgx(ptListMsg);
		dbgx(ptListNode);
		
		return ERR;
	}

	LockMx(ptListMsg->m_Mux);

	ptListNode->m_Next = NULL;

	if(NULL == ptListMsg->m_ptNodeEnd)
	{
		#if LIST_TWO_WAY_LINKED
		ptListNode->m_Previous = NULL;
		#endif
		
		ptListMsg->m_ptNodeHead = ptListNode;
		ptListMsg->m_ptNodeEnd = ptListNode;
	}
	else
	{
		#if LIST_TWO_WAY_LINKED
		ptListNode->m_Previous = ptListMsg->m_ptNodeEnd;
		#endif
		ptListMsg->m_ptNodeEnd->m_Next = ptListNode;
		
		ptListMsg->m_ptNodeEnd = ptListNode;
	}
	
	ptListMsg->m_iSum++;

	UnLockMx(ptListMsg->m_Mux);

	return OK;
}

void* list_At(TList *_ptList, int _iIndex)
{
	TListMsg* ptListMsg = (TListMsg *)_ptList;

	if(_iIndex < 0 || NULL == ptListMsg)
	{
		dbg();
		return NULL;
	}

	int iFind = 0;
	TStlHead *ptNodeRet = NULL;

	LockMx(ptListMsg->m_Mux);

	if(_iIndex < ptListMsg->m_iSum)
	{
		ptNodeRet = ptListMsg->m_ptNodeHead;

		while(ptNodeRet && iFind++ < _iIndex)
		{
			ptNodeRet = ptNodeRet->m_Next;
		}
	}
	
	UnLockMx(ptListMsg->m_Mux);

	return ptNodeRet;
}

void* list_GetHead(TList *_ptList)
{
	TListMsg* ptListMsg = (TListMsg *)_ptList;
	
	if(NULL == ptListMsg)
	{
		//dbg();
		return NULL;
	}
	
	TStlHead *ptNodeRet = NULL;

	LockMx(ptListMsg->m_Mux);

	ptNodeRet = ptListMsg->m_ptNodeHead;

	UnLockMx(ptListMsg->m_Mux);

	return ptNodeRet;
}

void* list_GetEnd(TList *_ptList)
{
	TListMsg* ptListMsg = (TListMsg *)_ptList;
	
	if(NULL == ptListMsg)
	{
		dbg();
		return NULL;
	}
	
	TStlHead *ptNodeRet = NULL;

	LockMx(ptListMsg->m_Mux);

	ptNodeRet = ptListMsg->m_ptNodeEnd;

	UnLockMx(ptListMsg->m_Mux);

	return ptNodeRet;
}

void* list_GetNext(TList *_ptList, void *_ptNode)
{
	TStlHead* ptNode = (TStlHead *)_ptNode;

	if(NULL == ptNode)
	{
		dbg();
		return NULL;
	}

	return ptNode->m_Next;
}

// 获取上一个元素
void* list_GetPrevious(TList *_ptList, void *_ptNode)
{
	#if LIST_TWO_WAY_LINKED
	TStlHead* ptNode = (TStlHead *)_ptNode;

	if(NULL == ptNode)
	{
		dbg();
		return NULL;
	}

	return ptNode->m_Previous;
	#endif

	return NULL;
}

int list_RemoveOne(TList *_ptList, void *_ptNode)
{
	TListMsg* ptListMsg = (TListMsg *)_ptList;
	
	if(NULL == ptListMsg)
	{
		dbg();
		return ERR;
	}

	LockMx(ptListMsg->m_Mux);

	TStlHead* ptNodeFind = NULL;

	#if !(LIST_TWO_WAY_LINKED)	// 双链表
	TStlHead* ptNodeLast = NULL;
	#endif
	
	if(_ptNode == ptListMsg->m_ptNodeHead)
	{
		if(ptListMsg->m_ptNodeHead != ptListMsg->m_ptNodeEnd)
		{
			ptListMsg->m_ptNodeHead = ptListMsg->m_ptNodeHead->m_Next;
			#if LIST_TWO_WAY_LINKED
			ptListMsg->m_ptNodeHead->m_Previous = NULL;
			#endif
		}
		else
		{
			ptListMsg->m_ptNodeHead = NULL;
			ptListMsg->m_ptNodeEnd = NULL;
		}

		if(ptListMsg->m_iSum > 0) ptListMsg->m_iSum--;
	}
	#if LIST_TWO_WAY_LINKED
	else if(_ptNode == ptListMsg->m_ptNodeEnd)
	{
		if(ptListMsg->m_ptNodeHead != ptListMsg->m_ptNodeEnd)
		{
			
			ptListMsg->m_ptNodeEnd = ptListMsg->m_ptNodeEnd->m_Previous;
			ptListMsg->m_ptNodeEnd->m_Next= NULL;
		}
		else
		{
			ptListMsg->m_ptNodeHead = NULL;
			ptListMsg->m_ptNodeEnd = NULL;
		}

		if(ptListMsg->m_iSum > 0) ptListMsg->m_iSum--;
	}
	#endif
	else if(ptListMsg->m_ptNodeHead) // 保证列表中有元素
	{
		#if LIST_TWO_WAY_LINKED	// 双链表
		ptNodeFind = ptListMsg->m_ptNodeHead;

		while(ptNodeFind)
		{
			if(_ptNode == ptNodeFind)
			{
				ptNodeFind->m_Previous->m_Next = ptNodeFind->m_Next;

				if(ptNodeFind->m_Next)
				{
					ptNodeFind->m_Next->m_Previous = ptNodeFind->m_Previous;
				}
				
				if(ptListMsg->m_iSum > 0) ptListMsg->m_iSum--;
				break;
			}
			
			ptNodeFind = ptNodeFind->m_Next;
		}
		#else // 单链表
		ptNodeLast = ptListMsg->m_ptNodeHead;
		ptNodeFind = ptNodeLast->m_Next;

		while(ptNodeFind)
		{
			if(_ptNode == ptNodeFind)
			{
				break;
			}
			
			ptNodeLast = ptNodeFind;
			ptNodeFind = ptNodeFind->m_Next;
		}

		if(ptNodeFind)
		{
			ptNodeLast->m_Next = ptNodeFind->m_Next;

			if(ptNodeFind == ptListMsg->m_ptNodeEnd)
			{
				ptListMsg->m_ptNodeEnd = ptNodeLast;
			}

			if(ptListMsg->m_iSum > 0) ptListMsg->m_iSum--;
		}
		#endif
	}

	UnLockMx(ptListMsg->m_Mux);

	return OK;
}

void* list_PopHead(TList *_ptList)
{
	TListMsg* ptListMsg = (TListMsg *)_ptList;
	
	if(NULL == ptListMsg)
	{
		dbg();
		return NULL;
	}

	LockMx(ptListMsg->m_Mux);

	TStlHead* ptNodeRet = ptListMsg->m_ptNodeHead;

	if(NULL == ptNodeRet)
	{
		goto EXIT;
	}

	if(ptListMsg->m_ptNodeHead != ptListMsg->m_ptNodeEnd)
	{
		ptListMsg->m_ptNodeHead = ptListMsg->m_ptNodeHead->m_Next;

		#if LIST_TWO_WAY_LINKED
		ptListMsg->m_ptNodeHead->m_Previous = NULL;
		#endif
	}
	else
	{
		ptListMsg->m_ptNodeHead = NULL;
		ptListMsg->m_ptNodeEnd = NULL;
	}

	if(ptListMsg->m_iSum > 0) ptListMsg->m_iSum--;

EXIT:
	UnLockMx(ptListMsg->m_Mux);	

	return ptNodeRet;
}

void* list_PopEnd(TList *_ptList)
{
	TListMsg* ptListMsg = (TListMsg *)_ptList;
	
	if(NULL == ptListMsg)
	{
		dbg();
		return NULL;
	}

	LockMx(ptListMsg->m_Mux);

	TStlHead* ptNodeRet = ptListMsg->m_ptNodeEnd;

	if(NULL == ptNodeRet)
	{
		dbg();
		goto EXIT;
	}

	#if LIST_TWO_WAY_LINKED	// 双链表
	if(ptListMsg->m_ptNodeHead != ptListMsg->m_ptNodeEnd)
	{
		ptListMsg->m_ptNodeEnd = ptListMsg->m_ptNodeEnd->m_Previous;
		ptListMsg->m_ptNodeEnd->m_Next = NULL;
	}
	#else // 单链表

	TStlHead* ptNodeFind = NULL;
	
	if(ptListMsg->m_ptNodeHead != ptListMsg->m_ptNodeEnd)
	{
		ptNodeFind = ptListMsg->m_ptNodeHead;

		while(ptNodeFind)
		{
			if(ptNodeFind->m_Next == ptListMsg->m_ptNodeEnd)
			{
				ptNodeFind->m_Next = NULL;
				ptListMsg->m_ptNodeEnd = ptNodeFind;

				break;
			}
		}
	}
	#endif
	else
	{
		ptListMsg->m_ptNodeHead = NULL;
		ptListMsg->m_ptNodeEnd = NULL;
	}

	if(ptListMsg->m_iSum > 0) ptListMsg->m_iSum--;

EXIT:
	UnLockMx(ptListMsg->m_Mux);	

	return ptNodeRet;
}

int list_Clear(TList *_ptList)
{
	TListMsg *ptListMsg = (TListMsg *)_ptList;
	
	if(NULL == ptListMsg)
	{
		dbg();
		return ERR;
	}

	LockMx(ptListMsg->m_Mux);
	
	ptListMsg->m_ptNodeHead = NULL;
	ptListMsg->m_ptNodeEnd = NULL;

	ptListMsg->m_iSum = 0;

	UnLockMx(ptListMsg->m_Mux);

	return OK;
}

int list_Destroy(TList *_ptList)
{
	TListMsg *ptListMsg = (TListMsg *)_ptList;
	
	if(NULL == ptListMsg)
	{
		dbg();
		return ERR;
	}

	list_Clear(_ptList);

	pthread_mutex_destroy(&ptListMsg->m_Mux);

	free(ptListMsg);
	ptListMsg = NULL;

	return OK;
}


