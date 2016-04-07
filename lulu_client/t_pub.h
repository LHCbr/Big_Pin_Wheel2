#ifndef _T_PUB_H_
#define _T_PUB_H_

#include <stdint.h>

typedef int32_t					T_JW_TYPE;			// 换算后的经纬度类型
#define IM_JW_RATE			(1000 * 1000)		// 经纬度系数

#define LockMx(Mux) 			    pthread_mutex_lock(&(Mux))		
#define UnLockMx(Mux) 		    pthread_mutex_unlock(&(Mux))
#define Lock_Init(Mux)		    pthread_mutex_init(&(Mux), NULL)
#define Lock_Destroy(Mux)	    pthread_mutex_destroy(&(Mux))


#define Lock_RD(Mux) 		    pthread_rwlock_rdlock(&(Mux))
#define Lock_WR(Mux) 		    pthread_rwlock_wrlock(&(Mux))
#define UnLock_RW(Mux) 		    pthread_rwlock_unlock(&(Mux))
#define Lock_Init_RW(Mux)	    pthread_rwlock_init(&(Mux), NULL)
#define Lock_Destroy_RW(Mux)	pthread_rwlock_destroy(&(Mux))

//无效网络套节字
#define INVALID_SOCKET 		(-1) 

#ifdef __cplusplus
extern "C" {
#endif

// 执行系统命令
int pub_DoSystem(const char *_pcStrCmd);
// 设置网络套接字为非阻塞
int set_socket_nonblock(int fd);
//设置函数close()关闭TCP连接时,立即关闭该连接
int set_socket_linger(int fd);
//设置复用，不然bind的时候会出错
int set_socket_reusable(int fd);

//下面的几个函数都是非线程安全的
int tcp_wait_recv(int _iSocket, int _tUSecTimeOut = 0);
int tcp_wait_send(int _iSocket, int _tUSecTimeOut = 0);
int tcp_nb_send_some(int _iSocket, const char* _pcBuf, int _iLen);
int tcp_nb_send_all(int _iSocket, const char* _pcBuf, int _iLen);
int tcp_nb_recv_some(int _iSocket, char *_pcRecv, int _iLenMax);
int tcp_nb_recv_all(int _iSocket, char *_pcRecv, int _iLenMax);


#if 0
int IsTcpConnected(int fd);
#endif

#ifdef __cplusplus
}
#endif

#endif


