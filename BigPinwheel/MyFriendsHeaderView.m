//
//  MyFriendsHeaderView.m
//  BigPinwheel
//
//  Created by 徐伟 on 16/2/21.
//  Copyright © 2016年 leita. All rights reserved.
//

#import "MyFriendsHeaderView.h"

@implementation MyFriendsHeaderView

-(void)dealloc
{
    self.delegate = nil;
    NSLog(@"朋友筛选HeaderView界面释放");
}

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self makeView];
    }
    return self;
}

-(void)makeView
{
    //筛选filterLabel filterBtn
    _fileterLabel = [self createLabelWithTextColor:COLOR(97, 97, 97, 1) frame:CGRectMake(13, 0, kDeviceWidth-13-57, 35) textFont:[UIFont systemFontOfSize:15] bgColor:[UIColor clearColor] layerFont:0 borderWith:0 textAligement:NSTextAlignmentLeft];
    _fileterLabel.text = @"最近在线（全部，同城）";
    [self addSubview:_fileterLabel];
    
    _filterDBtn = [FilterDespBtn buttonWithType:UIButtonTypeCustom];
    _filterDBtn.backgroundColor = [UIColor clearColor];
    _filterDBtn.frame = CGRectMake(kDeviceWidth -57,_fileterLabel.frame.origin.y , 44, 35);
    [_filterDBtn setTitleColor:COLOR(97, 97, 97, 1) forState:UIControlStateNormal];
    [_filterDBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [_filterDBtn setTitle:@"筛选" forState:UIControlStateNormal];
    [_filterDBtn setImage:[UIImage imageNamed:@"0222_filter"] forState:UIControlStateNormal];
    _filterDBtn.tag =0;
    [_filterDBtn addTarget:self action:@selector(filterBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_filterDBtn];
    
    UIView *sepline1 = [[UIView alloc]initWithFrame:CGRectMake(0, _fileterLabel.frame.size.height+_fileterLabel.frame.origin.y, kDeviceWidth, 0.5)];
    sepline1.backgroundColor = COLOR(221, 221, 221, 1);
    [self addSubview:sepline1];
    
}

-(void)filterBtnClick:(UIButton *)sender
{
    [_delegate filterButtonClick:sender];
}

/// 有layerFont就设置没有为0   有border宽就设置，没有为0
- (UILabel *)createLabelWithTextColor:(UIColor *)textColor
                                frame:(CGRect)frame
                             textFont:(UIFont *)textFont
                              bgColor:(UIColor *)bgColor
                            layerFont:(CGFloat)layerFont
                           borderWith:(CGFloat)borderWith
                        textAligement:(NSTextAlignment)textAligement

{
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = bgColor == nil ? [UIColor clearColor] : bgColor;
    label.textColor = textColor;
    label.font = textFont;
    label.textAlignment = textAligement;
    
    if (layerFont > 0) {
        [label.layer setCornerRadius:layerFont];
        [label.layer setMasksToBounds:YES];
    }
    
    if (borderWith > 0) {
        [label.layer setBorderColor:COLOR(226, 144, 33, 1).CGColor];
        [label.layer setBorderWidth:borderWith];
    }
    
    return label;
}



@end
