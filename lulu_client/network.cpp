#include "network.h"
#include "t_base.h"
#include "t_pub.h"

#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <string.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/ioctl.h>
//#include <sys/poll.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <netinet/in.h>
#include <netinet/tcp.h>


#define USE_NON_BLOCK_RECV_SEND 1

//old : 128 * 1024
#define SO_RCVBUF_LEN (512 * 1024)
//old : 64 * 1024
#define SO_SNDBUF_LEN (512 * 1024)


typedef struct 
{
	int m_iType;			// 网络类型，0 TCP 1UDP
	int m_iSocket;			//
	char m_pcIp[MAX_IP_LEN];
	int m_iPort;
	pthread_mutex_t m_SendMux;
	pthread_mutex_t m_RecvMux;
}TNetWorkMsg;


TNetWork *net_Create(int _iType)
{
	TNetWorkMsg *ptNetWorkMsg = (TNetWorkMsg *)malloc(sizeof(TNetWorkMsg));

	if(NULL == ptNetWorkMsg)
	{
		dbg();
		return NULL;
	}

	Lock_Init(ptNetWorkMsg->m_SendMux);
	Lock_Init(ptNetWorkMsg->m_RecvMux);

	ptNetWorkMsg->m_iType		= _iType;
	ptNetWorkMsg->m_iSocket		= INVALID_SOCKET;

	ptNetWorkMsg->m_pcIp[0]		= 0;
	ptNetWorkMsg->m_iPort		= -1;

	return (TNetWork *)ptNetWorkMsg;
}

static int udp_connect(TNetWorkMsg *_ptNetWorkMsg, const char* _pcIP, int _iPort)
{
	return OK;
}

static int tcp_connect(TNetWorkMsg *_ptNetWorkMsg, const char *_pcIP, int _iPort)
{
	if(NULL == _ptNetWorkMsg || NULL == _pcIP)
	{
		dbg();
		return ERR;
	}

	int iRet = ERR;
	unsigned int ul;
	dbgprintf(0, "start tcp connect to %s:%d", _ptNetWorkMsg->m_pcIp, _ptNetWorkMsg->m_iPort);
	
	fd_set rdevents,wrevents,exevents;
	struct   timeval tv;
	socklen_t sLen;
	struct sockaddr_in ptDestAddr;
	
	if(INVALID_SOCKET == _ptNetWorkMsg->m_iSocket)
	{
		struct linger so_linger;
    	_ptNetWorkMsg->m_iSocket = socket(AF_INET, SOCK_STREAM, 0);
		
    	if(INVALID_SOCKET == _ptNetWorkMsg->m_iSocket)
    	{
    		dbg();
			iRet = ERR;
			goto EXIT;
    	}

      	so_linger.l_onoff = 1;
       	so_linger.l_linger = 0;
       	iRet = setsockopt(_ptNetWorkMsg->m_iSocket, SOL_SOCKET, SO_LINGER, &so_linger, sizeof(so_linger));
       	
    	int cnt = SO_RCVBUF_LEN;
    	iRet = setsockopt(_ptNetWorkMsg->m_iSocket, SOL_SOCKET, SO_RCVBUF, (int *)&cnt,sizeof(int));
    	cnt = SO_SNDBUF_LEN;
    	iRet = setsockopt(_ptNetWorkMsg->m_iSocket, SOL_SOCKET, SO_SNDBUF, (int *)&cnt, sizeof(int));
	}

	#if 0
	// 绑定指定网卡或IP
	strut sockaddr_in sin;
	
	sin.sin_family = AF_INET;
	sin.sin_addr.s_addr = xxx;
	sin.sin_port = xxx;
	
	bind(sock, (struct sockaddr *)&sin, sizeof(sin));
	// 绑定结束
	#endif

	//设置为非阻塞模式
	ul = 1;
    ioctl(_ptNetWorkMsg->m_iSocket, FIONBIO, &ul);   

	// 指定地址和端口
	memset(&ptDestAddr, 0, sizeof(struct sockaddr_in));
	
	ptDestAddr.sin_family 	 	= AF_INET;
	ptDestAddr.sin_port   	 	= htons(_iPort);
	ptDestAddr.sin_addr.s_addr 	= inet_addr(_pcIP);

    // 与服务器端建立连接
    iRet = connect(_ptNetWorkMsg->m_iSocket,(struct sockaddr*)&ptDestAddr, sizeof(ptDestAddr));

	dbgint(iRet);
	dbgint(errno);
	
    if(-1 == iRet && errno != EINPROGRESS)
	{
		dbg();
 		iRet = ERR;
		goto EXIT;
	}
	
	//若没有直接连接成功则需要等待
	if(0 != iRet)
	{  
		//把先前的套接字加到读集合里面	
		FD_ZERO(&rdevents);
		FD_SET(_ptNetWorkMsg->m_iSocket, &rdevents);  
		wrevents = rdevents;  
		
		//异常集合
		exevents = rdevents;   

		#if 1
		//设置时间为5秒
		tv.tv_sec = 5;  
		tv.tv_usec = 0;
		#else
		//设置时间为10秒
		tv.tv_sec = 10;  
		tv.tv_usec = 0;
		#endif

		iRet = select(_ptNetWorkMsg->m_iSocket + 1, &rdevents, &wrevents, &exevents, &tv);

		dbgint(iRet);

		if(iRet <= 0) 
		{  
			dbg();
			dbgint(errno);
	    	//错误处理
        	iRet = ERR;
			goto EXIT;
		}
		#if 0		
		else if(0 == iRet) 
		{  
	    	//超时处理
	   		close(_pConnection->m_iSocKet);		
	   		_pConnection->m_iSocKet = INVALID_SOCKET;
			
        	iRet = ERR;
			goto leave;
		}
		#endif		
		else 
		{
			if(2 == iRet) 
			{  
				int iErr;
				int iLen = sizeof(iErr); 
				getsockopt(_ptNetWorkMsg->m_iSocket, SOL_SOCKET, SO_ERROR, &iErr, (socklen_t*)&iLen); 

				if(iErr) 
				{ 
					//dbg();
					dbgint(errno);
					//超时处理
					iRet = ERR;
					goto EXIT;
				} 
			}	
			
		    //套接字已经准备好
    		if(_ptNetWorkMsg->m_iSocket < 0)
    		{
    			dbg();
				dbgint(errno);
				iRet = ERR;
				goto EXIT;
    		}
			
    		if(!FD_ISSET(_ptNetWorkMsg->m_iSocket, &rdevents) && !FD_ISSET(_ptNetWorkMsg->m_iSocket, &wrevents)) 
			{
				dbg();
				dbgint(errno);
		      	iRet = ERR;
				goto EXIT;
	    	}
		
  	 		if (getsockopt(_ptNetWorkMsg->m_iSocket, SOL_SOCKET, SO_ERROR, &iRet, &sLen) < 0)
	   		{
				//perror("getsockopt ");
				dbg();
				dbgint(errno);
	   		}

			#if 0
	   		if (iRet != 0) 
	   		{
				dbg();
			}
			#endif
			
	   		if(2 == iRet)
	   		{
	   			dbg();
				dbgint(errno);
				iRet = ERR;
				goto EXIT;
	   		}

			//到这里说明connect()正确返回
			
		}
	}

	
	iRet = OK;
	
	set_socket_nonblock(_ptNetWorkMsg->m_iSocket);

	#if 0
	iRet = epoll_add_connection(_ptConnection, 1);

	if(iRet!=0)
	{
		iRet = ERR;
		goto EXIT;	  
	}
	#endif
	 
EXIT:	
	if(OK != iRet && INVALID_SOCKET != _ptNetWorkMsg->m_iSocket)
	{
		//dbg();
		close(_ptNetWorkMsg->m_iSocket);
		_ptNetWorkMsg->m_iSocket = INVALID_SOCKET;
	}
	
	return iRet;
}


TNetWork *net_CreateByIp(int _iType, const char *_pcIp, int _iPort)
{
	TNetWorkMsg *ptNetWorkMsg = (TNetWorkMsg *)malloc(sizeof(TNetWorkMsg));

	if(NULL == ptNetWorkMsg)
	{
		dbg();
		return NULL;
	}

	Lock_Init(ptNetWorkMsg->m_SendMux);
	Lock_Init(ptNetWorkMsg->m_RecvMux);
	
	ptNetWorkMsg->m_iType		= _iType;
	ptNetWorkMsg->m_iSocket		= INVALID_SOCKET;

	strncpy(ptNetWorkMsg->m_pcIp, _pcIp, MAX_IP_LEN);
	ptNetWorkMsg->m_iPort		= _iPort;
	
	return (TNetWork *)ptNetWorkMsg;
}


int net_ConnectByIp(TNetWork *_ptNetWork)
{
	if(NULL == _ptNetWork)
	{
		dbg();
		return ERR;
	}

	TNetWorkMsg *ptNetWorkMsg = (TNetWorkMsg *)_ptNetWork;	

	if(0 == ptNetWorkMsg->m_pcIp[0] || ptNetWorkMsg->m_iPort < 0 || ptNetWorkMsg->m_iPort > 65536)
	{
		dbg();
		return ERR;
	}
    int iRet = OK;
    LockMx(ptNetWorkMsg->m_SendMux);
	if(NET_TYPE_TCP == ptNetWorkMsg->m_iType)
	{
		iRet = tcp_connect(ptNetWorkMsg, ptNetWorkMsg->m_pcIp, ptNetWorkMsg->m_iPort);
	}
	else
	{
		iRet = udp_connect(ptNetWorkMsg, ptNetWorkMsg->m_pcIp, ptNetWorkMsg->m_iPort);
	}
	UnLockMx(ptNetWorkMsg->m_SendMux);
	return iRet;
}
#if 0
static int tcp_IsConnected2(TNetWorkMsg *_ptNetWorkMsg)
{
	if(NULL == _ptNetWorkMsg || _ptNetWorkMsg->m_iSocket < 0)
	{
		dbg();
		return ERR;
	}

	struct tcp_info info;
	int optlen = sizeof(struct tcp_info);
 	if (getsockopt (_ptNetWorkMsg->m_iSocket, IPPROTO_TCP, TCP_INFO, &info, (socklen_t *)&optlen) < 0) return ERR;
	
	if (info.tcpi_state == TCP_ESTABLISHED) return OK;

	return ERR;
}
#endif
static int tcp_IsConnected(TNetWorkMsg *_ptNetWorkMsg)
{
	if(NULL == _ptNetWorkMsg || _ptNetWorkMsg->m_iSocket < 0)
	{
		dbg();
		return ERR;
	}
	
    struct timeval timeout;
    timeout.tv_sec = 0;
    timeout.tv_usec = 0;
	
    fd_set fdwrite;
    fd_set fdexcept;
	
    FD_ZERO(&fdwrite);
    FD_ZERO(&fdexcept);
	
    FD_SET(_ptNetWorkMsg->m_iSocket, &fdwrite);
    FD_SET(_ptNetWorkMsg->m_iSocket, &fdexcept);

    int ret = select(_ptNetWorkMsg->m_iSocket + 1, NULL, &fdwrite, &fdexcept, &timeout);
	
    if(ret == -1)
    {
        return ERR;
    }

    if(ret > 0)
    {
        if(FD_ISSET(_ptNetWorkMsg->m_iSocket, &fdexcept))
        {
            return ERR;
        }
        else if(FD_ISSET(_ptNetWorkMsg->m_iSocket, &fdwrite))
        {
            int err = 0;
            socklen_t len = sizeof(err);
			
            int result = getsockopt(_ptNetWorkMsg->m_iSocket, SOL_SOCKET, SO_ERROR, (char*)&err, &len);

			if(result < 0 || err != 0)
            {
                return ERR;
            }
            else
            {
				//return tcp_IsConnected2(_ptNetWorkMsg);
                return OK;
            }
        }
    }
	
    return ERR;
}


int net_IsConnected(TNetWork *_ptNetWork)
{
	TNetWorkMsg *ptNetWorkMsg = (TNetWorkMsg *)_ptNetWork;

	if(NULL == ptNetWorkMsg || ptNetWorkMsg->m_iSocket == INVALID_SOCKET)
	{
		dbg();
		return ERR;
	}

	int iRet = OK;
	LockMx(ptNetWorkMsg->m_SendMux);
	if(NET_TYPE_TCP == ptNetWorkMsg->m_iType)
	{
		iRet = tcp_IsConnected(ptNetWorkMsg);
	}
	UnLockMx(ptNetWorkMsg->m_SendMux);
	return iRet;
}

int net_Connect(TNetWork *_ptNetWork, const char *_pcIp, int _iPort)
{
	TNetWorkMsg *ptNetWorkMsg = (TNetWorkMsg *)_ptNetWork;

	if(NULL == ptNetWorkMsg || NULL == _pcIp
		|| _iPort < 0 || _iPort > 65536)
	{
		dbg();
		return ERR;
	}

	net_Close(_ptNetWork);
	int iRet;
	LockMx(ptNetWorkMsg->m_SendMux);
	if(NET_TYPE_TCP == ptNetWorkMsg->m_iType)
	{
		iRet = tcp_connect(ptNetWorkMsg, _pcIp, _iPort);
	}
	else
	{
		iRet = udp_connect(ptNetWorkMsg, _pcIp, _iPort);
	}
	UnLockMx(ptNetWorkMsg->m_SendMux);
	return iRet;
}

int net_GetFd(TNetWork *_ptNetWork)
{
	if(NULL == _ptNetWork)
	{
		dbg();
		return ERR;
	}

	return ((TNetWorkMsg *)_ptNetWork)->m_iSocket;
}

int net_SetFd(TNetWork *_ptNetWork, int _iSocket)
{
	if(NULL == _ptNetWork || _iSocket < 0)
	{
		dbg();
		return ERR;
	}

	int iRet = ERR;
	int cnt = SO_RCVBUF_LEN;
	iRet = setsockopt(_iSocket, SOL_SOCKET, SO_RCVBUF, (int *)&cnt,sizeof(int));
	
	cnt = SO_SNDBUF_LEN;
	iRet = setsockopt(_iSocket, SOL_SOCKET, SO_SNDBUF, (int *)&cnt, sizeof(int));

	((TNetWorkMsg *)_ptNetWork)->m_iSocket = _iSocket;

	return iRet;
}

static int udp_recv(int _iSocket, char *_pcRecv, int _iLenMax)
{
	return OK;
}

static int tcp_recv(int _iSocket, char *_pcRecv, int _iLenMax)
{
	if(_iSocket <= 0 || NULL == _pcRecv || _iLenMax < 1)
	{
		dbg();
		return ERR;
	}
	//dbgprintf(0,"tcp_recv start,socket:%d max len:%d",_iSocket,_iLenMax);
	int iRet = recv(_iSocket, _pcRecv, _iLenMax, 0);

	if(-1 == iRet) // 正常
	{
		//dbgint(errno);

		if(errno == EAGAIN || errno == EINTR)
		{
			return OK;
		}
		else
		{
			//dbg();
			dbgint(errno);
			return ERR;
		}
	}
	else if(0 == iRet)	// 对端关闭
	{
		dbg();
		return ERR;
	}
	//dbgprintf(0,"tcp_recv end,socket:%d recv len:%d",_iSocket,iRet);
	return iRet;
}

int net_Recv(TNetWork *_ptNetWork, char *_pcRecv, int _iLenMax)
{
#if USE_NON_BLOCK_RECV_SEND
    return net_nb_Recv(_ptNetWork, _pcRecv, _iLenMax);
#endif

	if(NULL == _ptNetWork || NULL == _pcRecv || _iLenMax <= 0)
	{
		dbg();
		return ERR;
	}

	int iRet = 0;
	TNetWorkMsg *ptNetWorkMsg = (TNetWorkMsg *)_ptNetWork;
	if(ptNetWorkMsg->m_iSocket == INVALID_SOCKET)
	{
		dbg();
		return ERR;
	}
/*
#ifdef DEBUG_ON
		struct sockaddr_in clientaddr;
		socklen_t clilen = sizeof(clientaddr);
		if(getpeername(ptNetWorkMsg->m_iSocket, (struct sockaddr *)&clientaddr, &clilen) == 0)
		{
			dbgprintf(0, "%s,%d,Recv Data From: %s:%d MaxLen:%d", __func__, __LINE__, 
				inet_ntoa(clientaddr.sin_addr),ntohs(clientaddr.sin_port),_iLenMax);
		}
		else
		{
			dbgint(_iLenMax);
		}
#endif
*/

	LockMx(ptNetWorkMsg->m_RecvMux);
	
	if(NET_TYPE_TCP == ptNetWorkMsg->m_iType)
	{
		iRet = tcp_recv(ptNetWorkMsg->m_iSocket, _pcRecv, _iLenMax);
	}
	else
	{
		iRet = udp_recv(ptNetWorkMsg->m_iSocket, _pcRecv, _iLenMax);
	}

	UnLockMx(ptNetWorkMsg->m_RecvMux);

	return iRet;
}

static int udp_send(int _iSocket, const char *_pcBuf, int _iLen)
{
	return OK;
}

static int tcp_send(int _iSocket, const char *_pcBuf, int _iLen)
{
	if(_iSocket <= 0 || NULL == _pcBuf || _iLen <= 0)
	{
		dbg();
		dbgprintf(0,"Socket:%d,Buf(%s),Len:%d",_iSocket,_pcBuf,_iLen);
		return ERR;
	}

	//return send(_iSocket, _pcBuf, _iLen, MSG_NOSIGNAL);
	//return send(_iSocket, _pcBuf, _iLen, 0x4000);
	int iRet = send(_iSocket, _pcBuf, _iLen, 0);
	
	dbgint(iRet);

	if(iRet < 0)
	{
		dbgint(errno);
	}

	return iRet;
}

int net_Send(TNetWork *_ptNetWork, const char *_pcSend, int _iLen)
{
#if USE_NON_BLOCK_RECV_SEND
        return net_nb_Send(_ptNetWork, _pcSend, _iLen);
#endif

	if(NULL == _ptNetWork || NULL == _pcSend || _iLen <= 0)
	{
		dbg();
		return ERR;
	}

	int iRet = 0;
	TNetWorkMsg *ptNetWorkMsg = (TNetWorkMsg *)_ptNetWork;
	if(ptNetWorkMsg->m_iSocket == INVALID_SOCKET)
	{
		dbg();
		return ERR;
	}
	
#ifdef DEBUG_ON
	struct sockaddr_in clientaddr;
	socklen_t clilen = sizeof(clientaddr);
	if(getpeername(ptNetWorkMsg->m_iSocket, (struct sockaddr *)&clientaddr, &clilen) == 0)
	{
		dbgprintf(0, "%s,%d,Send Data To: %s:%d Len:%d", __func__, __LINE__, 
			inet_ntoa(clientaddr.sin_addr),ntohs(clientaddr.sin_port),_iLen);
	}
	else
	{
		dbgint(_iLen);
	}
#endif

	LockMx(ptNetWorkMsg->m_SendMux);
	if(NET_TYPE_TCP == ptNetWorkMsg->m_iType)
	{
		iRet = tcp_send(ptNetWorkMsg->m_iSocket, _pcSend, _iLen);
	}
	else
	{
		iRet = udp_send(ptNetWorkMsg->m_iSocket, _pcSend, _iLen);
	}

	UnLockMx(ptNetWorkMsg->m_SendMux);

	return iRet;
}

static int udp_close(int _iSocket)
{
	return OK;
}

static int tcp_close(int _iSocket)
{
	dbgint(_iSocket);
	
	if(INVALID_SOCKET != _iSocket)
	{
		close(_iSocket);
	}

	return OK;
}

int net_Close(TNetWork *_ptNetWork)
{
	TNetWorkMsg *ptNetWorkMsg = (TNetWorkMsg *)_ptNetWork;

	if(NULL == ptNetWorkMsg)
	{
		dbg();
		return ERR;
	}
	LockMx(ptNetWorkMsg->m_SendMux);
	if(NET_TYPE_TCP == ptNetWorkMsg->m_iType)
	{
		tcp_close(ptNetWorkMsg->m_iSocket);
	}
	else
	{
		udp_close(ptNetWorkMsg->m_iSocket);
	}
	UnLockMx(ptNetWorkMsg->m_SendMux);
	
	ptNetWorkMsg->m_iSocket = INVALID_SOCKET;

	return OK;
}

int net_Destroy(TNetWork *_ptNetWork)
{
	TNetWorkMsg *ptNetWorkMsg = (TNetWorkMsg *)_ptNetWork;
	
	if(NULL == ptNetWorkMsg)
	{
		dbg();
		return ERR;
	}
	/*
	Lock(ptNetWorkMsg->m_SendMux);
	UnLock(ptNetWorkMsg->m_SendMux);
	Lock_Destroy(ptNetWorkMsg->m_RecvMux);
	Lock_Destroy(ptNetWorkMsg->m_SendMux);
	*/
	if(ptNetWorkMsg) 
	{
    	free(ptNetWorkMsg);
    	ptNetWorkMsg = NULL;
	}
	return OK;
}


///////////////////////////////非阻塞读写////////////////////////////////////////
static int tcp_nb_send(int _iSocket, const char* _pcBuf, int _iLen)
{
    if(_iSocket <= 0 || NULL == _pcBuf || _iLen <= 0)
	{
		dbg();
		dbgprintf(0,"Socket:%d,Buf(%s),Len:%d",_iSocket,_pcBuf,_iLen);
		return ERR;
	}
	
	int iEintrCount = 0;
	int iEagainCount = 0;
	int iSend = 0;
	int iTotal = _iLen;
	const char *pcSend = _pcBuf;

	while(iTotal > 0)
	{
		iSend = send(_iSocket, pcSend, iTotal, 0);

		if(iSend < 0)
		{
		    if(errno == EINTR)  // 信号中断了
		    {
		        iEintrCount++;
		        if(iEintrCount > 3)
		        {
                    dbgint(errno);
		            break;
		        }
		        else
		        {
		            usleep(1000);
				    continue;
		        }
		    }
			else if(errno == EAGAIN || errno == EWOULDBLOCK)//缓冲满了,以后要改成加入epoll，等可写通知
			{
			    iEagainCount++;
			    if(iEagainCount > 1000)
			    {
			        break;//秒内，一点消息都没发出去,这个socket应该出问题了，时间可能再调整
			    }
				usleep(1000);
				continue;
			}
            dbgint(errno);
			return ERR;
		}
		else if(iSend == 0)
		{
		    dbgint(errno);
			return ERR;
		}

		if(iSend == iTotal)
		{
			return _iLen;
		}
        iEagainCount = 0;
        iEintrCount = 0;
        
		iTotal -= iSend;
		pcSend += iSend;
	}

	return (_iLen - iTotal);
}

int net_nb_Send(TNetWork *_ptNetWork, const char *_pcSend, int _iLen)
{
	if(NULL == _ptNetWork || NULL == _pcSend || _iLen <= 0)
	{
		dbg();
		return ERR;
	}

	int iRet = 0;
	TNetWorkMsg *ptNetWorkMsg = (TNetWorkMsg *)_ptNetWork;
	if(ptNetWorkMsg->m_iSocket == INVALID_SOCKET)
	{
		dbg();
		return ERR;
	}
	
#ifdef DEBUG_ON
	struct sockaddr_in clientaddr;
	socklen_t clilen = sizeof(clientaddr);
	if(getpeername(ptNetWorkMsg->m_iSocket, (struct sockaddr *)&clientaddr, &clilen) == 0)
	{
		dbgprintf(0, "%s,%d,Send Data To: %s:%d Len:%d", __func__, __LINE__, inet_ntoa(clientaddr.sin_addr),ntohs(clientaddr.sin_port),_iLen);
	}
	else
	{
		dbgint(_iLen);
	}
#endif

	LockMx(ptNetWorkMsg->m_SendMux);
	if(NET_TYPE_TCP == ptNetWorkMsg->m_iType)
	{
	//	iRet = tcp_nb_send(ptNetWorkMsg->m_iSocket, _pcSend, _iLen);
		iRet = tcp_nb_send_all(ptNetWorkMsg->m_iSocket, _pcSend, _iLen);
	}

	UnLockMx(ptNetWorkMsg->m_SendMux);

	return iRet;
}

static int tcp_nb_recv(int _iSocket, char *_pcRecv, int _iLenMax)
{
	if(_iSocket <= 0 || NULL == _pcRecv || _iLenMax < 1)
	{
		dbg();
		return ERR;
	}

	int iRet = 0;
	int iRetTmp;
	int iEintrCount = 0;
	while(iRet <_iLenMax)
	{
		iRetTmp = recv(_iSocket, _pcRecv + iRet, _iLenMax - iRet, 0);
		if(iRetTmp < 0) 
		{
		    if(errno == EINTR)
		    {
		        iEintrCount++;
		        if(iEintrCount > 3)
		        {
                    dbgint(errno);
		            break;
		        }
		        else
		        {
		            usleep(1000);
		            continue;
		        }
		    }
			else if(errno == EAGAIN || errno == EWOULDBLOCK)// 缓冲没数据了
			{
				break;
			}
			else
			{
				dbgint(errno);
				return ERR;
			}
		}
		else if(0 == iRetTmp)	// 对端关闭
		{
			dbg();
			return ERR;
		}
		iRet += iRetTmp;
	}
	
	return iRet;
}

int net_nb_Recv(TNetWork *_ptNetWork, char *_pcRecv, int _iLenMax)
{
	if(NULL == _ptNetWork || NULL == _pcRecv || _iLenMax <= 0)
	{
		dbg();
		return ERR;
	}

	int iRet = 0;
	TNetWorkMsg *ptNetWorkMsg = (TNetWorkMsg *)_ptNetWork;
	if(ptNetWorkMsg->m_iSocket == INVALID_SOCKET)
	{
		dbg();
		return ERR;
	}

	LockMx(ptNetWorkMsg->m_RecvMux);
	
	if(NET_TYPE_TCP == ptNetWorkMsg->m_iType)
	{
		iRet = tcp_nb_recv(ptNetWorkMsg->m_iSocket, _pcRecv, _iLenMax);
	}

	UnLockMx(ptNetWorkMsg->m_RecvMux);

	return iRet;
}


