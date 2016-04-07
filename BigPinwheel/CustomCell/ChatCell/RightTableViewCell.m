//
//  RightTableViewCell.m
//  LeiRen
//
//  Created by tw001 on 14-9-17.
//  Copyright (c) 2014年 wave. All rights reserved.
//

#import "RightTableViewCell.h"
#define KFacialSizeWidth 24
#define KFacialSizeHeight 24

@implementation RightTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

        self.bgImageView.image = _normalGreenImage;
        
        [_avatarBtn setFrame:CGRectMake(self.contentView.frame.size.width - kRightAvatarWidthZero, _avatarBtn.frame.origin.y, _avatarBtn.frame.size.width, _avatarBtn.frame.size.height)];

        _failueBtn = [[UIButton alloc] initWithFrame:CGRectMake(50, 10, 30, 30)];
        [_failueBtn setImage:[UIImage imageNamed:@"failue"] forState:UIControlStateNormal];
        _failueBtn.hidden = YES;
        [self.contentView addSubview:_failueBtn];
        
        _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activityView.frame = CGRectMake(50, 10, 30, 30);
        _activityView.color = COLOR(79, 173, 75, 1);
        _activityView.hidden = YES;
        [self.contentView addSubview:_activityView];

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
