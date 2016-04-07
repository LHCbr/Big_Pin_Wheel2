//
//  AddressBookTableViewCell2.m
//  BDMapDemo
//
//  Created by tw001 on 14/12/22.
//  Copyright (c) 2014年 ESX. All rights reserved.
//

#import "AddressBookTableViewCell2.h"

@implementation AddressBookTableViewCell2

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CELL_WIDTH;
        self.backgroundColor = [UIColor whiteColor];
        
        _avatarButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _avatarButton.frame = CGRectMake(10, 10, 36, 36);
        [_avatarButton.layer setCornerRadius:18];
        [_avatarButton.layer setMasksToBounds:YES];
        [self.contentView addSubview:_avatarButton];
        
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(51, 0, (self.contentView.frame.size.width / 2.0), 56)];
        _contentLabel.font = [UIFont systemFontOfSize:16.0f];
        _contentLabel.textColor = [UIColor blackColor];
        [self.contentView addSubview:_contentLabel];
        
        _locationLabel = [[UILabel alloc]initWithFrame:CGRectMake(51, 30, (self.contentView.frame.size.width / 2.0), 26)];
        _locationLabel.font = [UIFont systemFontOfSize:10];
        _locationLabel.textAlignment = NSTextAlignmentLeft;
        _locationLabel.textColor = COLOR(36, 157, 117, 1);
        [self.contentView addSubview:_locationLabel];
        _locationLabel.hidden = YES;
        
        _chatButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_chatButton setImage:[UIImage imageNamed:@"0728_quan"] forState:UIControlStateNormal];
        _chatButton.frame = CGRectMake(self.contentView.frame.size.width - 46, 0, 36, 56);
        [self.contentView addSubview:_chatButton];
        [_chatButton setHidden:YES];
        
        _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_deleteButton setImage:[UIImage imageNamed:@"0514_tongxun_shezhi"] forState:UIControlStateNormal];
        _deleteButton.frame = CGRectMake(self.contentView.frame.size.width - 46 - 36, 0, 36, 56);
        [self.contentView addSubview:_deleteButton];
        [_deleteButton setHidden:YES];

//        _snacksButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [_snacksButton setImage:[UIImage imageNamed:@"0603_tongxun_tang"] forState:UIControlStateNormal];
//        _snacksButton.frame = CGRectMake(self.contentView.frame.size.width - 46 - 36 - 36, 0, 36, 56);
//        [self.contentView addSubview:_snacksButton];
//        [_snacksButton setHidden:YES];
        
        _lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 55.5, self.contentView.frame.size.width, 0.5)];
        _lineView.backgroundColor = COLOR(235, 235, 235, 1);
        [self.contentView addSubview:_lineView];
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

@end
