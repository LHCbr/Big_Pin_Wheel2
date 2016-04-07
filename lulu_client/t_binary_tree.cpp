#include "t_binary_tree.h"

#include "t_base.h"
#include "t_pub.h"

#include <stdlib.h>
#include <string.h>

typedef struct BinaryTreeMsg
{
	int m_iNodeSize;
	TBinaryTreeNodeHead *m_ptHead;
	FBinaryTreeCompareFun m_pfBinaryTreeCompare;
	//FBinaryTreeFindFun m_pfBinaryTreeFind;
	FBinaryTreeCopyFun m_pfBinaryTreeCopy;
	FBinaryTreeDestroyFun m_pfBinaryTreeDestroy;
	pthread_mutex_t m_Lock;

}TBinaryTreeMsg;


TBinaryTree* binary_tree_Create(int _iNodeSize,
										FBinaryTreeCompareFun _pfBinaryTreeCompare, 
										//FBinaryTreeFindFun _pfBinaryTreeFind,
										FBinaryTreeCopyFun _pfBinaryTreeCopy,
										FBinaryTreeDestroyFun _pfBinaryTreeDestroy)
{
	if(_iNodeSize <= 0 
		|| NULL == _pfBinaryTreeCompare //|| NULL == _pfBinaryTreeFind 
		|| NULL == _pfBinaryTreeCopy || NULL == _pfBinaryTreeDestroy)
	{
		dbg();
		return NULL;
	}
	
	TBinaryTreeMsg *ptBinaryTreeMsg = (TBinaryTreeMsg *)malloc(sizeof(TBinaryTreeMsg));

	if(NULL == ptBinaryTreeMsg)
	{
		dbg();
		return NULL;
	}

	ptBinaryTreeMsg->m_iNodeSize = _iNodeSize;
	ptBinaryTreeMsg->m_ptHead = NULL;
	ptBinaryTreeMsg->m_pfBinaryTreeCompare = _pfBinaryTreeCompare;
	//ptBinaryTreeMsg->m_pfBinaryTreeFind = _pfBinaryTreeFind;
	ptBinaryTreeMsg->m_pfBinaryTreeCopy = _pfBinaryTreeCopy;
	ptBinaryTreeMsg->m_pfBinaryTreeDestroy = _pfBinaryTreeDestroy;
	Lock_Init(ptBinaryTreeMsg->m_Lock);

	return (TBinaryTree*)ptBinaryTreeMsg;
}

int binary_tree_Destroy(TBinaryTree *_ptBinaryTree)
{
	TBinaryTreeMsg *ptBinaryTreeMsg = (TBinaryTreeMsg *)_ptBinaryTree;

	if(ptBinaryTreeMsg)
	{
		free(ptBinaryTreeMsg);
	}

	return OK;
}

static int InsertNode(FBinaryTreeCompareFun _pfBinaryTreeCompare, 
							TBinaryTreeNodeHead *_ptInsertNode, 
							TBinaryTreeNodeHead **_pptBinaryNode)
{
	if(NULL == _pfBinaryTreeCompare || NULL == _ptInsertNode || NULL == _pptBinaryNode)
	{
		dbg();
		return ERR;
	}

	// 初始化
	_ptInsertNode->m_ptLeft = NULL;
	_ptInsertNode->m_ptRight = NULL;
	_ptInsertNode->m_ptNext = NULL;

	int iCompare = _pfBinaryTreeCompare(0, _ptInsertNode, *_pptBinaryNode);

	//dbgint(iCompare);
	//dbgx((*_pptBinaryNode));
	
	if(NULL == *_pptBinaryNode)
    {
        *_pptBinaryNode = _ptInsertNode;
    }
    else if(BINARY_TREE_COMPARE_RIGHT == iCompare)
    {
        InsertNode(_pfBinaryTreeCompare, _ptInsertNode, &((*_pptBinaryNode)->m_ptLeft));
    }
    else if(BINARY_TREE_COMPARE_LEFT == iCompare)
    {
        InsertNode(_pfBinaryTreeCompare, _ptInsertNode, &((*_pptBinaryNode)->m_ptRight));
    }
	else if(BINARY_TREE_COMPARE_DO == iCompare || BINARY_TREE_COMPARE_PASS == iCompare)
	{
		_ptInsertNode->m_ptNext = *_pptBinaryNode;
		_ptInsertNode->m_ptLeft = (*_pptBinaryNode)->m_ptLeft;
		_ptInsertNode->m_ptRight = (*_pptBinaryNode)->m_ptRight;
		
		*_pptBinaryNode = _ptInsertNode;
	}
    else
    {
		dbg();
	}

	return OK;
}

int binary_tree_Insert(TBinaryTree *_ptBinaryTree, void *_ptNode)
{
	TBinaryTreeMsg *ptBinaryTreeMsg = (TBinaryTreeMsg *)_ptBinaryTree;
	TBinaryTreeNodeHead *ptNode = (TBinaryTreeNodeHead *)_ptNode;

	if(NULL == ptBinaryTreeMsg)
	{
		dbg();
		return ERR;
	}

	int iRet = ERR;

	LockMx(ptBinaryTreeMsg->m_Lock);

	iRet = InsertNode(ptBinaryTreeMsg->m_pfBinaryTreeCompare,
						ptNode, &ptBinaryTreeMsg->m_ptHead);

	UnLockMx(ptBinaryTreeMsg->m_Lock);

	//dbgint(binary_tree_Display(_ptBinaryTree, BINARY_TREE_DISPLAY_MIDDLE));

	return iRet;
}

// iIndex 当前已找到的节点数
static int GetNode(TBinaryTreeMsg *_ptBinaryTreeMsg, int _iType, TBinaryTreeNodeHead *_ptNode,
						void *_ptKey, int *_piIndex, void **_pptNodeArray, int _iMaxCount)
{
	if(NULL == _ptBinaryTreeMsg || NULL == _ptBinaryTreeMsg->m_pfBinaryTreeCompare)
	{
		dbg();
		return ERR;
	}

	int iFind = _ptBinaryTreeMsg->m_pfBinaryTreeCompare(_iType, _ptNode, _ptKey);
	
	//dbgx(_ptNode);
	//dbgint(iFind);

	if(BINARY_TREE_COMPARE_DO == iFind || BINARY_TREE_COMPARE_PASS == iFind)
    {
    	TBinaryTreeNodeHead *ptSubNode = _ptNode;
		
    	while(*_piIndex < _iMaxCount)
    	{
 //   		dbgint(iFind);
    		if(BINARY_TREE_COMPARE_DO == iFind)
    		{
    			_pptNodeArray[(*_piIndex)++] = ptSubNode;
    		}

			ptSubNode = ptSubNode->m_ptNext;

			if(ptSubNode)
			{
				iFind = _ptBinaryTreeMsg->m_pfBinaryTreeCompare(_iType, ptSubNode, _ptKey);
			}
			else
			{
				break;
			}
    	}

		// 判断是不是继续搜索
		if(*_piIndex < _iMaxCount)
		{
//			dbgint(_iMaxCount);
			// 判断左分支
			iFind = _ptBinaryTreeMsg->m_pfBinaryTreeCompare(_iType, _ptNode->m_ptLeft, _ptKey);
			
			if(BINARY_TREE_COMPARE_DO == iFind || BINARY_TREE_COMPARE_PASS == iFind 
				|| BINARY_TREE_COMPARE_LEFT == iFind)
			{
				GetNode(_ptBinaryTreeMsg, _iType, _ptNode->m_ptLeft, _ptKey, _piIndex, _pptNodeArray, _iMaxCount);
			}

	//		dbgint(_iMaxCount);
			// 判断右分支
			iFind = _ptBinaryTreeMsg->m_pfBinaryTreeCompare(_iType, _ptNode->m_ptRight, _ptKey);

			if(BINARY_TREE_COMPARE_DO == iFind || BINARY_TREE_COMPARE_PASS == iFind 
				|| BINARY_TREE_COMPARE_RIGHT == iFind)
			{
				GetNode(_ptBinaryTreeMsg, _iType, _ptNode->m_ptRight, _ptKey, _piIndex, _pptNodeArray, _iMaxCount);
			}
		}
		
		return OK;
    }
    else if(BINARY_TREE_COMPARE_LEFT == iFind)
    {
        return GetNode(_ptBinaryTreeMsg, _iType, _ptNode->m_ptLeft, _ptKey, _piIndex, _pptNodeArray, _iMaxCount);
    }
    else if(BINARY_TREE_COMPARE_RIGHT == iFind)
    {
        return GetNode(_ptBinaryTreeMsg, _iType, _ptNode->m_ptRight, _ptKey, _piIndex, _pptNodeArray, _iMaxCount);
    }
	else
	{
		//dbg();
		return ERR;
	}
}


int binary_tree_Get(TBinaryTree *_ptBinaryTree, int _iType, void *_ptKey, void **_pptNodeArray, int _iMaxCount)
{
	TBinaryTreeMsg *ptBinaryTreeMsg = (TBinaryTreeMsg *)_ptBinaryTree;

	if(NULL == ptBinaryTreeMsg)
	{
		dbg();
		return 0;
	}

	int iIndex = 0;

	LockMx(ptBinaryTreeMsg->m_Lock);

	//dbgx(ptBinaryTreeMsg->m_ptHead);
	//dbgx(_ptKey);
	
	GetNode(ptBinaryTreeMsg, _iType, ptBinaryTreeMsg->m_ptHead, 
						_ptKey, &iIndex, _pptNodeArray, _iMaxCount);

	UnLockMx(ptBinaryTreeMsg->m_Lock);

	return iIndex;
}

// iIndex 当前已找到的节点数
static int FindNode(TBinaryTreeMsg *_ptBinaryTreeMsg, int _iType, TBinaryTreeNodeHead *_ptNode,
						void *_ptKey, int *_piIndex, void *_ptNodeArray, int _iMaxCount)
{
	if(NULL == _ptBinaryTreeMsg || NULL == _ptBinaryTreeMsg->m_pfBinaryTreeCompare 
		|| NULL == _ptBinaryTreeMsg->m_pfBinaryTreeCopy)
	{
		dbg();
		return ERR;
	}

	//dbgx(_ptNode);
	//dbgx(_ptKey);
	
	int iFind = _ptBinaryTreeMsg->m_pfBinaryTreeCompare(_iType, _ptNode, _ptKey);

	//dbgint(iFind);
	//dbgx(_ptNode);

	if(BINARY_TREE_COMPARE_DO == iFind || BINARY_TREE_COMPARE_PASS == iFind)
    {
		TBinaryTreeNodeHead *ptSubNode = _ptNode;
	
    	while(*_piIndex < _iMaxCount)
    	{
    		if(BINARY_TREE_COMPARE_DO == iFind)
    		{
				_ptBinaryTreeMsg->m_pfBinaryTreeCopy(((char *)_ptNodeArray + (*_piIndex) * _ptBinaryTreeMsg->m_iNodeSize), 
													_ptNode);

				(*_piIndex)++;
    		}
			
			ptSubNode = ptSubNode->m_ptNext;

			if(ptSubNode)
			{
				iFind = _ptBinaryTreeMsg->m_pfBinaryTreeCompare(_iType, ptSubNode, _ptKey);
			}
			else
			{
				break;
			}
    	}

		// 判断是不是继续搜索
		if(*_piIndex < _iMaxCount)
		{
			// 判断左分支
			iFind = _ptBinaryTreeMsg->m_pfBinaryTreeCompare(_iType, _ptNode->m_ptLeft, _ptKey);
			
			if(BINARY_TREE_COMPARE_DO == iFind || BINARY_TREE_COMPARE_PASS == iFind 
				|| BINARY_TREE_COMPARE_LEFT == iFind)
			{
				FindNode(_ptBinaryTreeMsg, _iType, _ptNode->m_ptLeft, _ptKey, _piIndex, _ptNodeArray, _iMaxCount);
			}

			// 判断右分支
			iFind = _ptBinaryTreeMsg->m_pfBinaryTreeCompare(_iType, _ptNode->m_ptRight, _ptKey);

			if(BINARY_TREE_COMPARE_DO == iFind || BINARY_TREE_COMPARE_PASS == iFind 
				|| BINARY_TREE_COMPARE_RIGHT == iFind)
			{
				FindNode(_ptBinaryTreeMsg, _iType, _ptNode->m_ptRight, _ptKey, _piIndex, _ptNodeArray, _iMaxCount);
			}
		}
		
		return OK;
    }
    else if(BINARY_TREE_COMPARE_LEFT == iFind)
    {
        return FindNode(_ptBinaryTreeMsg, _iType, _ptNode->m_ptLeft, _ptKey, _piIndex, _ptNodeArray, _iMaxCount);
    }
    else if(BINARY_TREE_COMPARE_RIGHT == iFind)
    {
        return FindNode(_ptBinaryTreeMsg, _iType, _ptNode->m_ptRight, _ptKey, _piIndex, _ptNodeArray, _iMaxCount);
    }
	else
	{
		//dbg();
		return ERR;
	}
}

int binary_tree_Find(TBinaryTree *_ptBinaryTree, int _iType, void *_ptKey, void *_ptNodeArray, int _iMaxCount)
{
	TBinaryTreeMsg *ptBinaryTreeMsg = (TBinaryTreeMsg *)_ptBinaryTree;

	if(NULL == ptBinaryTreeMsg)
	{
		dbg();
		return 0;
	}

	int iIndex = 0;

	LockMx(ptBinaryTreeMsg->m_Lock);
	
	FindNode(ptBinaryTreeMsg, _iType, ptBinaryTreeMsg->m_ptHead, 
						_ptKey, &iIndex, _ptNodeArray, _iMaxCount);

	UnLockMx(ptBinaryTreeMsg->m_Lock);

	return iIndex;
}

static int FindMinNode(TBinaryTreeMsg *_ptBinaryTreeMsg,
								TBinaryTreeNodeHead **_pptFindNode,
								TBinaryTreeNodeHead *_ptNode)
{
	if(NULL == _ptBinaryTreeMsg || NULL == _ptBinaryTreeMsg->m_pfBinaryTreeCompare
		|| NULL == _pptFindNode)
	{
		dbg();
		return ERR;
	}

	if(_ptNode)
	{
		if(BINARY_TREE_COMPARE_LEFT == _ptBinaryTreeMsg->m_pfBinaryTreeCompare(0, *_pptFindNode, _ptNode))
		{
			*_pptFindNode = _ptNode;
		}

		FindMinNode(_ptBinaryTreeMsg, _pptFindNode, _ptNode->m_ptLeft);
	}

	return OK;
}

static TBinaryTreeNodeHead* FindMin(TBinaryTreeMsg *_ptBinaryTreeMsg,
										TBinaryTreeNodeHead *_ptNode)
{
	if(NULL == _ptNode)
	{
		dbg();
		return NULL;
	}
	
	TBinaryTreeNodeHead* ptFindNode = _ptNode;

	FindMinNode(_ptBinaryTreeMsg, &ptFindNode, _ptNode->m_ptLeft);

	return ptFindNode;
}

// _iPointChildren 对于子节点的指向是否替换
static int Replace(TBinaryTreeMsg *_ptBinaryTreeMsg, TBinaryTreeNodeHead **_pptDstNode, 
						TBinaryTreeNodeHead *_ptSrcNode, int _iPointChildren)
{
	if(NULL == _ptBinaryTreeMsg || NULL == _ptBinaryTreeMsg->m_pfBinaryTreeCopy 
		|| NULL == _pptDstNode)
	{
		dbg();
		return ERR;
	}

	if(NULL == _ptSrcNode)
	{
		*_pptDstNode = NULL;
		return OK;
	}

	_ptBinaryTreeMsg->m_pfBinaryTreeCopy(*_pptDstNode, _ptSrcNode);

	if(_iPointChildren)
	{
		(*_pptDstNode)->m_ptLeft = _ptSrcNode->m_ptLeft;
		(*_pptDstNode)->m_ptRight = _ptSrcNode->m_ptRight;
	}

	return OK;
}

static int RemoveNodeByValue(TBinaryTreeMsg *_ptBinaryTreeMsg, 
										TBinaryTreeNodeHead *_ptRemoveNode, 
										TBinaryTreeNodeHead **_pptBinaryNode)
{
	if(NULL == _ptBinaryTreeMsg || NULL == _ptBinaryTreeMsg->m_pfBinaryTreeCompare
		|| NULL == _ptRemoveNode || NULL == _pptBinaryNode)
	{
		dbg();
		return ERR;
	}

	int iCompare = _ptBinaryTreeMsg->m_pfBinaryTreeCompare(0, _ptRemoveNode, *_pptBinaryNode);
	TBinaryTreeNodeHead *ptTmpNode = NULL;

	if(BINARY_TREE_COMPARE_RIGHT == iCompare)
	{
		RemoveNodeByValue(_ptBinaryTreeMsg, _ptRemoveNode, &((*_pptBinaryNode)->m_ptLeft));
	}
	else if(BINARY_TREE_COMPARE_LEFT == iCompare)
	{
		RemoveNodeByValue(_ptBinaryTreeMsg, _ptRemoveNode, &((*_pptBinaryNode)->m_ptRight));
	}
	else if(BINARY_TREE_COMPARE_DO == iCompare || BINARY_TREE_COMPARE_PASS == iCompare)/////////////////////////////////
	{
		if((*_pptBinaryNode)->m_ptLeft && (*_pptBinaryNode)->m_ptRight) // two children
		{
			ptTmpNode = FindMin(_ptBinaryTreeMsg, (*_pptBinaryNode)->m_ptRight);

			if(ptTmpNode)
			{
				Replace(_ptBinaryTreeMsg, _pptBinaryNode, ptTmpNode, 0);
				
				RemoveNodeByValue(_ptBinaryTreeMsg, ptTmpNode, &((*_pptBinaryNode)->m_ptRight));
			}
		}
		else if((*_pptBinaryNode)->m_ptLeft || (*_pptBinaryNode)->m_ptRight) 
		{
			ptTmpNode = (*_pptBinaryNode)->m_ptLeft ? (*_pptBinaryNode)->m_ptLeft : (*_pptBinaryNode)->m_ptRight;
		
			Replace(_ptBinaryTreeMsg, _pptBinaryNode, ptTmpNode, 1);

			if(_ptBinaryTreeMsg->m_pfBinaryTreeDestroy)
			{
				_ptBinaryTreeMsg->m_pfBinaryTreeDestroy(ptTmpNode);
			}
		}
		else
		{
			if(_ptBinaryTreeMsg->m_pfBinaryTreeDestroy)
			{
				_ptBinaryTreeMsg->m_pfBinaryTreeDestroy(*_pptBinaryNode);
			}

			*_pptBinaryNode = NULL;
		}
	}
	else
	{
		dbg();
	}

	return OK;
}

int binary_tree_RemoveByValue(TBinaryTree *_ptBinaryTree, void *_ptNode)
{
	TBinaryTreeMsg *ptBinaryTreeMsg = (TBinaryTreeMsg *)_ptBinaryTree;
	TBinaryTreeNodeHead *ptNode = (TBinaryTreeNodeHead *)_ptNode;

	int iRet = ERR;

	LockMx(ptBinaryTreeMsg->m_Lock);
	
	iRet = RemoveNodeByValue(ptBinaryTreeMsg, ptNode, &ptBinaryTreeMsg->m_ptHead);

	UnLockMx(ptBinaryTreeMsg->m_Lock);

	//dbgint(binary_tree_Display(_ptBinaryTree, BINARY_TREE_DISPLAY_MIDDLE));

	return iRet;
}

static int RemoveNode(TBinaryTreeMsg *_ptBinaryTreeMsg, 
										TBinaryTreeNodeHead *_ptRemoveNode, 
										TBinaryTreeNodeHead **_pptBinaryNode)
{
	if(NULL == _ptBinaryTreeMsg || NULL == _ptBinaryTreeMsg->m_pfBinaryTreeCompare
		|| NULL == _ptRemoveNode || NULL == _pptBinaryNode)
	{
		dbg();
		return ERR;
	}

	int iCompare = _ptBinaryTreeMsg->m_pfBinaryTreeCompare(0, _ptRemoveNode, *_pptBinaryNode);
	TBinaryTreeNodeHead *ptTmpNode = NULL;

	if(BINARY_TREE_COMPARE_RIGHT == iCompare)
	{
		RemoveNode(_ptBinaryTreeMsg, _ptRemoveNode, &((*_pptBinaryNode)->m_ptLeft));
	}
	else if(BINARY_TREE_COMPARE_LEFT == iCompare)
	{
		RemoveNode(_ptBinaryTreeMsg, _ptRemoveNode, &((*_pptBinaryNode)->m_ptRight));
	}
	else if(_ptRemoveNode == *_pptBinaryNode)/////////////////////////////////
	{
		if((*_pptBinaryNode)->m_ptLeft && (*_pptBinaryNode)->m_ptRight) // two children
		{
			ptTmpNode = FindMin(_ptBinaryTreeMsg, (*_pptBinaryNode)->m_ptRight);

			if(ptTmpNode)
			{
				Replace(_ptBinaryTreeMsg, _pptBinaryNode, ptTmpNode, 0);
				
				RemoveNode(_ptBinaryTreeMsg, ptTmpNode, &((*_pptBinaryNode)->m_ptRight));
			}
		}
		else if((*_pptBinaryNode)->m_ptLeft || (*_pptBinaryNode)->m_ptRight) 
		{
			ptTmpNode = (*_pptBinaryNode)->m_ptLeft ? (*_pptBinaryNode)->m_ptLeft : (*_pptBinaryNode)->m_ptRight;
		
			Replace(_ptBinaryTreeMsg, _pptBinaryNode, ptTmpNode, 1);

			if(_ptBinaryTreeMsg->m_pfBinaryTreeDestroy)
			{
				_ptBinaryTreeMsg->m_pfBinaryTreeDestroy(ptTmpNode);
			}
		}
		else
		{
			if(_ptBinaryTreeMsg->m_pfBinaryTreeDestroy)
			{
				_ptBinaryTreeMsg->m_pfBinaryTreeDestroy(*_pptBinaryNode);
			}

			*_pptBinaryNode = NULL;
		}
	}
	else
	{
		dbg();
	}

	return OK;
}


int binary_tree_Remove(TBinaryTree *_ptBinaryTree, void *_ptNode)
{
	TBinaryTreeMsg *ptBinaryTreeMsg = (TBinaryTreeMsg *)_ptBinaryTree;
	TBinaryTreeNodeHead *ptNode = (TBinaryTreeNodeHead *)_ptNode;

	int iRet = ERR;

	LockMx(ptBinaryTreeMsg->m_Lock);
	
	iRet = RemoveNode(ptBinaryTreeMsg, ptNode, &ptBinaryTreeMsg->m_ptHead);

	UnLockMx(ptBinaryTreeMsg->m_Lock);

	//dbgint(binary_tree_Display(_ptBinaryTree, BINARY_TREE_DISPLAY_MIDDLE));

	return iRet;
}

static void DisplayNode(TBinaryTreeNodeHead *_ptNode)
{
	while(_ptNode)
	{
		dbgprintf(0, "-----------------------------------");
		dbgprintf(0, "DisplayNode %x", _ptNode);

		_ptNode = _ptNode->m_ptNext;
	}
}

static void DiaplayBefore(TBinaryTreeNodeHead *_ptNode)
{
    if(NULL == _ptNode)
    {
        return;
    }

    DisplayNode(_ptNode);
    DiaplayBefore(_ptNode->m_ptLeft);
    DiaplayBefore(_ptNode->m_ptRight);
}

static void DiaplayMiddle(TBinaryTreeNodeHead *_ptNode)
{
    if(NULL == _ptNode)
    {
        return;
    }

    DiaplayMiddle(_ptNode->m_ptLeft);
    DisplayNode(_ptNode);
    DiaplayMiddle(_ptNode->m_ptRight);
}

static void DiaplayAffter(TBinaryTreeNodeHead *_ptNode)
{
    if(NULL == _ptNode)
    {
        return;
    }

    DiaplayAffter(_ptNode->m_ptLeft);
    DiaplayAffter(_ptNode->m_ptRight);
    DisplayNode(_ptNode);
}

int binary_tree_Display(TBinaryTree *_ptBinaryTree, int _iType)
{
	TBinaryTreeMsg *ptBinaryTreeMsg = (TBinaryTreeMsg *)_ptBinaryTree;

	if(NULL == ptBinaryTreeMsg)
	{
		dbg();
		return ERR;
	}

	LockMx(ptBinaryTreeMsg->m_Lock);

	switch(_iType)
    {
    case BINARY_TREE_DISPLAY_BEFORE:
        dbgprintf(0, "Node Left Right");
        DiaplayBefore(ptBinaryTreeMsg->m_ptHead);
        break;

    case BINARY_TREE_DISPLAY_MIDDLE:
        dbgprintf(0, "Left Node Right");
        DiaplayMiddle(ptBinaryTreeMsg->m_ptHead);
        break;

    case BINARY_TREE_DISPLAY_AFTER:
        dbgprintf(0, "Left Right Node");
        DiaplayAffter(ptBinaryTreeMsg->m_ptHead);
        break;

    default:
        break;
    }

	UnLockMx(ptBinaryTreeMsg->m_Lock);

	return OK;
}

static void TraversalAffter(TBinaryTreeNodeHead *_ptNode, FTraversalNode _pfTraversalNode)
{
    if(NULL == _ptNode)
    {
        return;
    }

    TraversalAffter(_ptNode->m_ptLeft, _pfTraversalNode);
    TraversalAffter(_ptNode->m_ptRight, _pfTraversalNode);

	TBinaryTreeNodeHead *ptFindNode = NULL;
	TBinaryTreeNodeHead *ptNextNode = NULL;
	
	if(_pfTraversalNode)
	{
		ptFindNode = _ptNode;
		
		while(ptFindNode)
		{
			ptNextNode = ptFindNode->m_ptNext;
			_pfTraversalNode(ptFindNode);

			ptFindNode = ptNextNode;//ptFindNode->m_ptNext; //如果执行的是删除操作，这里就有问题
		}
	}
}


int binary_tree_Traversal(TBinaryTree *_ptBinaryTree, FTraversalNode _pfTraversalNode)
{
	TBinaryTreeMsg *ptBinaryTreeMsg = (TBinaryTreeMsg *)_ptBinaryTree;

	if(NULL == ptBinaryTreeMsg)
	{
		dbg();
		return ERR;
	}

	LockMx(ptBinaryTreeMsg->m_Lock);
	
	TraversalAffter(ptBinaryTreeMsg->m_ptHead, _pfTraversalNode);
	
	UnLockMx(ptBinaryTreeMsg->m_Lock);

	return OK;
}

static void TraversalAffter2(TBinaryTreeNodeHead *_ptNode, FTraversalNode2 _pfTraversalNode2, void* _ptParam)
{
    if(NULL == _ptNode)
    {
        return;
    }

    TraversalAffter2(_ptNode->m_ptLeft, _pfTraversalNode2, _ptParam);
    TraversalAffter2(_ptNode->m_ptRight, _pfTraversalNode2, _ptParam);

	TBinaryTreeNodeHead *ptFindNode = NULL;
	TBinaryTreeNodeHead *ptNextNode = NULL;
	
	if(_pfTraversalNode2)
	{
		ptFindNode = _ptNode;
		
		while(ptFindNode)
		{
			ptNextNode = ptFindNode->m_ptNext;
			_pfTraversalNode2(ptFindNode,_ptParam);

			//ptFindNode = ptFindNode->m_ptNext;//如果执行的是删除操作，这里就有问题
			ptFindNode = ptNextNode;
		}
	}
}


int binary_tree_Traversal2(TBinaryTree *_ptBinaryTree, FTraversalNode2 _pfTraversalNode2, void* _ptParam)
{
	TBinaryTreeMsg *ptBinaryTreeMsg = (TBinaryTreeMsg *)_ptBinaryTree;

	if(NULL == ptBinaryTreeMsg)
	{
		dbg();
		return ERR;
	}

	LockMx(ptBinaryTreeMsg->m_Lock);
	
	TraversalAffter2(ptBinaryTreeMsg->m_ptHead, _pfTraversalNode2, _ptParam);
	
	UnLockMx(ptBinaryTreeMsg->m_Lock);

	return OK;
}

static void CopyAllNode(TBinaryTreeNodeHead *_ptNode, int _iStructSize, 
	char* _szBuf, int _iMaxLen, int *_piCopyPos, int *_piCount)
{
    if(NULL == _ptNode)
    {
        return;
    }

    CopyAllNode(_ptNode->m_ptLeft, _iStructSize, _szBuf, _iMaxLen, _piCopyPos, _piCount);
    CopyAllNode(_ptNode->m_ptRight, _iStructSize, _szBuf, _iMaxLen, _piCopyPos, _piCount);

	TBinaryTreeNodeHead *ptFindNode = _ptNode;
	while(ptFindNode)
	{
		if((*_piCopyPos) + _iStructSize > _iMaxLen) 
		{
			break;
		}
		
		memcpy(_szBuf + (*_piCopyPos), ptFindNode, _iStructSize);

		(*_piCopyPos) = (*_piCopyPos) + _iStructSize;
		(*_piCount)++;
		ptFindNode = ptFindNode->m_ptNext;
	}
		
}

int binary_tree_CopyAllNode(TBinaryTree *_ptBinaryTree, int _iStructSize, 
	char* _szBuf, int _iMaxLen, int *_piCopyPos, int *_piCount)
{
	TBinaryTreeMsg *ptBinaryTreeMsg = (TBinaryTreeMsg *)_ptBinaryTree;

	if(NULL == ptBinaryTreeMsg)
	{
		dbg();
		return ERR;
	}

	LockMx(ptBinaryTreeMsg->m_Lock);
	
	CopyAllNode(ptBinaryTreeMsg->m_ptHead,  _iStructSize, _szBuf, _iMaxLen, _piCopyPos, _piCount);
	
	UnLockMx(ptBinaryTreeMsg->m_Lock);

	return OK;
}

TBinaryTreeNodeHead * binary_tree_GetHead(TBinaryTree *_ptBinaryTree)
{
	TBinaryTreeMsg *ptBinaryTreeMsg = (TBinaryTreeMsg *)_ptBinaryTree;

	if(NULL == ptBinaryTreeMsg)
	{
		dbg();
		return NULL;
	}

	return ptBinaryTreeMsg->m_ptHead;
	
}

int binary_tree_Clear(TBinaryTree *_ptBinaryTree)
{
	TBinaryTreeMsg *ptBinaryTreeMsg = (TBinaryTreeMsg *)_ptBinaryTree;

	if(NULL == ptBinaryTreeMsg)
	{
		dbg();
		return ERR;
	}

	LockMx(ptBinaryTreeMsg->m_Lock);
	
	TraversalAffter(ptBinaryTreeMsg->m_ptHead, ptBinaryTreeMsg->m_pfBinaryTreeDestroy);

	ptBinaryTreeMsg->m_ptHead = NULL;
	
	UnLockMx(ptBinaryTreeMsg->m_Lock);

	return OK;
}


