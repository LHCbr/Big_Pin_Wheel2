//
//  SendMessageModel.h
//  LuLu
//
//  Created by a on 11/20/15.
//  Copyright © 2015 lbx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OperationModel.h"
#import "ChatObject.h"

@interface SendMessageModel : OperationModel

@property (strong, nonatomic) ChatObject *object;
- (instancetype)initWithChatObject:(ChatObject *)object;

@end
