#ifndef _IM_CLIENT_H_
#define _IM_CLIENT_H_

#include "im_client_service.h"

#if RUN_ON_ANDROID
// 装载
// 成功返回0，错误返回负值
int im_c_Load(JavaVM *_JavaVM);

// 初始化
// 传入服务器IP和端口，以及各种回调函数
// 成功返回0，错误返回负值
int im_c_Init(JNIEnv *_jniEnv, char *_pcIp, int _iPort, char *_pcFileSvrIp, int _iFileSvrPort);
#else
int im_c_Init(char *_pcIp, int _iPort, char *_pcFileSvrIp, int _iFileSvrPort, FImCallback _ptCallbackFunc);
#endif

// 连接服务器
// 成功返回0，错误返回负值
//int im_c_Connect();

// 判断当前连接是否有效
// 0 正常，其他值连接断开
int im_c_IsConnected();

// 断开服务器
// 成功返回0，错误返回负值
int im_c_DisConnect();

/** @brief    用户注册
  * @param[in]  _iArea			国际区号，最多四位
  * @param[in]  _llUser			用户名
  * @param[in]  _pcPsw			密码
  * @param[in]  _pcVerCode		验证码
  * @param[in]  _pcDeviceKey    设备唯一key
  * @param[in]  _pcOSType		系统型号
  * @param[in]  _pcOSVer		系统版本
  * @param[in]  _pcPhoneType    手机类型/ Andriod / iOS
  * @return  成功返回0，错误返回负值
  */
int im_c_Register(uint16_t _iArea, uint64_t _llUser, char *_pcPsw, char *_pcVerCode, char *_pcDeviceKey, char *_pcOSType, char *_pcOSVer, char *_pcPhoneType);
										
// 用户登陆
// _llUser 用户名
// _pcPsw 密码
// _llLastTime 好友列表更新时间
// 成功返回0，错误返回负值
int im_c_Login(uint16_t _iArea, uint64_t _llUser, char *_pcPsw, uint32_t _llLastTime);

// 用户登出
int im_c_Logout();

// 上传token
// _pcToken iOS设备的token
int im_c_UpdateToken(char *_pcToken);

/** @brief    更新用户个人资料
  * @param[in]  _iType  用户资料类型，详细请查看TImUserInfoType
  * @param[in]  _pcData 个人资料具体内容
  */
int im_c_UpdateUserInfo(int32_t _iType, char *_pcData);

//************************************
// Method:    im_c_ResetPassWd 重置密码
// FullName:  im_c_ResetPassWd
// Access:    public 
// Returns:   int	成功返回0，错误返回负值
// Qualifier:
// Parameter: uint16_t _iArea	国际区号
// Parameter: uint64_t _llUser	手机号
// Parameter: char * _pcPsw		新密码
// Parameter: char * _pcCode	验证码
//************************************
int im_c_ResetPassWd(uint16_t _iArea, uint64_t _llUser, char *_pcPsw, char *_pcCode);

//************************************
// Method:    im_c_ResetPswCheckCode	重置密码前检查验证码
// FullName:  im_c_ResetPswCheckCode
// Access:    public 
// Returns:   int
// Qualifier:
// Parameter: uint16_t _iArea	国际区号
// Parameter: uint64_t _llUser	手机号
// Parameter: char * _pcCode	验证码
//************************************
int im_c_ResetPswCheckCode(uint16_t _iArea, uint64_t  _llUser, char *_pcCode);

//************************************
// Method:    im_c_ReportLocation	报告位置信息
// FullName:  im_c_ReportLocation
// Access:    public 
// Returns:   int	成功返回0，错误返回负值
// Qualifier:
// Parameter: float _J	经度
// Parameter: float _W	纬度
//************************************
int im_c_ReportLocation(float _J, float _W);

//************************************
// Method:    im_c_GetUserInfo 查看好友的详细信息
// FullName:  im_c_GetUserInfo
// Access:    public 
// Returns:   int 成功返回0，错误返回负值
// Qualifier:
// Parameter: uint16_t _iArea 国际区号
// Parameter: uint64_t _llUser 手机号
//************************************
int im_c_GetUserInfo(uint16_t _iArea, uint64_t _llUser);

//************************************
// Method:    im_c_AddFriend
// FullName:  im_c_AddFriend	请求添加好友
// Access:    public 
// Returns:   int	成功返回0，错误返回负值
// Qualifier:
// Parameter: int64_t _iIndex	
// Parameter: uint16_t _iArea 国际区号
// Parameter: uint64_t _llUser	手机号
// Parameter: char * _pcData	验证信息
// Parameter: uint32_t _iDataLen	验证信息的长度
//************************************
int im_c_AddFriend(int64_t _iIndex, uint16_t _iArea, uint64_t _llUser, char *_pcData, uint32_t _iDataLen);

//************************************
// Method:    im_c_AddFriend_Force
// FullName:  im_c_AddFriend_Force	强制添加好友
// Access:    public 
// Returns:   int	成功返回0，错误返回负值
// Qualifier:
// Parameter: uint16_t _iArea 国际区号
// Parameter: uint64_t _llUser	手机号
//************************************
int im_c_AddFriend_Force(uint16_t _iArea, uint64_t _llUser);

//************************************
// Method:    im_c_ReAddFriend
// FullName:  im_c_ReAddFriend	回复好友添加
// Access:    public 
// Returns:   int	成功返回0，错误返回负值
// Qualifier:
// Parameter: int64_t _iIndex
// Parameter: uint16_t _iArea	国际区号
// Parameter: uint64_t _llUser	手机号
// Parameter: uint32_t _iState	1同意 0拒绝
//************************************
int im_c_ReAddFriend(int64_t _iIndex, uint16_t _iArea, uint64_t _llUser, uint32_t _iState);


//************************************
// Method:    im_c_DelFriend
// FullName:  im_c_DelFriend	删除好友
// Access:    public 
// Returns:   int	返回0-255表示发送序号，发送成功，错误返回其他值
// Qualifier:
// Parameter: uint16_t _iArea	国际区号
// Parameter: uint64_t _llUser	手机号
//************************************
int im_c_DelFriend(uint16_t _iArea, uint64_t _llUser);

// 获取发送消息的index,可能会重复
uint32_t im_c_GetIndex();
//产生几乎不可能重复的longlong值
uint64_t im_c_GetIndexLongLong();

/** @brief    向其他用户发送数据
  * @param[in]  _iIndex 从im_c_GetIndexLongLong() 返回的值
  * @param[in]  _llSrcUser
  * @param[in]  _llDstUser  目标用户Id
  * @param[in]  _iDataType  数据类型
  * @param[in]  _pcData     数据
  * @param[in]  _iDataLen   数据长度
  * @param[in]  _iAdditional    附加信息，对于阅后即焚，表示时间,对于声音，表示声音长度
  * @return  返回0-255表示发送序号，发送成功，错误返回其他值
  */
int im_c_SendUser(int64_t _iIndex, uint16_t _iSrcArea, uint64_t _llSrcUser, uint16_t _iDstArea, uint64_t _llDstUser, int16_t _iDataType, char *_pcData, uint32_t _iDataLen, int16_t _iAdditional);

#if RUN_TWO_THREAD
// 上传一个文件
// _uFileName 发送文件名，im_c_GetIndexLongLong 获取
// _iFileType 文件类型			IM_DATA_TYPE_TEXT 			= 0x0, 		// 文字
//								IM_DATA_TYPE_JS 			= 0x1, 		// js脚本
//								IM_DATA_TYPE_AMR			= 0x2, 		// 声音
//								IM_DATA_TYPE_PICTURE		= 0x3,		// 图片
//								IM_DATA_TYPE_TXT_AND_PIC	= 0x4,		// 文字加表情
//								IM_DATA_TYPE_MP4        	= 0x5,		// mp4视频
// _pcData 数据
// _iDataLen 数据长度
// 成功返回0，错误返回负值
int im_c_OtherUpLoad(uint64_t _llFileName, int32_t _iFileType, char *_pcData, uint32_t _iDataLen);

// 获取发送进度
// 返回值 ,正常:0-100 错误:负值
int im_c_OtherGetUpLoadProgress();

// 断点上传
int im_c_OtherContinueUpLoad();

// 取消上传
int im_c_OtherCancleUpLoad();

// 下载一个文件
// _pcUrl 文件地址
// 成功返回0，错误返回负值
int im_c_OtherDownLoad(char *_pcUrl);

// 获取下载进度
// 返回值 ,正常:0-100 错误:负值
int im_c_OtherGetDownLoadProgress();

// 断点下载
int im_c_OtherContinueDownLoad();

// 取消下载
int im_c_OtherCancleDownLoad();

#endif

// 反馈
int im_c_Feedback(char *_pcText);

//************************************
// Method:    im_c_FollowUser
// FullName:  im_c_FollowUser	关注
// Access:    public 
// Returns:   int	成功返回0,错误返回-1，已关注返回-2
// Qualifier:
// Parameter: uint16_t _iArea	国际区号
// Parameter: uint64_t _llUser	手机号
//************************************
int im_c_FollowUser(uint16_t _iArea, uint64_t _llUser);

//************************************
// Method:    im_c_UnFollowUser
// FullName:  im_c_UnFollowUser	取消关注
// Access:    public 
// Returns:   int	成功返回0，否则返回-1
// Qualifier:
// Parameter: uint16_t _iArea	国际区号
// Parameter: uint64_t _llUser	手机号
//************************************
int im_c_UnFollowUser(uint16_t _iArea, uint64_t _llUser);

//************************************
// Method:    c_GetFansList
// FullName:  c_GetFansList	获取粉丝列表
// Access:    public 
// Returns:   int	成功返回JSON，否则返回-1
// Qualifier:
// Parameter: uint16_t _iArea	国际区号
// Parameter: uint64_t _llUser	手机号
// Parameter: int32_t _nLastId	json中会返回一个id值，分页的时候，需要提交上次最后一个ID，第一页的时候是0
//************************************
int c_GetFansList(uint16_t _iArea, uint64_t _llUser,int32_t _nLastId);

//************************************
// Method:    c_GetFollowList	
// FullName:  c_GetFollowList	获取关注列表
// Access:    public 
// Returns:   int	成功返回JSON，否则返回-1
// Qualifier:
// Parameter: uint16_t _iArea	国际区号
// Parameter: uint64_t _llUser	手机号
// Parameter: int32_t _nLastId	json中会返回一个id值，分页的时候，需要提交上次最后一个ID，第一页的时候是0
//************************************
int c_GetFollowList(uint16_t _iArea, uint64_t _llUser,int32_t _nLastId);


//************************************
// Method:    im_c_GetMyFriends
// FullName:  im_c_GetMyFriends	获取我的好友列表
// Access:    public 
// Returns:   int
// Qualifier:
// Parameter: int32_t _nLastId	json中会返回一个id值，分页的时候，需要提交上次最后一个ID，第一页的时候是0
//************************************
int im_c_GetMyFriends(int32_t _nLastId);


//************************************
// Method:    c_SendIWant
// FullName:  c_SendIWant	发送请求（鹰眼）
// Access:    public 
// Returns:   int
// Qualifier:
// Parameter: float _beginLongitude	开始经度
// Parameter: float _beginLatitude	开始纬度
// Parameter: float _endLongitude	结束经度
// Parameter: float _endLatitude	结束纬度
// Parameter: char * _pcAddrInfo	用户所在地址 
// Parameter: char * _pcCountryInfo	用户所在国家 
// Parameter: char * _pcMsg			请求内容	35汉字，70个字母 我的数组最大450
// Parameter: int32_t _nLocalId		客户端需要的ID，服务器会直接返回
//************************************
int c_SendIWant(float _beginLongitude, float _beginLatitude,float _endLongitude, float _endLatitude,char* _pcAddrInfo,char* _pcCountryInfo,char* _pcMsg,int32_t _nLocalId);


//************************************
// Method:    im_c_SendVideo
// FullName:  im_c_SendVideo	发布视频
// Access:    public 
// Returns:   int
// Qualifier:
// Parameter: char * _pcVideoPath	视频路径
// Parameter: float _J				经度
// Parameter: float _W				纬度
// Parameter: char * _pcAddrInfo	地理位置信息
// Parameter: char * _pcMsg			用户填写的视频信息
// Parameter: int64_t _nIWantMsgId	如果是回复别的用户的千里眼请求的话，这个需要填上千里眼的id
// Parameter: int32_t _nLocalId		客户端需要的ID，服务器会直接返回
//************************************
int im_c_SendVideo(char* _pcVideoPath, float _J, float _W,char* _pcAddrInfo,char* _pcMsg,int64_t _nIWantMsgId,int32_t _nLocalId);


//************************************
// Method:    c_GetRangeUserNum
// FullName:  c_GetRangeUserNum	获取范围内的用户数
// Access:    public 
// Returns:   int
// Qualifier:
// Parameter: float _beginLongitude	开始经度
// Parameter: float _beginLatitude	开始纬度
// Parameter: float _endLongitude	结束经度
// Parameter: float _endLatitude	结束纬度
//************************************
int c_GetRangeUserNum(float _beginLongitude, float _beginLatitude,float _endLongitude, float _endLatitude);


//************************************
// Method:    c_GetRangeVideoLst
// FullName:  c_GetRangeVideoLst	获取范围内的视频列表
// Access:    public 
// Returns:   int
// Qualifier:
// Parameter: float _beginLongitude	开始经度
// Parameter: float _beginLatitude	开始纬度
// Parameter: float _endLongitude	结束经度
// Parameter: float _endLatitude	结束纬度
// Parameter: int32_t _nLastId	json中会返回一个id值，分页的时候，需要提交上次最后一个ID，第一页的时候是0
//************************************
int c_GetRangeVideoLst(float _beginLongitude, float _beginLatitude,float _endLongitude, float _endLatitude,int64_t _nLastId);


//************************************
// Method:    im_c_GetVideoLst
// FullName:  im_c_GetVideoLst	分页获取某人的视频列表
// Access:    public 
// Returns:   int
// Qualifier:
// Parameter: uint16_t _iArea	国际区号
// Parameter: uint64_t _llUser	手机号
// Parameter: int64_t _nLastId	json中会返回一个id值，分页的时候，需要提交上次最后一个ID，第一页的时候是0
//************************************
int im_c_GetVideoLst(uint16_t _iArea, uint64_t _llUser,int64_t _nLastId);


//************************************
// Method:    c_UpdateVideoLike
// FullName:  c_UpdateVideoLike	视频点赞
// Access:    public 
// Returns:   int	成功返回0 ，否则返回-1
// Qualifier:
// Parameter: int64_t _llVideoId	视频id
//************************************
int c_UpdateVideoLike(int64_t _llVideoId);

//************************************
// Method:    c_UpdateVideoComment
// FullName:  c_UpdateVideoComment	视频评论
// Access:    public 
// Returns:   int	成功返回0，否则返回-1
// Qualifier:
// Parameter: int64_t _llVideoId	视频id
// Parameter: char * _pcComment		评论内容
// Parameter: int _nLocalId			客户端需要的ID，服务器会直接返回
//************************************
int c_UpdateVideoComment(int64_t _llVideoId,char* _pcComment,int _nLocalId);


//************************************
// Method:    im_c_GetUserInfoCount
// FullName:  im_c_GetUserInfoCount	用户信息中的，视频数量，好友、关注、粉丝的总数及新增数
// Access:    public 
// Returns:   int
// Qualifier:
//************************************
int im_c_GetUserInfoCount();


/** @brief    设置当前程序是否后台运行中
  * @param[in]  _iBackground 0 非后台，1后台
  */
void c_SetBackground(int _iBackground);


/** @brief    删除视频
  * @param[in]  _llVideoId  视频id
  */
int im_c_DelUserVideo(int64_t _llVideoId);


/** @brief    点击浏览视频
  * @param[in]  _llVideoId  视频id
  */
int im_c_ClickUserVideo(int64_t  _llVideoId);

/** @brief    分享一次视频
  * @param[in]  _llVideoId  视频id
  */
int im_c_ShareUserVideo(int64_t  _llVideoId);

//************************************
// Method:    im_c_UpdatePushCounter
// FullName:  im_c_UpdatePushCounter	设置推送时的数值
// Access:    public 
// Returns:   int
// Qualifier:
// Parameter: int32_t _nCounter	推送显示的起始数据，不能小于0
//************************************
int im_c_UpdatePushCounter(int32_t _nCounter);

//************************************
// Method:    im_c_AddContact
// FullName:  im_c_AddContact	上传通讯录
// Access:    public 
// Returns:   int
// Qualifier:
// Parameter: char * _pcPhoneList	手机号列表，多个手机号用*隔开,需要带上国际区号
//************************************
int im_c_AddContact(char *_pcPhoneList);

/** @brief    新建群
  * @param[in]  GroupName    群名称,十六进制字符串
  * @param[in]  _pcTag   	 群说明,十六进制字符串
  * @param[in]  _pcUserID    用户列表，可以多个，逗号分隔，需要加区号 ：8613459259875,8613459259876,8613459259877
  * @retrun 	正常返回群号，错误返回-1
  */
int  im_c_CreateGroup(char *_pcGroupName,char *_pcTag,char *_pcUserID);

/** @brief    添加群组成员
  * @param[in]  	_nGroupid    群id号
  * @param[in]	_llUserID	    用户列表，可以多个，逗号分隔，需要加区号 ：8613459259875,8613459259876,8613459259877
  * @retrun   正常返回0，错误返回-1
  */
int im_c_Add_GroupMembers(uint64_t _llGroupid,char *_pcUserID);

/** @brief    删除群
  * @param[in]  _nGroupid    群id
  * @retrun   正常返回0，错误返回-1，该群不存在返回-3,不是群创建者返回-4
  */
int im_c_Delete_Group(uint64_t _llGroupid);

/** @brief    获取群组成员列表
  * @param[in]  _nGroupid   群id
  * @param[in]  _nLastId    最后一条记录的ID
  * @retrun   正常返回JSON，错误返回-1
  */
int im_c_Get_GroupMember_List(uint64_t _llGroupid,uint64_t _llLastId);

/** @brief    发送群消息
  * @param[in]  _iIndex 从im_c_GetIndexLongLong() 返回的值
  * @param[in]  _iSrcArea	发送手机区号
  * @param[in]  _llSrcUser	发送者手机号
  * @param[in]  _llGroupid  群组Id
  * @param[in]  _iDataType  数据类型
  * @param[in]  _pcData     数据
  * @param[in]  _iDataLen   数据长度
  * @param[in]  _iAdditional    附加信息，对于阅后即焚，表示时间,对于声音，表示声音长度
  * @return  返回0-255表示发送序号，发送成功，错误返回其他值
  */
int im_c_SendGroupMsg(int64_t  _iIndex, uint16_t _iSrcArea, uint64_t _llSrcUser, uint64_t _llGroupid, int16_t _iDataType, char *_pcData, uint32_t _iDataLen, int16_t _iAdditional);

/** @brief    成员退群
  * @param[in]  _llGroupid  群组Id
  * @retrun   正常返回0，错误返回-1
  */
int im_c_Exit_Group(uint64_t _llGroupid);

/** @brief	  获取我的群列表
  * @retrun   正常返回JSON，错误返回-1
  */
int im_c_Get_MyGroup_List();

/** @brief    群主删除某人
  * @param[in]  _llGroupid  群组Id
  * @param[in]  _iArea	发送手机区号
  * @param[in]  _llUserId   被删除的用户ID
  * @retrun   正常返回0，错误返回-1,操作者不是群创建者返回-3,被删除者不在该群返回-4
  */
int im_c_DelGroupMember(uint64_t _llGroupid, uint16_t _iArea,uint64_t _llUserId);


//************************************
// Method:    im_c_DriverQuotedPrice
// FullName:  im_c_DriverQuotedPrice	司机报价接口
// Access:    public 
// Returns:   int
// Qualifier:
// Parameter: char * _pcProvince	省份名称，最长50个字符
// Parameter: char * _pcCity	市名称，最长50个字符
// Parameter: char * _pcRegion	区名称，最长50个字符
// Parameter: uint32_t _iPrice	报价，正整形，个位是分，十位是角，百位是元，就是乘以100了
//************************************
int  im_c_DriverQuotedPrice(char *_pcProvince,char *_pcCity,char *_pcRegion,uint32_t _iPrice);

//************************************
// Method:    im_c_DelQuotedPrice
// FullName:  im_c_DelQuotedPrice	删除报价
// Access:    public 
// Returns:   int
// Qualifier:
// Parameter: uint64_t _idQuotedPrice	报价表中的ID
//************************************
int  im_c_DelQuotedPrice(uint64_t _idQuotedPrice);


//************************************
// Method:    im_c_GetUsrDFCInfo
// FullName:  im_c_GetUsrDFCInfo	获取大丰车相关的用户信息，现在有，位置，坐标，报价（司机才有）
// Access:    public 
// Returns:   int
// Qualifier:
// Parameter: uint16_t _iArea	区号
// Parameter: uint64_t _llUser	手机号
//************************************
int im_c_GetUsrDFCInfo(uint16_t _iArea, uint64_t _llUser);

///////////////////////////////下面的是旧方法,最好别用，会出问题的///////////////////////////////////////////

// 获取好友列表
//_iFriendType 好友列表数据:  临时好友 -1, 关注 0,被关注-10, 删除 1,拉黑 2
// 成功返回0，错误返回负值
int im_c_GetFriendList(int _iFriendType);

// 更新好友备注
int im_c_UpdateFriendTag(long long _llUserId, char *_pcTag);

// 查找好友
// _llUser 查找的用户ID ，_llUser<=0 表示不搜索
// _pcNickName 昵称 ，为空表示不搜索
// 成功返回0，错误返回负值
int im_c_Find(long long _llUser, char *_pcNickName);

/** @brief    设置当前账号的主账号
  * @param[in]  _llRelationUser	主账号ID ，0的时候表示删除主账号
  */
int im_c_UpdateRelationid(long long _llRelationUser);


// 查看个人详细信息
// 成功返回0，错误返回负值
int im_c_Is_Register_SC(char *_pcDeviceKey);


/** @brief    消息查看状态
  * @param[in]  _iIndex 消息唯一码
  * @param[in]  _llUser 接收消息的用户
  * @param[in]  _pcData 状态码，int转string
  * @param[in]  _iDataLen   消息长度
  */
int im_c_MsgCheckState(int64_t _iIndex, uint16_t _iArea, uint64_t _llUser, char *_pcData, uint32_t _iDataLen);




#if 0
/** @brief    上传一个文件
  * @param[in]  _uFileName  发送文件名，以时间秒数命名
  * @param[in]  _iFileType  文件类型
                            IM_DATA_TYPE_TEXT 			= 0, 	// 文字
                            IM_DATA_TYPE_JS 			= 1, 	// js脚本
                            IM_DATA_TYPE_AMR			= 2, 	// 声音
                            IM_DATA_TYPE_PICTURE		= 3,	// 图片
  * @param[in]  _pcData 要传送的文件内容
  * @param[in]  _iDataLen   文件内容长度
  * @return  成功返回0，错误返回负值
  */
int im_c_UpLoad(int _uFileName, int _iFileType, char *_pcData, int _iDataLen);

/** @brief    获取发送进度
  * @return  正常:0-100 错误:负值
  */
int im_c_GetUpLoadProgress();

/** @brief    断点上传
  */
int im_c_ContinueUpLoad();

/** @brief    取消上传
  */
int im_c_CancleUpLoad();

// 下载一个文件
// _pcUrl 文件地址
// 成功返回0，错误返回负值
int im_c_DownLoad(char *_pcUrl);

// 获取下载进度
// 返回值 ,正常:0-100 错误:负值
int im_c_GetDownLoadProgress();

// 断点下载
int im_c_ContinueDownLoad();

// 取消下载
int im_c_CancleDownLoad();

#endif

// 获取雷库信息
// 成功返回0，错误返回负值
int im_c_GetLibMines();

// 放置普通雷
// int _iTime
/*
0	01:01--07:00
1	07:01--08:00
2	08:01--10:00
3	10:01--12:00
4	12:01--13:00
5	13:01--15:00
6	15:01--17:00
7	17:01--19:00
8	19:01--21:00
9	21:01--23:00
10	23:01--01:00
*/
// _pcIndex 雷ID
// _J 经度
// _W纬度
// _iSex 性别1男2女0不限制
// _pcText 附带文本
// 成功返回0-255，错误返回负值
int im_c_SetOrdinaryMines(int _iTime, char *_pcIndex, float _J, float _W, int _iSex, char *_pcText,
	int _iBombLevel);

// 放置好友雷
// int _iTime
/*
0	01:01--07:00
1	07:01--08:00
2	08:01--10:00
3	10:01--12:00
4	12:01--13:00
5	13:01--15:00
6	15:01--17:00
7	17:01--19:00
8	19:01--21:00
9	21:01--23:00
10	23:01--01:00
*/

// 获取我放置的雷的信息
// _iType 0当前有效的，1一天之内的
// 成功返回0，错误返回负值
int im_c_SetMines(int _iType);

//查看八张图片的相册
//兼容获得自己相册接口
int Im_c_GetAlbumList(long long _llUserId);

//增加图片到八张图相册
int im_c_AlbumAdd(char *_pcPicture);
//从八张图相册删除
int im_c_AlbumDel(char * _pcPicture);

//static int im_c_DoAlbum(char *_pcPicture, int _iFun);


// 请求个人相册
int im_c_GetPhoto();

// 个人相册增加图片
// _pcPicture 图片url，多张图片用*隔开
int im_c_AddPhoto(char *_pcPicture);

// 个人相册删除图片
// _pcPicture 图片url，多张图片用*隔开
int im_c_DelPhoto(char *_pcPicture);


/** @brief   获得区域内所有的雷，区域内24小时内、最新、最热视频和区域内事件及视频列表
  * @param[in]  _StartJ 起点的经度
  * @param[in]  _StartW 起点的纬度
  * @param[in]  _StopJ 终点的经度
  * @param[in] _StopW 终点的纬度
  * @param[in] _nType 用位区分获项目内容	
  	GET_AREA_MINES				= 0x1,		// 获取区域内小雷人
	GET_AREA_VIDEO_ALL				= 0x2,		// 获取区域内24小时内视频
	GET_AREA_VIDEO_LATEST			= 0x4,		// 获取区域最新视频
	GET_AREA_VIDEO_HOTTEST			= 0x8,		// 获取区域最热视频
	GET_AREA_EVENT				= 0x10,		// 获取区域事件列表
	同时获取多个数据 用 | 结合
  */

int im_c_GetAreaMines(float _StartJ, float _StartW, float _StopJ, float _StopW,int _nType);


// 判断好友雷距离爆炸的距离
// _StartJ 被放置雷时的经度
// _StartW 被放置雷时的纬度
// _NowJ 当前经度
// _NowW 当前纬度
// 返回:单位:米
int im_c_JudgeMinesLen(float _StartJ, float _StartW, float _NowJ, float _NowW);

// 判断好友雷的方向
// _StartJ 被放置雷时的经度
// _StartW 被放置雷时的纬度
// _NowJ 当前经度
// _NowW 当前纬度
// 返回:方向，同放置雷的方向0-4
int im_c_JudgeMinesDirection(float _StartJ, float _StartW, float _NowJ, float _NowW);

// 设置被炸使能开关
// _iEnable 1允许被炸0不允许 , 在return里面返回，-1 设置失败， 0 设置关闭 1 设置开启
int im_c_SetDoMinesEnable(int _iEnable);

// 获取允许被炸的状态, 在return里面返回，-1 设置失败， 0 设置关闭 1 设置开启
int im_c_GetDoMinesEnable();

//int im_c_SetDir(char *_pcDir);

// 发送文件
// _pcDir 文件路径名
int im_c_SendFile(char *_pcDir);

// 根据坐标查询所在学校
// 返回值:json
//int im_c_GetSchoolByCoordinate(float _J, float _W);

// 校验学校，
// _iSchoolId 要校验的学校Id,在返回的json中获得
// 返回值:state回调
//int im_c_CheckSchool(int _iSchoolId);

// 增加未开通学校的计数
// _iSchoolId 要校验的学校Id,在返回的json中获得
//int im_c_AddSchoolCount(int _iSchoolId);

// 请求雷的明细
// _iIndex 若为0，请求最新的20条，若不为零，则请求这个之后的20条
int im_c_GetMinesRecord(int _iIndex);

/** @brief    设置被炸级别
  * @param[in]  _iBeomLevel	级别，大于0的时候是设置，0 的时候是获取
  * @return  设置的时候，通过FImReturnFun返回，获取的时候，通过FImStateFun返回，key:IM_STATE_RE_BOMB_LEVEL
  */
int im_c_BeBombLevel(int _iBeomLevel);




/** @brief    生成微信预支付订单
  * @param[in]  _pcOrderInfo    订单需要的json:{"school_id":"1","party_id":"1","total_num":"2","product_id_1":"1","product_id_num_1":"10","product_id_2":"2","product_id_num_2":"25"}
  */
int im_c_WxCreateOrder(char *_pcOrderInfo);

//举报用户
int im_c_ReportUser(long long _llUserId,int iReasonIndex, char *_pcReport);

//上传心情图片，图片已在客户端处理好，id直接获取，时间戳服务器打，只传url
int c_UpdateUserFeeling(char * _pcData);
//按类型点赞
int c_UpdateUserFeelingPraise(long long _llUser,int _iPraiseType);

//查询所有好友的心情，和自己的，包括赞自己的人
int c_GetFeelingList();
/** @brief    获取产品列表
  */
int c_GetProductList();
#if 0
/** @brief    获取我的零食列表
  * @param[in]  _iLastGiftId    0:获取最新的列表 大于0:上次获取的最后一个id值，用来分页
  */
int c_GetGiftList(int _iLastGiftId);
/** @brief    获取狂欢活动的总信息
  */
int c_GetPartyInfo();
/** @brief    获取狂欢活动的学校购买信息
  */
int c_GetPartyBuySchool();
/** @brief    获取狂欢活动的我购买信息
  */
int c_GetPartyBuyMy();

/** @brief    获取对应性别的所有地址
  */
int c_GetAddressAll();

/** @brief    获取我的地址
  */
int c_GetAddressMy();
#endif
/** @brief    抢零食
  * @param[in]  _iPartyId    当前活动的id
  */
int c_GetPartyGrabSnacks(int _iPartyId);
/** @brief    抢零食活动报名
  * @param[in]  _iPartyId    当前活动的id
  */
int c_GetPartyJoin(int _iPartyId);
/** @brief    抢零食活动最新消息，20条
  * @param[in]  _iPartyId    当前活动的id
  * @param[in]  _iSchoolId    当前活动的学校id
  */
int c_GetPartyGrabMsg(int _iPartyId,int _iSchoolId);


/** @brief    生成动支付宝支付订单
  * @param[in]  _pcOrderInfo    订单需要的json:{"recver_id":"1","party_id":"1","total_num":"2","product_id_1":"1","product_id_num_1":"10","product_id_2":"2","product_id_num_2":"25"}
  */
int im_c_AlipayCreateOrder(char *_pcOrderInfo);



/** @brief    查询单个好友的所有心情
  * @param[in]  _llFriendId 好友Id
  * @param[in]  _iFeelingId 0:第一页，大于0的时候，填最后一个feeling id
  */
int c_GetOneFeelingList(long long _llFriendId, int _iFeelingId);


//获得热点区域，暂时是学校
//返回八个学校和对应坐标
int c_GetHotAreaList();


/******************************图片广场功能(ING)***********************************/

//返回所有开通ING的学校
//JSON拼接返回，包括学校的id、名称、坐标范围，顺便返回用户自己的归属学校ID(用户身份)
int c_GetSchoolListWithING();
//发布ING
//前端根据用户归属学校ID(用户身份)与用户所处学校ID(坐标范围判定)决定用户发布权限,调用接口
//参数:图片、文字、目标广场(学校)ID、校外可见使能,剩余时间
int c_UpdateING(char* _pcPicUrl, char* _pcDescription, char* _pcTags, int _iSchoolId, 
	int _iOpenEnable, int _iMinutes, int _iIndex, char* _pcPosInfo);

//通过学校id获取该学校ING列表,
//第二个参数:是否显示隐藏图片
//前端根据用户归属学校ID(用户身份)与用户所处学校ID(坐标范围判定)决定第二参数是1是0
//第三个参数，分页起始点,假设10个一页,1代表第一页，11代表第2页，
int c_GetINGContentList(int _iSchoolId, int _iOpenEnable, long long _llPageStartContentId);
//针对内容Id进行"喜欢"统计
int c_UpdateINGLike(long long _llContentId);
//评论:没有楼中楼，但有谁回复谁
//评论人是自己，服务器获取，目标用户要有，评论内容要有,针对的内容id要有
int c_UpdateINGComment(long long _llContentId, long long _llDstUserId,char* _pcComment,int _iIndex);
//获取评论列表
//分页

int c_GetINGCommentWithContentId(long long _llContentId, long long _llPageStartCommentIndex);
//通知、发起的ing，参与的ing，三个外部接口，分页传json
/*
int c_GetINGListNotice(long long _llPageStartIndex);
int c_GetINGListMyPublish(long long _llPageStartIndex);
int c_GetINGListMyParticipate(long long _llPageStartIndex);
*/
/** @brief    获取学校ing的总贴和新帖数
  */
int c_GetINGCount(int _iSchoolId);
/** @brief    更新学校ing查看时间
  */
int c_UpdateINGCheckTime(int _iSchoolId);


/** @brief    发布发现
  * @param[in]  _pcPicUrl   图片地址
  * @param[in]  _pcDescription 内容 
  * @param[in]  _fJDu   经度
  * @param[in]  _fWDu   纬度
  * @param[in]  _pcCity 城市
  * @param[in]  _pcAddress 地理位置
  * @param[in]  _iIndex 客户端，发布成功后返回值 
  */
int im_c_UpdateUserFound(char* _pcPicUrl, char* _pcDescription, float _fJDu, float _fWDu, char* _pcCity
    , char* _pcAddress, int _iIndex);

/** @brief    点击发现
  * @param[in]  _iMsgId 发现的id
  */
int im_c_UserFoundBeClick(int _iMsgId);

/** @brief    获取发现列表
  * @param[in]  _pcCity 城市
  * @param[in]  _iSex   性别
  * @param[in]  _iMsgId 发现id,分页用;-1的时候获取按点击次数排序的50条;0的时候，获取最新; 其它获取小于该id分页列表
  */
int im_c_GetUserFoundList(char* _pcCity, int _iSex, int _iMsgId);


/** @brief    检测是否支付成功
  * @param[in]  _iType  送好友是0，送学校是活动的ID
  * @param[in]  _llRecvId   接收都的id, 好友id/学校id
  */
int im_c_CheckPayType(int _iType, long long _llRecvId);

/** @brief    获取我发的全局视频列表
  * @param[in]  _iLastId    分页，最后一个id值
  */
//int im_c_GetMyGlobalVideoList(long long  _llLastId);




/** @brief    获取视频点赞数
  * @param[in]  iGlobalVideoId  视频id
  * @return	成功返回json，否则返回-1
  */
int c_GetVideoLikeCount(long long _llGlobalVideoId);




/** @brief    分页获取视频评论内容
  * @param[in]  iGlobalVideoId  视频id
  * @param[in]  _llPageStartCommentIndex  	上页最后一条评论数
  * @return	成功返回JSON，否则返回-1
  */
int c_GetVideoCommentWithContentId(long long _llGlobalVideoId, long long _llPageStartCommentIndex);

/***********************************************  个人主页及主题视频相关接口 ********************************************************/



/** @brief   获取粉丝与关注总数
  * @param[in]  llUserID  用户id
  * @return	成功返回JSON，否则返回-1
  */
//int c_GetFansCount(long long _llUserId);



/** @brief   创建事件
  * @param[in]  _pcEventName  事件名称，必须唯一，以十六进制上传
  * @param[in]  _J  经度
  * @param[in]  _W  纬度
  * @param[in]  _offset_time  事件结束时间按天偏移
  * @param[in]  _nState  事件的类型，	PUBLIC_EVENT= 0X00	//公有事件PRIVATE_EVENT	= 0x01	//私有事件
  * @param[in]  _pcUserID  当事件为私有时该参数有效，表示事件内成员列表,只有添加进来的成员才有权限往该事件上发送视频,
							每个用户ID之间用,(英文格式,)隔开，例：123,234,234,345,444
  * @return	成功返回事件ID号，失败返回-1，如果该事件已存在返回-3;
  */
int c_CreateEvent(char *_pcEventName,float _J, float _W,int _offset_time,int _nState,char *_pcUserID);


/** @brief    添加事件成员
  * @param[in]  _llEventid    事件id
  * @param[in]  _pcUserID      用户ID字符串，每个用户ID之间用;(英文格式,)隔开，例：123,234,234,345,444
  * @retrun   正常返回0，错误返回-1，该事件不存在返回-5
  */
int im_c_Add_EventMembers(int _nEventid,char *_pcUserID);



/** @brief   获取用户创建的事件列表
  * @param[in]  llUserID  用户id
  * @return	成功返回JSON，否则返回-1
  */
int c_GetUserEvent(long long _llUserId,int _nLastId);


/** @brief   获取事件中指定用户的视频列表,当事件为该用户创建时显示事件内所有视频，事件为用户关联事件时只显示用户发送的视频
  * @param[in]  _nEventId  事件id
  * @param[in]  _lluserId 用户id
  * @return	成功返回JSON，否则返回-1
  */
int c_GetEvent_UserVideo(int _nEventId,long long _lluserId,int _nLastId);

/** @brief   获取事件内的视频列表
  * @param[in]  _nEventId  用户id
  * @param[in]  _StartJ 起点的经度
  * @param[in]  _StartW 起点的纬度
  * @param[in]  _StopJ 终点的经度
  * @param[in] 	_StopW 终点的纬度
  * @return	成功返回JSON，否则返回-1
  */

int c_GetEventVideo(int _nEventId,float _StartJ, float _StartW, float _StopJ, float _StopW);

/** @brief   获取他人的视频列表
  * @param[in]  llUserID  用户id
  * @param[in]  _llLastId  最后一条记录ID
  * @return	成功返回JSON，否则返回-1
  */
int c_GetOthersVideo(long long llUserID,long long _llLastId);

/** @brief   发送视频前获取当前位置附近的事件列表
  * @param[in]  _J  经度
  * @param[in]  _W  纬度
  * @param[in]  _nLastId  最后一条记录ID
  * @return	成功返回JSON，否则返回-1
  */
int c_GetSendEvent(float _J, float _W,int _nLastId);



/** @brief   获取用户是否具有创建事件的权限
  * @return	失败返回-1,成功返回 0= 没有权限，1=有权限
  */
int c_GetUserCreateEvent_rights();


/** @brief   通过位置信息获取当前矩形内的所有司机列表
  * @return	
  */
int im_c_GetDriversByDriver(float _iX1, float _iX2, float _iY1, float _iY2, int _iPageNum, int _iPageSize);

/** @brief   根据指定条件获取大丰车用户列表
  * @return	
  * @_iGetAllCityFlag   0： 获取所有，没有地址限制，不需输入省份和城市信息， 1： 获取指定地址，需输入省份和城市信息
  * @_iSexFlag  -1：所有性别， 0： 保密， 1： 男， 2：女
  * @_iIdentity  1：农民， 2：司机，3：公共账号  //当选择2时，需要输入价格起点和价格终点
  * @_pcProvince  省份信息
  * @_pcCity     城市信息
  * @_iPriceStart  价格起点
  * @_iPriceEnd   价格终点
  * @ _iCurIdx   记录开始位置
  * @ _iPageSize  获取记录条数
  */
int im_c_DfcQueryUsersByLocation(int _iGetAllCityFlag, int _iSexFlag, int _iIdentity, char* _pcProvince = NULL, char* _pcCity = NULL, int _iPriceStart = 0, int _iPriceEnd = 0, int _iCurIdx=0, int _iPageSize=100);

#endif


