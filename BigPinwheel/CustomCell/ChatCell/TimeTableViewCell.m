//
//  TimeTableViewCell.m
//  LeiRen
//
//  Created by tw001 on 14-9-17.
//  Copyright (c) 2014年 wave. All rights reserved.
//

#import "TimeTableViewCell.h"
#import "WSocket.h"

@implementation TimeTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CELL_WIDTH;
        self.contentView.backgroundColor = [UIColor clearColor];
        self.backgroundColor = [UIColor clearColor];
        
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.textColor = [UIColor whiteColor];
        _timeLabel.font = [UIFont boldSystemFontOfSize:14];
        _timeLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
        [_timeLabel.layer setCornerRadius:10];
        [_timeLabel.layer setMasksToBounds:YES];
        [self.contentView addSubview:_timeLabel];
        
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

/// 设置消息内容
- (void)setMsgContent:(NSString *)timeStr
{
    _timeLabel.text = timeStr;
    CGSize aSize = [self getSizeWithContent:timeStr size:CGSizeMake(10000, 20) font:14];
    _timeLabel.frame = CGRectMake((self.contentView.frame.size.width - (aSize.width + 20)) / 2, 10, aSize.width + 20, 20);
    if (_timeLabel.text.length <= 0) {
        _timeLabel.backgroundColor = [UIColor clearColor];
    } else {
        _timeLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
    }

}

/// 获取内容的cgsize
- (CGSize)getSizeWithContent:(NSString *)content size:(CGSize)size font:(CGFloat)font
{
    CGRect contentBounds = [content boundingRectWithSize:size
                                                 options:NSStringDrawingUsesLineFragmentOrigin
                                              attributes:[NSDictionary dictionaryWithObject:[UIFont boldSystemFontOfSize:font]
                                                                                     forKey:NSFontAttributeName]
                                                 context:nil];
    return contentBounds.size;
}

/// 获得高度
+ (float)getMsgHeight
{
    return 30.0f;
}

@end
