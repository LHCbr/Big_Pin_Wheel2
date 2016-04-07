//
//  ChatListTableViewCell.m
//  BigPinwheel
//
//  Created by 徐伟 on 16/1/19.
//  Copyright © 2016年 leita. All rights reserved.
//

#import "ChatListCell.h"

@implementation ChatListCell

-(void)dealloc
{
    NSLog(@"聊天列表cell界面释放");
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.contentView.frame = CGRectMake(0, 0, kDeviceWidth, kCellHeight);
        self.contentView.backgroundColor = [UIColor whiteColor];
        
        //头像_avatarView
        _avatarView = [[UIImageView alloc]initWithFrame:CGRectMake(11, 11,65.5, 65.5)];
        _avatarView.backgroundColor = [UIColor clearColor];
        [_avatarView.layer setMasksToBounds:YES];
        [_avatarView.layer setCornerRadius:4];
        [self.contentView addSubview:_avatarView];
        
        //姓名_namelabel  时间_timeLabel
        _nameLabel = [self createLabelWithTextColor:[UIColor blackColor] frame:CGRectMake(12.5+_avatarView.frame.size.width+_avatarView.frame.origin.x, 18, kDeviceWidth-(75+_avatarView.frame.size.width+_avatarView.frame.origin.x+12.5), 15) textFont:[UIFont systemFontOfSize:15] bgColor:[UIColor clearColor] layerFont:0 borderWith:0 textAligement:NSTextAlignmentLeft];
        [self.contentView addSubview:_nameLabel];
        
        _timeLabel = [self createLabelWithTextColor:COLOR(197, 197, 197, 1) frame:CGRectMake(kDeviceWidth-75, 17.5, 62, 11) textFont:[UIFont systemFontOfSize:11] bgColor:[UIColor clearColor] layerFont:0 borderWith:0 textAligement:NSTextAlignmentRight];
        [self.contentView addSubview:_timeLabel];
        
        _placeBtn = [[CLPlaceBtn alloc]initWithFrame:CGRectMake(_avatarView.frame.size.width+_avatarView.frame.origin.x+11, _nameLabel.frame.size.height+_nameLabel.frame.origin.y+5, kDeviceWidth -(_avatarView.frame.size.width+_avatarView.frame.origin.x+11), 15)];
        _placeBtn.backgroundColor = [UIColor clearColor];
        _placeBtn.imageSize = CGSizeMake(12, 15);
        [_placeBtn setImage:[UIImage imageNamed:@"0222_location"] forState:UIControlStateNormal];
        [_placeBtn setTitleColor:COLOR(166, 187, 204, 1) forState:UIControlStateNormal];
        [_placeBtn.titleLabel setFont:[UIFont systemFontOfSize:11]];
        [_placeBtn setEnabled:NO];
        [_placeBtn setHidden:YES];
        [self.contentView addSubview:_placeBtn];
        
        
        _lastMSGLabel = [self createLabelWithTextColor:COLOR(144, 144, 144, 1) frame:CGRectMake(_nameLabel.frame.origin.x+0.5, 15+11+_nameLabel.frame.size.height+_nameLabel.frame.origin.y+7.5, kDeviceWidth -13 -_nameLabel.frame.origin.x-0.5, 12) textFont:[UIFont systemFontOfSize:12] bgColor:[UIColor clearColor] layerFont:0 borderWith:0 textAligement:NSTextAlignmentLeft];
        [self.contentView addSubview:_lastMSGLabel];
        
        _defaultRect = _lastMSGLabel.frame;
        
        //底部sepline
        _sepline = [[UIView alloc]initWithFrame:CGRectMake(_nameLabel.frame.origin.x -13, _avatarView.frame.size.height+_avatarView.frame.origin.y+9, kDeviceWidth-(_nameLabel.frame.origin.x -13), 0.5)];
        _sepline.backgroundColor = COLOR(221, 221, 221, 1);
        [self.contentView addSubview:_sepline];
        
        //小圆圈提示
        _tipLabel = [self createLabelWithTextColor:COLOR(255, 59, 47, 1) frame:CGRectMake(kDeviceWidth -20 -15, _timeLabel.frame.size.height+_timeLabel.frame.origin.y+17, 22, 22) textFont:[UIFont systemFontOfSize:10] bgColor:[UIColor clearColor] layerFont:0 borderWith:0 textAligement:NSTextAlignmentCenter];
        [self.contentView addSubview:_tipLabel];
        
        //失败的标示
        _failedImageView = [[UIImageView alloc]initWithFrame:_tipLabel.frame];
        _failedImageView.image = [UIImage imageNamed:@"0230_failure"];
        [_failedImageView setContentMode:UIViewContentModeScaleAspectFit];
        [self.contentView addSubview:_failedImageView];
        [_failedImageView setHidden:YES];
        
    }
    return self;
}

-(void)setSeplineX:(BOOL)isEtch
{
    if (isEtch==YES) {
        _sepline.frame = CGRectMake(0, self.contentView.frame.size.height-0.5, self.contentView.frame.size.width, 0.5);
    }
    
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


- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

@end
