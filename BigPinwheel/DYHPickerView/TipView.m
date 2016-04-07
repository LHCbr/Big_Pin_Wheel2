//
//  TipView.m
//  BigPinwheel
//
//  Created by xumckay on 16/3/21.
//  Copyright © 2016年 leita. All rights reserved.
//

#import "TipView.h"

@implementation TipView

-(instancetype)initWithFrame:(CGRect)frame
{   self=[super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor=COLOR(231, 231, 235,1);
        self.userInteractionEnabled=YES;
        UIButton *cancelBtn=[[UIButton alloc]initWithFrame:CGRectMake(0,0,70,42)];
        [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [cancelBtn addTarget:self action:@selector(cancelBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:cancelBtn];
        
        UIButton *sureBtn=[[UIButton alloc]initWithFrame:CGRectMake(kDeviceWidth-80,0,70,42)];
        [sureBtn setTitle:@"确定" forState:UIControlStateNormal];
        [sureBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [sureBtn addTarget:self action:@selector(sureBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:sureBtn];
    }
    return self;
}

-(void)cancelBtnClicked:(UIButton *)sender
{
    if ([_delegate respondsToSelector:@selector(cancelBtnClicked)]) {
        [_delegate cancelBtnClicked];
    }
}

-(void)sureBtnClicked:(UIButton *)sender
{
    if ([_delegate respondsToSelector:@selector(sureBtnClicked)]) {
        [_delegate sureBtnClicked];
    }
}


@end
