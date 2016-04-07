#include "im_client.h"
#include "network.h"
#include "ringbuf.h"
#include "t_base.h"
#include "t_char.h"
#include "t_num.h"
#include "t_time.h"
#include "t_file.h"
#include "im_pub_service.h"
#include "mines.h"
#include "file_waiting_confirm.h"
#include "im_client_msg_filter.h"

#include "ImMsg.h"
#include "util.h"

#include "json/json.h"
#include "util.h"
using namespace std;
using namespace Json;

#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <time.h>
#include <sys/time.h>

#if RUN_ON_ANDROID

#include <android/log.h>

#define TAG "Lk"
#define LOGD(...) __android_log_print(ANDROID_LOG_DEBUG,TAG,__VA_ARGS__) // 定义LOGD类型
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO,TAG,__VA_ARGS__) // 定义LOGI类型
#define LOGW(...) __android_log_print(ANDROID_LOG_WARN,TAG,__VA_ARGS__) // 定义LOGW类型
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR,TAG,__VA_ARGS__) // 定义LOGE类型
#define LOGF(...) __android_log_print(ANDROID_LOG_FATAL,TAG,__VA_ARGS__) // 定义LOGF类型
#endif

typedef struct
{
	int m_iSendFile;			// 是否正在使用发送文件功能
	int m_iSendStart;			// 是否开始发送
	uint64_t m_llFileName;		// 文件名
	char m_pcMD5[MD5_LEN];		// 文件md5
	int32_t m_iFileType;		// 文件类型
	int32_t m_iFileSerial;		// 已发送的包数目 / 序列号
	int32_t m_iFileMaxSerial;	// 包的总数目 / 序列号
	char *m_pcData;				// 文件内容
	uint32_t m_iDataMemSize;	// 已经开辟内存的总长度
	int32_t m_iDataLen;			// 当前要发送的文件总长度
	uint32_t iLastSendTime;		// 最后一次发送数据的时间
	int32_t m_iDataLenRecv;		// 服务器已经接收到的数据长度
} TClientUploadFile;

typedef struct
{
	int iDownLoad; // 是否正在下载
	int iDownloadSerial; // 接收的文件序列号
	char pcDownLoadUrl[MAX_FILE_PATH_LEN]; // 要下载的文件的服务器路径
	char *pcDownloadData; // 接收到的内容
	int iDownloadBuffSize; // 存放文件内容的数组长度
	int iDownloadSize; // 要下载文件的总大小
	int iDownloadLen; // 已接收的长度
	int iLastRcvTime; // 最后一次接收到数据的时间
	int iSvrSendFinsh; // 服务器已经发送完了，开始请求丢掉的数据包
	int iMaxSerial; // 文件最大序列号
	long long llFileName; // 下载文件唯一标识
} TClientDownloadFile;

typedef struct
{
	TNetWork *m_Connection; // 简单判断socket是否还连接在服务器
	int m_IsConnected; // 连接结构体
	TRingBuf *m_RingBuf; // 数据接收池
	unsigned char m_CurrentSerial; // 接收序列号，在0--255之间循环
	unsigned char m_SendSerial; // 发送序号，在0--255之间循环
	int m_iThreadCreateRet; // 判断客户端线程是否创建成功
	int m_iLastEventTime; // 最后一次处理数据的时间
} TClientNetWork;

TClientDownloadFile g_DownloadFileMain; //主线程下载变量

static TNetWork *g_Connection = NULL;
static TRingBuf *g_RingBuf = NULL;
static unsigned char g_CurrentSerial = 0;
static unsigned char g_SendSerial = 0; // 发送序号，在0--255之间循环

static int g_iThreadCreateRet = -1;
//判断客户端线程是否创建成功
static int g_iThreadImConnectRet = -1;

#if RUN_TWO_THREAD
/*
static int g_OtherIsConnected = 0;
TNetWork *g_OtherConnection = NULL;
static unsigned char g_OtherSendSerial = 0; // 发送序号，在0--255之间循环
static TRingBuf *g_OtherRingBuf = NULL;

static int g_iOtherThreadCreateRet = -1;//判断客户端上传下载线程是否创建成功
*/
static TClientUploadFile g_UploadFile2;
static TClientNetWork *g_Connection2;
TClientDownloadFile g_DownloadFileOther; //连接到文件服务器下载变量

// 用于接收数据
//static int g_iOtherDownLoad = 0; // 是否正在下载
//static int g_iOtherDownloadSerial = 0; // 接收的序列号
//static char g_pcOtherDownLoadUrl[128];
//static char* g_pcOtherDownloadData = NULL; // 接收到的内容
//static int g_iOtherDownloadBuffSize = 0; // g_pcOtherDownloadData的长度
//static int g_iOtherDownloadSize = 0; // 正在接收的文件长度
//static int g_iOtherDownloadLen = 0; // 已接收的长度
#endif

#if IM_HEART_ENABLE
static unsigned int g_uLastRecvTime = 0;
static unsigned int g_uLastSendTime = 0;
#endif

#if 0
// 用于断点续传
static int g_iSendFile = 0; // 是否正在使用发送文件功能
static int g_iSendStart = 0; // 是否开始发送
static unsigned int g_uFileName = 0; // 文件名
static int g_iFileType = 0; // 文件类型
static int g_iFilePacket = IM_ONE_PACKAGE_SIZE; // 发送文件的包大小
static int g_iFileSerial = 0; // 已发送的包数目
static char *g_pcData = NULL; // 文件内容
static int g_iDataSize = 0; // g_pcData 的长度
static int g_iDataLen = 0; // 要发送的数据总长度
#endif

#if RUN_ON_ANDROID
static JNIEnv *g_jniEnv[2] = {0};
static JavaVM *g_jvm = NULL;
static jclass g_jClass = NULL;
static jmethodID g_jCallback[2] = {0};
#else

static FImCallback g_ptCallbackFun = NULL;

#endif

// 线程运行状态
enum
{
	IM_C_STATE_STOP,
	IM_C_STATE_RUNING
};
// 线程运行状态
enum
{
	IM_C_BG_STATE_NO,
	IM_C_BG_STATE_YES
};

static int g_iState = IM_C_STATE_STOP;
static int g_iBackgroundState = IM_C_BG_STATE_NO;
//程序是否后台运行
static pthread_mutex_t m_BackgrounpMux; //进入后台后，直接锁住线程

#if RUN_TWO_THREAD

static int OtherSendData(char *_pcSend, int _iCount);

static int OtherSendDataV2(TClientNetWork *_Connection, char *_pcSend, int _iCount);
static int OtherSendMsg(const char *_szBuf, size_t _bufLen, uint32_t _iFun, uint8_t _iSerial = 0, bool bEncoode = false);
static int OtherSendMsgV2(TClientNetWork *_Connection, const char *_szBuf, size_t _bufLen, uint32_t _iFun, uint8_t _iSerial = 0, bool bEncoode = false);
#endif

int im_c_Connect();

static inline int CallBackFunc(uint32_t _iFun, char *_pcJsonString, uint32_t _iJsonLen, char *_pcBitBuf = NULL, uint32_t _iBufLen = 0
#ifdef RUN_ON_ANDROID
	,uint32_t iThreadId = 0
#endif
	 )
{
#if RUN_ON_ANDROID
	jbyteArray JsonArray = 0;
	if (_iJsonLen > 0)
	{
		JsonArray = g_jniEnv[iThreadId]->NewByteArray(_iJsonLen);
		g_jniEnv[iThreadId]->SetByteArrayRegion(JsonArray, 0, _iJsonLen, (const jbyte *) _pcJsonString);
	}

	jbyteArray BitBufArray = 0;
	if(_iBufLen > 0)
	{
		BitBufArray = g_jniEnv[iThreadId]->NewByteArray(_iBufLen);
		g_jniEnv[iThreadId]->SetByteArrayRegion(BitBufArray, 0, _iBufLen, (const jbyte *) _pcBitBuf);
	}

	int iRet = g_jniEnv[iThreadId]->CallStaticIntMethod(g_jClass, g_jCallback[iThreadId], _iFun, JsonArray, _iJsonLen, BitBufArray, _iBufLen);

	if(_iBufLen > 0)
	{
		g_jniEnv[iThreadId]->ReleaseByteArrayElements(BitBufArray, (jbyte *) _pcBitBuf, JNI_COMMIT);
		g_jniEnv[iThreadId]->DeleteLocalRef(BitBufArray);
	}

	if (_iJsonLen > 0)
	{
		g_jniEnv[iThreadId]->ReleaseByteArrayElements(JsonArray, (jbyte *) _pcJsonString, JNI_COMMIT);
		g_jniEnv[iThreadId]->DeleteLocalRef(JsonArray);
	}

	return iRet;
#else
	return g_ptCallbackFun(_iFun, _pcJsonString, _iJsonLen, _pcBitBuf, _iBufLen);
#endif
}

static inline int CallBackFunc(uint32_t _iFun, const Value& jWriteValue, char *_pcBitBuf = NULL, uint32_t _iBufLen = 0)
{
	FastWriter fastWrite;
	string strJson = fastWrite.write(jWriteValue);
	return CallBackFunc(_iFun, (char*)strJson.c_str(), strJson.length(), _pcBitBuf, _iBufLen);
}

static inline int OtherCallBackFunc(uint32_t _iFun, const Value& jWriteValue, char *_pcBitBuf = NULL, uint32_t _iBufLen = 0)
{
	FastWriter fastWrite;
	string strJson = fastWrite.write(jWriteValue);
	return CallBackFunc(_iFun, (char*)strJson.c_str(), strJson.length(), _pcBitBuf, _iBufLen
#ifdef RUN_ON_ANDROID
		,1
#endif
	);
}

static inline int CallBackJson(uint32_t _iJsonType, char *_pcJsonString, uint32_t _iLen)
{
	Value jWriteValue;
	Reader jReader(Json::Features::strictMode());
	if (!jReader.parse(_pcJsonString,jWriteValue)) return ERR;

//	jWriteValue["json_type"] = Value(_iJsonType).asString();
	jWriteValue["ret"] = Value(0).asString(); //成功标识
	return CallBackFunc(_iJsonType,jWriteValue);//FUN_GET_JSON
}

static inline int CallBackRecv(uint32_t _iFun, int64_t _iIndex, uint64_t _llSrcUser, uint64_t _llDstUser,  uint32_t _uTime, int32_t _iDataType, char *_pcData, uint32_t _iDataLen)
{
	Value jWriteValue;
	jWriteValue["index"] = Value((Int64)_iIndex).asString();
	jWriteValue["src_area"] = Value((UInt64)_llSrcUser/PhoneMaxBit).asString();
	jWriteValue["src_user"] = Value((UInt64)_llSrcUser%PhoneMaxBit).asString();
	jWriteValue["dst_area"] = Value((UInt64)_llDstUser/PhoneMaxBit).asString();
	jWriteValue["dst_user"] = Value((UInt64)_llDstUser%PhoneMaxBit).asString();
	jWriteValue["time"] = Value(_uTime).asString();
	jWriteValue["data_type"] = Value(_iDataType & 0xFFFF).asString();
	jWriteValue["additional"] = Value(_iDataType >> 16).asString();
	string strData;
	strData.assign(_pcData,_iDataLen);
	jWriteValue["data"] = strData;
	jWriteValue["data_len"] = Value(_iDataLen).asString();

	return CallBackFunc(_iFun,jWriteValue);
}

static inline int CallBackRecvGroupMsg(uint32_t _iFun, int32_t _iIndex, uint64_t _llSrcUser, uint64_t _llGroupId, uint32_t _uTime, int32_t _iDataType, char *_pcData, uint32_t _iDataLen)
{
	Value jWriteValue;
	jWriteValue["index"] = Value(_iIndex).asString();
	jWriteValue["src_area"] = Value((UInt64)_llSrcUser/PhoneMaxBit).asString();
	jWriteValue["src_user"] = Value((UInt64)_llSrcUser%PhoneMaxBit).asString();
	jWriteValue["group_id"] = Value((UInt64)_llGroupId).asString();
	jWriteValue["time"] = Value(_uTime).asString();
	jWriteValue["data_type"] = Value(_iDataType & 0xFFFF).asString();
	jWriteValue["additional"] = Value(_iDataType >> 16).asString();
	string strData;
	strData.assign(_pcData,_iDataLen);
	jWriteValue["data"] = strData;
	jWriteValue["data_len"] = Value(_iDataLen).asString();

	return CallBackFunc(_iFun,jWriteValue);
}

static inline int CallBackReturn(int32_t _iFun, int32_t _iRetFun, int32_t _iRetSerial, int64_t _iRet)
{
	Value jWriteValue;
	jWriteValue["fun"] =Value(_iRetFun).asString();
	jWriteValue["serial"] = Value(_iRetSerial).asString();
	jWriteValue["ret"] = Value((Int64)_iRet).asString();
	//"{\"fun\":\"xxxx\",\"serial\":\"1\",\"ret\":\"0 成功，-1 失败\"}"
	return CallBackFunc(_iRetFun,jWriteValue);
}

static inline int CallBackState(int32_t _iState, int64_t _iRet, int32_t _iAdditional)
{
	if (IM_STATE_CLOSE == _iState || IM_STATE_RE_LOGIN == _iState)
	{
		dbg();
		im_c_DisConnect();
	}
	Value jWriteValue;
	jWriteValue["state"] = Value(_iState).asString();
	jWriteValue["ret"] = Value((Int64)_iRet).asString();
	jWriteValue["additional"] = Value(_iAdditional).asString();
	return CallBackFunc(IM_FUN_STATE,jWriteValue);
}

static inline int CallBackUserList(uint32_t _iFun, int32_t _iType, uint32_t _iCount, uint64_t *_pllFriendList) 
{
	Value jWriteValue;
	jWriteValue["type"] = Value(_iType).asString();
	jWriteValue["friend_count"] = Value(_iCount).asString();
	Value vFriendLst;
	for (int i = 0; i < _iCount; i++)
	{
		Value vTmp;
		vTmp["user_area"] = Value((UInt64)_pllFriendList[i]/PhoneMaxBit).asString();
		vTmp["user_id"] = Value((UInt64)_pllFriendList[i]%PhoneMaxBit).asString();
		vFriendLst.append(vTmp);
	}
	jWriteValue["friend_list"] = vFriendLst;
	return CallBackFunc(_iFun,jWriteValue);
}

static inline int CallBackSelfInfo(uint32_t _iFun, uint64_t _llUserId, uint8_t _iSex, char *_pcNickName, int32_t _iMines, char *_pcArea)
{
	Value jWriteValue;
	jWriteValue["user_area"] = Value((UInt64)_llUserId/PhoneMaxBit).asString();
	jWriteValue["user_id"] = Value((UInt64)_llUserId%PhoneMaxBit).asString();
	jWriteValue["sex"] = Value(_iSex).asString();
	jWriteValue["nickname"] = Value(_pcNickName).asString();
	jWriteValue["mines"] = Value(_iMines).asString();
	jWriteValue["area"] = Value(_pcArea).asString();
	return CallBackFunc(_iFun,jWriteValue);
}

static inline int CallBackAddFriendForce(uint32_t _iFun, uint64_t _llUserId, int8_t _iRet, uint8_t _iAdd)
{
	Value jWriteValue;
	jWriteValue["user_area"] = Value((UInt64)_llUserId/PhoneMaxBit).asString();
	jWriteValue["user_id"] = Value((UInt64)_llUserId%PhoneMaxBit).asString();

	jWriteValue["ret"] = Value(_iRet).asString();
	jWriteValue["bAdd"] = Value(_iAdd).asString(); //0 添加， 1被添加
	return CallBackFunc(_iFun,jWriteValue);
}
#if 0
//_iType 0 直接获取好友信息的返回 1 是通过查找的返回
static inline int CallBackUserInfo(uint32_t _iFun, uint64_t _llUser, uint8_t _iSex, char *_pcNickName, int32_t _iType, char *_pcArea) 
{
	Value jWriteValue;
	jWriteValue["user_id"] = Value((UInt64)_llUser).asString();
	jWriteValue["sex"] = Value(_iSex).asString();
	jWriteValue["nickname"] = _pcNickName;
	jWriteValue["type"] = Value(_iType).asString();
	jWriteValue["area"] = _pcArea;
	return CallBackFunc(_iFun,jWriteValue);
}
#endif

static inline int CallBackUpLoadFinish(uint32_t _iFun, uint32_t _uFileName, char *_pcFilePath)
{
	Value jWriteValue;
	jWriteValue["file_name"] = Value(_uFileName).asString();
	jWriteValue["file_path"] = _pcFilePath;
	return CallBackFunc(_iFun,jWriteValue);
}

static inline int CallBackLibMines(uint32_t _iFun, int32_t _iMinesSum, int32_t _iSetOrdinary, int32_t _iSetFriend, int32_t _iDoOrdinary, int32_t _iDoFriend, int32_t _iFailure, int32_t _iEarn)
{
	Value jWriteValue;
	jWriteValue["mines_sum"] = Value(_iMinesSum).asString();
	jWriteValue["set_ordinary"] = Value(_iSetOrdinary).asString();
	jWriteValue["set_friend"] = Value(_iSetFriend).asString();
	jWriteValue["do_ordinary"] = Value(_iDoOrdinary).asString();
	jWriteValue["do_friend"] = Value(_iDoFriend).asString();
	jWriteValue["failure"] = Value(_iFailure).asString();
	jWriteValue["earn"] = Value(_iEarn).asString();
	return CallBackFunc(_iFun,jWriteValue);
}

int CallBackDownloadFinish()
{
	g_DownloadFileMain.iDownLoad = 0;
	g_DownloadFileMain.iLastRcvTime = 0;

	Value jWriteValue;
	jWriteValue["download_url"] = g_DownloadFileMain.pcDownLoadUrl;
	return CallBackFunc(IM_FUN_DOWNLOAD_RE_FINISH, jWriteValue, g_DownloadFileMain.pcDownloadData, g_DownloadFileMain.iDownloadLen);
}

// 发送数据
static int c_SendData(char *_pcSend, int _iCount)
{
	if (IM_C_STATE_STOP == g_iState)
	{
		dbg();
		return ERR;
	}

	if (_iCount == net_Send(g_Connection, _pcSend, _iCount))
	{
#if IM_HEART_ENABLE
		// 更新最后发送时间
		g_uLastSendTime = time_GetSecSince1970();
#endif

		return OK;
	}
	else
	{
		net_Close(g_Connection);
		CallBackState(IM_STATE_CLOSE, 0, 0);
		dbg();
		return IM_RET_NO_NETWORK;
	}
}

// 发送数据
static int c_SendMsg(const char *_szBuf, size_t _bufLen, uint32_t _iFun, uint8_t _iSerial = 0)
{
	CImMsg imMsg;
	imMsg.set_data(_szBuf, _bufLen, _iFun, _iSerial);
	return c_SendData((char *) imMsg.head(), imMsg.length());
}

static int c_SendMsg(const CImMsg &imMsg)
{
	return c_SendData((char *) imMsg.head(), imMsg.length());
}

static int c_FormatAndSendData(char *_pcSend, int _iLen, int _iFun, int _iSerial)
{
	im_pub_SetFrameHead(_pcSend, _iLen - im_pub_GetHeadLen(), _iFun, _iSerial);
	im_pub_SetFrameEnd(_pcSend, _iLen);

	_iLen += im_pub_GetEndLen();

	return c_SendData(_pcSend, _iLen);
}

static int c_FormatAndSendData_other(TClientNetWork *_Connection, char *_pcSend, int _iLen, int _iFun, int _iSerial)
{
	im_pub_SetFrameHead(_pcSend, _iLen - im_pub_GetHeadLen(), _iFun, _iSerial);
	im_pub_SetFrameEnd(_pcSend, _iLen);

	_iLen += im_pub_GetEndLen();

	return OtherSendDataV2(_Connection, _pcSend, _iLen);
}

static int SendNoData(int _iFun)
{
	return c_SendMsg(NULL, 0, _iFun, g_SendSerial++);
}

static int SendOneInt(int32_t _iFun, int32_t _iData)
{
	TOneIntData oneData;
	oneData.m_iData = _iData;
	if (c_SendMsg((const char *) &oneData, sizeof(TOneIntData), _iFun, g_SendSerial++))
	{
		dbg();
		return ERR;
	}
	// 返回发送的序列号
	return g_SendSerial - 1;
}

static int SendOneLongLong(int32_t _iFun, int64_t _llData)
{
	TOneLongLongData oneData;
	oneData.m_llData = _llData;
	if (c_SendMsg((const char *) &oneData, sizeof(TOneLongLongData), _iFun, g_SendSerial++))
	{
		dbg();
		return ERR;
	}
	// 返回发送的序列号
	return g_SendSerial - 1;
}

static int SendOneString(int _iFun, char *_pcData, int _iLen)
{
	char pcSend[10240] = {0};
	if (NULL == _pcData || _iLen < 0 || _iLen > 10240)
	{
		dbg();
		return ERR;
	}
	TOneStringData *ptOneData = (TOneStringData *) (pcSend);
	if (NULL == ptOneData) return ERR;
	ptOneData->m_iLen = _iLen;
	char_ncopy(ptOneData->m_pcData, _pcData, ptOneData->m_iLen + 1);
	if (c_SendMsg((const char *) &pcSend, sizeof(TOneStringData) + _iLen + 1, _iFun, g_SendSerial++))
	{
		dbg();
		return ERR;
	}
	// 返回发送的序列号
	return g_SendSerial - 1;
}

static int GetJsonData(int64_t _llPageStartIndex, uint32_t _iJsonType)
{
	char pcSend[256] = {0};
	TOneJsonData *ptOneJsonData = (TOneJsonData *) pcSend;

	if (NULL == ptOneJsonData)
	{
		dbg();
		return ERR;
	}

	ptOneJsonData->m_llPageStartIndex = _llPageStartIndex;
	ptOneJsonData->m_iJsonType = _iJsonType;

	return c_SendMsg(pcSend, sizeof(TOneJsonData), FUN_GET_JSON, g_SendSerial++);
}

#if IM_HEART_ENABLE

// 发送心跳包
static int SendHeart()
{
	if (IM_C_STATE_STOP == g_iState)
	{
		return ERR;
	}
	return SendNoData(IM_FUN_HEART);
}

#endif

static inline int SendReturn(uint32_t _iFun, int32_t _iSerial, int64_t _iRet)
{
	TReturnData tReturnData;
	tReturnData.m_iFun = _iFun;
	tReturnData.m_cSerial = (uint8_t)_iSerial;
	tReturnData.m_iRet = _iRet;
	return c_SendMsg((const char *) &tReturnData, sizeof(TReturnData), IM_FUN_RETURN, g_SendSerial++);
}

static int SendReSerial(uint32_t _iFun, int64_t _iSendIndex)
{
	return SendReturn(_iFun, g_CurrentSerial - 1, _iSendIndex);//IM_RET_SERIAL
}
/*
static int SendErrSerial(int _iFun)
{
return SendReturn(_iFun, g_CurrentSerial - 1, IM_RET_ERR_SERIAL);
}
*/

// 接收到朋友圈列表
static int RecvJson(int _iFun, char *_pcData, int _iLen)
{
	return CallBackJson(_iFun, _pcData, _iLen);
}

// 接收到消息
static int RecvUserMsg(uint32_t _iFun, char *_pcData, int32_t _iLen)
{
	TSendUserData *ptSendUserData = (TSendUserData *)(_pcData + im_pub_DataStartLen);

	if (NULL == ptSendUserData)
	{
		dbg();
		return ERR;
	}

	SendReSerial(_iFun, ptSendUserData->m_iIndex);
	if (ERR == MsgFilterInstance().AddMsgToFilter(ptSendUserData->m_iIndex, ptSendUserData->m_iLen))
	{
		dbgll(ptSendUserData->m_iIndex);
		return ERR;
	}
	return CallBackRecv(_iFun, ptSendUserData->m_iIndex, ptSendUserData->m_llSrcUserId, ptSendUserData->m_llDstUserId,
		ptSendUserData->m_uTime, ptSendUserData->m_iType, ptSendUserData->m_pcData, ptSendUserData->m_iLen);
}

// 接收到群消息
static int RecvGroupMsg(uint32_t _iFun, char *_pcData, uint32_t _iLen)
{
	TSendGroupData*ptSendGroupData = (TSendGroupData *)(_pcData + im_pub_DataStartLen);
	if (NULL == ptSendGroupData)
	{
		dbg();
		return ERR;
	}
	SendReSerial(_iFun, ptSendGroupData->m_iIndex);
	if (ERR == MsgFilterInstance().AddMsgToFilter(ptSendGroupData->m_iIndex, ptSendGroupData->m_iLen))
	{
		dbg();
		return ERR;
	}
	return CallBackRecvGroupMsg(_iFun, ptSendGroupData->m_iIndex, ptSendGroupData->m_llSrcUserId, ptSendGroupData->m_llGroupId, 
		ptSendGroupData->m_uTime, ptSendGroupData->m_iType, ptSendGroupData->m_pcData, ptSendGroupData->m_iLen);
}

// 接收到个人详细信息
static int RecvSelfInfo(uint32_t _iFun, char *_pcData, uint32_t _iLen)
{
	TUserInfoData_SC *ptSelfInfoData = (TUserInfoData_SC *)(_pcData + im_pub_DataStartLen);

	if (NULL == ptSelfInfoData)
	{
		dbg();
		return ERR;
	}
	return CallBackSelfInfo(_iFun, ptSelfInfoData->m_llUserId, ptSelfInfoData->m_cSex, ptSelfInfoData->m_pcNickName, ptSelfInfoData->m_iMines, ptSelfInfoData->m_pcArea);
}

// 接收到用户详细信息 //_iType 0 直接获取好友信息的返回 1 是通过查找的返回
static int RecvUserInfo(uint32_t _iFun, char *_pcData, uint32_t _iLen, int32_t _iType)
{
	TUserInfoData *ptUserInfoData = (TUserInfoData *)(_pcData + im_pub_DataStartLen);
	if (NULL == ptUserInfoData)
	{
		dbg();
		return ERR;
	}
	Value jWriteValue;
//	jWriteValue["user_id"] = Value((UInt64)ptUserInfoData->user_id).asString(); //表ID
	jWriteValue["phone_num"] = Value((UInt64)ptUserInfoData->llUserId).asString();
	jWriteValue["phone_area"] = Value((UInt64)ptUserInfoData->iArea).asString();
	jWriteValue["sex"] = Value(ptUserInfoData->m_cSex).asString();
	jWriteValue["nick_name"] = ptUserInfoData->m_pcNickName;
	jWriteValue["birthday"] = ptUserInfoData->m_pcBirthday;
	jWriteValue["head_portrait"] = ptUserInfoData->m_pcHeadPortrait;
	jWriteValue["signature"] = ptUserInfoData->m_pcSignature;
	jWriteValue["identity"] = ptUserInfoData->m_cIdentity;

	jWriteValue["ret"] = Value(0).asString(); //成功标识
	return CallBackFunc(_iFun,jWriteValue);
}

// 接收到雷库信息
static int RecvLibMines(uint32_t _iFun, char *_pcData, int _iLen)
{
	TLibMinesData *ptLibMinesData = (TLibMinesData *)(_pcData + im_pub_DataStartLen);
	if (NULL == ptLibMinesData)
	{
		dbg();
		return ERR;
	}


	return CallBackLibMines(_iFun, ptLibMinesData->m_iMinesSum, ptLibMinesData->m_iSetOrdinary, ptLibMinesData->m_iSetFriend, ptLibMinesData->m_iDoOrdinary,
		ptLibMinesData->m_iDoFriend, ptLibMinesData->m_iFailure, ptLibMinesData->m_iEarn);
}

static int SendLostDownloadPack(void *_ptNode)
{
	TFileWaitingConfirm *ptNode = (TFileWaitingConfirm *) _ptNode;

	if (NULL == ptNode) {
		dbg();
		return ERR;
	}
	int iRet = SendOneInt(IM_FUN_DOWNLOAD_LOST_PACK, ptNode->m_iSerial);
	usleep(IM_TIME_BETWEEN_PACKAGE);
	// TskImClientSleep(0,IM_TIME_BETWEEN_PACKAGE);
	return iRet;
}

static int OtherSendLostDownloadPack(void *_ptNode)
{
	int nRet = 0;
	TFileWaitingConfirm *ptNode = (TFileWaitingConfirm *) _ptNode;

	if (NULL == ptNode)
	{
		dbg();
		return ERR;
	}

	TDownLoadContinue tDownLoadData;
	tDownLoadData.m_llFileName = g_DownloadFileOther.llFileName;
	tDownLoadData.m_nDownLoadSerial = ptNode->m_iSerial;
	nRet = OtherSendMsgV2(g_Connection2, (const char *) &tDownLoadData, sizeof(TDownLoadContinue), IM_FUN_DOWNLOAD_LOST_PACK, g_SendSerial++);

	usleep(IM_TIME_BETWEEN_PACKAGE);
	return nRet;
}
#if 0
// 接收到下载的数据
int RecvDownloadData(char *_pcData, int _iLen)
{
	TDownLoadData *ptDownLoadData = (TDownLoadData *)(_pcData + im_pub_DataStartLen);

	if (NULL == ptDownLoadData)
	{
		dbg();
		return ERR;
	}
	if (1 > ptDownLoadData->m_iFileSize)
	{
		dbg();
		return ERR;
	}

	dbgint(ptDownLoadData->m_iSerial);

	if (0 == ptDownLoadData->m_iSerial)
	{
		g_DownloadFileMain.iDownloadSerial = 0;
		g_DownloadFileMain.iDownloadLen = 0;
		g_DownloadFileMain.iDownloadSize = ptDownLoadData->m_iFileSize;

		if (g_DownloadFileMain.iDownloadBuffSize < g_DownloadFileMain.iDownloadSize)
		{
			if (g_DownloadFileMain.pcDownloadData)
			{
				free(g_DownloadFileMain.pcDownloadData);
				g_DownloadFileMain.iDownloadBuffSize = 0;
			}

			g_DownloadFileMain.pcDownloadData = (char *) malloc(g_DownloadFileMain.iDownloadSize);

			if (g_DownloadFileMain.pcDownloadData)
			{
				g_DownloadFileMain.iDownloadBuffSize = g_DownloadFileMain.iDownloadSize;
			}
			else
			{
				dbg();
				return ERR;
			}
		}
		g_DownloadFileMain.iMaxSerial = ptDownLoadData->m_iFileSize / IM_ONE_PACKAGE_SIZE;
		if (g_DownloadFileMain.iMaxSerial * IM_ONE_PACKAGE_SIZE == ptDownLoadData->m_iFileSize)
		{
			g_DownloadFileMain.iMaxSerial--;
		}
		file_waiting_confirm_create(g_DownloadFileMain.iMaxSerial + 1);
	}

	//有问题，重新下载这个文件
	if (g_DownloadFileMain.iDownLoad == 1 && g_DownloadFileMain.iDownloadSize != ptDownLoadData->m_iFileSize)
	{
		dbg();
		//这里应该发送取消下载，不然会出问题
		im_c_CancleDownLoad();
		CallBackDownloadFinish();
		return ERR;
	}

	int iDataLen = _iLen - im_pub_GetFixLen() - sizeof(TDownLoadData);


	if (0 == g_DownloadFileMain.iSvrSendFinsh ||
		ptDownLoadData->m_iSerial < g_DownloadFileMain.iMaxSerial)
	{
		SendNoData(IM_FUN_DOWNLOAD_CONFIRMATION);
	}

	g_DownloadFileMain.iLastRcvTime = time_GetSecSince1970();
	TFileWaitingConfirm *ptFWCData = file_waiting_confirm_get(ptDownLoadData->m_iSerial);
	if (ptFWCData)
	{
		g_DownloadFileMain.iDownloadSerial = ptDownLoadData->m_iSerial + 1;
		memcpy(g_DownloadFileMain.pcDownloadData +
			(ptDownLoadData->m_iSerial * IM_ONE_PACKAGE_SIZE),
			ptDownLoadData->m_pcData, iDataLen);
		g_DownloadFileMain.iDownloadLen += iDataLen;

		dbgint(g_DownloadFileMain.iDownloadLen);

		file_waiting_confirm_remove(ptFWCData);
		//最后一个了，可以开始请求丢的包
		if (g_DownloadFileMain.iMaxSerial == ptDownLoadData->m_iSerial)
		{
			g_DownloadFileMain.iSvrSendFinsh = 1;
			//请求丢包数据
			file_waiting_confirm_traversal(SendLostDownloadPack);
		}
	}
	return OK;
}

int RecvDownloadReData(char *_pcData, int _iLen)
{
	if (g_DownloadFileMain.iDownLoad)
	{
		if (g_DownloadFileMain.iDownloadLen >= g_DownloadFileMain.iDownloadSize)
		{
			// 首先通知服务器，关闭上次下载的文件
			SendNoData(IM_FUN_DOWNLOAD_RE_FINISH);
			CallBackDownloadFinish();
		}
		else
		{
			int *piRet = (int *) (_pcData + im_pub_DataStartLen);
			if (*piRet >= g_DownloadFileMain.iMaxSerial)
			{
				g_DownloadFileMain.iSvrSendFinsh = 1;
			}
			if (g_DownloadFileMain.iSvrSendFinsh == 1)
			{
				if (file_waitng_confirm_is_empty())
				{
					//下载出错了，因为上面已经判断过下载长度和要下载的文件总大小了
					dbg();
					im_c_CancleDownLoad();
					g_DownloadFileMain.iDownloadLen = 0;//置0 ,客户端好判断
					g_DownloadFileMain.iLastRcvTime = 0;
					CallBackDownloadFinish();
				}
				else
				{
					//请求丢包数据
					file_waiting_confirm_traversal(SendLostDownloadPack);
				}
			}
			else
			{
				im_c_ContinueDownLoad();
			}
		}
	}
	else
	{
		SendNoData(IM_FUN_DOWNLOAD_RE_FINISH);
	}
	return OK;
}
#endif
// 接收到返回值
static int RecvReturn(int32_t _iFun, char *_pcData, int32_t _iLen)
{
	TReturnData *ptReturnData = (TReturnData *)(_pcData + im_pub_DataStartLen);
	uint32_t iRetFun = ptReturnData->m_iFun;//不转会越界
	if (NULL == ptReturnData)
	{
		dbg();
		return ERR;
	}

	if (IM_RET_ERR_SERIAL == ptReturnData->m_iRet)
	{
		// 序列号错误，对方校正
		//g_SendSerial = ptReturnData->m_cSerial;

		// 直接返回，不回调
		return OK;
	}
#if 0
	// 下载文件出错，置位,允许下载
	else if (IM_FUN_DOWNLOAD == iRetFun && g_DownloadFileMain.iDownLoad)
	{
		g_DownloadFileMain.iDownLoad = 0;

		// 直接返回，不回调
		//return OK;
	}
	// 续传文件出错，置位,允许下载
	else if (IM_FUN_FILE_GRESS == iRetFun && g_iSendFile)
	{
		g_iSendFile = 0;

		// 直接返回，不回调
		//return OK;
	}
	else if (IM_FUN_FILE_DATA == iRetFun)
	{
		g_iFileSerial = ptReturnData->m_iRet;

		g_iSendStart = 1;
		// 直接返回，不回调
		return OK;
	}
#endif
	return CallBackReturn(_iFun, iRetFun, ptReturnData->m_cSerial, ptReturnData->m_iRet);
}

//接收到添加好友
static int RecvAddFriendForce(int32_t _iFun, char *_pcData, int32_t _iLen)
{
	TAddFriendForeRetData *ptReturnData = (TAddFriendForeRetData *)(_pcData + im_pub_DataStartLen);

	if (NULL == ptReturnData)
	{
		dbg();
		return ERR;
	}
	return CallBackAddFriendForce(_iFun, ptReturnData->llUserId, ptReturnData->iRet, ptReturnData->iAdd);
}

// 接收到推送状态
static int RecvState(char *_pcData, int _iLen)
{
	TStateData *ptStateData = (TStateData *)(_pcData + im_pub_DataStartLen);
	if (NULL == ptStateData)
	{
		dbg();
		return ERR;
	}
	return CallBackState(ptStateData->m_iState, ptStateData->m_iRet, ptStateData->m_iAdditional);
}
#if 0
// 接收到用户回复的文件发送进度
int RecvFileReGress(char *_pcData, int _iLen)
{
	TOneIntData *ptOneData = (TOneIntData *)(_pcData + im_pub_DataStartLen);

	if (NULL == ptOneData)
	{
		dbg();
		return ERR;
	}

	if (g_iSendFile)
	{
		g_iFileSerial = ptOneData->m_iData;
		g_iSendStart = 1;
	}
	else
	{
		im_c_CancleUpLoad();//已经不发送了，取消上传
	}

	return OK;
}

int RecvFileReFinish(uint32_t _iFun, char *_pcData, uint32_t _iLen)
{
	TFileFinishData *ptFileFinishData = (TFileFinishData *)(_pcData + im_pub_DataStartLen);
	if (NULL == ptFileFinishData)
	{
		dbg();
		return ERR;
	}
	return CallBackUpLoadFinish(_iFun, ptFileFinishData->m_uFileName, ptFileFinishData->m_pcUrl);
}
#endif
// 接收到用户列表
static int RecvUserListV2(uint32_t _iFun, char *_pcData, uint32_t _iLen)
{
	TUserListData* ptUserListDataV2 = (TUserListData *)(_pcData + im_pub_DataStartLen);
	if (NULL == ptUserListDataV2)
	{
		dbg();
		return ERR;
	}

	return CallBackUserList(_iFun, ptUserListDataV2->m_iFriendType + IM_USER_FOLLOW, ptUserListDataV2->m_iUserCount,  ptUserListDataV2->m_pllUserList);
}

// 接收到改变好友状态的用户列表

static int RecvChangeFriendType(int _iFun, char *_pcData, int _iLen)
{
	TUserListData* ptUserListData = (TUserListData *)(_pcData + im_pub_DataStartLen);

	if (NULL == ptUserListData)
	{
		dbg();
		return ERR;
	}
	int iClientFriend = (ptUserListData->m_iFriendType == IM_FRIEND_DEL) ? IM_USER_LIST_DEL
		: IM_USER_LIST_BLACK;

	dbgprintf(2, "iClientFriend(type) = %d", iClientFriend);

	return CallBackUserList(_iFun, iClientFriend, ptUserListData->m_iUserCount, ptUserListData->m_pllUserList);
}

static int SendFileData(TClientNetWork *_Connection, uint64_t _llFileName, int32_t _iFileType, int32_t _iFileSerial,
						  const char *_pcData, uint32_t _iLen, int32_t _iFileLen, const char *_pcFileMD5)
{
	char pcSend[2048] = {0};
	if (_iLen + sizeof(TSendFileData) > sizeof(pcSend)) 
	{
		dbg();
		return ERR;
	}

	TSendFileData *ptSendFileData = (TSendFileData *) pcSend;
	if (NULL == ptSendFileData) 
	{
		dbg();
		return ERR;
	}

	ptSendFileData->m_llFileName = _llFileName;
	ptSendFileData->m_iFileType = _iFileType;
	ptSendFileData->m_iSerial = _iFileSerial;
	ptSendFileData->m_iFileLen = _iFileLen;
	memcpy(ptSendFileData->m_pcData, _pcData, _iLen);

	char_ncopy(ptSendFileData->m_pcFileMD5, _pcFileMD5, MD5_LEN);
	return OtherSendMsgV2(_Connection, pcSend, _iLen + sizeof(TSendFileData), IM_FUN_FILE_DATA, _Connection->m_SendSerial++);
}

static void BackgroundLock()
{
	if (IM_C_BG_STATE_YES == g_iBackgroundState) 
	{
		LockMx(m_BackgrounpMux);
		UnLockMx(m_BackgrounpMux);
	}
}

#if RUN_ON_ANDROID

//初始化安卓的函数
static int InitAndroidFun(int _i) 
{
	g_jvm->AttachCurrentThread(&g_jniEnv[_i], NULL);

	if (NULL == g_jClass) 
	{
		dbg();
		return ERR;
	}

	g_jCallback[_i] = g_jniEnv[_i]->GetStaticMethodID(g_jClass, "retCallback", "(I[BI[BI)I");

	if ( g_jCallback[_i] <= 0) 
	{
			dbg();
			return ERR;
	}
	return OK;
}

#endif

void *TskImClientConnect(void *arg) 
{
	while (1) 
	{
		BackgroundLock();

		if (IM_C_STATE_STOP == g_iState) 
		{
			if (g_Connection) 
			{
				net_Close(g_Connection);
				net_Destroy(g_Connection);
				g_Connection = NULL;
			}

			im_c_Connect();
		}

		usleep(1000);
		//TskImClientConnectSleep(0,1000);
	}
	pthread_exit(NULL);
}

void *TskImClient(void *arg) 
{
	func_info();

	int iDataCount = 0;
	int iLen = 0;
	int iRead = 0;
	int iSend = 0;
	int iFun = 0;
	char pcRecv[102400] = {0};
	unsigned char cServerSerial = 0;

#if RUN_ON_ANDROID
	if (ERR == InitAndroidFun(0)) 
	{
		return NULL;
	}
#endif

	while (1) 
	{
		BackgroundLock();
		if (IM_C_STATE_STOP == g_iState /*|| IM_C_BG_STATE_YES == g_iBackgroundState*/) 
		{
			usleep(1000);
			// TskImClientSleep(0,1000);
			continue;
		}
		int iTimeNow = time_GetSecSince1970();

#if IM_HEART_ENABLE
		// IM_HEART_MAX内未收到数据，断开连接
		if (iTimeNow - g_uLastRecvTime > IM_HEART_MAX) 
		{
			dbg();
			CallBackState(IM_STATE_CLOSE, 0, 0);
		}
		// 发送心跳包
		if (iTimeNow - g_uLastSendTime > IM_HEART_SEND) 
		{
			SendHeart();
		}
#endif

		// 接收数据
		iRead = net_Recv(g_Connection, pcRecv, sizeof(pcRecv));
		if (iRead > 0) 
		{
			ringbuf_Write(iRead, pcRecv, g_RingBuf);
		}
		else if (iRead < 0) 
		{
			dbg();
			CallBackState(IM_STATE_CLOSE, 0, 0);
		}

		// 开始处理数据
		iDataCount = ringbuf_DataSize(g_RingBuf);

		CImMsg imMsg;
		PPackHead pHead;
		PPackInfo pHeadInfo;
		if (iDataCount < sizeof(PackHead)) 
		{
			goto ANALY_NEXT;
		}

		iRead = ringbuf_Copy(sizeof(PackHead), pcRecv, g_RingBuf);
		if (sizeof(PackHead) != iRead) 
		{
			dbg();
			goto ANALY_ERR;
		}
		pHead = (PPackHead) pcRecv;
		if (pHead->dataLen <= 0) 
		{
			dbg();
			goto ANALY_ERR;
		}
		iLen = pHead->dataLen + sizeof(PackHead);

		dbgint(iDataCount);
		dbgint(iLen);

		if (iDataCount < iLen) 
		{
			goto ANALY_NEXT;
		}

		iRead = ringbuf_Read(iLen, pcRecv, g_RingBuf);

		if (iLen != iRead) 
		{
			dbg();
			goto ANALY_ERR;
		}
#if IM_HEART_ENABLE
		// 更新最后一次接收时间
		g_uLastRecvTime = time_GetSecSince1970();
#endif
		imMsg.set_full_data(pcRecv, iLen);
		pHeadInfo = (PPackInfo) imMsg.head();
		iLen = imMsg.length();
		memcpy(pcRecv, imMsg.head(), iLen);
		iFun = pHeadInfo->msgHead.iFun;
		cServerSerial = pHeadInfo->msgHead.iSerial;

		if (g_CurrentSerial++ != cServerSerial)// 发送序号校验
		{
			dbg();
			// 回复错误序列号
			//SendErrSerial(iFun);//不用管了，丢的等超时吧
			g_CurrentSerial = cServerSerial + 1;// 校正本地序列号，保证对方发送的连续性
		}
		dbgx(iFun);
		switch (iFun) 
		{
#if IM_HEART_ENABLE
		case IM_FUN_RE_HEART:// 回复心跳包
			break;
#endif
//		case IM_FUN_ADD_FRIEND:		// 添加好友
//		case IM_FUN_RE_ADD_FRIEND:	// 回复添加好友
		case IM_FUN_SEND_USER:		// 接收到其他用户发送的消息
			RecvUserMsg(iFun, pcRecv, iLen);
			break;
		case IM_FUN_SEND_GROUP_MESSAGE:
			RecvGroupMsg(iFun, pcRecv, iLen);
			break;
		case IM_FUN_RE_CONTACT_ADD:	// 手机号校验状态
		case IM_FUN_MINES_RECORD:// 雷的明细
		case IM_FUN_AREA_MINES:
		case IM_FUN_GET_ALBUM_LIST:
		case FUN_GET_FEELING_LIST://获取心情列表
		case FUN_GET_HOT_AREA_LIST://获取热点地区(学校):
		case FUN_GET_SCHOOL_LIST_WITH_ING://获取开通ING学校列表
		case FUN_GET_ING_CONTENT_LIST://获取学校内ING分页列表
		case FUN_GET_ING_COMMENT_LIST://获取ING评论的分页列表
		case FUN_GET_VIDEO_COMMENT_LIST: //获取视频评论的分页列表
		case FUN_GET_FANS_LIST: 	 //获取粉丝列表
		case FUN_GET_FOLLOW_LIST: //获取粉关注列表
		case FUN_GET_USEREVENT_LIST: 	  //获取用户创建的事件列表
		case FUN_GET_EVENT_VIDEO_LIST: 	 //获取事件区域内的视频列表
		case FUN_GET_EVENT_USERVIDEO_LIST: 	   //获取事件内指定用户的视频列表
		case FUN_GET_OTHERS_VIDEO_LIST: 	   //获取他人的视频列表
		case FUN_GET_SENDEVENT_LIST: 	//发送视频前获取当前位置附近的事件列表
		case IM_FUN_GET_GROUPMEMBER_LIST: //获取群组成员列表
		case IM_FUN_GET_MYGROUP_LIST:   //获取群列表
			{
				TOneStringData *ptOneData = (TOneStringData *)(pcRecv + im_pub_DataStartLen);
				CallBackJson(iFun, ptOneData->m_pcData, ptOneData->m_iLen);
				break;
			}					
		case FUN_GET_JSON: 	  //合并JSON回调，用JsonType代替iFun
			{
				TOneJsonData * ptOneJsonData = (TOneJsonData *)(pcRecv + im_pub_DataStartLen);
				uint32_t iJsonType = ptOneJsonData->m_iJsonType;
				
				CallBackJson(iJsonType, ptOneJsonData->m_tOneStringData.m_pcData, ptOneJsonData->m_tOneStringData.m_iLen);
				break;
			}
		case IM_FUN_IS_REGISTER:   // 获取个人详细信息
			RecvSelfInfo(iFun, pcRecv, iLen);
			break;
		case IM_FUN_FRIEND_LIST: // 接收到好友列表信息
			RecvUserListV2(iFun, pcRecv, iLen);
			break;
		case IM_FUN_FIND_USER: // 接收到查询好友列表
			RecvUserInfo(iFun, pcRecv, iLen, 1);
			break;
		case IM_FUN_HD_DEL_FRIEND: // 推送删除好友
			RecvChangeFriendType(iFun, pcRecv, iLen);
			break;
		case IM_FUN_GET_USER_INFO:	// 接收到用户详细信息
			RecvUserInfo(iFun, pcRecv, iLen, 0);
			break;
		case IM_FUN_RETURN:	// 执行结果返回值
			RecvReturn(iFun, pcRecv, iLen);
			break;
		case IM_FUN_ADD_FRIEND:
			RecvAddFriendForce(iFun, pcRecv, iLen);
			break;
#if 0
		case IM_FUN_FILE_RE_GRESS:	// 对方回复接收文件进度
			RecvFileReGress(pcRecv, iLen);
			break;
		case IM_FUN_FILE_RE_FINISH:	// 对方接收文件完成，返回url
			g_iSendFile = 0;
			RecvFileReFinish(iFun, pcRecv, iLen);
			break;
		case IM_FUN_FILE_RE_CANCLE:	// 确认取消上传
			g_iSendFile = 0;
			g_iFileSerial = 0;//如果要续传，那只能从0开始发了
			break;
		case IM_FUN_FILE_FINISH:	// 对方回复发送文件完成
			break;
		case IM_FUN_GET_LIB_MINES:	// 接收到雷库信息
			RecvLibMines(iFun, pcRecv, iLen);
			break;
		case IM_FUN_DOWNLOAD_DATA:	// 接收到文件数据
			RecvDownloadData(pcRecv, iLen);
			if (g_DownloadFileMain.iDownLoad == 1 && g_DownloadFileMain.iDownloadLen >= g_DownloadFileMain.iDownloadSize) 
			{
					SendNoData(IM_FUN_DOWNLOAD_RE_FINISH);// 首先通知服务器，关闭上次下载的文件
					CallBackDownloadFinish();
			}
			break;
		case IM_FUN_DOWNLOAD_RE_GRESS:
			RecvDownloadReData(pcRecv, iLen);
			break;
		case IM_FUN_DOWNLOAD_RE_CANCLE:	// 确认取消下载
			g_DownloadFileMain.iDownLoad = 0;
			break;
		case IM_FUN_FILE_CONFIRMATION:	// 对方确认数据，继续发送数据
			g_iSendStart = 1;
			break;
#endif

		case IM_FUN_STATE:	// 推送信息
			RecvState(pcRecv, iLen);
			break;
		case IM_FUN_PHOTO_RE_GET:	// 个人相册
			RecvJson(IM_FUN_PHOTO_RE_GET, pcRecv, iLen);
			break;
		default:
			dbg();
			dbgx(im_pub_GetFun(pcRecv));
			break;
		}

ANALY_NEXT:
		usleep(1000);
		// TskImClientSleep(0,1000);
		continue;

ANALY_ERR:
		ringbuf_Remove(1, g_RingBuf);
		continue;
	}

	func_exit();

#if RUN_ON_ANDROID
	g_jvm->DetachCurrentThread();
	//DetachCurrentThread();
#endif
	pthread_exit(NULL);
}

#if RUN_TWO_THREAD

// 发送数据
static int OtherSendData(char *_pcSend, int _iCount) 
{
	if (0 == g_Connection2->m_IsConnected) {
		if (OK != net_ConnectByIp(g_Connection2->m_Connection)) {
			dbg();
			return IM_RET_NO_NETWORK;
		}

		g_Connection2->m_IsConnected = 1;
	}

	if (_iCount == net_Send(g_Connection2->m_Connection, _pcSend, _iCount)) {
		return OK;
	}
	else {
		net_Close(g_Connection2->m_Connection);
		g_Connection2->m_IsConnected = 0;

		dbg();
		return IM_RET_NO_NETWORK;
	}
}

static int OtherCloseConnect(TClientNetWork *_Connection) 
{
	dbgprintf(0, "OtherCloseConnect:0x%x", _Connection);
	net_Close(_Connection->m_Connection);
	_Connection->m_iLastEventTime = 0;
	_Connection->m_IsConnected = 0;
	return OK;
}

static int OtherSendDataV2(TClientNetWork *_Connection, char *_pcSend, int _iCount) 
{
	if (0 == _Connection->m_IsConnected) 
	{
		if (OK != net_ConnectByIp(_Connection->m_Connection)) {
			dbg();
			return IM_RET_NO_NETWORK;
		}
		_Connection->m_iLastEventTime = time_GetSecSince1970();
		_Connection->m_IsConnected = 1;
	}

	if (_iCount == net_Send(_Connection->m_Connection, _pcSend, _iCount)) {
		return OK;
	}
	else {
		OtherCloseConnect(_Connection);
		dbg();
		return IM_RET_NO_NETWORK;
	}
}

static int OtherSendMsg(const char *_szBuf, size_t _bufLen, uint32_t _iFun, uint8_t _iSerial, bool bEncoode) 
{
	return OtherSendMsgV2(g_Connection2, _szBuf, _bufLen, _iFun, _iSerial, bEncoode);
}

static int OtherSendMsgV2(TClientNetWork *_Connection, const char *_szBuf, size_t _bufLen, uint32_t _iFun, uint8_t _iSerial, bool bEncoode) 
{
	CImMsg imMsg;
	imMsg.set_data(_szBuf, _bufLen, _iFun, _iSerial, bEncoode ? cmpr_zip_rc4 : cmpr_rc4);
	return OtherSendDataV2(_Connection, (char *) imMsg.head(), imMsg.length());
}

static int OtherSendOneLongLong(TClientNetWork *_Connection, int _iFun, long long _llData) 
{
	TOneLongLongData tOneData;
	tOneData.m_llData = _llData;
	if (OtherSendMsgV2(_Connection, (const char *) &tOneData, sizeof(TOneLongLongData), _iFun, _Connection->m_SendSerial++)) 
	{
		dbg();
		return ERR;
	}
	// 返回发送的序列号
	return _Connection->m_SendSerial - 1;
}

int OtherRecvFileReGress(char *_pcData, int _iLen) 
{
	TOneIntData *ptOneData = (TOneIntData *)(_pcData + im_pub_DataStartLen);

	if (NULL == ptOneData) 
	{
		dbg();
		return ERR;
	}

	if (g_UploadFile2.m_iSendFile) 
	{
		g_UploadFile2.m_iDataLenRecv = ptOneData->m_iData;
	}
	else 
	{
		im_c_OtherCancleUpLoad();
	}

	return OK;
}

int OtherRecvFileUnRecv(char *_pcData, int _iLen) 
{
	TLostSerialPack *ptLostData = (TLostSerialPack *)(_pcData + im_pub_DataStartLen);

	if (NULL == ptLostData) 
	{
		dbg();
		return ERR;
	}
	if (ptLostData->m_iLen <= 0 || NULL == ptLostData->m_ptLostSerials) 
	{
		dbg();
		return ERR;
	}
	if (g_UploadFile2.m_llFileName != ptLostData->m_llFileName || NULL == g_UploadFile2.m_pcData) 
	{
		dbg();
		return ERR;
	}
	int i = 0;
	int32_t iSend = 0;
	dbgint(ptLostData->m_iLen);
	for (; i < ptLostData->m_iLen; i++) 
	{
		iSend = TMIN(IM_ONE_PACKAGE_SIZE, (int32_t)g_UploadFile2.m_iDataLen - (ptLostData->m_ptLostSerials[i] * IM_ONE_PACKAGE_SIZE));

		if (!SendFileData(g_Connection2, g_UploadFile2.m_llFileName, g_UploadFile2.m_iFileType, ptLostData->m_ptLostSerials[i], g_UploadFile2.m_pcData +
			(ptLostData->m_ptLostSerials[i] * IM_ONE_PACKAGE_SIZE), iSend, g_UploadFile2.m_iDataLen, "") ) 
		{
			g_UploadFile2.iLastSendTime = time_GetSecSince1970();
		}
		else 
		{
			OtherCloseConnect(g_Connection2);
			break;
		}
	}
	return OK;
}

static inline int OtherCallBackUpLoadFinish(uint64_t _llFileName, char *_pcFilePath) 
{
	Value jWriteValue;
	jWriteValue["file_name"] = Value((UInt64)_llFileName).asString();
	jWriteValue["file_path"] = _pcFilePath;
	return OtherCallBackFunc(IM_FUN_FILE_RE_FINISH,jWriteValue);
}

int OtherRecvFileReFinish(char *_pcData, int _iLen) 
{
	TFileFinishDataV2* ptFileFinishData = (TFileFinishDataV2 *)(_pcData + im_pub_DataStartLen);

	if (NULL == ptFileFinishData) 
	{
		dbg();
		return ERR;
	}

	if (g_UploadFile2.m_llFileName != ptFileFinishData->m_llFileName) 
	{
		return ERR;
	}
	g_UploadFile2.m_iSendFile = 0;
	g_UploadFile2.iLastSendTime = 0;
	g_UploadFile2.m_iSendStart = 0;
	memset(g_UploadFile2.m_pcMD5, 0, MD5_LEN);
	return OtherCallBackUpLoadFinish(ptFileFinishData->m_llFileName, ptFileFinishData->pcUrl);
}

int OtherRecvFileCancel(char *_pcData, int _iLen) 
{
	TOneLongLongData* ptOneData = (TOneLongLongData *)(_pcData + im_pub_DataStartLen);
	if (NULL == ptOneData) 
	{
		dbg();
		return ERR;
	}

	if (g_UploadFile2.m_llFileName != ptOneData->m_llData) 
	{
		return ERR;
	}

	if (g_UploadFile2.m_iSendFile) 
	{
		OtherCallBackUpLoadFinish(ptOneData->m_llData, (char *) "");//向客户端返回出错
	}

	g_UploadFile2.m_iSendFile = 0;
	g_UploadFile2.iLastSendTime = 0;
	g_UploadFile2.m_iSendStart = 0;
	memset(g_UploadFile2.m_pcMD5, 0, MD5_LEN);

	return OK;
}

int OtherCallBackDownloadFinish() 
{
	g_DownloadFileOther.iDownLoad = 0;
	g_DownloadFileOther.iLastRcvTime = 0;

	Value jWriteValue;
	jWriteValue["download_url"] = g_DownloadFileOther.pcDownLoadUrl;
	return OtherCallBackFunc(IM_FUN_DOWNLOAD_RE_FINISH, jWriteValue, g_DownloadFileOther.pcDownloadData, g_DownloadFileOther.iDownloadLen);
}

// 接收到返回值
static int OtherRecvReturn(int32_t _iFun, char *_pcData, int32_t _iLen)
{
	TReturnData *ptReturnData = (TReturnData *)(_pcData + im_pub_DataStartLen);
	if (NULL == ptReturnData)
	{
		dbg();
		return ERR;
	}

	uint32_t iRetFun = ptReturnData->m_iFun;
	if (IM_RET_ERR_SERIAL == ptReturnData->m_iRet) return OK;
	
	if (IM_FUN_DOWNLOAD == iRetFun && g_DownloadFileOther.iDownLoad)// 下载文件出错，置位,允许下载
	{
		OtherCallBackDownloadFinish();
		return OK;
	}
	Value jWriteValue;
	jWriteValue["fun"] =Value(ptReturnData->m_iFun).asString();
	jWriteValue["serial"] = Value(ptReturnData->m_cSerial).asString();
	jWriteValue["ret"] = Value((Int64)ptReturnData->m_iRet).asString();
	//"{\"fun\":\"xxxx\",\"serial\":\"1\",\"ret\":\"0 成功，-1 失败\"}"
	return OtherCallBackFunc(iRetFun,jWriteValue);
}

static int OtherRecvDownloadData(char *_pcData, int _iLen) 
{
	TDownLoadData *ptDownLoadData = (TDownLoadData *)(_pcData + im_pub_DataStartLen);

	if (NULL == ptDownLoadData) 
	{
		dbg();
		return ERR;
	}
	if (1 > ptDownLoadData->m_iFileSize) 
	{
		dbg();
		return ERR;
	}

	dbgint(ptDownLoadData->m_iSerial);

	if (0 == ptDownLoadData->m_iSerial) 
	{
		g_DownloadFileOther.iDownloadSerial = 0;
		g_DownloadFileOther.iDownloadLen = 0;
		g_DownloadFileOther.iDownloadSize = ptDownLoadData->m_iFileSize;

		if (g_DownloadFileOther.iDownloadBuffSize < g_DownloadFileOther.iDownloadSize) 
		{
			if (g_DownloadFileOther.pcDownloadData) 
			{
				free(g_DownloadFileOther.pcDownloadData);
				g_DownloadFileOther.iDownloadBuffSize = 0;
			}

			g_DownloadFileOther.pcDownloadData = (char *) malloc(g_DownloadFileOther.iDownloadSize);

			if (g_DownloadFileOther.pcDownloadData) 
			{
				g_DownloadFileOther.iDownloadBuffSize = g_DownloadFileOther.iDownloadSize;
			}
			else 
			{
				dbg();
				return ERR;
			}
		}
		g_DownloadFileOther.iMaxSerial = ptDownLoadData->m_iFileSize / IM_ONE_PACKAGE_SIZE;
		if (g_DownloadFileOther.iMaxSerial * IM_ONE_PACKAGE_SIZE == ptDownLoadData->m_iFileSize) 
		{
			g_DownloadFileOther.iMaxSerial--;
		}
		file_waiting_confirm_create(g_DownloadFileOther.iMaxSerial + 1);
	}

	//有问题，重新下载这个文件
	if (g_DownloadFileOther.iDownLoad == 1 && g_DownloadFileOther.iDownloadSize != ptDownLoadData->m_iFileSize) 
	{
			dbg();
			//这里应该发送取消下载，不然会出问题
			im_c_OtherCancleUpLoad();
			OtherCallBackDownloadFinish();
			return ERR;
	}

	int iDataLen = _iLen - im_pub_GetFixLen() - sizeof(TDownLoadData);
	
	if (0 == g_DownloadFileOther.iSvrSendFinsh || ptDownLoadData->m_iSerial < g_DownloadFileOther.iMaxSerial) 
	{
		OtherSendOneLongLong(g_Connection2, IM_FUN_DOWNLOAD_CONFIRMATION, g_DownloadFileOther.llFileName);
	}

	g_DownloadFileOther.iLastRcvTime = time_GetSecSince1970();
	TFileWaitingConfirm *ptFWCData = file_waiting_confirm_get(ptDownLoadData->m_iSerial);
	if (ptFWCData) 
	{
		g_DownloadFileOther.iDownloadSerial = ptDownLoadData->m_iSerial + 1;
		memcpy(g_DownloadFileOther.pcDownloadData + (ptDownLoadData->m_iSerial * IM_ONE_PACKAGE_SIZE), ptDownLoadData->m_pcData, iDataLen);
		g_DownloadFileOther.iDownloadLen += iDataLen;

		dbgint(g_DownloadFileOther.iDownloadLen);

		file_waiting_confirm_remove(ptFWCData);
		//最后一个了，可以开始请求丢的包
		if (g_DownloadFileOther.iMaxSerial == ptDownLoadData->m_iSerial) 
		{
			g_DownloadFileOther.iSvrSendFinsh = 1;
			file_waiting_confirm_traversal(OtherSendLostDownloadPack);//请求丢包数据
		}
	}

	return OK;
}

void OtherSendUploadFinish() 
{
	dbgprintf(0, "OtherSendUploadFinish");
	OtherSendOneLongLong(g_Connection2, IM_FUN_FILE_FINISH, g_UploadFile2.m_llFileName);
	g_UploadFile2.iLastSendTime = time_GetSecSince1970();
	g_Connection2->m_iLastEventTime = time_GetSecSince1970();
	// 发送完成
	g_UploadFile2.m_iSendStart = 0;
}

int OtherRecvDownloadReData(char *_pcData, int _iLen);

void *TskImOther(void *arg) 
{
	func_info();
	int iDataCount = 0;
	int iLen = 0;
	int iRead = 0;
	int32_t iSend = 0;
	int iFun = 0;
	char pcRecv[102400];

#if RUN_ON_ANDROID
	if (ERR == InitAndroidFun(1)) 
	{
		return NULL;
	}
#endif

	while (1) 
	{
		BackgroundLock();

		CImMsg imMsg;
		PPackHead pHead;
		PPackInfo pHeadInfo;
		int iTimeNow = time_GetSecSince1970();

		//if(0 == g_UploadFile2.m_iSendFile && 0 == g_iOtherDownLoad)
		if (0 == g_UploadFile2.m_iSendFile && 0 == g_DownloadFileOther.iDownLoad) 
		{
			goto ANALY_NEXT;
		}

		if (0 == g_Connection2->m_IsConnected) 
		{
			if (OK != net_ConnectByIp(g_Connection2->m_Connection)) 
			{
				goto ANALY_NEXT;
			}
			g_Connection2->m_iLastEventTime = time_GetSecSince1970();
			g_Connection2->m_IsConnected = 1;
		}

		//下载超时处理
		if (g_DownloadFileOther.iDownLoad == 1 && g_DownloadFileOther.iLastRcvTime != 0 && g_DownloadFileOther.iDownloadLen == 0 &&
			iTimeNow - g_DownloadFileOther.iLastRcvTime > IM_TIME_MAX_DOWNLOAD) 
		{
				//首个请求都没成功,重新请求下载
				char pcSend[300] = {0};
				int nLen = 0;
				nLen = strlen(g_DownloadFileOther.pcDownLoadUrl);
				TFileFinishDataV2 *ptTmpData = (TFileFinishDataV2 *) pcSend;
				if (NULL != ptTmpData) 
				{
					ptTmpData->m_llFileName = g_DownloadFileOther.llFileName;
					g_DownloadFileOther.iLastRcvTime = iTimeNow;
					memcpy(ptTmpData->pcUrl, g_DownloadFileOther.pcDownLoadUrl, nLen);
					OtherSendMsgV2(g_Connection2, pcSend, sizeof(TFileFinishDataV2) + nLen + 1, IM_FUN_DOWNLOAD, g_SendSerial++);
				}
				else 
				{
					dbg();
				}
		}

		if (g_UploadFile2.m_iSendFile && g_UploadFile2.iLastSendTime && iTimeNow - g_UploadFile2.iLastSendTime > IM_TIME_MAX_FILE
			&& g_UploadFile2.m_iFileSerial * IM_ONE_PACKAGE_SIZE >= g_UploadFile2.m_iDataLen) //传完并超时
		{
			OtherSendUploadFinish();
		}

		// 是否存在要发送的文件数据
		if (g_UploadFile2.m_iSendFile && g_UploadFile2.m_iSendStart) 
		{
			do {
				iSend = TMIN(IM_ONE_PACKAGE_SIZE, g_UploadFile2.m_iDataLen - (g_UploadFile2.m_iFileSerial * IM_ONE_PACKAGE_SIZE));// 发送长度
				if (iSend > 0) 
				{
					// 发送一包上传数据
					if (!SendFileData(g_Connection2, g_UploadFile2.m_llFileName, g_UploadFile2.m_iFileType, g_UploadFile2.m_iFileSerial,
						g_UploadFile2.m_pcData + (g_UploadFile2.m_iFileSerial * IM_ONE_PACKAGE_SIZE), iSend, g_UploadFile2.m_iDataLen, g_UploadFile2.m_pcMD5)) 
					{
						g_UploadFile2.m_iFileSerial++;
						g_UploadFile2.iLastSendTime = time_GetSecSince1970();
						g_Connection2->m_iLastEventTime = time_GetSecSince1970();
					//	dbgprintf(2, "TskIm_m_iFileSerial = %d", g_UploadFile2.m_iFileSerial);
					}
					else 
					{
						OtherCloseConnect(g_Connection2);
						break;
					}

					if (0 == g_UploadFile2.m_iFileSerial % IM_ONE_TIME_PACKAGE) 
					{
						break;
					}
					usleep(200);
				}
				else 
				{
					OtherSendUploadFinish();
					break;
				}
			} while (1);
		}

		// 接收数据
		iRead = net_Recv(g_Connection2->m_Connection, pcRecv, sizeof(pcRecv));

		dbgint(iRead);

		if (iRead > 0) 
		{
			ringbuf_Write(iRead, pcRecv, g_Connection2->m_RingBuf);
		}
		else if (iRead < 0) 
		{
			net_Close(g_Connection2->m_Connection);
			g_Connection2->m_IsConnected = 0;
			goto ANALY_NEXT;
		}

		// 开始处理数据
		iDataCount = ringbuf_DataSize(g_Connection2->m_RingBuf);

		dbgint(iDataCount);

		if (iDataCount < sizeof(PackHead)) 
		{
			goto ANALY_NEXT;
		}

		iRead = ringbuf_Copy(sizeof(PackHead), pcRecv, g_Connection2->m_RingBuf);
		if (sizeof(PackHead) != iRead) 
		{
			dbg();
			goto ANALY_ERR;
		}
		pHead = (PPackHead) pcRecv;
		if (pHead->dataLen <= 0) 
		{
			dbg();
			goto ANALY_ERR;
		}
		iLen = pHead->dataLen + sizeof(PackHead);

		dbgint(iDataCount);
		dbgint(iLen);

		if (iDataCount < iLen) 
		{
			goto ANALY_NEXT;
		}

		iRead = ringbuf_Read(iLen, pcRecv, g_Connection2->m_RingBuf);

		if (iLen != iRead) 
		{
			dbg();
			goto ANALY_ERR;
		}

		if (!imMsg.set_full_data(pcRecv, iLen))
		{
			dbg();
			goto ANALY_ERR;
		}
		pHeadInfo = (PPackInfo) imMsg.head();
		iLen = imMsg.length();
		memcpy(pcRecv, imMsg.head(), iLen);
		iFun = pHeadInfo->msgHead.iFun;
		dbgx(iFun);
		g_Connection2->m_iLastEventTime = time_GetSecSince1970();

		switch (iFun) 
		{
		case IM_FUN_FILE_RE_DATA:	// 对方请求丢失的包
			OtherRecvFileUnRecv(pcRecv, iLen);
			break;
		case IM_FUN_FILE_RE_GRESS:	// 对方回复接收文件进度
			OtherRecvFileReGress(pcRecv, iLen);
			break;
		case IM_FUN_FILE_RE_FINISH:	// 对方接收文件完成，返回url
			OtherRecvFileReFinish(pcRecv, iLen);
			break;
		case IM_FUN_FILE_RE_CANCLE:	// 确认取消上传
			OtherRecvFileCancel(pcRecv, iLen);
			break;
		case IM_FUN_FILE_FINISH:	// 对方回复发送文件完成
			break;
		case IM_FUN_DOWNLOAD_DATA:	// 接收到文件数据
			OtherRecvDownloadData(pcRecv, iLen);
			if (g_DownloadFileOther.iDownLoad == 1 && g_DownloadFileOther.iDownloadLen >= g_DownloadFileOther.iDownloadSize) 
			{
				OtherSendOneLongLong(g_Connection2, IM_FUN_DOWNLOAD_RE_FINISH, g_DownloadFileOther.llFileName);// 首先通知服务器，关闭上次下载的文件
				OtherCallBackDownloadFinish();
			}
			break;
		case IM_FUN_DOWNLOAD_RE_GRESS:
			OtherRecvDownloadReData(pcRecv, iLen);
			break;
		case IM_FUN_DOWNLOAD_RE_CANCLE:	// 确认取消下载
			g_DownloadFileOther.iDownLoad = 0;
			break;
		case IM_FUN_FILE_CONFIRMATION:	// 对方确认数据，继续发送数据
			g_UploadFile2.m_iSendStart = 1;
			break;
		case IM_FUN_RETURN:
			OtherRecvReturn(iFun, pcRecv, iLen);
			break;
		default:
			dbg();
			dbgx(im_pub_GetFun(pcRecv));
			break;
		}

ANALY_NEXT:
		if (g_Connection2->m_IsConnected && (iTimeNow - g_Connection2->m_iLastEventTime > IM_TIME_FILE_TIMEOUT)) 
		{
				OtherCloseConnect(g_Connection2);
		}
		usleep(1000);
		continue;
ANALY_ERR:
		ringbuf_Remove(1, g_Connection2->m_RingBuf);
		continue;
	}

	func_exit();

#if RUN_ON_ANDROID
	g_jvm->DetachCurrentThread();
#endif

	pthread_exit(NULL);
}

#endif

#if IM_CLUSTER_ENABLE

//客户端连接的端口
static TServerInfo g_LoginSvrInfo;
//文件服务器
static TServerInfo g_FileSvrInfo;

// 发送数据
static int ClientSendData(void *_ptNetWork, char *_pcSend, int _iCount) 
{
	TNetWork *ptNetWork = (TNetWork *) _ptNetWork;
	if (_iCount == net_Send(ptNetWork, _pcSend, _iCount)) 
	{
		return OK;
	}
	else 
	{
		CallBackState(IM_STATE_CLOSE, 0, 0);
		dbg();
		return IM_RET_NO_NETWORK;
	}
}

//收数据
static int im_client_Wait(void *_ptNetWork, char *_pcData, int _iMaxLen) 
{
	int iIndex = 0;
	int iRecv = 0;
	int iLen = 0;

	TNetWork *ptNetWork = (TNetWork *) _ptNetWork;

	if (NULL == ptNetWork) 
	{
		dbg();
		return ERR;
	}

	int iCount = 50;

	while (iCount-- > 0) 
	{
		iRecv = net_Recv(ptNetWork, _pcData + iIndex, _iMaxLen - iIndex);

		if (iRecv < 0) 
		{
			break;
		}
		iIndex += iRecv;
		if (iIndex >= sizeof(PackHead)) 
		{
			PPackHead packHead = (PPackHead) _pcData;
			if (iIndex >= packHead->dataLen + sizeof(PackHead)) 
			{
				CImMsg imMsg;
				if (!imMsg.set_full_data(_pcData, packHead->dataLen + sizeof(PackHead))) 
				{
					dbg();
					return ERR;
				}
				memcpy(_pcData, imMsg.head(), imMsg.length());
				iIndex = iLen = imMsg.length();
				break;
			}
		}

		usleep(1000 * 100);
	}

	if (iLen > 0 && iIndex >= iLen) 
	{
		return iIndex;
	}
	else 
	{
		return ERR;
	}
}

static int im_client_GetLnkSvrInfo(void *_ptNetWork, char *_pcHost, int *_piPort) 
{
	CImMsg imMsg;
	imMsg.set_data(NULL, 0, IM_LOGIN_SVR_GET_LNK_SVR);
	int iRet = ClientSendData(_ptNetWork, imMsg.head(), imMsg.length());

	if (iRet != OK) 
	{
		dbg();
		return iRet;
	}

	char pcData[256] = {0};

	int iLen = im_client_Wait(_ptNetWork, pcData, sizeof(pcData));

	if (iLen <= 0) 
	{
		dbg();
		return ERR;
	}
	PPackInfo packInfo = (PPackInfo) pcData;
	if (IM_LOGIN_SVR_GET_LNK_SVR != packInfo->msgHead.iFun) 
	{
		dbg();
		return ERR;
	}

	TLnkSvrInfo *ptLnkSvr = (TLnkSvrInfo *) (pcData + PACK_INFO_LEN);

	if (NULL == ptLnkSvr) {
		dbg();
		return ERR;
	}

	if (_piPort) *_piPort = ptLnkSvr->m_iPort;
	if (_pcHost) char_ncopy(_pcHost, ptLnkSvr->m_pcHost, IM_IP_LEN);
	return OK;
}

/** @brief 通过登录服务器得到连接服务器
* @param[in] _pcInLoginHost 登录服务器IP
* @param[in] _piInLoginPort 登录服务器端口
* @param[out] _pcOutLnkSvrHost 连接服务器IP
* @param[out] _piOutLnkSvrPort 连接服务器端口
*/
static int im_client_GetLnkSvrInfo2(char *_pcInLoginHost, int _iInLoginPort, char *_pcOutLnkSvrHost, int *_piOutLnkSvrPort)
{
	char pcHost[IM_IP_LEN] = {0};
	TNetWork *ptLogin = net_CreateByIp(NET_TYPE_TCP, _pcInLoginHost, _iInLoginPort);
	if (NULL == ptLogin) {
		dbg();
		return ERR;
	}

	int iRetLogin = net_ConnectByIp(ptLogin);
	if (ERR == iRetLogin)
	{
		dbg();
		goto EXIT;
	}

	int _iPort;
	iRetLogin = im_client_GetLnkSvrInfo(ptLogin, pcHost, &_iPort);
	if (ERR == iRetLogin)
	{
		dbg();
		goto EXIT;
	}
	net_Close(ptLogin);
	net_Destroy(ptLogin);
	char_ncopy(_pcOutLnkSvrHost, pcHost, sizeof(pcHost));
	*_piOutLnkSvrPort = _iPort;
	return OK;

EXIT:
	if (ptLogin)
	{
		net_Close(ptLogin);
		net_Destroy(ptLogin);
	}

	return ERR;
}

static int im_client_InitConnect(char *_pcInLoginHost, int _iInLoginPort) 
{
	char pcLnkSvrHost[IM_IP_LEN] = {0};
	int iLnkSvrPort = 0;

	if (NULL == g_Connection) 
	{
		int iRet = im_client_GetLnkSvrInfo2(_pcInLoginHost, _iInLoginPort,
			pcLnkSvrHost, &iLnkSvrPort);

		if (OK != iRet || 0 == iLnkSvrPort) 
		{
			dbg();
			return ERR;
		}
		g_Connection = net_CreateByIp(NET_TYPE_TCP, pcLnkSvrHost, iLnkSvrPort);

		if (NULL == g_Connection) 
		{
			dbg();
			return ERR;
		}
	}

	return OK;
}

#endif

#if RUN_ON_ANDROID

int im_c_Load(JavaVM *_JavaVM) 
{
	g_jvm = _JavaVM;

	if (NULL == g_jvm) {
		dbg();
		return ERR;
	}

	return OK;
}

int im_c_Init(JNIEnv *_jniEnv, char *_pcIp, int _iPort, char *_pcFileSvrIp, int _iFileSvrPort)
#else
int im_c_Init(char *_pcIp, int _iPort, char *_pcFileSvrIp, int _iFileSvrPort, FImCallback _ptCallbackFunc)
#endif
{
	if (g_Connection)  return OK;
	srand(time_GetSecSince1970());

#if RUN_ON_ANDROID
	
	if (NULL == g_jvm) // 必须首先load，然后在init
	{
		return ERR;
	}
	// 已经初始化过，不用重复初始化
	if (g_jClass) 
	{
		return OK;
	}
	jclass temp = _jniEnv->FindClass(JNI_CLASS_NAME);
	g_jClass = (jclass) _jniEnv->NewGlobalRef(temp);

	_jniEnv->DeleteLocalRef(temp);
	if (NULL == g_jClass)  return ERR;

#else
	if(NULL == _ptCallbackFunc) return ERR;
	g_ptCallbackFun = _ptCallbackFunc;// 接收到数据的回调函数

#endif

#if IM_CLUSTER_ENABLE
	char_ncopy(g_LoginSvrInfo.m_pcHost, _pcIp, IM_IP_LEN);
	g_LoginSvrInfo.m_iPort = _iPort;

#endif

	char_ncopy(g_FileSvrInfo.m_pcHost, _pcFileSvrIp, IM_IP_LEN);
	g_FileSvrInfo.m_iPort = _iFileSvrPort;

	Lock_Init(m_BackgrounpMux);

#if (0 == IM_CLUSTER_ENABLE)
	if(NULL == g_Connection) g_Connection = net_CreateByIp(NET_TYPE_TCP, _pcIp, _iPort);

	if(NULL == g_Connection) return ERR;
#endif
	// 解析数据用的
	if (NULL == g_RingBuf) 
	{
		g_RingBuf = ringbuf_Create(1024 * 1024, RINGBUF_WRITE_COVER);
	}

	if (NULL == g_RingBuf)  return ERR;

	// 创建服务线程
	if (g_iThreadCreateRet) 
	{
		pthread_t pth_ClientService;
		g_iThreadCreateRet = pthread_create(&pth_ClientService, NULL, TskImClient, (void *) (NULL));
		if (g_iThreadCreateRet) 
		{
			dbg();
			return ERR;
		}
		pthread_detach(pth_ClientService);
	}

	// 创建服务线程
	if (g_iThreadImConnectRet) 
	{
		pthread_t pth_ClientConnect;
		g_iThreadImConnectRet = pthread_create(&pth_ClientConnect, NULL, TskImClientConnect, (void *) (NULL));
		if (g_iThreadImConnectRet) 
		{
			dbg();
			return ERR;
		}
		pthread_detach(pth_ClientConnect);
	}
	memset(&g_DownloadFileMain, 0, sizeof(TClientDownloadFile));
	memset(&g_DownloadFileOther, 0, sizeof(TClientDownloadFile));

#if RUN_TWO_THREAD

	if (NULL == g_Connection2) 
	{
		g_Connection2 = (TClientNetWork *) malloc(sizeof(TClientNetWork));
		if (NULL == g_Connection2) 
		{
			dbg();
			return ERR;
		}
		memset(g_Connection2, 0, sizeof(TClientNetWork));
		g_Connection2->m_iThreadCreateRet = ERR;
	}
	if (NULL == g_Connection2) 
	{
		dbg();
		return ERR;
	}

	if (NULL == g_Connection2->m_Connection) 
	{
		g_Connection2->m_Connection = net_CreateByIp(NET_TYPE_TCP, g_FileSvrInfo.m_pcHost, g_FileSvrInfo.m_iPort);
	}

	if (NULL == g_Connection2->m_Connection) 
	{
		dbg();
		return ERR;
	}

	// 解析数据用的
	if (NULL == g_Connection2->m_RingBuf) 
	{
		g_Connection2->m_RingBuf = ringbuf_Create(1024 * 1024, RINGBUF_WRITE_COVER);
	}

	if (NULL == g_Connection2->m_RingBuf) 
	{
		dbg();
		return ERR;
	}
	// 创建服务线程
	if (g_Connection2->m_iThreadCreateRet) 
	{
		pthread_t pth_ClientOther;
		g_Connection2->m_iThreadCreateRet = pthread_create(&pth_ClientOther, NULL, TskImOther, (void *) (NULL));
		if (g_Connection2->m_iThreadCreateRet) 
		{
			dbg();
			return ERR;
		}
		pthread_detach(pth_ClientOther);
	}

	memset(&g_UploadFile2, 0, sizeof(TClientUploadFile));
#endif

//	InitMsgFilter();//消息过滤用，防止客户端多次收到相同消息
	return OK;
}

int im_c_Connect() 
{
#if IM_CLUSTER_ENABLE
	int iLoginRet = im_client_InitConnect(g_LoginSvrInfo.m_pcHost,
		g_LoginSvrInfo.m_iPort);
	if (OK != iLoginRet) return ERR;
	if (NULL == g_Connection) return ERR;
#endif

	im_c_DisConnect();

	int iRet = net_ConnectByIp(g_Connection);

	if (OK == iRet) 
	{
		g_CurrentSerial = 0;
		g_SendSerial = 0;
		g_iState = IM_C_STATE_RUNING;

#if IM_HEART_ENABLE
		g_uLastRecvTime = time_GetSecSince1970();
		g_uLastSendTime = g_uLastRecvTime;
#endif
	}
	else 
	{
		net_Close(g_Connection);
		net_Destroy(g_Connection);
		g_Connection = NULL;
	}

	return iRet;
}

int im_c_IsConnected() 
{
	if (IM_C_STATE_STOP == g_iState) 
	{
		return ERR;
	}
	return net_IsConnected(g_Connection);
}

int im_c_DisConnect() 
{
	g_iState = IM_C_STATE_STOP;
	return net_Close(g_Connection);
}

int im_c_Register(uint16_t _iArea, uint64_t _llUser, char *_pcPsw, char *_pcVerCode, char *_pcDeviceKey, char *_pcOSType, char *_pcOSVer, char *_pcPhoneType)
{
	if (IM_C_STATE_STOP == g_iState || NULL == _pcPsw || NULL == _pcVerCode || NULL == _pcDeviceKey || NULL == _pcOSType || NULL == _pcOSVer || NULL == _pcPhoneType) 
	{
		return ERR;
	}
	char pcSend[512] = {0};
	TRegisterDataV2 *ptRegisterData = (TRegisterDataV2 *) pcSend;

	if (NULL == ptRegisterData) return ERR;
	ptRegisterData->iArea = _iArea;
	ptRegisterData->llUserId = _llUser;
	char_ncopy(ptRegisterData->pcPsw, _pcPsw, IM_PASSWORD_LEN);
	char_ncopy(ptRegisterData->pcVerCode, _pcVerCode, IM_VER_CODE_LEN);
	char_ncopy(ptRegisterData->phoneInfo.m_pcDeviceKey, _pcDeviceKey, SC_DEVICE_KEY_LEN);
	char_ncopy(ptRegisterData->phoneInfo.m_pcPhoneType, _pcPhoneType, SC_DEVICE_KEY_LEN);
	char_ncopy(ptRegisterData->phoneInfo.m_pcOSType, _pcOSType, SC_DEVICE_KEY_LEN);
	char_ncopy(ptRegisterData->phoneInfo.m_pcOSVer, _pcOSVer, SC_DEVICE_KEY_LEN);
	return c_SendMsg(pcSend, sizeof(TRegisterDataV2), IM_FUN_REGISTER, g_SendSerial++);
}

int im_c_Login(uint16_t _iArea, uint64_t _llUser, char *_pcPsw, uint32_t _llLastTime) 
{
	if (IM_C_STATE_STOP == g_iState || NULL == _pcPsw)  return ERR;
	char pcSend[128];
	TLoginData *ptLoginData = (TLoginData *) pcSend;
	if (NULL == ptLoginData) return ERR;
	ptLoginData->iArea = _iArea;
	ptLoginData->llUserId = _llUser;
	char_ncopy(ptLoginData->pcPsw, _pcPsw, 16);
	ptLoginData->iLastTime = _llLastTime;
	return c_SendMsg(pcSend, sizeof(TLoginData), IM_FUN_LOGIN, g_SendSerial++);
}

int im_c_Logout() 
{
	return SendNoData(IM_FUN_LOGOUT);
}

int im_c_UpdateToken(char *_pcToken) 
{
	if (NULL == _pcToken) 
	{
		dbg();
		return ERR;
	}

	return SendOneString(IM_FUN_UPDATE_TOKEN, _pcToken, strlen(_pcToken));
}

int im_c_UpdateUserInfo(int32_t _iType, char *_pcData)
{
	if (NULL == _pcData)
	{
		dbg();
		return ERR;
	}
	int iDataLen = char_len(_pcData);
	if (0 == iDataLen)
	{
		dbg();
		return ERR;
	}

	char pcSend[1024] = {0};
	TUpdateUserInfoData *ptUserData = (TUpdateUserInfoData *) pcSend;

	if (NULL == ptUserData) return ERR;
	ptUserData->m_iType = _iType;
	ptUserData->m_ptData.m_iLen = iDataLen;
	char_ncopy(ptUserData->m_ptData.m_pcData, _pcData, iDataLen + 1);
	return c_SendMsg(pcSend, sizeof(TUpdateUserInfoData) + iDataLen, IM_FUN_UPDATE_INFO, g_SendSerial++);
}

int im_c_UpdateRelationid(long long _llRelationUser) 
{
	return SendOneLongLong(IM_FUN_UPDATE_RELATION_ID, _llRelationUser);
}

int im_c_ResetPassWd(uint16_t _iArea, uint64_t _llUser, char *_pcPsw, char *_pcCode) 
{
	if (NULL == _pcPsw || NULL == _pcCode)  return ERR;
	TResetPassWdData tResetData;
	tResetData.iArea = _iArea;
	tResetData.llUserId = _llUser;
	char_ncopy(tResetData.m_pcPsw, _pcPsw, IM_PASSWORD_LEN);
	char_ncopy(tResetData.m_pcCode, _pcCode, 6);
	return c_SendMsg((const char*)&tResetData, sizeof(TResetPassWdData), IM_FUN_RESET_PASSWD, g_SendSerial++);
}

int im_c_ResetPswCheckCode(uint16_t _iArea, uint64_t _llUser, char *_pcCode)
{
	if (NULL == _pcCode)  return ERR;
	TResetPassWdData tResetData;
	tResetData.iArea = _iArea;
	tResetData.llUserId = _llUser;
	char_ncopy(tResetData.m_pcCode, _pcCode, 6);
	return c_SendMsg((const char*)&tResetData, sizeof(TResetPassWdData), IM_FUN_RESET_PSW_CHECK, g_SendSerial++);
}

int im_c_Is_Register_SC(char *_pcDeviceKey) 
{
	if (IM_C_STATE_STOP == g_iState || NULL == _pcDeviceKey) return ERR;

	char pcSend[128] = {0};
	TOneStringData *ptData = (TOneStringData *) pcSend;

	if (NULL == ptData) return ERR;
	ptData->m_iLen = char_len(_pcDeviceKey);
	char_ncopy(ptData->m_pcData, _pcDeviceKey, ptData->m_iLen + 1);
	return c_SendMsg(pcSend, sizeof(TOneStringData) + ptData->m_iLen + 1, IM_FUN_IS_REGISTER, g_SendSerial++);
}

// 查看好友的详细信息
int im_c_GetUserInfo(uint16_t _iArea, uint64_t _llUser) 
{
	return SendOneLongLong(IM_FUN_GET_USER_INFO, FullPhone(_iArea,_llUser));
}

int im_c_GetFriendList(int _iFriendType) 
{
	//return SendNoData(IM_FUN_FRIEND_LIST);
	return SendOneInt(IM_FUN_FRIEND_LIST, _iFriendType);
}

uint32_t im_c_GetIndex() 
{
	return im_p_GetIndex();
}

uint64_t im_c_GetIndexLongLong() 
{
	return im_p_GetIndexLongLong();
}

int im_c_SendUser(int64_t _iIndex, uint16_t _iSrcArea, uint64_t _llSrcUser, uint16_t _iDstArea, uint64_t _llDstUser, int16_t _iDataType, char *_pcData, uint32_t _iDataLen, int16_t _iAdditional)
{
	if (NULL == _pcData || 0 == _iDataLen) return ERR;

	int32_t iDType = (_iAdditional << 16) | _iDataType;

	std::vector<char> vcData(sizeof(TSendUserData) + _iDataLen + 1);
	TSendUserData *ptSendUserData = (TSendUserData *)&*vcData.begin();
	if (NULL == ptSendUserData) return ERR;

	ptSendUserData->m_iIndex = _iIndex;
	ptSendUserData->m_llSrcUserId = FullPhone(_iSrcArea,_llSrcUser);
	ptSendUserData->m_llDstUserId = FullPhone(_iDstArea,_llDstUser);
	ptSendUserData->m_uTime = time_GetSecSince1970();
	ptSendUserData->m_iType = iDType;
	ptSendUserData->m_iLen = _iDataLen;
	char_ncopy(ptSendUserData->m_pcData, _pcData, _iDataLen + 1);

	if (OK != c_SendMsg((const char*)&*vcData.begin(), vcData.size(), IM_FUN_SEND_USER, g_SendSerial++))
	{
		return ERR;
	}
	
#if 0
	CImMsg imMsg;
	imMsg.set_data((const char*)&*vcData.begin(), vcData.size(), IM_FUN_SEND_USER, g_SendSerial++);

	const uint32_t iMaxSendOnce = 1024;
	uint32_t iOffset = 0;
	uint32_t iSend = imMsg.length() > iMaxSendOnce ? iMaxSendOnce : imMsg.length();
	while (iOffset < imMsg.length()) 
	{
		if (c_SendData(imMsg.head() + iOffset, iSend) == ERR) return ERR;

		iOffset += iSend;
		iSend = imMsg.length() - iOffset > iMaxSendOnce ? iMaxSendOnce : imMsg.length() - iOffset;
		usleep(200);
	}
#endif
	// 返回发送的序列号
	return g_SendSerial - 1;
}

int im_c_Find(long long _llUser, char *_pcNickName) 
{
	char pcSend[256];
	TFindData *ptFindData = (TFindData *) pcSend;

	if (NULL == ptFindData) return ERR;
	ptFindData->m_ptFindInfo.m_iGlobalInt = 0;
	if (_llUser > 0) 
	{
		ptFindData->m_ptFindInfo.m_ptGlobalStruct.m_bFindId = 1;
		ptFindData->m_llUserId = _llUser;
	}
	if (_pcNickName && strlen(_pcNickName) > 0) {
		ptFindData->m_ptFindInfo.m_ptGlobalStruct.m_bFindName = 1;
		char_ncopy(ptFindData->m_pcNickName, _pcNickName, IM_NICKNAME_LEN);
	}
	if (0 == ptFindData->m_ptFindInfo.m_iGlobalInt) 
	{
		dbg();
		return ERR;
	}
	return c_SendMsg(pcSend, sizeof(TFindData), IM_FUN_FIND_USER, g_SendSerial++);
}

int im_c_MsgCheckState(int64_t _iIndex, uint16_t _iArea, uint64_t _llUser, char *_pcData, uint32_t _iDataLen) 
{
	return im_c_SendUser(_iIndex, 0, 0, _iArea, _llUser, IM_DATA_TYPE_MSG_CHECK_STATE, _pcData, _iDataLen,0);
}

int im_c_AddFriend(int64_t _iIndex, uint16_t _iArea, uint64_t _llUser, char *_pcData, uint32_t _iDataLen) 
{
	return im_c_SendUser(_iIndex, 0, 0, _iArea, _llUser, IM_DATA_TYPE_ADDFRIEND, _pcData, _iDataLen, 0);
}

int im_c_AddFriend_Force(uint16_t _iArea, uint64_t _llUser) 
{
	return SendOneLongLong(IM_FUN_ADD_FRIEND, FullPhone(_iArea,_llUser));
}

int im_c_ReAddFriend(int64_t _iIndex, uint16_t _iArea, uint64_t _llUser, uint32_t _iState) 
{
	//string strMsg = StrFormatA("%" PRIu32,_iState);
	char szSend[15] = {0};
	snprintf(szSend,sizeof(szSend),"%" PRIu32,_iState);
	return im_c_SendUser(_iIndex, 0, 0, _iArea, _llUser, IM_DATA_TYPE_RE_ADDFRIEND, (char*)szSend, strlen(szSend), 0);
}

int im_c_DelFriend(uint16_t _iArea, uint64_t _llUser) 
{
	return SendOneLongLong(IM_FUN_DEL_FRIEND, FullPhone(_iArea,_llUser));
}

#if 0

int im_c_UpLoad(int _uFileName, int _iFileType, char *_pcData, int _iDataLen) 
{
	// 正在发送数据
	if (g_iSendFile) 
	{
		dbg();
		return ERR;
	}

	if (_iDataLen > g_iDataSize) 
	{
		if (g_pcData) 
		{
			free(g_pcData);
			g_pcData = NULL;

			g_iDataSize = 0;
		}

		g_pcData = (char *) malloc(_iDataLen);

		dbgx(g_pcData);

		if (NULL == g_pcData) 
		{
			dbg();
			return ERR;
		}

		g_iDataSize = _iDataLen;
	}

	g_iDataLen = _iDataLen;
	memcpy(g_pcData, _pcData, g_iDataLen);

	g_iFileSerial = 0;
	g_uFileName = _uFileName;
	g_iFileType = _iFileType;
	g_iSendFile = 1;
	g_iSendStart = 1;

	return OK;
}

int im_c_CancleUpLoad() 
{
	// 通知服务器
	return SendNoData(IM_FUN_FILE_CANCLE);
}

int im_c_GetUpLoadProgress() 
{
	if (0 == g_iDataLen) 
	{
		return 0;
	}
	else 
	{
		return ((float) (g_iFileSerial * g_iFilePacket) / (float) g_iDataLen) * 100;
	}
}

int im_c_ContinueUpLoad() 
{
	g_iSendFile = 1;

	// 从服务器请求上传进度
	return SendNoData(IM_FUN_FILE_GRESS);
}

int im_c_ContinueDownLoad() 
{
	return SendOneInt(IM_FUN_DOWNLOAD_RE_GRESS, g_DownloadFileMain.iDownloadSerial);
}

int im_c_CancleDownLoad() 
{
	// 通知服务器
	g_DownloadFileMain.iDownLoad = 0;
	return SendNoData(IM_FUN_DOWNLOAD_CANCLE);
}

int im_c_GetDownLoadProgress() 
{
	if (0 == g_DownloadFileMain.iDownloadSize) 
	{
		return 0;
	}
	else {
		return ((float) g_DownloadFileMain.iDownloadLen / (float) g_DownloadFileMain.iDownloadSize) * 100;
	}
}

int im_c_DownLoad(char *_pcUrl) 
{
	if (g_DownloadFileMain.iDownLoad) 
	{
		dbg();
		return -2;//返回客户端现在正在下载
	}

	//if(NULL == _pcUrl)
	if (char_len(_pcUrl) < 5) //后缀加名字，至少5个
	{
		dbg();
		return ERR;
	}

	g_DownloadFileMain.iDownLoad = 1;
	g_DownloadFileMain.iDownloadLen = 0;
	g_DownloadFileMain.iDownloadSerial = 0;
	g_DownloadFileMain.iSvrSendFinsh = 0;
	g_DownloadFileMain.iMaxSerial = 0;

	char_ncopy(g_DownloadFileMain.pcDownLoadUrl, _pcUrl, sizeof(g_DownloadFileMain.pcDownLoadUrl));
	g_DownloadFileMain.iLastRcvTime = time_GetSecSince1970();

	return SendOneString(IM_FUN_DOWNLOAD, g_DownloadFileMain.pcDownLoadUrl,
		strlen(g_DownloadFileMain.pcDownLoadUrl));
	//return SendOneString(IM_FUN_DOWNLOAD, _pcUrl, strlen(_pcUrl));
}
#endif

#if RUN_TWO_THREAD

int im_c_OtherUpLoad(uint64_t _llFileName, int32_t _iFileType, char *_pcData, uint32_t _iDataLen) 
{
	if (NULL == _pcData || _iDataLen < 1) 
	{
		dbg();
		return ERR;
	}

	// 正在发送数据
	if (g_UploadFile2.m_iSendFile) 
	{
		dbg();
		return ERR;
	}
	g_UploadFile2.m_iFileSerial = 0;
	if (_iDataLen > g_UploadFile2.m_iDataMemSize) 
	{
		if (g_UploadFile2.m_pcData) {
			free(g_UploadFile2.m_pcData);
			g_UploadFile2.m_pcData = NULL;

			g_UploadFile2.m_iDataMemSize = 0;
		}

		g_UploadFile2.m_pcData = (char *) malloc(_iDataLen);
		if (NULL == g_UploadFile2.m_pcData) {
			dbg();
			return ERR;
		}

		g_UploadFile2.m_iDataMemSize = _iDataLen;
	}

	if (NULL == g_UploadFile2.m_pcData) 
	{
		dbg();
		return ERR;
	}

	g_UploadFile2.m_iDataLen = _iDataLen;
	memcpy(g_UploadFile2.m_pcData, _pcData, g_UploadFile2.m_iDataLen);

	memset(g_UploadFile2.m_pcMD5, 0, MD5_LEN);
	//im_p_MD5(g_UploadFile2.m_pcMD5, _pcData, _iDataLen);

	g_UploadFile2.m_iFileSerial = 0;
	g_UploadFile2.m_llFileName = _llFileName;
	g_UploadFile2.m_iFileType = _iFileType;
	g_UploadFile2.m_iSendFile = 1;
	g_UploadFile2.m_iSendStart = 1;
	g_UploadFile2.m_iDataLenRecv = 0;
	g_UploadFile2.iLastSendTime = time_GetSecSince1970();
	return OK;
}

int im_c_OtherCancleUpLoad() 
{
	// 通知服务器
	return OtherSendOneLongLong(g_Connection2, IM_FUN_FILE_CANCLE, g_UploadFile2.m_llFileName);
}

int im_c_OtherGetUpLoadProgress() 
{
	if (0 == g_UploadFile2.m_iDataLen) 
	{
		return 0;
	}
	else 
	{
		dbgprintf(2, "m_iFileSerial = %d", g_UploadFile2.m_iDataLenRecv);
		return ((float) g_UploadFile2.m_iDataLenRecv / (float) g_UploadFile2.m_iDataLen) * 100;
	}
}

int im_c_OtherContinueUpLoad() 
{
	return ERR;
}

int im_c_OtherContinueDownLoad() 
{
	char pcSend[sizeof(TDownLoadContinue)];
	TDownLoadContinue *ptDownLoadData = (TDownLoadContinue *) pcSend;

	if (NULL == ptDownLoadData) return ERR;
	ptDownLoadData->m_llFileName = g_DownloadFileOther.llFileName;
	ptDownLoadData->m_nDownLoadSerial = g_DownloadFileOther.iDownloadSerial;
	g_DownloadFileOther.iDownLoad = 1;
	return OtherSendMsgV2(g_Connection2, pcSend, sizeof(TDownLoadContinue), IM_FUN_DOWNLOAD_RE_GRESS, g_SendSerial++);
}

int im_c_OtherCancleDownLoad() 
{
	if (0 == g_DownloadFileOther.iDownLoad) return ERR;

	return OtherSendOneLongLong(g_Connection2, IM_FUN_DOWNLOAD_CANCLE, g_DownloadFileOther.llFileName);
}

int im_c_OtherGetDownLoadProgress() 
{
	if (0 == g_DownloadFileOther.iDownloadSize) 
	{
		return 0;
	}
	else 
	{
		return ((float) g_DownloadFileOther.iDownloadLen / (float) g_DownloadFileOther.iDownloadSize) * 100;
	}
}

int im_c_OtherDownLoad(char *_pcUrl)
{
	if (g_DownloadFileOther.iDownLoad) return -2;//返回客户端现在正在下载
	//后缀加名字，至少5个
	if (char_len(_pcUrl) < 5) return ERR;

	char pcSend[300] = {0};
	int nLen = 0;
	nLen = strlen(_pcUrl);

	if (nLen + sizeof(TFileFinishDataV2) > sizeof(pcSend)) return ERR;
	TFileFinishDataV2 *ptTmpData = (TFileFinishDataV2 *) pcSend;

	if (NULL == ptTmpData) return ERR;
	ptTmpData->m_llFileName = im_c_GetIndexLongLong();
	memcpy(ptTmpData->pcUrl, _pcUrl, nLen);
	g_DownloadFileOther.iDownLoad = 1;
	g_DownloadFileOther.iDownloadLen = 0;
	g_DownloadFileOther.iDownloadSerial = 0;
	g_DownloadFileOther.iSvrSendFinsh = 0;
	g_DownloadFileOther.iMaxSerial = 0;
	g_DownloadFileOther.llFileName = ptTmpData->m_llFileName;
	char_ncopy(g_DownloadFileOther.pcDownLoadUrl, _pcUrl,
		sizeof(g_DownloadFileOther.pcDownLoadUrl));
	g_DownloadFileOther.iLastRcvTime = time_GetSecSince1970();

	return OtherSendMsgV2(g_Connection2, pcSend, sizeof(TFileFinishDataV2) + nLen + 1, IM_FUN_DOWNLOAD, g_Connection2->m_SendSerial++);
}

#endif

int im_c_ReportLocation(float _J, float _W)
{
	char pcSend[256] = {0};
	TLocationData *ptLocationData = (TLocationData *) pcSend;

	if (NULL == ptLocationData) return ERR;
	ptLocationData->m_J = _J * IM_JW_RATE;
	ptLocationData->m_W = _W * IM_JW_RATE;
	return c_SendMsg(pcSend, sizeof(TLocationData), IM_FUN_LOCATION, g_SendSerial++);
}

int im_c_GetLibMines() 
{
	return SendNoData(IM_FUN_GET_LIB_MINES);
}

int im_c_SetOrdinaryMines(int _iTime, char *_pcIndex, float _J, float _W, int _iSex, char *_pcText, int _iBombLevel)
{
	if (NULL == _pcIndex || 0 == *_pcIndex) return ERR;
	char pcSend[256];
	TSetOrdinaryMinesDataV2 *ptSetMinesData = (TSetOrdinaryMinesDataV2 *) pcSend;

	if (NULL == ptSetMinesData) return ERR;
	ptSetMinesData->m_cTime = _iTime;
	char_ncopy(ptSetMinesData->m_pcIndex, _pcIndex, IM_MINES_INDEX_LEN);
	ptSetMinesData->m_J = _J * IM_JW_RATE;
	ptSetMinesData->m_W = _W * IM_JW_RATE;
	ptSetMinesData->m_iSex = _iSex;
	char_ncopy(ptSetMinesData->m_pcText, _pcText, 64);
	ptSetMinesData->m_iBombLevel = _iBombLevel;
	c_SendMsg(pcSend, sizeof(TSetOrdinaryMinesDataV2), IM_FUN_SET_MINES_ORDINARY, g_SendSerial++);
	// 返回发送的序列号
	return g_SendSerial - 1;
}

int im_c_SetMines(int _iType) 
{
	return SendOneInt(IM_FUN_GET_SET_MINES, _iType);
}

//获取八张图相册的图片列表
int Im_c_GetAlbumList(long long _llUserId) 
{
	return SendOneLongLong(IM_FUN_GET_ALBUM_LIST, _llUserId);
}

static int im_c_DoAlbum(char *_pcPicture, int _iFun) 
{
	return SendOneString(_iFun, _pcPicture, strlen(_pcPicture));
}

//增加图片到八张图相册
int im_c_AlbumAdd(char *_pcPicture) 
{
	return im_c_DoAlbum(_pcPicture, IM_FUN_ALBUM_ADD);
}

//从八张图相册删除
int im_c_AlbumDel(char *_pcPicture) 
{
	return im_c_DoAlbum(_pcPicture, IM_FUN_ALBUM_DEL);
}

int im_c_GetPhoto() 
{
	return SendNoData(IM_FUN_PHOTO_GET);
}

static int im_c_DoPhoto(char *_pcPicture, int _iFun) 
{
	return SendOneString(_iFun, _pcPicture, strlen(_pcPicture));
}

int im_c_AddPhoto(char *_pcPicture) 
{
	return im_c_DoPhoto(_pcPicture, IM_FUN_PHOTO_ADD);
}

int im_c_DelPhoto(char *_pcPicture) 
{
	return im_c_DoPhoto(_pcPicture, IM_FUN_PHOTO_DEL);
}

static int SendAreaData(int _iFun, float _StartJ, float _StartW, float _StopJ, float _StopW, int _nType) 
{
	char pcSend[sizeof(TAreaData)] = {0};
	TAreaData *ptHotData = (TAreaData *) pcSend;

	if (NULL == ptHotData) return ERR;
	ptHotData->m_StartJ = _StartJ * IM_JW_RATE;
	ptHotData->m_StartW = _StartW * IM_JW_RATE;
	ptHotData->m_StopJ = _StopJ * IM_JW_RATE;
	ptHotData->m_StopW = _StopW * IM_JW_RATE;
	ptHotData->m_nType = _nType;
	c_SendMsg(pcSend, sizeof(TAreaData), _iFun, g_SendSerial++);
	return g_SendSerial - 1;// 返回发送的序列号
}

int im_c_GetAreaMines(float _StartJ, float _StartW, float _StopJ, float _StopW, int _nType) 
{
	return SendAreaData(IM_FUN_AREA_MINES, _StartJ, _StartW, _StopJ, _StopW, _nType);
}

int im_c_AddContact(char *_pcPhoneList) 
{
	return SendOneString(IM_FUN_CONTACT_ADD, _pcPhoneList, strlen(_pcPhoneList));
}

int im_c_JudgeMinesLen(float _StartJ, float _StartW, float _NowJ, float _NowW) 
{
	return mines_GetLen(_StartJ * IM_JW_RATE, _StartW * IM_JW_RATE,
		_NowJ * IM_JW_RATE, _NowW * IM_JW_RATE) / 10;
}

int im_c_JudgeMinesDirection(float _StartJ, float _StartW, float _NowJ, float _NowW) 
{
	int Angle = mines_GetAngle(_StartJ * IM_JW_RATE, _StartW * IM_JW_RATE, _NowJ * IM_JW_RATE, _NowW * IM_JW_RATE);

	int iDir = 0;
	if (Angle <= 45 || (Angle >= 315 && Angle <= 360)) // 北
	{
		iDir = 4;
	}
	else if (Angle >= 135 && Angle <= 225) // 南
	{
		iDir = 2;
	}
	else if (Angle >= 225 && Angle <= 315) // 西
	{
		iDir = 3;
	}
	else if (Angle >= 45 && Angle <= 135) // 东
	{
		iDir = 1;
	}

	return iDir;
}

int im_c_SetDoMinesEnable(int _iEnable) 
{
	return SendOneInt(IM_FUN_SET_DO_MINES_ENABLE, _iEnable);
}

int im_c_GetDoMinesEnable() 
{
	return SendNoData(IM_FUN_GET_DO_MINES_ENABLE);
}

int im_c_SendFile(char *_pcDir) 
{
	void *fp = file_OpenForRead(_pcDir);

	if (NULL == fp) 
	{
		dbg();
		return ERR;
	}

	int iCount = 0;
	int iRead = 0;
	char pcData[1024];

	while ((iRead = file_Read(fp, pcData, sizeof(pcData))) > 0) 
	{
		iCount += iRead;
	}

	return iCount;
}

int im_c_GetMinesRecord(int _iIndex) 
{
	return SendOneInt(IM_FUN_MINES_RECORD, _iIndex);
}

int im_c_BeBombLevel(int _iBeomLevel) 
{
	return SendOneInt(IM_FUN_BE_BOMB_LEVEL, _iBeomLevel);
}

int im_c_UpdateFriendTag(long long _llUserId, char *_pcTag)
{
	char pcSend[256];
	TFriendTagData *ptFriendTag = (TFriendTagData *) pcSend;

	if (NULL == ptFriendTag) return ERR;
	ptFriendTag->m_llUserId = _llUserId;
	char_ncopy(ptFriendTag->m_pcTag, _pcTag, IM_TAG_LEN);
	return c_SendMsg(pcSend, sizeof(TFriendTagData), IM_FUN_UPDATE_FRIEND_TAG, g_SendSerial++);
}

int im_c_Feedback(char *_pcText)
{
	return SendOneString(IM_FUN_FEEDBACK, _pcText, char_len(_pcText));
}

int im_c_WxCreateOrder(char *_pcOrderInfo)
{
	return SendOneString(IM_FUN_WX_CREATE_ORDER, _pcOrderInfo, char_len(_pcOrderInfo));
}

int im_c_ReportUser(long long _llUserId, int _iReasonIndex, char *_pcReport) 
{
	char pcSend[sizeof(TReportUserData)];
	TReportUserData *ptReportUserData = (TReportUserData *) pcSend;

	if (NULL == ptReportUserData) return ERR;
	ptReportUserData->m_llUserId = _llUserId;
	ptReportUserData->m_iReasonIndex = _iReasonIndex;
	char_ncopy(ptReportUserData->m_pcReport, _pcReport, char_len(_pcReport) + 1);
	return c_SendMsg(pcSend, sizeof(TReportUserData), IM_FUN_REPORTUSER, g_SendSerial++);
}

//上传心情
int c_UpdateUserFeeling(char *_pcData)
{
	return SendOneString(FUN_UPDATE_USER_FEELING, _pcData, strlen(_pcData));
}

//按类型点赞
int c_UpdateUserFeelingPraise(long long _llUserId, int _iPraiseType)
{
	char pcSend[256];
	TUpdateUserFeelingPraise *ptUpdateUserFeelingPraise = (TUpdateUserFeelingPraise *) pcSend;

	if (NULL == ptUpdateUserFeelingPraise) return ERR;
	ptUpdateUserFeelingPraise->m_llUser = _llUserId;
	ptUpdateUserFeelingPraise->m_iPraiseType = _iPraiseType;
	return c_SendMsg(pcSend, sizeof(TUpdateUserFeelingPraise), FUN_UPDATE_USER_FEELING_PRAISE, g_SendSerial++);
}

int c_GetFeelingList()
{
	return SendNoData(FUN_GET_FEELING_LIST);
}

int c_GetProductList()
{
	return SendNoData(FUN_GET_PRODUCT_LIST);
}
/*
int c_GetGiftList(int _iLastGiftId)
{
	return GetJsonData(_iLastGiftId, JSON_TYPE_GET_GIFT_LST);
}

int c_GetPartyInfo()
{
	return GetJsonData(0, JSON_TYPE_PARTY_INFO);
}

int c_GetPartyBuySchool()
{
	return GetJsonData(0, JSON_TYPE_PARTY_BUY_SCHOOL);
}

int c_GetPartyBuyMy()
{
	return GetJsonData(0, JSON_TYPE_PARTY_BUY_MY);
}

int c_GetPartyGrabSnacks(int _iPartyId)
{
	return GetJsonData(_iPartyId, JSON_TYPE_PARTY_GRAB_SNACKS);
}

int c_GetPartyJoin(int _iPartyId)
{
	return GetJsonData(_iPartyId, JSON_TYPE_PARTY_JOIN);
}

int c_GetPartyGrabMsg(int _iPartyId, int _iSchoolId)
{
	long long _llPageStartIndex = (((long long) _iPartyId) << 32) | _iSchoolId;

	return GetJsonData(_llPageStartIndex, JSON_TYPE_PARTY_GRAB_MSG);
}

int im_c_AlipayCreateOrder(char *_pcOrderInfo)
{
	return SendOneString(IM_FUN_ALIPAY_CREATE_ORDER, _pcOrderInfo, char_len(_pcOrderInfo));
}

int c_GetAddressAll()
{
	return GetJsonData(0, JSON_TYPE_GET_ADDRESS_ALL);
}

int c_GetAddressMy()
{
	return GetJsonData(0, JSON_TYPE_GET_ADDRESS_MY);
}
*/
int c_GetOneFeelingList(long long _llFriendId, int _iFeelingId)
{
	char pcSend[256] = {0};
	TGetOneFeelingLst *ptOneFeelingLst = (TGetOneFeelingLst *) pcSend;

	if (NULL == ptOneFeelingLst) return ERR;
	ptOneFeelingLst->m_llFriendId = _llFriendId;
	ptOneFeelingLst->m_iFeelingId = _iFeelingId;
	return c_SendMsg(pcSend, sizeof(TGetOneFeelingLst), FUN_GET_ONE_FEELING_LIST, g_SendSerial++);
}

int c_GetHotAreaList()
{
	return SendNoData(FUN_GET_HOT_AREA_LIST);
}

int c_GetSchoolListWithING()
{
	return SendNoData(FUN_GET_SCHOOL_LIST_WITH_ING);
}

int c_UpdateING(char *_pcPicUrl, char *_pcDescription, char *_pcTags, int _iSchoolId, int _iOpenEnable, int _iMinutes, int _iIndex, char *_pcPosInfo)
{
	char pcSend[5120];
	TUpdateINGV2 *ptUpdateING = (TUpdateINGV2 *) pcSend;

	if (NULL == ptUpdateING) return ERR;
	char_ncopy(ptUpdateING->m_pcPicUrl, _pcPicUrl, MAX_PIC_URL_LEN);
	char_ncopy(ptUpdateING->m_pcDescription, _pcDescription, MAX_DESCRIPTION_LEN);
	char_ncopy(ptUpdateING->m_pcTags, _pcTags, MAX_ING_TAGS_LEN);
	char_ncopy(ptUpdateING->m_pcPosInfo, _pcPosInfo, MAX_POS_INFO_LEN);
	ptUpdateING->m_iSchoolId = _iSchoolId;
	ptUpdateING->m_iOpenEnable = _iOpenEnable;
	ptUpdateING->m_iMinutes = _iMinutes;
	ptUpdateING->m_iIndex = _iIndex;
	return c_SendMsg(pcSend, sizeof(TUpdateINGV2), FUN_UPDATE_ING, g_SendSerial++);
}

int c_GetINGContentList(int _iSchoolId, int _iOpenEnable, long long _llPageStartContentId)
{
	char pcSend[25600];
	TGetINGContentList *ptGetINGContentList = (TGetINGContentList *) pcSend;

	if (NULL == ptGetINGContentList) return ERR;
	ptGetINGContentList->m_iSchoolId = _iSchoolId;
	ptGetINGContentList->m_iOpenEnable = _iOpenEnable;
	ptGetINGContentList->m_llPageStartContentId = _llPageStartContentId;//分页起始点:1,11,21,31....
	return c_SendMsg(pcSend, sizeof(TGetINGContentList), FUN_GET_ING_CONTENT_LIST, g_SendSerial++);
}

//为统计感兴趣人数，以聊天计算，不能重复
int c_UpdateINGLike(long long _llContentId)
{
	return SendOneLongLong(FUN_UPDATE_ING_LIKE, _llContentId);
}

int c_UpdateINGComment(long long _llContentId, long long _llDstUserId, char *_pcComment, int _iIndex)
{
	char pcSend[10240];
	TUpdateINGComment *ptUpdateIngComment = (TUpdateINGComment *) pcSend;

	if (NULL == ptUpdateIngComment) return ERR;
	ptUpdateIngComment->m_llUserId = _llDstUserId;
	ptUpdateIngComment->m_llContentdId = _llContentId;
	ptUpdateIngComment->m_iIndex = _iIndex;
	int iLen = char_len(_pcComment) + 1;
	char_ncopy(ptUpdateIngComment->m_pcComment, _pcComment, char_len(_pcComment) + 1);
	return c_SendMsg(pcSend, sizeof(TUpdateINGComment) + iLen, FUN_UPDATE_ING_COMMENT, g_SendSerial++);
}

int c_GetINGCommentWithContentId(long long _llContentId, long long _llPageStartCommentIndex)
{
	char pcSend[10240];
	TGetINGCommentList *ptGetINGCommentList = (TGetINGCommentList *) pcSend;

	if (NULL == ptGetINGCommentList) return ERR;
	ptGetINGCommentList->m_llContentdId = _llContentId;
	ptGetINGCommentList->m_llPageStartCommentIndex = _llPageStartCommentIndex;
	return c_SendMsg(pcSend, sizeof(TGetINGCommentList), FUN_GET_ING_COMMENT_LIST, g_SendSerial++);
}
/*
int c_GetINGListNotice(long long _llPageStartIndex)
{
	return GetJsonData(_llPageStartIndex, JSON_TYPE_LIST_ING_NOTICE);
}

int c_GetINGListMyPublish(long long _llPageStartIndex)
{
	return GetJsonData(_llPageStartIndex, JSON_TYPE_LIST_ING_MY_PUBLISH);
}

int c_GetINGListMyParticipate(long long _llPageStartIndex)
{
	return GetJsonData(_llPageStartIndex, JSON_TYPE_LIST_ING_MY_PARTICIPATE);
}*/

/** @brief 获取学校ing的总贴和新帖数
*/
int c_GetINGCount(int _iSchoolId)
{
	return SendOneInt(IM_FUN_GET_ING_COUNT, _iSchoolId);
}

/** @brief 更新学校ing查看时间
*/
int c_UpdateINGCheckTime(int _iSchoolId)
{
	return SendOneInt(IM_FUN_UPDATE_ING_CHECK_TIME, _iSchoolId);
}

void c_SetBackground(int _iBackground)
{
	g_iBackgroundState = _iBackground;

	if (IM_C_BG_STATE_YES == g_iBackgroundState) 
	{
		LockMx(m_BackgrounpMux);
	}
	else 
	{
		UnLockMx(m_BackgrounpMux);
	}
}

int im_c_UpdateUserFound(char *_pcPicUrl, char *_pcDescription, float _fJDu, float _fWDu, char *_pcCity, char *_pcAddress, int _iIndex)
{
	char pcSend[1152] = {0};
	TUpdateUserFound *ptMsg = (TUpdateUserFound *) pcSend;

	if (NULL == ptMsg) return ERR;
	char_ncopy(ptMsg->m_pcPicUrl, _pcPicUrl, MAX_PIC_URL_LEN);
	char_ncopy(ptMsg->m_pcDescription, _pcDescription, MAX_USER_FOUND_CONTENT);
	char_ncopy(ptMsg->m_pcCity, _pcCity, MAX_USER_FOUND_CITY);
	ptMsg->m_J = _fJDu * IM_JW_RATE;
	ptMsg->m_W = _fWDu * IM_JW_RATE;
	ptMsg->m_iIndex = _iIndex;
	char_ncopy(ptMsg->m_pcAddress, _pcAddress, MAX_POS_INFO_LEN);
	return c_SendMsg(pcSend, sizeof(TUpdateUserFound), IM_FUN_UPDATE_USER_FOUND_MSG, g_SendSerial++);
}

int im_c_UserFoundBeClick(int _iMsgId)
{
	return SendOneInt(IM_FUN_CLICK_USER_FOUND, _iMsgId);
}

int im_c_GetUserFoundList(char *_pcCity, int _iSex, int _iMsgId)
{
	char pcSend[512] = {0};
	TGetUserFoundLst *ptMsg = (TGetUserFoundLst *) pcSend;

	if (NULL == ptMsg) return ERR;
	char_ncopy(ptMsg->m_pcCity, _pcCity, MAX_USER_FOUND_CITY);
	ptMsg->m_iSex = _iSex;
	ptMsg->m_iMsgId = _iMsgId;
	return c_SendMsg(pcSend, sizeof(TGetUserFoundLst), IM_FUN_GET_USER_FOUND_LIST, g_SendSerial++);
}

int im_c_CheckPayType(int _iType, long long _llRecvId) 
{
	char pcSend[256] = {0};
	TCheckPayType *ptData = (TCheckPayType *) pcSend;

	if (NULL == ptData) return ERR;
	ptData->m_iType = _iType;
	ptData->m_llRecvId = _llRecvId;
	return c_SendMsg(pcSend, sizeof(TCheckPayType), IM_FUN_CHECK_PAY_TYPE, g_SendSerial++);
}

int im_c_SendVideo(char* _pcVideoPath, float _J, float _W,char* _pcAddrInfo,char* _pcMsg,int64_t _nIWantMsgId,int32_t _nLocalId)
{
	if (NULL == _pcVideoPath || NULL == _pcAddrInfo || NULL == _pcMsg) return ERR;

	char pcSend[sizeof(TUserVideo)] = {0};
	TUserVideo *ptTmpData = (TUserVideo *) pcSend;
	char_ncopy(ptTmpData->pcUrl, _pcVideoPath, sizeof(ptTmpData->pcUrl));
	char_ncopy(ptTmpData->pcAddrInfo, _pcAddrInfo, sizeof(ptTmpData->pcAddrInfo));
	char_ncopy(ptTmpData->pcMsg, _pcMsg, sizeof(ptTmpData->pcMsg));
	ptTmpData->m_J = _J * IM_JW_RATE;
	ptTmpData->m_W = _W * IM_JW_RATE;
	ptTmpData->nIWantMsgId = _nIWantMsgId;
	ptTmpData->nLocalId = _nLocalId;
	return c_SendMsg(pcSend, sizeof(TUserVideo), IM_FUN_SEND_USER_VIDEO, g_SendSerial++);
}

int im_c_DelUserVideo(int64_t _llVideoId) 
{
	return SendOneLongLong(IM_FUN_DEL_USER_VIDEO, _llVideoId);
}

int im_c_ClickUserVideo(int64_t _llVideoId) 
{
	return SendOneLongLong(IM_FUN_CLICK_USER_VIDEO, _llVideoId);
}

int im_c_ShareUserVideo(int64_t _llVideoId) 
{
	return SendOneLongLong(IM_FUN_SHARE_USER_VIDEO, _llVideoId);
}
/*
int im_c_GetMyGlobalVideoList(long long _llLastId) 
{
	return GetJsonData(_llLastId, JSON_TYPE_GLOBAL_VIDEO_MY);
}
*/
/** @brief 视频点赞
* @param[in] iGlobalVideoId 视频id
* @return 成功返回0 ，否则返回-1
*/
int c_UpdateVideoLike(int64_t _llVideoId) 
{
	return SendOneLongLong(FUN_UPDATE_VIDEO_LIKE, _llVideoId);
}

int c_GetVideoLikeCount(long long _llGlobalVideoId) 
{
	return SendOneLongLong(FUN_GET_VIDEO_LIKE_COUNT, _llGlobalVideoId);
}

/** @brief 视频评论
* @param[in] iGlobalVideoId 视频id
* @param[in] _pcComment 评论内容
* @return 成功返回0，否则返回-1
*/
int c_UpdateVideoComment(int64_t _llVideoId, char *_pcComment, int _nLocalId) 
{
	char pcSend[10240];
	TUpdateVideoComment *ptUpdateVideoComment = (TUpdateVideoComment *) pcSend;
	if (NULL == ptUpdateVideoComment) return ERR;
	ptUpdateVideoComment->m_llContentdId = _llVideoId;
	ptUpdateVideoComment->nLocalId = _nLocalId;
	int iLen = char_len(_pcComment) + 1;
	char_ncopy(ptUpdateVideoComment->m_pcComment, _pcComment, char_len(_pcComment) + 1);
	return c_SendMsg(pcSend, sizeof(TUpdateINGComment) + iLen + 1, FUN_UPDATE_VIDEO_COMMENT, g_SendSerial++);
}

int im_c_GetUserInfoCount()
{
	return SendNoData(FUN_GET_USER_INFO_COUNT);
}

/** @brief 分页获取视频评论内容
* @param[in] iGlobalVideoId 视频id
* @param[in] _llPageStartCommentIndex 上页最后一条评论数
* @return 成功返回JSON，否则返回-1
*/
int c_GetVideoCommentWithContentId(long long _llGlobalVideoId, long long _llPageStartCommentIndex) 
{
	char pcSend[10240];
	TGetINGCommentList *ptGetINGCommentList = (TGetINGCommentList *) pcSend;

	if (NULL == ptGetINGCommentList) return ERR;
	ptGetINGCommentList->m_llContentdId = _llGlobalVideoId;
	ptGetINGCommentList->m_llPageStartCommentIndex = _llPageStartCommentIndex;
	return c_SendMsg(pcSend, sizeof(TGetINGCommentList), FUN_GET_VIDEO_COMMENT_LIST, g_SendSerial++);
}

/*********************************************** 个人主页及主题视频相关接口 ********************************************************/

int im_c_FollowUser(uint16_t _iArea, uint64_t _llUser) 
{
	return SendOneLongLong(FUN_FOLLOW_USER, FullPhone(_iArea,_llUser));
}

int im_c_UnFollowUser(uint16_t _iArea, uint64_t _llUser) 
{
	return SendOneLongLong(FUN_CANCEL_FOLLOW_USER, FullPhone(_iArea,_llUser));
}
/*
int c_GetFansCount(long long _llUserId) 
{
	return GetJsonData(_llUserId, JSON_TYPE_GET_FANS_COUNT);
}*/

int c_GetFansList(uint16_t _iArea, uint64_t _llUser,int32_t _nLastId) 
{
	char pcSend[sizeof(TGFansList)] = {0};
	TGFansList *ptGetFansList = (TGFansList *) pcSend;

	if (NULL == ptGetFansList) return ERR;
	ptGetFansList->m_llUserId = FullPhone(_iArea,_llUser);
	ptGetFansList->m_nLastId = _nLastId;
	return c_SendMsg(pcSend, sizeof(TGFansList), FUN_GET_FANS_LIST, g_SendSerial++);
}

int c_GetFollowList(uint16_t _iArea, uint64_t _llUser,int32_t _nLastId) 
{
	char pcSend[sizeof(TGFansList)] = {0};
	TGFansList *ptGetFansList = (TGFansList *) pcSend;

	if (NULL == ptGetFansList) return ERR;
	ptGetFansList->m_llUserId = FullPhone(_iArea,_llUser);
	ptGetFansList->m_nLastId = _nLastId;
	return c_SendMsg(pcSend, sizeof(TGFansList), FUN_GET_FOLLOW_LIST, g_SendSerial++);
}

int im_c_GetMyFriends(int32_t _nLastId)
{
	return SendOneInt(IM_FUN_MY_FRIENDS, _nLastId);
}

int c_SendIWant(float _beginLongitude, float _beginLatitude,float _endLongitude, float _endLatitude,char* _pcAddrInfo,char* _pcCountryInfo,char* _pcMsg,int32_t _nLocalId)
{
	if (NULL == _pcAddrInfo || NULL == _pcMsg) return ERR;

	char pcSend[sizeof(TMsgIWant)] = {0};
	TMsgIWant *ptMsgIWant = (TMsgIWant *) pcSend;
	if (NULL == ptMsgIWant) return ERR;
	ptMsgIWant->beginLocation.m_J = TMIN(_beginLongitude,_endLongitude) * IM_JW_RATE;
	ptMsgIWant->beginLocation.m_W = TMIN(_beginLatitude,_endLatitude) * IM_JW_RATE;
	ptMsgIWant->endLocation.m_J = TMAX(_beginLongitude,_endLongitude) * IM_JW_RATE;
	ptMsgIWant->endLocation.m_W = TMAX(_beginLatitude,_endLatitude) * IM_JW_RATE;
	char_ncopy(ptMsgIWant->pcAddrInfo,_pcAddrInfo,sizeof(ptMsgIWant->pcAddrInfo));
	char_ncopy(ptMsgIWant->pcCountryInfo,_pcCountryInfo,sizeof(ptMsgIWant->pcCountryInfo));
	char_ncopy(ptMsgIWant->pcMsg,_pcMsg,sizeof(ptMsgIWant->pcMsg));
	ptMsgIWant->nLocalId = _nLocalId;
	return c_SendMsg(pcSend, sizeof(TMsgIWant), FUN_MSG_I_WANT, g_SendSerial++);
}

int c_GetRangeUserNum(float _beginLongitude, float _beginLatitude,float _endLongitude, float _endLatitude)
{
	char pcSend[sizeof(TTwoLocation)] = {0};
	TTwoLocation *ptData = (TTwoLocation *) pcSend;
	if (NULL == ptData) return ERR;
	ptData->beginLocation.m_J = TMIN(_beginLongitude,_endLongitude) * IM_JW_RATE;
	ptData->beginLocation.m_W = TMIN(_beginLatitude,_endLatitude) * IM_JW_RATE;
	ptData->endLocation.m_J = TMAX(_beginLongitude,_endLongitude) * IM_JW_RATE;
	ptData->endLocation.m_W = TMAX(_beginLatitude,_endLatitude) * IM_JW_RATE;

	return c_SendMsg(pcSend, sizeof(TTwoLocation), IM_FUN_RANGE_USER_NUM, g_SendSerial++);
}

int c_GetRangeVideoLst(float _beginLongitude, float _beginLatitude,float _endLongitude, float _endLatitude,int64_t _nLastId)
{
	char pcSend[sizeof(TRangeVideoLst)] = {0};
	TRangeVideoLst *ptData = (TRangeVideoLst *) pcSend;
	if (NULL == ptData) return ERR;
	ptData->beginLocation.m_J = TMIN(_beginLongitude,_endLongitude) * IM_JW_RATE;
	ptData->beginLocation.m_W = TMIN(_beginLatitude,_endLatitude) * IM_JW_RATE;
	ptData->endLocation.m_J = TMAX(_beginLongitude,_endLongitude) * IM_JW_RATE;
	ptData->endLocation.m_W = TMAX(_beginLatitude,_endLatitude) * IM_JW_RATE;
	ptData->nLastId = _nLastId;

	return c_SendMsg(pcSend, sizeof(TRangeVideoLst), IM_FUN_RANGE_VIDEO_LST, g_SendSerial++);
}

int im_c_GetVideoLst(uint16_t _iArea, uint64_t _llUser,int64_t _nLastId)
{
	char pcSend[sizeof(TUserPaging)] = {0};
	TUserPaging *ptGetFansList = (TUserPaging *) pcSend;
	if (NULL == ptGetFansList) return ERR;

	ptGetFansList->iArea = _iArea;
	ptGetFansList->llUserId = _llUser;
	ptGetFansList->nLastId = _nLastId;
	return c_SendMsg(pcSend, sizeof(TUserPaging), IM_FUN_USER_VIDEO_LST, g_SendSerial++);
}

int c_CreateEvent(char *_pcEventName, float _J, float _W, int _offset_time, int _nState,char *_pcUserID)
{
	char pcSend[10240] = {0};
	int nLen = 0;
	nLen = strlen(_pcUserID);
	if (nLen + sizeof(TSGroupMsg) > sizeof(pcSend)) return ERR;
	TCreateEvent *ptTmpData = (TCreateEvent *) pcSend;

	if (NULL == ptTmpData) return ERR;
	char_ncopy(ptTmpData->m_pcName, _pcEventName, sizeof(ptTmpData->m_pcName));
	ptTmpData->m_J = _J * IM_JW_RATE;
	ptTmpData->m_W = _W * IM_JW_RATE;
	ptTmpData->m_nOffset = _offset_time;
	ptTmpData->m_nState = _nState;
	memcpy(ptTmpData->m_pcUserid, _pcUserID, nLen);
	return c_SendMsg(pcSend, sizeof(TCreateEvent) + nLen + 1, FUN_CREATE_EVENT, g_SendSerial++);
}

int im_c_Add_EventMembers(int _nEventid, char *_pcUserID) 
{
	char pcSend[10240] = {0};
	int nLen = 0;
	nLen = strlen(_pcUserID);
	if (nLen + sizeof(TSGroupMsg) > sizeof(pcSend)) return ERR;
	TSGroupMsg *ptTmpData = (TSGroupMsg *) pcSend;

	if (NULL == ptTmpData) return ERR;
	ptTmpData->m_llGroupid = _nEventid;
	memcpy(ptTmpData->m_pcUserID, _pcUserID, nLen);

	return c_SendMsg(pcSend, sizeof(TSGroupMsg) + nLen + 1, IM_FUN_ADD_EVENT_MEMBERS, g_SendSerial++);
}

int c_GetUserEvent(long long _llUserId, int _nLastId) 
{
	char pcSend[1024];
	TGFansList *ptGetFansList = (TGFansList *) pcSend;

	if (NULL == ptGetFansList) return ERR;
	ptGetFansList->m_llUserId = _llUserId;
	ptGetFansList->m_nLastId = _nLastId;
	return c_SendMsg(pcSend, sizeof(TGFansList), FUN_GET_USEREVENT_LIST, g_SendSerial++);
}

int c_GetEventVideo(int _nEventId, float _StartJ, float _StartW, float _StopJ, float _StopW) 
{
	char pcSend[1024];
	TEventVideoList *ptGetEventVideoList = (TEventVideoList *) pcSend;

	if (NULL == ptGetEventVideoList) return ERR;
	ptGetEventVideoList->m_nEventId = _nEventId;
	ptGetEventVideoList->m_StartJ = _StartJ;
	ptGetEventVideoList->m_StartW = _StartW;
	ptGetEventVideoList->m_StopJ = _StopJ;
	ptGetEventVideoList->m_StopW = _StopW;
	return c_SendMsg(pcSend, sizeof(TEventVideoList), FUN_GET_EVENT_VIDEO_LIST, g_SendSerial++);
}

int c_GetEvent_UserVideo(int _nEventId, long long _lluserId, int _nLastId) 
{
	char pcSend[256];
	TEventUserVideoList *ptGetEventUserVideoList = (TEventUserVideoList *) pcSend;

	if (NULL == ptGetEventUserVideoList) return ERR;
	ptGetEventUserVideoList->m_nEventId = _nEventId;
	ptGetEventUserVideoList->m_llUserId = _lluserId;
	ptGetEventUserVideoList->m_nLastId = _nLastId;
	return c_SendMsg(pcSend, sizeof(TEventUserVideoList), FUN_GET_EVENT_USERVIDEO_LIST, g_SendSerial++);
}

int c_GetOthersVideo(long long llUserID, long long _llLastId) 
{
	char pcSend[10240];
	TGetINGCommentList *ptOthersVideoList = (TGetINGCommentList *) pcSend;

	if (NULL == ptOthersVideoList) return ERR;
	ptOthersVideoList->m_llContentdId = llUserID;
	ptOthersVideoList->m_llPageStartCommentIndex = _llLastId;
	return c_SendMsg(pcSend, sizeof(TGetINGCommentList), FUN_GET_OTHERS_VIDEO_LIST, g_SendSerial++);
}

int c_GetSendEvent(float _J, float _W, int _nLastId) 
{
	char pcSend[1024] = {0};
	TGSendEvent *ptTmpData = (TGSendEvent *) pcSend;

	if (NULL == ptTmpData) return ERR;
	//char_ncopy(ptTmpData->m_pcName,_pcEventName,sizeof(ptTmpData->m_pcName));
	ptTmpData->m_nLastId = _nLastId;
	ptTmpData->m_J = _J * IM_JW_RATE;
	ptTmpData->m_W = _W * IM_JW_RATE;
	return c_SendMsg(pcSend, sizeof(TGSendEvent), FUN_GET_SENDEVENT_LIST, g_SendSerial++);
}

int im_c_CreateGroup(char *_pcGroupName, char *_pcTag, char *_pcUserID) 
{
	char pcSend[10240] = {0};
	int nLen = char_len(_pcUserID);
	if (nLen + sizeof(TGroupInfo) > sizeof(pcSend)) return ERR;

	TGroupInfo *ptTmpData = (TGroupInfo *) pcSend;
	if (NULL == ptTmpData) return ERR;

	char_ncopy(ptTmpData->m_pcName, _pcGroupName, sizeof(ptTmpData->m_pcName));
	char_ncopy(ptTmpData->m_pcTag, _pcTag, sizeof(ptTmpData->m_pcTag));
	memcpy(ptTmpData->m_pcUserID, _pcUserID, nLen);
	return c_SendMsg(pcSend, sizeof(TGroupInfo) + nLen + 1, IM_FUN_CREATE_GROUP, g_SendSerial++);
}

int im_c_Add_GroupMembers(uint64_t _llGroupid, char *_pcUserID) 
{
	char pcSend[10240] = {0};
	int nLen =  char_len(_pcUserID);
	if (nLen + sizeof(TSGroupMsg) > sizeof(pcSend)) return ERR;
	TSGroupMsg *ptTmpData = (TSGroupMsg *) pcSend;
	if (NULL == ptTmpData) return ERR;

	ptTmpData->m_llGroupid = _llGroupid;
	memcpy(ptTmpData->m_pcUserID, _pcUserID, nLen);
	return c_SendMsg(pcSend, sizeof(TSGroupMsg) + nLen + 1, IM_FUN_ADD_GROUP_MEMBERS, g_SendSerial++);
}

int im_c_Delete_Group(uint64_t _llGroupid) 
{
	return SendOneLongLong(IM_FUN_DELETE_GROUP, _llGroupid);
}

int im_c_Get_GroupMember_List(uint64_t _llGroupid, uint64_t _llLastId) 
{
	char pcSend[sizeof(TGGroupUserList)] = {0};
	TGGroupUserList *ptTmpData = (TGGroupUserList *) pcSend;

	if (NULL == ptTmpData) return ERR;

	ptTmpData->m_nIndex = im_c_GetIndex();
	ptTmpData->m_llGroupId = _llGroupid;
	ptTmpData->m_llLastId = _llLastId;
	return c_SendMsg(pcSend, sizeof(TGGroupUserList), IM_FUN_GET_GROUPMEMBER_LIST, g_SendSerial++);
}

int im_c_SendGroupMsg(int64_t  _iIndex, uint16_t _iSrcArea, uint64_t _llSrcUser, uint64_t _llGroupid, int16_t _iDataType, char *_pcData, uint32_t _iDataLen, int16_t _iAdditional)
{
	if (NULL == _pcData || 0 == _iDataLen) return ERR;
	int iDType = (_iAdditional << 16) | _iDataType;

	std::vector<char> vcData(sizeof(TSendGroupData) + _iDataLen + 1);
	TSendGroupData *ptSendUserData = (TSendGroupData *)&*vcData.begin();
	if (NULL == ptSendUserData) return ERR;

	ptSendUserData->m_iIndex = _iIndex;
	ptSendUserData->m_llSrcUserId = FullPhone(_iSrcArea,_llSrcUser);
	ptSendUserData->m_llGroupId = _llGroupid;
	ptSendUserData->m_uTime = time_GetSecSince1970();
	ptSendUserData->m_iType = iDType;
	ptSendUserData->m_iLen = _iDataLen;
	char_ncopy(ptSendUserData->m_pcData, _pcData, _iDataLen + 1);

	if (OK != c_SendMsg((const char*)&*vcData.begin(), vcData.size(), IM_FUN_SEND_GROUP_MESSAGE, g_SendSerial++))
	{
		return ERR;
	}
#if 0
	CImMsg imgMsg(sizeof(TSendGroupData) + _iDataLen);
	TSendGroupData *ptSendUserData = (TSendGroupData *) imgMsg.data();
	if (NULL == ptSendUserData) return ERR;

	ptSendUserData->m_iIndex = _iIndex;
	ptSendUserData->m_llSrcUserId = _llSrcUser;
	ptSendUserData->m_llGroupId = _llGroupid;
	ptSendUserData->m_uTime = time_GetSecSince1970();
	ptSendUserData->m_iType = iDType;
	ptSendUserData->m_iLen = _iDataLen;
	char_ncopy(ptSendUserData->m_pcData, _pcData, _iDataLen + 1);

	PMsgHead msgHead = (PMsgHead) imgMsg.body();
	msgHead->iFun = IM_FUN_SEND_GROUP_MESSAGE;
	msgHead->iSerial = g_SendSerial++;
	imgMsg.encode_packet();

	const uint32_t iMaxSendOnce = 1024;
	uint32_t iOffset = 0;
	uint32_t iSend = imgMsg.length() > iMaxSendOnce ? iMaxSendOnce : imgMsg.length();
	while (iOffset < imgMsg.length()) 
	{
		if (ERR == c_SendData((char*)imgMsg.head() + iOffset, iSend)) return ERR;

		iOffset += iSend;
		iSend = imgMsg.length() - iOffset > iMaxSendOnce ? iMaxSendOnce : imgMsg.length() - iOffset;
		usleep(200);
	}
#endif

	return g_SendSerial - 1;// 返回发送的序列号
}

int im_c_Exit_Group(uint64_t _llGroupid) 
{
	return SendOneLongLong(IM_FUN_EXIT_GROUP, _llGroupid);
}

int im_c_Get_MyGroup_List() 
{
	return SendNoData(IM_FUN_GET_MYGROUP_LIST);
}

int im_c_DelGroupMember(uint64_t _llGroupid, uint16_t _iArea, uint64_t _llUserId)
{
	char pcSend[256] = {0};
	TGGroupUserList *ptTmpData = (TGGroupUserList *) pcSend;
	if (NULL == ptTmpData) return ERR;

	ptTmpData->m_nIndex = im_c_GetIndex();
	ptTmpData->m_llGroupId = _llGroupid;
	ptTmpData->m_llLastId = FullPhone(_iArea,_llUserId);
	return c_SendMsg(pcSend, sizeof(TGGroupUserList), IM_FUN_DEL_GROUP_MEMBER, g_SendSerial++);
}

int im_c_DriverQuotedPrice(char *_pcProvince,char *_pcCity,char *_pcRegion,uint32_t _iPrice)
{
	char pcSend[sizeof(DriverQuotedPrice)] = {0};
	DriverQuotedPrice *ptTmpData = (DriverQuotedPrice *) pcSend;
	if (NULL == ptTmpData) return ERR;

	char_ncopy(ptTmpData->m_pcProvince, _pcProvince, sizeof(ptTmpData->m_pcProvince));
	char_ncopy(ptTmpData->m_pcCity, _pcCity, sizeof(ptTmpData->m_pcCity));
	char_ncopy(ptTmpData->m_pcRegion, _pcRegion, sizeof(ptTmpData->m_pcRegion));
	ptTmpData->m_iPrice = _iPrice;
	return c_SendMsg(pcSend, sizeof(DriverQuotedPrice), IM_FUN_DRIVER_QUOTE_PRICE, g_SendSerial++);
}


int im_c_DelQuotedPrice(uint64_t _idQuotedPrice)
{
	return SendOneLongLong(IM_FUN_DEL_QUOTE_PRICE,_idQuotedPrice);
}

int im_c_GetUsrDFCInfo(uint16_t _iArea, uint64_t _llUser)
{
	return SendOneLongLong(IM_FUN_DFC_USER_INFO,FullPhone(_iArea,_llUser));
}

int c_GetUserCreateEvent_rights() 
{
	return SendNoData(FUN_GET_USER_CREATE_EVENT_RIGHTS);
}

int OtherRecvDownloadReData(char *_pcData, int _iLen) 
{
	if (g_DownloadFileOther.iDownLoad) 
	{
		if (g_DownloadFileOther.iDownloadLen >= g_DownloadFileOther.iDownloadSize) 
		{
			// 首先通知服务器，关闭上次下载的文件
			//OtherSendNoData(g_Connection2, IM_FUN_DOWNLOAD_RE_FINISH);
			OtherSendOneLongLong(g_Connection2, IM_FUN_DOWNLOAD_RE_FINISH, g_DownloadFileOther.llFileName);
			//CallBackDownloadFinish();
			OtherCallBackDownloadFinish();
		}
		else 
		{
			int *piRet = (int *) (_pcData + im_pub_DataStartLen);
			if (*piRet >= g_DownloadFileOther.iMaxSerial) 
			{
				g_DownloadFileOther.iSvrSendFinsh = 1;
			}
			if (g_DownloadFileOther.iSvrSendFinsh == 1) 
			{
				if (file_waitng_confirm_is_empty()) 
				{
					//下载出错了，因为上面已经判断过下载长度和要下载的文件总大小了
					dbg();
					im_c_OtherCancleDownLoad();
					g_DownloadFileOther.iDownloadLen = 0;//置0 ,客户端好判断
					g_DownloadFileOther.iLastRcvTime = 0;
					//CallBackDownloadFinish();
					OtherCallBackDownloadFinish();
				}
				else 
				{
					file_waiting_confirm_traversal(OtherSendLostDownloadPack);//请求丢包数据
				}
			}
			else 
			{
				im_c_OtherContinueDownLoad();
			}
		}
	}
	else 
	{
		//OtherSendNoData(g_Connection2, IM_FUN_DOWNLOAD_RE_FINISH);
		OtherSendOneLongLong(g_Connection2, IM_FUN_DOWNLOAD_RE_FINISH, g_DownloadFileOther.llFileName);
	}
	return OK;
}

int im_c_UpdatePushCounter(int32_t _nCounter)
{
	if (_nCounter < 0) return ERR;
	return SendOneInt(IM_FUN_UPDATE_PUSH_COUNTER, _nCounter);
}


int im_c_GetDriversByDriver(float _iX1, float _iX2, float _iY1, float _iY2, int _iPageNum, int _iPageSize)
{
	char pcSend[128];
	TQueryDirversData *ptQueryData = (TQueryDirversData *) pcSend;
	if (NULL == ptQueryData) return ERR;
	ptQueryData->iX1 = _iX1;
	ptQueryData->iX2 = _iX2;
	ptQueryData->iY1 = _iY1;
	ptQueryData->iY2 = _iY2;
	ptQueryData->iPageNum = _iPageNum;
	ptQueryData->iPageSize = _iPageSize;
	return c_SendMsg(pcSend, sizeof(TQueryDirversData), IM_FUN_DFC_QUERY_DRIVERS, g_SendSerial++	);
}


int im_c_DfcQueryUsersByLocation(int _iGetAllCityFlag, int _iSexFlag, int _iIdentity, char* _pcProvince, char* _pcCity, int _iPriceStart, int _iPriceEnd, int _iCurIdx, int _iPageSize)
{
	int iProvinceLen = 0;
	int iCityLen = 0;
	if (_iGetAllCityFlag == 1)
	{
		if (NULL == _pcProvince)
		{
			dbg();
			return ERR;
		}
		iProvinceLen = char_len(_pcProvince);
		if (iProvinceLen == 0)
		{
			dbg();
			return ERR;
		}
		if (NULL == _pcCity)
		{
			dbg();
			return ERR;
		}
		iCityLen = char_len(_pcCity);
		if (iCityLen == 0)
		{
			dbg();
			return ERR;
		}
	}
	
	char pcSend[1024] = {0};
	TDfcQueryUsersByLocation *ptUserData = (TDfcQueryUsersByLocation *) pcSend;

	if (NULL == ptUserData) return ERR;
	ptUserData->m_city_flag = _iGetAllCityFlag;
	ptUserData->m_sex_flag = _iSexFlag;
	ptUserData->m_identity = _iIdentity;
	ptUserData->m_price_start = _iPriceStart;
	ptUserData->m_price_end = _iPriceEnd;
	ptUserData->m_page_num = _iCurIdx;
	ptUserData->m_page_size = _iPageSize;
	char_ncopy(ptUserData->m_pcProvince, _pcProvince, iProvinceLen + 1);
	char_ncopy(ptUserData->m_pcCity, _pcCity, iCityLen + 1);
	return c_SendMsg(pcSend, sizeof(TDfcQueryUsersByLocation) + iProvinceLen + iCityLen, IM_FUN_DFC_QUERY_USERS_BY_LOC, g_SendSerial++);
}
