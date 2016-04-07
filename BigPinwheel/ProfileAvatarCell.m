//
//  ProfileAvatarCell.m
//  BigPinwheel
//
//  Created by xuwei on 16/2/28.
//  Copyright © 2016年 leita. All rights reserved.
//

#import "ProfileAvatarCell.h"

@implementation ProfileAvatarCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        
        self.contentView.backgroundColor = [UIColor clearColor];
        self.contentView.frame =CGRectMake(0, 0, kPopOffSetX, 270/2);
        self.backgroundColor = [UIColor clearColor];
        
        //_avatarBtn  _nameLabel _placeBtn
        _avatarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _avatarBtn.backgroundColor = [UIColor clearColor];
        _avatarBtn.frame = CGRectMake(9, 63/2, 175/2, 175/2);
        [_avatarBtn.layer setMasksToBounds:YES];
        [_avatarBtn.layer setCornerRadius:8];
        _avatarBtn.contentMode = UIViewContentModeScaleAspectFit;
        _avatarBtn.userInteractionEnabled = NO;
        [self.contentView addSubview:_avatarBtn];
        
        _nameLabel = [self createLabelWithTextColor:[UIColor whiteColor]frame:CGRectMake(12+_avatarBtn.frame.size.width+_avatarBtn.frame.origin.x, 59/2 +_avatarBtn.frame.origin.y, kDeviceWidth - (12+_avatarBtn.frame.size.width+_avatarBtn.frame.origin.x), 16) textFont:[UIFont systemFontOfSize:16] bgColor:[UIColor clearColor] layerFont:0 borderWith:0 textAligement:NSTextAlignmentLeft];
        _nameLabel.text = @"司机师傅";
        [self.contentView addSubview:_nameLabel];
        
        _placeBtn = [CLPlaceBtn buttonWithType:UIButtonTypeCustom];
        _placeBtn.backgroundColor = [UIColor clearColor];
        _placeBtn.imageSize = CGSizeMake(8, 10.5);
        _placeBtn.frame = CGRectMake(_nameLabel.frame.origin.x - 0.5, CGRectGetMaxY(_nameLabel.frame)+13.5, kDeviceWidth - (_nameLabel.frame.origin.x - 0.5), 11);
        _placeBtn.enabled = NO;
        [_placeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_placeBtn.titleLabel setFont:[UIFont systemFontOfSize:11]];
        [_placeBtn setTitle:@"苏州市相城区太平镇金澄村" forState:UIControlStateNormal];
        [_placeBtn setImage:[UIImage imageNamed:@"0229_location"] forState:UIControlStateNormal];
        [self.contentView addSubview:_placeBtn];
        
        UIView *sepline = [[UIView alloc]initWithFrame:CGRectMake(9.5,self.contentView.frame.size.height, kPopOffSetX -19, 0.5)];
        sepline.backgroundColor = COLOR(158, 147, 116, 1);
        [self.contentView addSubview:sepline];
        
        
    }
    return self;
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
