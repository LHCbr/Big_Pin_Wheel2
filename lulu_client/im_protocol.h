#ifndef __IM_PROTOCOL_HPP__
#define __IM_PROTOCOL_HPP__

#define __STDC_FORMAT_MACROS
#include <inttypes.h>

#include <stdint.h>



#pragma pack(1)

#define HighWaterMarkSize	10 * 1024 * 1024
#define LowWaterMarkSize	5 * 1024 * 1024

#define MAX_IP_LEN 16
//密码最大长度
#define MAX_PSW_LEN 33

enum CompareType
{
	cmpr_null = 0,
	cmpr_zip,
	cmpr_rc4,
	cmpr_zip_rc4,
};

#define PROTOCOL_KEY1	0xF9
#define PROTOCOL_KEY2	0x28

#define PACK_HEAD_LEN	sizeof(PackHead)
#define MSG_HEAD_LEN	sizeof(MsgHead)
#define PACK_INFO_LEN	sizeof(PackInfo)

typedef struct	PackHead_
{
	uint8_t		proKey1;
	uint32_t	crc32;				// 包头校验
	uint32_t	dataLen;			// 包长,不包括包头自己;放到最前，可以兼容其他系统
	struct
	{
		uint8_t Version:4;			// 最多１６个版本，过早版本直接放弃
		uint8_t Compressed:4;		// 压缩或者加密，混合最多情况
	}; 
//	uint16_t	iRatio;				// 是原始长度的多少倍,不要DWORD	RawLen;	没有压缩前的长度
	uint32_t	unzipLen;			// 没有压缩前的长度
	uint8_t		proKey2;
}PackHead,*PPackHead;

typedef struct	MsgHead_
{
	uint32_t	iFun;			// 业务信息
	uint8_t		iSerial;		// 消息序列号
}MsgHead,*PMsgHead;

// 实际处理的包头
typedef struct	PackInfo_ : public PackHead
{
	MsgHead msgHead;
	char		data[0];
}PackInfo,*PPackInfo;

//返回简单的执行结果，用户登录，注册等
typedef int32_t ReturnData;
// 函数返回值
enum
{	
	RES_ERR 		= -1,
	RES_OK 			= 0,	
};

typedef struct LnkInfo_
{
	char ip[MAX_IP_LEN];
	uint32_t port;
}LnkInfo,*PLnkInfo;

typedef struct LnkSvrInfo_ : LnkInfo_
{
	uint32_t lnkSvrId;			//链接服务器的ID，不能有相同的
	uint32_t lnkSvrClient;		//已经连接到该链接服务器上的用户数
}LnkSvrInfo,*PLnkSvrInfo;

typedef struct
{
	uint64_t iArea		:14;					// 国际区号，最多四位
	uint64_t llUserId	:37; 					// 用户名 手机号
	uint64_t			:13; 					// 兼容windows的sizeof
}PhoneInfo,*PPhoneInfo;

#pragma pack ()

#endif