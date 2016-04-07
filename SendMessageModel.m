//
//  SendMessageModel.m
//  LuLu
//
//  Created by a on 11/20/15.
//  Copyright © 2015 lbx. All rights reserved.
//

#import "SendMessageModel.h"

@implementation SendMessageModel

- (instancetype)initWithChatObject:(ChatObject *)object;
{
    self = [super init];
    if (self) {
        _object = object;
    }
    return self;
}

@end
