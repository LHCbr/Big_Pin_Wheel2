//
//  MineHeaderView.m
//  BigPinwheel
//
//  Created by xuwei on 16/4/12.
//  Copyright © 2016年 leita. All rights reserved.
//

#import "MineHeaderView.h"

@implementation MineHeaderView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor grayColor];
        
        _settingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _settingBtn.backgroundColor = [UIColor clearColor];
        _settingBtn.frame = CGRectMake(kDeviceWidth-50, 15, 30, 15);
        [_settingBtn.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [_settingBtn.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [_settingBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_settingBtn setTitle:@"设置" forState:UIControlStateNormal];
        
        [self addSubview:_settingBtn];
    }
    return self;
}

@end
