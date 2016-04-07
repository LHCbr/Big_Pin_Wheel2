//
//  ChatTableViewCell.m
//  LeiRen
//
//  Created by tw001 on 14-9-17.
//  Copyright (c) 2014年 wave. All rights reserved.
//

#import "ChatTableViewCell.h"

@implementation ChatTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        float width = [UIScreen mainScreen].bounds.size.width;
        self.contentView.backgroundColor = [UIColor clearColor];
        self.backgroundColor = [UIColor clearColor];
        self.contentView.frame = CGRectMake(0, 0, width, 40.0);
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _avatarBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 5, 40, 40)];
        _avatarBtn.layer.masksToBounds = YES;
        _avatarBtn.layer.cornerRadius = 20.0f;
        [_avatarBtn setImage:nil forState:UIControlStateNormal];
//        [self.contentView addSubview:_avatarBtn];
        
        _msgView = [[UIView alloc] initWithFrame:CGRectMake(0, 5, self.contentView.frame.size.width - 50, 40)];
        [self.contentView addSubview:_msgView];
        
        _bgImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [_msgView addSubview:_bgImageView];
        
        _msgTime = [ChatListDateBtn buttonWithType:UIButtonTypeCustom];
        _msgTime.userInteractionEnabled = NO;
        [_msgTime.titleLabel setTextAlignment:NSTextAlignmentRight];
        [_msgTime.titleLabel setFont:[UIFont systemFontOfSize:9]];
        [_msgTime setBackgroundColor:[UIColor clearColor]];
        [_msgTime.titleLabel setAdjustsFontSizeToFitWidth:YES];
        _msgTime.frame = CGRectZero;
        [self.contentView addSubview:_msgTime];
        
        _roundGreenImage = [UIImage imageNamed:@"1111_bubble_round_green"];
        _roundGreenImage = [_roundGreenImage stretchableImageWithLeftCapWidth:25 topCapHeight:17];
        
        _roundWhiteImage = [UIImage imageNamed:@"1111_bubble_round_white"];
        _roundWhiteImage = [_roundWhiteImage stretchableImageWithLeftCapWidth:25 topCapHeight:17];
        
        _normalGreenImage = [UIImage imageNamed:@"1111_bubble_normal_green"];
        _normalGreenImage = [_normalGreenImage stretchableImageWithLeftCapWidth:9 topCapHeight:6];

        _normalWhiteImage = [UIImage imageNamed:@"1111_bubble_normal_white"];
        _normalWhiteImage = [_normalWhiteImage stretchableImageWithLeftCapWidth:9 topCapHeight:6];

    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
