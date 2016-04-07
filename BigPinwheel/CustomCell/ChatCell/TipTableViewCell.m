//
//  TipTableViewCell.m
//  BDMapDemo
//
//  Created by tw001 on 14/11/6.
//  Copyright (c) 2014年 ESX. All rights reserved.
//

#import "TipTableViewCell.h"
#import "WSocket.h"

@implementation TipTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CELL_WIDTH;
        self.backgroundColor = [UIColor clearColor];
        
        _tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 10, self.contentView.frame.size.width - 80, 0)];
        _tipLabel.textAlignment = NSTextAlignmentCenter;
        _tipLabel.userInteractionEnabled = YES;
        _tipLabel.textColor = [UIColor blackColor];
        _tipLabel.backgroundColor = [UIColor clearColor];
        _tipLabel.layer.cornerRadius = 3.0f;
        _tipLabel.layer.borderWidth = 1;
        _tipLabel.numberOfLines = 0;
        _tipLabel.layer.borderColor = [[UIColor colorWithRed:206/255.0 green:206/255.0 blue:206/255.0 alpha:1] CGColor];
        _tipLabel.font = [UIFont systemFontOfSize:14];
        [self.contentView addSubview:_tipLabel];
        
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

- (void)tapShow
{
    [_delegate tapShowUserDetail];
}

/// 设置内容
- (void)setMsgContent:(NSString *)str
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapShow)];
    [_tipLabel addGestureRecognizer:tap];
    
    
    _tipLabel.text = str;
    CGSize aSize = [[InscriptionManager sharedManager] getSizeWithContent:str size:CGSizeMake(10000, 20) font:14];
    
    _tipLabel.frame = CGRectMake(_tipLabel.frame.origin.x, 10, _tipLabel.frame.size.width, aSize.height + 4);
}

/// 获得高度
+ (float)getMsgHeight:(NSString *)str
{
    float height = 0.0f;
    height = [[InscriptionManager sharedManager] getSizeWithContent:str size:CGSizeMake(10000, 20) font:14].height;
    height += 14;
    
    return height + 5;
}

@end
