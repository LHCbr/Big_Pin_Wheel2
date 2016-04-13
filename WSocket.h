//
//  WSocket.h
//  LuLu
//
//  Created by a on 11/4/15.
//  Copyright © 2015 lbx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InscriptionManager.h"
#import "UploadingModel.h"
#import "DownloadingModel.h"
#import "DFCUserInfo.h"

typedef enum : NSUInteger {
    ConnectStateSuccess = 0,
    ConnectStateConnecting = 1,
    ConnectNoNetwork = 2
} ConnectStatus;

typedef enum : NSUInteger {
    LBX_IM_DATA_TYPE_TEXT = 0,
    LBX_IM_DATA_TYPE_JS,
    LBX_IM_DATA_TYPE_AMR,
    LBX_IM_DATA_TYPE_PICTURE,
    LBX_IM_DATA_TYPE_TXT_AND_PIC,
    LBX_IM_DATA_TYPE_MP4,
    LBX_IM_DATA_TYPE_SYSTEM,
    LBX_IM_DATA_TYPE_TIME
} FileType;

enum MsgChatRefrashType {
    MsgChatRefrashTypePageNoFinish  = 0,    // 分页没结束
    MsgChatRefrashTypePageIsFinish  = 1,    // 分页已结束
    MsgChatRefrashTypeSendSuccess   = 2,    // 发送消息添加
    MsgChatRefrashTypeReciveMsg     = 3,    // 接收消息添加
    MsgChatRefrashTypeNormal        = 4,    // 普通刷新表
    MsgChatRefrashTypeDeleteMsg     = 5,    // 删除聊天消息
    MsgChatRefrashTypeSendFailue    = 6,    // 发送消息失败
    MsgChatRefrashTypeSendVoice     = 7,    // 发送语音
};

@interface WSocket : NSObject

@property (nonatomic, strong)InscriptionManager *lbxManager;               // 工具句柄

@property (assign, nonatomic) int isInitSuccess;                  // socket是否初始化成功
@property (assign, nonatomic) BOOL isLoginOK;                     // 是否登录成功

@property (nonatomic, strong)UploadingModel *uploadingModel;       // 当前上传的url
@property (nonatomic, strong)DownloadingModel *downingModel;       // 当前下载的url

@property (nonatomic, strong)NSMutableArray *messageList;         // 聊天界面的聊天记录
@property (nonatomic, strong)NSMutableArray *nearMessageList;     // 最新了解的界面记录
@property (nonatomic, strong)NSMutableArray *waitMessageList;     // 所有未发送成功的消息

@property (nonatomic, strong) NSOperationQueue *downQueue;        // 下载队列
@property (nonatomic, strong) NSOperationQueue *uploadQueue;      // 上传队列

@property (nonatomic, strong) NSOperationQueue *sendMessageQueue; // 发送消息队列

@property (nonatomic, strong)NSTimer *longTimer;                  // 循环检测所有的东西

@property(strong,nonatomic)DFCUserInfo *dfcUserInfo;

#pragma mark - 这里列出一个所有请求的队列， 这个队列就是为了一步一步的进行操作
/// 请求粉丝的队列请求
@property (nonatomic, strong) NSOperationQueue *getFansQueue;
/// 请求关注的队列请求
@property (nonatomic, strong) NSOperationQueue *getIdolQueue;
/// 请求范围内视频的队列请求
@property (nonatomic, strong) NSOperationQueue *getRangeVideoListQueue;


/// 获取单例
+ (id)sharedWSocket;

/// 连接服务器
- (void)connectToServerAndLogin;

/// 获取随机不一样的id
- (NSString *)getSerialId;

/// 设置程序是否在后台给C调用,防止在后台程序断开链接崩溃
- (void)tellCIsBackground:(int)isBackground;

/// 设置服务器推送消息个数
- (void)updatePushCount:(int)count;

#pragma mark - 显示所有的请求失败处理
/// 显示所有的请求之后的提示
- (void)showAlertWithTag:(int)tag;

#pragma mark - 注册、登陆、重置密码
/// 注册回调
typedef void (^registerBlock)(int success);
@property (nonatomic, copy)registerBlock registerSuccess;
- (void)registing:(NSString *)username passwd:(NSString *)passwd code:(NSString *)code registingBlock:(registerBlock)registerSuccess;

/// 登陆回调
typedef void (^loginBlock)(int success);
@property (nonatomic, copy)loginBlock loginSuccess;
- (void)logining:(NSString *)username password:(NSString *)password isAuto:(BOOL)isAuto loginBlock:(loginBlock)loginSuccess;

/// 退出登陆 如果返回0就是退出执行成功
typedef void (^logOutBlock)(int success);
@property (nonatomic, copy)logOutBlock logOutSuccess;
- (void)logOutIsSuccess:(logOutBlock)logOutSuccess;

/// 重置密码前的验证码的确认
typedef void (^resetPswCheckCodeBlock)(int success);
@property (nonatomic, copy)resetPswCheckCodeBlock resetPswCheckCodeSuccess;
- (void)resetPswCheckCodeWithPhone:(NSString *)phone code:(NSString *)code checkCodeBlock:(resetPswCheckCodeBlock)resetPswCheckCodeSuccess;

/// 重置密码
typedef void (^resetPswBlock)(int success);
@property (nonatomic, copy)resetPswBlock resetPswSuccess;
- (void)resetPswWithPhone:(NSString *)phone withPsw:(NSString *)psw withCode:(NSString *)code resetPswBlock:(resetPswBlock)resetPswSuccess;

/// 上传token
- (void)registerDeviceToken:(NSData *)token;

#pragma mark - 联系人相关(添加，删除，关注)
/// 我删除最新消息的对话框,不删除聊天记录
- (void)deleteNearMessageWithPhone:(NSString *)phone;

/// 我删除好友/好友删除我， 删除聊天对话框，删除聊天记录， 删除好友列表，暂时不删除这个人的资料
- (void)deleteFriend:(NSString *)phone;

/// 获取好友列表，暂时无用，只是封装一下搁在这里 (如果需要好友列表分页才需要这个接口)
- (int)getFriendListWithLastId:(NSString *)lastId;

/// 获取粉丝列表
typedef void (^getFansListBlock)(int ret, NSDictionary *rootDict);
@property (nonatomic, copy)getFansListBlock getFansListSuccess;
- (void)getFansListWithPhone:(NSString *)phone area:(NSString *)area lastId:(NSString *)lastId success:(getFansListBlock)getFansListSuccess;

/// 获取关注列表
typedef void (^getIdolListBlock)(int ret, NSDictionary *rootDict);
@property (nonatomic, copy)getIdolListBlock getIdolListSuccess;
- (void)getIdolListWithPhone:(NSString *)phone area:(NSString *)area lastId:(NSString *)lastId success:(getIdolListBlock)getIdolListSuccess;

/// 请求添加好友 返回值为0，本地执行成功
- (int)AddFriendWithPhone:(NSString *)phone requestText:(NSString *)text;

/// 回复添加好友 返回值为0，本地执行成功  1 同意， 0 拒绝
- (int)ReAddFriendWithPhone:(NSString *)phone isAccept:(int)isAccept;

/// 删除好友
- (int)DeleteFriendWithPhone:(NSString *)phone;

/// 强制添加好友
- (int)addFriend_Force:(NSString *)phone;

/// 检查用户是不是好友
- (int)addContact:(NSString *)phoneList;

/// 关注
typedef void (^followUserBlock)(int success);
@property (nonatomic, copy)followUserBlock followUserSuccess;
- (void)followUser:(NSString *)phone success:(followUserBlock)followUserSuccess;

/// 取消关注
typedef void (^unFollowUserBlock)(int success);
@property (nonatomic, copy)unFollowUserBlock unFollowUserSuccess;
- (void)unFollowUser:(NSString *)phone success:(unFollowUserBlock)unFollowUserSuccess;

/// 获得通讯录好友
- (NSMutableDictionary *)getAddressBook;

/// 排序
- (NSMutableArray *)sortAddressBook:(NSMutableDictionary *)friendsList;

/// 模糊搜索
- (NSMutableArray *)fuzzySearchFriends:(NSString *)keywords;

#pragma mark - 个人资料相关
/// 更新用户个人资料
typedef void (^updateUserInfoBlock)(int success);
@property (nonatomic, copy)updateUserInfoBlock updateUserInfoSuccess;
- (void)updateUserInfo:(NSDictionary *)info updateUserInfoBlock:(updateUserInfoBlock)updateUserInfoSuccess;

/// 获取某一个用户的详细信息
typedef void (^getUserInfoBlock)(int ret, WJID *uJid);
@property (nonatomic, copy)getUserInfoBlock getUserInfoSuccess;
- (void)getUserInfo:(NSString *)phone getUserInfoBlock:(getUserInfoBlock)getUserInfoSuccess;

///获取大风车相关用户资料
typedef void (^getUserDFCInfoBlock)(int ret,DFCUserInfo *DFCInfo);
@property (copy,nonatomic)getUserDFCInfoBlock getUserDFCInfoSuccess;
-(void)getUserDFCInfoBlock:(NSString *)phone getUserDFCInfoBlock:(getUserDFCInfoBlock)getUserDFCInfoSuccess;

///司机报价接口
typedef void(^driverQuotedPriceBlock)(int success);
@property (copy,nonatomic)driverQuotedPriceBlock driverQuotedPriceSuccess;
-(void)updateDriverQuotedPriceWithProvince:(NSString *)province City:(NSString *)city Region:(NSString *)region Price:(NSString *)price driverQuotedPriceBlock:(driverQuotedPriceBlock)driverQuotedPriceSuccess;

///司机删除报价接口
typedef void(^DelQuotedPriceBlock)(int success);
@property (copy,nonatomic)DelQuotedPriceBlock DelQuotedPriceSuccess;
-(void)DelQuotedPriceWithId:(NSString *)idQuotedPrice DelQuotedPriceBlock:(DelQuotedPriceBlock)delQuotedPriceSuccess;


/*通过手动上传经纬度或者城市选项获取附近的人*/
typedef void(^GetNearByUsersBlock)(int ret,NSDictionary *rootDict);
@property(copy,nonatomic)GetNearByUsersBlock GetNearByUserSuccess;
-(void)GetNearByUsersIsCoordinate:(BOOL)isCoordinate Longitude:(float)longitude Latitude:(float)latitude Identity:(int)identity Province:(NSString *)province City:(NSString *)city PageSize:(int)pageSize GetNearByUsersBlock:(GetNearByUsersBlock) GetNearByUserSuccess;

/*获取当前矩阵范围内的所有司机列表*/
typedef void(^GetRangeDriversBlock)(int ret ,NSDictionary *rootDict);
@property(copy,nonatomic)GetRangeDriversBlock GetRangeDriverSuccess;
-(void)GetRangeDriverStartLongitude:(float)longitude0 StartLatitude:(float)latitude0 EndLongitude:(float)longitude1  EndLatitude:(float)latitude1 pageSize:(int)pageSize GetRangeDriversBlock:(GetRangeDriversBlock) GetRangeDriverSuccess;

#pragma mark - 发送消息相关
/// 收到消息
- (void)receiveMessagePhone:(NSString *)phone
                       area:(NSString *)area
                           time:(NSString *)time
                           type:(int)type
                     hexMessage:(NSString *)pcData
                    destoryTime:(int)destoryTime
                     voice_time:(int)voice_time
                        isSound:(BOOL)isSound
                       serialId:(NSString *)serialId
                       nickname:(NSString *)nickname
                      groupUser:(NSString *)groupUser;

/// 再次发送语音
- (void)resendAudio:(ChatObject *)object isAddWaitMessage:(BOOL)isAdd isAddRemind:(BOOL)isAddRemind;

/// 再次发送图片
- (void)resendImage:(ChatObject *)object isAddWaitMessage:(BOOL)isAdd isAddRemind:(BOOL)isAddRemind;

/// 再次发送文字
- (void)resendText:(ChatObject *)object isAddWaitMessage:(BOOL)isAdd isAddRemind:(BOOL)isAddRemind;

/// 发送图片
- (void)sendImage:(UIImage *)image
      foreignUser:(NSString *)foreignUser
             area:(NSString *)area
      messageType:(int)messageType
          message:(NSString *)message
      destoryTime:(int)destoryTime
      serialIndex:(NSString *)serialIndex;

/// 发送语音
- (void)sendAudioWithChatObject:(ChatObject *)object
      wavFilePath:(NSString *)wavFilePath
          wavName:(NSString *)wavName
      amrFilePath:(NSString *)amrFilePath
        timeObject:(ChatObject *)timeObject;

/// 发送文字消息
- (void)sendText:(NSString *)text
     foreignUser:(NSString *)foreignUser
            area:(NSString *)area
     messageType:(int)messageType
     destoryTime:(int)destoryTime
     serialIndex:(NSString *)serialIndex;

/// 发送消息
- (void)sendMessageWithChatObject:(ChatObject *)object;

/// 添加messageView的消息
- (void)addRemindWithNearObject:(NearMessageObject *)nearObject;

/// 保存最近消息
- (void)saveNearMessageWithObject:(NearMessageObject *)nearObject;

#pragma mark - 上传相关
/// 上传文件， 这里是上传文件成功后，回调到当前任务的block（全局唯一），然后在当前任务的block中，再次回调每个任务自带的block(针对不同的界面刷新)
typedef void (^upLoadFileToServer)(int ret, NSString *fileName, NSString *fileUrl);
@property (nonatomic, copy)upLoadFileToServer upLoadFileToServerSuccess;
- (void)startUpLoadFileToServer:(NSData *)data withFileName:(NSString *)fileName withFileType:(int)type success:(upLoadFileToServer)upLoadFileToServerSuccess;

/// 上传文件  这里只是把文件加入上传队列
typedef void (^upLoadFileBlock)(int ret, NSString *fileName, NSString *fileUrl);
@property (nonatomic, copy)upLoadFileBlock upLoadFileSuccess;
- (void)addUploadFileOperationWithFilePath:(NSString *)filePath
                                      data:(NSData *)fileData
                                isFilePath:(BOOL)isFilePath
                                  fileType:(FileType)type
                                  fileName:(NSString *)fileName
                                  serialId:(NSString *)serialId
                                 modelType:(ModelType)modelType
                                      info:(id)info
                               uploadBlock:(upLoadFileBlock)upLoadFileSuccess;

/// 获取上传进度
- (int)getUploadFileProgress;

/// 取消上传
- (void)cancelUploadFile;

/// 当前上传的模型
- (UploadingModel *)getUploadingModel;

#pragma mark - 下载相关
/// 下载文件， 这里是下载文件成功后，回调到当前任务的block（全局唯一），然后在当前任务的block中，再次回调每个任务自带的block(针对不同的界面刷新)
typedef void (^downLoadFileFromServer)(int ret, NSData *data, NSString *fileUrl);
@property (nonatomic, copy)downLoadFileFromServer downLoadFileFromServerSuccess;
- (void)startDownLoadFileFromServer:(NSString *)url success:(downLoadFileFromServer)downLoadFileFromServerSuccess;

/// 下载文件 这里只是把文件加入下载队列
typedef void (^downLoadBlock)(int ret, int isSave, NSData *data, NSString *fileUrl);
@property (nonatomic, copy)downLoadBlock downFileSuccess;
- (void)addDownFileOperationWithFileUrlString:(NSString *)fileUrl
                                     serialId:(NSString *)serialId
                                    modelType:(ModelType)modelType
                                         info:(id)info
                                    downBlock:(downLoadBlock)downFileSuccess;

/// 获取下载进度
- (int)getDownloadFileProgress;

/// 取消下载
- (void)cancelDownloadFile;

/// 当前下载的模型
- (DownloadingModel *)getDowningModel;

#pragma mark - 地图相关
/// 上传个人位置
- (void)reportLocation:(CLLocationCoordinate2D)coor;


#pragma mark - 反馈系统
/// 反馈问题到服务器
- (int)reportFeedback:(NSString *)text;

#pragma mark - 群
/// 群的block
typedef void (^createNewGroupIsSuc)(int groupId);
typedef void (^deleteGroupIsSuc)(int ret);
typedef void (^addFriendMem)(int ret);
typedef void (^exitGro)(int ret);

/// 创建group（基本实现）
@property (nonatomic,strong)createNewGroupIsSuc createGroupIsSuccess;
- (void)createNewGroupWithGroupName:(NSString *)groupName groupDesc:(NSString *)groupDesc memberList:(NSString *)memberList isSuccess:(createNewGroupIsSuc)isSuccess;

/// 删除group
@property (nonatomic, strong)deleteGroupIsSuc deleteGroupIsSuccess;
- (void)deleteGroupWithGroupId:(NSString *)groupId isSuccess:(deleteGroupIsSuc)isSuccess;

/// 添加群组成员（简单实现，没有逻辑呢）
@property (nonatomic, strong)addFriendMem addFriendMember;
- (void)addFriendMemberWithGroupId:(NSString *)groupId memberId:(NSString *)users  isSuccess:(addFriendMem)isSuccess;

/// 退群
@property (nonatomic, strong)exitGro exitGroup;
- (void)exitGroupWithGroupId:(NSString *)groupId isSuccess:(exitGro)isSuccess;

/// 删除群里的某个人
@property (nonatomic, strong)exitGro removeGroup;
- (void)removeOneMember:(NSString *)member fromGroupId:(NSString *)groupId isSuccess:(exitGro)isSuccess;

/// 获取我的群列表(参照telegram没有必要)
- (void)getMyGroupList;

/// 获取群里的成员列表 (ok)
- (void)getGroupMemberList:(NSString *)groupId lastId:(NSString *)lastId;


@end
