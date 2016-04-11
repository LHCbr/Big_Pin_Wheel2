//
//  WSocket.m
//  LuLu
//
//  Created by a on 11/4/15.
//  Copyright © 2015 lbx. All rights reserved.
//

#import "WSocket.h"
#import <CommonCrypto/CommonDigest.h>
#import <netdb.h>
#import <arpa/inet.h>
#import "InscriptionManager.h"
#import "im_client.h"
#import "UploadingModel.h"
#import "DownloadingModel.h"
#import "GetModel.h"
#import "SendMessageModel.h"
#import "VoiceConverter.h"
#import "PlaySystemSound.h"

@interface WSocket()

@property (nonatomic, copy)NSString *deviceToken;                  // 推送的token

@property (nonatomic, strong)GetModel *getFansModel;               // 请求粉丝的当前Model
@property (nonatomic, strong)GetModel *getIdolModel;               // 请求关注的当前Model
@property (nonatomic, strong)GetModel *getRangeVideoListModel;     // 请求范围内视频当前的model

@property (nonatomic, assign) NSInteger getTimeCount;              // 目前用于  发送鹰眼请求计数，因为他们2个只能单独进行一个

@end

@implementation WSocket

/// 获取单例
static WSocket *wSocket = nil;
+ (WSocket *)sharedWSocket
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        wSocket = [[self alloc] init];
        [wSocket initWSocket];
    });
    return wSocket;
}

/// init
- (instancetype)init
{
    self = [super init];
    if (self) {
        _isInitSuccess = -1;
        _isLoginOK = NO;
        _deviceToken = @"";
        _getTimeCount = 0;
        _messageList = [[NSMutableArray alloc] init];
        _nearMessageList = [[NSMutableArray alloc] init];
        _waitMessageList = [[NSMutableArray alloc] init];
        _lbxManager = [InscriptionManager sharedManager];
        [self initQueues];
        
        _longTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(checkAll) userInfo:nil repeats:YES];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkChange:) name:kNetworkChange object:nil];

    }
    return self;
}

/// 初始化用到的所有的队列
- (void)initQueues
{
    _downQueue = [[NSOperationQueue alloc] init];
    [_downQueue setMaxConcurrentOperationCount:1];
    
    _uploadQueue = [[NSOperationQueue alloc] init];
    [_uploadQueue setMaxConcurrentOperationCount:1];
    
    _getFansQueue = [[NSOperationQueue alloc] init];
    [_getFansQueue setMaxConcurrentOperationCount:1];
    
    _getIdolQueue = [[NSOperationQueue alloc] init];
    [_getIdolQueue setMaxConcurrentOperationCount:1];
    
    _getRangeVideoListQueue = [[NSOperationQueue alloc] init];
    [_getRangeVideoListQueue setMaxConcurrentOperationCount:1];
    
    _sendMessageQueue = [[NSOperationQueue alloc] init];
}

/// 初始化Socket服务器
- (void)initWSocket
{
    NSString *tIP = @"115.28.49.135";
    int tPort = 5604;
    NSString *tFileIP = @"115.28.49.135";
    int tFilePort = 5603;
  
    char *pcIp = (char *)[tIP cStringUsingEncoding:NSASCIIStringEncoding];
    char *pcFileIp = (char *)[tFileIP cStringUsingEncoding:NSASCIIStringEncoding];
    NSLog(@"初始化之前 isInit=%d", wSocket.isInitSuccess);
    
    wSocket.isInitSuccess = im_c_Init(pcIp, tPort, pcFileIp, tFilePort, im_callback);
   
    NSLog(@"初始化之后 isInit=%d", wSocket.isInitSuccess);
}

/// 让设备连接服务器, 如果连接成功马上登录
- (void)connectToServerAndLogin
{
    if (wSocket.isInitSuccess >= 0) {
        
        NSString *username = _lbxManager.wJid.phone;
        NSString *password = _lbxManager.wJid.password;
        
        if (username.length <= 0 && password.length <= 0) {
            username = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:kUserName]];
            if (username.length == 11) {
                _lbxManager.wJid.phone = username;
            } else {
                username = @"";
            }
            
            password = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:kPassword]];
            if (password.length >= 6 && ![password isEqualToString:@"(null)"] && ![password isEqualToString:@"<null>"]) {
                _lbxManager.wJid.password = password;
            } else {
                password = @"";
            }
        }
        
        NSLog(@"1username = %@,password = %@",username,password);

        if (username.length > 0 && password.length > 0) {
            __weak WSocket *weakSocket = wSocket;
            [wSocket logining:username password:password isAuto:YES loginBlock:^(int success) {
                [weakSocket showAlertWithTag:success];
            }];
        } else {
            NSLog(@"没有数据，没法登录");
        }
    } else {
        [wSocket initWSocket];
        
        NSString *username = _lbxManager.wJid.phone;
        NSString *password = _lbxManager.wJid.password;
        
        if (username.length <= 0 && password.length <= 0) {
            username = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:kUserName]];
            if (username.length == 11) {
                _lbxManager.wJid.phone = username;
            } else {
                username = @"";
            }
            
            password = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:kPassword]];
            if (password.length >= 6 && ![password isEqualToString:@"(null)"] && ![password isEqualToString:@"<null>"]) {
                _lbxManager.wJid.password = password;
            } else {
                password = @"";
            }
        }
                
        if (username.length > 0 && password.length > 0) {
            __weak WSocket *weakSocket = wSocket;
            [wSocket logining:username password:password isAuto:YES loginBlock:^(int success) {
                [weakSocket showAlertWithTag:success];
            }];
        } else {
            NSLog(@"没有数据，没法登录");
        }
    }
}

/// 获取随机不一样的id
- (NSString *)getSerialId
{
    return [NSString stringWithFormat:@"%lld",im_c_GetIndexLongLong()];
}

/// 设置程序是否在后台给C调用,防止在后台程序断开链接崩溃
- (void)tellCIsBackground:(int)isBackground
{
    c_SetBackground(isBackground);
}

/// 设置服务器推送消息个数
- (void)updatePushCount:(int)count
{
    im_c_UpdatePushCounter(count);
}

/// char * 转 NSString
- (NSString *)charToString:(char *)pData dataLen:(NSUInteger)dataLen
{
    NSLog(@"%d",(int)dataLen);
    if (dataLen == 0 || dataLen >= 100000) {
        return @"";
    }
    NSData *data = [NSData dataWithBytes:pData length:dataLen];
    NSString *str = nil;
    str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    return str;
}

/// NSString 转 char *
- (char *)stringToChar:(NSString *)str
{
    return (char*)[str cStringUsingEncoding:NSUTF8StringEncoding];
}

#pragma mark - Socket回调函数
/// _iFun是功能码  pcJsonString是返回的json， _iJsonLen 是json的长度， _pcBitBuf是二进制数据， _iBufLen是是二进制数据
///  后边2个一般是文件下载用
int im_callback(uint32_t _iFun, char *_pcJsonString, uint32_t _iJsonLen, char *_pcBitBuf, uint32_t _iBufLen)
{
    NSLog(@"功能码是 iFun ＝ %d， pcJsonString = %s",_iFun, _pcJsonString);
    
    NSDictionary *rootDict = nil;
    
    if (!strlen(_pcJsonString)) {
        NSLog(@"json没有数据 可能是其他的数据");
    } else {
        rootDict = [wSocket fixData:_pcJsonString isDict:YES];
    }
    
    if (rootDict == nil) {
        NSLog(@"rootDict字典为空，停止处理");
    }
    
    int fun = _iFun;
    long long ret = [[rootDict objectForKey:@"ret"] longLongValue];
    int serial = [[rootDict objectForKey:@"serial"] intValue];
    
    NSLog(@"返回的数据是 fun = %d ret = %lld serial = %d",fun, ret, serial);

    switch (_iFun) {
        case IM_FUN_RE_CONTACT_ADD:
        {
            NSLog(@"lbxlbx = %@",rootDict);
            [[NSNotificationCenter defaultCenter] postNotificationName:kPhoneContactsResponse object:rootDict];

            break;
        }
        case IM_FUN_STATE:
        {
            [wSocket responseFunState:rootDict];
            break;
        }
        case IM_FUN_REGISTER:
        {
            if (wSocket.registerSuccess) {
                wSocket.registerSuccess((int)ret);
            }
            wSocket.registerSuccess = nil;
            break;
        }
        case IM_FUN_LOGIN:
        {
            if (ret >= 0) {
                wSocket.isLoginOK = YES;
                
                [wSocket updatePushCount:0];
                
                // 获取自己的个人资料
                [wSocket getUserInfo:wSocket.lbxManager.wJid.phone getUserInfoBlock:^(int ret, WJID *uJid) {
                }];
                
                // 获取好友，粉丝，关注个数
                [wSocket getAllTypeFriendCount];
                
                //获取所有农民列表  identity暂时为司机
                [wSocket QueryUsersByLocationIsAllCity:0 Sex:-1 Identity:2 Province:@"" City:@"" PriceStart:0 PriceEnd:65534 PageNum:0 PageSize:10 DfcQueryUsersByLocationBlock:^(int ret, NSMutableArray *filtedList) {
                }];

                // 上传自己的token
                if (wSocket.deviceToken.length) {
                    NSLog(@"login ok token = %@",wSocket.deviceToken);
                    char *s_token = [wSocket stringToChar:wSocket.deviceToken];
                    im_c_UpdateToken(s_token);
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kLoginSuccess object:nil];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateOnlineStatus object:@"1"];
                
            }
            if (wSocket.loginSuccess) {
                wSocket.loginSuccess((int)ret);
            }
            wSocket.loginSuccess = nil;

            break;
        }
            
        case IM_FUN_UPDATE_INFO:
        {
            if (wSocket.updateUserInfoSuccess) {
                wSocket.updateUserInfoSuccess((int)ret);
            }
            wSocket.updateUserInfoSuccess = nil;
            break;
        }
        case IM_FUN_RESET_PASSWD:
        {
            if (wSocket.resetPswSuccess) {
                wSocket.resetPswSuccess((int)ret);
            }
            wSocket.resetPswSuccess = nil;
            break;
        }
        case IM_FUN_RESET_PSW_CHECK:
        {
            if (wSocket.resetPswCheckCodeSuccess) {
                wSocket.resetPswCheckCodeSuccess((int)ret);
            }
            wSocket.resetPswCheckCodeSuccess = nil;
            break;
        }
        case IM_FUN_FRIEND_LIST:
        {
            [wSocket fixFriendList:rootDict];
            break;
        }
        case IM_FUN_ADD_FRIEND:
        {
            [wSocket addFriendSuccess:rootDict];
            break;
        }
        case IM_FUN_GET_USER_INFO:
        {
            [wSocket fixUserInfo:rootDict];
            break;
        }
        case IM_FUN_DFC_USER_INFO:
        {
            [wSocket fixDFCInfo:rootDict];
            break;
        }
            
        case IM_FUN_DRIVER_QUOTE_PRICE:
        {
            if (wSocket.driverQuotedPriceSuccess) {
                wSocket.driverQuotedPriceSuccess(int(ret));
            }
            wSocket.driverQuotedPriceSuccess = nil;
            break;
        }
            
        case IM_FUN_DEL_QUOTE_PRICE:
        {
            if (wSocket.DelQuotedPriceSuccess) {
                wSocket.DelQuotedPriceSuccess(int(ret));
            }
            wSocket.DelQuotedPriceSuccess = nil;
            break;
        }
            
        case IM_FUN_DFC_QUERY_USERS_BY_LOC:
        {
            NSLog(@"QueryByLocDict= %@",rootDict);
            
            if (ret>=0)
            {
                NSString *hasMore = [NSString stringWithFormat:@"%@",[rootDict objectForKey:@"has_more"]];
                NSString *cur_idx = [NSString stringWithFormat:@"%@",[rootDict objectForKey:@"cur_idx"]];
                
                if ([hasMore intValue]==1){
                    
                }else{
                    ret =500;
                }
                
                [wSocket.lbxManager saveTheLastFilteredFarmlist:rootDict Cur_idx:[cur_idx intValue]];
                NSMutableArray *filterlist = [NSMutableArray arrayWithArray:[wSocket.lbxManager getTheLastFilterFarmListWithCuridx:[cur_idx intValue]]];
                
                if (wSocket.DfcQueryUsersByLocationSuccess)
                {
                    wSocket.DfcQueryUsersByLocationSuccess(int(ret),filterlist);
                }
            }else
            {
                if (wSocket.DfcQueryUsersByLocationSuccess)
                {
                    wSocket.DfcQueryUsersByLocationSuccess(int(ret),nil);
                }
            }
             wSocket.DfcQueryUsersByLocationSuccess = nil;
               break;
        }
            
        case IM_FUN_DFC_QUERY_DRIVERS:
        {
            if (wSocket.GetDriversByDriverSuccess)
            {
                wSocket.GetDriversByDriverSuccess(int(ret),rootDict);
            }
            wSocket.GetDriversByDriverSuccess = nil;
            break;
        }
            
        case IM_FUN_FILE_RE_FINISH:
        {
            NSString *fileName = [rootDict objectForKey:@"file_name"];
            NSString *filePath = [rootDict objectForKey:@"file_path"];

            if (wSocket.upLoadFileToServerSuccess) {
                if (filePath.length) {
                    wSocket.upLoadFileToServerSuccess(0, fileName, filePath);
                } else {
                    wSocket.upLoadFileToServerSuccess(kRequestFailed, @"", @"");
                }
                wSocket.upLoadFileToServerSuccess = nil;
            } else {
                if (wSocket.uploadQueue.isSuspended) {
                    [wSocket.uploadQueue setSuspended:NO];
                }
            }
            break;
        }
        case IM_FUN_DOWNLOAD_RE_FINISH:
        {
            NSData *fileData = [NSData dataWithBytes:_pcBitBuf length:_iBufLen];
            NSString *fileName = [rootDict objectForKey:@"download_url"];
            NSLog(@"下载完成的文件 = %@",fileName);
            
            if (wSocket.downLoadFileFromServerSuccess) {
                
                if (fileData) {
                    wSocket.downLoadFileFromServerSuccess(0, fileData, fileName);
                } else {
                    NSString *saveFileName = [wSocket.lbxManager upper16_MD5:fileName];
                    if ([fileName hasSuffix:@".mp4"]) {
                        [fileData writeToFile:[NSString stringWithFormat:@"%@/%@.mp4",kPathVideo,saveFileName] atomically:YES];
                    } else if ([fileName hasSuffix:@".amr"]) {
                        [fileData writeToFile:[NSString stringWithFormat:@"%@/%@",kPathVoice,saveFileName] atomically:YES];
                    } else {
                        [fileData writeToFile:[NSString stringWithFormat:@"%@/%@",kPathPicture,saveFileName] atomically:YES];
                    }
                    wSocket.downLoadFileFromServerSuccess(kRequestFailed, nil, fileName);
                }
                wSocket.downLoadFileFromServerSuccess = nil;
            } else {
                if (wSocket.downQueue.isSuspended) {
                    [wSocket.downQueue setSuspended:NO];
                }
            }
            break;
    }
        case IM_FUN_DEL_FRIEND:
        {
            NSLog(@"删除好友，成功或者失败，可能也没用了 lbxlbx");
            break;
        }
        case IM_FUN_HD_DEL_FRIEND:
        {
            NSString *phone = [NSString stringWithFormat:@"%@",[rootDict objectForKey:@"user_id"]];
            NSLog(@"%@删除我好友了,可能也没用了 lbxlbx",phone);

            if ([wSocket.lbxManager.wJid.talkingUser isEqualToString:phone]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kDeleteMe object:nil];
            }
            
            [wSocket deleteFriend:phone];
            break;
        }
        case IM_FUN_FEEDBACK:
        {
            NSLog(@"反馈结果出来了 %d",(int)ret);
            break;
        }
        case FUN_FOLLOW_USER:
        {
            if (wSocket.followUserSuccess) {
                wSocket.followUserSuccess((int)ret);
            }
            wSocket.followUserSuccess = nil;
            break;
        }
        case FUN_CANCEL_FOLLOW_USER:
        {
            if (wSocket.unFollowUserSuccess) {
                wSocket.unFollowUserSuccess((int)ret);
            }
            wSocket.unFollowUserSuccess = nil;
            break;
        }
        case FUN_GET_FANS_LIST:
        {
            if (wSocket.getFansListSuccess) {
                wSocket.getFansListSuccess((int)ret, rootDict);
            }
            wSocket.getFansListSuccess = nil;
            wSocket.getFansModel = nil;
            if (wSocket.getFansQueue.isSuspended) {
                [wSocket.getFansQueue setSuspended:NO];
            }
            break;
        }
        case FUN_GET_FOLLOW_LIST:
        {
            if (wSocket.getIdolListSuccess) {
                wSocket.getIdolListSuccess((int)ret, rootDict);
            }
            wSocket.getIdolListSuccess = nil;
            wSocket.getIdolModel = nil;
            if (wSocket.getIdolQueue.isSuspended) {
                [wSocket.getIdolQueue setSuspended:NO];
            }
            break;
        }
        case IM_FUN_SEND_USER:
        {
            [wSocket fixMessage:rootDict];
            break;
        }
        case IM_FUN_SEND_GROUP_MESSAGE:
        {
            [wSocket fixMessage:rootDict];
            break;
        }
        case FUN_MSG_I_WANT:
        {
            NSLog(@"我请求的鹰眼请求 id = %d   成功还是失败了? %d ",serial, (int)ret);
            break;
        }
        case IM_FUN_SEND_USER_VIDEO:
        {
            break;
        }
        case IM_FUN_RANGE_USER_NUM:
        {
            if (ret >= 0) {
                NSLog(@"获取范围内人数成功   %lld", ret);
                [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateRangeUserCount object:[NSString stringWithFormat:@"%lld",ret]];
            }
            break;
        }
        case IM_FUN_RANGE_VIDEO_LST:
        {
            break;
        }
        case FUN_UPDATE_VIDEO_LIKE:
        {
            if (ret == -1) { NSLog(@"点赞或者取消赞失败"); } else if (ret == 1) { NSLog(@"点赞成功"); } else if (ret == 0) { NSLog(@"取消赞成功"); }
            break;
        }
        case FUN_UPDATE_VIDEO_COMMENT:
        {
            if (ret == -1) { NSLog(@"视频评论失败"); } else {
                NSLog(@"本地id为%lld的视频评论成功了",ret);
            }
            break;
        }
        case FUN_GET_USER_INFO_COUNT:
        {
            if (ret >= 0) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateAllCount object:rootDict];
            }
            break;
        }
        case IM_FUN_MY_FRIENDS:
        {
            /*   json格式
             JsonString:{"area_code":"86","friend_list":[{"area_code":"86","friend_id":"4","head_portrait":"/home/nfs/data/1447376208/1447384153003.jpg","user_id":"13459259875","user_name":"e68891e79a84e5a5bde4bda0e4b88de68782"},{"area_code":"86","friend_id":"2","head_portrait":"/home/nfs/data/1447376208/1447384153003.jpg","user_id":"13459259875","user_name":"e68891e79a84e5a5bde4bda0e4b88de68782"}],"previous_id":"0","ret":"0","user_id":"13459259875"}

             */
            NSLog(@"此接口只用来提交好友更新的时间，用来做左侧视图显示的新增好友");
            NSLog(@"获取我的好友列表分页查看的时候才需要这个接口，目前暂时无用lbxlbx");
            break;
        }
        case IM_FUN_CREATE_GROUP:
        {
            wSocket.createGroupIsSuccess((int)ret);
            break;
        }
        case IM_FUN_DELETE_GROUP:
        {
            wSocket.deleteGroupIsSuccess((int)ret);
            break;
        }
        case IM_FUN_ADD_GROUP_MEMBERS:
        {
            wSocket.addFriendMember((int)ret);
            break;
        }
        case IM_FUN_EXIT_GROUP:
        {
            wSocket.exitGroup((int)ret);
            break;
        }
        case IM_FUN_GET_ALBUM_LIST:
        {
            [wSocket.lbxManager showHudViewLabelText:@"我的群列表获取失败" detailsLabelText:nil afterDelay:1];
            break;
        }
        case IM_FUN_DEL_GROUPMEMBER: case IM_FUN_DEL_GROUP_MEMBER:
        {
            wSocket.removeGroup((int)ret);
            break;
        }
            
        case IM_FUN_GET_MYGROUP_LIST:
        {
            [wSocket getMyGroupList:rootDict];
            break;
        }
        case IM_FUN_GET_GROUPMEMBER_LIST:
        {
            [wSocket getGroupMemberList:rootDict];
            break;
        }
   
            
        default:
            break;
    }

    return 1;
}

/// 将服务器返回的char* json转换成类型返回
- (id)fixData:(char *)data isDict:(BOOL)isDict
{
    NSLog(@"data = %s",data);
    NSData *jsonData = [NSData dataWithBytes:data length:strlen(data)];
    
    if (isDict) {
        NSError *error = nil;
        if (jsonData.length) {
            NSDictionary *rootDict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
            
            if (error) {
                NSLog(@"json转换失败 error = %@",error.description);
                return nil;
            }
            
            if (rootDict) {
                return rootDict;
            }
        }
    } else {
        NSLog(@"下载的文件，数据为jsonData");
    }
    
    return nil;
}

#pragma mark - 收到消息了
- (void)fixMessage:(NSDictionary *)rootDict
{
    
    NSLog(@"收到%@发来的消息了,是发给%@的,  消息id是 %@,  消息类型是 %@,  消息长度是 %@",[rootDict objectForKey:@"src_user"],[rootDict objectForKey:@"dst_user"], [rootDict objectForKey:@"index"], [rootDict objectForKey:@"data_type"],[rootDict objectForKey:@"data_len"]);
    
    NSString *mIndex = [rootDict objectForKey:@"index"];
    NSString *pcData = [rootDict objectForKey:@"data"];
    NSLog(@"pcData = %@",pcData);
    
    NSString *foreign_phone = [NSString stringWithFormat:@"%@",[rootDict objectForKey:@"src_user"]];
    NSString *time = [NSString stringWithFormat:@"%@",[rootDict objectForKey:@"time"]];
    int dataType = [[NSString stringWithFormat:@"%@",[rootDict objectForKey:@"data_type"]] intValue];
    NSString *area = [NSString stringWithFormat:@"%@",[rootDict objectForKey:@"area"]];
    
    // 这是主帐号功能，这个字段是指定发送消息给谁
    NSString *to_phone = [NSString stringWithFormat:@"%@",[rootDict objectForKey:@"dst_user"]];
    NSLog(@"主账号，要发给的人是 %@",to_phone);
    // 这个是阅后即焚功能，显示几秒之后销毁
    int additional = [[NSString stringWithFormat:@"%@",[rootDict objectForKey:@"additional"]] intValue];
    
    NSString *groupId = [NSString stringWithFormat:@"%@",[rootDict objectForKey:@"group_id"]];
    
    NSString *groupUser = @"";
    
    if (groupId.length && ![groupId isEqualToString:@"(null)"] && ![groupId isEqualToString:@"<null>"]) {
        foreign_phone = [NSString stringWithFormat:@"%@Q",groupId];
        groupUser = [NSString stringWithFormat:@"%@",[rootDict objectForKey:@"src_user"]];
    }
    
    switch (dataType) {
        case IM_DATA_TYPE_TEXT:
        {
            dispatch_sync(_lbxManager.recvQueue, ^{
                NSLog(@"收到文本消息 %@ %@",pcData, mIndex);
                
                [wSocket receiveMessagePhone:foreign_phone area:area time:time type:LBX_IM_DATA_TYPE_TEXT hexMessage:pcData destoryTime:additional voice_time:additional isSound:YES serialId:mIndex nickname:@"" groupUser:groupUser];
                
            });
            
            break;
        }
        case IM_DATA_TYPE_PICTURE:
        {
            dispatch_sync(_lbxManager.recvQueue, ^{
                NSLog(@"收到图片文件 %@  %@",pcData, mIndex);
                
                [wSocket receiveMessagePhone:foreign_phone area:area time:time type:LBX_IM_DATA_TYPE_PICTURE hexMessage:pcData destoryTime:additional voice_time:additional isSound:YES serialId:mIndex nickname:@"" groupUser:groupUser];
            });
            break;
        }
        case IM_DATA_TYPE_JS:
        {
            dispatch_sync(_lbxManager.recvQueue, ^{
                NSLog(@"收到js脚本文件");
                
            });
            break;
        }
        case IM_DATA_TYPE_AMR:
        {
            dispatch_sync(_lbxManager.recvQueue, ^{
                NSLog(@"接收AMR %@ %@", pcData, mIndex);
                [wSocket receiveMessagePhone:foreign_phone area:area time:time type:LBX_IM_DATA_TYPE_AMR hexMessage:pcData destoryTime:additional voice_time:additional isSound:YES serialId:mIndex nickname:@"" groupUser:groupUser];
                
                
                //                [wSocket receiveVoiceMsg:foreign_user timestamp:timestamp file_url:pcData voice_time:destoryImageTime serial_id:mIndex];
            });
            break;
        }
        case IM_DATA_TYPE_MP4:
        {
            dispatch_sync(_lbxManager.recvQueue, ^{
                
            });
            break;
        }
        case IM_DATA_TYPE_TXT_AND_PIC:
        {
            dispatch_sync(_lbxManager.recvQueue, ^{
                
            });
            break;
        }
        case IM_DATA_TYPE_SYSTEM:
        {
            dispatch_sync(_lbxManager.recvQueue, ^{
                NSLog(@"收到系统消息 %@ %@", pcData, mIndex);
                
            });
            break;
        }
        case IM_DATA_TYPE_ADDFRIEND:
        {
            dispatch_sync(_lbxManager.recvQueue, ^{
                NSLog(@"请求添加好友 %@ %@",pcData,mIndex);
            });
            break;
        }
        case IM_DATA_TYPE_RE_ADDFRIEND:
        {
            dispatch_sync(_lbxManager.recvQueue, ^{
                NSLog(@"回复添加好友 %@ %@",pcData, mIndex);
            });
            break;
        }
        case IM_DATA_TYPE_MSG_I_WANT:
        {
            dispatch_sync(_lbxManager.recvQueue, ^{
            });
            break;
        }
        case IM_DATA_TYPE_MSG_I_WANT_RE:
        {
            dispatch_sync(_lbxManager.recvQueue, ^{
            });
            break;
        }
        default:
            break;
    }

}

#pragma mark - 解析服务器返回的json，然后发送不同的通知
/// 这里是处理所有的状态返回
- (void)responseFunState:(NSDictionary *)rootDict
{
    int additional = [[rootDict objectForKey:@"additional"] intValue];
    long long ret = [[rootDict objectForKey:@"ret"] longLongValue];
    int state = [[rootDict objectForKey:@"state"] intValue];
    NSLog(@"状态返回的关键字是 %d  返回值是 %lld 状态吗是 %d", additional, ret, state);

    switch (state) {
        case IM_STATE_UPDATE_USER_INFO:
        {
            NSLog(@"更新的个人资料的选项是 %d",additional);   // 这是additional的枚举 TImUserInfoType
            break;
        }
        case IM_STATE_CLOSE:
        {
            if (wSocket.logOutSuccess) {
                wSocket.logOutSuccess((int)ret);
                wSocket.logOutSuccess = nil;
            } else {
                NSLog(@"连接失效了");
            }
            wSocket.isLoginOK = NO;
            [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateOnlineStatus object:@"0"];
            break;
        }
        case IM_STATE_NO_LOGIN:
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateOnlineStatus object:@"0"];
            static int count = 0;
            if (count%3 == 0) {
                if (_lbxManager.wJid.phone.length && _lbxManager.wJid.password.length) {
                    __weak WSocket *weakSocket = wSocket;
                    [wSocket logining:_lbxManager.wJid.phone password:_lbxManager.wJid.password isAuto:YES loginBlock:^(int success) {
                        [weakSocket showAlertWithTag:success];
                    }];
                }
            }
            count++;
            break;
        }
        case IM_STATE_ADD_FRIEND:
        {
            dispatch_sync(_lbxManager.recvQueue, ^{

                [_lbxManager saveUserRelationship:[NSString stringWithFormat:@"%d",additional] friendType:ValidateTypeWait serial:[NSString stringWithFormat:@"%lld",ret]];
            });
            break;
        }
        case IM_STATE_RE_ADD_FRIEND:
        {
            NSLog(@"回复好友的请求成功，无用！");
            break;
        }
        case IM_STATE_RE_SERIAL:
        {
            NSLog(@"消息发送成功，消息ID是 %lld, 更新数据库，刷新界面",ret);
            [self sendMessageSuccess:YES serialId:[NSString stringWithFormat:@"%lld",ret]];
            break;
        }
        case IM_STATE_ERR_SERIAL:
        {
            NSLog(@"消息发送失败，消息ID是 %lld, 更新数据库，刷新界面",ret);
            [self sendMessageSuccess:NO serialId:[NSString stringWithFormat:@"%lld",ret]];
            break;
        }
        default:
            break;
    }
}

/// 返回好友列表
- (void)fixFriendList:(NSDictionary *)rootDict
{
    // 保存更新好友的最后时间
    [wSocket.lbxManager friendLastUpdateTimeIsGet:NO withPhone:wSocket.lbxManager.wJid.phone];
    
    if ([[rootDict objectForKey:@"friend_list"]isKindOfClass:[NSNull class]]) {
        return;
    }
    for (NSDictionary *info in [rootDict objectForKey:@"friend_list"]) {
        NSString *area = [NSString stringWithFormat:@"%@",[info objectForKey:@"user_area"]];
        NSString *phone = [NSString stringWithFormat:@"%@",[info objectForKey:@"user_id"]];
        dispatch_sync(_lbxManager.recvQueue, ^{
            [wSocket.lbxManager saveFriendWithPhone:phone area:area];
        });

        [wSocket getUserInfo:phone getUserInfoBlock:^(int ret, WJID *uJid) {
        }];
        
        [wSocket getUserDFCInfoBlock:phone getUserDFCInfoBlock:^(int ret, DFCUserInfo *DFCInfo) {
            
        }];
    }
}

/// 双方加为好友成功
- (void)addFriendSuccess:(NSDictionary *)rootDict
{
    int ret = [[rootDict objectForKey:@"ret"] intValue];
    if (ret == 0) {
        NSString *area = [NSString stringWithFormat:@"%@",[rootDict objectForKey:@"user_area"]];
        NSString *phone = [NSString stringWithFormat:@"%@",[rootDict objectForKey:@"user_id"]];
        dispatch_sync(_lbxManager.recvQueue, ^{
            [wSocket.lbxManager saveFriendWithPhone:phone area:area];
        });
        
        [wSocket getUserInfo:phone getUserInfoBlock:^(int ret, WJID *uJid) {
            
        }];
        
        [wSocket getUserDFCInfoBlock:phone getUserDFCInfoBlock:^(int ret, DFCUserInfo *DFCInfo) {
            
        }];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateFriendList object:nil];
    }
}

/// 返回自己或者其他用户的详细资料
- (void)fixUserInfo:(NSDictionary *)rootDict
{
    NSLog(@"userInfoDict = %@",rootDict);
    
    NSString *avatarUrl = [rootDict objectForKey:@"head_portrait"];
    if (avatarUrl.length) {
        
        __weak WSocket *weakSocket = wSocket;
        
        [wSocket addDownFileOperationWithFileUrlString:avatarUrl serialId:@"-1" modelType:ModelTypeNormal info:nil downBlock:^(int ret, int isSave, NSData *data, NSString *fileUrl) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (ret >= 0 && isSave) {
                    [data writeToFile:[NSString stringWithFormat:@"%@/%@",kPathAvatar,[weakSocket.lbxManager upper16_MD5:fileUrl]] atomically:YES];
                }
            });
        }];
    }
    
    NSString *phone = [rootDict objectForKey:@"phone_num"];
    if ([phone isEqualToString:_lbxManager.wJid.phone]) {
        _lbxManager.wJid.birthday = [rootDict objectForKey:@"birthday"];
        _lbxManager.wJid.avatarUrl = [rootDict objectForKey:@"head_portrait"];
        _lbxManager.wJid.nickname = [rootDict objectForKey:@"nick_name"];
        _lbxManager.wJid.sex = [[rootDict objectForKey:@"sex"] intValue] == 2 ? @"女" : @"男";
        _lbxManager.wJid.signature = [rootDict objectForKey:@"signature"];
        _lbxManager.wJid.identity = [[rootDict objectForKey:@"identity"]intValue]==2?@"司机" :@"农民";
        _lbxManager.wJid.contactNum = [rootDict objectForKey:@"phone_num"];
        
        dispatch_sync(_lbxManager.userInfoQueue, ^{
            [_lbxManager saveUserInfoWithObject:_lbxManager.wJid];
            [wSocket getUserDFCInfoBlock:phone getUserDFCInfoBlock:^(int ret, DFCUserInfo *DFCInfo) {
            }];
        });
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kBackSelfInfo object:nil];
        [[NSNotificationCenter defaultCenter]postNotificationName:kBackDFCSelfInfo object:nil];
    } else
    {
        WJID *uJid = [[WJID alloc] init];
        uJid.phone = phone;
        uJid.birthday = [rootDict objectForKey:@"birthday"];
        uJid.avatarUrl = [rootDict objectForKey:@"head_portrait"];
        uJid.nickname = [rootDict objectForKey:@"nick_name"];
        uJid.sex = [[rootDict objectForKey:@"sex"] intValue] == 2 ? @"女" : @"男";
        uJid.signature = [rootDict objectForKey:@"signature"];
        uJid.identity = [[rootDict objectForKey:@"identity"]intValue]==2?@"司机" :@"农民";
        uJid.contactNum = [rootDict objectForKey:@"phone_num"];
        
        dispatch_sync(_lbxManager.userInfoQueue, ^{

            [_lbxManager saveUserInfoWithObject:uJid];
            [wSocket getUserDFCInfoBlock:phone getUserDFCInfoBlock:^(int ret, DFCUserInfo *DFCInfo) {
            }];
        });
        
        if (_getUserInfoSuccess) {
            _getUserInfoSuccess(0, uJid);
        }
        
        _getUserInfoSuccess = nil;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateFriendList object:nil];
    }
    
}

///返回大风车资料详细信息 quoted_price_list只保留最近的5个 然后根据phone写入本地plist
-(void)fixDFCInfo:(NSDictionary *)rootDict
{
    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:[rootDict objectForKey:@"quoted_price_list"]];
    if (tempArray.count >5)
    {
        [tempArray removeObjectsInRange:NSMakeRange(0, tempArray.count -5)];
        [rootDict setValue:tempArray forKey:@"quoted_price_list"];
    }
    
    NSLog(@"fixedRootDic = %@",rootDict);
    
    NSString *phone = [rootDict objectForKey:@"phone_num"];
    if ([phone isEqualToString:_lbxManager.wJid.phone] )
    {
        [_lbxManager.dfcInfo setValuesForKeysWithDictionary:rootDict];
        _lbxManager.dfcInfo.provice = [rootDict objectForKey:@"province"];
        
        if (_getUserDFCInfoSuccess)
        {
            _getUserDFCInfoSuccess(0,nil);
        }
        _getUserDFCInfoSuccess = nil;
        
        [_lbxManager saveDfcUserintoSqlWithObjcet:_lbxManager.dfcInfo];
        
        [[NSNotificationCenter defaultCenter]postNotificationName:kBackDFCSelfInfo object:nil];
        
    }else
    {
        DFCUserInfo *userInfo = [[DFCUserInfo alloc]init];
        [userInfo setValuesForKeysWithDictionary:rootDict];
        userInfo.provice = [rootDict objectForKey:@"province"];
        
        if (_getUserDFCInfoSuccess)
        {
            _getUserDFCInfoSuccess(0,userInfo);
        }
        _getUserDFCInfoSuccess = nil;
        
        [_lbxManager saveDfcUserintoSqlWithObjcet:userInfo];
        
        [[NSNotificationCenter defaultCenter]postNotificationName:kGetDfCOtherUserInfo object:nil];
    }
}


#pragma mark - 显示所有的请求失败处理
/// 显示所有的请求之后的提示
- (void)showAlertWithTag:(int)tag
{
    if (tag == kConnectNoNetwork) {
        [[InscriptionManager sharedManager] showHudViewLabelText:@"无网络链接" detailsLabelText:nil afterDelay:1];
        [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateOnlineStatus object:@"0"];
        wSocket.isLoginOK = NO;
    } else if (tag == kRequestFailed) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateOnlineStatus object:@"0"];
        wSocket.isLoginOK = NO;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3.0*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            if (wSocket.isLoginOK == NO) {
                [wSocket connectToServerAndLogin];
            }
        });
    } else if (tag) {
        NSString *str = [NSString stringWithFormat:@"没有处理过的错误tag %d",tag];
        [[InscriptionManager sharedManager] showHudViewLabelText:str detailsLabelText:nil afterDelay:2];
    }
}

#pragma mark - 注册、登陆、充值密码
/// 注册
- (void)registing:(NSString *)username passwd:(NSString *)passwd code:(NSString *)code registingBlock:(registerBlock)registerSuccess
{
    _registerSuccess = [registerSuccess copy];
    
    if ([_lbxManager checkIsHasNetwork:YES] == NO) {
        _registerSuccess(kConnectNoNetwork);
        return;
    }
    
    long long user = [username longLongValue];
    char *pwd = [self stringToChar:passwd];
    char *vcode = [self stringToChar:code];
    char *deviceKey = [self stringToChar:[NSString stringWithFormat:@"%@",[_lbxManager getUUID]]];
    
    char *deviceType = [self stringToChar:[UIDevice currentDevice].systemName];
    char *deviceVer = [self stringToChar:[UIDevice currentDevice].systemVersion];
    char *deviceT = [self stringToChar:@"iPhone"];
    
    if (im_c_Register(86, user, pwd, vcode, deviceKey, deviceType, deviceVer, deviceT) == kConnectFailue) {
        _registerSuccess(kRequestFailed);
    }
}

/// 登陆
- (void)logining:(NSString *)username password:(NSString *)password isAuto:(BOOL)isAuto loginBlock:(loginBlock)loginSuccess
{
    _loginSuccess = loginSuccess;
    
    if ([_lbxManager checkIsHasNetwork:!isAuto] == NO) {
        _loginSuccess(kConnectNoNetwork);
        return;
    }
    
    UInt32 lastTime = [_lbxManager friendLastUpdateTimeIsGet:YES withPhone:username];
    
    long long user = [username longLongValue];
    char *pwd = [self stringToChar:password];
    NSLog(@"user = %lld   pwd = %s", user, pwd);
    
    if (im_c_Login(86, user, pwd, lastTime) == kConnectFailue) {
        _loginSuccess(kRequestFailed);
    }
}

/// 退出登陆
- (void)logOutIsSuccess:(logOutBlock)logOutSuccess;
{
    _logOutSuccess = logOutSuccess;
    
    if ([_lbxManager checkIsHasNetwork:YES] == NO) {
        _logOutSuccess(kConnectNoNetwork);
        return;
    }
    
    if (im_c_Logout() == kConnectFailue) {
        _logOutSuccess(kRequestFailed);
        return;
    }
    return;
}

/// 重置密码前的检查验证码
- (void)resetPswCheckCodeWithPhone:(NSString *)phone code:(NSString *)code checkCodeBlock:(resetPswCheckCodeBlock)resetPswCheckCodeSuccess
{
    _resetPswCheckCodeSuccess = resetPswCheckCodeSuccess;
    
    if ([_lbxManager checkIsHasNetwork:YES] == NO) {
        _resetPswCheckCodeSuccess(kConnectNoNetwork);
        return;
    }
    
    long long user = [phone longLongValue];
    char *pcCode = [self stringToChar:code];
    
    if (im_c_ResetPswCheckCode(86, user, pcCode) == kConnectFailue) {
        _resetPswCheckCodeSuccess(kRequestFailed);
    }
}

/// 重置密码
- (void)resetPswWithPhone:(NSString *)phone withPsw:(NSString *)psw withCode:(NSString *)code resetPswBlock:(resetPswBlock)resetPswSuccess
{
    _resetPswSuccess = resetPswSuccess;
    
    if ([_lbxManager checkIsHasNetwork:YES] == NO) {
        _resetPswSuccess(kConnectNoNetwork);
        return;
    }
    
    long long user = [phone longLongValue];
    char *pcPsw = [self stringToChar:psw];
    char *pcCode = [self stringToChar:code];
    
    if (im_c_ResetPassWd(86, user, pcPsw, pcCode) == kConnectFailue) {
        _resetPswSuccess(kRequestFailed);
    }
}

/// 上传token
- (void)registerDeviceToken:(NSData *)deviceToken
{
    NSString *tokenStr = [NSString stringWithFormat:@"%@",deviceToken];
    NSMutableString *tokenAfterSub = [NSMutableString stringWithString:[tokenStr substringWithRange:NSMakeRange(1, [tokenStr length]-2)]];
    NSString *string2 = @" ";
    int i = 0;
    do {
        NSRange range = [tokenAfterSub rangeOfString:string2];
        [tokenAfterSub deleteCharactersInRange:range];
        i++;
    } while (i < 7);
    
    
    wSocket.deviceToken = tokenAfterSub;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        while (1) {
            if (_isLoginOK) {
                NSLog(@"token = %@",tokenAfterSub);
                char *s_token = [wSocket stringToChar:tokenAfterSub];
                im_c_UpdateToken(s_token);
                break;
            }
            [NSThread sleepForTimeInterval:3];
        }
    });
}

#pragma mark - 联系人相关
/// 我删除最近消息的对话框,不删除聊天记录
- (void)deleteNearMessageWithPhone:(NSString *)phone
{
    NSString *deleteSql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE phone='%@' AND local_user='%@'", kNearMessageTableName, phone, _lbxManager.wJid.phone];
    [[DBConnect shareConnect] executeUpdateSql:deleteSql];
}

/// 我删除好友/好友删除我， 删除聊天对话框，删除聊天记录， 删除好友列表，暂时不删除这个人的资料
- (void)deleteFriend:(NSString *)phone
{
    // lbxlbx
}

/// 获取好友列表，暂时无用，只是封装一下搁在这里  (如果需要好友列表分页才需要这个接口)
- (int)getFriendListWithLastId:(NSString *)lastId
{
    if ([_lbxManager checkIsHasNetwork:YES] == NO) {
        return -1;
    }
    
    if (_isLoginOK == NO) {
        [wSocket showAlertWithTag:kRequestFailed];
        return -1;
    }
    
    if (im_c_GetMyFriends([lastId intValue]) == kConnectFailue) {
        return -1;
    }
    
    return 0;
}

/// 获取好友，粉丝，关注的个数
- (void)getAllTypeFriendCount
{
    if ([_lbxManager checkIsHasNetwork:YES] == NO) {
        return;
    }
    
    if (_isLoginOK == NO) {
        [wSocket showAlertWithTag:kRequestFailed];
        return;
    }
    
    if (im_c_GetUserInfoCount() == kConnectFailue) {
        [_lbxManager showHudViewLabelText:@"请求失败" detailsLabelText:nil afterDelay:1];
    }
}

/// 获取粉丝列表
- (void)getFansListWithPhone:(NSString *)phone area:(NSString *)area lastId:(NSString *)lastId success:(getFansListBlock)getFansListSuccess
{
    
    if ([_lbxManager checkIsHasNetwork:YES] == NO) {
        getFansListSuccess(kConnectNoNetwork, nil);
        return;
    }
    
    if (_isLoginOK == NO) {
        getFansListSuccess(kRequestFailed, nil);
        [wSocket showAlertWithTag:kRequestFailed];
        return;
    }
    
    [_getFansQueue cancelAllOperations];
    
    NSDictionary *info = [[NSDictionary alloc] initWithObjectsAndKeys:phone,kModelPhone,area,kModelArea,lastId,kModelLastId, nil];
    GetModel *model = [[GetModel alloc] initWithInfo:info block:getFansListSuccess];
    
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:wSocket selector:@selector(getFans:) object:model];
    [_getFansQueue addOperation:operation];
    model.operation = operation;
}

/// 获取粉丝列表执行
- (void)getFans:(GetModel *)model
{
    [_getFansQueue setSuspended:YES];
    _getFansModel = model;
    
    NSLog(@"获取粉丝列表了");
    _getFansListSuccess = model.aBlock;
    
    if (c_GetFansList([model.area intValue], [model.phone longLongValue], [model.lastId intValue]) == kConnectFailue) {
        _getFansListSuccess(kRequestFailed, nil);
        _getFansListSuccess = nil;
        if (wSocket.getFansQueue.isSuspended) {
            [wSocket.getFansQueue setSuspended:NO];
        }
    }
}

/// 获取关注列表
- (void)getIdolListWithPhone:(NSString *)phone area:(NSString *)area lastId:(NSString *)lastId success:(getIdolListBlock)getIdolListSuccess
{
    
    if ([_lbxManager checkIsHasNetwork:YES] == NO) {
        getIdolListSuccess(kConnectNoNetwork, nil);
        return;
    }
    
    if (_isLoginOK == NO) {
        getIdolListSuccess(kRequestFailed, nil);
        [wSocket showAlertWithTag:kRequestFailed];
        return;
    }
    
    [_getIdolQueue cancelAllOperations];
    
    NSDictionary *info = [[NSDictionary alloc] initWithObjectsAndKeys:phone,kModelPhone,area,kModelArea,lastId,kModelLastId, nil];
    GetModel *model = [[GetModel alloc] initWithInfo:info block:getIdolListSuccess];
    
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:wSocket selector:@selector(getIdol:) object:model];
    [_getFansQueue addOperation:operation];
    model.operation = operation;
}

/// 获取关注列表执行
- (void)getIdol:(GetModel *)model
{
    [_getIdolQueue setSuspended:YES];
    _getIdolModel = model;
    _getIdolListSuccess = model.aBlock;
    
    if (c_GetFollowList([model.area intValue], [model.phone longLongValue], [model.lastId intValue]) == kConnectFailue) {
        _getIdolListSuccess(kRequestFailed, nil);
        _getIdolListSuccess = nil;
        if (wSocket.getIdolQueue.isSuspended) {
            [wSocket.getIdolQueue setSuspended:NO];
        }
    }
}

/// 请求添加好友
- (int)AddFriendWithPhone:(NSString *)phone requestText:(NSString *)text
{
    int area = [kPhoneArea intValue];
    
    NSString *serialIndex = [wSocket getSerialId];
    
    char *pcData = [wSocket stringToChar:text];
    int dataLength = (int)strlen(pcData);
    
    
    if (im_c_AddFriend([serialIndex longLongValue], area, [phone longLongValue], pcData, dataLength) == 0) {
        NSLog(@"加好友请求成功");
        dispatch_sync(_lbxManager.recvQueue, ^{

            [_lbxManager saveUserRelationship:phone friendType:ValidateTypeNone serial:serialIndex];
        });
        return 0;
    }
    
    return -1;
}

/// 回复添加好友 返回值为0，本地执行成功
- (int)ReAddFriendWithPhone:(NSString *)phone isAccept:(int)isAccept
{
    NSString *serialIndex = [wSocket getSerialId];
    int area = [kPhoneArea intValue];
    
    if (im_c_ReAddFriend([serialIndex longLongValue], area, [phone longLongValue], isAccept) == 0) {
        int type = ValidateTypeDelete;
        if (isAccept) {
            type = ValidateTypeFriend;
        }
        dispatch_sync(_lbxManager.recvQueue, ^{

            [_lbxManager saveUserRelationship:phone friendType:type serial:serialIndex];
        });
        return 0;
    }
    return -1;
}

/// 删除好友
- (int)DeleteFriendWithPhone:(NSString *)phone
{
    int area = [kPhoneArea intValue];
    if (im_c_DelFriend(area, [phone longLongValue]) == 0) {
        dispatch_sync(_lbxManager.recvQueue, ^{
            [_lbxManager saveUserRelationship:phone friendType:ValidateTypeDelete serial:@"-1"];
        });
        return 0;
    }
    return -1;
}

/// 强制添加好友
- (int)addFriend_Force:(NSString *)phone
{
    if (wSocket.isLoginOK == NO) {
        return -1;
    }
    
    if ([wSocket.lbxManager checkIsHasNetwork:NO] == NO) {
        return -1;
    }

    int area = [kPhoneArea intValue];
    NSLog(@"强制添加好友成功");

    NSLog(@"area = %d  phone = %@",area, phone);
    return im_c_AddFriend_Force(area, [phone longLongValue]);
}

/// 检查用户是不是好友
- (int)addContact:(NSString *)phoneList
{
    if (wSocket.isLoginOK == NO) {
        return -1;
    }
    
    if ([wSocket.lbxManager checkIsHasNetwork:NO] == NO) {
        return -1;
    }
   
    char *p = [self stringToChar:phoneList];
    return im_c_AddContact(p);
}

/// 关注  -5是已经关注过了，0是成功，其他为失败
- (void)followUser:(NSString *)phone success:(followUserBlock)followUserSuccess
{
    
    if ([_lbxManager checkIsHasNetwork:YES] == NO) {
        followUserSuccess(kConnectNoNetwork);
        return;
    }
    
    if (_isLoginOK == NO) {
        followUserSuccess(kRequestFailed);
        [wSocket showAlertWithTag:kRequestFailed];
        return;
    }
    
    _followUserSuccess = followUserSuccess;
    
    int area = [kPhoneArea intValue];
    
    if (im_c_FollowUser(area, [phone longLongValue]) == kConnectFailue) {
        _followUserSuccess(kRequestFailed);
    }
}

/// 取消关注 -5 没有关注 其他取消失败
- (void)unFollowUser:(NSString *)phone success:(unFollowUserBlock)unFollowUserSuccess
{
    
    if ([_lbxManager checkIsHasNetwork:YES] == NO) {
        unFollowUserSuccess(kConnectNoNetwork);
        return;
    }
    
    if (_isLoginOK == NO) {
        unFollowUserSuccess(kRequestFailed);
        [wSocket showAlertWithTag:kRequestFailed];
        return;
    }
    
    _unFollowUserSuccess = unFollowUserSuccess;

    
    int area = [kPhoneArea intValue];
    if (im_c_UnFollowUser(area, [phone longLongValue]) == kConnectFailue) {
        _unFollowUserSuccess(kRequestFailed);
    }
}

/// 获得通讯录好友
- (NSMutableDictionary *)getAddressBook
{
    return [_lbxManager getAddressBook];
}

/// 排序
- (NSMutableArray *)sortAddressBook:(NSMutableDictionary *)friendsList
{
    return [_lbxManager sortAddressBook:friendsList];
}

/// 模糊搜索
- (NSMutableArray *)fuzzySearchFriends:(NSString *)keywords
{
   // return [[MethodSocket shareMethodSocket] fuzzySearchFriends:keywords];
    return nil;
}

#pragma mark - 个人资料相关
/// 更新用户个人资料
- (void)updateUserInfo:(NSDictionary *)info updateUserInfoBlock:(updateUserInfoBlock)updateUserInfoSuccess
{
    
    if ([_lbxManager checkIsHasNetwork:YES] == NO) {
        updateUserInfoSuccess(kConnectNoNetwork);
        return;
    }
    
    if (_isLoginOK == NO) {
        updateUserInfoSuccess(kRequestFailed);
        [wSocket showAlertWithTag:kRequestFailed];
        return;
    }
    
    _updateUserInfoSuccess = updateUserInfoSuccess;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:info options:NSJSONWritingPrettyPrinted error:nil];
    NSString *infoString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    char *pcInfo = [self stringToChar:infoString];
    
    if (!(info.count ==9))
    {
        if (im_c_UpdateUserInfo(IM_USER_INFO_ALL, pcInfo))
        {
            _updateUserInfoSuccess(kRequestFailed);
        }
    }else
    {
        if (im_c_UpdateUserInfo(IM_USER_INFO_ADDRESS, pcInfo)) {
            _updateUserInfoSuccess(kRequestFailed);
        }
    }
}

/// 获取某一个用户的详细信息 如果block为nil，那么就不需要回调，发通知
- (void)getUserInfo:(NSString *)phone getUserInfoBlock:(getUserInfoBlock)getUserInfoSuccess
{
    if ([phone hasSuffix:@"Q"]) {
        getUserInfoSuccess(kConnectNoNetwork, nil);
        return;
    }
    
    if ([_lbxManager checkIsHasNetwork:YES] == NO) {
        getUserInfoSuccess(kConnectNoNetwork, nil);
        return;
    }
    
    if (_isLoginOK == NO) {
        getUserInfoSuccess(kRequestFailed, nil);
        [wSocket showAlertWithTag:kRequestFailed];
        return;
    }
    
    _getUserInfoSuccess = getUserInfoSuccess;

    
    if (im_c_GetUserInfo(86, [phone longLongValue]) == kConnectFailue) {
        if (_getUserInfoSuccess) {
            _getUserInfoSuccess(kRequestFailed, nil);
        }
    }
    
}

///获取大风车用户详细资料
-(void)getUserDFCInfoBlock:(NSString *)phone getUserDFCInfoBlock:(getUserDFCInfoBlock)getUserDFCInfoSuccess
{
    if ([_lbxManager checkIsHasNetwork:YES]==NO)
    {
        getUserDFCInfoSuccess(kConnectNoNetwork,nil);
        return;
    }
    
    if (_isLoginOK ==NO)
    {
        getUserDFCInfoSuccess(kRequestFailed,nil);
        [wSocket showAlertWithTag:kRequestFailed];
        return;
    }
    
    _getUserDFCInfoSuccess = getUserDFCInfoSuccess;
    
    if (im_c_GetUsrDFCInfo(86, [phone longLongValue])==kConnectFailue)
    {
        if (_getUserDFCInfoSuccess) {
            _getUserDFCInfoSuccess(kRequestFailed,nil);
        }
    }
    
}
///根据省城市区域和价格向服务器添加报价
-(void)updateDriverQuotedPriceWithProvince:(NSString *)province City:(NSString *)city Region:(NSString *)region Price:(NSString *)price driverQuotedPriceBlock:(driverQuotedPriceBlock)driverQuotedPriceSuccess
{
    _driverQuotedPriceSuccess = driverQuotedPriceSuccess;
    
    if ([_lbxManager checkIsHasNetwork:YES]==NO) {
        _driverQuotedPriceSuccess(kConnectNoNetwork);
        return;
    }
    
    if (_isLoginOK ==NO) {
        driverQuotedPriceSuccess(kRequestFailed);
        [wSocket showAlertWithTag:kRequestFailed];
        return;
    }
    
    char *pcProvince = [self stringToChar:province];
    char *pcCity = [self stringToChar:city];
    char *pcRegion =  [self stringToChar:region];
    int pcPrice = [price intValue]/100;
    
    if (im_c_DriverQuotedPrice(pcProvince, pcCity, pcRegion,pcPrice)==kConnectFailue)
    {
        if (_driverQuotedPriceSuccess) {
            _driverQuotedPriceSuccess(kConnectFailue);
        }
    }
    
}

///根据报价表中的ID删除报价
-(void)DelQuotedPriceWithId:(NSString *)idQuotedPrice DelQuotedPriceBlock:(DelQuotedPriceBlock)delQuotedPriceSuccess
{
    _DelQuotedPriceSuccess = delQuotedPriceSuccess;
    
    if ([_lbxManager checkIsHasNetwork:YES]==NO) {
        delQuotedPriceSuccess(kConnectNoNetwork);
        return;
    }
    
    if (_isLoginOK==NO) {
        delQuotedPriceSuccess(kRequestFailed);
        [wSocket showAlertWithTag:kRequestFailed];
        return;
    }
    
    long long _idQuotedPrice = [idQuotedPrice longLongValue];

    if (im_c_DelQuotedPrice(_idQuotedPrice) ==kConnectFailue) {
        if (_DelQuotedPriceSuccess) {
            _DelQuotedPriceSuccess(kConnectFailue);
        }
    }
    
}

/*根据指定条件获取大丰车用户列表*/
-(void)QueryUsersByLocationIsAllCity:(int)isGetAllCity Sex:(int)sex Identity:(int)identity Province:(NSString *)province City:(NSString *)city PriceStart:(int)priceStart PriceEnd:(int)priceEnd PageNum:(int)pageNum PageSize:(int)pageSize DfcQueryUsersByLocationBlock:(DfcQueryUsersByLocationBlock)DfcQueryUsersByLocationSuccess
{
    
    if ([_lbxManager checkIsHasNetwork:YES]== NO)
    {
        DfcQueryUsersByLocationSuccess(kConnectNoNetwork,nil);
        return;
    }
    
    if (_isLoginOK == NO)
    {
        DfcQueryUsersByLocationSuccess(kRequestFailed,nil);
        [wSocket showAlertWithTag:kRequestFailed];
        return;
    }
    _DfcQueryUsersByLocationSuccess = DfcQueryUsersByLocationSuccess;
    
    char *prov = [wSocket stringToChar:province];
    char *cities = [wSocket stringToChar:city];
    
    if (im_c_DfcQueryUsersByLocation(isGetAllCity, sex, identity,prov,cities,priceStart,priceEnd,pageNum,pageSize)== kConnectFailue)
    {
        if (_DfcQueryUsersByLocationSuccess)
        {
            _DfcQueryUsersByLocationSuccess(kRequestFailed,nil);
        }
    }
}

/*通过位置信息获取大丰车当前矩形内的所有司机列表*/
-(void)GetDriversByDriveriX1:(float)ix1 iX2:(float)ix2 iY1:(float)iy1 iY2:(float)iy2 pageNum:(int)pageNum pageSize:(int)pageSize GetDriversByDriversBlock:(GetDriversByDriverBlock)GetDriversByDriverSuccess
{
    if ([_lbxManager checkIsHasNetwork:YES]==NO)
    {
        GetDriversByDriverSuccess(kConnectNoNetwork,nil);
        return;
    }
    if (_isLoginOK ==NO)
    {
        GetDriversByDriverSuccess(kRequestFailed,nil);
        [wSocket showAlertWithTag:kRequestFailed];
        return;
    }
    
    _GetDriversByDriverSuccess = GetDriversByDriverSuccess;
    
    if (im_c_GetDriversByDriver(ix1, ix2, iy1, iy2, pageNum, pageSize)==kConnectFailue)
    {
        _GetDriversByDriverSuccess(kRequestFailed,nil);
    }
}

static int firstCount = 0;
static int firstCountTwo = 0;
#pragma mark - 循环检测所有的东西
/// 网络变化
- (void)networkChange:(NSNotification *)noti
{
    // 检测消息的重新发送
    int status = [[noti object] intValue];
    if (status == 0 || status == 1) {
        firstCount = 0;
        NSInteger count = _waitMessageList.count;
        if (count > 0) {
            if (wSocket.isLoginOK) {
                for (NSInteger i = count - 1; i >= 0; i--) {
                    ChatObject *object = [_waitMessageList objectAtIndex:i];
                    if (object.type == LBX_IM_DATA_TYPE_AMR) {
                        [self resendAudio:object isAddWaitMessage:NO isAddRemind:NO];
                    } else if (object.type == LBX_IM_DATA_TYPE_PICTURE) {
                        [self resendImage:object isAddWaitMessage:NO isAddRemind:NO];
                    } else if (object.type == LBX_IM_DATA_TYPE_TEXT) {
                        [self resendText:object isAddWaitMessage:NO isAddRemind:NO];
                    }
                }
            }
        }
    }
}

/// 检测所有的东西
- (void)checkAll
{
    if (wSocket.isLoginOK == NO) {
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 检测上传
        if (_uploadingModel) {
            _uploadingModel.time+=10;
            // 上传次数最多5次，超过5次，废弃任务
            if (_uploadingModel.count < 5) {
                
                if (_uploadingModel.time > 60) {
                    NSLog(@"上传超出15秒了,把任务放到最后");
                    [_uploadingModel.operation cancel];
                    im_c_OtherCancleUpLoad();
                    _uploadingModel.time = 0;
                    _uploadingModel.count++;
                    if (wSocket.upLoadFileToServerSuccess) {
                        wSocket.upLoadFileToServerSuccess(-1, @"", @"");
                        wSocket.upLoadFileToServerSuccess = nil;
                    } else {
                        if (wSocket.uploadQueue.isSuspended) {
                            [wSocket.uploadQueue setSuspended:NO];
                        }
                    }
//                    [_uploadQueue addOperation:_uploadingModel.operation];
                    _uploadingModel = nil;
                }
            } else {
                NSLog(@"上传次数超过5次了，废弃");
                [_uploadingModel.operation cancel];
                im_c_OtherCancleUpLoad();
                if (wSocket.upLoadFileToServerSuccess) {
                    wSocket.upLoadFileToServerSuccess(-1, @"", @"");
                    wSocket.upLoadFileToServerSuccess = nil;
                } else {
                    if (wSocket.uploadQueue.isSuspended) {
                        [wSocket.uploadQueue setSuspended:NO];
                    }
                }
                _uploadingModel = nil;
            }
        }
        
        // 检测下载
        if (_downingModel) {
            _downingModel.time+=10;
            // 下载次数最多5次，超过5次，废弃任务
            if (_downingModel.count < 5) {
                
                if (_downingModel.time > 60) {
                    NSLog(@"下载超出15秒了，把任务放到最后");
                    [_downingModel.operation cancel];
                    im_c_OtherCancleDownLoad();
                    _downingModel.time = 0;
                    _downingModel.count++;
                    if (wSocket.downLoadFileFromServerSuccess) {
                        wSocket.downLoadFileFromServerSuccess(-1, nil, @"");
                        wSocket.downLoadFileFromServerSuccess = nil;
                    } else {
                        if (wSocket.downQueue.isSuspended) {
                            [wSocket.downQueue setSuspended:NO];
                        }
                    }
//                    [_downQueue addOperation:_downingModel.operation];
                    _downingModel = nil;
                }
            } else {
                NSLog(@"下载次数超过5次了，废弃");
                [_downingModel.operation cancel];
                _downingModel = nil;
                im_c_OtherCancleDownLoad();
                if (wSocket.downLoadFileFromServerSuccess) {
                    wSocket.downLoadFileFromServerSuccess(-1, nil, @"");
                    wSocket.downLoadFileFromServerSuccess = nil;
                } else {
                    if (wSocket.downQueue.isSuspended) {
                        [wSocket.downQueue setSuspended:NO];
                    }
                }
                _downingModel = nil;
            }
        }
        
        // 检测消息的重新发送
        
        NSInteger count = _waitMessageList.count;
        if (count > 0) {
            if (wSocket.isLoginOK) {
                if ((firstCount == 0) || (firstCountTwo % 2 == 0)) {
                    firstCount = 1;
                    for (NSInteger i = 0; i < count; i++) {
                        ChatObject *object = [_waitMessageList objectAtIndex:i];
                        if (object.type == LBX_IM_DATA_TYPE_AMR) {
                            [self resendAudio:object isAddWaitMessage:NO isAddRemind:NO];
                        } else if (object.type == LBX_IM_DATA_TYPE_PICTURE) {
                            [self resendImage:object isAddWaitMessage:NO isAddRemind:NO];
                        } else if (object.type == LBX_IM_DATA_TYPE_TEXT) {
                            [self resendText:object isAddWaitMessage:NO isAddRemind:NO];
                        }
                    }
                }
                firstCountTwo++;
            }
        }
        
    });
}

#pragma mark - 发送消息相关
/// 发送消息/自动发送/重新发送的时候，第一步先保存最近消息、聊天页面、waitMessageList
- (void)saveSomeDataWithChatObject:(ChatObject *)object isAddWaitMessageList:(BOOL)isAdd isAddRemind:(BOOL)isAddRemind
{
    dispatch_sync(_lbxManager.recvQueue, ^{
        [_lbxManager saveChatMessageWithObject:object];
    });
    
    NearMessageObject *nearObject = [[NearMessageObject alloc] initWithSerialId:object.serialId phone:object.phone nickname:object.nickname message:object.message time:object.time avatarUrl:object.avatarUrl chatType:0 status:0 type:object.type noReadCount:-1 isSend:1];
    
    if (isAdd) {
        [self addWaitMessageListWithChatObject:object isDelete:NO];
    }

    if (isAddRemind) {
        [self addRemindWithNearObject:nearObject];
    }
}

/// 添加messageView的消息
- (void)addRemindWithNearObject:(NearMessageObject *)nearObject
{
    BOOL isHas = NO;
    NSInteger replaceIndex = 0;
    for (NSInteger i = wSocket.nearMessageList.count - 1; i >= 0; i--) {
        NearMessageObject *object = [wSocket.nearMessageList objectAtIndex:i];
        if ([object.phone isEqualToString:nearObject.phone]) {
            int count = (object.noReadCount <= 0 ? 0 : object.noReadCount) + nearObject.noReadCount;
            if (nearObject.noReadCount == -1) {
                count = -1;
            }
            nearObject.noReadCount = count;
            [wSocket.nearMessageList replaceObjectAtIndex:i withObject:nearObject];
            replaceIndex = i;
            isHas = YES;
            break;
        }
    }
    
    if (replaceIndex != 0) {
        NearMessageObject *object = [[NearMessageObject alloc] init];
        object = [wSocket.nearMessageList objectAtIndex:replaceIndex];
        [wSocket.nearMessageList removeObjectAtIndex:replaceIndex];
        [wSocket.nearMessageList insertObject:object atIndex:0];
    }
    
    if (isHas == NO) {
        [wSocket.nearMessageList insertObject:nearObject atIndex:0];
    }

    [self saveNearMessageWithObject:nearObject];
}

/// 保存最近消息
- (void)saveNearMessageWithObject:(NearMessageObject *)nearObject
{
    dispatch_sync(_lbxManager.recvQueue, ^{
        [_lbxManager saveNearMessageWithObject:nearObject];
    });
}

/// 添加到所有的未发送完成的队列里面 isDelete为YES， 通过object的serialId来删除消息
- (void)addWaitMessageListWithChatObject:(ChatObject *)object isDelete:(BOOL)isDelete
{
    if (isDelete) {
        for (ChatObject *aObject in _waitMessageList) {
            if ([aObject.serialId isEqualToString:object.serialId]) {
                [_waitMessageList removeObject:aObject];
                NSLog(@"serial 为 %@的消息发送成功，从waitMessageList里面删除",aObject.serialId);
                break;
            }
        }
        return;
    }
    
    [_waitMessageList addObject:object];
}

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
                      groupUser:(NSString *)groupUser
{
    NSString *sqlCount = [NSString stringWithFormat:@"SELECT COUNT(*) count FROM %@ WHERE serialId='%@' AND local_user='%@'", kMessageTableName, serialId, _lbxManager.wJid.phone];
    int count = [_lbxManager.dbConnect getDBDataCount:sqlCount];
    if (count > 0) {
        NSLog(@"收到重复id的消息了，不处理");
        return;
    }
    
    WJID *uJid = [wSocket.lbxManager getUserInfoWithPhone:phone];
    
    ChatObject *object = [[ChatObject alloc] init];
    object.serialId = serialId;
    object.phone = phone;
    object.area = area;
    object.type = type;
    object.message = pcData;
    object.destoryTime = destoryTime;
    object.status = 1;
    object.time = time;
    object.isSendMessage = NO;
    object.nickname = uJid.nickname;
    object.avatarUrl = uJid.avatarUrl;
    object.isRead = YES;
    object.voice_time = destoryTime;
    object.f_voice_time = 0;
    object.filePath = pcData;
    object.resendCount = 0;
    object.isGroupChat = 0;
    object.groupUser = @"";
    
    NSString *foreignDirectory = [NSString stringWithFormat:@"%@/%@",kPathChat,object.phone];
    [_lbxManager creatDirectPath:foreignDirectory];

    if (object.type == LBX_IM_DATA_TYPE_TEXT) {
        
        [self receiveMessageSuccess:object isSound:YES];
        
    } else if (object.type == LBX_IM_DATA_TYPE_PICTURE) {
        object.isRead = NO;
        object.downloadProgress = 100;
        
        NSString *imageFilePath = [NSString stringWithFormat:@"%@/%@",foreignDirectory,[_lbxManager upper16_MD5:object.filePath]];
        
        __weak WSocket *weakSocket = wSocket;
        __block NSString *weakImageFilePath = imageFilePath;

        [wSocket addDownFileOperationWithFileUrlString:object.filePath serialId:@"-1" modelType:ModelTypeNormal info:nil downBlock:^(int ret, int isSave, NSData *data, NSString *fileUrl) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (ret >= 0) {
                    [data writeToFile:weakImageFilePath atomically:YES];
                    
                    // 这里处理声音，然后存数据
                    [weakSocket receiveMessageSuccess:object isSound:YES];
                } else {
                    NSLog(@"聊天图片下载出错了");
                }
            });
        }];

    } else if (object.type == LBX_IM_DATA_TYPE_AMR) {
        object.isRead = NO;
        object.downloadProgress = 100;
        
        NSString *amrFilePath = [NSString stringWithFormat:@"%@/%@.amr",foreignDirectory,[_lbxManager upper16_MD5:object.filePath]];
        NSString *wavFilePath = [amrFilePath stringByReplacingOccurrencesOfString:@".amr" withString:@".wav"];
        
        __weak WSocket *weakSocket = wSocket;
        __block NSString *weakAmrFilePath = amrFilePath;
        __block NSString *weakWavFilePath = wavFilePath;
        
        [wSocket addDownFileOperationWithFileUrlString:object.filePath serialId:@"-1" modelType:ModelTypeNormal info:nil downBlock:^(int ret, int isSave, NSData *data, NSString *fileUrl) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (ret >= 0) {
                    [data writeToFile:weakAmrFilePath atomically:YES];
                    [VoiceConverter amrToWav:weakAmrFilePath wavSavePath:weakWavFilePath];
                    
                    // 这里处理声音，然后存数据
                    [weakSocket receiveMessageSuccess:object isSound:YES];
                } else {
                    NSLog(@"聊天语音下载出错了");
                }
            });
        }];

    } else {
        NSLog(@"没有处理这个type的类型的消息，type = %d",object.type);
    }
}

/// 接受到消息，消息都处理好了，把消息存入数据库，添加提醒列表，播放声音，发送通知
- (void)receiveMessageSuccess:(ChatObject *)object isSound:(BOOL)isSound
{
    NSInteger mCount = wSocket.messageList.count;
    if (mCount > 0) {
        ChatObject *lastObject = [wSocket.messageList lastObject];
        
        if ([_lbxManager.wJid.talkingUser isEqualToString:object.phone]) {
            if ([object.time intValue] - kBetweenTime > [lastObject.time intValue]) {
                ChatObject *timeObject = [[ChatObject alloc] init];
                timeObject.message = object.time;
                timeObject.isSendMessage = NO;
                timeObject.time = object.time;
                timeObject.type = LBX_IM_DATA_TYPE_TIME;
                [wSocket.messageList addObject:timeObject];
            }
        }
    }
    
    if (isSound) {
        NSString *showText = object.message;
        if (object.type == LBX_IM_DATA_TYPE_TEXT) {
            showText = [wSocket.lbxManager stringFromHexString:object.message];
        } else if (object.type == LBX_IM_DATA_TYPE_AMR) {
            showText = @"[声音]";
        } else if (object.type == LBX_IM_DATA_TYPE_PICTURE) {
            showText = @"[图片]";
        }
        
        NSString *endShowText = [NSString stringWithFormat:@"%@: %@",[_lbxManager stringFromHexString:object.nickname],showText];

        [self playSound:kAudioReceiveMessage showText:endShowText];
    }
    
    int noReadCount = 1;
    if ([wSocket.lbxManager.wJid.talkingUser isEqualToString:object.phone]) {
        noReadCount = -1;
        
        [wSocket.messageList addObject:object];
        [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshMessageList object:[NSString stringWithFormat:@"%d",MsgChatRefrashTypeReciveMsg]];
    } else {
        [wSocket receiveMessageStye:1];
        
    }
    
    NearMessageObject *nearObject = [[NearMessageObject alloc] initWithSerialId:object.serialId phone:object.phone nickname:object.nickname message:object.message time:object.time avatarUrl:object.avatarUrl chatType:0 status:1 type:object.type noReadCount:noReadCount isSend:0];
    


    [self addRemindWithNearObject:nearObject];
    
    [self saveSomeDataWithChatObject:object isAddWaitMessageList:NO isAddRemind:NO];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kBadgeChange object:nil];
}

/// 播放声音和显示文字
- (void)playSound:(NSString *)audioName showText:(NSString *)showText
{
    [[PlaySystemSound sharedManager] showNotificationWithContent:showText soundName:audioName];
}

/// 发送消息成功的回执
- (void)sendMessageSuccess:(BOOL)isSuccuess serialId:(NSString *)serialId
{
    ChatObject *object = [[ChatObject alloc] init];
    object.serialId = serialId;
    
    [self addWaitMessageListWithChatObject:object isDelete:isSuccuess];
    
    NSString *status = @"0";
    if (isSuccuess) {
        status = @"1";
    }
    
    // 遍历nearMessageList
    for (NearMessageObject *object in _nearMessageList) {
        if ([object.serialId isEqualToString:serialId]) {
            object.status = [status intValue];
            break;
        }
    }
    
    // 遍历chatMessageList
    for (ChatObject *object in _messageList) {
        if ([object.serialId isEqualToString:serialId]) {
            object.status = [status intValue];
            break;
        }
    }

    if (isSuccuess) {
        NSLog(@"消息发送成功   %@", serialId);
    } else {
        NSLog(@"消息发送失败   %@", serialId);
    }
    
    dispatch_sync(_lbxManager.recvQueue, ^{
        
        [_lbxManager updateMessageWithSerialId:serialId key:@"status" value:status isInteger:YES tableName:kNearMessageTableName];
        [_lbxManager updateMessageWithSerialId:serialId key:@"status" value:status isInteger:YES tableName:kMessageTableName];
    });

}

/// 再次发送语音
- (void)resendAudio:(ChatObject *)object isAddWaitMessage:(BOOL)isAdd isAddRemind:(BOOL)isAddRemind
{
    if (wSocket.isLoginOK == NO) {
        if ([wSocket.lbxManager checkIsHasNetwork:YES] == NO) {
            return;
        }
        [wSocket.lbxManager showHudViewLabelText:@"无网络连接" detailsLabelText:nil afterDelay:1];
        return;
    }
    ChatObject *oldObject = [wSocket.lbxManager getOneData:object.serialId];

    if (oldObject.uploadProgress >= 100) {
        return;
    } else {
    }
    
    NSString *foreignDirectory = [NSString stringWithFormat:@"%@/%@",kPathChat,object.phone];

    NSString *wavFilePath = [NSString stringWithFormat:@"%@/%@",foreignDirectory, object.filePath];
    NSString *amrName = [object.filePath stringByReplacingOccurrencesOfString:@".wav" withString:@".amr"];
    NSString *amrFilePath = [NSString stringWithFormat:@"%@/%@",foreignDirectory, amrName];
    
    int encode = [VoiceConverter wavToAmr:wavFilePath amrSavePath:amrFilePath];
    NSLog(@"amrFilePath=%@", amrFilePath);
    if (encode == 0) {
        NSLog(@"语音转码成功");
        
        [self saveSomeDataWithChatObject:object isAddWaitMessageList:isAdd isAddRemind:isAddRemind];
        
        __weak ChatObject *weakObject = object;
        __weak WSocket *weakSocket = wSocket;
        
        [wSocket addUploadFileOperationWithFilePath:amrFilePath data:nil isFilePath:YES fileType:LBX_IM_DATA_TYPE_AMR fileName:object.serialId serialId:object.serialId modelType:ModelTypeChat info:object uploadBlock:^(int ret, NSString *fileName, NSString *fileUrl) {
            if (ret >= 0) {
                
                weakObject.message = fileUrl;
                
                dispatch_sync(_lbxManager.recvQueue, ^{
                    [weakSocket.lbxManager updateMessageWithSerialId:fileName key:@"message" value:fileUrl isInteger:NO tableName:kMessageTableName];
                });
                
                [weakSocket sendMessageWithChatObject:weakObject];
            } else {
                
                [_waitMessageList addObject:weakObject];
                
                dispatch_sync(_lbxManager.recvQueue, ^{
                    
                    [weakSocket.lbxManager updateMessageWithSerialId:weakObject.serialId key:@"status" value:@"0" isInteger:YES tableName:kMessageTableName];
                    [weakSocket.lbxManager updateMessageWithSerialId:weakObject.serialId key:@"status" value:@"0" isInteger:YES tableName:kNearMessageTableName];
                });
            }
        }];
        
    }else{
        NSLog(@"语音转码失败");
        [_messageList removeObject:object];
        [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshMessageList object:[NSNumber numberWithInt:MsgChatRefrashTypeSendFailue]];
        [_lbxManager.fileManager removeItemAtPath:wavFilePath error:nil];
    }


}

/// 再次发送图片
- (void)resendImage:(ChatObject *)object isAddWaitMessage:(BOOL)isAdd isAddRemind:(BOOL)isAddRemind
{
    if (wSocket.isLoginOK == NO) {
        if ([wSocket.lbxManager checkIsHasNetwork:YES] == NO) {
            return;
        }
        [wSocket.lbxManager showHudViewLabelText:@"无网络连接" detailsLabelText:nil afterDelay:1];
        return;
    }
    ChatObject *oldObject = [wSocket.lbxManager getOneData:object.serialId];
    if (oldObject.uploadProgress >= 100) {
        [wSocket sendMessageWithChatObject:oldObject];
        NSLog(@"111222333 图片消息已经上传成功了，直接发送图片的文字消息");
        return;
    }
    
    [self saveSomeDataWithChatObject:object isAddWaitMessageList:isAdd isAddRemind:isAddRemind];
    
    NSString *foreignDirectory = [NSString stringWithFormat:@"%@/%@",kPathChat,object.phone];
    NSString *imagePath = [NSString stringWithFormat:@"%@/%@",foreignDirectory,[_lbxManager upper16_MD5:object.filePath]];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    
    __weak ChatObject *weakObject = object;
    __weak WSocket *weakSocket = wSocket;
    
    [wSocket addUploadFileOperationWithFilePath:@"" data:UIImageJPEGRepresentation(image, 0.5) isFilePath:NO fileType:LBX_IM_DATA_TYPE_PICTURE fileName:object.serialId serialId:object.serialId modelType:ModelTypeChat info:object uploadBlock:^(int ret, NSString *fileName, NSString *fileUrl) {
        if (ret >= 0) {
//            [_lbxManager.fileManager removeItemAtPath:imagePath error:nil];
            weakObject.message = fileUrl;
            weakObject.filePath = fileUrl;
            weakObject.uploadProgress = 100;
            
            NSString *foreDir = [NSString stringWithFormat:@"%@/%@",kPathChat,weakObject.phone];
            
            [UIImageJPEGRepresentation(image, 0.5) writeToFile:[NSString stringWithFormat:@"%@/%@",foreDir,[_lbxManager upper16_MD5:fileUrl]] atomically:YES];
            
            dispatch_sync(weakSocket.lbxManager.recvQueue, ^{
                [weakSocket.lbxManager updateMessageWithSerialId:weakObject.serialId key:@"filePath" value:fileUrl isInteger:NO tableName:kMessageTableName];
                [weakSocket.lbxManager updateMessageWithSerialId:weakObject.serialId key:@"uploadProgress" value:@"100" isInteger:YES tableName:kMessageTableName];
                
            });
            
            [wSocket sendMessageWithChatObject:object];
        } else {
            dispatch_sync(_lbxManager.recvQueue, ^{
                [wSocket addWaitMessage:weakObject];
                
                [_lbxManager updateMessageWithSerialId:object.serialId key:@"status" value:@"0" isInteger:YES tableName:kMessageTableName];
                [_lbxManager updateMessageWithSerialId:object.serialId key:@"status" value:@"0" isInteger:YES tableName:kNearMessageTableName];
            });
        }
    }];
    
}

/// 再次发送文字
- (void)resendText:(ChatObject *)object isAddWaitMessage:(BOOL)isAdd isAddRemind:(BOOL)isAddRemind
{
    if (wSocket.isLoginOK == NO)
    {
        if ([wSocket.lbxManager checkIsHasNetwork:YES] == NO) {
            return;
        }
        [wSocket.lbxManager showHudViewLabelText:@"无网络连接" detailsLabelText:nil afterDelay:1];
        return;
    }
    
    [self saveSomeDataWithChatObject:object isAddWaitMessageList:isAdd isAddRemind:isAddRemind];

    // 添加到消息队列准备发送
    [self sendMessageWithChatObject:object];
}

/// 将没有上传成功的文件假如待发送列表
- (void)addWaitMessage:(ChatObject *)object
{
    [_waitMessageList addObject:object];
}

/// 发送图片
- (void)sendImage:(UIImage *)image
      foreignUser:(NSString *)foreignUser
             area:(NSString *)area
      messageType:(int)messageType
          message:(NSString *)message
      destoryTime:(int)destoryTime
      serialIndex:(NSString *)serialIndex
{
    NSLog(@"发送图片");
    
    WJID *uJid = [wSocket.lbxManager getUserInfoWithPhone:foreignUser];
    
    NSString *foreignDirectory = [NSString stringWithFormat:@"%@/%@",kPathChat,foreignUser];
    NSString *imageName = [NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970]];
    NSString *imagePath = [NSString stringWithFormat:@"%@/%@",foreignDirectory,[_lbxManager upper16_MD5:imageName]];
    [UIImageJPEGRepresentation(image, 1) writeToFile:imagePath atomically:YES];

    ChatObject *object = [[ChatObject alloc] init];
    object.serialId = serialIndex;
    object.phone = foreignUser;
    object.area = area;
    object.type = messageType;
    object.message = message;
    object.destoryTime = destoryTime;
    object.status = 0;
    object.time = [NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970]];
    object.isSendMessage = YES;
    object.nickname = uJid.nickname;
    object.avatarUrl = uJid.avatarUrl;
    object.isRead = YES;
    object.voice_time = 0;
    object.f_voice_time = 0;
    object.filePath = imageName;
    object.resendCount = 0;
    object.isGroupChat = 0;
    object.groupUser = @"";
    
    if (wSocket.messageList.count <= 0) {
        long long timestamp = [[NSDate date] timeIntervalSince1970];
        
        ChatObject *object = [[ChatObject alloc] init];
        object.message = [wSocket.lbxManager turnTime:[NSString stringWithFormat:@"%lld", timestamp] formatType:2 isEnglish:NO];
        object.isSendMessage = YES;
        object.type = LBX_IM_DATA_TYPE_TIME;
        object.time = [NSString stringWithFormat:@"%lld",timestamp];
        [wSocket.messageList addObject:object];
    }
    
    [wSocket.messageList addObject:object];
    
    [self saveSomeDataWithChatObject:object isAddWaitMessageList:YES isAddRemind:YES];
    
    __weak ChatObject *weakObject = object;
    __weak WSocket *weakSocket = wSocket;
    
    [wSocket addUploadFileOperationWithFilePath:@"" data:UIImageJPEGRepresentation(image, 0.5) isFilePath:NO fileType:LBX_IM_DATA_TYPE_PICTURE fileName:object.serialId serialId:object.serialId modelType:ModelTypeChat info:object uploadBlock:^(int ret, NSString *fileName, NSString *fileUrl) {
        if (ret >= 0) {
//            [_lbxManager.fileManager removeItemAtPath:imagePath error:nil];
            weakObject.message = fileUrl;
            weakObject.filePath = fileUrl;
            weakObject.uploadProgress = 100;
            
            NSString *foreDir = [NSString stringWithFormat:@"%@/%@",kPathChat,weakObject.phone];

            [UIImageJPEGRepresentation(image, 0.5) writeToFile:[NSString stringWithFormat:@"%@/%@",foreDir,[_lbxManager upper16_MD5:fileUrl]] atomically:YES];
            
            dispatch_sync(weakSocket.lbxManager.recvQueue, ^{
                [weakSocket.lbxManager updateMessageWithSerialId:weakObject.serialId key:@"filePath" value:fileUrl isInteger:NO tableName:kMessageTableName];
                [weakSocket.lbxManager updateMessageWithSerialId:weakObject.serialId key:@"uploadProgress" value:@"100" isInteger:YES tableName:kMessageTableName];

            });
            
            [wSocket sendMessageWithChatObject:object];
        } else {
            dispatch_sync(_lbxManager.recvQueue, ^{
                [wSocket addWaitMessage:weakObject];

                [_lbxManager updateMessageWithSerialId:object.serialId key:@"status" value:@"0" isInteger:YES tableName:kMessageTableName];
                [_lbxManager updateMessageWithSerialId:object.serialId key:@"status" value:@"0" isInteger:YES tableName:kNearMessageTableName];
            });
        }
    }];
}

/// 发送语音
- (void)sendAudioWithChatObject:(ChatObject *)object
                    wavFilePath:(NSString *)wavFilePath
                        wavName:(NSString *)wavName
                    amrFilePath:(NSString *)amrFilePath
                     timeObject:(ChatObject *)timeObject;
{
    if (object) {
        NSLog(@"发送语音   %@",object);
        object.filePath = wavName;
        int encode = [VoiceConverter wavToAmr:wavFilePath amrSavePath:amrFilePath];
        NSLog(@"amrFilePath=%@", amrFilePath);
        if (encode == 0) {
            NSLog(@"语音转码成功");
           
            [self saveSomeDataWithChatObject:object isAddWaitMessageList:YES isAddRemind:YES];
            
            __weak ChatObject *weakObject = object;
            __weak WSocket *weakSocket = wSocket;
            
            [wSocket addUploadFileOperationWithFilePath:amrFilePath data:nil isFilePath:YES fileType:LBX_IM_DATA_TYPE_AMR fileName:object.serialId serialId:object.serialId modelType:ModelTypeChat info:object uploadBlock:^(int ret, NSString *fileName, NSString *fileUrl) {
                if (ret >= 0) {
                    
                    weakObject.message = fileUrl;
                    
                    dispatch_sync(weakSocket.lbxManager.recvQueue, ^{
                        [weakSocket.lbxManager updateMessageWithSerialId:fileName key:@"message" value:fileUrl isInteger:NO tableName:kMessageTableName];
                    });
                    
                    [weakSocket sendMessageWithChatObject:weakObject];
                } else {
                    dispatch_sync(weakSocket.lbxManager.recvQueue, ^{
                        [wSocket addWaitMessage:weakObject];

                        [weakSocket.lbxManager updateMessageWithSerialId:weakObject.serialId key:@"status" value:@"0" isInteger:YES tableName:kMessageTableName];
                        [weakSocket.lbxManager updateMessageWithSerialId:weakObject.serialId key:@"status" value:@"0" isInteger:YES tableName:kNearMessageTableName];
                    });
                }
            }];
            
        }else{
            NSLog(@"语音转码失败");
            [_messageList removeObject:object];
            [_messageList removeObject:timeObject];
            [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshMessageList object:[NSNumber numberWithInt:MsgChatRefrashTypeSendFailue]];
            [_lbxManager.fileManager removeItemAtPath:wavFilePath error:nil];
        }
    }
}

/// 发送文字消息
- (void)sendText:(NSString *)text
     foreignUser:(NSString *)foreignUser
            area:(NSString *)area
     messageType:(int)messageType
     destoryTime:(int)destoryTime
     serialIndex:(NSString *)serialIndex
{
    WJID *uJid = [wSocket.lbxManager getUserInfoWithPhone:foreignUser];
    
    ChatObject *object = [[ChatObject alloc] init];
    object.serialId = serialIndex;
    object.phone = foreignUser;
    object.area = area;
    object.type = messageType;
    object.message = text;
    object.destoryTime = destoryTime;
    object.status = 0;
    object.time = [NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970]];
    object.isSendMessage = YES;
    object.nickname = uJid.nickname;
    object.avatarUrl = uJid.avatarUrl;
    object.isRead = YES;
    object.voice_time = 0;
    object.f_voice_time = 0;
    object.filePath = @"";
    object.resendCount = 0;
    object.isGroupChat = 0;
    object.groupUser = @"";
    
    if (wSocket.messageList.count <= 0) {
        long long timestamp = [[NSDate date] timeIntervalSince1970];

        ChatObject *object = [[ChatObject alloc] init];
        object.message = [wSocket.lbxManager turnTime:[NSString stringWithFormat:@"%lld", timestamp] formatType:2 isEnglish:NO];
        object.isSendMessage = YES;
        object.type = LBX_IM_DATA_TYPE_TIME;
        object.time = [NSString stringWithFormat:@"%lld",timestamp];
        [wSocket.messageList addObject:object];
    }
    
    [wSocket.messageList addObject:object];
    
    [self saveSomeDataWithChatObject:object isAddWaitMessageList:YES isAddRemind:YES];
    
    // 添加到消息队列准备发送
    [self sendMessageWithChatObject:object];
}

/// 发送消息
- (void)sendMessageWithChatObject:(ChatObject *)object
{
    SendMessageModel *model = [[SendMessageModel alloc] initWithChatObject:object];
    
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(sendMessageAction:) object:model];
    [_sendMessageQueue addOperation:operation];
}

/// 发送消息执行
- (void)sendMessageAction:(SendMessageModel *)model
{
    if ([_lbxManager checkIsHasNetwork:YES] == NO) {
        NSLog(@"没有网络");
    }
    
    if (_isLoginOK == NO) {
        NSLog(@"没有链接或者没有登陆");
    }
    
    ChatObject *object = model.object;
    
    NSString *hexMsg = object.message;
    char *pcData = [self stringToChar:hexMsg];
    int pcDataLen = (int)strlen(pcData);
    
    int data_type = object.type;
    NSLog(@"发送消息  %@  ---  iDataLen=====%d", hexMsg, pcDataLen);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL isRequestSuccess = NO;
        for (int i = 0; i < 5; i++) {
            NSLog(@"第%d次发送消息尝试  %@",i,object.phone);
            
            if ([object.phone hasSuffix:@"Q"]) {
                
                if (im_c_SendGroupMsg([object.serialId longLongValue], [_lbxManager.wJid.area intValue], [_lbxManager.wJid.phone longLongValue], [object.phone intValue], data_type, pcData, pcDataLen, object.destoryTime) >= 0) {
                    isRequestSuccess = YES;
                    break;
                }
            } else {
                
                if (im_c_SendUser([object.serialId longLongValue], [_lbxManager.wJid.area intValue], [_lbxManager.wJid.phone longLongValue], [object.area intValue], [object.phone longLongValue], data_type, pcData, pcDataLen, object.destoryTime) >= 0) {
                    isRequestSuccess = YES;
                    break;
                }
            }
            NSLog(@"发送消息尝试休息中》。。。");
            sleep(3);
        }
        
        if (isRequestSuccess == NO) {
            NSLog(@"发送消息失败 存储数据库");
            dispatch_sync(_lbxManager.recvQueue, ^{
                
                [_lbxManager updateMessageWithSerialId:object.serialId key:@"status" value:@"0" isInteger:YES tableName:kMessageTableName];
                [_lbxManager updateMessageWithSerialId:object.serialId key:@"status" value:@"0" isInteger:YES tableName:kNearMessageTableName];
            });
            
        } else {
            NSLog(@"消息本地执行成功  %@",object.serialId);
        }
    });
}


#pragma mark - 上传相关
/// ① 将上传任务加入队列
- (void)addUploadFileOperationWithFilePath:(NSString *)filePath
                                      data:(NSData *)fileData
                                isFilePath:(BOOL)isFilePath
                                  fileType:(FileType)type
                                  fileName:(NSString *)fileName
                                  serialId:(NSString *)serialId
                                 modelType:(ModelType)modelType
                                      info:(id)info
                               uploadBlock:(upLoadFileBlock)upLoadFileSuccess
{
    NSData *data;
    if (isFilePath && !fileData) {
        data = [NSData dataWithContentsOfFile:filePath];
    } else {
        data = fileData;
    }
    
    UploadingModel *model = [[UploadingModel alloc] initWithFileName:fileName data:data fileType:type time:0 count:0 block:upLoadFileSuccess serialId:serialId modelType:modelType info:info];
    
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(uploadWithInfo:) object:model];
    [_uploadQueue addOperation:operation];
    model.operation = operation;
}

/// ② 执行上传文件的方法 并且在这里等待文件下载完成
- (void)uploadWithInfo:(UploadingModel *)model
{
    [_uploadQueue setSuspended:YES];
    
    _upLoadFileSuccess = model.aBlock;
    _uploadingModel = model;
    
    [wSocket startUpLoadFileToServer:model.data withFileName:model.fileName withFileType:model.fileType success:^(int ret, NSString *fileName, NSString *fileUrl) {
        NSLog(@"上传完成了，刷新界面 fileUrl = %@ fileName = %@, ret = %d",fileUrl,fileName, ret);
        dispatch_async(dispatch_get_main_queue(), ^{
            [model.operation cancel];
            _upLoadFileSuccess(ret, fileName, fileUrl);
            _uploadingModel = nil;
            if (wSocket.uploadQueue.isSuspended) {
                [wSocket.uploadQueue setSuspended:NO];
            }
            
        });
    }];
}

/// ③ 执行上传文件
- (void)startUpLoadFileToServer:(NSData *)data withFileName:(NSString *)fileName withFileType:(int)type success:(upLoadFileToServer)upLoadFileToServerSuccess
{
    
    if ([_lbxManager checkIsHasNetwork:YES] == NO) {
        upLoadFileToServerSuccess(kConnectNoNetwork, @"", @"");
        return;
    }
    
    if (_isLoginOK == NO) {
        [wSocket showAlertWithTag:kRequestFailed];
        upLoadFileToServerSuccess(kRequestFailed, @"", @"");
        return;
    }
    
    _upLoadFileToServerSuccess = upLoadFileToServerSuccess;

    char *pcData = (char *)[data bytes];
    int dataLen = (int)[data length];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL isRequestSuccess = NO;
        for (int i = 0; i < 5; i++) {
            NSLog(@"第%d次上传尝试  dataLen = %d",i, dataLen);
            if (im_c_OtherUpLoad([fileName longLongValue], type, pcData, dataLen) == 0) {
                isRequestSuccess = YES;
                NSLog(@"上传尝试有结果了");
                break;
            }
            NSLog(@"上传尝试休息中》。。。");
            im_c_OtherCancleUpLoad();
            sleep(3);
        }
        
        if (isRequestSuccess == NO) {
            _upLoadFileToServerSuccess(kRequestFailed, @"", @"");
            NSLog(@"上传失败，开启下一次的上传");
        } else {
            NSLog(@"开始上传文件 is = %d",isRequestSuccess);
        }
    });
}

/// 获取上传进度
- (int)getUploadFileProgress
{
    return im_c_OtherGetUpLoadProgress();
}

/// 取消上传
- (void)cancelUploadFile
{
//    if ([_lbxManager checkIsHasNetwork:YES] == NO) {
//        return;
//    }
    //
    //    if (_isLoginOK == NO) {
    //        [wSocket showAlertWithTag:kRequestFailed];
    //        return;
    //    }
    
    if (im_c_OtherCancleUpLoad() == kConnectFailue) {
        [wSocket showAlertWithTag:kRequestFailed];
        [_lbxManager showHudViewLabelText:@"取消上传失败" detailsLabelText:nil afterDelay:1];
    } else {
        [_lbxManager showHudViewLabelText:@"取消上传本地执行成功" detailsLabelText:nil afterDelay:1];
    }
    if (wSocket.upLoadFileToServerSuccess) {
        wSocket.upLoadFileToServerSuccess(-1, @"", @"");
        wSocket.upLoadFileToServerSuccess = nil;
    } else {
        if (wSocket.uploadQueue.isSuspended) {
            [wSocket.uploadQueue setSuspended:NO];
        }
    }
    _uploadingModel = nil;
    
}

/// 当前上传的模型
- (UploadingModel *)getUploadingModel
{
    return _uploadingModel;
}



#pragma mark - 下载相关
/// 下载之前检查一下本地是都有数据
- (BOOL)localIsHasFile:(NSString *)str downBlock:(downLoadBlock)downFileSuccess
{
    if (str.length <= 0 || [str isEqualToString:@"(null)"] || [str isEqualToString:@"<null>"]) {
        downFileSuccess(-1, 0, nil, str);
        return YES;
    }
    
    // MD5的路径， 本地存储文件都是MD5编码
    NSString *pathMD5 = [_lbxManager upper16_MD5:str];
    
    NSData *data = nil;
    
    // 1. 检查头像路径
    NSString *avatarPath = [NSString stringWithFormat:@"%@/%@",kPathAvatar,pathMD5];
    data = [NSData dataWithContentsOfFile:avatarPath];
    if (data) {
        downFileSuccess(0, 0, data, str);
        return YES;
    }
    
    // 2. 检查普通图片路径
    NSString *imagePath = [NSString stringWithFormat:@"%@/%@",kPathPicture, pathMD5];
    data = [NSData dataWithContentsOfFile:imagePath];
    if (data) {
        downFileSuccess(0, 0, data, str);
        return YES;
    }
    
    // 3. 检查普通视频路径
    NSString *videoPath = [NSString stringWithFormat:@"%@/%@.mp4",kPathVideo, pathMD5];
    data = [NSData dataWithContentsOfFile:videoPath];
    if (data) {
        downFileSuccess(0, 0, data, str);
        return YES;
    }
    
    // 4. 检查普通声音路径
    NSString *audioPath = [NSString stringWithFormat:@"%@/%@",kPathVoice, pathMD5];
    data = [NSData dataWithContentsOfFile:audioPath];
    if (data) {
        downFileSuccess(0, 0, data, str);
        return YES;
    }
    
    // 5. 检查聊天里面的路径(包括图片和视频和声音) 如果talkingUser是正在聊天的
    if (_lbxManager.wJid.talkingUser.length) {
        NSString *chatPath = [NSString stringWithFormat:@"%@/%@/%@",kPathChat,_lbxManager.wJid.talkingUser,pathMD5];
        data = [NSData dataWithContentsOfFile:chatPath];
        if (data) {
            downFileSuccess(0, 0, data, str);
            return YES;
        } else {
            data = [NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@.mp4",chatPath]];
            if (data) {
                downFileSuccess(0, 0, data, str);
                return YES;
            }
        }
    }
    
    return NO;
}

/// ① 将下载任务添加到队列
- (void)addDownFileOperationWithFileUrlString:(NSString *)fileUrl
                                     serialId:(NSString *)serialId
                                    modelType:(ModelType)modelType
                                         info:(id)info
                                    downBlock:(downLoadBlock)downFileSuccess
{
    if ([self localIsHasFile:fileUrl downBlock:downFileSuccess]) {
        return;
    }
    
    DownloadingModel *model = [[DownloadingModel alloc] initWithFileUrl:fileUrl time:0 count:0 block:downFileSuccess serialId:serialId modelType:modelType info:info];
    
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(downLoadWithInfo:) object:model];
    [_downQueue addOperation:operation];
    model.operation = operation;
}

/// ② 执行任务下载方法
- (void)downLoadWithInfo:(DownloadingModel *)model
{
    if ([self localIsHasFile:model.fileUrl downBlock:model.aBlock]) {
        return;
    }
    
    [_downQueue setSuspended:YES];
    
    _downFileSuccess = model.aBlock;
    _downingModel = model;
    
    [wSocket startDownLoadFileFromServer:model.fileUrl success:^(int ret, NSData *data, NSString *fileUrl) {
        NSLog(@"下载完成了, 刷新界面");
        [model.operation cancel];
        _downFileSuccess(ret, 1, data, fileUrl);
        _downingModel = nil;
        if (wSocket.downQueue.isSuspended) {
            [wSocket.downQueue setSuspended:NO];
        }
    }];
}

/// ③ 执行下载
- (void)startDownLoadFileFromServer:(NSString *)url success:(downLoadFileFromServer)downLoadFileFromServerSuccess
{
    
    if ([_lbxManager checkIsHasNetwork:YES] == NO) {
        downLoadFileFromServerSuccess(kConnectNoNetwork, nil, @"");
        return;
    }
    
    if (_isLoginOK == NO) {
        [wSocket showAlertWithTag:kRequestFailed];
        downLoadFileFromServerSuccess(kRequestFailed, nil, @"");
        return;
    }
    
    _downLoadFileFromServerSuccess = downLoadFileFromServerSuccess;

    char *fileUrl = [wSocket stringToChar:url];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL isRequestSuccess = NO;
        for (int i = 0; i < 4; i++) {
            if (im_c_OtherDownLoad(fileUrl) == 0) {
                isRequestSuccess = YES;
                break;
            }
            
            im_c_OtherCancleDownLoad();
            sleep(3);
        }
        
        if (isRequestSuccess == NO) {
            _downLoadFileFromServerSuccess(kRequestFailed, nil, @"");
            NSLog(@"下载失败，开启下一次的下载");
        } else {
            NSLog(@"开始下载文件");
        }
    });
}

/// 获取当前的下载进度
- (int)getDownloadFileProgress
{
    return im_c_OtherGetDownLoadProgress();
}

/// 取消下载
- (void)cancelDownloadFile
{
//    if ([_lbxManager checkIsHasNetwork:YES] == NO) {
//        return;
//    }
//    
//    if (_isLoginOK == NO) {
//        [wSocket showAlertWithTag:kRequestFailed];
//        return;
//    }
    
    if (im_c_OtherCancleDownLoad() == kConnectFailue) {
        [wSocket showAlertWithTag:kRequestFailed];
        [_lbxManager showHudViewLabelText:@"取消下载失败" detailsLabelText:nil afterDelay:1];
    } else {
        [_lbxManager showHudViewLabelText:@"取消下载本地执行成功" detailsLabelText:nil afterDelay:1];
    }
    if (wSocket.downLoadFileFromServerSuccess) {
        wSocket.downLoadFileFromServerSuccess(kRequestFailed, nil, @"");
        wSocket.downLoadFileFromServerSuccess = nil;
    } else {
        if (wSocket.downQueue.isSuspended) {
            [wSocket.downQueue setSuspended:NO];
        }
    }
    _downingModel = nil;
}

/// 当前下载的模型
- (DownloadingModel *)getDowningModel
{
    return _downingModel;
}

#pragma mark -地图相关
/// 上传个人位置
- (void)reportLocation:(CLLocationCoordinate2D)coor
{
    if ([_lbxManager checkIsHasNetwork:YES] == NO) {
        return;
    }
    
    if (_isLoginOK == NO) {
        [wSocket showAlertWithTag:kRequestFailed];
        return;
    }
    
    if (im_c_ReportLocation(coor.longitude, coor.latitude) == kConnectFailue) {
        [wSocket showAlertWithTag:kRequestFailed];
    } else {
        NSLog(@"终于提交到服务器位置了");
    }
}


/// 收到鹰眼消息或者聊天消息、来刷新主界面的提示框 messageStyle 1为聊天 2为Giraffe
- (void)receiveMessageStye:(int)messageStyle
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (messageStyle == 1) {
        NSString *messageCountKey = [NSString stringWithFormat:@"%@%@",kRootMessageTipCount,_lbxManager.wJid.phone];
        int messageCount = [[[NSUserDefaults standardUserDefaults] objectForKey:messageCountKey] intValue];
        int endCount = messageCount + 1;
        [userDefaults setObject:[NSString stringWithFormat:@"%d",endCount] forKey:messageCountKey];
        [userDefaults synchronize];

    } else if (messageStyle == 2) {
        NSString *giraffeCountKey = [NSString stringWithFormat:@"%@%@",kRootGiraffeTipCount,_lbxManager.wJid.phone];
        int giraffeCount = [[[NSUserDefaults standardUserDefaults] objectForKey:giraffeCountKey] intValue];
        int endCount = giraffeCount + 1;
        [userDefaults setObject:[NSString stringWithFormat:@"%d",endCount] forKey:giraffeCountKey];
        [userDefaults synchronize];
        [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateGiraffeCount object:@"1"];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kRootUpdateTipCount object:[NSString stringWithFormat:@"%d",messageStyle]];
}

#pragma mark - 反馈系统
/// 反馈问题到服务器
- (int)reportFeedback:(NSString *)text
{
    char *pcData = [wSocket stringToChar:text];
    if (im_c_Feedback(pcData) == 0) {
        return 0;
    }
    return -1;
}

#pragma mark - 群聊相关
/// 执行创建群(ok)
- (void)createNewGroupWithGroupName:(NSString *)groupName groupDesc:(NSString *)groupDesc memberList:(NSString *)memberList isSuccess:(createNewGroupIsSuc)isSuccess
{
    _createGroupIsSuccess = isSuccess;
    char *pcGroupName = [wSocket stringToChar:[wSocket.lbxManager hexStringFromString:groupName]];
    char *pcTag = [wSocket stringToChar:[wSocket.lbxManager hexStringFromString:groupDesc]];
    char *pcId = [wSocket stringToChar:memberList];
    NSLog(@"pcId = %s",pcId);
    if (im_c_CreateGroup(pcGroupName, pcTag,pcId) == kConnectFailue || ![wSocket.lbxManager checkIsHasNetwork:NO]) {
        _createGroupIsSuccess(-99);
    }
}

/// 删除群（本地不用实现）(ok)
- (void)deleteGroupWithGroupId:(NSString *)groupId isSuccess:(deleteGroupIsSuc)isSuccess
{
    _deleteGroupIsSuccess = isSuccess;
    im_c_Delete_Group([groupId longLongValue]);
}

/// 添加群组成员(ok)
- (void)addFriendMemberWithGroupId:(NSString *)groupId memberId:(NSString *)users  isSuccess:(addFriendMem)isSuccess
{
    NSLog(@"邀请进的群id是%@, 人名是%@",groupId,users);
    _addFriendMember = isSuccess;
    char *pcUsers = [wSocket stringToChar:users];
    if (im_c_Add_GroupMembers([groupId longLongValue], pcUsers) == kConnectFailue || ![wSocket.lbxManager checkIsHasNetwork:NO]) {
        _addFriendMember(-99);
    }
}

/// 退出群(ok)
- (void)exitGroupWithGroupId:(NSString *)groupId isSuccess:(exitGro)isSuccess
{
    _exitGroup = isSuccess;
    if (im_c_Exit_Group([groupId longLongValue]) == kConnectFailue || ![wSocket.lbxManager checkIsHasNetwork:NO]) {
        _exitGroup(-99);
    }
}

/// 删除群里的某个人(ok)
- (void)removeOneMember:(NSString *)member fromGroupId:(NSString *)groupId isSuccess:(exitGro)isSuccess
{
    _removeGroup = isSuccess;
    if (im_c_DelGroupMember([groupId longLongValue],86,[member longLongValue]) == kConnectFailue || ![wSocket.lbxManager checkIsHasNetwork:NO]) {
        _removeGroup(-99);
    }
}

/// 获取我的群列表（ok）
- (void)getMyGroupList
{
    im_c_Get_MyGroup_List();
}

/// 返回群列表
- (void)getMyGroupList:(NSDictionary *)rootDict
{
    NSLog(@"群列表获取的回调");
    for (NSDictionary *dict in [rootDict objectForKey:@"group_list"]) {
        NSLog(@"群的内容是 = %@",dict);
        
    }
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"getMyGroupListReceive" object:rootDict];
    
}

/// 获取群里的成员列表(ok)
- (void)getGroupMemberList:(NSString *)groupId lastId:(NSString *)lastId
{
    NSLog(@"获取群里的成员列表信息 %@  ---   %@", groupId, lastId);
    if (im_c_Get_GroupMember_List([groupId longLongValue], [lastId longLongValue]) == kConnectFailue || ![wSocket.lbxManager checkIsHasNetwork:NO]) {
        [wSocket.lbxManager showHudViewLabelText:@"网络连接失败" detailsLabelText:nil afterDelay:1];
    }
}

/// 群成员列表获取回掉（ok）
- (void)getGroupMemberList:(NSDictionary *)rootDict
{
    NSLog(@"获取群内的成员列表信息的回调");
    
    NSUserDefaults *userDetaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *cacheGroupMemberInfo = [[NSMutableDictionary alloc] initWithDictionary:[userDetaults objectForKey:@"group_member_list_info"]];
    if (cacheGroupMemberInfo == nil) {
        cacheGroupMemberInfo = [[NSMutableDictionary alloc] init];
    }
    
    NSArray *array = [rootDict objectForKey:@"User_list"];
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    NSMutableArray *memberList = [[NSMutableArray alloc] init]; // 这个是用来添加人进入群的时候的人名检测
    for (NSDictionary *dict in array) {
        WJID *uJid = [[WJID alloc] init];
        uJid.phone = [dict objectForKey:@"user_id"];
        // 这里用waiteGiraffeCount代替数据库里面的id
        uJid.waiteGiraffeCount = [[dict objectForKey:@"id"] intValue];
        uJid.sex = [dict objectForKey:@"user_sex"];
        uJid.nickname = [wSocket.lbxManager stringFromHexString:[dict objectForKey:@"user_name"]];
        [dataArray addObject:uJid];
        [memberList addObject:uJid.phone];
        
        // 缓存到临时字典
        NSMutableDictionary *aDict = [[NSMutableDictionary alloc] init];
        [aDict setObject:uJid.phone forKey:@"phone"];
        [aDict setObject:uJid.sex forKey:@"sex"];
        [aDict setObject:uJid.nickname forKey:@"nickname"];
        [cacheGroupMemberInfo setObject:aDict forKey:[NSString stringWithFormat:@"%@_group",uJid.phone]];
    }
    [userDetaults setObject:cacheGroupMemberInfo forKey:@"group_member_list_info"];
    [userDetaults synchronize];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:dataArray forKey:@"dataArray"];
    [dict setObject:memberList forKey:@"memberList"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"getGroupMemberListRet" object:dict];
}



@end
