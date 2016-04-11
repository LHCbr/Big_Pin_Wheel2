//
//  LBXManager.h
//  BigPinwheel
//
//  Created by 徐伟 on 16/1/15.
//  Copyright © 2016年 leita. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "AppDelegate.h"
#import "WJID.h"
#import "DFCUserInfo.h"
#import <Photos/Photos.h>
#import <Contacts/Contacts.h>
#import "pop/POP.h"
#import "ChatObject.h"
#import "NearMessageObject.h"
#import "ExpressionView.h"
#import "MoreView.h"
#import "DBConnect.h"
#import "DFCUserInfo.h"
#import "MBProgressHUD.h"

#define kDefaultNull               @"(null)"
#define kSettingTableName          @"setting"
#define kNearMessageTableName      @"nearMessagelist"
#define kRelationshipTableName     @"relationship"
#define kFriendListTableName       @"friendList"
#define kUserInfoTableName         @"userInfo"
#define kMessageTableName          @"message"
#define kVideoHomeTableName        @"videoname"
#define kDFCUserinfoTableName      @"dfcuserinfoname"  
#define kDFCDriverPriceTableName   @"dfcDriverPrice"
#define kDFCFarmerFilterList       @"dfcfarmerfilterlist"
#define kDFCDriverFilterList       @"dfcdriverfilterlist"

#define kPageSize 30
#define kBetweenTime 86400

enum ValidateType {
    ValidateTypeNone = 0,         // 我加好友的请求失败
    ValidateTypeWait,             // 我叫对方好友，等待对方验证
    ValidateTypeWaitAccept,       // 对方加我好友，我还没有答应他
    ValidateTypeFriend,           // 我们已经是好友了
    ValidateTypeDelete,           // 我删除的好友
    ValidateTypeFans,             // 我是他的粉丝
    ValidateTypeMyFans,           // 他是我的粉丝
    ValidateTypeEachOther,        // 我们是互粉
};

enum FriendType {
    FriendTypeNone = 0,           // 普通好友
    FriendTypeFans,               // 我的粉丝
    FriendTypeIdol,               // 我的关注
};



@interface InscriptionManager : NSObject<UIAlertViewDelegate>

@property(strong,nonatomic)NSFileManager *fileManager;
@property(strong,nonatomic)WJID *wJid;                             //用户信息
@property(strong,nonatomic)DFCUserInfo *dfcInfo;
@property(strong,nonatomic)DBConnect *dbConnect;

@property(assign,nonatomic)BOOL isBackGroundOperation;
@property(strong,nonatomic)dispatch_queue_t userInfoQueue;         //用户信息数据线程
@property(strong,nonatomic)dispatch_queue_t recvQueue;             //聊天消息数据线程
@property(strong,nonatomic)dispatch_queue_t getFriendQueue;        //获取好友关系线程



#pragma mark -通用的方法
///获取单例
+(id)sharedManager;

///获取AFNetworking https
-(AFSecurityPolicy *)getHttpsSetting;

///获取用户资料
-(WJID *)getWJid;

///用户是否登陆
-(BOOL)isLoginSuccess;

///获取当前前台还是后台
-(BOOL)isBackGroundOperation;

/// 获取内容的CGsize
- (CGSize)getSizeWithContent:(NSString *)content size:(CGSize)size font:(CGFloat)font;

///实🍐化个人信息
-(void)intializeSelfInfo;

///获取UUID
-(NSString *)getUUID;

///上传UUID
-(void)uploadUUID;

///检查手机号是否正确
-(BOOL)checkPhoneNum:(NSString *)phone;

///获取是否记住密码选项
-(NSInteger)checkIsRemeberPassward;

///判断是否有网络
-(BOOL)checkIsHasNetwork:(BOOL)isShowAlert;

///显示指示器 在windows窗口上
- (void)showHudViewLabelText:(NSString *)text detailsLabelText:(NSString *)detailsText afterDelay:(float)delay;

///显示指示器 在普通的View上
-(void)showHubAction:(NSInteger)actionIndex showView:(UIView *)showView;


///创建存储文件夹的路径 默认存储到kRootFilePath下
-(void)creatDirectPath:(NSString *)directPath;

///保存／获取 好友的最后更新时间
-(UInt32)friendLastUpdateTimeIsGet:(BOOL)isGet withPhone:(NSString *)phone;

#pragma mark -用户权限的判断

/// 是否可以使用相机
- (BOOL)isCanUseCamera;

/// 判断用户是否可以使用相册
- (BOOL)isCanUsePhotoLibrary;

/// 是否可以使用麦克风
- (BOOL)canRecord;

/// 定位是否可以使用
- (BOOL)isCanLocation;

/// 是否可以使用通讯录
- (BOOL)isCanAddressBook;


-(MBProgressHUD *)ShowHubProgress:(NSString *)text;





#pragma mark -Pop动画效果
///POPBasicAnimation
-(POPBasicAnimation *)creatAnimationWithPropName:(NSString *)propName FunctionName:(NSString *)functionName FromValue:(NSValue *)fromValue ToValue:(NSValue*)toValue Duration:(CGFloat)duration;

///POPSpringAnimation
-(POPSpringAnimation *)creatSpringAnimationWithPropName:(NSString *)aName ToValue:(NSValue *)toValue SpringBounciness:(CGFloat)bounciness SpringSpeed:(CGFloat)springSpeed;

#pragma mark -数据库的方法操作

#pragma mark -聊天的方法
/// 完整的存入一条消息
- (void)saveChatMessageWithObject:(ChatObject *)object;

/// 更新一条消息的局部数据
- (void)updateMessageWithSerialId:(NSString *)serialId key:(NSString *)key value:(NSString *)value isInteger:(BOOL)isInteger tableName:(NSString *)tableName;

// 获取某一条聊天数据
- (ChatObject *)getOneData:(NSString *)serialId;

/// 获取聊天记录
- (int)getMsgList:(NSString *)foreignUser
             page:(int)page
       srmsgCount:(int)srmsgCount
       foreignDir:(NSString *)foreignDir
  foreignNickname:(NSString *)foreignNickname
    foreignAvatar:(NSString *)foreignAvatar;

/// 获得消息数量
- (int)getMsgPageCount:(NSString *)foreignUser;

#pragma mark - 联系人的方法
/// 好友的存储
- (void)saveFriendWithPhone:(NSString *)phone area:(NSString *)area;

/// 获取所有的好友
- (NSArray *)getAllFriendListFromLocal;

/// 是否是我的好友
- (BOOL)isSelfFriend:(NSString *)phone area:(NSString *)area;

/// 获得通讯录好友
- (NSMutableDictionary *)getAddressBook;

/// 排序
- (NSMutableArray *)sortAddressBook:(NSMutableDictionary *)friendsList;

#pragma mark - 最近消息的方法
/// 获取消息
- (NSMutableArray *)getAllMessage;

/// 消息的存储和更新
- (void)saveNearMessageWithObject:(NearMessageObject *)object;

#pragma mark - 新的用户关系表
/// 保存最新用户到这个关系表
- (void)saveUserRelationship:(NSString *)phone friendType:(int)friendType serial:(NSString *)serial;

/// 获取所有的用户关系
- (NSArray *)getAllUserRelationship;

#pragma mark - 设置的方法
/// 设置的存储
- (void)saveSettingWithTag:(NSString *)tag value:(int)value;

/// 设置的获取
- (NSDictionary *)getSetting;

#pragma mark - 个人资料的方法
/// 存储个人资料
- (void)saveUserInfoWithObject:(WJID *)uJid;

/// 个人资料的获取
- (WJID *)getUserInfoWithPhone:(NSString *)phone;

///大风车用户数据保存
-(void)saveDfcUserintoSqlWithObjcet:(DFCUserInfo *)info;

///大风车用户数据获取
-(DFCUserInfo *)getDFCInfoFromSqlWithPhone:(NSString *)phone;

/*存储每次筛选后的最新农民信息  requestNum==0的时候，相当于条件变更后的起始plist*/
-(void)saveTheLastFilteredFarmlist:(NSDictionary *)dict Cur_idx:(int)cur_idx;

/*获取最近一次筛选后存入本地的农民信息*/
-(NSMutableArray *)getTheLastFilterFarmListWithCuridx:(int)cur_idx;

#pragma mark - 所有的表情数据和更多界面
/// 获取更多界面的view
- (MoreView *)getMoreView;

/// 获取表情的view
- (ExpressionView *)getExpressionView;

/// 获取所有的表情
- (NSDictionary *)getEmojiDict;

/// 获取所有的表情数组
- (NSArray *)getEmojiArray;

#pragma mark -字符串和16进制的转换
///十六进制转换成普通字符串
-(NSString *)stringFromHexString:(NSString *)hexString;

/// 普通字符串转换为十六进制的。
- (NSString *)hexStringFromString:(NSString *)string;




#pragma mark - MD5加密
/// MD5加密 32位加密（小写）
- (NSString *)lower32_MD5:(NSString *)str;

/// md5 16位加密 （大写）
- (NSString *)upper16_MD5:(NSString *)str;

/// 时间转换  type 默认为0， 0 是普通的几分钟前，其他之后再添加
- (NSString *)turnTime:(NSString *)timestamp formatType:(int)type isEnglish:(BOOL)isEnglish;


@end
