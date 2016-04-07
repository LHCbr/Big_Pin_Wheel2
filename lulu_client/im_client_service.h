#ifndef _IM_CLIENT_SERVICE_H_
#define _IM_CLIENT_SERVICE_H_

#include "im_pub.h"

#define RUN_ON_ANDROID		0 // 是否运行在安卓平台 1是 0否
#define RUN_TWO_THREAD		1 // 上传、下载图片单独一个线程

#if RUN_ON_ANDROID
#include <jni.h>

#define JNI_CLASS_NAME		"com/lulu/xo/lulu/service/LuluService"
#define JNI_FRIEND_SUM		100
#define JNI_LUCK_SUM		100
#define JNI_MINES_SUM		100
#endif

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 返回其他用户发来的消息
// _iIndex 标记值
// _llSrcUser 发送用户
// _lTime 发送时间
// _iDataType 数据类型 ，详见im_pub.h中TImDataType
// _pcData 数据
// _iDataLen 数据长度
typedef int(* FImRecvFun)(int _iIndex, long long _llSrcUser, long long _llDstUser, int _uTime, 
							int _iDataType, char *_pcData, int _iDataLen, int _iAdditional);

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 返回执行结果
// _iFun 功能号，见im_pub.h中TImFun
//_iSerial 序列号
// _iRet 0成功 其他值 失败，见im_pub.h中TImRet
typedef int(* FImReturnFun)(int _iFun, int _iSerial, int _iRet);

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 返回状态
// _iState 状态，详见im_pub.h中，TImState
// _iRet 值
typedef int(* FImStateFun)(int _iState, int _iRet, int _iAdditional);

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 返回用户ID列表
// _iType 
//IM_USER_LIST_FIREND 	= 1,		// 获取自己的好友列表
//IM_USER_LIST_FIND		= 2,		// 查找到的用户列表
//IM_USER_LIST_DEL		= 3,		// 已经删除的好友列表，A删除B,通过此回调，推送给B
								// 20150116->改成了取消关注的返回
// _iCount 用户ID数量
// _pllFriendList 用户ID列表
typedef int(* FImUserListFun)(int _iType, int _iCount, long long *_pllFriendList);

// 返回用户列表的类型
enum
{
	IM_USER_LIST_FIREND 	= 1,		// 获取自己的好友列表
	IM_USER_LIST_FIND		= 2,		// 查找到的用户列表
	IM_USER_LIST_DEL		= 3,		// 已经删除的好友列表，A删除B,通过此回调，推送给B
										// 20150116->改成了取消关注的返回
	IM_USER_LIST_BLACK		= 4,		// 已经拉黑的好友列表，A拉黑B,通过此回调，推送给B
	IM_USER_FOLLOW_MUTUAL	= 1,		//互相关注或者好友
	IM_USER_BE_FOLLOW 		= 90,		// 被关注
	IM_USER_TMEPORAR 		= 99,		// 临时好友
	IM_USER_FOLLOW 			= 100,		// 关注
//	IM_USER_VERSION_DIFF	= 100,		//版本差距
	IM_USER_DEL 			= 101,		// 删除
	IM_USER_BLACK 			= 102,		// 拉黑
};

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/** @brief    返回个人详细信息
  * @param[in]  _iSex   性别 1男 2女 0保密
  * @param[in]  _pcNickName 昵称
  * @param[in]  _iMines 雷数量
  */
typedef int(* FImSelfInfoFun)(long long _llUserId, int _iSex, char *_pcNickName, int _iMines, char *_pcArea);
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 返回个人详细扩展信息
// _iPhoneshow是否展示手机
// _pcLookingfor 寻找
// _pcFeature 外貌
// _pcAffection 情感状态
// _pcCharacter 性格
// _pcHobby爱好
// _pcOccupation 职业
// _pcHomeplace 出生地
// _pcLanguage 语言

//暂时也可被FImUserExtendInfoFun代替
typedef int(* FImSelfExtendInfoFun)(int _iPhoneshow, char *_pcLookingfor, char *_pcFeature, 
										char *_pcAffection, char *_pcCharacter, char *_pcHobby,
										char *_pcOccupation, char *_pcHomeplace, char *_pcLanguage
										);								
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 返回用户详细信息
// _llUser 用户ID
// _iFriendSource 0邀请注册，1添加 2炸 3通讯录推荐
// _pcTag 备注
// _iState 是否是好友
// _iSex 性别 1男 2女 0保密
// _pcBirthday 生日
// _iAge 年龄
// _pcNickName 昵称
// _pcHeadPortrait 头像Url
// _pcSignature 个性签名
// _pcSchool 学校
// _pcCompany 公司
// _pcArea 地区
// _iMines 雷数量
// _pcSchoolName 学校名
// _pcClassName 班级名
typedef int(* FImUserInfoFun)(long long _llUser, int _iSex, char *_pcNickName, int _iMines, char *_pcArea);


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 返回用户扩展详细信息
// _llUser 用户ID
// _iPhoneshow是否展示手机
// _pcLookingfor 寻找
// _pcFeature 外貌
// _pcAffection 情感状态
// _pcCharacter 性格
// _pcHobby爱好
// _pcOccupation 职业
// _pcHomeplace 出生地
// _pcLanguage 语言
//_iFans粉丝
//动物肖像索引值
typedef int(* FImUserExtendInfoFun)(long long _llUser, int _iPhoneshow, char* _pcLookingfor,
								char *_pcFeature, char *_pcAffection, char *_pcCharacter,
								char *_pcHobby, char *_pcOccupation, char *_pcHomeplace, char *_pcLanguage,
								int _iFans, int _iAnimalPotraitIndex
								);



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 返回雷信息
// _iMinesSum 雷数目
// _iSetOrdinary 已放置的普通雷
// _iSetFriend 已放置的好友雷
// _iDoOrdinary 已成功的普通雷
// _iDoFriend 已成功的好友雷
// _iFailure 已失效的雷
// _iEarn 净赚的雷
typedef int(* FImLibMinesFun)(int _iMinesSum, int _iSetOrdinary, int _iSetFriend,
								int _iDoOrdinary, int _iDoFriend, int _iFailure, int _iEarn);

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 返回Json数据
// _iFun 详见im_pub.h中TImFun
// _pcJsonString json数据
// _iLen json长度
//typedef int(* FImCircleListFun)(int _iCount, TOneCircleData **_pptCircleList);
typedef int(* FImJsonFun)(int _iFun, char *_pcJsonString, int _iLen);
typedef int(* FImCallback)(uint32_t _iFun, char *_pcJsonString, uint32_t _iJsonLen, char *_pcBitBuf, uint32_t _iBufLen);

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 返回发送文件的url
// _lFileName 文件名
// _pcFilePath 文件路径url
typedef int(* FImUpLoadFinishFun)(int _uFileName, char *_pcFilePath);

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 返回下载的文件数据
// _pcUrl 文件Url
// _ptCircleList 信息列表
typedef int(* FImDownloadFinishFun)(char *_pcUrl, char *_pcData, int _iLen);

#if RUN_TWO_THREAD
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 返回发送文件的url
// _lFileName 文件名
// _pcFilePath 文件路径url
typedef int(* FImOtherUpLoadFinishFun)(long long _lFileName, char *_pcFilePath);

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 返回下载的文件数据
// _pcUrl 文件Url
// _ptCircleList 信息列表
typedef int(* FImOtherDownloadFinishFun)(char *_pcUrl, char *_pcData, int _iLen);
#endif

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 返回设置的雷的信息
// _iType 请求类型，同函数im_c_SetMines的参数_iType
// _iOrdinaryCount 普通雷的数量
// _ptOrdinaryMines 普通雷的信息
// _iFriendCount 好友雷的数量
// _ptFriendMines 好友雷的信息
typedef int (*FImSetMinesFun)(int _iType, int _iOrdinaryCount, TBackOrdinaryMinesData *_ptOrdinaryMines,
									int _iFriendCount, TBackFriendMinesData *_ptFriendMines);

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 返回抽奖信息列表
// _iCount 信息数量
// _ptLuckData 信息列表
//typedef int(* FImLuckListFun)(int _iCount, TLuckOneData *_ptLuckData);

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 返回好友被放置的雷数
// _iCount 数量
// _ptOneMinesData 好友雷信息
typedef int(* FImFriendListMinesFun)(int _iCount, TFriendOneMinesData *_ptOneMinesData);

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 返回任务状态列表
// _iCount 数量
// _piState 任务状态_piState[i]代表第i个任务的状态 0未完成1完成
// 0 邀请好友
// 1 上传头像
// 2 个性签名
// 3 上传一个图片
// 4 布置雷
typedef int(* FImTskStateFun)(int _iCount, int *_piState);

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 返回好友雷上传结果
// _pcNewId 雷ID
// _iResult 结果:0正确<0 错误原因
typedef int(* FImFMinesResultFun)(char *_pcNewId, int _iResult);


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#endif

