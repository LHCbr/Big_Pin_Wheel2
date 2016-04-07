//
//  SexIdentityPickerView.m
//  BigPinwheel
//
//  Created by xuwei on 16/3/17.
//  Copyright © 2016年 leita. All rights reserved.
//

#import "SexIdentityPickerView.h"

@implementation SexIdentityPickerView

-(instancetype)initWithFrame:(CGRect)frame isSex:(BOOL)isSex
{
    self = [super initWithFrame:frame];
    if (self) {
        _isSex = isSex;
        if (_isSex) {
            _dataArray = [NSMutableArray arrayWithObjects:@"女",@"男",nil];
        }else
        {
            _dataArray = [NSMutableArray arrayWithObjects:@"农民",@"司机",nil];
        }
        self.frame = frame;
        self.backgroundColor = COLOR(187, 186, 185, 0.5);
        
        UIView *btnBGView = [[UIView alloc]initWithFrame:CGRectMake(0,self.frame.size.height *(1- 520/1270), kDeviceWidth, 44)];
        btnBGView.backgroundColor = COLOR(231, 231, 235, 1);
        [self addSubview:btnBGView];
        
        _cancelBtn = [self creatBtnWithX:0 Title:@"取消"];
        _cancelBtn.tag = 0;
        [btnBGView addSubview:_cancelBtn];
        
        _confirmBtn = [self creatBtnWithX:kDeviceWidth - 56 Title:@"确定"];
        _confirmBtn.tag = 1;
        [btnBGView addSubview:_confirmBtn];
        
        _pickerView = [[UIPickerView alloc]initWithFrame:CGRectMake(0, _cancelBtn.frame.size.height+_cancelBtn.frame.origin.y, kDeviceWidth, self.frame.size.height - (_cancelBtn.frame.size.height+_cancelBtn.frame.origin.y))];
        _pickerView.backgroundColor = COLOR(239, 239, 244, 1);
        [self addSubview:_pickerView];
        
        
    }
    return self;
}

///View创建工具
-(UIButton *)creatBtnWithX:(CGFloat )x Title:(NSString *)title
{
    UIButton *button =  [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor clearColor];
    button.frame = CGRectMake(x, 0, 56, 43);
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [button.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

///点击事件
-(void)buttonClick:(UIButton *)sender
{
    
}

#pragma mark -UIPickViewDelegate
-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 35;
}

-(CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    return kDeviceWidth/2;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *title = [NSString stringWithFormat:@"%@",[_dataArray objectAtIndex:row]];
    return title;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    
}

#pragma mark - UIPickerViewDataSource
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    switch (component) {
        case 0:
            return _dataArray.count;
            break;
            
        default:
            return 0;
            break;
    }
}





@end
