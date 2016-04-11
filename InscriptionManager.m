//
//  LBXManager.m
//  BigPinwheel
//
//  Created by 徐伟 on 16/1/15.
//  Copyright © 2016年 leita. All rights reserved.
//

#import "InscriptionManager.h"
#import "MyCustom.h"
#import "LBXKeychain.h"
#import "netdb.h"
#import "VersionsCheckView.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreLocation/CoreLocation.h>
#import <CommonCrypto/CommonDigest.h>
#import <AddressBook/AddressBook.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "WSocket.h"
#import <objc/runtime.h>
#import "pinyin.h"



#define UUIDKEY                    @"uuidkey"
#define kPhoneMetaData             @"^[1][3,4,5,7,8,9][\\d]{9}$"

@interface InscriptionManager()
@property(strong,nonatomic)MBProgressHUD *HUD;
@property(strong,nonatomic)NSDateFormatter *formatter;

@property (strong, nonatomic)NSMutableDictionary *emojiDict;     // 表情字典，用来检索文件内是否有表情
@property (strong, nonatomic)NSMutableArray      *emojiArray;    // 表情数据，用来排版表情界面
@property (strong, nonatomic)ExpressionView *expressionView;     // 做成全局变量的view
@property (strong, nonatomic)MoreView *moreView;                 // 更多的view


@end

@implementation InscriptionManager

///获取单例
+(InscriptionManager *)sharedManager
{
    static InscriptionManager *inscriptionManager = nil;
    static dispatch_once_t once;
    dispatch_once (&once, ^{
        inscriptionManager = [[self alloc]init];
    });
    return inscriptionManager;
}

///获取AFNetworking https
-(AFSecurityPolicy *)getHttpsSetting
{
    AFSecurityPolicy *securityPolicy =[AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
    securityPolicy.allowInvalidCertificates = YES;
    securityPolicy.validatesDomainName = NO;
    
    return securityPolicy;
}

-(instancetype)init
{
    self = [super init];
    if (self)
    {
        _fileManager = [NSFileManager defaultManager];
        _dbConnect = [DBConnect shareConnect];
        _isBackGroundOperation = NO;
        
        [self creatDirectorys];
        [self createSelfTables];
        [self intializeSelfInfo];
        [self initSomeData];
        [self getEmojiData];
        [self setNotSuccessMessageToFailStatusAction];
        
        
        _recvQueue = dispatch_queue_create("com.BigPinWheel.recvQueue", DISPATCH_QUEUE_CONCURRENT);
        _userInfoQueue = dispatch_queue_create("com.BigPinWheel.userInfoQueue", DISPATCH_QUEUE_CONCURRENT);
        _getFriendQueue = dispatch_queue_create("com.BigPinWheel.getFriendQueue", DISPATCH_QUEUE_CONCURRENT);
        
    }
    return self;
}

///创建沙盒下的文件目录
-(void)creatDirectorys
{
    [self creatDirectPath:kRootFilePath];
    [self creatDirectPath:kPathAvatar];
    [self creatDirectPath:kPathVideo];
    [self creatDirectPath:kPathVoice];
    [self creatDirectPath:kPathPicture];
    [self creatDirectPath:kPathChat];
    [self creatDirectPath:kPathPlist];
}

///获取用户资料
-(WJID *)getWJid
{
    return _wJid;
}

///用户是否登陆
-(BOOL)isLoginSuccess
{
    return _wJid.phone.length&&_wJid.password.length ? YES:NO;
}

///获取当前前台还是后台
-(BOOL)isBackGroundOperation
{
    return _isBackGroundOperation;
}

/// 获取内容的CGsize
- (CGSize)getSizeWithContent:(NSString *)content size:(CGSize)size font:(CGFloat)font
{
    CGRect contentBounds = [content boundingRectWithSize:size
                                                 options:NSStringDrawingUsesLineFragmentOrigin
                                              attributes:[NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:font]
                                                                                     forKey:NSFontAttributeName]
                                                 context:nil];
    return contentBounds.size;
}

///实🍐化个人信息
-(void)intializeSelfInfo
{
    NSString *username = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:kUserName]];
    NSString *password = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:kPassword]];
    if (username.length !=11) {
        username = @"";
        password = @"";
    }
    if (password.length<=0||[password isEqualToString:@"(null)"]||[password isEqualToString:@"<null>"] ) {
        password = @"";
    }
    _wJid = [[WJID alloc]init];
    
    WJID *uJid = [self getUserInfoWithPhone:username];
    if (uJid) {
        _wJid = uJid;
    }
    _wJid.phone = username;
    _wJid.password = password;
    
    _dfcInfo = [[DFCUserInfo alloc]init];
    
    DFCUserInfo *DfcUserInfo = [self getDFCInfoFromSqlWithPhone:username];
    if (DfcUserInfo) {
        _dfcInfo = DfcUserInfo;
    }
    
    _dfcInfo.phone_num = username;
}

/// 默认的设置
- (void)initSomeData
{
    AFNetworkReachabilityManager *netWorkReachability = [AFNetworkReachabilityManager sharedManager];
    [netWorkReachability startMonitoring];
    
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusNotReachable: {
                NSLog(@"无网络");
                break;
            }
            case AFNetworkReachabilityStatusReachableViaWiFi: {
                NSLog(@"WiFi网络");
                break;
            }
            case AFNetworkReachabilityStatusReachableViaWWAN: {
                NSLog(@"2G,3G,4G,5G网络");
                
                break;
            }
            default:
                break;
        }
    }];
    
    ////处理网络状态变化的刷新///主要应对从无网络到有网络的变化
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshSomeData:) name:AFNetworkingReachabilityDidChangeNotification object:nil];
    
    ///////////设置进入应用，推送的消息提示置为0；注意此处，IOS7以下可以直接设置 ，以上要做如下处理
    if ([[UIDevice currentDevice].systemName floatValue] > 7.0) {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
}

/// 网络发生变化时的通知
- (void)refreshSomeData:(NSNotification *)noti
{
    [[InscriptionManager sharedManager] performSelector:@selector(checkCompulsory_version) withObject:nil afterDelay:kAfterDelayTime];
    
    NSString *status = [noti object];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNetworkChange object:status];
}

/// 检测版本更新
- (void)checkCompulsory_version
{
//    dispatch_async(dispatch_get_main_queue(), ^{
//        //[[VersionsCheckView sharedVersionCheck] checkVersions];
//    });
}

/// 获取关于表情的数据
- (void)getEmojiData
{
    _emojiArray = [[NSMutableArray alloc] init];
    [_emojiArray addObjectsFromArray:@[@"[微笑]", @"[撇嘴]", @"[色]", @"[发呆]", @"[得意]", @"[流泪]", @"[害羞]", @"[闭嘴]", @"[睡]", @"[大哭]", @"[尴尬]", @"[发怒]", @"[调皮]", @"[龇牙]", @"[惊讶]", @"[难过]", @"[酷]", @"[冷汗]", @"[抓狂]", @"[吐]", @"[偷笑]", @"[可爱]", @"[白眼]", @"[傲慢]", @"[饥饿]", @"[困]", @"[惊恐]", @"[流汗]", @"[憨笑]", @"[大兵]", @"[奋斗]", @"[咒骂]", @"[疑问]", @"[嘘]", @"[晕]", @"[折磨]", @"[衰]", @"[骷髅]", @"[敲打]", @"[再见]", @"[擦汗]", @"[抠鼻]", @"[鼓掌]", @"[糗大了]", @"[坏笑]", @"[左哼哼]", @"[右哼哼]", @"[哈欠]", @"[鄙视]", @"[委屈]", @"[快哭了]", @"[阴险]", @"[亲亲]", @"[吓]", @"[可怜]", @"[菜刀]", @"[西瓜]", @"[啤酒]", @"[篮球]", @"[乒乓]", @"[咖啡]", @"[饭]", @"[猪头]", @"[玫瑰]", @"[凋谢]", @"[示爱]", @"[爱心]", @"[心碎]", @"[蛋糕]", @"[闪电]", @"[炸弹]", @"[刀]", @"[足球]", @"[瓢虫]", @"[便便]", @"[月亮]", @"[太阳]", @"[礼物]", @"[拥抱]", @"[强]", @"[弱]", @"[握手]", @"[胜利]", @"[抱拳]", @"[勾引]", @"[拳头]", @"[差劲]", @"[爱你]", @"[NO]", @"[OK]", @"[爱情]", @"[飞吻]", @"[跳跳]", @"[发抖]", @"[怄火]", @"[转圈]", @"[磕头]", @"[回头]", @"[跳绳]", @"[挥手]", @"[激动]", @"[街舞]", @"[献吻]", @"[左太极]", @"[右太极]", @"[钱]"]];
    
    NSMutableArray *array2 = [[NSMutableArray alloc] init];
    for (int i = 0; i < 106; i++) {
        NSString *imgName = [NSString stringWithFormat:@"face_%03d", i];
        [array2 addObject:imgName];
    }
    _emojiDict = [[NSMutableDictionary alloc] initWithObjects:array2 forKeys:_emojiArray];
    
    _expressionView = [[ExpressionView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, 216) m_emojiArray:_emojiArray m_emojiDictionary:_emojiDict];
    
    _moreView = [[MoreView alloc] initWithFrame:_expressionView.frame];
}

///获取UUID
-(NSString *)getUUID
{
    if ([LBXKeychain load:UUIDKEY]) {
        
        NSString *result = [LBXKeychain load:UUIDKEY];
        return result;
    } else {
        CFUUIDRef puuid = CFUUIDCreate( nil );
        CFStringRef uuidString = CFUUIDCreateString( nil, puuid );
        
        NSString *result = (NSString *)CFBridgingRelease(CFStringCreateCopy(NULL, uuidString));
        CFRelease(puuid);
        CFRelease(uuidString);
        
        [LBXKeychain save:UUIDKEY data:result];
        
        return result;
    }
    return nil;
}

///上传UUID
-(void)uploadUUID
{
    if ([self checkIsHasNetwork:YES]==NO)
    {
        return;
    }
}

///检查手机号是否正确
-(BOOL)checkPhoneNum:(NSString *)phone
{
    NSString *metaStr = kPhoneMetaData;
    NSPredicate *predict = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",metaStr];
    BOOL isMatch = [predict evaluateWithObject:phone];
    return isMatch;
}

///获取是否记住密码选项
-(NSInteger)checkIsRemeberPassward
{
    NSInteger value = [[[NSUserDefaults standardUserDefaults]objectForKey:kRemeberPassword]intValue];
    if (value ==0) {
        value = 1;
        [[NSUserDefaults standardUserDefaults]setObject:@"1" forKey:kRemeberPassword];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
    return value;
}

///判断是否有网络
-(BOOL)checkIsHasNetwork:(BOOL)isShowAlert
{
    // Create zero addy
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    // Recover reachability flags
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
    SCNetworkReachabilityFlags flags;
    
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
    
    if (!didRetrieveFlags)
    {
        printf("Error. Could not recover network reachability flags\n");
        return NO;
    }
    
    BOOL isReachable = ((flags & kSCNetworkFlagsReachable) != 0);
    BOOL needsConnection = ((flags & kSCNetworkFlagsConnectionRequired) != 0);

    BOOL isHasNetwork = (isReachable&&!needsConnection)?YES:NO;
    
    if (isHasNetwork == NO && isShowAlert == YES) {
        [self showHudViewLabelText:@"无网络连接" detailsLabelText:nil afterDelay:kAfterDelayTime];
    }
    
    if (isHasNetwork == NO) {
        WSocket *wSocket = [WSocket sharedWSocket];
        wSocket.isLoginOK = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateOnlineStatus object:@"0"];
        
    }
    return isHasNetwork;
}

///显示指示器 在windows窗口上
- (void)showHudViewLabelText:(NSString *)text detailsLabelText:(NSString *)detailsText afterDelay:(float)delay;
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_HUD)
        {
            [_HUD removeFromSuperview];
            _HUD = nil;
        }
        _HUD = [[MBProgressHUD alloc]initWithView:[UIApplication sharedApplication].keyWindow];
        _HUD.margin = 15.0f;
        _HUD.dimBackground = NO;
        _HUD.mode = MBProgressHUDModeText;
        _HUD.userInteractionEnabled = NO;
        
        [[UIApplication sharedApplication].keyWindow addSubview:_HUD];
        _HUD.labelText = text;
        _HUD.labelFont = [UIFont systemFontOfSize:13];
        if (detailsText.length) {
            _HUD.detailsLabelText = detailsText;
        }else
        {
            _HUD.detailsLabelText = nil;
        }
        [_HUD show:YES];
        [_HUD hide:YES afterDelay:delay];
        NSLog(@"显示的指示器标题是%@",text);
    });
}

-(MBProgressHUD *)ShowHubProgress:(NSString *)text
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (_HUD)
        {
            [_HUD removeFromSuperview];
            _HUD = nil;
        }
        _HUD = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
        _HUD.margin = 15.0f;
        _HUD.dimBackground = NO;
        _HUD.mode = MBProgressHUDModeIndeterminate;
        _HUD.userInteractionEnabled = NO;
        
        [[UIApplication sharedApplication].keyWindow addSubview:_HUD];
        _HUD.labelText = text;
        _HUD.labelFont = [UIFont systemFontOfSize:13];
        [_HUD show:YES];
        
    });
    return _HUD;
}

///显示指示器 在普通的View上 actionIndex==0 显示 其它隐藏
-(void)showHubAction:(NSInteger)actionIndex showView:(UIView *)showView
{
    if (actionIndex ==0&&_HUD)
    {
        [_HUD removeFromSuperViewOnHide];
        _HUD = nil;
        NSLog(@"111");
    }
    
    if (actionIndex==0&&_HUD==nil)
    {
        _HUD = [[MBProgressHUD alloc]initWithView:showView];
        _HUD.margin = 15.0f;
        _HUD.dimBackground = NO;
        _HUD.mode =MBProgressHUDModeIndeterminate;
        _HUD.userInteractionEnabled = NO;
        [showView addSubview:_HUD];
        NSLog(@"222");
    }else
    {
        [_HUD hide:YES];
        [_HUD removeFromSuperview];
        _HUD = nil;
        NSLog(@"333");
    }
}

///创建存储文件夹的路径 默认存储到kRootFilePath下
-(void)creatDirectPath:(NSString *)directPath
{
    BOOL isDirectory = NO;
    BOOL isExsited = [_fileManager fileExistsAtPath:directPath isDirectory:&isDirectory];
    if ( !(isDirectory == YES && isExsited == YES) )
    {
        [_fileManager createDirectoryAtPath:directPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

///保存／获取 好友的最后更新时间
-(UInt32)friendLastUpdateTimeIsGet:(BOOL)isGet withPhone:(NSString *)phone
{
    NSString *key = [NSString stringWithFormat:@"%@%@",kFriendLastUpdateTime,phone];
    NSUserDefaults *userDefalut = [NSUserDefaults standardUserDefaults];
    if (isGet) {
        return [[userDefalut objectForKey:key]intValue];
    }
    
    NSTimeInterval timeInterval = [[NSDate date]timeIntervalSince1970];
    NSString *lastUpdate = [NSString stringWithFormat:@"%.0f",timeInterval];
    
    [userDefalut setObject:lastUpdate forKey:key];
    [userDefalut synchronize];
    
    return 1;
}

#pragma mark -用户权限的判断 

/// 是否可以使用相机
- (BOOL)isCanUseCamera
{
    
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if(authStatus == AVAuthorizationStatusRestricted){
        NSLog(@"家长控制");
        [self showNoCanAlert:@"此应用没有相机使用权限, 您可以在\"隐私设置\"中启用访问."];
    }else if(authStatus == AVAuthorizationStatusDenied){
        NSLog(@"拒绝使用");
        [self showNoCanAlert:@"此应用没有相机使用权限, 您可以在\"隐私设置\"中启用访问."];
        return NO;
    }
    else if(authStatus == AVAuthorizationStatusAuthorized){
        NSLog(@"容许访问");
        
    }else if(authStatus == AVAuthorizationStatusNotDetermined){
        [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
            // 询问用户是否可以容许使用相机
            if(granted){
                // 容许
                NSLog(@"用户同意使用 %@", mediaType);
            } else {
                // 不容许
                NSLog(@"用户不同意使用 %@", mediaType);
            }
        }];
    }else {
        NSLog(@"错误的相机状态");
    }
    return YES;
}

/// 判断用户是否可以使用相册
- (BOOL)isCanUsePhotoLibrary
{
    ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
    if (author == ALAuthorizationStatusRestricted) {
        NSLog(@"家长控制");
        [self showNoCanAlert:@"此应用没有相册使用权限, 您可以在\"隐私设置\"中启用访问."];
        return NO;
    } else if (author == ALAuthorizationStatusDenied) {
        NSLog(@"拒绝使用");
        [self showNoCanAlert:@"此应用没有相册使用权限, 您可以在\"隐私设置\"中启用访问."];
        return NO;
    } else if (author == ALAuthorizationStatusAuthorized) {
        NSLog(@"允许使用");
    } else if (author == ALAuthorizationStatusNotDetermined) {
        
    } else {
        
        NSLog(@"错误的相册状态 author = %d",(int)author);
    }
    return YES;
}

/// 是否可以使用麦克风
- (BOOL)canRecord
{
    __block BOOL bCanRecord = YES;
    
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
        if (granted) {
            bCanRecord = YES;
        } else {
            bCanRecord = NO;
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"无法录音"
                                                                message:@"请在iPhone的“设置-隐私-麦克风”选项中，允许Boom访问你的手机麦克风"
                                                               delegate:self
                                                      cancelButtonTitle:@"取消"
                                                      otherButtonTitles:@"去开启", nil];
            alertView.tag = 95;
            [alertView show];
        }
    }];
    return bCanRecord;
}

/// 定位是否可以使用
- (BOOL)isCanLocation
{
    if([CLLocationManager locationServicesEnabled] && ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied)) {
        return YES;
    } else {
        return NO;
    }
}

/// 是否可以使用通讯录
- (BOOL)isCanAddressBook
{
    __block BOOL isCan = YES;;
    
    ABAuthorizationStatus authStatus = ABAddressBookGetAuthorizationStatus();
    
    if (authStatus != kABAuthorizationStatusAuthorized)
    {
        ABAddressBookRef addressBook = ABAddressBookCreate();
        
        ABAddressBookRequestAccessWithCompletion
        (addressBook, ^(bool granted, CFErrorRef error)
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 if (error) {
                     NSLog(@"Error: %@", (__bridge NSError *)error);
                 } else if (!granted) {
                     NSLog(@"不同意使用通讯录");
                     isCan = NO;
                     [self showNoCanAlert:@"你已拒绝使用通讯录,请在\"设置-隐私-通讯录\"中开启"];
                 } else {
                     ABAddressBookRevert(addressBook);
                     NSLog(@"同意使用通讯录");
                 }
             });
         });
    }
    
    return isCan;
}

- (void)showNoCanAlert:(NSString *)message
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"title" message:@"message" preferredStyle:UIAlertControllerStyleAlert];
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertC animated:YES completion:^{
            NSLog(@"alert完成");
        }];
                                     
        
        
                                     
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                              otherButtonTitles:@"去开启",nil];
        alert.tag = 95;
        [alert show];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:@"知道了"
                                              otherButtonTitles:nil,nil];
        alert.tag = 95;
        [alert show];
    }
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.cancelButtonIndex == buttonIndex) {
        return;
    }
    
    if (alertView.tag == 95) {
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }
    }
}


//为NSObject添加FaceBookPop动画
-(POPBasicAnimation *)creatAnimationWithPropName:(NSString *)propName FunctionName:(NSString *)functionName FromValue:(NSValue *)fromValue ToValue:(NSValue*)toValue Duration:(CGFloat)duration
{
    POPBasicAnimation *baseAnimation = [POPBasicAnimation animationWithPropertyNamed:propName];
    baseAnimation.timingFunction = [CAMediaTimingFunction functionWithName:functionName];
    baseAnimation.duration = duration;
    baseAnimation.fromValue = fromValue;
    baseAnimation.toValue = toValue;
    baseAnimation.delegate = self;
    
    return baseAnimation;
}

//springAnimation SpringSpeed默认为12
-(POPSpringAnimation *)creatSpringAnimationWithPropName:(NSString *)aName ToValue:(NSValue *)toValue SpringBounciness:(CGFloat)bounciness SpringSpeed:(CGFloat)springSpeed
{
    POPSpringAnimation *springAnimation = [POPSpringAnimation animationWithPropertyNamed:aName];
    springAnimation.toValue = toValue;
    springAnimation.springBounciness = bounciness;
    springAnimation.springSpeed =springSpeed;
    springAnimation.delegate = self;
    
    return springAnimation;
}

#pragma mark - 数据库的方法操作
/// 创建本工程所有需要的数据表
- (void)createSelfTables
{
    // 建立设置表
    if ([_dbConnect isTableOK:kSettingTableName] == NO) {
        NSString *createSettingSql = [NSString stringWithFormat:@"CREATE TABLE '%@' ('id' INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, 'fans' INTEGER default 1, 'report' INTEGER default 1, 'idol' INTEGER default 1, 'autoPlay' INTEGER default 1, 'low' INTEGER default 0, 'mute' INTEGER default 0, 'local_user' TEXT default '(null)');", kSettingTableName];
        [_dbConnect createTableSql:createSettingSql];
    }
    
    // 建立最近消息表
    if ([_dbConnect isTableOK:kNearMessageTableName] == NO) {
        NSString *createMessageSql = [NSString stringWithFormat:@"CREATE TABLE '%@' ('id' INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, 'serialId' TEXT default '0', 'phone' TEXT default '(null)', 'nickname' TEXT default '(null)', 'message' TEXT default '(null)', 'time' TEXT default '(null)', 'chatType' INTEGER default 0, 'status' INTEGER default 0, 'type' INTEGER default 0, 'avatarUrl' TEXT default '(null)', 'noReadCount' INTEGER default 0, 'local_user' TEXT default '(null)', 'isSend' INTEGER default 0);", kNearMessageTableName];
        [_dbConnect createTableSql:createMessageSql];
    }
    
    // 建立 好友名单列表  friend_source 来自哪里加的好友，暂时无用
    if ([_dbConnect isTableOK:kFriendListTableName] == NO) {
        NSString *createFriendFansIdoSql = [NSString stringWithFormat:@"CREATE TABLE '%@' ('id' INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, 'area' TEXT default '86', 'local_user' TEXT default '(null)', 'phone' TEXT default '(null)', 'friend_source' INTEGER default 0);",kFriendListTableName];
        [_dbConnect createTableSql:createFriendFansIdoSql];
    }
    
    // 建立跟我有关系的所有的人物关系 friend_type   0 我请求对方为好友请求，服务器还没有回执  1 我请求加对方为好友   2 对方请求加我好友  3 我们已经是好友  4 我已删除的好友  5 我单独关注对方，成为对方的粉丝 6 对方单独关注我，成为我的粉丝  7 我们互相关注，互相粉丝
    if ([_dbConnect isTableOK:kRelationshipTableName] == NO) {
        NSString *createNewFriendSql = [NSString stringWithFormat:@"CREATE TABLE '%@' ('id' INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, 'local_user' TEXT default '(null)', 'phone' TEXT default '(null)', 'friend_type' INTEGER default 0, 'serial' TEXT default '0');", kRelationshipTableName];
        [_dbConnect createTableSql:createNewFriendSql];
    }
    
    // 建立用户详细资料表
    if ([_dbConnect isTableOK:kUserInfoTableName] == NO) {
        NSString *createUserInfoSql = [NSString stringWithFormat:@"CREATE TABLE '%@' ('id' INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, 'phone' TEXT default '(null)', 'nickname' TEXT default '(null)', 'sex' TEXT default '(null)', 'birthday' TEXT default '(null)', 'avatarUrl' TEXT default '(null)', 'signature' TEXT default '这家伙很懒，什么都没有留下', 'area' TEXT default '86', 'personalityBg' TEXT default '(null)', 'notename' TEXT default '(null)', 'address' TEXT default '(null)', 'idolCount' INTEGER default 0, 'fansCount' INTEGER default 0, 'videoCount' INTEGER default 0, 'otherOne' TEXT default '(null)', 'otherTwo' TEXT default '(null)', otherThree TEXT default '(null)','identity' TEXT default '(null)',  'contactNum' TEXT default '(null)' );",kUserInfoTableName];
        [_dbConnect createTableSql:createUserInfoSql];
    }
    
    //建立大风车用户基本信息表
    if ([_dbConnect isTableOK:kDFCUserinfoTableName]==NO) {
        NSString *creatDFCUserInfoTableSql = [NSString stringWithFormat:@"CREATE TABLE '%@'('id' INTEGER PRIMARY KEY  AUTOINCREMENT NOT NULL, 'area_code' TEXT default '(null)','phone_num' TEXT default '(null)','sex' TEXT default '(null)','identity' TEXT default '(null)','nick_name' TEXT default '(null)', 'head_portrait' TEXT default '(null)','signature' TEXT default '(null)','birthday' TEXT default '(null)','phone_show_flag' TEXT default '(null)','phone' TEXT default '(null)','country' TEXT default '(null)' , 'province' TEXT default '(null)','city' TEXT default '(null)','region' TEXT default '(null)','remaining_addr' TEXT default '(null)','longitude' TEXT default '(null)','latitude' TEXT default '(null)','postion_update_time' TEXT default '(null)');",kDFCUserinfoTableName];
        [_dbConnect createTableSql:creatDFCUserInfoTableSql];
    }
    //建立大风车司机报价表
    if ([_dbConnect isTableOK:kDFCDriverPriceTableName]==NO) {
        NSString *creatPriceTablesql = [NSString stringWithFormat:@"CREATE TABLE '%@'('id' INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,'phone_num' TEXT default '(null)','quoted_price' TEXT default '(null)','price_id' TEXT default '(null)','provinc' TEXT default '(null)','region' TEXT default '(null)','city' TEXT default '(null)','update_time' TEXT default '(null)' );",kDFCDriverPriceTableName];
        [_dbConnect createTableSql:creatPriceTablesql];
    }
    
//    //建立大风车farmerfilterlist表
//    if ([_dbConnect isTableOK:kDFCFarmerFilterList]==NO) {
//        NSString *creatDFCfarmerlistSql = [NSString stringWithFormat:@"CREATE TABLE '%@'('id' INTEGER PRIMARY KEY  AUTOINCREMENT NOT NULL, 'area_code' TEXT default '(null)','phone_num' TEXT default '(null)','sex' TEXT default '(null)','identity' TEXT default '(null)','nick_name' TEXT default '(null)', 'head_portrait' TEXT default '(null)','signature' TEXT default '(null)','birthday' TEXT default '(null)','phone_show_flag' TEXT default '(null)','phone' TEXT default '(null)','country' TEXT default '(null)' , 'province' TEXT default '(null)','city' TEXT default '(null)','region' TEXT default '(null)','remaining_addr' TEXT default '(null)','longitude' TEXT default '(null)','latitude' TEXT default '(null)','postion_update_time' TEXT default '(null)');",kDFCFarmerFilterList];
//        [_dbConnect createTableSql:creatDFCfarmerlistSql];
//    }

    // 建立消息表  kMessageTableName
    NSString *msgsql = [NSString stringWithFormat:@"CREATE TABLE '%@' ('id' INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, 'time' TEXT default '(null)', 'isSendMessage' INTEGER default 0, 'local_user' TEXT default '(null)', 'message' TEXT default '(null)', 'status' INTEGER default 0, 'filePath' TEXT default '(null)', 'voice_time' INTEGER default 0, 'isRead' INTEGER default 0, 'phone' TEXT default '(null)', 'type' INTEGER default 0, 'serialId' TEXT default '0', 'destoryTime' INTEGER default 0, 'uploadProgress' INTEGER default 0, 'downloadProgress' INTEGER default 0, 'resendCount' INTEGER default 0, 'isGroupChat' INTEGER default 0, 'groupUser' TEXT default '(null)')", kMessageTableName];
    
    if ([_dbConnect isTableOK:kMessageTableName] == NO) {
        [_dbConnect createTableSql:msgsql];
    }
}

#pragma mark - 最近消息的方法
#pragma mark - 聊天的方法
/// 刚运行程序，设置所有的未成功的消息为失败消息
- (void)setNotSuccessMessageToFailStatusAction
{
    NSString *sql1 = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE local_user='%@' AND status='0'", kMessageTableName, _wJid.phone];
    NSArray *array1 = [[DBConnect shareConnect] getDBlist:sql1];
    for (NSDictionary *dict in array1) {
        NSString *serialId = [dict objectForKey:@"serialId"];
        NSString *updateSql1 = [NSString stringWithFormat:@"UPDATE %@ SET status='2' WHERE serialId='%@'",kMessageTableName, serialId];
        [[DBConnect shareConnect] executeInsertSql:updateSql1];
    }
    
    NSString *sql2 = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE local_user='%@' AND status='0'",kNearMessageTableName, _wJid.phone];
    NSArray *array2 = [[DBConnect shareConnect] getDBlist:sql2];
    for (NSDictionary *dict in array2) {
        NSString *serialId = [dict objectForKey:@"serialId"];
        NSString *updateSql2 = [NSString stringWithFormat:@"UPDATE %@ SET status='2' WHERE serialId='%@'",kNearMessageTableName, serialId];
        [[DBConnect shareConnect] executeInsertSql:updateSql2];
    }
}

/// 完整的存入一条消息
- (void)saveChatMessageWithObject:(ChatObject *)object
{
    NSString *sql = [NSString stringWithFormat:@"SELECT COUNT(*) count FROM %@ WHERE serialId='%@'", kMessageTableName,  object.serialId];
    int count = [[DBConnect shareConnect] getDBDataCount:sql];
    
    if (count == 0) {
        NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO %@ (time, isSendMessage, local_user, message, status, filePath, voice_time, isRead, phone, type, serialId, destoryTime, uploadProgress, downloadProgress, resendCount, isGroupChat, groupUser) values ('%@', '%d', '%@', '%@', '%d', '%@', '%d', '%d', '%@', '%d', '%@', '%d', '%d', '%d', '%d', '%d', '%@')", kMessageTableName, object.time, object.isSendMessage, _wJid.phone, object.message, object.status, object.filePath, object.voice_time, object.isRead, object.phone, object.type, object.serialId, object.destoryTime, object.uploadProgress, object.downloadProgress, object.resendCount, object.isGroupChat, object.groupUser];
        
        [_dbConnect executeInsertSql:insertSql];
    } else {
        NSString *updateSql = [NSString stringWithFormat:@"UPDATE %@ SET status='%d', filePath='%@', isRead='%d', destoryTime='%d' WHERE serialId='%@'",kMessageTableName, object.status, object.filePath, object.isRead, object.destoryTime, object.serialId];
        [_dbConnect executeUpdateSql:updateSql];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshMessageList object:[NSString stringWithFormat:@"%d",MsgChatRefrashTypeNormal]];
}

/// 更新一条消息的局部数据
- (void)updateMessageWithSerialId:(NSString *)serialId key:(NSString *)key value:(NSString *)value isInteger:(BOOL)isInteger tableName:(NSString *)tableName
{
    NSString *updateSql = [NSString stringWithFormat:@"UPDATE %@ SET %@='%@' WHERE serialId='%@'", tableName, key, value, serialId];
    if ([value isEqualToString:@"0"] && [key isEqualToString:@"status"]) {
        updateSql = [NSString stringWithFormat:@"UPDATE %@ SET %@='%d' WHERE serialId='%@' AND status!='1'", tableName, key, [value intValue], serialId];
    }
    
    
    if (isInteger) {
        updateSql = [NSString stringWithFormat:@"UPDATE %@ SET %@='%d' WHERE serialId='%@'", tableName, key, [value intValue], serialId];
        if ([value isEqualToString:@"0"] && [key isEqualToString:@"status"]) {
            updateSql = [NSString stringWithFormat:@"UPDATE %@ SET %@='%d' WHERE serialId='%@' AND status!='1'", tableName, key, [value intValue], serialId];
        }
    }
    [_dbConnect executeUpdateSql:updateSql];
    
    if ([tableName isEqualToString:kMessageTableName]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshMessageList object:[NSString stringWithFormat:@"%d",MsgChatRefrashTypeNormal]];
    }
    if ([tableName isEqualToString:kNearMessageTableName]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshNearMessageList object:nil];
    }
}

// 获取某一条聊天数据
- (ChatObject *)getOneData:(NSString *)serialId
{
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE local_user='%@' AND serialId='%@'", kMessageTableName, _wJid.phone, serialId];
    NSDictionary *dict = [_dbConnect getDBOneData:sql];
    
    ChatObject *object = [[ChatObject alloc] init];
    [object setValuesForKeysWithDictionary:dict];
    return object;
}


/// 获取聊天记录
- (int)getMsgList:(NSString *)foreignUser
             page:(int)page
       srmsgCount:(int)srmsgCount
       foreignDir:(NSString *)foreignDir
  foreignNickname:(NSString *)foreignNickname
    foreignAvatar:(NSString *)foreignAvatar
{
    NSLog(@"------------------ srmsgCount = %d",srmsgCount);
    int offset = (page - 1) * kPageSize;
    if (srmsgCount > 0) {
        offset += srmsgCount;
    }
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE local_user='%@' AND phone='%@' ORDER BY id DESC LIMIT %d,%d", kMessageTableName, _wJid.phone, foreignUser, offset, kPageSize];
    long long time1 = 0;
    long long time2 = 0;
    WSocket *wSocket = [WSocket sharedWSocket];
    if (wSocket.messageList.count > 0) {
        ChatObject *firstObj = [wSocket.messageList objectAtIndex:0];
        time1 = [firstObj.time longLongValue];
    }
    
    int isPageFinish = 1;
    long timestamp = [[NSDate date] timeIntervalSince1970];
    NSArray *array = [[DBConnect shareConnect] getDBlist:sql];
    if (array.count > 0) {
        for (NSDictionary *dictionary in array) {
            isPageFinish = 0;
            ChatObject *object = [[ChatObject alloc] init];
            [object setValuesForKeysWithDictionary:dictionary];
            
            if (wSocket.messageList.count == 0) {
                [wSocket.messageList addObject:object];
            }else{
                if (object == nil) {
                    NSLog(@"获得消息列表====%@", object);
                }else{
                    [wSocket.messageList insertObject:object atIndex:0];
                }
            }
            
            if (time1 == 0) {
                time1 = timestamp;
            }
            time2 = [object.time longLongValue];
            NSString *lastTime = [self turnTime:[NSString stringWithFormat:@"%lld", time1] formatType:2 isEnglish:NO];
            NSString *currentTime = [self turnTime:[NSString stringWithFormat:@"%lld", time2] formatType:2 isEnglish:NO];
            if (/*(time2 + kBetweenTime) <= time1*/![lastTime isEqualToString:currentTime]) {
                time1 = [object.time longLongValue];
                ChatObject *object = [[ChatObject alloc] init];
                object.message = [wSocket.lbxManager turnTime:[dictionary objectForKey:@"time"] formatType:2 isEnglish:NO];
                object.type = LBX_IM_DATA_TYPE_TIME;
                object.time = [NSString stringWithFormat:@"%lld",time1];
                if (object == nil) {
                    NSLog(@"活的消息列表时间＝＝＝＝%@",object);
                } else {
                    [wSocket.messageList insertObject:object atIndex:0];
                }
            }
        }
        
        ChatObject *firstObject = [wSocket.messageList firstObject];
        if (firstObject.type != LBX_IM_DATA_TYPE_TIME) {
            ChatObject *object = [[ChatObject alloc] init];
            object.message = [wSocket.lbxManager turnTime:firstObject.time formatType:2 isEnglish:NO];
            object.type = LBX_IM_DATA_TYPE_TIME;
            object.time = [NSString stringWithFormat:@"%lld",time1];
            if (object == nil) {
                NSLog(@"活的消息列表时间＝＝＝＝%@",object);
            } else {
                [wSocket.messageList insertObject:object atIndex:0];
            }
        }
        
    }else{
        if (page == 1) {
            ChatObject *object = [[ChatObject alloc] init];
            object.type = LBX_IM_DATA_TYPE_TIME;
            object.phone = foreignUser;
            object.nickname = foreignNickname;
            object.avatarUrl = foreignAvatar;
            //            [wSocket.messageList addObject:object];
        }
    }
    
    NSLog(@"page = %d   ispagefinish = %d",page, isPageFinish);
    [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshMessageList object:[NSString stringWithFormat:@"%d",isPageFinish]];
    
    
    return isPageFinish;
}

/// 获得消息数量
- (int)getMsgPageCount:(NSString *)foreignUser
{
    NSString *sql = [NSString stringWithFormat:@"SELECT count(*) count FROM %@ WHERE local_user='%@' AND phone='%@'", kMessageTableName, _wJid.phone, foreignUser];
    int count = [[DBConnect shareConnect] getDBDataCount:sql];
    
    int pageCount = 0;
    if (count > 0) {
        if (count % kPageSize == 0) {
            pageCount = count / kPageSize;
        }else{
            pageCount = (count / kPageSize) + 1;
        }
    }
    return pageCount;
}

#pragma mark - 联系人的方法
/// 好友的存储
- (void)saveFriendWithPhone:(NSString *)phone area:(NSString *)area
{
    NSString *sql = [NSString stringWithFormat:@"SELECT COUNT(*) count FROM %@ WHERE local_user='%@' AND phone='%@'", kFriendListTableName, _wJid.phone, phone];
    int count = [[DBConnect shareConnect] getDBDataCount:sql];
    
    if (count == 0) {
        NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO %@ (local_user, phone, area) values ('%@', '%@', '%@')",kFriendListTableName, _wJid.phone, phone, area];
        [[DBConnect shareConnect] executeInsertSql:insertSql];
    }
}

/// 获取所有的好友列表 这里来个连表查询，获取详细信息
- (NSArray *)getAllFriendListFromLocal
{
    NSString *sql = [NSString stringWithFormat:@"SELECT u.phone, u.nickname, u.sex, u.birthday, u.avatarUrl, u.signature, u.area, u.personalityBg, u.notename, u.address, u.idolCount, u.fansCount, u.videoCount FROM %@  u LEFT JOIN %@ f ON f.phone = u.phone WHERE local_user='%@'",kUserInfoTableName, kFriendListTableName, _wJid.phone];
    NSArray *array = [[DBConnect shareConnect] getDBlist:sql];
    
    if (array.count) {
        NSMutableArray *dataArray = [[NSMutableArray alloc] init];
        for (NSDictionary *dict in array) {
            WJID *uJid = [[WJID alloc] init];
            [uJid setValuesForKeysWithDictionary:dict];
            uJid.avatarUrl = [self replaceFanXieGang:NO string:uJid.avatarUrl];
            uJid.avatarUrl = [uJid.avatarUrl stringByReplacingOccurrencesOfString:@"___" withString:@"/"];
            [dataArray addObject:uJid];
        }
        return dataArray;
    }
    
    return nil;
}

/// 是否是我的好友
- (BOOL)isSelfFriend:(NSString *)phone area:(NSString *)area
{
    
    NSString *sql = [NSString stringWithFormat:@"SELECT COUNT(*) count FROM %@ WHERE local_user='%@' AND phone='%@'", kFriendListTableName, _wJid.phone, phone];
    int count = [[DBConnect shareConnect] getDBDataCount:sql];
    return count;
}

/// 获取最近消息
- (NSMutableArray *)getAllMessage
{
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE local_user='%@'",kNearMessageTableName, _wJid.phone];
    NSArray *array = [[DBConnect shareConnect] getDBlist:sql];
    
    NSMutableArray *dataArray = [[NSMutableArray alloc] initWithCapacity:array.count];
    
    for (NSDictionary *subDict in array) {
        NearMessageObject *object = [[NearMessageObject alloc] init];
        [object setValuesForKeysWithDictionary:subDict];
        [dataArray addObject:object];
    }
    
    NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"time" ascending:NO]];
    [dataArray sortUsingDescriptors:sortDescriptors];
    
    return dataArray;
}

/// 获得通讯录好友
- (NSMutableDictionary *)getAddressBook
{
    NSLog(@"获得通讯录好友");
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    NSString *sql = [NSString stringWithFormat:@"SELECT u.phone, u.nickname, u.sex, u.birthday, u.avatarUrl, u.signature, u.area, u.personalityBg, u.notename, u.address, u.idolCount, u.fansCount, u.videoCount FROM %@  u LEFT JOIN %@ f ON f.phone = u.phone WHERE local_user='%@'",kUserInfoTableName, kFriendListTableName, _wJid.phone];
    
    NSArray *array = [[DBConnect shareConnect] getDBlist:sql];
    
    for (NSDictionary *didi in array) {
        
        WJID *wJid = [[WJID alloc] init];
        [wJid setValuesForKeysWithDictionary:didi];
        wJid.avatarUrl = [self replaceFanXieGang:NO string:wJid.avatarUrl];
        wJid.avatarUrl = [wJid.avatarUrl stringByReplacingOccurrencesOfString:@"___" withString:@"/"];
        wJid.nickname = [self stringFromHexString:wJid.nickname];
        if (wJid.nickname.length <= 0 || [wJid.nickname isEqualToString:@"(null)"]) {
            
            NSMutableString *str = [[NSMutableString alloc] initWithString:wJid.phone];
            
            if (str.length == 11) {
                [str insertString:@"-" atIndex:str.length - 4];
                [str insertString:@"-" atIndex:3];
            }
            wJid.nickname = [NSString stringWithFormat:@"+%@ %@",wJid.area,str];
            
        }
        
        NSString *key = @"#";
        if (![wJid.nickname hasPrefix:@"+"]) {

            key = [wJid.nickname uppercasePinYinFirstLetter];
        }
        NSMutableArray *object = [dict objectForKey:key];
        if (object == nil){
            NSMutableArray *newobject = [[NSMutableArray alloc] init];
            [dict setObject:newobject forKey:key];
            [newobject addObject:wJid];
        }else{
            [object addObject:wJid];
        }
    }
    return dict;
}

/// 排序
- (NSMutableArray *)sortAddressBook:(NSMutableDictionary *)friendsList
{
    NSMutableArray *dGroup = [friendsList objectForKey:@"D"];
    WJID *dwJ = [[WJID alloc]init];
    if (dGroup.count>0)
    {
        for (WJID *wj in dGroup)
        {
            if ([wj.phone isEqualToString:@"888"])     //大风车团队phone:888
            {
                dwJ = wj;
                [dGroup removeObject:wj];
            }
        }
    }
    
    for (NSString *key in friendsList)
    {
        NSMutableArray *keyArray = [friendsList objectForKey:key];
        [keyArray sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2)
         {
            return [[obj1 nickname] compare: [obj2 nickname]];
        }];
    }
    
    NSArray *allkey = [friendsList allKeys];
    NSMutableArray *groups = [NSMutableArray arrayWithArray:[allkey sortedArrayUsingSelector:@selector(compare:)]];
    if ([dwJ.phone isEqualToString:@"888"])
    {
        [dGroup insertObject:dwJ atIndex:0];
    }
    
    if (groups.count>1)
    {
        [groups removeObjectAtIndex:0];
        [groups addObject:@"#"];
    }
    return groups;
}

/// 最新消息的存储和更新 每收到一条消息的时候就在这里更新一下
- (void)saveNearMessageWithObject:(NearMessageObject *)object
{
    NSString *sql = [NSString stringWithFormat:@"SELECT COUNT(*) count FROM %@ WHERE local_user='%@' AND phone='%@'", kNearMessageTableName, _wJid.phone, object.phone];
    int count = [[DBConnect shareConnect] getDBDataCount:sql];
    
    if (count == 0) {
        NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO %@ (serialId, phone, nickname, message, time, chatType, status, type, avatarUrl, noReadCount, local_user, isSend) values ('%@', '%@', '%@', '%@', '%@', %d, %d,  %d, '%@', %d, '%@', %d)",kNearMessageTableName, object.serialId, object.phone, object.nickname, object.message, object.time, object.chatType, object.status, object.type, [self specialCharactersToEscape:object.avatarUrl], object.noReadCount > 0 ? object.noReadCount : 0, _wJid.phone, object.isSend];
        [_dbConnect executeInsertSql:insertSql];
    } else {
        
        if (object.noReadCount == -1) {
            NSString *updateSql = [NSString stringWithFormat:@"UPDATE %@ SET message='%@', time='%@', status='%d', type='%d', serialId='%@', noReadCount='0', isSend='%d' WHERE local_user='%@' AND phone='%@'", kNearMessageTableName, object.message, object.time, object.status, object.type, object.serialId, object.isSend, _wJid.phone, object.phone];
            [_dbConnect executeUpdateSql:updateSql];
        } else {
            NSString *updateSql = [NSString stringWithFormat:@"UPDATE %@ SET message='%@', time='%@', status='%d', type='%d', noReadCount='%d', serialId='%@', isSend='%d' WHERE local_user='%@' AND phone='%@'", kNearMessageTableName, object.message, object.time, object.status, object.type, object.noReadCount, object.serialId, object.isSend, _wJid.phone, object.phone];
            [_dbConnect executeUpdateSql:updateSql];
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshNearMessageList object:nil];
}

#pragma mark - 设置的方法
/// 设置的存储
- (void)saveSettingWithTag:(NSString *)tag value:(int)value
{
    NSString *updateSql = [NSString stringWithFormat:@"UPDATE %@ SET %@=%d WHERE local_user='%@'", kSettingTableName, tag, value, _wJid.phone];
    [_dbConnect executeUpdateSql:updateSql];
}

/// 设置的获取
- (NSDictionary *)getSetting
{
    if (_wJid.phone.length <= 0) {
        return nil;
    }
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE local_user='%@'", kSettingTableName, _wJid.phone];
    NSDictionary *dictionary = [[DBConnect shareConnect] getDBOneData:sql];
    
    if (dictionary == nil) {
        NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO %@ (fans, report, idol, autoPlay, low, mute, local_user) values (%d, %d, %d, %d, %d, %d, '%@')", kSettingTableName, 1, 1, 1, 1, 0, 0, _wJid.phone];
        [[DBConnect shareConnect] executeInsertSql:insertSql];
        
        return [[NSDictionary alloc] initWithObjectsAndKeys:@"1",@"fans",@"1",@"report",@"1",@"idol",@"1",@"autoPlay",@"0",@"low",@"0",@"mute", nil];
    }
    
    return dictionary;
}

#pragma mark - 个人资料的方法
/// 存储个人资料
- (void)saveUserInfoWithObject:(WJID *)uJid
{
    NSString *sql = [NSString stringWithFormat:@"SELECT COUNT(*) count FROM %@ WHERE phone='%@'", kUserInfoTableName, uJid.phone];
    int count = [[DBConnect shareConnect] getDBDataCount:sql];
    
    if (count == 0) {
        NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO %@ (phone, nickname, sex, birthday, avatarUrl, signature, personalityBg, notename, address, idolCount, fansCount, videoCount, identity,  contactNum) values ('%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', %d, %d, %d, '%@', '%@')",kUserInfoTableName, uJid.phone, uJid.nickname, uJid.sex, uJid.birthday, [self replaceFanXieGang:YES string:uJid.avatarUrl], uJid.signature, uJid.personalityBg, uJid.notename, uJid.address, [uJid.idolCount intValue], [uJid.fansCount intValue], [uJid.videoCount intValue],uJid.identity,uJid.contactNum];
        [[DBConnect shareConnect] executeInsertSql:insertSql];
    } else {
        NSString *updateSql = [NSString stringWithFormat:@"UPDATE %@ SET nickname='%@', sex='%@', birthday='%@', avatarUrl='%@', signature='%@', personalityBg='%@', notename='%@', address='%@', idolCount='%d', fansCount='%d', videoCount='%d', identity='%@', contactNum = '%@' WHERE phone='%@'",kUserInfoTableName,uJid.nickname, uJid.sex, uJid.birthday, [self replaceFanXieGang:YES string:uJid.avatarUrl], uJid.signature, uJid.personalityBg, uJid.notename, uJid.address, [uJid.idolCount intValue], [uJid.fansCount intValue], [uJid.videoCount intValue],uJid.identity,uJid.contactNum,uJid.phone];
        [_dbConnect executeUpdateSql:updateSql];
    }
}

///存储大风车用户资料到sql
-(void)saveDfcUserintoSqlWithObjcet:(DFCUserInfo *)info
{
    NSString *sql = [NSString stringWithFormat:@"SELECT COUNT(*) count FROM %@ WHERE phone_num = '%@'",kDFCUserinfoTableName,info.phone_num];
    int count = [[DBConnect shareConnect]getDBDataCount:sql];
    
    if (count ==0)
    {
        NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO %@ (area_code,phone_num,sex,identity,nick_name,head_portrait,signature,birthday,phone_show_flag,phone,country,province,city,region,remaining_addr,longitude,latitude,postion_update_time)values('%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@')",kDFCUserinfoTableName,info.area_code,info.phone_num,info.sex,info.identity,info.nick_name,[self replaceFanXieGang:YES string:info.head_portrait],info.signature,info.birthday,info.phone_show_flag,info.phone,info.country,info.provice,info.city,info.region,info.remaining_addr,info.longitude,info.latitude,info.postion_update_time];
        [[DBConnect shareConnect]executeInsertSql:insertSql];
        
        if (info.quoted_price_list.count>0)
        {
            dispatch_sync(self.userInfoQueue, ^{
                for (NSInteger i =0; i<info.quoted_price_list.count; i++)
                {
                    NSDictionary *dict = [info.quoted_price_list objectAtIndex:i];
                    NSString *insertPriceSql = [NSString stringWithFormat:@"INSERT INTO %@(phone_num, quoted_price,price_id,provinc,region,city,update_time)values('%@','%@','%@','%@','%@','%@','%@')",kDFCDriverPriceTableName,info.phone_num,[dict objectForKey:@"quoted_price"],[dict objectForKey:@"price_id"],[dict objectForKey:@"provinc"],[dict objectForKey:@"region"],[dict objectForKey:@"city"],[dict objectForKey:@"update_time"]];
                    [[DBConnect shareConnect]executeInsertSql:insertPriceSql];
                }
            });
        }
    }
    else
    {
        NSString *updateSql = [NSString stringWithFormat:@"UPDATE %@ SET area_code = '%@', sex = '%@', identity = '%@',nick_name = '%@', head_portrait = '%@', signature = '%@',birthday = '%@',phone_show_flag = '%@',phone = '%@',country = '%@',province = '%@',city = '%@',region = '%@',remaining_addr = '%@',longitude = '%@',latitude = '%@',postion_update_time = '%@' WHERE phone_num = '%@'",kDFCUserinfoTableName,info.area_code,info.sex,info.identity,info.nick_name,[self replaceFanXieGang:YES string:info.head_portrait],info.signature,info.birthday,info.phone_show_flag,info.phone,info.country,info.provice,info.city,info.region,info.remaining_addr,info.longitude,info.latitude,info.postion_update_time, info.phone_num];
        
        
        [[DBConnect shareConnect]executeUpdateSql:updateSql];
        
        if (info.quoted_price_list.count>0)
        {
            NSString *delSql = [NSString stringWithFormat:@"DELETE FROM %@",kDFCDriverPriceTableName];
            [[DBConnect shareConnect]executeUpdateSql:delSql];
            
            dispatch_sync(self.userInfoQueue, ^{
                for (NSInteger i =0; i<info.quoted_price_list.count; i++)
                {
                    NSDictionary *dict = [info.quoted_price_list objectAtIndex:i];
                    NSString *insertPriceSql = [NSString stringWithFormat:@"INSERT INTO %@(phone_num,quoted_price,price_id,provinc,region,city,update_time)values('%@','%@','%@','%@','%@','%@','%@')",kDFCDriverPriceTableName,info.phone_num,[dict objectForKey:@"quoted_price"],[dict objectForKey:@"price_id"],[dict objectForKey:@"provinc"],[dict objectForKey:@"region"],[dict objectForKey:@"city"],[dict objectForKey:@"update_time"]];
                    
                    [[DBConnect shareConnect]executeInsertSql:insertPriceSql];
                }
            });
            
        }
    }
}

/*存储每次筛选后的最新农民信息  requestNum==0的时候，相当于条件变更后的起始plist*/
-(void)saveTheLastFilteredFarmlist:(NSDictionary *)dict Cur_idx:(int)cur_idx
{
    if (dict)
    {
        [dict writeToFile:[NSString stringWithFormat:@"%@/%@%d",kPathPlist,[self upper16_MD5:kDFCFarmerFilterList],cur_idx] atomically:YES];
    }
}

/*获取最近一次筛选后存入本地的农民信息*/
-(NSMutableArray *)getTheLastFilterFarmListWithCuridx:(int)cur_idx
{
    
    NSDictionary *farmlist = [NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"%@/%@%d",kPathPlist,[self upper16_MD5:kDFCFarmerFilterList],cur_idx]];
    NSMutableArray *tempfarmlist = [[NSMutableArray alloc]init];
    
    for (NSDictionary *dict in [farmlist objectForKey:@"user_list"])
    {
        DFCUserInfo *userinfo = [[DFCUserInfo alloc]init];
        [userinfo setValuesForKeysWithDictionary:dict];
        userinfo.provice = [NSString stringWithFormat:@"%@",[dict objectForKey:@"province"]];
        userinfo.latitude = [NSString stringWithFormat:@"%@",[dict objectForKey:@"location_w"]];
        userinfo.longitude = [NSString stringWithFormat:@"%@",[dict objectForKey:@"location_j"]];
        [tempfarmlist addObject:userinfo];
    }
    NSLog(@"tempfarmlist.count = %lu,tempfarmlist.count = %@",(unsigned long)tempfarmlist.count,tempfarmlist);
    return tempfarmlist;
}

/////存储每次筛选后最新的农民信息
//-(void)saveTheLastFiltedFarmerlist:(DFCUserInfo *)info
//{
//    NSString *sql = [NSString stringWithFormat:@"SELECT COUNT(*) count FROM %@ WHERE phone_num = '%@'",kDFCFarmerFilterList,info.phone_num];
//    int count = [[DBConnect shareConnect]getDBDataCount:sql];
//    
//    if (count ==0)
//    {
//        NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO %@ (area_code,phone_num,sex,identity,nick_name,head_portrait,signature,birthday,phone_show_flag,phone,country,province,city,region,remaining_addr,longitude,latitude,postion_update_time)values('%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@')",kDFCFarmerFilterList,info.area_code,info.phone_num,info.sex,info.identity,info.nick_name,[self replaceFanXieGang:YES string:info.head_portrait],info.signature,info.birthday,info.phone_show_flag,info.phone,info.country,info.provice,info.city,info.region,info.remaining_addr,info.longitude,info.latitude,info.postion_update_time];
//        [[DBConnect shareConnect]executeInsertSql:insertSql];
//        
//    }
//    else
//    {
//        NSString *updateSql = [NSString stringWithFormat:@"UPDATE %@ SET area_code = '%@', sex = '%@', identity = '%@',nick_name = '%@', head_portrait = '%@', signature = '%@',birthday = '%@',phone_show_flag = '%@',phone = '%@',country = '%@',province = '%@',city = '%@',region = '%@',remaining_addr = '%@',longitude = '%@',latitude = '%@',postion_update_time = '%@' WHERE phone_num = '%@'",kDFCFarmerFilterList,info.area_code,info.sex,info.identity,info.nick_name,[self replaceFanXieGang:YES string:info.head_portrait],info.signature,info.birthday,info.phone_show_flag,info.phone,info.country,info.provice,info.city,info.region,info.remaining_addr,info.longitude,info.latitude,info.postion_update_time, info.phone_num];
//        
//        
//        [[DBConnect shareConnect]executeUpdateSql:updateSql];
//    }
//}

/// 个人资料的获取
- (WJID *)getUserInfoWithPhone:(NSString *)phone
{
    NSLog(@"获取用户资料");
    
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE phone='%@'", kUserInfoTableName, phone];
    NSDictionary *dict = [_dbConnect getDBOneData:sql];
    
    if (dict) {
        WJID *uJid = [[WJID alloc] init];
        [uJid setValuesForKeysWithDictionary:dict];
        uJid.phone = phone;
        uJid.avatarUrl = [self replaceFanXieGang:NO string:uJid.avatarUrl];
        NSLog(@"获取的用户资料 uJid ＝ %@",uJid);
        return uJid;
    } else {
        if ([phone hasSuffix:@"Q"]) {
            WJID *uJid = [[WJID alloc] init];
            uJid.phone = phone;
            NSLog(@"获取的用户资料 uJid ＝ %@",uJid);
            return uJid;
        }
    }
    NSLog(@"没有找到用户资料");
    return nil;
}

-(DFCUserInfo *)getDFCInfoFromSqlWithPhone:(NSString *)phone
{
    NSLog(@"从本地sql数据库获取大风车用户资料");
    
    NSString *getSql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE phone_num = '%@'",kDFCUserinfoTableName,phone];
    NSString *getPriceSql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE phone_num = '%@'",kDFCDriverPriceTableName,phone];
    
    NSDictionary *normalInfo = [_dbConnect getDBOneData:getSql];
    NSArray *pricelist = [_dbConnect getDBlist:getPriceSql];
    
    NSLog(@"normalinfo = %@,pricelist = %@",normalInfo,pricelist);
    
    if (normalInfo) {
        DFCUserInfo *userinfo = [[DFCUserInfo alloc]init];
        [userinfo setValuesForKeysWithDictionary:normalInfo];
        userinfo.head_portrait = [self replaceFanXieGang:NO string:userinfo.head_portrait];
        if (pricelist.count>0) {
            userinfo.quoted_price_list = [NSMutableArray arrayWithArray:pricelist];
        }
        NSLog(@"从本地sql数据库获取的userinfo = %@",userinfo);
        return userinfo;
    }
    NSLog(@"没有从本地sql数据库找到大风车相关资料");
    return nil;
}

#pragma mark - 新的用户关系表
/// 保存最新用户到这个关系表
- (void)saveUserRelationship:(NSString *)phone friendType:(int)friendType serial:(NSString *)serial
{
    NSString *sql = [NSString stringWithFormat:@"SELECT COUNT(*) count FROM %@ WHERE local_user='%@' AND phone='%@'", kRelationshipTableName, _wJid.phone, phone];
    int count = [[DBConnect shareConnect] getDBDataCount:sql];
    
    if (phone.length <= 0) {
        count = 0;
    }
    
    if (count == 0) {
        
        NSString *sql = [NSString stringWithFormat:@"SELECT COUNT(*) count FROM %@ WHERE serial='%@'", kRelationshipTableName, serial];
        int count2 = [[DBConnect shareConnect] getDBDataCount:sql];
        
        if ([serial isEqualToString:@"-1"]) {
            count2 = 0;
        }
        
        if (count2 != 0) {
            NSString *updateSql = [NSString stringWithFormat:@"UPDATE %@ SET friend_type='%d', phone='%@', local_user='%@' WHERE serial='%@'", kRelationshipTableName, friendType, phone, _wJid.phone, serial];
            [_dbConnect executeUpdateSql:updateSql];
        } else {
            
            NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO %@ (phone, local_user, friend_type, serial) values ('%@', '%@', %d, '%@')",kRelationshipTableName, phone, _wJid.phone, friendType, serial];
            [[DBConnect shareConnect] executeInsertSql:insertSql];
        }
    } else {
        NSString *updateSql = [NSString stringWithFormat:@"UPDATE %@ SET friend_type='%d', serial='%@' WHERE local_user='%@' AND phone='%@'", kRelationshipTableName, friendType, serial, _wJid.phone, phone];
        [_dbConnect executeUpdateSql:updateSql];
    }
}

/// 获取所有的用户关系
- (NSArray *)getAllUserRelationship
{
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE local_user='%@'",kRelationshipTableName, _wJid.phone];
    NSArray *array = [[DBConnect shareConnect] getDBlist:sql];
    
    return array;
}

#pragma mark - 所有的表情数据和更多的view
/// 获取更多界面的view
- (MoreView *)getMoreView
{
    return _moreView;
}

/// 获取表情的view
- (ExpressionView *)getExpressionView
{
    return _expressionView;
}

/// 获取所有的表情字典
- (NSDictionary *)getEmojiDict
{
    return _emojiDict;
}

/// 获取所有的表情数组
- (NSArray *)getEmojiArray
{
    return _emojiArray;
}

#pragma mark - 字符串和16进制互转
/// 十六进制转换为普通字符串的。
- (NSString *)stringFromHexString:(NSString *)hexString
{
    if (hexString.length <= 1)
    {
        return hexString;
    }
    
    for (int i = 0; i < hexString.length; i++)
    {
        char s = [hexString characterAtIndex:i];
        if (s < 48 || (s > 58 && s < 65) || (s > 70 && s < 97) || s > 102) {
            return hexString;
        }
    }
    
    char *myBuffer = (char *)malloc((int)[hexString length] / 2 + 1);
    bzero(myBuffer, [hexString length] / 2 + 1);
    for (int i = 0; i < [hexString length] - 1; i += 2) {
        unsigned int anInt;
        NSString * hexCharStr = [hexString substringWithRange:NSMakeRange(i, 2)];
        NSScanner * scanner = [[NSScanner alloc] initWithString:hexCharStr];
        [scanner scanHexInt:&anInt];
        myBuffer[i / 2] = (char)anInt;
    }
    NSString *unicodeString = [NSString stringWithCString:myBuffer encoding:4];
    if (!unicodeString || unicodeString.length <= 0 || [unicodeString isEqualToString:@" "]) {
        return hexString;
    }
    
    free(myBuffer);
    myBuffer = NULL;
    
    return unicodeString;
}

/// 普通字符串转换为十六进制的。
- (NSString *)hexStringFromString:(NSString *)string
{
    NSData *myD = [string dataUsingEncoding:NSUTF8StringEncoding];
    Byte *bytes = (Byte *)[myD bytes];
    //下面是Byte 转换为16进制。
    NSString *hexStr=@"";
    for(int i=0;i<[myD length];i++)
        
    {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];///16进制数
        
        if([newHexStr length]==1)
            
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        
        else
            
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
    }
    return hexStr;
}

#pragma mark - MD5加密
/// MD5加密 32位加密（小写）
- (NSString *)lower32_MD5:(NSString *)str
{
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, (int)strlen(cStr), result); // This is the md5 call
    return [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

/// md5 16位加密 （大写）
- (NSString *)upper16_MD5:(NSString *)str
{
    
    if (str) {
        const char *cStr = [str UTF8String];
        unsigned char result[16];
        CC_MD5( cStr, (int)strlen(cStr), result );
        return [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
                result[0], result[1], result[2], result[3],
                result[4], result[5], result[6], result[7],
                result[8], result[9], result[10], result[11],
                result[12], result[13], result[14], result[15]
                ];
    }else{
        return nil;
    }
}

/// 时间转换  type 默认为0， 0 是普通的几分钟前，1是小时、分，2是月和日，其他之后再添加
- (NSString *)turnTime:(NSString *)timestamp formatType:(int)type isEnglish:(BOOL)isEnglish
{
    long time = (long)[timestamp longLongValue];
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    int betweentime = (int)now - (int)time;
    
    int year = betweentime / (3600*24*365);
    int month = betweentime / (3600*24*30);
    int days = betweentime / (3600*24);
    int hours = betweentime % (3600*24)/3600;
    int minute = betweentime / 60;
    
    NSString *dateContent = nil;
    
    if (_formatter == nil) {
        _formatter = [[NSDateFormatter alloc] init];
        //        [_formatter setDateStyle:NSDateFormatterMediumStyle];
        //        [_formatter setTimeStyle:NSDateFormatterShortStyle];
        [_formatter setDateFormat:@"HH:mm"];
    } else {
        [_formatter setDateFormat:@"HH:mm"];
    }
    
    if (type == 0) {
        
        if (year > 0) {
            dateContent = [NSString stringWithFormat:@"%i %@", month, isEnglish ? @"year ago" : @"年前"];
        }else if (month > 0) {
            dateContent = [NSString stringWithFormat:@"%i %@", month, isEnglish ? @"month ago" : @"个月前"];
        } else if(days > 0){
            dateContent = [NSString stringWithFormat:@"%i %@", days, isEnglish ? @"day ago" : @"天前"];
        }else if(hours > 0){
            dateContent = [NSString stringWithFormat:@"%i %@", hours, isEnglish ? @"hour ago" : @"小时前"];
        }else if(minute > 0){
            dateContent = [NSString stringWithFormat:@"%i %@", minute, isEnglish ? @"min ago" : @"分钟前"];
        }else{
            dateContent = isEnglish ? @"now" : @"刚刚";
        }
        return dateContent;
    } else if (type == 1) {
        NSDate *dd = [NSDate dateWithTimeIntervalSince1970:[timestamp longLongValue]];
        dateContent = [_formatter stringFromDate:dd];
        return dateContent;
    } else if (type == 2) {
        [_formatter setDateFormat:@"MM-dd"];
        NSDate *dd = [NSDate dateWithTimeIntervalSince1970:[timestamp longLongValue]];
        dateContent = [_formatter stringFromDate:dd];
        return dateContent;
        
    } else {
        return @"刚刚啊啊";
    }
}

#pragma mark - url地址存入数据库的时候，把反斜杠转换成3个_,取出时转回来
// isReplace是yes，替换反斜杠为3个底杠 ，no则相反
- (NSString *)replaceFanXieGang:(BOOL)isReplace string:(NSString *)string
{
    if (isReplace) {
        string = [string stringByReplacingOccurrencesOfString:@"/" withString:@"___"];
    } else {
        string = [string stringByReplacingOccurrencesOfString:@"___" withString:@"/"];
    }
    return string;
}

#pragma mark - 特殊字符转义和反转义
/// 特殊字符转义
- (NSString *)specialCharactersToEscape:(NSString *)escapeStr
{
    escapeStr = (NSMutableString *)[escapeStr stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
    escapeStr = (NSMutableString *)[escapeStr stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    escapeStr = (NSMutableString *)[escapeStr stringByReplacingOccurrencesOfString:@"%" withString:@"\%"];
    escapeStr = (NSMutableString *)[escapeStr stringByReplacingOccurrencesOfString:@"&" withString:@"\\&"];
    return escapeStr;
}

/// 特殊字符反转义
- (NSString *)specialCharactersToAgainstEscape:(NSString *)escapeStr
{
    escapeStr = (NSMutableString *)[escapeStr stringByReplacingOccurrencesOfString:@"\\\\" withString:@"\\"];
    escapeStr = (NSMutableString *)[escapeStr stringByReplacingOccurrencesOfString:@"''" withString:@"'"];
    escapeStr = (NSMutableString *)[escapeStr stringByReplacingOccurrencesOfString:@"\%" withString:@"%"];
    escapeStr = (NSMutableString *)[escapeStr stringByReplacingOccurrencesOfString:@"\\&" withString:@"&"];
    return escapeStr;
}



@end
