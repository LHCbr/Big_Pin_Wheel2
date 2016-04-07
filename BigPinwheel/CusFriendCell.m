//
//  CusFriendCell.m
//  LuLu
//
//  Created by a on 1/8/16.
//  Copyright © 2016 lbx. All rights reserved.
//

#import "CusFriendCell.h"

@implementation CusFriendCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier isMin:(BOOL)isMin
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        float width = [UIScreen mainScreen].bounds.size.width;
        float height = 50.0;
        
        self.contentView.frame = CGRectMake(0, 0, width, height);
        self.contentView.backgroundColor = [UIColor whiteColor];
        self.backgroundColor = [UIColor whiteColor];
        
        _avatarButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _avatarButton.frame = CGRectMake(15, 3, 44, 44);
        [_avatarButton.layer setCornerRadius:22];
        if (isMin) {
            _avatarButton.frame = CGRectMake(20, 8, 34, 34);
            [_avatarButton.layer setCornerRadius:17];
        }
        [_avatarButton.layer setMasksToBounds:YES];
        [_avatarButton.layer setBorderColor:[UIColor lightGrayColor].CGColor];
        [_avatarButton.layer setBorderWidth:0.25];
        [_avatarButton setBackgroundColor:[UIColor clearColor]];
        [_avatarButton.imageView setContentMode:UIViewContentModeScaleAspectFill];
        _avatarButton.userInteractionEnabled = NO;
        [self.contentView addSubview:_avatarButton];
        
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(74.0, 5, width - 74.0 - 30, 20)];
        if (isMin) {
            _nameLabel.frame = CGRectMake(74.0, 5, width - 74.0 - 30, 40);
        }
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.textColor = [UIColor blackColor];
        _nameLabel.font = [UIFont systemFontOfSize:17];
        [self.contentView addSubview:_nameLabel];
        
        if (!isMin) {
            _descLabel = [[UILabel alloc] initWithFrame:CGRectMake(_nameLabel.frame.origin.x, _nameLabel.frame.size.height + _nameLabel.frame.origin.y, _nameLabel.frame.size.width, 15)];
            _descLabel.backgroundColor = [UIColor clearColor];
            _descLabel.textColor = [UIColor lightGrayColor];
            _descLabel.font = [UIFont systemFontOfSize:13];
            [self.contentView addSubview:_descLabel];
        }
        
        UIView *sepLine = [[UIView alloc] initWithFrame:CGRectMake(74.0, 49.5, width - 74.0, 0.5)];
        sepLine.backgroundColor = [UIColor lightGrayColor];
        [self.contentView addSubview:sepLine];
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
