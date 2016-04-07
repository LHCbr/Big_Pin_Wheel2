#include "recv_pool.h"
#include "t_base.h"

#include "t_pool.h"

static TPool *g_ptRecvPool = NULL;
static int g_iSize = 2048;

static int node_Init(void *_ptNode)
{
	TRecvNode * ptRecvNode = (TRecvNode *)_ptNode;

	//dbgx(ptServiceNode);
	
	if(ptRecvNode)
	{
		ptRecvNode->m_iSize = g_iSize;
		ptRecvNode->m_iStart = 0;
		ptRecvNode->m_iSum = 0;
	}

	return OK;
}

int recv_pool_Init()
{
	g_ptRecvPool = pool_Create(sizeof(TRecvNode) + g_iSize, 100, node_Init, POOL_SIZE_GROWTH, 100);

	if(NULL == g_ptRecvPool)
	{
		dbg();
		return ERR;
	}
	else
	{
		return OK;
	}
}

TRecvNode* recv_pool_New()
{
	//dbgprintf(0, "recv_pool_New()");
		
	return (TRecvNode*)pool_New(g_ptRecvPool);
}

int recv_pool_Delete(TRecvNode* _ptNode)
{
	//dbgprintf(0, "recv_pool_Delete()");
	
	return pool_Delete(g_ptRecvPool, _ptNode);
}

