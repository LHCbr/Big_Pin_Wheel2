//
//  FilterBtn.m
//  BigPinwheel
//
//  Created by 徐伟 on 16/2/20.
//  Copyright © 2016年 leita. All rights reserved.
//

#import "FilterBtn.h"

@implementation FilterBtn

-(instancetype)initWithFrame:(CGRect)frame BtnName:(NSString *)btnName Property:(NSString *)property
{
    self = [super initWithFrame:frame];
    if (self) {
        _value_name = btnName ;
        _proper_name = property;
        
        [self makeView];
    }
    return self;
}

-(void)makeView
{
    
    [self setBackgroundColor:[UIColor whiteColor]];
    [self.layer setMasksToBounds:YES];
    [self.layer setCornerRadius:4.0];
    [self.layer setBorderWidth:0.5];
    [self.layer setBorderColor:COLOR(197, 197, 197, 1).CGColor];
    [self setTitle:_value_name forState:UIControlStateNormal];
    [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [self.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self setExclusiveTouch:YES];
    
    _selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _selectBtn.backgroundColor = COLOR(220, 220, 220, 0.7);
    _selectBtn.frame = self.bounds;
    _selectBtn.userInteractionEnabled = NO;
    [_selectBtn setHidden:YES];
    [self addSubview:_selectBtn];
    
}


-(void)setSelfisHidden:(BOOL)isSelected
{
    [_selectBtn setHidden:!isSelected];
}














@end
