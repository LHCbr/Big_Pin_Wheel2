//
//  ChatViewController.m
//  LuLu
//
//  Created by a on 11/12/15.
//  Copyright © 2015 lbx. All rights reserved.
//

#import "ChatViewController.h"
#import "InscriptionManager.h"
#import "WSocket.h"
#import "CheckReportViewController.h"
#import "FriendInfoViewController.h"
#import "ChatViewController.h"
#import "NameCardViewController.h"


#define kPressString            @"按住 说话"
#define kLoosenString           @"松开 结束"
#define kVoiceTime              60
#define kMsgTextViewMaxHeight   95.0f

@interface ChatViewController()<UIActionSheetDelegate>

@property (strong, nonatomic)UIView *chatInputView;          // 输入背景框
@property (strong, nonatomic)UITextView *textView;           // 输入框
@property (strong, nonatomic)UIView *textViewBg;             // 输入框背景view
@property (strong, nonatomic)UIButton *recordButton;          // 录音按钮
@property (strong, nonatomic)UIButton *audioButton;          // 选择语音按钮
@property (strong, nonatomic)UIButton *cameraButton;         // 更多按钮
@property (strong, nonatomic)UIButton *smileButton;          // 笑脸按钮

@property (assign, nonatomic)CGRect defaultInputViewFrame;   // 默认输入frame
@property (assign, nonatomic)CGRect defaultTableViewFrame;   // 默认的tableView的frame
@property (assign, nonatomic)CGRect defaultTextViewFrame;    // 默认的textView的frame

@property (strong, nonatomic)WSocket *wSocket;
@property (copy, nonatomic) NSString *foreignDirectory;      // 对方的文件夹

@property (assign, nonatomic)BOOL isKeyBoadShow;             // 键盘是否显示
@property (assign, nonatomic)BOOL isMoreViewShow;            // 更多界面是否显示
@property (assign, nonatomic)float keyboardHeight;           // 键盘显示的高度
@property (assign, nonatomic)float textViewHeight;           // 文本框里有字时的高度

@property (strong, nonatomic) NSTimer           *uploadTimer;   // 监听图片上传进度
@property (strong, nonatomic) NSTimer           *downloadTimer; // 监听图片下载进度

@property (assign, nonatomic) NSInteger         playVoiceNowIndex;
@property (strong, nonatomic) NSIndexPath       *prevIndexPath;

@property (assign, nonatomic) int               page;
@property (assign, nonatomic) int               pageCount;
@property (assign, nonatomic) int               srmsgCount;
@property (assign, nonatomic) NSInteger         prevCount;
@property (assign, nonatomic) NSInteger         offsetCount;


@property (strong, nonatomic) NSArray           *senderVoiceArray;
@property (strong, nonatomic) NSArray           *receiverVoiceArray;
@property (assign, nonatomic) CGFloat           oldHeight;

@property (nonatomic, strong) dispatch_queue_t sendQueue;         // 发送聊天消息数据线程
@property (nonatomic, strong) dispatch_queue_t getMsgQueue;       // 获取聊天消息的线程

@property (nonatomic, assign) BOOL isTapMoreView;                 // 是否点击更多界面

@end

@implementation ChatViewController

#pragma mark - 本类的通知
/// 刷新界面
- (void)refreshMessageList:(NSNotification *)noti
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        int msgChatRefrashType = [[noti object] intValue];
        
        [self fixLabelArray];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            switch (msgChatRefrashType) {
                case MsgChatRefrashTypePageNoFinish:
                {
                    if (_page == 1) {
                        [_tableView reloadData];
                        [self fixTableViewOffset];
                        return;
                    }
                    [self performSelector:@selector(doneDownReLoadingTableViewData) withObject:nil afterDelay:0.5];
                    return;
                }
                case MsgChatRefrashTypePageIsFinish:
                {
                    if (_page == 1) {
                        [_tableView reloadData];
                        [self fixTableViewOffset];
                        return;
                    }
                    [self performSelector:@selector(doneDownReLoadingTableViewData2) withObject:nil afterDelay:0.5];
                    return;
                }
                case MsgChatRefrashTypeSendSuccess:
                {
                    _prevCount = _wSocket.messageList.count;
                    break;
                }
                case MsgChatRefrashTypeReciveMsg:
                {
                    _srmsgCount++;
                    _prevCount = _wSocket.messageList.count;
                    return;
                }
                case MsgChatRefrashTypeNormal:
                {
                    _prevCount = _wSocket.messageList.count;
                    break;
                }
                case MsgChatRefrashTypeDeleteMsg:
                {
                    _prevCount = _wSocket.messageList.count;
                    break;
                }
                case MsgChatRefrashTypeSendFailue:
                {
                    _srmsgCount--;
                    _prevCount = _wSocket.messageList.count;
                    break;
                }
                case MsgChatRefrashTypeSendVoice:
                {
                    _prevCount = _wSocket.messageList.count;
                    break;
                }
                default:
                    break;
            }
            [_tableView reloadData];
            [self fixTableViewOffset];
        });
    });
}

/// 对方把我删除后，如果我当前界面是在聊天，退出聊天界面
- (void)deleteMe:(NSNotification *)noti
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:YES];
    });
}

/// 连接状态的更改
- (void)updateOnlineStatus:(NSNotification *)noti
{
    dispatch_async(dispatch_get_main_queue(), ^{
        int select = [[noti object] intValue];
        if (select == 1) {
            NSString *nickname = [_wSocket.lbxManager stringFromHexString:_uJid.nickname];
            self.navigationItem.title = nickname;
        } else {
            self.navigationItem.title = @"连接中...";
        }
    });
}

- (void)dealloc
{
    NSLog(@"和%@的聊天界面释放",[_wSocket.lbxManager stringFromHexString:_uJid.nickname]);
    _wSocket.lbxManager.wJid.talkingUser = @"";
    _expressionView.delegate = nil;
    _moreView.delegate = nil;
    [_expressionView removeFromSuperview];
    [_moreView removeFromSuperview];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_wSocket.messageList removeAllObjects];
    [self saveEndText];
    _playVoiceNowIndex = -1;
    _prevIndexPath = [NSIndexPath indexPathForRow:-1 inSection:0];
}

/// 记录最后的输入记录
- (void)saveEndText
{
    //每一次退出聊天页面都会把当前键盘上的字符串持久化到本地
    NSString *str = _textView.text;
    if (_textView.text.length <= 0) {
        str = @"";
    }
    [[NSUserDefaults standardUserDefaults] setObject:str forKey:[NSString stringWithFormat:@"%@_text",_uJid.phone]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - 监听是否来电话
- (void)resignActive:(NSNotificationCenter *)notification
{
    
    
    // 来电话将语音发送掉
    NSLog(@"来电话啦》》》》》》》》");
    [_uploadTimer setFireDate:[NSDate distantFuture]];
    [_downloadTimer setFireDate:[NSDate distantFuture]];
    [_timer setFireDate:[NSDate distantFuture]];

    _hideBgView.hidden = YES;
    _recordView.remindLabel.text = kVoiceRecordPauseString;
    [_recordButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_recordButton setTitle:kPressString forState:UIControlStateNormal];
    
    float cTime = _recorder.currentTime;
    if (_voiceIndexPath.row > 0 && cTime > 1) {
        ChatObject *object = [_wSocket.messageList objectAtIndex:_voiceIndexPath.row];
        
        RightVoiceTableViewCell *cell = (RightVoiceTableViewCell *)[_tableView cellForRowAtIndexPath:_voiceIndexPath];
        cell.activityView.hidden = NO;
        cell.timeLabel.hidden = NO;
        int voice_time = ceilf(_recorder.currentTime);
        object.voice_time = voice_time;
        float timeWidth = 16.0f;
        if (voice_time >= 10) {
            timeWidth = 24.0f;
        }
        cell.timeLabel.text = [NSString stringWithFormat:@"%d\"", voice_time];
        float voiceWidth = 40.0f;
        if (voice_time > 1) {
            voiceWidth = voiceWidth + voice_time * 2.66f;
        }
        float orginX = self.view.frame.size.width - 20 - voiceWidth - timeWidth - 50;
        cell.bgImageView.alpha = 1;
        cell.activityView.frame = CGRectMake(orginX - 30, cell.activityView.frame.origin.y, 30, 30);
        cell.voiceBtn.backgroundColor = [UIColor clearColor];
        cell.timeLabel.frame = CGRectMake(orginX, 20, timeWidth, 20);
        cell.msgView.frame = CGRectMake(orginX + timeWidth, cell.msgView.frame.origin.y, voiceWidth + 15, 40);
        cell.bgImageView.frame = CGRectMake(0, 0, voiceWidth + 15, 40);
        cell.voiceBtn.frame = CGRectMake(4, 1.5, cell.msgView.frame.size.width - 18, cell.msgView.frame.size.height - 3);
        cell.voiceImage.frame = CGRectMake(cell.voiceBtn.frame.size.width - 15, 9, 20, 20);
        [cell.activityView startAnimating];
        
        NSLog(@"cTime=%f", cTime);
        if (cTime > 0.6) { //如果录制时间 < 0.6 不发送
            NSLog(@"发出去");
            ChatObject *objectTime = _voiceTimeMsgObj;
            if (_voiceIndexPath.row >= 1) {
                ChatObject *timeObject = [_wSocket.messageList objectAtIndex:(_voiceIndexPath.row - 1)];
                if (timeObject.type == LBX_IM_DATA_TYPE_TIME && timeObject.isSendMessage == YES) {
                    objectTime = timeObject;
                }
            }
            _srmsgCount++;

            //如果录制时间 < 0.6 不发送
            dispatch_sync(_sendQueue, ^{
                self.voiceMsgObj.voice_time = voice_time;
                self.voiceMsgObj.destoryTime = voice_time;
                [_wSocket sendAudioWithChatObject:self.voiceMsgObj wavFilePath:_wavFilePath wavName:_wavName amrFilePath:_amrFilePath timeObject:objectTime];
            });
            
        }else {
            [_wSocket.messageList removeObject:_voiceTimeMsgObj];
            for (NSInteger i = _wSocket.messageList.count - 1; i >= 0; i--) {
                ChatObject *object = [_wSocket.messageList objectAtIndex:i];
                if (object.type == LBX_IM_DATA_TYPE_AMR && object.f_voice_time <= 0.6 && object.isSendMessage == YES) {
                    [_wSocket.messageList removeObjectAtIndex:i];
                }
            }
            [_tableView reloadData];
            [self fixTableViewOffset];

            [_wSocket.lbxManager showHudViewLabelText:@"录音时间太短！" detailsLabelText:nil afterDelay:1];

            // 删除存储的
            [_wSocket.lbxManager.fileManager removeItemAtPath:_wavFilePath error:nil];
        }
        [_recorder stop];
    }
    
    _voiceIndexPath = [NSIndexPath indexPathForRow:-1 inSection:0];
}


#pragma mark - M80AttributedLabelDelegate
- (void)m80AttributedLabel:(M80AttributedLabel *)label clickedOnLink:(M80AttributedLabelURL *)linkInfo
{
//    NSLog(@"isShowMenu===%d", _isShowMenu);
//    if (_isShowMenu == NO) {
//        _isShowMenu = NO;
//        if (linkInfo.linkType == LinkTypeURL) {
//            WebViewController *webVC = [[WebViewController alloc] init];
//            webVC.webUrl = linkInfo.linkInfo;
//            [self.navigationController pushViewController:webVC animated:YES];
//        }else if (linkInfo.linkType == LinkTypeEmail) {
//            _emailStr = [NSString stringWithFormat:@"%@", linkInfo.linkInfo];
//            NSString *title = [NSString stringWithFormat:@"向%@发送邮件", _emailStr];
//            UIActionSheet *emailSheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"使用默认邮件账户", nil];
//            emailSheet.tag = 300;
//            [emailSheet showInView:self.view];
//        }else if (linkInfo.linkType == LinkTypePhone) {
//            _phoneStr = [NSString stringWithFormat:@"%@", linkInfo.linkInfo];
//            NSString *title = [NSString stringWithFormat:@"%@可能是一个电话号码，你可以", _phoneStr];
//            UIActionSheet *phoneSheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"呼叫", @"复制", nil];
//            phoneSheet.tag = 301;
//            [phoneSheet showInView:self.view];
//        }
//    }
}

/// 处理text
- (void)fixLabelArray
{
    for (NSInteger i = _wSocket.messageList.count - 1; i >=0; i--) {
        ChatObject *object = [_wSocket.messageList objectAtIndex:i];
        if (object.msgRowHeight > 0) {
            
        } else {
            if (object.type == LBX_IM_DATA_TYPE_TEXT) {
                M80AttributedLabel *label = [[M80AttributedLabel alloc] initWithFrame:CGRectZero];
                label.delegate = self;
                label.autoDetectLinks = NO;
                label.underLineForLink = NO;
                label.backgroundColor = [UIColor clearColor];
                label.font = [UIFont systemFontOfSize:kFontSize];
                [self updateLabel:label text:[_wSocket.lbxManager stringFromHexString:object.message]];
                
                float labelHeight = label.frame.size.height;
                if (label.frame.size.height < 30) {
                    labelHeight = 30 + kTextTop * 2 + 3;
                }else{
                    labelHeight = labelHeight + kTextTop * 3;
                }
                object.msgLabel = label;
                object.msgRowHeight = labelHeight;
            }else {
                object.msgLabel = nil;
                object.msgRowHeight = 0.0f;
            }
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([_timer isValid] == NO) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(detectionVoice) userInfo:nil repeats:YES];
        [_timer setFireDate:[NSDate distantFuture]];
    }
    if ([_uploadTimer isValid] == NO) {
        _uploadTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(listeningUploadProgress) userInfo:nil repeats:YES];
    } else {
        [_uploadTimer setFireDate:[NSDate date]];
    }
    
    if ([_downloadTimer isValid] == NO) {
//        _downloadTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(listeningDownloadProgress) userInfo:nil repeats:YES];
    } else {
        [_downloadTimer setFireDate:[NSDate date]];
    }

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [_timer invalidate];
    _timer = nil;
    
    if (_isTapMoreView == NO) {
        [_uploadTimer invalidate];
        _uploadTimer = nil;
        [_downloadTimer invalidate];
        _downloadTimer = nil;
    } else {
        _isTapMoreView = NO;
    }
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _wSocket = [WSocket sharedWSocket];
        _timingCount = 0;
        _isKeyBoadShow = NO;
        _isMoreViewShow = NO;
        _isTapMoreView = NO;
        
        _srmsgCount = 0;
        _page = 1;
        _isPageFinish = NO;
        _prevIndexPath = [NSIndexPath indexPathForRow:-1 inSection:0];
        
        _sendQueue = dispatch_queue_create("com.lulu.sendQueue", DISPATCH_QUEUE_CONCURRENT);
        _getMsgQueue = dispatch_queue_create("com.lulu.getMsgQueue", DISPATCH_QUEUE_CONCURRENT);
        
        // 添加刷新界面的通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshMessageList:) name:kRefreshMessageList object:nil];
        // 监听电话来电
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resignActive:) name:UIApplicationWillResignActiveNotification object:nil];
        // 添加好友删除我的通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteMe:) name:kDeleteMe object:nil];
        // 添加更改状态的通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateOnlineStatus:) name:@"updateOnlineStatus" object:nil];

    }
    return self;
}

/// 创建对方文件夹
- (void)createDirectory:(NSString *)phone
{
    _foreignDirectory = [NSString stringWithFormat:@"%@/%@",kPathChat,phone];
    [_wSocket.lbxManager creatDirectPath:_foreignDirectory];
}

/// 查看好友详细
- (void)seeFriendInfo
{
    [self hideBottom];
//    FriendInfoViewController *oneInfoVC = [[FriendInfoViewController alloc] init];
//    oneInfoVC.uJid = _uJid;
//    oneInfoVC.showTitle = self.navigationItem.title;
//    [self.navigationController pushViewController:oneInfoVC animated:YES];
    
//    NameCardViewController *nameCardVC = [[NameCardViewController alloc]init];
//    [self.navigationController pushViewController:nameCardVC animated:YES];
    
    DFCUserInfo *userinfo = [_wSocket.lbxManager getDFCInfoFromSqlWithPhone:_uJid.phone];
    NameCardViewController *nameCardVC = [[NameCardViewController alloc]init];
    nameCardVC.userinfo = userinfo;
    [self.navigationController pushViewController:nameCardVC animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *uTitle = @"";
    NSString *nickname = [_wSocket.lbxManager stringFromHexString:_uJid.nickname];
    NSLog(@"nickname = %@",nickname);
    if (_uJid.friendType == mFans) {
        uTitle = [NSString stringWithFormat:@"我的粉丝-%@",nickname];
    } else if (_uJid.friendType == mIdol) {
        uTitle = [NSString stringWithFormat:@"我的关注-%@",nickname];
    } else {
        uTitle = [NSString stringWithFormat:@"我的好友-%@",nickname];
    }
    
    if ([_uJid.nickname isEqualToString:@"(null)"] || _uJid.nickname.length <= 0) {
        NSMutableString *str = [[NSMutableString alloc] initWithString:_uJid.phone];
    
        if (str.length == 11) {
            [str insertString:@"-" atIndex:str.length - 4];
            [str insertString:@"-" atIndex:3];
        }
        nickname = [NSString stringWithFormat:@"+86 %@",str];
    }

    NAVBAR(nickname);
    if (_wSocket.isLoginOK == NO) {
        self.navigationItem.title = @"连接中...";
    }
    self.view.backgroundColor = kThemeColor;
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(0, 0, 40, 40);
    [rightButton setImage:[UIImage imageNamed:@"0110_chat_default"] forState:UIControlStateNormal];
    [rightButton setExclusiveTouch:YES];
    [rightButton.layer setCornerRadius:20];
    [rightButton.layer setMasksToBounds:YES];
    [rightButton addTarget:self action:@selector(seeFriendInfo) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = -10;
    
    self.navigationItem.rightBarButtonItems = @[negativeSpacer,rightButtonItem];
    
    __weak WSocket *weakSocket = _wSocket;
    __weak UIButton *weakButton = rightButton;
    
    [_wSocket addDownFileOperationWithFileUrlString:_uJid.avatarUrl serialId:@"-1" modelType:ModelTypeNormal info:nil downBlock:^(int ret, int isSave, NSData *data, NSString *fileUrl) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (ret >= 0) {
                [weakButton setImage:[UIImage imageWithData:data] forState:UIControlStateNormal];
                if (isSave) {
                    [data writeToFile:[NSString stringWithFormat:@"%@/%@",kPathAvatar,[weakSocket.lbxManager upper16_MD5:fileUrl]] atomically:YES];
                }
            }
        });
    }];
    
    
    __weak ChatViewController *weakSelf = self;
    if (_uJid == nil || _uJid.nickname.length <= 0 || [_uJid.nickname isEqualToString:@"(null)"]) {
        if (![_uJid.phone hasSuffix:@"Q"]) {
            [_wSocket getUserInfo:_uJid.phone getUserInfoBlock:^(int ret, WJID *uJid) {
                if (ret >= 0) {
                    weakSelf.uJid = uJid;
                    [weakSelf.tableView reloadData];
                }
            }];
        }
    }
    
    _wSocket.lbxManager.wJid.talkingUser = _uJid.phone;

    _tableView.frame = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 64.0 - 40);
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    _defaultTableViewFrame = _tableView.frame;
    
    _pageCount = [_wSocket.lbxManager getMsgPageCount:_uJid.phone];
    if (_pageCount <= 1) {
        _isPageFinish = YES;
    }
    
    [_wSocket.messageList removeAllObjects];
    [_wSocket.lbxManager getMsgList:_uJid.phone page:_page srmsgCount:0 foreignDir:_foreignDirectory foreignNickname:_uJid.nickname foreignAvatar:_uJid.avatarUrl];

    if (_wSocket.messageList.count < kPageSize) {
        _isPageFinish = YES;
    }
    
    _prevCount = _wSocket.messageList.count;
    
    [self setOriZero];
        
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHide:)];
    [_tableView addGestureRecognizer:tap];
    
    // 添加输入框
    [self addInputViewAction];
    
    [self.view addSubview:_expressionView = [_wSocket.lbxManager getExpressionView]];
    _expressionView.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, _expressionView.frame.size.height);
    _expressionView.delegate = self;
    
    [self.view addSubview:_moreView = [_wSocket.lbxManager getMoreView]];
    _moreView.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, _moreView.frame.size.height);
    _moreView.delegate = self;
    
    _hideBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    _hideBgView.backgroundColor = [UIColor clearColor];
    _hideBgView.hidden = YES;
    [self.view addSubview:_hideBgView];
    
    _recordView = [[RecordView alloc] initWithFrame:CGRectMake((_hideBgView.frame.size.width - 160)/2, (_hideBgView.frame.size.height - 160)/2, 160, 160)];
    _recordView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.9];
    _recordView.layer.cornerRadius = 5;
    [_hideBgView addSubview:_recordView];
    
    _senderVoiceArray = [NSArray arrayWithObjects:[UIImage imageNamed:@"SenderVoiceNodePlaying000"],
                         [UIImage imageNamed:@"SenderVoiceNodePlaying001"],
                         [UIImage imageNamed:@"SenderVoiceNodePlaying002"],
                         [UIImage imageNamed:@"SenderVoiceNodePlaying003"],nil];
    _receiverVoiceArray = [NSArray arrayWithObjects:[UIImage imageNamed:@"ReceiverVoiceNodePlaying000"],
                           [UIImage imageNamed:@"ReceiverVoiceNodePlaying001"],
                           [UIImage imageNamed:@"ReceiverVoiceNodePlaying002"],
                           [UIImage imageNamed:@"ReceiverVoiceNodePlaying003"],nil];
    
    _setting = [NSDictionary dictionaryWithObjectsAndKeys:
                [NSNumber numberWithFloat:8000], AVSampleRateKey,
                [NSNumber numberWithInt:kAudioFormatLinearPCM], AVFormatIDKey,
                [NSNumber numberWithInt:16], AVLinearPCMBitDepthKey,//采样位数 默认 16
                [NSNumber numberWithInt:1], AVNumberOfChannelsKey,
                nil];
}

#pragma mark - 刷新
/// 获得新数据
- (void)waveRefrashNewData
{
    _prevCount = _wSocket.messageList.count;
    if (_pageCount > 1) {
        dispatch_sync(_getMsgQueue, ^{
            _page++;
            _isPageFinish = [_wSocket.lbxManager getMsgList:_uJid.phone page:_page srmsgCount:_srmsgCount foreignDir:_foreignDirectory foreignNickname:_uJid.nickname foreignAvatar:_uJid.avatarUrl];
        });
    }
}

- (void)EndTriggerRefresh
{
    NSLog(@"结束刷新");
    NSInteger nowCount = _wSocket.messageList.count;
    _offsetCount = nowCount - _prevCount;
    
    NSLog(@"%ld  %ld   %ld",nowCount, _prevCount, _offsetCount);
    _prevCount = nowCount;
    [_tableView reloadData];
    if (_offsetCount >= 0) {
        [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_offsetCount inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
}

#pragma mark - Table view datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_wSocket.messageList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChatObject *msgObj = [_wSocket.messageList objectAtIndex:indexPath.row];
    ChatObject *nextObj = nil;
    if (msgObj.type != LBX_IM_DATA_TYPE_TIME && msgObj.type != LBX_IM_DATA_TYPE_SYSTEM) {
        if (_wSocket.messageList.count > indexPath.row + 1) {
            nextObj = [_wSocket.messageList objectAtIndex:indexPath.row + 1];
        }
        
        if (nextObj) {
            if (nextObj.type == LBX_IM_DATA_TYPE_SYSTEM || nextObj.type == LBX_IM_DATA_TYPE_TIME) {
                nextObj = nil;
            }
        }
    }

    if (msgObj.type == LBX_IM_DATA_TYPE_TIME) {
        static NSString *identifier1 = @"chat_time_cell";
        TimeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier1];
        if (cell == nil) {
            cell = [[TimeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier1];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setMsgContent:msgObj.message];
        return cell;
        
    } else {
        if (msgObj.isSendMessage) {
            if (msgObj.type == LBX_IM_DATA_TYPE_TEXT) {
                static NSString *identifier3 = @"chat_right_text_cell";
                RightTextTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier3];
                if (cell == nil) {
                    cell = [[RightTextTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier3];
                }
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.rowIndex = indexPath.row;
                cell.indexPath = indexPath;
                cell.delegate = self;
                [cell setMsgContent:msgObj];
                if (nextObj && nextObj.isSendMessage) {
                    cell.bgImageView.image = cell.roundGreenImage;
                    if (_wSocket.messageList.count == indexPath.row - 1) {
                        cell.bgImageView.image = cell.normalGreenImage;
                    }
                } else {
                    cell.bgImageView.image = cell.normalGreenImage;
                }
                
                __weak WSocket *weakSocket = _wSocket;
                __weak RightTextTableViewCell *weakCell = cell;
                
                [_wSocket addDownFileOperationWithFileUrlString:_wSocket.lbxManager.wJid.avatarUrl serialId:@"-1" modelType:ModelTypeNormal info:nil downBlock:^(int ret, int isSave, NSData *data, NSString *fileUrl) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (ret >= 0) {
                            [weakCell.avatarBtn setImage:[UIImage imageWithData:data] forState:UIControlStateNormal];
                            if (isSave) {
                                [data writeToFile:[NSString stringWithFormat:@"%@/%@",kPathAvatar,[weakSocket.lbxManager upper16_MD5:fileUrl]] atomically:YES];
                            }
                        } else {
                            [weakCell.avatarBtn setImage:kDefaultAvatarImage forState:UIControlStateNormal];
                        }
                    });
                }];

                [cell.avatarBtn addTarget:self action:@selector(goSelfUserDetail) forControlEvents:UIControlEventTouchUpInside];

                return cell;
                
            }else if (msgObj.type == LBX_IM_DATA_TYPE_PICTURE) {
                static NSString *identifier3 = @"chat_right_image_cell";
                RightImageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier3];
                if (cell == nil) {
                    cell = [[RightImageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier3];
                }
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.rowIndex = indexPath.row;
                cell.delegate = self;
                [cell setMsgContent:msgObj];
                
                __weak WSocket *weakSocket = _wSocket;
                __weak RightImageTableViewCell *weakCell = cell;
                
                [_wSocket addDownFileOperationWithFileUrlString:_wSocket.lbxManager.wJid.avatarUrl serialId:@"-1" modelType:ModelTypeNormal info:nil downBlock:^(int ret, int isSave, NSData *data, NSString *fileUrl) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (ret >= 0) {
                            [weakCell.avatarBtn setImage:[UIImage imageWithData:data] forState:UIControlStateNormal];
                            if (isSave) {
                                [data writeToFile:[NSString stringWithFormat:@"%@/%@",kPathAvatar,[weakSocket.lbxManager upper16_MD5:fileUrl]] atomically:YES];
                            }
                        } else {
                            [weakCell.avatarBtn setImage:kDefaultAvatarImage forState:UIControlStateNormal];
                        }
                    });
                }];
                
                [cell.avatarBtn addTarget:self action:@selector(goSelfUserDetail) forControlEvents:UIControlEventTouchUpInside];

                
                
                return cell;
                
            }else if (msgObj.type == LBX_IM_DATA_TYPE_AMR) {
                static NSString *identifier3 = @"chat_right_voice_cell";
                RightVoiceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier3];
                if (cell == nil) {
                    cell = [[RightVoiceTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier3];
                }
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.indexPath = indexPath;
                cell.delegate = self;
                [cell setMsgContent:msgObj];
                
                __weak WSocket *weakSocket = _wSocket;
                __weak RightVoiceTableViewCell *weakCell = cell;
                
                [_wSocket addDownFileOperationWithFileUrlString:_wSocket.lbxManager.wJid.avatarUrl serialId:@"-1" modelType:ModelTypeNormal info:nil downBlock:^(int ret, int isSave, NSData *data, NSString *fileUrl) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (ret >= 0) {
                            [weakCell.avatarBtn setImage:[UIImage imageWithData:data] forState:UIControlStateNormal];
                            if (isSave) {
                                [data writeToFile:[NSString stringWithFormat:@"%@/%@",kPathAvatar,[weakSocket.lbxManager upper16_MD5:fileUrl]] atomically:YES];
                            }
                        } else {
                            [weakCell.avatarBtn setImage:kDefaultAvatarImage forState:UIControlStateNormal];
                        }
                    });
                }];
                
                [cell.avatarBtn addTarget:self action:@selector(goSelfUserDetail) forControlEvents:UIControlEventTouchUpInside];

                if (_playVoiceNowIndex == indexPath.row) {
                    [cell.voiceImage startAnimating];
                }
                return cell;
            } else {
                static NSString *identifier4 = @"chat_right_tip_cell";
                TipTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier4];
                if (cell == nil) {
                    cell = [[TipTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier4];
                }
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.delegate = self;
                [cell setMsgContent:msgObj.message];
                return cell;
            }
            
        }else{
            WJID *oneJid = nil;
            if ([msgObj.phone hasSuffix:@"Q"]) {
                oneJid = [[[WSocket sharedWSocket] lbxManager] getUserInfoWithPhone:msgObj.groupUser];
            }
            
            NSString *avatarUrl = _uJid.avatarUrl;
            if (oneJid && oneJid.avatarUrl.length) {
                avatarUrl = oneJid.avatarUrl;
            }

            
            
            if (msgObj.type == LBX_IM_DATA_TYPE_TEXT) {
                static NSString *identifier3 = @"chat_left_text_cell";
                LeftTextTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier3];
                if (cell == nil) {
                    cell = [[LeftTextTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier3];
                }
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.rowIndex = indexPath.row;
                cell.indexPath = indexPath;
                cell.delegate = self;
                [cell setMsgContent:msgObj];
                
                if (nextObj && nextObj.isSendMessage == NO) {
                    cell.bgImageView.image = cell.roundWhiteImage;
                    if (_wSocket.messageList.count == indexPath.row - 1) {
                        cell.bgImageView.image = cell.normalWhiteImage;
                    }
                } else {
                    cell.bgImageView.image = cell.normalWhiteImage;
                }
                
                __weak WSocket *weakSocket = _wSocket;
                __weak LeftTextTableViewCell *weakCell = cell;
                
                [_wSocket addDownFileOperationWithFileUrlString:_uJid.avatarUrl serialId:@"-1" modelType:ModelTypeNormal info:nil downBlock:^(int ret, int isSave, NSData *data, NSString *fileUrl) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (ret >= 0) {
                            [weakCell.avatarBtn setImage:[UIImage imageWithData:data] forState:UIControlStateNormal];
                            if (isSave) {
                                [data writeToFile:[NSString stringWithFormat:@"%@/%@",kPathAvatar,[weakSocket.lbxManager upper16_MD5:fileUrl]] atomically:YES];
                            }
                        }
                    });
                }];
                
                [cell.avatarBtn addTarget:self action:@selector(goSelfUserDetail) forControlEvents:UIControlEventTouchUpInside];

                return cell;
                
            }else if (msgObj.type == LBX_IM_DATA_TYPE_PICTURE) {
                static NSString *identifier3 = @"chat_left_image_cell";
                LeftImageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier3];
                if (cell == nil) {
                    cell = [[LeftImageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier3];
                }
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.rowIndex = indexPath.row;
                cell.delegate = self;
                [cell setMsgContent:msgObj];
                
                __weak WSocket *weakSocket = _wSocket;
                __weak LeftImageTableViewCell *weakCell = cell;
                
                [_wSocket addDownFileOperationWithFileUrlString:_uJid.avatarUrl serialId:@"-1" modelType:ModelTypeNormal info:nil downBlock:^(int ret, int isSave, NSData *data, NSString *fileUrl) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (ret >= 0) {
                            [weakCell.avatarBtn setImage:[UIImage imageWithData:data] forState:UIControlStateNormal];
                            if (isSave) {
                                [data writeToFile:[NSString stringWithFormat:@"%@/%@",kPathAvatar,[weakSocket.lbxManager upper16_MD5:fileUrl]] atomically:YES];
                            }
                        }
                    });
                }];
                
                [cell.avatarBtn addTarget:self action:@selector(goSelfUserDetail) forControlEvents:UIControlEventTouchUpInside];

                return cell;
                
            }else if(msgObj.type == LBX_IM_DATA_TYPE_AMR) {
                static NSString *identifier3 = @"chat_left_voice_cell";
                LeftVoiceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier3];
                if (cell == nil) {
                    cell = [[LeftVoiceTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier3];
                }
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.indexPath = indexPath;
                cell.delegate = self;
                [cell setMsgContent:msgObj];
                
                __weak WSocket *weakSocket = _wSocket;
                __weak LeftVoiceTableViewCell *weakCell = cell;
                
                [_wSocket addDownFileOperationWithFileUrlString:_uJid.avatarUrl serialId:@"-1" modelType:ModelTypeNormal info:nil downBlock:^(int ret, int isSave, NSData *data, NSString *fileUrl) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (ret >= 0) {
                            [weakCell.avatarBtn setImage:[UIImage imageWithData:data] forState:UIControlStateNormal];
                            if (isSave) {
                                [data writeToFile:[NSString stringWithFormat:@"%@/%@",kPathAvatar,[weakSocket.lbxManager upper16_MD5:fileUrl]] atomically:YES];
                            }
                        }
                    });
                }];
                
                [cell.avatarBtn addTarget:self action:@selector(goSelfUserDetail) forControlEvents:UIControlEventTouchUpInside];

                if (_playVoiceNowIndex == indexPath.row) {
                    [cell.voiceImage startAnimating];
                }
                return cell;
                
            } else {
                static NSString *identifier4 = @"chat_left_tip_cell";
                TipTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier4];
                if (cell == nil) {
                    cell = [[TipTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier4];
                }
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.delegate = self;
                [cell setMsgContent:msgObj.message];
                return cell;
            }
        }
    }
    
}

#pragma mark - Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    float height = 0.0f;
    ChatObject *msgObj = [_wSocket.messageList objectAtIndex:indexPath.row];
    if (msgObj.type == LBX_IM_DATA_TYPE_TIME) {
        height = [TimeTableViewCell getMsgHeight];
    }else{
        if (msgObj.isSendMessage) {
            if (msgObj.type == LBX_IM_DATA_TYPE_TEXT) {
                height = [RightTextTableViewCell getMsgHeight:msgObj];
            }else if (msgObj.type == LBX_IM_DATA_TYPE_PICTURE) {
                height = [RightImageTableViewCell getMsgHeight:msgObj];
            }else if (msgObj.type == LBX_IM_DATA_TYPE_AMR) {
                height = [RightVoiceTableViewCell getMsgHeight:msgObj];
            }else if (msgObj.type == LBX_IM_DATA_TYPE_SYSTEM) {
                height = [TipTableViewCell getMsgHeight:msgObj.message];
            }
        }else{
            if (msgObj.type == LBX_IM_DATA_TYPE_TEXT) {
                height = [LeftTextTableViewCell getMsgHeight:msgObj];
            }else if (msgObj.type == LBX_IM_DATA_TYPE_PICTURE) {
                height = [LeftImageTableViewCell getMsgHeight:msgObj];
            }else if (msgObj.type == LBX_IM_DATA_TYPE_AMR) {
                height = [LeftVoiceTableViewCell getMsgHeight:msgObj];
            }else if (msgObj.type == LBX_IM_DATA_TYPE_SYSTEM) {
                height = [TipTableViewCell getMsgHeight:msgObj.message];
            }
        }
    }
    
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self hideBottom];
}

#pragma mark - 输入框
/// 添加输入框的view
- (void)addInputViewAction
{
    _chatInputView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 40, self.view.frame.size.width, 40)];
    _chatInputView.backgroundColor = COLOR(247, 247, 249, 1);
    [self.view addSubview:_chatInputView];
    
    _defaultInputViewFrame = _chatInputView.frame;
    
    _cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_cameraButton setImage:[UIImage imageNamed:@"1111_liaotian_paizhao"] forState:UIControlStateNormal];
    _cameraButton.frame = CGRectMake(0, 0, 40, _chatInputView.frame.size.height);
    [_cameraButton setBackgroundColor:[UIColor clearColor]];
    [_cameraButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_cameraButton addTarget:self action:@selector(showMore:) forControlEvents:UIControlEventTouchUpInside];
    _cameraButton.tag = 205;
    [_chatInputView addSubview:_cameraButton];
    
    _audioButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_audioButton setImage:[UIImage imageNamed:@"1111_liaotian_shengyin"] forState:UIControlStateNormal];
    [_audioButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _audioButton.frame = CGRectMake(self.view.frame.size.width - 50, 0, 50, _chatInputView.frame.size.height);
    [_audioButton setBackgroundColor:[UIColor clearColor]];
    _audioButton.tag = 202;
    [_audioButton addTarget:self action:@selector(showVoice:) forControlEvents:UIControlEventTouchUpInside];
    [_chatInputView addSubview:_audioButton];
    
    _textViewBg = [[UIView alloc] initWithFrame:CGRectMake(40, 5, _chatInputView.frame.size.width - 50 - 40, _chatInputView.frame.size.height - 10)];
    _textViewBg.backgroundColor = [UIColor whiteColor];
    _textViewBg.clipsToBounds = YES;
    [_textViewBg.layer setCornerRadius:6];
    [_textViewBg.layer setMasksToBounds:YES];
    [_textViewBg.layer setBorderColor:COLOR(197, 198, 206, 1).CGColor];
    [_textViewBg.layer setBorderWidth:0.5];
    [_chatInputView addSubview:_textViewBg];
    
    _textViewHeight = _textViewBg.frame.size.height;
    
    _textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, _textViewBg.frame.size.width - 30, _textViewBg.frame.size.height)];
    _defaultTextViewFrame = _textView.frame;
    _textView.font = [UIFont systemFontOfSize:18.0];
    _textView.returnKeyType = UIReturnKeySend;
    _textView.backgroundColor = [UIColor clearColor];
    _textView.autocorrectionType = UITextAutocorrectionTypeNo;
    _textView.delegate = self;
    _textView.enablesReturnKeyAutomatically = YES;
    _textView.contentInset = UIEdgeInsetsMake(-3, 5, 0, -5);
    _textView.showsHorizontalScrollIndicator = NO;
    _textView.showsVerticalScrollIndicator = NO;
    [_textViewBg addSubview:_textView];

    _smileButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _smileButton.frame = CGRectMake(_textView.frame.size.width + _textView.frame.origin.x, _textView.frame.origin.y, 30, _textView.frame.size.height);
    _smileButton.tag = 200;
    [_smileButton setImage:[UIImage imageNamed:@"1111_liaotian_xiaolian"] forState:UIControlStateNormal];
    [_smileButton setBackgroundColor:[UIColor clearColor]];
    [_smileButton addTarget:self action:@selector(smileButtonClick:) forControlEvents:UIControlEventTouchUpInside];
//    [_textViewBg addSubview:_smileButton];
    
    _recordButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _recordButton.frame = _textViewBg.frame;
    [_recordButton setTitle:kPressString forState:UIControlStateNormal];
    [_recordButton setBackgroundColor:[UIColor whiteColor]];
    [_recordButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_chatInputView addSubview:_recordButton];
    [_recordButton.layer setCornerRadius:6];
    [_recordButton.layer setMasksToBounds:YES];
    [_recordButton.layer setBorderColor:COLOR(197, 198, 206, 1).CGColor];
    [_recordButton.layer setBorderWidth:0.5];
    [_recordButton addTarget:self action:@selector(handlePress) forControlEvents:UIControlEventTouchDown];
    [_recordButton addTarget:self action:@selector(handleLoosen) forControlEvents:UIControlEventTouchUpInside];
    [_recordButton addTarget:self action:@selector(handleCancelPress) forControlEvents:UIControlEventTouchUpOutside];
    [_recordButton addTarget:self action:@selector(handleDragOut) forControlEvents:UIControlEventTouchDragOutside];
    [_recordButton addTarget:self action:@selector(handleDragIn) forControlEvents:UIControlEventTouchDragInside];
    [_recordButton setHidden:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _chatInputView.frame.size.width, 0.5)];
    line1.backgroundColor = COLOR(197, 198, 206, 1);
    [_chatInputView addSubview:line1];
}

#pragma mark - 录音
/// 按住 说话
- (void)handlePress
{
    if (_avPlay.playing) {
        [_avPlay stop];
    }
    
    if (![_wSocket.lbxManager canRecord]) {
        return;
    }
    
    NSError *error = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];

    [[AVAudioSession sharedInstance] setActive:YES error:&error];

    _timingCount = 0;
    _recordView.microPhoneImageView.hidden = NO;
    _recordView.recordingHUDImageView.hidden = NO;
    _recordView.timingCountLabel.hidden = YES;
    [_timer setFireDate:[NSDate date]];
    
    [_recordButton setTitle:kLoosenString forState:UIControlStateNormal];
    [_recordButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    
    NSLog(@"按住 说话");
    _hideBgView.hidden = NO;
    long timestamp = [[NSDate date] timeIntervalSince1970];
    _wavName = [NSString stringWithFormat:@"%ld.wav", timestamp];
    _amrName = [NSString stringWithFormat:@"%ld.amr", timestamp];
    _wavFilePath = [NSString stringWithFormat:@"%@/%@", _foreignDirectory, _wavName];
    _amrFilePath = [NSString stringWithFormat:@"%@/%@", _foreignDirectory, _amrName];
    
    _urlPlay = [NSURL fileURLWithPath:_wavFilePath];
    _recorder = [[AVAudioRecorder alloc] initWithURL:_urlPlay settings:_setting error:nil];
    
    _recorder.delegate = self;
    [_recorder peakPowerForChannel:0];
    _recorder.meteringEnabled = YES;
    BOOL isRecorder = [_recorder prepareToRecord];
    NSLog(@"isRecorder = %d",isRecorder);
    // 创建录音文件，准备录音
    if ([_recorder prepareToRecord]) {
        // 开始
        [_recorder record];
        BOOL isTime = NO;
        long long timestamp = [[NSDate date] timeIntervalSince1970];
        if (_wSocket.messageList.count > 0) {
            NSLog(@"count = %ld",_wSocket.messageList.count);
            ChatObject *lastObject = [_wSocket.messageList lastObject];
            if (lastObject.type != LBX_IM_DATA_TYPE_TIME) {
                NSString *lastTime = [_wSocket.lbxManager turnTime:[NSString stringWithFormat:@"%lld", timestamp] formatType:2 isEnglish:NO];
                NSString *currentTime = [_wSocket.lbxManager turnTime:[NSString stringWithFormat:@"%lld", timestamp] formatType:2 isEnglish:NO];
                if (/*timestamp - kBetweenTime > [lastObject.time longLongValue]*/![lastTime isEqualToString:currentTime]) {
                    ChatObject *object = [[ChatObject alloc] init];
                    object.message = [_wSocket.lbxManager turnTime:[NSString stringWithFormat:@"%lld", timestamp] formatType:2 isEnglish:NO];
                    object.isSendMessage = YES;
                    object.time = [NSString stringWithFormat:@"%lld",timestamp];
                    object.type = LBX_IM_DATA_TYPE_TIME;
                    self.voiceTimeMsgObj = object;
                    [_wSocket.messageList addObject:object];
                    isTime = YES;
                }
            }
        }else{
            ChatObject *object = [[ChatObject alloc] init];
            object.message = [_wSocket.lbxManager turnTime:[NSString stringWithFormat:@"%lld", timestamp] formatType:2 isEnglish:NO];
            object.isSendMessage = YES;
            object.type = LBX_IM_DATA_TYPE_TIME;
            object.time = [NSString stringWithFormat:@"%lld",timestamp];
            self.voiceTimeMsgObj = object;
            [_wSocket.messageList addObject:object];
            isTime = YES;
            
            NSLog(@"firstTime = %@",object.message);
        }
        
        ChatObject *object = [[ChatObject alloc] init];
        object.time = [NSString stringWithFormat:@"%lld",timestamp];
        object.isSendMessage = YES;
        object.message = @"语音";
        object.isRead = YES;
        object.phone = _uJid.phone;
        object.area = _uJid.area;
        object.type = LBX_IM_DATA_TYPE_AMR;
        object.filePath = @"";
        object.voice_time = 10;
        object.f_voice_time = 0;
        object.status = 0;
        object.nickname = _uJid.nickname;
        object.avatarUrl = _uJid.avatarUrl;
        object.serialId = [_wSocket getSerialId];
        object.resendCount = 0;
        
        if ([_uJid.phone hasSuffix:@"Q"]) {
            object.isGroupChat = 1;
            object.groupUser = _wSocket.lbxManager.wJid.phone;
        } else {
            object.isGroupChat = 0;
            object.groupUser = @"";
        }

        self.voiceMsgObj = object;
        [_wSocket.messageList addObject:object];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshMessageList object:[NSString stringWithFormat:@"%d",MsgChatRefrashTypeSendVoice]];
        
        _voiceIndexPath = [NSIndexPath indexPathForRow:(_wSocket.messageList.count ? _wSocket.messageList.count - 1 : 0) inSection:0];
    } else {
        NSLog(@"不可以录音啊");
    }
}

/// 松开 结束
- (void)handleLoosen
{
    NSLog(@"松开 结束");
    float delayTime = 0.0f;
    _hideBgView.hidden = YES;
    _recordView.remindLabel.text = kVoiceRecordPauseString;
    [_recordButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_recordButton setTitle:kPressString forState:UIControlStateNormal];
    [_timer setFireDate:[NSDate distantFuture]];
    
    if (_wSocket.messageList.count <_voiceIndexPath.row) {
        _voiceIndexPath = [NSIndexPath indexPathForRow:-1 inSection:0];
    }
    
    if ([_recorder isRecording] && _voiceIndexPath.row > 0) {
        ChatObject *msgObj = [_wSocket.messageList objectAtIndex:_voiceIndexPath.row];
        RightVoiceTableViewCell *cell = (RightVoiceTableViewCell *)[_tableView cellForRowAtIndexPath:_voiceIndexPath];
        cell.activityView.hidden = NO;
        cell.timeLabel.hidden = NO;
        msgObj.f_voice_time = _recorder.currentTime + delayTime;
        int voice_time = ceilf(msgObj.f_voice_time);
        msgObj.voice_time = voice_time;
        float timeWidth = 16.0f;
        if (voice_time >= 10) {
            timeWidth = 24.0f;
        }
        cell.timeLabel.text = [NSString stringWithFormat:@"%d\"", voice_time];
        float voiceWidth = 40.0f;
        if (voice_time > 1) {
            voiceWidth = voiceWidth + voice_time * 2.66f;
        }
        float orginX = self.view.frame.size.width - 20 - voiceWidth - timeWidth - 50;
        cell.bgImageView.alpha = 1;
        cell.activityView.frame = CGRectMake(orginX - 30, cell.activityView.frame.origin.y, 30, 30);
        cell.voiceBtn.backgroundColor = [UIColor clearColor];
        cell.timeLabel.frame = CGRectMake(orginX, 20, timeWidth, 20);
        cell.msgView.frame = CGRectMake(orginX + timeWidth, cell.msgView.frame.origin.y, voiceWidth + 15, 40);
        cell.bgImageView.frame = CGRectMake(0, 0, voiceWidth + 15, 40);
        cell.voiceBtn.frame = CGRectMake(4, 1.5, cell.msgView.frame.size.width - 18, cell.msgView.frame.size.height - 3);
        cell.voiceImage.frame = CGRectMake(cell.voiceBtn.frame.size.width - 15, 9, 20, 20);
        [cell.activityView startAnimating];
    }
    [self performSelector:@selector(delaySend) withObject:nil afterDelay:delayTime];
}

/// 松开手指 取消发送
- (void)handleCancelPress
{
//    NSLog(@"松开手指 取消发送");
    _hideBgView.hidden = YES;
    _recordView.remindLabel.text = kVoiceRecordPauseString;
    _recordView.remindLabel.backgroundColor = [UIColor clearColor];
    [_recordButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_recordButton setTitle:kPressString forState:UIControlStateNormal];
    
    // 删除录制文件
    [_recorder stop];
    [_wSocket.lbxManager.fileManager removeItemAtPath:_wavFilePath error:nil];
    [_wSocket.messageList removeObject:_voiceTimeMsgObj];
    [_wSocket.messageList removeObject:_voiceMsgObj];
    _voiceIndexPath = [NSIndexPath indexPathForRow:-1 inSection:0];
    [_timer setFireDate:[NSDate distantFuture]];
    [_tableView reloadData];
    [self fixTableViewOffset];
}

/// 拖出去
- (void)handleDragOut
{
//    NSLog(@"松开手指，取消发送=======");
    _recordView.remindLabel.text = kVoiceRecordResaueString;
    _recordView.remindLabel.backgroundColor = [UIColor redColor];
}

/// 拖进来
- (void)handleDragIn
{
//    NSLog(@"拖进来=======");
    _recordView.remindLabel.text = kVoiceRecordPauseString;
    _recordView.remindLabel.backgroundColor = [UIColor clearColor];
}

/// 音量
- (void)detectionVoice
{
    if ([_recorder isRecording]) {
        _timingCount++;
        [_recorder updateMeters];//刷新音量数据
        //获取音量的平均值  [recorder averagePowerForChannel:0];
        //音量的最大值  [recorder peakPowerForChannel:0];
        double lowPassResults = pow(10, (0.05 * [_recorder peakPowerForChannel:0]));
        NSLog(@"%lf",lowPassResults);
        //最大50  0
        //图片 小-》大
        if (0 < lowPassResults <= 0.06) {
            [_recordView.recordingHUDImageView setImage:[UIImage imageNamed:@"RecordingSignal001"]];
        }else if (0.06 < lowPassResults <= 0.16) {
            [_recordView.recordingHUDImageView setImage:[UIImage imageNamed:@"RecordingSignal002"]];
        }else if (0.16 < lowPassResults <= 0.26) {
            [_recordView.recordingHUDImageView setImage:[UIImage imageNamed:@"RecordingSignal003"]];
        }else if (0.26 < lowPassResults <= 0.36) {
            [_recordView.recordingHUDImageView setImage:[UIImage imageNamed:@"RecordingSignal004"]];
        }else if (0.36 < lowPassResults <= 0.46) {
            [_recordView.recordingHUDImageView setImage:[UIImage imageNamed:@"RecordingSignal005"]];
        }else if (0.46 < lowPassResults <= 0.56) {
            [_recordView.recordingHUDImageView setImage:[UIImage imageNamed:@"RecordingSignal006"]];
        }else if (0.56 < lowPassResults <= 0.66) {
            [_recordView.recordingHUDImageView setImage:[UIImage imageNamed:@"RecordingSignal007"]];
        }else if (0.66 < lowPassResults <= 0.76) {
            [_recordView.recordingHUDImageView setImage:[UIImage imageNamed:@"RecordingSignal008"]];
        }else {
            [_recordView.recordingHUDImageView setImage:[UIImage imageNamed:@"RecordingSignal008"]];
        }
        
        NSLog(@"_timingCount=====%d", _timingCount);
        if (_voiceIndexPath.row >= 0) {
            [UIView animateWithDuration:0.2 animations:^{
                RightVoiceTableViewCell *cell = (RightVoiceTableViewCell *)[_tableView cellForRowAtIndexPath:_voiceIndexPath];
                if (_timingCount % 2 == 0) {
                    cell.bgImageView.alpha = 0.5;
                }else{
                    cell.bgImageView.alpha = 1;
                }
            }];

        }
        
        if (_timingCount >= (kVoiceTime - 9)) {
            _recordView.microPhoneImageView.hidden = YES;
            _recordView.recordingHUDImageView.hidden = YES;
            _recordView.timingCountLabel.hidden = NO;
            _recordView.timingCountLabel.text = [NSString stringWithFormat:@"%d", kVoiceTime - _timingCount];
        }
        if (_timingCount > kVoiceTime) {
            [self handleLoosen];
        }
    }else{
        NSLog(@"没有录音");
        [_timer setFireDate:[NSDate distantFuture]];
    }
}

#pragma mark - 处理近距离监听触发事件
- (void)sensorStateChange:(NSNotificationCenter *)notification
{
    // 如果此时手机靠近面部放在耳朵旁，那么声音将通过听筒输出，并将屏幕变暗（省电啊）
    if ([[UIDevice currentDevice] proximityState] == YES){
        // 黑屏
        NSLog(@"Device is close to user");
        // 切换为听筒播放
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        
    }else {
        // 没黑屏幕
        NSLog(@"Device is not close to user");
        // 切换为扬声器播放
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    }
}

#pragma mark - 按钮点击事件
#pragma mark - 显示录音
- (void)showVoice:(UIButton *)sender
{
    if (sender.tag == 202) {
        NSLog(@"显示录音");
        sender.tag = 203;
        [_recordButton setHidden:NO];
        _isMoreViewShow = NO;
        if (_isKeyBoadShow == YES || _isMoreViewShow == YES) {
            [_textView resignFirstResponder];
            _isMoreViewShow = NO;
            [UIView animateWithDuration:0.25 animations:^{
                [UIView setAnimationBeginsFromCurrentState:YES];
                [UIView setAnimationCurve:7];
                
                _expressionView.frame = CGRectMake(0, self.view.frame.size.height, _expressionView.frame.size.width, _expressionView.frame.size.height);
                _moreView.frame = CGRectMake(0, self.view.frame.size.height, _moreView.frame.size.width, _moreView.frame.size.height);
                
                _keyboardHeight = 0;
                float textHeight = 40.0;
                
                _textViewBg.frame = CGRectMake(_textViewBg.frame.origin.x, _textViewBg.frame.origin.y, _textViewBg.frame.size.width, textHeight - 10);
                _textView.frame = CGRectMake(_textView.frame.origin.x, _textView.frame.origin.y, _textView.frame.size.width, _textViewBg.frame.size.height);
                
                _chatInputView.frame = CGRectMake(0, self.view.frame.size.height - _keyboardHeight - _textViewBg.frame.size.height - 10, _chatInputView.frame.size.width, _textViewBg.frame.size.height + 10);

                _tableView.frame = CGRectMake(0, 64.0, self.view.frame.size.width, self.view.frame.size.height - _chatInputView.frame.size.height - 64.0);
            }];
        }else{
            _isMoreViewShow = NO;
            [UIView animateWithDuration:0.25 animations:^{
                [UIView setAnimationBeginsFromCurrentState:YES];
                [UIView setAnimationCurve:7];
                _expressionView.frame = CGRectMake(0, self.view.frame.size.height, _expressionView.frame.size.width, _expressionView.frame.size.height);
                _moreView.frame = CGRectMake(0, self.view.frame.size.height, _moreView.frame.size.width, _moreView.frame.size.height);

                _keyboardHeight = 0;
                float textHeight = 40.0;
                _textViewBg.frame = CGRectMake(_textViewBg.frame.origin.x, _textViewBg.frame.origin.y, _textViewBg.frame.size.width, textHeight - 10);
                _textView.frame = CGRectMake(_textView.frame.origin.x, _textView.frame.origin.y, _textView.frame.size.width, _textViewBg.frame.size.height);
                _chatInputView.frame = CGRectMake(0, self.view.frame.size.height - _keyboardHeight - _textViewBg.frame.size.height - 10, _chatInputView.frame.size.width, _textViewBg.frame.size.height + 10);

                _tableView.frame = CGRectMake(0, 64.0, self.view.frame.size.width, self.view.frame.size.height - _chatInputView.frame.size.height - 64.0);

                
                [self fixTableViewOffset];
            }];
        }
    }else{
        sender.tag = 202;
        [_recordButton setHidden:YES];
        [_textView becomeFirstResponder];
    }
}

#pragma mark - 显示表情
- (void)smileButtonClick:(UIButton *)sender
{
    if (sender.tag == 200) {
        _isMoreViewShow = YES;
        _cameraButton.tag = 205;
        sender.tag = 201;
        [_recordButton setHidden:YES];
        _moreView.frame = CGRectMake(0, self.view.frame.size.height, _moreView.frame.size.width, _moreView.frame.size.height);
        
        [_textView resignFirstResponder];
        
        _keyboardHeight = _moreView.frame.size.height;
        
        [UIView animateWithDuration:0.25 animations:^{
            [UIView setAnimationBeginsFromCurrentState:YES];
            [UIView setAnimationCurve:7];
            _expressionView.frame = CGRectMake(0, self.view.frame.size.height - _expressionView.frame.size.height, _expressionView.frame.size.width, _expressionView.frame.size.height);
            
            float textHeight = _textViewHeight;
            _textViewBg.frame = CGRectMake(_textViewBg.frame.origin.x, _textViewBg.frame.origin.y, _textViewBg.frame.size.width, textHeight);
            _textView.frame = CGRectMake(_textView.frame.origin.x, _textView.frame.origin.y, _textView.frame.size.width, _textViewBg.frame.size.height);
            _chatInputView.frame = CGRectMake(0, self.view.frame.size.height - _moreView.frame.size.height - textHeight - 10, _chatInputView.frame.size.width, textHeight+10);

            _tableView.frame = CGRectMake(0, 64.0, self.view.frame.size.width, self.view.frame.size.height - _chatInputView.frame.size.height - _keyboardHeight);
            [self fixTableViewOffset];
        }];
        
    }else {
        _isMoreViewShow = NO;
        sender.tag = 200;
        _expressionView.frame = CGRectMake(0, self.view.frame.size.height, _expressionView.frame.size.width, _expressionView.frame.size.height);
        [_textView becomeFirstResponder];
    }
}

#pragma mark - 显示更多操作
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    
    if (actionSheet.tag == 43) {
        if (buttonIndex == 0) {
            [self selectedCamera];
        } else if (buttonIndex == 1) {
            [self selectedPhoto];
        }
    }
}


- (void)showMore:(UIButton *)sender
{
    // 这里先写简化版本
    [_textView resignFirstResponder];
    
    _isMoreViewShow = NO;
    [UIView animateWithDuration:0.25 animations:^{
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationCurve:7];
        _expressionView.frame = CGRectMake(0, self.view.frame.size.height, _expressionView.frame.size.width, _expressionView.frame.size.height);
        _moreView.frame = CGRectMake(0, self.view.frame.size.height, _moreView.frame.size.width, _moreView.frame.size.height);
        
        _keyboardHeight = 0;
        float textHeight = 40.0;
        _textViewBg.frame = CGRectMake(_textViewBg.frame.origin.x, _textViewBg.frame.origin.y, _textViewBg.frame.size.width, textHeight - 10);
        _textView.frame = CGRectMake(_textView.frame.origin.x, _textView.frame.origin.y, _textView.frame.size.width, _textViewBg.frame.size.height);
        _chatInputView.frame = CGRectMake(0, self.view.frame.size.height - _keyboardHeight - _textViewBg.frame.size.height - 10, _chatInputView.frame.size.width, _textViewBg.frame.size.height + 10);
        
        _tableView.frame = CGRectMake(0, 64.0, self.view.frame.size.width, self.view.frame.size.height - _chatInputView.frame.size.height - 64.0);
        
        
        [self fixTableViewOffset];
    }];
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"相册", nil];
    actionSheet.tag = 43;
    [actionSheet showInView:self.view];
    return;
    
    if (sender.tag == 205) {
        _isMoreViewShow = YES;
        sender.tag = 206;
        _recordButton.tag = 202;
        _recordButton.hidden = YES;
        _smileButton.tag = 200;
        _expressionView.frame = CGRectMake(0, self.view.frame.size.height, _expressionView.frame.size.width, _expressionView.frame.size.height);
        [_textView resignFirstResponder];
        
        _keyboardHeight = _moreView.frame.size.height;
        
        float textHeight = _textViewHeight;

        [UIView animateWithDuration:0.25 animations:^{
            [UIView setAnimationBeginsFromCurrentState:YES];
            [UIView setAnimationCurve:7];
        
            _moreView.frame = CGRectMake(0, self.view.frame.size.height - _moreView.frame.size.height, _moreView.frame.size.width, _moreView.frame.size.height);
            _textViewBg.frame = CGRectMake(_textViewBg.frame.origin.x, _textViewBg.frame.origin.y, _textViewBg.frame.size.width, textHeight);
            _textView.frame = CGRectMake(_textView.frame.origin.x, _textView.frame.origin.y, _textView.frame.size.width, _textViewBg.frame.size.height);
            
            _chatInputView.frame = CGRectMake(0, self.view.frame.size.height - _keyboardHeight - textHeight - 10, _chatInputView.frame.size.width, textHeight+10);
            _tableView.frame = CGRectMake(0, 64.0, self.view.frame.size.width, self.view.frame.size.height - _chatInputView.frame.size.height - _keyboardHeight - 64.0);

            [self fixTableViewOffset];
        }];
    }else{
        _isMoreViewShow = NO;
        sender.tag = 205;
        _moreView.frame = CGRectMake(0, self.view.frame.size.height, _moreView.frame.size.width, _moreView.frame.size.height);
        [_textView becomeFirstResponder];
    }
}

/// 修改位置
- (void)changeFrame
{
    float textHeight = 0.0f;
    textHeight = [_wSocket.lbxManager getSizeWithContent:_textView.text size:CGSizeMake(_textView.frame.size.width - 10, 1000) font:18.0].height;
    if (textHeight < 30.0) {
        textHeight = 30.0;
    }
    _textViewHeight = textHeight;
    
    /// 最大高度
    if (_textViewHeight > kMsgTextViewMaxHeight) {
        _textViewHeight = kMsgTextViewMaxHeight;
    }
    
    _textViewBg.frame = CGRectMake(_textViewBg.frame.origin.x, _textViewBg.frame.origin.y, _textViewBg.frame.size.width, _textViewHeight);
    _textView.frame = CGRectMake(_textView.frame.origin.x, _textView.frame.origin.y, _textView.frame.size.width, _textViewHeight);
    
    if (_textViewHeight > 30.0) {
        _textView.contentInset = UIEdgeInsetsMake(-3, 5, 0, -5);
    }else{
        _textView.contentInset = UIEdgeInsetsMake(-3, 5, 0, -5);
    }
    
    if (_oldHeight != _textViewHeight) {
        [UIView animateWithDuration:0.25 animations:^{
            [UIView setAnimationBeginsFromCurrentState:YES];
            [UIView setAnimationCurve:0];
            
            _chatInputView.frame = CGRectMake(0, self.view.frame.size.height - _keyboardHeight - _textViewBg.frame.size.height - 10, _chatInputView.frame.size.width, _textViewBg.frame.size.height + 10);
            
            _tableView.frame = CGRectMake(0, 64.0, self.view.frame.size.width, self.view.frame.size.height - 64.0 - _keyboardHeight - _chatInputView.frame.size.height);
            [self fixTableViewOffset];
        }];
    }
    
    if (textHeight < kMsgTextViewMaxHeight) {
        
    }else{
        
        float contentHeight = _textView.contentSize.height;
        [_textView setContentOffset:CGPointMake(_textView.contentOffset.x, contentHeight - _textView.frame.size.height) animated:NO];
    }
    
    _oldHeight = _textViewHeight;
}

/// 发送信息
- (void)sendMessageClick
{
    if (_textView.text.length <= 0) {
        return;
    }

    [self sendMessageToCustomServer];
}

/// 点击tableView收键盘
- (void)tapHide:(UITapGestureRecognizer *)tap
{
    _isMoreViewShow = NO;
    _isKeyBoadShow = NO;
    [self hideBottom];
//    [UIView animateWithDuration:0.26 animations:^{
//        _moreView.frame = CGRectMake(0, self.view.frame.size.height, _moreView.frame.size.width, _moreView.frame.size.height);
//        _expressionView.frame = CGRectMake(0, self.view.frame.size.height, _expressionView.frame.size.width, _expressionView.frame.size.height);
//        _chatInputView.frame = CGRectMake(0, self.view.frame.size.height - _chatInputView.frame.size.height, _chatInputView.frame.size.width, _chatInputView.frame.size.height);
//    }];
//    [_textView resignFirstResponder];
}

- (void)hideBottom
{
    if (_isKeyBoadShow == YES) {
        [_textView resignFirstResponder];
        [UIView animateWithDuration:0.25 animations:^{
            [UIView setAnimationBeginsFromCurrentState:YES];
            [UIView setAnimationCurve:7];
            if (_keyboardHeight > 0) {
                _keyboardHeight = 0;
                float textHeight = _textViewHeight;
                
                _textViewBg.frame = CGRectMake(_textViewBg.frame.origin.x, _textViewBg.frame.origin.y, _textViewBg.frame.size.width, textHeight);
                _textView.frame = CGRectMake(_textView.frame.origin.x, _textView.frame.origin.y, _textView.frame.size.width, textHeight);
                
                _chatInputView.frame = CGRectMake(_chatInputView.frame.origin.x, self.view.frame.size.height - _keyboardHeight - textHeight - 10, _chatInputView.frame.size.height, textHeight+10);
                
                _tableView.frame = CGRectMake(0, 64.0, self.view.frame.size.width, self.view.frame.size.height - 64.0 - _chatInputView.frame.size.height);
            }
        }];
        
    }else{
        [UIView animateWithDuration:0.25 animations:^{
            [_textView resignFirstResponder];
            [UIView setAnimationBeginsFromCurrentState:YES];
            [UIView setAnimationCurve:7];
            _expressionView.frame = CGRectMake(0, self.view.frame.size.height, _expressionView.frame.size.width, _expressionView.frame.size.height);
            _moreView.frame = CGRectMake(0, self.view.frame.size.height, _moreView.frame.size.width, _moreView.frame.size.height);
            _smileButton.tag = 200;
            _audioButton.tag = 202;
            _cameraButton.tag = 205;
            if (_keyboardHeight > 0) {
                _keyboardHeight = 0;
                float textHeight = _textViewHeight;
                _textViewBg.frame = CGRectMake(_textViewBg.frame.origin.x, _textViewBg.frame.origin.y, _textViewBg.frame.size.width, textHeight);
                _textView.frame = CGRectMake(_textView.frame.origin.x, _textView.frame.origin.y, _textView.frame.size.width, _textViewBg.frame.size.height);
                
                _chatInputView.frame = CGRectMake(0, self.view.frame.size.height - _keyboardHeight - textHeight - 10, _chatInputView.frame.size.width, textHeight+10);
                
                _tableView.frame = CGRectMake(0, 64.0, self.view.frame.size.width, self.view.frame.size.height - 64.0 - _chatInputView.frame.size.height);
            }
        }];
    }
}

#pragma mark - 键盘通知
/// 键盘将要显示
- (void)keyboardWillShow:(NSNotification *)noti
{
    CGRect keyboardBounds;
    NSDictionary *userInfo = [noti userInfo];
    [[userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    _isKeyBoadShow = YES;
    _keyboardHeight = keyboardBounds.size.height;
    
    
    float textHeight = _textViewHeight;
    
    [UIView animateWithDuration:duration.floatValue animations:^{
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationCurve:[curve intValue]];
        
        _textViewBg.frame = CGRectMake(_textViewBg.frame.origin.x, _textViewBg.frame.origin.y, _textViewBg.frame.size.width, textHeight);
        _textView.frame = CGRectMake(_textView.frame.origin.x, _textView.frame.origin.y, _textView.frame.size.width, textHeight);
        
        _chatInputView.frame = CGRectMake(0, self.view.frame.size.height - keyboardBounds.size.height - textHeight - 10, _chatInputView.frame.size.width, textHeight+10);
        _tableView.frame = CGRectMake(_tableView.frame.origin.x, _tableView.frame.origin.y, _tableView.frame.size.width, self.view.frame.size.height - _tableView.frame.origin.y - keyboardBounds.size.height - _chatInputView.frame.size.height);
        
        [self fixTableViewOffset];
    }];

}

/// 键盘将要隐藏
- (void)keyboardWillHide:(NSNotification *)noti
{
    _isKeyBoadShow = NO;
    
//    [UIView animateWithDuration:0.26 animations:^{
//        [UIView setAnimationBeginsFromCurrentState:YES];
//        if (_isMoreViewShow == NO) {
//            _chatInputView.frame = _defaultInputViewFrame;
//            _tableView.frame = _defaultTableViewFrame;
//        }
//    }];
}

/// 滑动tableView到该到的地方
- (void)fixTableViewOffset
{
    float offset = _tableView.contentSize.height - _tableView.frame.size.height;
    offset = offset < 0 ? 0 : offset;
    [_tableView setContentOffset:CGPointMake(_tableView.contentOffset.x, offset)];

}

#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    
    if ([text isEqualToString:@"\n"]) {
        if ([_textView.text isEqualToString:@""] == NO) {
            [self sendMessageClick];
        }
        return NO;
    }else if ([text length] == 0) {
        [self delMsgTextViewText:1];
        [self changeFrame];
        return YES;
    }
    
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""] == NO) {
        _textView.enablesReturnKeyAutomatically = NO;
    }
}

- (void)textViewDidChangeSelection:(UITextView *)textView
{
    [self changeFrame];
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    return NO;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{

}

/// 点击头像
- (void)goSelfUserDetail
{
//    FriendInfoViewController *friendInfoVC = [[FriendInfoViewController alloc] init];
    
    WJID *uJid = [[WJID alloc] init];
    uJid = [_wSocket.lbxManager getUserInfoWithPhone:_uJid.phone];
//    friendInfoVC.uJid = uJid;
    
//    [self.navigationController pushViewController:friendInfoVC animated:YES];
}

#pragma mark - 所有的cell的代理放在这里
- (void)selectButtonTag:(id)object
{
    ChatObject *ob = (ChatObject *)object;
    
//    FriendInfoViewController *friendInfoVC = [[FriendInfoViewController alloc] init];
    
    WJID *uJid = [[WJID alloc] init];
    uJid.phone = ob.phone;
    uJid.nickname = ob.nickname;
    uJid.avatarUrl = ob.avatarUrl;
    
//    friendInfoVC.uJid = uJid;
    
//    [self.navigationController pushViewController:friendInfoVC animated:YES];
    
}

/// 所有的M80字符串
- (void)updateLabel:(M80AttributedLabel *)label text:(NSString *)text
{
    
    NSRegularExpression *regex = [[NSRegularExpression alloc]
                                  initWithPattern:@"(.*?)(\\[*+\\]|\\Z)"
                                  options:NSRegularExpressionCaseInsensitive|NSRegularExpressionDotMatchesLineSeparators
                                  error:nil];
    NSArray* chunks = [regex matchesInString:text options:0
                                       range:NSMakeRange(0, [text length])];
    for (NSTextCheckingResult *b in chunks) {
        NSString *bstr = [text substringWithRange:b.range];
        if (bstr.length > 0) {
            NSString *imgName = [[_wSocket.lbxManager getEmojiDict] objectForKey:bstr];
            if (imgName) {
                UIImage *image = [UIImage imageNamed:imgName];
                [label appendImage:image
                           maxSize:CGSizeMake(24, 24)
                            margin:UIEdgeInsetsZero
                         alignment:M80ImageAlignmentCenter];
            }else{
                NSArray *array = [bstr componentsSeparatedByString:@"["];
                int i = 0;
                for (NSString *str in array) {
                    if (i == 0) {
                        [label appendText:str];
                    }else{
                        NSString *astr = [NSString stringWithFormat:@"[%@", str];
                        NSString *imgName = [[_wSocket.lbxManager getEmojiDict] objectForKey:astr];
                        if (imgName) {
                            UIImage *image = [UIImage imageNamed:imgName];
                            [label appendImage:image
                                       maxSize:CGSizeMake(24, 24)
                                        margin:UIEdgeInsetsZero
                                     alignment:M80ImageAlignmentCenter];
                        }else{
                            [label appendText:astr];
                        }
                    }
                    i++;
                }
            }
        }
    }
    
    NSArray *rexArray = [M80AttributedLabel addRexArr:label.labelText];
    NSArray *httpArr = [rexArray objectAtIndex:0];
    NSArray *phoneNumArr = [rexArray objectAtIndex:1];
    NSArray *emailArr = [rexArray objectAtIndex:2];
    if ([emailArr count]) {
        for (NSString *emailStr in emailArr) {
            [label addCustomLink:[NSURL URLWithString:emailStr] forRange:[label.labelText rangeOfString:emailStr] linkType:LinkTypeEmail];
        }
    }
    if ([phoneNumArr count]) {
        for (NSString *phoneNum in phoneNumArr) {
            [label addCustomLink:[NSURL URLWithString:phoneNum] forRange:[label.labelText rangeOfString:phoneNum] linkType:LinkTypePhone];
        }
    }
    if ([httpArr count]) {
        for (NSString *httpStr in httpArr) {
            [label addCustomLink:[NSURL URLWithString:httpStr] forRange:[label.labelText rangeOfString:httpStr] linkType:LinkTypeURL];
        }
    }
    
    CGRect labelRect = label.frame;
    CGSize labelSize = [label sizeThatFits:CGSizeMake(self.view.frame.size.width - 100 - 50, CGFLOAT_MAX)];
    labelRect.size.width = labelSize.width < 50 ? 50 : labelSize.width;
    labelRect.size.height = labelSize.height;
    label.frame = labelRect;
}

#pragma mark - 表情的选择代理
/// 选择一个表情
- (void)selectedExpression:(NSString *)str
{
    NSString *str2 = [NSString stringWithFormat:@"%@%@", _textView.text, str];
    _textView.text = str2;
    
    [self changeFrame];
}

/// 删除一个表情
- (void)delClicked
{
    [self delMsgTextViewText:2];
}

/// 发送按钮
- (void)sendClicked
{
    if ([_textView.text isEqualToString:@""] == NO) {
        [self sendMessageClick];
    }
}

- (int)delMsgTextViewText:(int)type
{
    int offset = 0;
    if (type == 1) {
        offset = 0;
        NSInteger length = [_textView.text length];
        if (length > 0) {
            if (![[_textView.text substringFromIndex:length - 1] isEqualToString:@"]"]) {
                return 1;
            }
        }
    }else{
        offset = -1;
    }
    
    NSString *text = [_textView textInRange:[_textView textRangeFromPosition:_textView.beginningOfDocument toPosition:_textView.selectedTextRange.start]];
    NSLog(@"text=======%@", text);
    NSString *e = [text substringWithRange:NSMakeRange(text.length - 3, 3)];
    BOOL isPix = NO;
    for (NSString *emoji in [_wSocket.lbxManager getEmojiArray]) {
        NSString *emojiStr = [NSString stringWithFormat:@"%@", emoji];
        if ([e isEqualToString:emojiStr]) {
            offset = -2 + offset;
            isPix = YES;
            break;
        }
    }
    BOOL isPix2 = NO;
    if (isPix == NO) {
        NSString *e2 = [text substringWithRange:NSMakeRange(text.length - 4, 4)];
        for (NSString *emoji in [_wSocket.lbxManager getEmojiArray]) {
            NSString *emojiStr = [NSString stringWithFormat:@"%@", emoji];
            if ([e2 isEqualToString:emojiStr]) {
                offset = -3 + offset;
                isPix2 = YES;
                break;
            }
        }
    }
    if (isPix2 == NO) {
        NSString *e3 = [text substringWithRange:NSMakeRange(text.length - 5, 5)];
        for (NSString *emoji in [_wSocket.lbxManager getEmojiArray]) {
            NSString *emojiStr = [NSString stringWithFormat:@"%@", emoji];
            if ([e3 isEqualToString:emojiStr]) {
                offset = -4 + offset;
                break;
            }
        }
    }
    
    UITextRange *range = [_textView textRangeFromPosition:[_textView positionFromPosition:_textView.selectedTextRange.start offset:offset] toPosition:_textView.selectedTextRange.start];
    [_textView replaceRange:range withText:@""];
    
    return NO;
}

#pragma mark - 查看图片
- (void)lookImage:(NSInteger)rowIndex
{
    NSLog(@"000088888----------------查看图片");
    ChatObject *msgObj = [_wSocket.messageList objectAtIndex:rowIndex];
    [self updateMsgAlreadyRead:msgObj];
    
    
    if (msgObj.filePath.length) {
        UIImage *image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",_foreignDirectory,[_wSocket.lbxManager upper16_MD5:msgObj.filePath]]];
        
        CheckReportViewController *checkReportVC = [[CheckReportViewController alloc] init];
        if (image) {
            checkReportVC.imgArray = @[image];
        } else {
            checkReportVC.imgArray = @[msgObj.filePath];
        }
        [self.navigationController pushViewController:checkReportVC animated:NO];
    }
}

#pragma mark - 重新发送消息
- (void)resendMsg:(NSInteger)rowIndex
{
    dispatch_sync(_sendQueue, ^{
        ChatObject *object = [_wSocket.messageList objectAtIndex:rowIndex];
        object.status = 0;
        NSLog(@"重发  object = %@",object);
        if (object.type == LBX_IM_DATA_TYPE_AMR) {
            [_wSocket resendAudio:object isAddWaitMessage:YES isAddRemind:NO];
        } else if (object.type == LBX_IM_DATA_TYPE_PICTURE) {
            [_wSocket resendImage:object isAddWaitMessage:YES isAddRemind:NO];
        } else if (object.type == LBX_IM_DATA_TYPE_TEXT) {
            [_wSocket resendText:object isAddWaitMessage:YES isAddRemind:NO];
        }
        
//        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:rowIndex inSection:0];
//        
//        NSInteger count = _wSocket.messageList.count - 1;
//        if (count < 1) {
//            return;
//        }
//        
//        NSIndexPath *endIndexPath = [NSIndexPath indexPathForRow:_wSocket.messageList.count - 1 inSection:0];
//        
//        [_tableView moveRowAtIndexPath:indexPath toIndexPath:endIndexPath];
//        
//        id aObject = [_wSocket.messageList objectAtIndex:indexPath.row];
//        [_wSocket.messageList removeObjectAtIndex:indexPath.row];
//        [_wSocket.messageList addObject:aObject];
//        
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [_tableView reloadRowsAtIndexPaths:@[indexPath,endIndexPath] withRowAnimation:UITableViewRowAnimationTop];
//        });
    });
}

#pragma mark - 右侧代理/左侧代理
- (void)playVoice:(NSIndexPath *)indexPath
{
    ChatObject *msgObj = [_wSocket.messageList objectAtIndex:indexPath.row];
    NSLog(@"播放音频  是我发送的吗?  %d",msgObj.isSendMessage);

    if (msgObj.status != 2) {
        if (_playVoiceNowIndex == indexPath.row) {
            if (_avPlay.playing) {
                [_avPlay stop];
                if (_prevIndexPath.row >= 0) {
                    RightVoiceTableViewCell *rightCell = (RightVoiceTableViewCell *)[_tableView cellForRowAtIndexPath:_prevIndexPath];
                    [rightCell.voiceImage stopAnimating];
                    
                    LeftVoiceTableViewCell *leftCell = (LeftVoiceTableViewCell *)[_tableView cellForRowAtIndexPath:_prevIndexPath];
                    [leftCell.voiceImage stopAnimating];
                }
            }else{
                [_avPlay play];
                if (_prevIndexPath.row >= 0) {
                    RightVoiceTableViewCell *rightCell = (RightVoiceTableViewCell *)[_tableView cellForRowAtIndexPath:_prevIndexPath];
                    [rightCell.voiceImage startAnimating];
                    
                    LeftVoiceTableViewCell *leftCell = (LeftVoiceTableViewCell *)[_tableView cellForRowAtIndexPath:_prevIndexPath];
                    [leftCell.voiceImage startAnimating];
                }
            }
        }else{
            _playVoiceNowIndex = indexPath.row;
            NSString *playPath = @"";
            if (msgObj.isSendMessage) {
                playPath = [NSString stringWithFormat:@"%@/%@", _foreignDirectory, msgObj.filePath];
            }else{
                playPath = [NSString stringWithFormat:@"%@/%@.wav", _foreignDirectory, [_wSocket.lbxManager upper16_MD5:msgObj.filePath]];
            }
            NSLog(@"播放语音 playPath = %@",playPath);
            if ([_wSocket.lbxManager.fileManager fileExistsAtPath:playPath]) {
                NSURL *playUrl = [NSURL URLWithString:playPath];
                if (_avPlay.playing) {
                    [_avPlay stop];
                }
                if (_prevIndexPath.row >= 0) {
                    RightVoiceTableViewCell *rightCell = (RightVoiceTableViewCell *)[_tableView cellForRowAtIndexPath:_prevIndexPath];
                    [rightCell.voiceImage stopAnimating];
                    
                    LeftVoiceTableViewCell *leftCell = (LeftVoiceTableViewCell *)[_tableView cellForRowAtIndexPath:_prevIndexPath];
                    [leftCell.voiceImage stopAnimating];
                }
                [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error: nil];
                AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:playUrl error:nil];
                player.delegate = self;
                _avPlay = player;
                _avPlay.volume = 1;
                [_avPlay prepareToPlay];
                [_avPlay play];
                [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
                if ([UIDevice currentDevice].proximityMonitoringEnabled == YES) {
                    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sensorStateChange:)name:UIDeviceProximityStateDidChangeNotification object:nil];
                }
                if (msgObj.isSendMessage) {
                    RightVoiceTableViewCell *cell = (RightVoiceTableViewCell *)[_tableView cellForRowAtIndexPath:indexPath];
                    cell.voiceImage.animationImages = _senderVoiceArray;
                    cell.voiceImage.animationDuration = 1;
                    cell.voiceImage.animationRepeatCount = [cell.timeLabel.text intValue];
                    [cell.voiceImage startAnimating];
                }else{
                    LeftVoiceTableViewCell *cell = (LeftVoiceTableViewCell *)[_tableView cellForRowAtIndexPath:indexPath];
                    cell.noReadImageView.hidden = YES;
                    cell.voiceImage.animationImages = _receiverVoiceArray;
                    cell.voiceImage.animationDuration = 1;
                    cell.voiceImage.animationRepeatCount = [cell.timeLabel.text intValue];
                    [cell.voiceImage startAnimating];
                    [self updateMsgAlreadyRead:msgObj];
                }
            }else{
                NSLog(@"没有下载完毕");
            }
        }
        _prevIndexPath = indexPath;
    }
}

- (void)updateMsgAlreadyRead:(ChatObject *)msgObj
{
    if (msgObj.isRead == NO) {
        msgObj.isRead = YES;
        dispatch_sync(_wSocket.lbxManager.recvQueue, ^{
            
            [_wSocket.lbxManager updateMessageWithSerialId:msgObj.serialId key:@"isRead" value:@"1" isInteger:YES tableName:kMessageTableName];
        });
        [_tableView reloadData];
    }
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    NSLog(@"播放完");
    [self voicePlayFinish];
}

- (void)voicePlayFinish
{
    _playVoiceNowIndex = -1;
    [self deleteTheCloseEvent];
}

/// 删除近距离事件监听
- (void)deleteTheCloseEvent
{
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    if ([UIDevice currentDevice].proximityMonitoringEnabled == YES) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceProximityStateDidChangeNotification object:nil];
    }
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
}

#pragma mark - 长按弹出显示菜单
- (void)longPressBegin:(NSIndexPath *)indPath
{
//    _isShowMenu = YES;
//    [self hideBottom];
//    
//    CGRect aFrame = CGRectZero;
//    _rowIndex = indPath.row;
//    MsgObject *msgObj = [ws.messagesList objectAtIndex:_rowIndex];
//    if (msgObj.m_type == MsgText) {
//        if (msgObj.direction) {
//            RightTextTableViewCell *cell = (RightTextTableViewCell *)[_tableView cellForRowAtIndexPath:indPath];
//            float orginX = cell.frame.size.width - cell.bgImageView.frame.size.width - 50;
//            aFrame = CGRectMake(orginX, cell.frame.origin.y + 13, 50, cell.frame.size.height);
//        }else{
//            LeftTextTableViewCell *cell = (LeftTextTableViewCell *)[_tableView cellForRowAtIndexPath:indPath];
//            aFrame = CGRectMake(50, cell.frame.origin.y + 13, 50, cell.frame.size.height);
//        }
//    }
//    
//    [self becomeFirstResponder];
//    UIMenuController *menuController = [UIMenuController sharedMenuController];
//    UIMenuItem *menuItem_1 = [[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(msgTextCopy)];
//    menuController.menuItems = [NSArray arrayWithObjects: menuItem_1, nil];
//    [menuController setTargetRect:aFrame inView:_tableView];
//    [menuController setMenuVisible:YES animated:YES];
}

- (void)msgTextCopy
{
//    MsgObject *msgObj = [ws.messagesList objectAtIndex:_rowIndex];
//    UIPasteboard *gpBoard = [UIPasteboard generalPasteboard];
//    [gpBoard setString:msgObj.messageStr];
}

- (void)msgForwarding
{
//    CreateChatViewController *createVC = [[CreateChatViewController alloc] init];
//    [self presentViewController:createVC animated:YES completion:nil];
}

- (void)longPressShowMenu:(NSIndexPath *)indPath
{
//    _isShowMenu = NO;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if (action == @selector(msgTextCopy)) {
        return YES;//显示
    }else if (action == @selector(msgForwarding)) {
        return YES;
    }
    return NO;//不显示
}

- (BOOL)canBecomeFirstResponder{
    return YES;
}


#pragma mark - 监听上传进度
- (void)listeningUploadProgress
{
    int progress = [_wSocket getUploadFileProgress];
    
    if (progress < 100) {
        for (ChatObject *object in _wSocket.messageList) {
            if ([object.serialId isEqualToString:_wSocket.uploadingModel.serialId] && object.status == 0 && object.type == LBX_IM_DATA_TYPE_PICTURE) {
                object.uploadProgress = progress;
                NSLog(@"progress = %d",object.uploadProgress);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_tableView reloadData];
                });
                break;
            }
        }
    }
}

#pragma mark - 监听下载进度
- (void)listeningDownloadProgress
{
    int progress = [_wSocket getDownloadFileProgress];
    
    if (progress < 100) {
        for (ChatObject *object in _wSocket.messageList) {
            if ([object.serialId isEqualToString:_wSocket.downingModel.serialId] && object.status == 0 && object.type == LBX_IM_DATA_TYPE_PICTURE) {
                object.downloadProgress = progress;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_tableView reloadData];
                });
                break;
            }
        }
    }
}

#pragma mark - 更多的界面代理
/// 选择相册
- (void)selectedPhoto
{
    _isTapMoreView = YES;
    NSLog(@"选择相册");
    [self hideBottom];
    [self LocalPhoto];
}

/// 选择相机
- (void)selectedCamera
{
    _isTapMoreView = YES;
    NSLog(@"选择相机");
    [self hideBottom];
    [self takePhoto];
}

//开始拍照
- (void)takePhoto
{
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
    {
//        if ([[InscriptionManager sharedManager] isCanUseCamera] == NO) {
//            return;
//        }
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        //设置拍照后的图片可被编辑
//        picker.allowsEditing = YES;
        picker.sourceType = sourceType;
        
        if (inspIsPad) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self presentViewController:picker animated:NO completion:nil];
            }];
        } else {
            [self presentViewController:picker animated:NO completion:nil];
        }
    } else {
        NSLog(@"模拟其中无法打开照相机,请在真机中使用");
    }
}

//打开本地相册
- (void)LocalPhoto
{
//    if ([[LBXManager sharedManager] isCanUsePhotoLibrary] == NO) {
//        return;
//    }
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    //设置选择后的图片可被编辑
//    picker.allowsEditing = YES;
    if (inspIsPad) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self presentViewController:picker animated:NO completion:nil];
        }];
    } else {
        [self presentViewController:picker animated:NO completion:nil];
    }
}

//当选择一张图片后进入这里
-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:/*UIImagePickerControllerEditedImage*/UIImagePickerControllerOriginalImage];
    
    NSData *data = UIImageJPEGRepresentation(image, 0.5);
    if (!data) {
        data = UIImagePNGRepresentation(image);
    }
    
    UIImage *img = [UIImage imageWithData:data];
    
    NSLog(@"img = %@",img);
    
    [self sendImage:img destoryTime:0];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    NSLog(@"您取消了选择图片");
    [picker dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark - 发送消息

/// 发送图片
- (void)sendImage:(UIImage *)image destoryTime:(int)destoryTime
{
    if (image) {
        _srmsgCount += 1;
        dispatch_sync(_sendQueue, ^{
            NSString *serialId = [_wSocket getSerialId];
            [_wSocket sendImage:image foreignUser:_uJid.phone area:_uJid.area messageType:LBX_IM_DATA_TYPE_PICTURE message:@"图片" destoryTime:0 serialIndex:serialId];
        });
    }else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"没图片" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alertView show];
    }
}

/// 发送声音
- (void)delaySend
{
    NSLog(@"_recorder=======%d", [_recorder isRecording]);
    if ([_recorder isRecording]) {
        float cTime = _recorder.currentTime;
        
        NSLog(@"cTime=%f", cTime);
        if (cTime > 0.6) {
            NSLog(@"发出去  _voiceIndexPath.row====%d", (int)_voiceIndexPath.row);
            if (_voiceIndexPath.row >0) {
                int voice_time = ceilf(cTime);
                ChatObject *msgTimeMsgObj = _voiceTimeMsgObj;
                if (_voiceIndexPath.row >= 1) {
                    ChatObject *vmsgTimeMsgObj = [_wSocket.messageList objectAtIndex:(_voiceIndexPath.row - 1)];
                    if (vmsgTimeMsgObj.type == LBX_IM_DATA_TYPE_TIME && vmsgTimeMsgObj.isSendMessage == YES) {
                        msgTimeMsgObj = vmsgTimeMsgObj;
                    }
                }
                
                //如果录制时间 < 0.6 不发送
                _srmsgCount++;
                dispatch_sync(_sendQueue, ^{
                    self.voiceMsgObj.voice_time = voice_time;
                    self.voiceMsgObj.destoryTime = voice_time;
                    [_wSocket sendAudioWithChatObject:self.voiceMsgObj wavFilePath:_wavFilePath wavName:_wavName amrFilePath:_amrFilePath timeObject:msgTimeMsgObj];
                });
            }else{
                [_wSocket.messageList removeObject:_voiceTimeMsgObj];
                for (NSInteger i = _wSocket.messageList.count - 1; i >= 0; i--) {
                    ChatObject *msgObj = [_wSocket.messageList objectAtIndex:i];
                    if (msgObj.type == LBX_IM_DATA_TYPE_AMR && msgObj.f_voice_time <= 0.6 && msgObj.isSendMessage == YES) {
                        [_wSocket.messageList removeObjectAtIndex:i];
                    }
                }
                [_tableView reloadData];
                [self fixTableViewOffset];
            }
            
        }else {
            [_wSocket.messageList removeObject:_voiceTimeMsgObj];
            for (NSInteger i = _wSocket.messageList.count - 1; i >= 0; i--) {
                ChatObject *msgObj = [_wSocket.messageList objectAtIndex:i];
                if (msgObj.type == LBX_IM_DATA_TYPE_AMR && msgObj.f_voice_time <= 0.6 && msgObj.isSendMessage == YES) {
                    [_wSocket.messageList removeObjectAtIndex:i];
                }
            }
            [_tableView reloadData];
            [self fixTableViewOffset];
            
            [_wSocket.lbxManager showHudViewLabelText:@"录音时间太短！" detailsLabelText:nil afterDelay:1];
            
            // 删除存储的
            [_wSocket.lbxManager.fileManager removeItemAtPath:_wavFilePath error:nil];
        }
        [_recorder stop];
    }
    
    _voiceIndexPath = [NSIndexPath indexPathForRow:-1 inSection:0];
}

/// 发送文字消息
- (void)sendMessageToCustomServer
{
    NSInteger len = _textView.text.length;
    int limit = 499;
    
    if (len > limit) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"提示" message:@"每次最多发送499字" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [av show];
        return;
    }
    
    _srmsgCount+=1;
    
    NSString *hexString = [_wSocket.lbxManager hexStringFromString:_textView.text];

    dispatch_sync(_sendQueue, ^{
        [_wSocket sendText:hexString foreignUser:_uJid.phone area:_uJid.area messageType:LBX_IM_DATA_TYPE_TEXT destoryTime:0 serialIndex:[_wSocket getSerialId]];
        
    });
    
    _textView.text = @"";
    [self fixTableViewOffset];
    _textViewHeight = 0.0f;
    _textViewHeight = 30.0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
