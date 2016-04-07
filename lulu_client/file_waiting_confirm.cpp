#include "file_waiting_confirm.h"
#include "t_pub.h"
#include "t_num.h"
#include "t_base.h"
#include "t_char.h"

#include <stdlib.h>
#include <string.h>

static TBinaryTree *g_ptFWCBinaryTree = NULL;

static int FWCCompare(int _iType, void *_ptNode, void *_ptKey)
{
	TFileWaitingConfirm *ptNode1 = (TFileWaitingConfirm *)_ptNode;
	TFileWaitingConfirm *ptNode2 = (TFileWaitingConfirm *)_ptKey;

	if(NULL == ptNode1 || NULL == ptNode2)
	{
		//dbg();
		return BINARY_TREE_COMPARE_UNKNOWN;
	}

	
 	if(ptNode1->m_iSerial > ptNode2->m_iSerial) return BINARY_TREE_COMPARE_LEFT;
	if(ptNode1->m_iSerial < ptNode2->m_iSerial) return BINARY_TREE_COMPARE_RIGHT;
	
	return BINARY_TREE_COMPARE_DO;
}

static int FWCCopy(void *_ptDstNode, void *_ptSrcNode)
{
	TFileWaitingConfirm *ptDstNode = (TFileWaitingConfirm *)_ptDstNode;
	TFileWaitingConfirm *ptSrcNode = (TFileWaitingConfirm *)_ptSrcNode;

	if(NULL == ptDstNode || NULL == ptSrcNode)
	{
		dbg();
		return ERR;
	}

	ptDstNode->m_iSerial = ptSrcNode->m_iSerial;
	ptDstNode->m_iLastSendTime = ptSrcNode->m_iLastSendTime;
	
	return OK;
}

int FWCDestroy(void *_ptNode)
{
	if(NULL == _ptNode)
	{
		return ERR;
	}
	TFileWaitingConfirm* ptNode = (TFileWaitingConfirm *)_ptNode;

	if(ptNode)
	{
		free(ptNode);
	}
	_ptNode = NULL;

	return OK;
}

int file_waiting_confirm_init()
{
	g_ptFWCBinaryTree = binary_tree_Create(sizeof(TFileWaitingConfirm), FWCCompare, FWCCopy, FWCDestroy);

	if(NULL == g_ptFWCBinaryTree)
	{
		dbg();
		return ERR;
	}
	return OK;
}

int file_waiting_confirm_create(int _iMaxSerial)
{
	if(_iMaxSerial < 1)
	{
		return ERR;
	}
	if(NULL == g_ptFWCBinaryTree)
	{
		if(ERR == file_waiting_confirm_init())
		{
			return ERR;
		}
	}
	
	if(ERR == file_waiting_confirm_clear())
	{
		return ERR;
	}
	int i = 0 ;
	for( i = 0 ; i < _iMaxSerial; i++)
	{
		file_waiting_confirm_insert(i, 0);
	}
	
	return OK;
}


static TFileWaitingConfirm* GetFileWaitingConfirm()
{
	TFileWaitingConfirm* ptNote = (TFileWaitingConfirm *)malloc(sizeof(TFileWaitingConfirm));
	memset(ptNote ,0 , sizeof(TFileWaitingConfirm));
	return ptNote;
}

int file_waiting_confirm_insert(int _iSerial,int _iLastSendTime)
{
	if(NULL == g_ptFWCBinaryTree)
	{
		dbg();
		return ERR;
	}
	
	TFileWaitingConfirm* ptNote = GetFileWaitingConfirm();

	if(NULL == ptNote)
	{
		dbg();
		return ERR;
	}

	ptNote->m_iSerial = _iSerial;
	ptNote->m_iLastSendTime = _iLastSendTime;

	return binary_tree_Insert(g_ptFWCBinaryTree, ptNote);
}

//找出一个包括某一点的学校
TFileWaitingConfirm* file_waiting_confirm_get(int _iSerial)
{
	if(NULL == g_ptFWCBinaryTree)
	{
		dbg();
		return NULL;
	}
	
	TFileWaitingConfirm* ptNote = GetFileWaitingConfirm();//申请内存

	if(ptNote)
	{
		ptNote->m_iSerial = _iSerial;
	}
	else
	{
		dbg();
		return NULL;
	}
	TFileWaitingConfirm* pptNoteFile[2] = {0};
	binary_tree_Get(g_ptFWCBinaryTree, 1, ptNote, (void **)pptNoteFile, 1);
	FWCDestroy(ptNote);

	return pptNoteFile[0];
}

int file_waiting_confirm_remove(TFileWaitingConfirm *_pTSchoolMines)
{
	if(NULL == g_ptFWCBinaryTree)
	{
		dbg();
		return ERR;
	}
	return binary_tree_Remove(g_ptFWCBinaryTree, _pTSchoolMines);
}
//遍历
int file_waiting_confirm_traversal(FTraversalNode _pfTraversalNode)
{
	if(NULL == g_ptFWCBinaryTree)
	{
		dbg();
		return ERR;
	}
	
	return binary_tree_Traversal(g_ptFWCBinaryTree, _pfTraversalNode);
}

int file_waiting_confirm_clear()
{
	if(NULL == g_ptFWCBinaryTree)
	{
		dbg();
		return ERR;
	}
	
	return binary_tree_Clear(g_ptFWCBinaryTree);
}

int file_waitng_confirm_is_empty()
{
	if(NULL == binary_tree_GetHead(g_ptFWCBinaryTree))
	{
		return OK;
	}
	return ERR;
}


