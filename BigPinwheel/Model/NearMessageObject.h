//
//  NearMessageObject.h
//  LuLu
//
//  Created by a on 11/18/15.
//  Copyright © 2015 lbx. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NearMessageObject : NSObject

@property (nonatomic,   copy)NSString *serialId;        // 消息的序列号
@property (nonatomic,   copy)NSString *phone;           // 手机号
@property (nonatomic,   copy)NSString *nickname;        // 昵称
@property (nonatomic,   copy)NSString *message;         // 内容
@property (nonatomic,   copy)NSString *time;            // 时间
@property (nonatomic,   copy)NSString *avatarUrl;       // 头像
@property (nonatomic, assign)int noReadCount;           // 未读个数
@property (nonatomic, assign)int chatType;              // 消息种类 是聊天还是其他，目前只有聊天
@property (nonatomic, assign)int status;                // 消息发送状态， 0 发送中，1发送完成， 2发送失败
@property (nonatomic, assign)int type;                  // 消息类型   0普通文字， 1图片， 2 声音， 3 视频
@property (nonatomic, assign)int isSend;                // 1是自己发送  0 对方发送

- (instancetype)initWithSerialId:(NSString *)serialId
                           phone:(NSString *)phone
                     nickname:(NSString *)nickname
                      message:(NSString *)message
                         time:(NSString *)time
                    avatarUrl:(NSString *)avatarUrl
                        chatType:(int)chatType
                        status:(int)status
                         type:(int)type
                  noReadCount:(int)noReadCount
                          isSend:(int)isSend;

@end
