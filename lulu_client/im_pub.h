#ifndef _IM_PUB_H_
#define _IM_PUB_H_

#include "t_pub.h"
#include <stdint.h>


#include "ImMsg.h"

#define 	IM_CLUSTER_ENABLE		1	// 服务器集群
#define     IM_USE_GEO_HASH         1   //使用geo hash 计算坐标

#define HAVE_OPENSSL

#define 	IM_HEART_ENABLE			1 	// 是否有心跳包
#define 	IM_HEART_SEND			5	// 心跳发送间隔:秒
#define 	IM_HEART_MAX			30	// 心跳失效时间:秒
#define 	IM_TIME_MAX_SERIAL		5	// 发送的消息未确认时间:秒
#define 	IM_TIME_MAX_FILE		5	// 未接收到上传数据时间:秒
#define 	IM_TIME_MAX_DOWNLOAD	5	// 未接收到下载确认的时间:秒

#define 	IM_TIME_FILE_TIMEOUT	20	// 上传下载线程无操作超时，关闭socket用
#define 	IM_INVATATION_CODE		0 // 注册是否需要邀请码
#define		IM_BE_MINES_UPPER		20 //每天被炸上限
#define 	IM_IP_LEN			16

//手机号最大位数
#define		PhoneMaxBit 100000000000
#define		FullPhone(iArea,llPhoneNum)	((uint64_t)iArea * PhoneMaxBit + llPhoneNum)

//获取区域内数据列表功能
enum TGetArea_DataType{
	GET_AREA_PEOPLE					= 0X1,		//获取区域内小雷人
	GET_AREA_VIDEO_ALL				= 0x2,		// 获取区域内24小时内视频
	GET_AREA_VIDEO_LATEST			= 0x4,		// 获取区域最新视频
	GET_AREA_VIDEO_HOTTEST			= 0x8,		// 获取区域最热视频
	GET_AREA_EVENT					= 0x10,		// 获取区域事件列表
	//GET_AREA_MINES					= 0x20,		// 获取区域内所有雷
};

//事件类型
enum EventType{
	PUBLIC_EVENT					= 0X00,		//公有事件
	PRIVATE_EVENT				    = 0x01,		//私有事件
};

// 帧的功能号
enum TImFun
{
	IM_FUN_REGISTER						= 0x1,		// 注册
	IM_FUN_LOGIN						= 0x2,		// 登陆
	IM_FUN_IS_REGISTER					= 0x3,		// 判断是否已经注册
	IM_FUN_RESET_PASSWD					= 0x4,		// 重置密码
	IM_FUN_RESET_PSW_CHECK				= 0x5,		// 重置密码前检查验证码
	IM_FUN_UPDATE_INFO					= 0x7,		// 更新个人详细信息
	FUN_GET_EVENT_USERVIDEO_LIST		= 0x8,		//获取事件内用户的视频列表		
	IM_FUN_UPDATE_TOKEN					= 0x9,		// 更新token	
	FUN_GET_USER_CREATE_EVENT_RIGHTS	= 0xA,    //获取用户是否具有创建事件的权限
	IM_FUN_DEL_GROUP_MEMBER				= 0xB,		// 群主删除某人
	IM_FUN_LOGOUT						= 0x10,		// 登出
	IM_FUN_CREATE_GROUP					= 0x12,		// 新建群
	IM_FUN_DELETE_GROUP					= 0x13,		// 删除群

	IM_FUN_AREA_MINES					= 0x14,		// 获得区域内的所有雷
	IM_FUN_ADD_GROUP_MEMBERS			= 0x15,		// 添加群组成员
	IM_FUN_GET_GROUPMEMBER_LIST 		= 0x16,		// 获取群组成员列表
	IM_FUN_SEND_GROUP_MESSAGE			= 0x17,		// 发送群消息
	IM_FUN_EXIT_GROUP					= 0x18,		// 成员退群

//	IM_FUN_NORMAL_REGISTER				= 0x19,		// 无校验注册	
	IM_FUN_GET_MYGROUP_LIST				= 0x1A,		// 获取我的群列表
	IM_FUN_ADD_EVENT_MEMBERS			= 0x1B,     // 添加事件成员
	IM_FUN_DEL_GROUPMEMBER				= 0x1C,		// 被移出群通知	

	IM_FUN_RANGE_USER_NUM				= 0x1D,		// 获得区域内的用户数
	IM_FUN_RANGE_VIDEO_LST				= 0x1E,		// 获得区域内的视频列表，有分页
	IM_FUN_USER_VIDEO_LST				= 0x1F,		// 获得某个用户的视频列表，有分页

	FUN_GET_USER_INFO_COUNT				= 0x20,		//用户信息中的，视频数量，好友、关注、粉丝的总数及新增数

	IM_FUN_ADD_FRIEND					= 0x21,		// 添加好友(现在单方添加就行)
//	IM_FUN_RE_ADD_FRIEND				= 0x22,		// 回复添加好友
	IM_FUN_DEL_FRIEND					= 0x23,		// 删除好友
	IM_FUN_HD_DEL_FRIEND				= 0x24,		// A删除或拉黑B,通知B更新好友列表
	
	IM_FUN_RE_FRIEND_MINES				= 0x26,		// 回复
	IM_FUN_UPDATE_FRIEND_TAG			= 0x27,		// 上传更新朋友标签	
	IM_FUN_SEND_USER_VIDEO				= 0x28,		// 发布视频
	IM_FUN_CLICK_USER_VIDEO				= 0x29,		// 点击视频
	FUN_MSG_I_WANT						= 0x2A,		// 发送请求(鹰眼)
	IM_FUN_DEL_USER_VIDEO				= 0x2B,		// 删除视频
	IM_FUN_SHARE_USER_VIDEO				= 0x2C,		// 分享视频

	IM_FUN_WX_CREATE_ORDER				= 0x30,		// 生成微信预支付订单
	IM_FUN_CHECK_PAY_TYPE				= 0x31,		// 查询用户支付状态
	IM_FUN_RECV_GIFT_NOTIFY				= 0x32,		// 好友赠送礼物

	IM_FUN_INVITATION					= 0x33,		// 邀请好友
	IM_FUN_SEND_USER					= 0x35,		// 向用户发送消息,带主账号功能
	IM_FUN_UPDATE_RELATION_ID			= 0x36,		// 更新主账号
	FUN_GET_PRODUCT_LIST				= 0x37,		// 获取产品列表
	IM_FUN_ALIPAY_CREATE_ORDER			= 0x38,		// 生成支付宝支付订单

	IM_FUN_PHOTO_GET					= 0x41,		// 请求相册
	IM_FUN_PHOTO_RE_GET					= 0x42,		// 回复相册
	IM_FUN_PHOTO_ADD					= 0x43,		// 增加照片
	IM_FUN_PHOTO_DEL					= 0x44,		// 删除照片
	
	IM_FUN_UPDATE_PUSH_COUNTER			= 0x45,		// 更新推送时的数字

	IM_FUN_ALBUM_ADD					= 0x47,		// 增加图片到八张图片相册
	IM_FUN_ALBUM_DEL					= 0x48,		// 从八张图片相册删除
	FUN_UPDATE_USER_FEELING				= 0x49,		// 图片心情功能，上传图片url更新数据表
	FUN_UPDATE_USER_FEELING_PRAISE		= 0x4a,		// 对他人的图片心情点赞
	FUN_GET_FEELING_LIST				= 0x4b,		// 获取该页面所需所有好友心情以及赞等信息
	FUN_GET_HOT_AREA_LIST				= 0x4c,		// 获取热点区域，暂时返回八个学校名称和学校坐标。
	FUN_GET_ONE_FEELING_LIST			= 0x4d,		// 获取单个好友所有心情以及赞等信息
	
	IM_FUN_FIND_USER					= 0x51,		// 查找用户
	IM_FUN_CONTACT_ADD					= 0x55,		// 上传通讯录
	IM_FUN_RE_CONTACT_ADD				= 0x56,		// 回复上传通讯录

	IM_FUN_MY_FRIENDS					= 0x60,		// 获取好友列表
	IM_FUN_FRIEND_LIST					= 0x61,		// 获取好友列表
	IM_FUN_GET_USER_INFO				= 0x62,		// 查看用户详细信息

	IM_FUN_DRIVER_QUOTE_PRICE			= 0x63,		// 司机报价
	IM_FUN_DEL_QUOTE_PRICE				= 0x64,		// 删除报价
	IM_FUN_DFC_USER_INFO				= 0x65,		// 获取大丰车相关的用户信息
	IM_FUN_DFC_QUERY_DRIVERS				= 0x66, // 通过位置查询大丰车司机列表
	IM_FUN_DFC_QUERY_USERS_BY_LOC	= 0x67,	// 通过位置信息查询大丰车用户列表

	IM_FUN_FILE_DATA					= 0x71,		// 发送文件数据
	IM_FUN_FILE_RE_DATA					= 0x72,		// 回复发送文件 , 请求丢包
	IM_FUN_FILE_GRESS					= 0x73,		// 请求进度
	IM_FUN_FILE_RE_GRESS				= 0x74,		// 回复进度
	IM_FUN_FILE_FINISH					= 0x75,		// 发送文件完成，
	IM_FUN_FILE_RE_FINISH				= 0x76,		// 回复文件发送完成，包含url
	IM_FUN_FILE_CANCLE					= 0x77,		// 取消文件发送
	IM_FUN_FILE_RE_CANCLE				= 0x78,		// 回复取消文件发送
	IM_FUN_FILE_CONFIRMATION			= 0x79,		// 对发送数据进行确认，每10包确认一次

	IM_FUN_DOWNLOAD						= 0x81,		// 下载一个文件
	IM_FUN_DOWNLOAD_DATA				= 0x82,		// 下载的数据包
	IM_FUN_DOWNLOAD_RE_DATA				= 0x83,		// 回复数据包
	//IM_FUN_DOWNLOAD_FINISH			= 0x84,		// 下载完成
	IM_FUN_DOWNLOAD_LOST_PACK			= 0x84,		// 下载丢包
	IM_FUN_DOWNLOAD_RE_FINISH			= 0x85,		// 回复下载完成
	IM_FUN_DOWNLOAD_GRESS				= 0x86,		// 确认进度，进行断点续传
	IM_FUN_DOWNLOAD_RE_GRESS			= 0x87,		// 回复进度
	IM_FUN_DOWNLOAD_CANCLE				= 0x88,		// 取消下载
	IM_FUN_DOWNLOAD_RE_CANCLE			= 0x89,		// 确认取消下载
	IM_FUN_DOWNLOAD_CONFIRMATION		= 0x8A,		// 对下载数据进行确认

	IM_FUN_LOCATION						= 0x91,		// 报告个人位置信息
	IM_FUN_GET_LIB_MINES				= 0x92,		// 获取雷信息
	
	IM_FUN_SET_MINES_ORDINARY			= 0x94,		// 放置普通雷
	IM_FUN_SET_MINES_FRIEND				= 0x95,		// 放置好友雷
	IM_FUN_GET_SET_MINES				= 0x96,		// 获取放置的雷信息
	IM_FUN_RE_SET_MINES					= 0x97,		// 获取放置的雷信息
	
	
	IM_FUN_MINES_RECORD					= 0x9D,		// 获得雷的明细
	IM_FUN_BE_BOMB_LEVEL				= 0x9E,		// 获取/设置被炸级别
		
	IM_FUN_GET_ALBUM_LIST				= 0xAA,		// 获取影集图片

	IM_FUN_SET_DO_MINES_ENABLE			= 0xC1,		// 设置允许被炸的状态
	IM_FUN_RE_DO_MINES_ENABLE			= 0xC2,		// 回复允许被炸的状态
	IM_FUN_GET_DO_MINES_ENABLE			= 0xC3,		// 查询允许被炸的状态

	//IM_FUN_GET_SCHOOL					= 0xD1,		// 查询坐标所在学校
	FUN_GET_SCHOOL_LIST_WITH_ING		= 0xD4,		// 获取所有学校(开通ING的学校都返回，用使能区分)
	FUN_UPDATE_ING						= 0xD5,		// 发布ING
	FUN_GET_ING_CONTENT_LIST			= 0xD6,		// 获取学校ING列表
	FUN_UPDATE_ING_LIKE					= 0xD7,		// 喜欢该内容
	FUN_UPDATE_ING_COMMENT				= 0xD8,		// 评论该内容
	FUN_GET_ING_COMMENT_LIST			= 0xD9,		// 获取评论
	IM_FUN_GET_ING_COUNT				= 0xDA,		// 获取学校ing的总贴新帖数
	IM_FUN_UPDATE_ING_CHECK_TIME		= 0xDB,		// 更新学校ing的查看时间

	IM_FUN_UPDATE_USER_FOUND_MSG   		= 0xDC,		// 更新发现
	IM_FUN_CLICK_USER_FOUND     		= 0xDD,		// 点击发现
	IM_FUN_GET_USER_FOUND_LIST    		= 0xDE,		// 获取发现列表

	#if IM_HEART_ENABLE
	IM_FUN_HEART						= 0xE1,		// 心跳包
	IM_FUN_RE_HEART						= 0xE2,		// 回复心跳包
	#endif	
	
	IM_FUN_RETURN						= 0xE3,		// 返回结果,注册、登陆等操作的结果
	IM_FUN_STATE						= 0xE4,		// 返回状态
	IM_FUN_FEEDBACK						= 0xE5,		// 反馈
	IM_FUN_REPORTUSER					= 0xE6,		// 举报用户
	
	FUN_GET_JSON						= 0xF1,		// 获取JSON协议

	FUN_UPDATE_VIDEO_LIKE   			= 0xF2,  	// 视频点赞
	FUN_GET_VIDEO_LIKE_COUNT			= 0xF3,		// 获取点赞及评论总数
	FUN_UPDATE_VIDEO_COMMENT   			= 0xF4, 	// 视频评论
	FUN_GET_VIDEO_COMMENT_LIST   		= 0xF5, 	// 获取视频评论
	FUN_FOLLOW_USER						= 0xF6,		// 关注
	FUN_CANCEL_FOLLOW_USER				= 0xF7,		// 取消关注
	FUN_GET_FANS_LIST					= 0xF8,		// 获取粉丝列表
	FUN_GET_FOLLOW_LIST					= 0xF9,		// 获取粉关注表
	FUN_CREATE_EVENT					= 0xFA,		// 创建事件
	FUN_GET_USEREVENT_LIST				= 0xFB,		// 用户创建的事件列表
	FUN_GET_EVENT_VIDEO_LIST			= 0xFC,		// 获取事件内的视频列表
	FUN_GET_OTHERS_VIDEO_LIST			= 0xFD,		// 获取他人的视频列表
	FUN_GET_SENDEVENT_LIST				= 0xFE,		// 发送视频前获取当前位置附近的事件列表
	
	IM_FUN_MAX							= 0xFFFF		// 最大值
};

// 返回值
enum TImRet
{
	IM_RET_IS_BOOMINGTEAM		= -61,		//这是booming团队帐号
	IM_RET_RE_DO_MINES			= -60,		// 对一个已经确认状态的雷，进行重复确认
	IM_RET_REPEAT_INVITATION	= -53,		// 您已经被邀请过该用户
	IM_RET_ERR_PSW				= -52,		// 密码不合法
	IM_RET_ERR_VER_CODE			= -51,		// 验证码不正确或超时
	IM_RET_REPEAT_REGISTER		= -50,		// 该用户已经注册过
	IM_RET_NOT_FRIEND			= -40,		// 该用户不是您的好友
	IM_RET_NOT_FOLLOW			= -40,		// 兼容:你没有关注该用户
	IM_RET_NO_MINES				= -30,		// 雷数目不足
	IM_RET_REPEAT_FRIEND_MINES	= -31,		// 不能同时设置2个好友雷
	IM_RET_NOT_ALLOW_MINES		= -32,		// 对方不允许防雷
	IM_RET_MINES_FRIEND_USER	= -20,		// 放置的好友雷针对的用户不能是自己
	IM_RET_NOT_EXIST			= -11,		// 操作的对象不存在
	IM_RET_NO_NETWORK			= -4,		// 网络错误
	IM_RET_ERR_PARAMETER		= -3,		// 参数错误
	IM_RET_ERR_SERIAL			= -2,		// 序列号错误
	IM_RET_ERR_UNKNOWN			= -1,		// 未知错误
	IM_RET_OK					= 0,		// 成功执行
	IM_RET_SERIAL				= 1,		// 确认序列号

};

// 发送信息的类型
enum TImDataType
{
	IM_DATA_TYPE_ADDFRIEND		    = 0x21,		// 添加好友
	IM_DATA_TYPE_RE_ADDFRIEND	    = 0x22,		// 回复添加好友

	IM_DATA_TYPE_GIFT_BE_GRAB		= 0x26,		// 零食被抢，成为好友
	IM_DATA_TYPE_GIFT_DO_GRAB		= 0x27,		// 抢到别人的零食，成为好友

	IM_DATA_TYPE_MSG_I_WANT			= 0x28,		// 千里眼消息
	IM_DATA_TYPE_MSG_I_WANT_RE		= 0x29,		// 回复千里眼消息

	IM_DATA_TYPE_DO_MINES		    = 0x31,		// 触雷
	IM_DATA_TYPE_RE_MINES		    = 0x32,		// 自己放置的雷被触发
	IM_DATA_TYPE_DO_FRIEND		    = 0x33,		// 触好友雷
	IM_DATA_TYPE_RE_FRIEND		    = 0x34,		// 自己放置的好友雷被触发
	IM_DATA_TYPE_FAILURE		    = 0x35,		// 猜错好友雷
	IM_DATA_TYPE_RE_FAILURE		    = 0x36,		// 自己放置的好友雷猜错了
	IM_DATA_TYPE_SET_FRIEND		    = 0x37,		// 你被放置了一颗好友雷
	IM_DATA_TYPE_COUNT_FRIEND	    = 0x38,		// 好友雷结果的统计信息
	IM_DATA_TYPE_RE_INVITATION	    = 0x39,		// 邀请反馈

	IM_DATA_TYPE_MSG_CHECK_STATE    = 0x41,		//发送输入状态
	IM_DATA_TYPE_ING_NOTICE		    = 0x42,		//Ing 离线通知
	
	IM_DATA_TYPE_TEXT 			    = 0x0, 		// 文字
	IM_DATA_TYPE_JS 			    = 0x1, 		// js脚本
	IM_DATA_TYPE_AMR			    = 0x2, 		// 声音
	IM_DATA_TYPE_PICTURE		    = 0x3,		// 图片
	IM_DATA_TYPE_TXT_AND_PIC	    = 0x4,		// 文字加表情
	IM_DATA_TYPE_MP4        	    = 0x5,		// mp4视频

	IM_DATA_TYPE_SYSTEM			    = 0xA,	
};

// 状态
enum TImState
{
	IM_STATE_CONNECTED			= 0x9,	// 连上服务器了
	IM_STATE_CLOSE				= 0xA,	// 连接已失效，关闭
	IM_STATE_RE_LOGIN			= 0xB,	// 你在另处登录，被踢下线
	IM_STATE_NO_LOGIN			= 0xC,	// 连接后，未登录
    IM_STATE_UPDATE_USER_INFO	= 0xD,	// 更新个人资料后的状态返回

	IM_STATE_MSG_CHECK			= 0x61,	//发送给b正在输入的状态	
	IM_STATE_ADD_FRIEND			= 0x62,
	IM_STATE_RE_ADD_FRIEND		= 0x63,
	IM_STATE_RE_SERIAL			= 0x64,	// 确认及时消息,_iRet 对应的消息发送成功
	IM_STATE_ERR_SERIAL			= 0x65,	// 消息发送失败，_iRet 对应的消息发送失败

};

// 好友类型
enum TImFriendType
{
	IM_FRIEND_MUTUAL_FOLLOW		= -99,	// 好友
	IM_FRIEND_FIND				= -98,	// 查找出来的用户列表
	IM_FRIEND_BE_FOLLOW			= -10,	// 被关注
										//上面的所有关系都是操作 结构，不能用于好友关系表里面
	IM_FRIEND_TEMPORARY			= -1,	// 临时好友
	IM_FRIEND_FOLLOW			= 0,	// 关注
	IM_FRIEND_DEL				= 1,	// 删除或者陌生人
	IM_FRIEND_BLACK				= 2,	// 拉黑
};

//#if IM_CLUSTER_ENABLE
// 连接服务器互连的帧功能号
enum TILnkSvrFun
{
	IM_LNK_SVR_MSG_FORWARDING			= 0x1,		// 消息转发
	IM_LNK_SVR_RESET_PSW				= 0x2,		// 密码重置
	IM_LNK_SVR_UPDATE_TOKEN				= 0x3,		// 更新token
	IM_LNK_SVR_REGISTER					= 0x4,		// 用户注册
	IM_LNK_SVR_LOCATION					= 0x5,		// 用户报告位置
	IM_LNK_SVR_NEW_SVR					= 0x6,		// 有新的连接服务器连接过来
	IM_LNK_SVR_UPDATE_RID				= 0x7,		// 更新主账号
	IM_LNK_SVR_LOGIN_OTHER				= 0x8,		// 在其它服务器登录了，把本服务器的踢掉
	IM_LNK_SVR_DEL_FRND_NOTY			= 0x9,		// 删除好友，通知该服务器上的被删除用户
	
	IM_LNK_SVR_FRIEND_LST				= 0x10,		// 推送好友列表
	IM_LNK_SVR_ING_NOTICE				= 0x11,		// Ing通知转发
	IM_LNK_SVR_UPDATE_USER_INFO			= 0x12,		// 更新用户信息
//	IM_LNK_SVR_UPDATE_EXTERND_INFO		= 0x13,		// 更新用户扩展信息
	IM_LNK_SVR_USER_BE_MINES			= 0x14,		// 用户被炸
//	IM_LNK_SVR_UPDATE_SCHOOL_ID			= 0x15,		// 更新用户ing里的学校Id
	IM_LNK_SVR_UPDATE_BE_BOMB			= 0x16,		// 设置允许被炸状态
	IM_LNK_SVR_UPDATE_USER_INFO_V2		= 0x17,		// 更新用户信息
	IM_LNK_SVR_MSG_FORWARDING_V2		= 0x18,		// 消息转发

	IM_LNK_SVR_ADD_FRND_NOTY			= 0x19,		// 添加好友，通知该服务器上的用户被添加成好友了
	
	IM_LNK_SVR_UPDATE_SIMPLE			= 0xF0,		// 一些简单的功能
	
};

// 个人信息类型，用于更新
enum TImUserInfoType
{
	IM_USER_INFO_SEX		    = 0,	// 性别
	IM_USER_INFO_NICKNAME,				// 昵称
	IM_USER_INFO_AREA,					// 地区	
	IM_USER_INFO_ADDRESS,				//地址
	IM_USER_INFO_TELEPHONE,			// 电话号码
	IM_USER_INFO_ALL			= 255,	//所有
};


typedef union
{
	int m_iData;
	long long m_llData;
	char m_pcData[512];
/*	TLnkSvrIngNotice m_tIngNotice;
	TLnkSvrUserBeMines m_tUserBeMines;
	TLnkSvrUpdateSchoolId m_tUserSchoolId;*/
}TLnkSvrSimpleData;

typedef struct
{
	int m_iType;						//更新事件类型
	long long m_llUser;					//用户
	TLnkSvrSimpleData m_tSimpleData;	//数据
}TLnkSvrUpdateSimple;

enum TILnkSvrSimpleType
{
/*	IM_LSST_RESET_PSW			= 0x1,		// 密码重置
	IM_LSST_UPDATE_TOKEN		= 0x2,		// 更新token
	IM_LSST_UPDATE_RID			= 0x3,		// 更新主账号
	IM_LSST_LOGIN_OTHER			= 0x4,		// 在其它服务器登录了，把本服务器的踢掉
	IM_LSST_DEL_FRND_NOTY		= 0x5,		// 删除好友，通知该服务器上的被删除用户
	IM_LSST_FRIEND_LST			= 0x6,		// 推送好友列表	
	IM_LSST_ING_NOTICE			= 0x7,		// Ing通知转发
	IM_LSST_USER_BE_MINES		= 0x8,		// 用户被炸
	IM_LSST_UPDATE_SCHOOL_ID	= 0x9,		// 更新用户ing里的学校Id*/
	IM_LSST_UPDATE_BEBOMBLEVEL	= 0x10,		// 更新用户被炸级别
};

// 帧的功能号
enum TLoginSvrFun
{
	IM_LOGIN_SVR_HEART					= 0x1,		// 链接服务器心跳
	IM_LOGIN_SVR_GET_LNK_SVR			= 0x2,		// 链接服务器获取其它链接服务器
	IM_LOGIN_SVR_NEW_LNK_SVR			= 0x3,		// 链接服务器上线
//	IM_LOGIN_SVR_CLIENT_GET_LINKIP		= 0x4,		// 客户端请求登录的链接服务器地址
//	IM_LOGIN_SVR_LINKSERVER_RET			= 0x5,		// 链接服务器返回用户登录、登出
};

//ING通知类型
enum TIngNoticeType
{
	ING_NT_SYSTEM					= 0x0,		// 系统通知
	ING_NT_REPLY					= 0x1,		// 评论通知
	ING_NT_LIKE						= 0x2,		// 赞通知
	ING_NT_SCHOOL_USER				= 0x3,		// 身份确认,并提示进入学校ing的系统通知
};

//#endif

///////////////////////////////////////////////////////////////////////////////////////////////////
#define IM_CIRCLE_INDEX_LEN		32		// 朋友圈消息ID长度
#define IM_TAG_LEN				64		// 好友标签备注长度
#define IM_MINES_INDEX_LEN		32		// 雷ID长度
#define IM_MINES_TEXT_LEN		64		// 雷填写内容长度
#define IM_NAME_LEN				32		// 名称的长度
#define IM_NICKNAME_LEN			64		// 昵称的长度
#define IM_SIGNATURE_LEN		128		// 个性签名的长度
#define IM_HEAD_LEN				64		// 头像长度
#define IM_BIRTHDAY_LEN			11		// 生日长度
#define IM_AREA_LEN				31		// 地区长度
#define IM_SCHOOL_LEN			5120	// 学校长度
#define IM_COMPANY_LEN			5120	// 公司名
#define IM_LOOKINGFOR_LEN		512		// 交友目标
#define IM_FEATURE_LEN			512		// 外貌特征
#define IM_AFFECTION_LEN		512		// 情感状态
#define IM_CHARACTER_LEN		512		// 性格
#define IM_HOBBY_LEN			5120	// 兴趣
#define IM_OCCUPATION_LEN		512		// 职业
#define IM_HOMEPLACE_LEN		512		// 出生地
#define IM_LANGUAGE_LEN			300		// 语言
#define IM_TOKEN_LEN			68		// Token的长度
#define IM_PASSWORD_LEN			16		// 密码的长度
#define IM_DEVICE_KEY_LEN		50		// 设备唯一key长度
#define IM_VER_CODE_LEN			6		// 激请码，验证码的最大长度

#define IM_REPORTUSER_LEN		512 	// 举报用户
#define MAX_PIC_URL_LEN			255		// 上传图片链接长度
#define MAX_DESCRIPTION_LEN		2000	// 图片描述
#define MAX_ING_TAGS_LEN		255		// 标签
#define MAX_POS_INFO_LEN	    301		// 位置信息
#define MAX_MSG_I_WANT_LEN	    451		// 千里眼消息长度
#define MAX_COUNTRY_INFO_LEN	51		// 国家名字长度

#define MAX_ING_COMMENT_LEN		999 	// ING图片评论,单数，最后一个是0

#define IM_ONE_TIME_PACKAGE		10		// 上传或下载，一次发送的包数目
#define IM_ONE_PACKAGE_SIZE		1024 	// 上传或下载，一包的大小
#define IM_TIME_BETWEEN_PACKAGE	200	// 两包数据之间的间隔ms
#define MAX_FILE_PATH_LEN		255		// 文件路径最大长度
#define IM_SCHOOL_MAX_LEN		512		// 学校长度
#define MAX_USER_FOUND_CONTENT	301	    // 描述
#define MAX_USER_FOUND_CITY 	121	    // 城市

#define MAX_JSON_LEN            204800  //Json的最大传输长度

#define MD5_LEN 	33	    // MD5长度
#define IM_USER_NAME_LEN		121		// 用户名最长
#define IM_ROOM_ADDR_LEN		121		// 宿舍地址最长

#define IM_ONE_ADDR_LEN			50		// 省，市，区的最大长度


///////////////////////////////////////////////////////////////////////////////////////////////////

#pragma pack(1)

// 返回执行结果:登陆 注册等
typedef struct
{
	uint32_t m_iFun;
	uint8_t m_cSerial;
	int64_t m_iRet;
}TReturnData;

#define SC_DEVICE_KEY_LEN 51
#define SC_NICK_NAME_LEN 61

typedef struct DeviceInfo_
{
	char m_pcDeviceKey[SC_DEVICE_KEY_LEN];		// 设备key
	char m_pcOSType[SC_DEVICE_KEY_LEN];			// 系统型号 
	char m_pcOSVer[SC_DEVICE_KEY_LEN];			// 系统版本号
	char m_pcPhoneType[SC_DEVICE_KEY_LEN];		// 手机类型 Adroid 或 iOS
}DeviceInfo,*PDeviceInfo;
// 注册
typedef struct TRegisterDataV2_ : public PhoneInfo
{
	char pcPsw[IM_PASSWORD_LEN];			// 密码
	char pcVerCode[IM_VER_CODE_LEN];		// 验证码
	DeviceInfo phoneInfo;
}TRegisterDataV2;

// 登陆
typedef struct : public PhoneInfo
{
	char pcPsw[IM_PASSWORD_LEN];		// 密码
	uint32_t iLastTime;
}TLoginData;

// 查询司机列表
typedef struct QueryDirvers
{
	float iX1;
	float iX2;
	float iY1;
	float iY2;
	int iPageNum;
	int iPageSize;
}TQueryDirversData;




// 重置密码
typedef struct : public PhoneInfo
{
	char m_pcPsw[IM_PASSWORD_LEN];		// 新密码
	char m_pcCode[6];					// 验证码
}TResetPassWdData;


// 回复添加好友
// 添加好友
// 向用户发送消息
typedef struct
{
	int64_t m_iIndex;
	uint64_t m_llSrcUserId;	// 发送数据的用户ID
	uint64_t m_llDstUserId;	// 接收数据的用户ID
	uint32_t m_uTime;		// 发送时间
	int32_t m_iType;		// 数据类型
	uint32_t m_iLen;		// 数据长度
	char m_pcData[0];		// 数据
}TSendUserData;

typedef struct
{
	int64_t m_iIndex;
	uint64_t m_llSrcUserId;	// 发送数据的用户ID
	uint64_t m_llGroupId;	// 接收群ID
	uint32_t m_uTime;		// 发送时间
	int32_t m_iType;		// 数据类型
	uint32_t m_iLen;		// 数据长度
	char m_pcData[0];		// 数据
}TSendGroupData;

// 好友列表信息
typedef struct
{
	int32_t m_iFriendType;
	uint32_t m_iUserCount;		// 好友数目
	uint64_t m_pllUserList[0];	// 好友列表
}TUserListData;

//强加好友的返回
typedef struct
{
	uint64_t llUserId;			//对方的ID
	int8_t iRet;				//返回添加状态
	uint8_t iAdd: 1;			//0 添加， 1被添加
	uint8_t		: 7;			// 兼容windows的sizeof
}TAddFriendForeRetData;

// 查找项，项为1搜索，项为0不搜索
typedef struct 
{
	int8_t m_bFindId				: 1;
	int8_t m_bFindName				: 1;
	int8_t							: 6;	// 兼容windows的sizeof
}TFindGlobalData;

// 更新项
typedef union
{
	int m_iGlobalInt;
	TFindGlobalData m_ptGlobalStruct;
}TFindInfoIndex;

// 查找好友信息
typedef struct
{
	TFindInfoIndex m_ptFindInfo;
	long long m_llUserId;
	char m_pcNickName[IM_NICKNAME_LEN];
}TFindData;

//更新好友标签备注
typedef struct
{
	long long m_llUserId;
	char m_pcTag[IM_TAG_LEN];
}TFriendTagData;

// 用户详细信息
typedef struct : public PhoneInfo
{
//	uint64_t user_id; //表里面的id
	int8_t m_cSex;
	char m_pcBirthday[IM_BIRTHDAY_LEN];
	char m_pcNickName[IM_NICKNAME_LEN];
	char m_pcHeadPortrait[IM_HEAD_LEN];
	char m_pcSignature[IM_SIGNATURE_LEN];
	int8_t m_cIdentity;
}TUserInfoData;

// 回复用户背景图片
typedef struct
{
	long long m_llUser;
	char m_pcBack[0];
		char SharmBack[64];

}TReBackGroundData;

// 发送文件包
typedef struct
{
	uint64_t m_llFileName;	        // 文件名
	char m_pcFileMD5[MD5_LEN];	    // 文件MD5
	int32_t m_iFileType;	        // 文件类型
	int32_t m_iSerial;		        // 文件序列号
	int32_t m_iFileLen;		        // 文件总大小 ，非本次传输大小
	char m_pcData[0];	            // 文件内容
}TSendFileData;


// 回复发送完成
typedef struct
{
	unsigned int m_uFileName;
	char pcUrl[0];
}TFileFinishData;

// 回复发送完成
typedef struct
{
	uint64_t m_llFileName;
	char pcUrl[0];
}TFileFinishDataV2;


// 下载数据包
typedef struct
{
	int m_iSerial;		// 文件序列号
	int m_iFileSize;
	char m_pcData[0];	// 文件内容
	
}TDownLoadData;

// 一个班级的信息

typedef struct
{
	int m_iId;			// 班级ID
	char m_pcName[0];	// 班级名称
		char SharmName[32]; // 忽略
}TClassOneData;

// 班级列表
typedef struct
{
	int m_iCount;
	TClassOneData m_ptClassList[0];
}TClassListData;

// 邀请
typedef struct
{
	long long m_llUser;
}TInvitationData;

// 用户位置信息
typedef struct
{
	T_JW_TYPE m_J;
	T_JW_TYPE m_W;
}TLocationData;
// 心情点赞
typedef struct
{
	long long m_llUser;
	int m_iPraiseType;
}TUpdateUserFeelingPraise;


typedef struct
{
	int m_iSchoolId;
	int m_iOpenEnable;
	long long m_llPageStartContentId;
}TGetINGContentList;

typedef struct
{
	char m_pcPicUrl[MAX_PIC_URL_LEN];			//图片链接
	char m_pcDescription[MAX_DESCRIPTION_LEN];	//图片描述
	char m_pcTags[MAX_ING_TAGS_LEN];			//标签JSON
	int m_iSchoolId;							//目标ING广场
	int m_iOpenEnable;							//是否对外校开放
	int m_iMinutes;								//剩余消失时间
	int m_iIndex;
}TUpdateING;

typedef struct
{
	char m_pcPicUrl[MAX_PIC_URL_LEN];			//图片链接
	char m_pcDescription[MAX_DESCRIPTION_LEN];	//图片描述
	char m_pcTags[MAX_ING_TAGS_LEN];			//标签JSON
	int m_iSchoolId;							//目标ING广场
	int m_iOpenEnable;							//是否对外校开放
	int m_iMinutes;								//剩余消失时间
	int m_iIndex;
	char m_pcPosInfo[MAX_POS_INFO_LEN];		    //位置信息
}TUpdateINGV2;

typedef struct
{
	char m_pcPicUrl[MAX_PIC_URL_LEN];			    //图片链接
	char m_pcDescription[MAX_USER_FOUND_CONTENT];	//描述
	char m_pcCity[MAX_USER_FOUND_CITY];	            //城市
    T_JW_TYPE m_J;
    T_JW_TYPE m_W;
	int m_iIndex;
	char m_pcAddress[MAX_POS_INFO_LEN];	        //地理位置
}TUpdateUserFound;

typedef struct
{
	char m_pcCity[MAX_USER_FOUND_CITY];	            //城市
    int m_iSex;
	int m_iMsgId;
}TGetUserFoundLst;

typedef struct
{
	char m_pcName[MAX_PIC_URL_LEN];
	char pcUrl[MAX_PIC_URL_LEN];			    //图片链接
//	char m_pcDescription[MAX_USER_FOUND_CONTENT];	//描述
    T_JW_TYPE m_J;
    T_JW_TYPE m_W;
	int m_nEventid;
	int nLocalId;
}TSendBlobalVideo;

typedef struct
{
	char m_pcName[MAX_PIC_URL_LEN];
    T_JW_TYPE m_J;
    T_JW_TYPE m_W;
	int m_nOffset;
	int m_nState;
	char m_pcUserid[0];
}TCreateEvent;

typedef struct
{
	int m_nLastId;
    T_JW_TYPE m_J;
    T_JW_TYPE m_W;
}TGSendEvent;



typedef struct
{
	long long m_llFriendId;
	int m_iFeelingId;
}TGetOneFeelingLst;

typedef struct
{
	char m_pcName[MAX_PIC_URL_LEN];
	char m_pcTag[MAX_PIC_URL_LEN];
	char m_pcUserID[0];
}TGroupInfo;



typedef struct
{
	uint64_t m_llUserId;
	int32_t m_nLastId;
}TGFansList;

typedef struct : public PhoneInfo
{
	int64_t nLastId;
}TUserPaging;

typedef struct
{
	uint64_t m_llGroupid;
	char  m_pcUserID[0];
}TSGroupMsg;

typedef struct
{
	uint32_t m_nIndex;
	uint64_t m_llGroupId;
	uint64_t  m_llLastId;
}TGGroupUserList;


typedef struct
{
	char m_pcProvince[IM_ONE_ADDR_LEN];
	char m_pcCity[IM_ONE_ADDR_LEN];
	char m_pcRegion[IM_ONE_ADDR_LEN];
	uint32_t m_iPrice;
}DriverQuotedPrice;

typedef struct
{
	int64_t m_llFileName;
	int32_t m_nDownLoadSerial;
}TDownLoadContinue;


typedef struct
{
	int m_nEventId;
	T_JW_TYPE m_StartJ;	// 起点经度
	T_JW_TYPE m_StartW;	// 起点纬度
	T_JW_TYPE m_StopJ;	// 终点经度
	T_JW_TYPE m_StopW;	// 终点纬度
	
}TEventVideoList;

typedef struct
{
	int m_nEventId;
	long long m_llUserId;
	int m_nLastId;
}TEventUserVideoList;




typedef struct
{
	int m_iType;
	long long m_llRecvId;
}TCheckPayType;



// 雷库中雷的数量
typedef struct
{
	int32_t m_iMinesSum;		// 雷的数目
	int32_t m_iSetOrdinary;		// 设置的普通雷
	int32_t m_iSetFriend;		// 设置的好友雷
	int32_t m_iDoOrdinary;		// 炸的普通雷
	int32_t m_iDoFriend;		// 炸的好友雷
	int32_t m_iFailure;			// 失效的雷
	int32_t m_iEarn;			// 净赚的雷
}TLibMinesData;

// 放置普通雷
typedef struct
{
	char m_cTime;
	char m_pcIndex[0]; // ID
		char SharmIndex[IM_MINES_INDEX_LEN]; // 忽略
	T_JW_TYPE m_J;	// 经度
	T_JW_TYPE m_W;	// 纬度
	char m_iSex;	// 性别
	char m_pcText[0];	// 捎句话
		char SharmText[64]; // 忽略

}TSetOrdinaryMinesData;
// 放置普通雷
typedef struct
{
	char m_cTime;
	char m_pcIndex[0]; // ID
		char SharmIndex[IM_MINES_INDEX_LEN]; // 忽略
	T_JW_TYPE m_J;	// 经度
	T_JW_TYPE m_W;	// 纬度
	char m_iSex;	// 性别
	char m_pcText[0];	// 捎句话
		char SharmText[64]; // 忽略
	int m_iBombLevel;		// 要炸什么级别以上的人
}TSetOrdinaryMinesDataV2;

// 放置好友雷信息
typedef struct
{
	//char m_cTime;
	char m_pcIndex[0]; // ID
		char SharmIndex[IM_MINES_INDEX_LEN]; // 忽略
	#if 0
	T_JW_TYPE m_J;		// 经度
	T_JW_TYPE m_W;		// 纬度
	#endif
	long long m_llUser;	// 好友ID
	int m_iDirection; // 方向
	int m_iLen;		// 行进距离
	char m_pcText[0];	// 捎句话
		char SharmText[64]; // 忽略

}TSetFriendMinesData;

// 回调放置普通雷信息
typedef struct
{
	char m_pcIndex[0]; // ID
		char SharmIndex[IM_MINES_INDEX_LEN]; // 忽略
	float m_J;		// 经度
	float m_W;		// 纬度
	char m_cSex;	// 性别
	char m_pcSetTime[0];	// 下雷时间
		char SharmSetTime[20]; // 忽略
	char m_cState;	// 状态 0放置 1已炸 2失效
	int m_iRestTime; // 剩余时间，分钟
	char m_pcTime[0];	// 爆炸时间
		char SharmTime[20]; // 忽略
	

}TBackOrdinaryMinesData;

// 回调放置好友雷信息
typedef struct
{
	char m_pcIndex[0]; // ID
		char SharmIndex[IM_MINES_INDEX_LEN]; // 忽略
	float m_J;		// 经度
	float m_W;		// 纬度
	long long m_llUser;	// 好友ID
	char m_cDirection; // 方向
	int m_iLen;		// 行进距离
	char m_pcSetTime[0];	// 下雷时间
		char SharmSetTime[20]; // 忽略
	char m_cState;	// 状态 0放置 1已炸 2失效
	int m_iRestTime; // 剩余时间，分钟
	char m_pcTime[0];	// 爆炸时间
		char SharmTime[20]; // 忽略

}TBackFriendMinesData;

// 放置的雷的信息
typedef struct
{
	int m_iType;
	int m_iOrdinaryCount;
	int m_iFriendCount;

	TBackOrdinaryMinesData m_ptOrdinaryMines[0];
}TSetMinesData;

// 一条抽奖信息
typedef struct
{
	int m_iDbId; 	// 数据库id
	int m_iState;	// 0正常1已抽奖2失效
	int m_iTime;	// 剩余时间
}TLuckOneData;

// 抽奖列表
typedef struct
{
	int m_iCount;	// 个数
	TLuckOneData m_ptList[0];
	
}TLuckListData;

// 状态
typedef struct
{
	int32_t m_iState;
	int64_t m_iRet;
	int32_t m_iAdditional;
}TStateData;

// 任务状态
typedef struct
{
	char m_cTsk1;
	char m_cTsk2;
	char m_cTsk3;
	char m_cTsk4;
	char m_cTsk5;

}TTskStateData;

// 一个用户被放置的好友雷数目
typedef struct
{
	long long m_llUser;
	int m_iMines;
}TFriendOneMinesData;

// 返回用户当天被放置的好友雷数量
typedef struct
{
	int m_iCount;
	TFriendOneMinesData m_ptMinesList[0];
	
}TFriendListMinesData;

// 获得热点区域
typedef struct
{
	T_JW_TYPE m_StartJ;	// 起点经度
	T_JW_TYPE m_StartW;	// 起点纬度
	T_JW_TYPE m_StopJ;	// 终点经度
	T_JW_TYPE m_StopW;	// 终点纬度
	int m_nType;		//获取数据类型
}TAreaData;

// 上报好友雷结果
typedef struct
{
	char m_pcNewId[0];
		char SharmNewId[IM_MINES_INDEX_LEN];
	int m_iResult;
}TFriendMinesResultData;

// 发送一个int
typedef struct
{
	int32_t m_iData;
}TOneIntData;

// 发送一个long long 
typedef struct
{
	int64_t m_llData;
}TOneLongLongData;

// 发送一个String
typedef struct
{
	uint32_t m_iLen;
	char m_pcData[0];
}TOneStringData;
//发送一个JSON字符串
typedef struct
{
	uint32_t m_iJsonType;
	int64_t m_llPageStartIndex;
	TOneStringData m_tOneStringData;
}TOneJsonData;
/*
// 查询所在学校
typedef struct
{
	T_JW_TYPE m_J;		// 经度
	T_JW_TYPE m_W;		// 纬度
	
}TGetSchoolData;
*/

// 更新个人信息
typedef struct
{
    int32_t m_iType;
    TOneStringData m_ptData;
}TUpdateUserInfoData;

// 根据位置获取大丰车用户列表
typedef struct
{
	uint32_t m_city_flag;
	int32_t  m_sex_flag;
	uint32_t m_identity;
	uint32_t m_price_start;
	uint32_t m_price_end;
	uint32_t m_page_num;
	uint32_t m_page_size;
	char m_pcProvince[100];
	char m_pcCity[100];
}TDfcQueryUsersByLocation;

typedef TLocationData TGetSchoolData;

typedef struct
{
	uint64_t m_llUserId;
	int32_t m_iReasonIndex;			//备用，举报原因选项
	char m_pcReport[IM_REPORTUSER_LEN];
}TReportUserData;

typedef struct
{
	long long m_llUserId;				//目标用户
	long long m_llContentdId;			//所属图片ID
	int m_iIndex;						//反馈发送结果用
	char m_pcComment[0];
		char SharmComment[MAX_ING_COMMENT_LEN];

}TUpdateINGComment;

typedef struct
{
	int64_t m_llContentdId;			//所属视频ID
	int32_t nLocalId;				//客户端上传本地ID
	char m_pcComment[0];
}TUpdateVideoComment;


typedef struct
{
	long long m_llContentdId;			//所属图片ID
	long long m_llPageStartCommentIndex;		//分页index
}TGetINGCommentList;


typedef struct
{
	int32_t m_iPort;
	char m_pcHost[IM_IP_LEN];
	uint32_t m_iClientCount;
}TLnkSvrInfo;

typedef struct
{
	int m_iPort;
	char m_pcHost[IM_IP_LEN];
}TServerInfo;

//消息转发
typedef struct
{
	int64_t m_iIndex;
	uint64_t m_llSrcUserId;	// 发送者ID 
	uint64_t m_llDstUserId;	// 目标者ID 
	uint64_t m_llRcvUserId;	// 接收者ID 可能是目标者，也可能是目标者的主账号
	
	uint32_t m_uTime;		// 发送时间
	int32_t m_iType;		// 信息类型
	uint32_t m_iLen;		// 数据长度
	char m_pcData[0];		// 数据
}TMsgForwarding;


//消息转发
typedef struct
{
	int64_t m_iIndex;
	int32_t m_nMsgType;		//消息类型，0为普通消息，1为群消息
	uint64_t m_llGroupId;	//当消息为群消息时该变量为接收消息的群id号
	uint64_t m_llSrcUserId;	// 发送者ID 
	uint64_t m_llDstUserId;	// 目标者ID 
	uint64_t m_llRcvUserId;	// 接收者ID 可能是目标者，也可能是目标者的主账号
	
	uint32_t m_uTime;		// 发送时间
	int32_t m_iType;		// 信息类型
	uint32_t m_iLen;		// 数据长度
	char m_pcData[0];		// 数据
}TMsgForwarding_V2;


#if IM_CLUSTER_ENABLE

typedef TMsgForwarding TLnkSvrMsgForwarding;
typedef TMsgForwarding_V2 TLnkSvrMsgForwarding_V2;


// 发送一个String
typedef struct
{
	uint64_t m_llUserId;	// 发送者ID 
	TOneStringData m_strData;
}TLnkSvrOneStringData;

typedef struct
{
    uint64_t m_llUserId;
    int32_t m_iType;
    TOneStringData m_ptData;
}TLnkSvrUpdateUserInfoData;

// 发送一个位置信息
typedef struct
{
	long long m_llUserId;	// 发送者ID 
	TLocationData m_locationLast;//上一次最后出现的位置
	TLocationData m_locationNow;//当前所有位置
}TLnkSvrLocation;

// 用户注册
typedef struct : public PhoneInfo
{
	char m_pcPsw[IM_PASSWORD_LEN];		// 密码
}TLnkSvrRegister;

// 用户被炸
typedef struct
{
	long long m_llUserId;	//  发送者ID 
	int m_iLaseMinesTime;	//	最后被炸时间
	int m_iMinesTotal;		//	最后被炸那天，被炸的总次数
}TLnkSvrUserBeMines;

// 用户更新 ing 中的学校id
typedef struct
{
	long long m_llUserId;	//  发送者ID 
	int m_iSchoolId;	//	学校id
	char m_pcSchoolName[IM_SCHOOL_MAX_LEN];
}TLnkSvrUpdateSchoolId;


//
typedef struct
{
	long long m_llUserId;	// 用户
	long long m_llRelationId;	// 主账号
}TUserAndRelationId;

typedef struct
{
	long long m_llUserId;	// 用户
	int m_iBeBomb;	// 被炸设置
}TSetBeBomb;


typedef struct
{
	uint64_t m_llData1;
	uint64_t m_llData2;
}TTwoLongLongData;

//Ing通知转发
typedef struct
{
	int m_iEventType;		// 通知类型
	long long m_llSrcUserId;	// 触发通知用户
	long long m_llDstUserId;	// 接收通知的用户
	long long m_llIngId;	
	int m_iOtherId;			// 赞ID或者回复ID
}TLnkSvrIngNotice;

typedef struct
{
	TLocationData beginLocation;
	TLocationData endLocation;
}TTwoLocation;

typedef struct : public TTwoLocation
{
	char pcAddrInfo[MAX_POS_INFO_LEN];
	char pcCountryInfo[MAX_COUNTRY_INFO_LEN];
	char pcMsg[MAX_MSG_I_WANT_LEN];
	int32_t nLocalId;
}TMsgIWant;

typedef struct : public TTwoLocation
{
	int64_t nLastId;
}TRangeVideoLst;

typedef struct
{
	char pcUrl[MAX_PIC_URL_LEN];			    // 图片链接
	T_JW_TYPE m_J;
	T_JW_TYPE m_W;
	char pcAddrInfo[MAX_POS_INFO_LEN];			// 地址
	char pcMsg[MAX_MSG_I_WANT_LEN];				// 用户填写的视频信息
	int64_t nIWantMsgId;						// 大于0的时候，对应对方请求的千里眼表id
	int32_t nLocalId;							//需要返回给客户端的
}TUserVideo;

////////////////////////////模仿snapchat////////////////////////////////////


// 注册

// 用户详细信息
typedef struct
{
	uint64_t m_llUserId;
	uint8_t m_cSex;
	char m_pcNickName[SC_NICK_NAME_LEN];
	int32_t m_iMines;
	char m_pcArea[IM_AREA_LEN];
}TUserInfoData_SC;

typedef struct
{
	long long m_llFileName;	        		    // 文件名
	int m_iLen;                                 //  数组的有效长度
	int m_ptLostSerials[0];	                    // 没接收到的序列号
}TLostSerialPack;

#endif 



#pragma pack ()

//////////////////////////////////////////////////////////////////////////////////////////////////

// 帧头长度 4字节长度，2个0x68
#define im_pub_GetHeadLen()		6

// 帧尾长度
#define im_pub_GetEndLen()		2

// 数据起始字节
#define im_pub_DataStartLen		PACK_INFO_LEN
#define im_pub_GetFixLen()		PACK_INFO_LEN


// 解析协议中的长度
int im_pub_GetLen(const char *_pcData);

// 解析协议中的版本号
int im_pub_GetVersion(const char *_pcData);

// 解析协议中的功能号
int im_pub_GetFun(const char *_pcData);

// 解析协议中的发送序号
int im_pub_GetSendSerial(const char *_pcData);

#if 0
int im_pub_DataStartLen;
#endif

// 设置帧头，包括长度、功能号、发送序号
int im_pub_SetFrameHead(char *_pcSend, int _iDataLen, int _iFun, int _iSerial);

// 设置帧尾
int im_pub_SetFrameEnd(char *_pcSend, int _iCount);

// 设置发送序号
int im_pub_SetSendSerial(char *_pcSend, int _iSerial);

#endif


