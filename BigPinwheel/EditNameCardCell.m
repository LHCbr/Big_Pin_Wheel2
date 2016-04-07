//
//  EditNameCardCell.m
//  BigPinwheel
//
//  Created by xuwei on 16/3/3.
//  Copyright © 2016年 leita. All rights reserved.
//

#import "EditNameCardCell.h"

@implementation EditNameCardCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.contentView.backgroundColor = [UIColor whiteColor];
        self.contentView.frame = CGRectMake(0, 0, kDeviceWidth, 44);
        
        _textField = [[UITextField alloc]initWithFrame:CGRectMake(0, 0, kDeviceWidth*3/4, 44)];
        _textField.backgroundColor = [UIColor clearColor];
        _textField.font = [UIFont systemFontOfSize:14];
        _textField.keyboardAppearance = UIKeyboardAppearanceDefault;
        _textField.keyboardType = UIKeyboardTypeNamePhonePad;
        _textField.leftViewMode = UITextFieldViewModeAlways;
        _textField.rightViewMode = UITextFieldViewModeAlways;
        [self.contentView addSubview:_textField];
        
        UIView *leftView =[[UIView alloc]initWithFrame:CGRectMake(0, 0, 176/2, _textField.frame.size.height)];
        leftView.backgroundColor = [UIColor clearColor];
        _textField.leftView = leftView;
        
        _label = [self createLabelWithTextColor:COLOR(128, 128, 128, 1) frame:CGRectMake(12, (leftView.frame.size.height -14)/2, leftView.frame.size.width -12, 13.5) textFont:[UIFont systemFontOfSize:14] bgColor:[UIColor clearColor] layerFont:0 borderWith:0 textAligement:NSTextAlignmentLeft];
        [leftView addSubview:_label];
        
        _descrilabel = [self createLabelWithTextColor:COLOR(128, 128, 128, 1) frame:CGRectMake(kDeviceWidth -256/2, _label.frame.origin.y, 150/2+2, 13.5) textFont:[UIFont systemFontOfSize:13.5] bgColor:[UIColor clearColor] layerFont:0 borderWith:0 textAligement:NSTextAlignmentCenter];
        _descrilabel.hidden = YES;
        _descrilabel.text = @"公开";
        [self.contentView addSubview:_descrilabel];
        
        _sepline = [[UIView alloc]initWithFrame:CGRectMake(leftView.frame.size.width-4, self.contentView.frame.size.height, kDeviceWidth - (_label.frame.origin.x -4), 0.5)];
        _sepline.backgroundColor = COLOR(221, 221, 221, 1);
        [self.contentView addSubview:_sepline];
        
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
