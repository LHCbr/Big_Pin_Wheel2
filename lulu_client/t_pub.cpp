#include "t_pub.h"

#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <errno.h>
#include <fcntl.h>
#include <netdb.h>
//#include <sys/sysinfo.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <netinet/tcp.h>

#if RUN_ON_ANDROID
#include <linux/in.h>
#endif

int pub_DoSystem(const char *_pcStrCmd)
{
	//如果cmdstring为空趁早闪退吧，尽管system()函数也能处理空指针
	if(NULL == _pcStrCmd) return -1;
	
	int status = system(_pcStrCmd);
	return (status < 0) ? 0 : -1;
}

int set_socket_nonblock(int fd)
{
	if(INVALID_SOCKET == fd) return 0;
    int flag = fcntl(fd,F_GETFL,NULL);
    if (flag < 0) return 0;
    flag |= O_NONBLOCK;
    if (fcntl(fd,F_SETFL,flag) < 0) return 0;
    return -1;
}

int set_socket_linger(int fd)
{
    struct linger linger;
    
    linger.l_onoff = 1;
    linger.l_linger = 0;
    
    return setsockopt(fd,SOL_SOCKET,SO_LINGER,&linger,sizeof(struct linger));
}

int set_socket_reusable(int fd)
{
    int reuse_on = 1;
    return setsockopt(fd,SOL_SOCKET,SO_REUSEADDR,&reuse_on,sizeof(reuse_on));
}
#if 0
int IsTcpConnected(int fd)
{
	if(fd < 0) return 0;

	struct tcp_info info;
	int optlen = sizeof(struct tcp_info);
	if (getsockopt (fd, IPPROTO_TCP, TCP_INFO, &info, (socklen_t *)&optlen) < 0) return 0;

	if (info.tcpi_state == TCP_ESTABLISHED) return -1;

	return 0;
}
#endif


int tcp_wait_send(int _iSocket, int _tUSecTimeOut)
{
	if(_iSocket < 0) return -1;

	struct timeval timeout;
	timeout.tv_sec = _tUSecTimeOut / 1000000;
	timeout.tv_usec = _tUSecTimeOut % 1000000;

	fd_set fdWrite;
	FD_ZERO(&fdWrite);
	FD_SET(_iSocket, &fdWrite);

	return select(_iSocket + 1, NULL, &fdWrite, NULL, &timeout);
}

int tcp_wait_recv(int _iSocket, int _tUSecTimeOut)
{
	if(_iSocket < 0) return -1;

	struct timeval timeout;
	timeout.tv_sec = _tUSecTimeOut / 1000000;
	timeout.tv_usec = _tUSecTimeOut % 1000000;

	fd_set fdRead;
	FD_ZERO(&fdRead);
	FD_SET(_iSocket, &fdRead);

	return select(_iSocket + 1, &fdRead, NULL, NULL, &timeout);
}

int tcp_nb_send_some(int _iSocket, const char* _pcBuf, int _iLen)
{
	if(_iSocket <= 0 || NULL == _pcBuf || _iLen <= 0) return -1;
	int iSen = send(_iSocket, _pcBuf, _iLen, 0);

	if (iSen > 0) return iSen;
	//缓冲区已满
	if((iSen < 0) && (errno == EAGAIN || errno == EWOULDBLOCK)) return 0;
	//出错了
	return -1;
}
//如果超过缓存呢？
int tcp_nb_send_all(int _iSocket, const char* _pcBuf, int _iLen)
{
	if(_iSocket <= 0 || NULL == _pcBuf || _iLen <= 0) return -1;

	int iSendTotal = 0, iSendOnce = 0;
	while (iSendTotal < _iLen)
	{
		iSendOnce = tcp_nb_send_some(_iSocket, _pcBuf + iSendTotal, _iLen - iSendTotal);
		if (-1 == iSendOnce) return iSendTotal; //出错了 ,返回已经发送的量
		if (0 == iSendOnce)
		{
			int iRet = tcp_wait_send(_iSocket,30000000); //3秒
			if (iRet <= 0) return iSendTotal; //超时或出错,返回已经发送的量
		}
		iSendTotal += iSendOnce;
	}
	return iSendTotal;
}

int tcp_nb_recv_some(int _iSocket, char *_pcRecv, int _iLenMax)
{
	if(_iSocket <= 0 || NULL == _pcRecv || _iLenMax < 1) return -1;
	int iRcv = recv(_iSocket, _pcRecv, _iLenMax, 0);
	if (iRcv > 0 ) return iRcv;
	// 缓冲没数据了
	if((iRcv < 0) && (errno == EAGAIN || errno == EWOULDBLOCK)) return 0;

	return -1;
}

int tcp_nb_recv_all(int _iSocket, char *_pcRecv, int _iLenMax)
{
	if(_iSocket <= 0 || NULL == _pcRecv || _iLenMax < 1) return -1;
	
	int iRcvTotal = 0;
	int iRcvOnce;
	while(iRcvTotal < _iLenMax)
	{
		iRcvOnce = tcp_nb_recv_some(_iSocket, _pcRecv + iRcvTotal, _iLenMax - iRcvTotal);
		if (-1 == iRcvOnce) return -1; //出错,socket出问题了，需要断开
		if (0 == iRcvOnce)
		{
			int iRet = tcp_wait_recv(_iSocket,30000000); //3秒
			if (iRet <= 0) return -1;
		}
		iRcvTotal += iRcvOnce;
	}

	return iRcvTotal;
}