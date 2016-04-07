//
//  NearMessageObject.m
//  LuLu
//
//  Created by a on 11/18/15.
//  Copyright © 2015 lbx. All rights reserved.
//

#import "NearMessageObject.h"

@implementation NearMessageObject

/// 防止模型赋值出错
-(void)setValue:(id)value forUndefinedKey:(NSString *)key
{
//    NSLog(@"给用户模型赋值的时候出现失误key = %@",key);
}

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
                          isSend:(int)isSend
{
    self = [super init];
    if (self) {
        _serialId = serialId;
        _phone = phone;
        _nickname = nickname;
        _message = message;
        _time = time;
        _avatarUrl = avatarUrl;
        _chatType = chatType;
        _status = status;
        _type = type;
        _noReadCount = noReadCount;
        _isSend = isSend;
    }
    return self;
}

@end
