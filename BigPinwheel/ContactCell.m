//
//  ContactCell.m
//  BigPinwheel
//
//  Created by xuwei on 16/3/4.
//  Copyright © 2016年 leita. All rights reserved.
//

#import "ContactCell.h"

@implementation ContactCell

-(void)dealloc
{
    NSLog(@"ContactCell界面释放");
    self.delegate = nil;
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = [UIColor whiteColor];
        self.contentView.frame = CGRectMake(0, 0, kDeviceWidth, 110/2 - 0.5);
        _avatarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _avatarBtn.backgroundColor = [UIColor clearColor];
        _avatarBtn.frame = CGRectMake(19/2, (self.contentView.frame.size.height -73/2)/2, 73/2, 73/2);
        [_avatarBtn.layer setMasksToBounds:YES];
        [_avatarBtn.layer setCornerRadius:4];
        [_avatarBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_avatarBtn];
        
        _namelabel = [self createLabelWithTextColor:[UIColor blackColor] frame:CGRectMake(_avatarBtn.frame.size.width+_avatarBtn.frame.origin.x +10.5, (self.contentView.frame.size.height-16)/2, kDeviceWidth - (_avatarBtn.frame.size.width+_avatarBtn.frame.origin.x +10.5), 16) textFont:[UIFont systemFontOfSize:16] bgColor:[UIColor clearColor] layerFont:0 borderWith:0 textAligement:NSTextAlignmentLeft];
        [self.contentView addSubview:_namelabel];
        
        _sepline = [[UIView alloc]initWithFrame:CGRectMake(_avatarBtn.frame.origin.x -1, self.contentView.frame.size.height, kDeviceWidth -(_avatarBtn.frame.origin.x -1), 0.5)];
        _sepline.backgroundColor = COLOR(217, 217, 217, 1);
        [self.contentView addSubview:_sepline];
        
    }
    return self;
}


-(void)buttonClick:(UIButton *)sender
{
    [_delegate cellAvatarBtnClick:sender];
    
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
