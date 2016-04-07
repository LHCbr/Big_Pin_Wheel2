//
//  NameCardHeaderView.h
//  BigPinwheel
//
//  Created by 徐伟 on 16/2/17.
//  Copyright © 2016年 leita. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CityAndOnlineBtn.h"

@interface NameCardHeaderView : UIView

@property(strong,nonatomic)UIImageView *avatarView;
@property(strong,nonatomic)UILabel *nameLabel;
@property(strong,nonatomic)CityAndOnlineBtn *cityBtn;
@property(strong,nonatomic)CityAndOnlineBtn *onlineBtn;
@property(strong,nonatomic)UIImageView *mountainView;

@end
