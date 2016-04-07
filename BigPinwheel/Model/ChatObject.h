//
//  ChatObject.h
//  LuLu
//
//  Created by a on 11/12/15.
//  Copyright © 2015 lbx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "M80AttributedLabel.h"

@interface ChatObject : NSObject

@property (nonatomic, assign) int id;                         // 数据库里面的id

@property (nonatomic,   copy) NSString *serialId;             // 消息id
@property (nonatomic,   copy) NSString *time;                 // 时间
@property (nonatomic, assign) BOOL isSendMessage;             // yes是发消息， no是接受消息
@property (nonatomic,   copy) NSString *phone;                // 对方手机号
@property (nonatomic,   copy) NSString *area;                 // 手机区号
@property (nonatomic,   copy) NSString *nickname;             // 对方昵称
@property (nonatomic,   copy) NSString *avatarUrl;            // 对方头像
@property (nonatomic,   copy) NSString *message;              // 消息内容
@property (nonatomic, assign) int status;                     // 消息发送状态， 0 发送中，1发送成功， 2发送失败
@property (nonatomic, assign) int type;                       // 消息类型   0普通文字， 1图片， 2 声音， 3 视频 4 系统消息 5 时间
@property (nonatomic, assign) BOOL isRead;                    // 是否已读
@property (nonatomic, assign) int voice_time;                 // 语音时间
@property (nonatomic, assign) float f_voice_time;             // 录音时间

@property (nonatomic, assign) int uploadProgress;             // 上传进度
@property (nonatomic, assign) int downloadProgress;           // 下载进度
@property (nonatomic,   copy) NSString *filePath;             // 文件路径
@property (nonatomic, assign) int destoryTime;                // 剩余销毁时间

@property (nonatomic, assign) int resendCount;                // 消息重发次数

@property (nonatomic, assign) int isGroupChat;                // 是否是群发消息
@property (nonatomic,   copy) NSString *groupUser;            // 群里的发送者

@property (nonatomic, assign) float msgRowHeight;            // 记录这条消息在cell里面占的高
@property (nonatomic, strong) M80AttributedLabel *msgLabel;  // label

@end
