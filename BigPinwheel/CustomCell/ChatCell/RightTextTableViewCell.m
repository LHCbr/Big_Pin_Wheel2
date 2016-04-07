//
//  RightTextTableViewCell.m
//  BDMapDemo
//
//  Created by tw001 on 14-9-29.
//  Copyright (c) 2014年 ESX. All rights reserved.
//

#import "RightTextTableViewCell.h"

@implementation RightTextTableViewCell

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
    
    float orginX = self.contentView.frame.size.width - msgObj.msgLabel.frame.size.width - 35 - kRightAvatarWidthZero;
    msgObj.msgLabel.frame = CGRectMake(10, kTextTop, msgObj.msgLabel.frame.size.width, msgObj.msgRowHeight - kTextTop * 2);
    if (msgObj.status == 0) {
        _failueBtn.hidden = YES;
        _activityView.hidden = NO;
        _activityView.frame = CGRectMake(orginX - 30, _activityView.frame.origin.y, 30, 30);
        [_activityView startAnimating];
        [_msgTime setImage:nil forState:UIControlStateNormal];
        
    }else if (msgObj.status == 1) {
        _failueBtn.hidden = YES;
        _activityView.hidden = YES;
        [_activityView stopAnimating];
        [_msgTime.imageView setHidden:NO];
        [_msgTime setImage:[UIImage imageNamed:@"0106_alreadysend"] forState:UIControlStateNormal];
        
    }else if (msgObj.status == 2){
        _failueBtn.hidden = NO;
        _activityView.hidden = YES;
        _failueBtn.frame = CGRectMake(self.contentView.frame.size.width - 30, msgObj.msgRowHeight - 33, 30, 30);
        [_failueBtn addTarget:self action:@selector(clickResendMsg) forControlEvents:UIControlEventTouchUpInside];
        [_activityView stopAnimating];
        [_msgTime setImage:nil forState:UIControlStateNormal];

        orginX -= 25;
    }
    _msgView.frame = CGRectMake(orginX, _msgView.frame.origin.y, msgObj.msgLabel.frame.size.width + 20, msgObj.msgRowHeight - kTextTop);
    _bgImageView.frame = CGRectMake(0, 0, _msgView.frame.size.width + 10, _msgView.frame.size.height);
    [_msgView addSubview:msgObj.msgLabel];
    
    _msgTime.frame = CGRectMake(orginX+msgObj.msgLabel.frame.size.width - 60, _msgView.frame.size.height - 9, 80, 10);

    NSString *timeSt = [[[WSocket sharedWSocket] lbxManager] turnTime:msgObj.time formatType:1 isEnglish:NO];

    NSDictionary *attrDict3 = @{ NSObliquenessAttributeName: @(0.1),
                                 NSFontAttributeName: [UIFont systemFontOfSize:9],
                                 NSForegroundColorAttributeName: COLOR(94, 194, 74, 1)};
    [_msgTime setAttributedTitle:[[NSAttributedString alloc] initWithString:timeSt attributes: attrDict3] forState:UIControlStateNormal];
    
}

/// 获得高度
+ (float)getMsgHeight:(ChatObject *)msgObj
{
    return msgObj.msgRowHeight;
}

/// 点击重新发送消息
- (void)clickResendMsg
{
    [_delegate resendMsg:_rowIndex];
}

- (void)avatarButtonClick
{
    [_delegate selectButtonTag:nil];
}

@end
