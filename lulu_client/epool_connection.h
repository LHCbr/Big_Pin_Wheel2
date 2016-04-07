#ifndef _EPOOL_CONNECTION_H_
#define _EPOOL_CONNECTION_H_

#include "ringbuf.h"
#include "t_list.h"

#if EPOOL_CONNECTION_LOCK
#include <pthread.h>
#endif

#define EPOOL_CONNECTION_LOCK 	0 // 使用锁

enum TEpoolState
{
	EPOOL_STATE_UNINIT	= 0,		// 未分配
	EPOOL_STATE_INIT ,				// 已分配	
	EPOOL_STATE_WORK,			// 开始解析
	EPOOL_STATE_CLOSING,			// 等待关闭
	EPOOL_STATE_CLOSED,			// 已经关闭
};

enum TEpoolType
{
	EPOOL_TYPE_UNKNOWN = 0,	// 未知
	EPOOL_TYPE_COM = 1,		// 串口
	EPOOL_TYPE_CAN,			// CAN 口
	EPOOL_TYPE_CLIENT,		// 客户端
	EPOOL_TYPE_SERVER,		// 服务器端，为每个接收到的连接创建一个线程
	EPOOL_TYPE_SOCKET,		// 服务器端接收到的连接
};

// 连接结构体
typedef struct EpoolConnection
{
	TStlHead m_Head;
	
	void *m_ptConnectStruct;		// 保存TNetWork、TCom、TCanSocket
	int m_iFd;					// 监听的套接字
	int m_iType;					// 监听类型TEpoolType	
	int m_iState;					// 连接状态TEpoolState,连接、工作、断开等
	TRingBuf *m_ptRecvRingBuf;	// 保存接收到的数据,以ringbuf的形式存储
	TList *m_ptRecvList;			// 保存接收到的数据，以包的形式存储
	//int m_iUserInt;					// 预留字段，可以用于解析状态等
	//void* m_iUserPointer;			// 预留字段
	
	int (*f_Start)(struct EpoolConnection *_ptEpoolConnection);// 客户端连接服务器
	int (*f_Recv)(struct EpoolConnection *_ptEpoolConnection);// 接收数据
	int (*f_Send)(struct EpoolConnection *_ptEpoolConnection, const void *_pcData, int _iLen);// 发送数据
	void* (*f_Accept)(struct EpoolConnection *_ptEpoolConnection);// 接收到连接
	void* (*f_AcceptGet)();// 得到存放接收的新连接的结构体
	int (*f_AcceptAfter)(struct EpoolConnection *_ptEpoolConnection);// 接收到连接以后
	int (*f_CloseBefore)(struct EpoolConnection *_ptEpoolConnection); // 关闭连接前
	int (*f_Close)(struct EpoolConnection *_ptEpoolConnection); // 关闭连接

	#if EPOOL_CONNECTION_LOCK
	pthread_mutex_t m_Lock; // 锁
	#endif
}TEpoolConnection;

// 设置连接、断开等操作的用户操作
typedef int (*FECOperation)(TEpoolConnection *_ptEpoolConnection);
typedef void* (*FECAcceptOperation)(TEpoolConnection *_ptEpoolConnection);
typedef void* (*FECAcceptGetOperation)();
typedef int (*FECSendOperation)(TEpoolConnection *_ptEpoolConnection, const void *_pcData, int _iLen);

enum
{
	EPOOL_OPERAT_START,
	EPOOL_OPERAT_RECV,
	EPOOL_OPERAT_ACCEPT_AFTER,
	EPOOL_OPERAT_CLOSE_BEFORE,
	EPOOL_OPERAT_CLOSE,
};

// 创建
void* ec_Create(int _iNodeSize, int _iSum);

// 析构
int ec_Destroy(void *_ptEC);

// 初始化
int ec_Init(void *_ptEC);

int ec_SetState(void *_ptEC, int _iState);
int ec_GetState(void *_ptEC);

// ptConnStruct 连接结构体
int ec_SetConnectStruct(void *_ptEC, void *_ptConnStruct);
void* ec_GetConnectStruct(void *_ptEC);

// 套接字
int ec_SetFd(void *_ptEC, int _iFd);
int ec_GetFd(void *_ptEC);
// 获取ip地址
int ec_GetIp(void *_ptEC, char * _pcOut, int _iMaxLen);


// 连接类型
int ec_SetEpoolType(void *_ptEC, int _iType);
int ec_GetEpoolType(void *_ptEC);

// Recv Ringbuf
int ec_SetRecvRingBuf(void *_ptEC, TRingBuf *_ptRingBuf);
TRingBuf* ec_GetRecvRingBuf(void *_ptEC);

// Recv List
int ec_SetRecvList(void *_ptEC, TList *_ptList);
TList* ec_GetRecvList(void *_ptEC);

// operation
int ec_SetOperation(void *_ptEC, int _iOperationType, FECOperation _pfOperationFun);

// 设置发送的函数指针
int ec_SetSendOperation(void *_ptEC, FECSendOperation _pfOperationFun);

// 设置接收连接的函数指针
int ec_SetAcceptOperation(void *_ptEC, FECAcceptOperation _pfOperationFun);

// 设置获取连接结构体的函数指针
int ec_SetAcceptGetOperation(void *_ptEC, FECAcceptGetOperation _pfOperationFun);
////////////////////////////////////////////////////////////////////////////////////////////////////////

// 连接
int ec_Start(void *_ptEC);

// 接收连接
int ec_Accept(void *_ptEC);

// 得到存放新连接的结构体
void* ec_AcceptGet(void *_ptEC);

// 接收
int ec_Recv(void *_ptEC);

// 发送
int ec_Send(void *_ptEC, const void *_pcData, int _iLen);

// 关闭
int ec_Close(void *_ptEC);

#endif

