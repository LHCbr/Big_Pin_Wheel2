#include "epool_connection.h"
#include "t_base.h"
#include "t_pub.h"

#include <stdlib.h>
#include <netinet/in.h>
#include <arpa/inet.h>

void* ec_Create(int _iNodeSize, int _iSum)
{
	return malloc(_iNodeSize * _iSum);
}

// 析构
int ec_Destroy(void *_ptEC)
{
	#if EPOOL_CONNECTION_LOCK
	TEpoolConnection *ptEC = (TEpoolConnection *)_ptEC;

	if(ptEC)
	{
		Lock_Destroy(ptEC->m_Lock);		
	}
	#endif

	return OK;
}

int ec_Init(void *_ptEC)
{
	TEpoolConnection *ptEC = (TEpoolConnection *)_ptEC;

	if(ptEC)
	{
		ptEC->m_ptConnectStruct = NULL;
		ptEC->m_iFd = -1;
		ptEC->m_iType = EPOOL_TYPE_UNKNOWN;
		ptEC->m_iState = EPOOL_STATE_UNINIT;
		ptEC->m_ptRecvRingBuf = NULL;
		ptEC->m_ptRecvList = NULL;
		ptEC->f_Start = NULL;
		ptEC->f_Recv = NULL;
		ptEC->f_Send = NULL;
		ptEC->f_Accept = NULL;
		ptEC->f_AcceptAfter = NULL;
		ptEC->f_CloseBefore = NULL;
		ptEC->f_Close = NULL;

		#if EPOOL_CONNECTION_LOCK
		Lock_Init(ptEC->m_Lock);
		#endif

		return OK;
	}
	else
	{
		dbg();
		return ERR;
	}
}

int ec_SetState(void *_ptEC, int _iState)
{
	TEpoolConnection *ptEC = (TEpoolConnection *)_ptEC;

	if(ptEC)
	{
		ptEC->m_iState = _iState;
		return OK;
	}
	else
	{
		dbg();
		return ERR;
	}
}

int ec_GetState(void *_ptEC)
{
	TEpoolConnection *ptEC = (TEpoolConnection *)_ptEC;

	if(ptEC)
	{
		return ptEC->m_iState;
	}
	else
	{
		dbg();
		return EPOOL_STATE_UNINIT;
	}
}

// ptConnStruct 连接结构体
int ec_SetConnectStruct(void *_ptEC, void *_ptConnStruct)
{
	TEpoolConnection *ptEC = (TEpoolConnection *)_ptEC;

	if(ptEC)
	{
		ptEC->m_ptConnectStruct = _ptConnStruct;
		return OK;
	}
	else
	{
		dbg();
		return ERR;
	}
}

void* ec_GetConnectStruct(void *_ptEC)
{
	TEpoolConnection *ptEC = (TEpoolConnection *)_ptEC;

	if(ptEC)
	{
		return ptEC->m_ptConnectStruct;
	}
	else
	{
		dbg();
		return NULL;
	}
}

// 套接字
int ec_SetFd(void *_ptEC, int _iFd)
{
	TEpoolConnection *ptEC = (TEpoolConnection *)_ptEC;

	if(ptEC)
	{
		ptEC->m_iFd = _iFd;
		return OK;
	}
	else
	{
		dbg();
		return ERR;
	}
}

int ec_GetFd(void *_ptEC)
{
	TEpoolConnection *ptEC = (TEpoolConnection *)_ptEC;

	if(ptEC)
	{
		return ptEC->m_iFd;
	}
	else
	{
		dbg();
		return -1;
	}
}


int ec_GetIp(void *_ptEC, char * _pcOut, int _iMaxLen)
{
#if RUN_ON_ANDROID

    if(NULL == _ptEC || NULL == _pcOut)
    {
        dbg();
        return ERR;
    }
    struct sockaddr_in clientaddr;
	socklen_t clilen = sizeof(clientaddr);
	if(getpeername(ec_GetFd(_ptEC), (struct sockaddr *)&clientaddr, &clilen) != 0)
	{
	    return ERR;
	}
	
	snprintf(_pcOut,_iMaxLen,"%s",inet_ntoa(clientaddr.sin_addr));
#endif
    return OK;
}


// 连接类型
int ec_SetEpoolType(void *_ptEC, int _iType)
{
	TEpoolConnection *ptEC = (TEpoolConnection *)_ptEC;

	if(ptEC)
	{
		ptEC->m_iType = _iType;
		return OK;
	}
	else
	{
		dbg();
		return ERR;
	}
}

int ec_GetEpoolType(void *_ptEC)
{
	TEpoolConnection *ptEC = (TEpoolConnection *)_ptEC;

	if(ptEC)
	{
		return ptEC->m_iType;
	}
	else
	{
		dbg();
		return EPOOL_TYPE_UNKNOWN;
	}
}

// Recv Ringbuf
int ec_SetRecvRingBuf(void *_ptEC, TRingBuf *_ptRingBuf)
{
	TEpoolConnection *ptEC = (TEpoolConnection *)_ptEC;

	if(ptEC)
	{
		ptEC->m_ptRecvRingBuf = _ptRingBuf;
		return OK;
	}
	else
	{
		dbg();
		return ERR;
	}
}

TRingBuf* ec_GetRecvRingBuf(void *_ptEC)
{
	TEpoolConnection *ptEC = (TEpoolConnection *)_ptEC;

	if(ptEC)
	{
		return ptEC->m_ptRecvRingBuf;
	}
	else
	{
		dbg();
		return NULL;
	}
}

// Recv List
int ec_SetRecvList(void *_ptEC, TList *_ptList)
{
	TEpoolConnection *ptEC = (TEpoolConnection *)_ptEC;

	if(ptEC)
	{
		ptEC->m_ptRecvList = _ptList;
		return OK;
	}
	else
	{
		dbg();
		return ERR;
	}
}

TList* ec_GetRecvList(void *_ptEC)
{
	TEpoolConnection *ptEC = (TEpoolConnection *)_ptEC;

	if(ptEC)
	{
		return ptEC->m_ptRecvList;
	}
	else
	{
		dbg();
		return NULL;
	}
}

int ec_SetOperation(void *_ptEC, int _iOperationType, FECOperation _pfOperationFun)
{
	TEpoolConnection *ptEC = (TEpoolConnection *)_ptEC;

	if(ptEC && _pfOperationFun)
	{
		switch(_iOperationType)
		{
		case EPOOL_OPERAT_START:
			ptEC->f_Start = _pfOperationFun;
			break;

		case EPOOL_OPERAT_RECV:
			ptEC->f_Recv = _pfOperationFun;
			break;

		case EPOOL_OPERAT_ACCEPT_AFTER:
			ptEC->f_AcceptAfter = _pfOperationFun;
			break;
			
		case EPOOL_OPERAT_CLOSE_BEFORE:
			ptEC->f_CloseBefore = _pfOperationFun;
			break;
			
		case EPOOL_OPERAT_CLOSE:
			ptEC->f_Close = _pfOperationFun;
			break;

		default:
			dbg();
			dbgx(_iOperationType);
			break;
		}
	}

	return OK;
}

int ec_SetSendOperation(void *_ptEC, FECSendOperation _pfOperationFun)
{
	TEpoolConnection *ptEC = (TEpoolConnection *)_ptEC;

	if(ptEC && _pfOperationFun)
	{
		ptEC->f_Send = _pfOperationFun;
		return OK;
	}
	else
	{
		dbg();
		return ERR;
	}
}

int ec_SetAcceptOperation(void *_ptEC, FECAcceptOperation _pfOperationFun)
{
	TEpoolConnection *ptEC = (TEpoolConnection *)_ptEC;

	if(ptEC && _pfOperationFun)
	{
		ptEC->f_Accept = _pfOperationFun;
		return OK;
	}
	else
	{
		dbg();
		return ERR;
	}
}

int ec_SetAcceptGetOperation(void *_ptEC, FECAcceptGetOperation _pfOperationFun)
{
	TEpoolConnection *ptEC = (TEpoolConnection *)_ptEC;

	if(ptEC && _pfOperationFun)
	{
		ptEC->f_AcceptGet = _pfOperationFun;
		return OK;
	}
	else
	{
		dbg();
		return ERR;
	}
}

// 连接
int ec_Start(void *_ptEC)
{
	TEpoolConnection *ptEC = (TEpoolConnection *)_ptEC;

	if(ptEC && ptEC->f_Start)
	{
		return ptEC->f_Start(ptEC);
	}
	else
	{
		dbg();
		return ERR;
	}
}

int ec_Accept(void *_ptEC)
{
	TEpoolConnection *ptEC = (TEpoolConnection *)_ptEC;

	void *ptRet = NULL;
	
	if(ptEC && ptEC->f_Accept)
	{
		// 返回新连接结构体
		ptRet = ptEC->f_Accept(ptEC);

		if(ptRet)
		{
			// 接收到连接以后的操作
			if(ptEC->f_AcceptAfter)
			{
				// 传回新连接结构体
				ptEC->f_AcceptAfter((EpoolConnection*)ptRet);
			}

			return OK;
		}
		else
		{
			dbg();
			return ERR;
		}
	}
	else
	{
		dbg();
		return ERR;
	}
}

void* ec_AcceptGet(void *_ptEC)
{
	TEpoolConnection *ptEC = (TEpoolConnection *)_ptEC;

	if(ptEC && ptEC->f_AcceptGet)
	{
		return ptEC->f_AcceptGet();
	}
	else
	{
		dbg();
		return NULL;
	}
}

// 接收
int ec_Recv(void *_ptEC)
{
	TEpoolConnection *ptEC = (TEpoolConnection *)_ptEC;

	if(ptEC && ptEC->f_Recv)
	{
		return ptEC->f_Recv(ptEC);
	}
	else
	{
		dbg();
		return ERR;
	}
}

// 发送
int ec_Send(void *_ptEC, const void *_pcData, int _iLen)
{
	TEpoolConnection *ptEC = (TEpoolConnection *)_ptEC;

	if(ptEC && ptEC->f_Send)
	{
		if(_iLen == ptEC->f_Send(ptEC, _pcData, _iLen))
		{
			return _iLen;
		}
		else
		{
			dbg();
			ec_SetState(_ptEC, EPOOL_STATE_CLOSING);
			return ERR;
		}
	}
	else
	{
		dbg();
		dbgx(ptEC);
		return ERR;
	}
}

// 关闭
int ec_Close(void *_ptEC)
{
	TEpoolConnection *ptEC = (TEpoolConnection *)_ptEC;

	if(ptEC && ptEC->f_Close)
	{
		ec_SetState(ptEC, EPOOL_STATE_CLOSED);
		
		// 关闭前的操作
		if(ptEC->f_CloseBefore)
		{
			ptEC->f_CloseBefore(ptEC);
		}
			
		return ptEC->f_Close(ptEC);
	}
	else
	{
		dbg();
		dbgx(ptEC);
		//dbgx(ptEC->f_Close);
		return ERR;
	}
}

