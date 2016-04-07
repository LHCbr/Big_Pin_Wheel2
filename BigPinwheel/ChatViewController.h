//
//  ChatViewController.h
//  LuLu
//
//  Created by a on 11/12/15.
//  Copyright © 2015 lbx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WJID.h"
#import "ExpressionView.h"
#import "MoreView.h"
#import "RecordView.h"
#import "ChatObject.h"
#import "AllCell.h"
#import "M80AttributedLabel.h"
#import "IMRefrashViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ChatViewController : IMRefrashViewController<UITableViewDataSource,UITableViewDelegate,UITextViewDelegate,ExpressionDelegate,MoreViewDelegate,AVAudioRecorderDelegate,AVAudioPlayerDelegate,AVAudioSessionDelegate,MoreViewDelegate,M80AttributedLabelDelegate,LeftTextTableViewCellDelegate,LeftVoiceTableViewCellDelegate,LeftImageTableViewCellDelegate,RightImageTableViewCellDelegate,RightTextTableViewCellDelegate,RightVoiceTableViewCellDelegate,TipTableViewCellDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property (strong, nonatomic)WJID *uJid;       // 对方的详细数据

@property (strong, nonatomic)ExpressionView *expressionView;      // 表情界面
@property (strong, nonatomic)MoreView *moreView;                  // 更多界面
@property (strong, nonatomic)RecordView *recordView;              // 录音提示界面
@property (strong, nonatomic)UIView *hideBgView;                  // 录音的背景界面

@property (strong, nonatomic) AVAudioPlayer     *avPlay;
@property (strong, nonatomic) AVAudioRecorder   *recorder;
@property (strong, nonatomic) NSTimer           *timer;
@property (strong, nonatomic) NSURL             *urlPlay;
@property (strong, nonatomic) NSDictionary      *setting;
@property (strong, nonatomic) NSString          *wavFilePath;
@property (strong, nonatomic) NSString          *amrFilePath;
@property (strong, nonatomic) NSString          *wavName;
@property (strong, nonatomic) NSString          *amrName;
@property (assign, nonatomic) int               timingCount;         // 计时

@property (strong, nonatomic) ChatObject        *voiceTimeMsgObj;    // 录音上一级添加的时间
@property (strong, nonatomic) ChatObject        *voiceMsgObj;        // 正在录音的对象
@property (strong, nonatomic) NSIndexPath       *voiceIndexPath;     // 正在录音的某一行

/// 创建对方文件夹
- (void)createDirectory:(NSString *)phone;

@end
