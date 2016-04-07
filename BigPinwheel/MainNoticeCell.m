//
//  MainNoticeTableViewCell.m
//  BigPinwheel
//
//  Created by 徐伟 on 16/1/25.
//  Copyright © 2016年 leita. All rights reserved.
//

#import "MainNoticeCell.h"
#import "UIView+Extension.h"

@implementation MainNoticeCell

-(void)dealloc
{
    NSLog(@"主通知cell界面释放");
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        //头像_avatarView _timeLabel
        _avatarView = [[UIImageView alloc]initWithFrame:CGRectMake(11, 11, 65.5, 65.5 )];
        _avatarView.backgroundColor = [UIColor clearColor];
        [_avatarView.layer setMasksToBounds:YES];
        [_avatarView.layer setCornerRadius:8];
        [self.contentView addSubview:_avatarView];
        
        _timeLabel = [self createLabelWithTextColor:COLOR(131, 131, 131, 1) frame:CGRectMake(kDeviceWidth -75, 57/2, 75-13, 11) textFont:[UIFont systemFontOfSize:11] bgColor:[UIColor clearColor] layerFont:0 borderWith:0 textAligement:NSTextAlignmentRight];
        [self.contentView addSubview:_timeLabel];
        
        //_mainTitle _subTitle sepline
        _nameLabel = [self createLabelWithTextColor:[UIColor blackColor] frame:CGRectMake(12+_avatarView.frame.size.width+_avatarView.frame.origin.x, 25, kDeviceWidth-75, 14) textFont:[UIFont systemFontOfSize:14] bgColor:[UIColor clearColor] layerFont:0 borderWith:0 textAligement:NSTextAlignmentLeft];
        _nameLabel.text = @"大丰车团队";
        [self.contentView addSubview:_nameLabel];
        
        _lastMSGLabel = [self createLabelWithTextColor:COLOR(133, 133, 133, 1) frame:CGRectMake(_nameLabel.frame.origin.x, 8+_nameLabel.frame.size.height+_nameLabel.frame.origin.y, kDeviceWidth-_nameLabel.frame.origin.x-75/2, 12) textFont:[UIFont systemFontOfSize:12] bgColor:[UIColor clearColor] layerFont:0 borderWith:0 textAligement:NSTextAlignmentLeft];
        [self.contentView addSubview:_lastMSGLabel];
        
        _sepline = [[UIView alloc]initWithFrame:CGRectMake(_avatarView.frame.size.width+_avatarView.frame.origin.x+0.5, _avatarView.frame.origin.y+_avatarView.frame.size.height+8.5, kDeviceWidth-(_avatarView.frame.size.width+_avatarView.frame.origin.x+0.5), 0.5)];
        _sepline.backgroundColor = COLOR(221, 221, 221, 1);
        [self.contentView addSubview:_sepline];
        
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

    // Configure the view for the selected state
}

@end
