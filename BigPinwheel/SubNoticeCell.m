//
//  BIZContactableViewCell.m
//  BigPinwheel
//
//  Created by 徐伟 on 16/2/14.
//  Copyright © 2016年 leita. All rights reserved.
//

#import "SubNoticeCell.h"

@implementation SubNoticeCell

-(void)dealloc
{
    NSLog(@"通讯录通知cell或者商业合作cell释放");
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier isTaskCenter:(BOOL)isTaskCenter
{
    self = [super init];
    if (self) {
        self.contentView.frame = CGRectMake(0, 0, kDeviceWidth, 65);
        self.contentView.backgroundColor =  [UIColor whiteColor];
        
        //头像avatarView 小圆圈tipLabel
        _avatarView = [[UIImageView alloc]initWithFrame:CGRectMake(12.5, 10, 44.5, 44.5)];
        _avatarView.backgroundColor = [UIColor clearColor];
        [_avatarView.layer setMasksToBounds:YES];
        [_avatarView.layer setCornerRadius:4];
        [self.contentView addSubview:_avatarView];
        
        CGFloat tipWidth = 17;
        CGFloat tipY = 1;
        if (isTaskCenter==YES) {
            tipWidth = 12;
            tipY = 4;
        }
        _tipLabel = [self createLabelWithTextColor:[UIColor whiteColor] frame:CGRectMake(_avatarView.frame.origin.x+_avatarView.frame.size.width-tipWidth/2, tipY,tipWidth,tipWidth) textFont:[UIFont systemFontOfSize:(tipWidth+1)/2] bgColor:COLOR(255, 109, 110, 1) layerFont:0 borderWith:0 textAligement:NSTextAlignmentCenter];
        [_tipLabel.layer setMasksToBounds:YES];
        [_tipLabel.layer setCornerRadius:tipWidth/2];
        [self.contentView addSubview:_tipLabel];
        
        //mainlabel timelabel sublabel
        _nameLabel = [self createLabelWithTextColor:[UIColor blackColor] frame:CGRectMake(12+_avatarView.frame.origin.x+_avatarView.frame.size.width, 15, kDeviceWidth -75-12-(_avatarView.frame.origin.x+_avatarView.frame.size.width), 15) textFont:[UIFont systemFontOfSize:14] bgColor:[UIColor clearColor] layerFont:0 borderWith:0 textAligement:NSTextAlignmentLeft];
        [self.contentView addSubview:_nameLabel];
        _timeLabel = [self createLabelWithTextColor:COLOR(131, 131, 131, 1) frame:CGRectMake(kDeviceWidth-75, 18, 62, 10) textFont:[UIFont systemFontOfSize:10] bgColor:[UIColor clearColor] layerFont:0 borderWith:0 textAligement:NSTextAlignmentRight];
        [self.contentView addSubview:_timeLabel];
        _lastMSGLabel = [self createLabelWithTextColor:COLOR(131, 131, 131, 1) frame:CGRectMake(_nameLabel.frame.origin.x-0.5, _nameLabel.frame.size.height+_nameLabel.frame.origin.y+11, kDeviceWidth-_nameLabel.frame.origin.x+0.5, 12) textFont:[UIFont systemFontOfSize:12] bgColor:[UIColor clearColor] layerFont:0 borderWith:0 textAligement:NSTextAlignmentLeft];
        [self.contentView addSubview:_lastMSGLabel];
        
        //底部sepline
        CGFloat sepX = _nameLabel.frame.origin.x -6;
        if (isTaskCenter==YES) {
            sepX = 0;
        }
        CGFloat sepWidth = kDeviceWidth -sepX;
        _sepline = [[UIView alloc]initWithFrame:CGRectMake(sepX, self.contentView.frame.size.height-0.5,sepWidth, 0.5)];
        _sepline.backgroundColor = COLOR(220, 220, 220, 1);
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
