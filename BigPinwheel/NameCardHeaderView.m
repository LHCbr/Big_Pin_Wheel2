//
//  NameCardHeaderView.m
//  BigPinwheel
//
//  Created by 徐伟 on 16/2/17.
//  Copyright © 2016年 leita. All rights reserved.
//

#import "NameCardHeaderView.h"

@implementation NameCardHeaderView

-(void)dealloc
{
    NSLog(@"名片界面释放");
}

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = COLOR(255, 214, 94, 1);
        //头像
        _avatarView = [[UIImageView alloc]initWithFrame:CGRectMake(9, 70, 175/2, 175/2)];
        _avatarView.backgroundColor = [UIColor clearColor];
        [_avatarView.layer setMasksToBounds:YES];
        [_avatarView.layer setCornerRadius:8];
        _avatarView.userInteractionEnabled = YES;
        [self addSubview:_avatarView];
        
        
        //nameLabel cityBtn onlineBtn
        _nameLabel = [self createLabelWithTextColor:[UIColor blackColor] frame:CGRectMake(_avatarView.frame.size.width+_avatarView.frame.origin.x+10.5, 80, kDeviceWidth -(_avatarView.frame.size.width+_avatarView.frame.origin.x+10.5), 18) textFont:[UIFont systemFontOfSize:18] bgColor:[UIColor clearColor] layerFont:0 borderWith:0 textAligement:NSTextAlignmentLeft];
        [self addSubview:_nameLabel];
        
        _cityBtn = [CityAndOnlineBtn buttonWithType:UIButtonTypeCustom];
        _cityBtn.backgroundColor = [UIColor clearColor];
        _cityBtn.frame = CGRectMake(_nameLabel.frame.origin.x, 8+_nameLabel.frame.origin.y+_nameLabel.frame.size.height, _nameLabel.frame.size.width, 15);
        _cityBtn.imageSize = CGSizeMake(12, 15);
        [_cityBtn setImage:[UIImage imageNamed:@"0217_cityBtn"] forState:UIControlStateNormal];
        [_cityBtn setTitleColor:COLOR(119, 103, 61, 1) forState:UIControlStateNormal];
        [_cityBtn.titleLabel setFont:[UIFont systemFontOfSize:11]];
        [_cityBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [self addSubview:_cityBtn];
        
        _onlineBtn = [CityAndOnlineBtn buttonWithType:UIButtonTypeCustom];
        _onlineBtn.backgroundColor = [UIColor clearColor];
        _onlineBtn.frame = CGRectMake(_cityBtn.frame.origin.x, _cityBtn.frame.origin.y+_cityBtn.frame.size.height+19/2, _cityBtn.frame.size.width, 11);
        _onlineBtn.imageSize = CGSizeMake(19/2, 19/2);
        [_onlineBtn setImage:[UIImage imageNamed:@"0217_onlineBtn"] forState:UIControlStateNormal];
        [_onlineBtn setTitleColor:COLOR(119, 103, 61, 1) forState:UIControlStateNormal];
        [_onlineBtn.titleLabel setFont:[UIFont systemFontOfSize:11]];
        [_onlineBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [self addSubview:_onlineBtn];
        
        
        //mountainView
        _mountainView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 12+_avatarView.frame.size.height+_avatarView.frame.origin.y, kDeviceWidth, 85/2 )];
        _mountainView.backgroundColor = [UIColor clearColor];
        [_mountainView setImage:[UIImage imageNamed:@"0217_mountains"]];
        [self addSubview:_mountainView];
        
    }
    return self;
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
