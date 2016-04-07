//
//  LeftTextTableViewCell.m
//  BDMapDemo
//
//  Created by tw001 on 14-9-29.
//  Copyright (c) 2014年 ESX. All rights reserved.
//

#import "LeftTextTableViewCell.h"

@implementation LeftTextTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)longPress:(UIGestureRecognizer *)ges
{
    if (ges.state == 1) {
        [_delegate longPressBegin:_indexPath];
    }
    if (ges.state == 3) {
        [_delegate longPressShowMenu:_indexPath];
    }
}

/// 设置消息内容
- (void)setMsgContent:(ChatObject *)msgObj
{
    for (UIView *sview in [_msgView subviews]) {
        if ([sview isKindOfClass:[M80AttributedLabel class]]) {
            [sview removeFromSuperview];
        }
    }
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    longPress.minimumPressDuration = 1.0;
    [_msgView addGestureRecognizer:longPress];
    
    float orginX = kLeftAvatarWidthZero;
    
    msgObj.msgLabel.frame = CGRectMake(17, kTextTop, msgObj.msgLabel.frame.size.width, msgObj.msgRowHeight - kTextTop * 2);
    _msgView.frame = CGRectMake(orginX, _msgView.frame.origin.y, msgObj.msgLabel.frame.size.width + 20, msgObj.msgRowHeight - kTextTop);
    _bgImageView.frame = CGRectMake(5, 0, _msgView.frame.size.width + 10, _msgView.frame.size.height);
    
    [_msgView addSubview:msgObj.msgLabel];
    
    _msgTime.frame = CGRectMake(5+_msgView.frame.size.width - 60, _msgView.frame.size.height - 9, 80, 10);
    
    NSString *timeSt = [[[WSocket sharedWSocket] lbxManager] turnTime:msgObj.time formatType:1 isEnglish:NO];
    
    NSDictionary *attrDict3 = @{ NSObliquenessAttributeName: @(0.1),
                                 NSFontAttributeName: [UIFont systemFontOfSize:9],
                                 NSForegroundColorAttributeName: COLOR(182, 182, 182, 1)};
    [_msgTime setAttributedTitle:[[NSAttributedString alloc] initWithString:timeSt attributes: attrDict3] forState:UIControlStateNormal];

}

/// 获得高度
+ (float)getMsgHeight:(ChatObject *)msgObj
{
    return msgObj.msgRowHeight;
}

@end
