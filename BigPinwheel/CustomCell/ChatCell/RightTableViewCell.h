//
//  RightTableViewCell.h
//  LeiRen
//
//  Created by tw001 on 14-9-17.
//  Copyright (c) 2014年 wave. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatTableViewCell.h"

#define kRightAvatarWidthZero 0.0

#define kRightTimeColor COLOR(52, 177, 30, 1)

@interface RightTableViewCell : ChatTableViewCell
{
    UIButton *_failueBtn;
    UIActivityIndicatorView *_activityView;
    
}

@property (strong, nonatomic) UIButton *failueBtn;
@property (strong, nonatomic) UIActivityIndicatorView *activityView;    // 风火轮

@end
