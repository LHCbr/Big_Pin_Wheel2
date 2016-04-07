//
//  ChatTableViewCell.h
//  LeiRen
//
//  Created by tw001 on 14-9-17.
//  Copyright (c) 2014年 wave. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSocket.h"
#import "ChatObject.h"
#import "M80AttributedLabel.h"
#import "InscriptionManager.h"
#import "ChatListDateBtn.h"

#define kTextTop 9.5f
#define kFontSize 15.0f

@interface ChatTableViewCell : UITableViewCell
{
    UIImageView *_bgImageView;
    UIButton *_avatarBtn;
    UIView *_msgView;
    ChatListDateBtn *_msgTime;
    
    UIImage *_roundGreenImage;
    UIImage *_roundWhiteImage;
    UIImage *_normalGreenImage;
    UIImage *_normalWhiteImage;
}

@property (strong, nonatomic) UIImageView *bgImageView;
@property (strong, nonatomic) UIButton *avatarBtn;
@property (strong, nonatomic) UIView *msgView;
@property (strong, nonatomic) ChatListDateBtn *msgTime;

@property (strong, nonatomic) UIImage *roundGreenImage;
@property (strong, nonatomic) UIImage *roundWhiteImage;
@property (strong, nonatomic) UIImage *normalGreenImage;
@property (strong, nonatomic) UIImage *normalWhiteImage;

@end
