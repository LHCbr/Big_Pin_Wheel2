#include "im_client_msg_filter.h"
#include "t_list.h"
#include "t_base.h"

#include <stdlib.h>



//保存消息的数量
#define MSG_FILTER_MAX_SIZE 100
#if 0
TList* g_ptRecvMsgList = NULL;

typedef struct
{
	TStlHead m_Head;
	int64_t m_iSendIndex;
	uint32_t m_iMsgLen;
}TMsgFilter;

int InitMsgFilter()
{
	if(g_ptRecvMsgList)
	{
		return OK;
	}
	
	g_ptRecvMsgList = list_Create();
	if(NULL == g_ptRecvMsgList)
	{
		return ERR;
	}
	return OK;
}

TMsgFilter* FndMsgFrmFilter(int64_t _iSendIndex, uint32_t _iMsgLen)
{
	if(NULL == g_ptRecvMsgList)
	{
		return NULL;
	}
	TMsgFilter *ptNode = (TMsgFilter *)list_GetHead(g_ptRecvMsgList);
	while(ptNode)
	{
		if(_iSendIndex == ptNode->m_iSendIndex && 
			_iMsgLen == ptNode->m_iMsgLen)
		{
			break;
		}
		ptNode = (TMsgFilter *)list_GetNext(g_ptRecvMsgList,ptNode);
	}
	return ptNode;
}


int AddMsgToFilter(int64_t _iSendIndex, uint32_t _iMsgLen)
{
	if(NULL == g_ptRecvMsgList)
	{
		return ERR;
	}
	TMsgFilter* ptMsgFilter = FndMsgFrmFilter(_iSendIndex,_iMsgLen);
	if(NULL != ptMsgFilter)
	{
		return ERR;
	}
	//保持MSG_FILTER_MAX_SIZE个就可以了
	if(list_Sum(g_ptRecvMsgList)>MSG_FILTER_MAX_SIZE)
	{
		TMsgFilter *ptNode = (TMsgFilter *)list_PopHead(g_ptRecvMsgList);
		if(ptNode) free(ptNode);
	}
	TMsgFilter *ptNode = (TMsgFilter *)malloc(sizeof(TMsgFilter));
	if(NULL == ptNode)
	{
		dbg();
		return ERR;
	}
	ptNode->m_iSendIndex = _iSendIndex;
	ptNode->m_iMsgLen = _iMsgLen;
	return list_PushEnd(g_ptRecvMsgList,ptNode);
}

int MsgFilterDestroy()
{
	if(NULL == g_ptRecvMsgList)
	{
		return ERR;
	}
	TMsgFilter *ptNode = (TMsgFilter *)list_PopHead(g_ptRecvMsgList);
	while(ptNode)
	{
		free(ptNode);
		ptNode = (TMsgFilter *)list_PopHead(g_ptRecvMsgList);
	}
		
	int iRet = list_Destroy(g_ptRecvMsgList);
	g_ptRecvMsgList = NULL;
	return iRet;
}

#endif

int CClientMsgFilter::AddMsgToFilter(int64_t _iSendIndex,uint32_t nMsgLen)
{
	if (FndMsgFrmFilter(_iSendIndex, nMsgLen)) return ERR;

	AutoMLock aml(_mutex);
	if (_msg_lst.size() > MSG_FILTER_MAX_SIZE)
	{
		_msg_lst.pop_front();
	}
	TMsgFilterData msgData;
	msgData.m_iSendIndex = _iSendIndex;
	msgData.m_iMsgLen = nMsgLen;
	_msg_lst.push_back(msgData);
	return OK;
}

CClientMsgFilter& CClientMsgFilter::Instance()
{
	static CClientMsgFilter msgFilter;
	return msgFilter;
}

bool CClientMsgFilter::FndMsgFrmFilter(int64_t _iSendIndex, uint32_t _iMsgLen)
{
	AutoMLock aml(_mutex);
	if (_msg_lst.empty()) return false;
	MsgFilterLstIt it = _msg_lst.begin();
	while (it != _msg_lst.end())
	{
		if (it->m_iSendIndex == _iSendIndex && it->m_iMsgLen == _iMsgLen) return true;
		it++;
	}
	return false;
}