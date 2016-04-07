//
//  addFriendsCell.m
//  BigPinwheel
//
//  Created by xuwei on 16/3/4.
//  Copyright © 2016年 leita. All rights reserved.
//

#import "addFriendsCell.h"

@implementation addFriendsCell

-(void)dealloc
{
    NSLog(@"添加好友cell界面释放");
    self.delegate = nil;
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.contentView.backgroundColor = [UIColor whiteColor];
        self.contentView.frame = CGRectMake(0, 0, kDeviceWidth, 119/2);
        
        _avatarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _avatarBtn.backgroundColor = [UIColor purpleColor];
        _avatarBtn.frame = CGRectMake(10, 19/2, 36, 36);
        _avatarBtn.contentMode = UIViewContentModeScaleAspectFit;
        _avatarBtn.tag = 2;
        [_avatarBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_avatarBtn];
        
        _namelabel = [self createLabelWithTextColor:[UIColor blackColor] frame:CGRectMake(_avatarBtn.frame.size.width+_avatarBtn.frame.origin.x+11, 11, kDeviceWidth -(_avatarBtn.frame.size.width+_avatarBtn.frame.origin.x+11+64), 16) textFont:[UIFont systemFontOfSize:16] bgColor:[UIColor clearColor] layerFont:0 borderWith:0 textAligement:NSTextAlignmentLeft];
        [self.contentView addSubview:_namelabel];
        
        _desplabel = [self createLabelWithTextColor:COLOR(141, 141, 141, 1) frame:CGRectMake(_namelabel.frame.origin.x, _namelabel.frame.size.height+_namelabel.frame.origin.y+8.5,_namelabel.frame.size.width , 13) textFont:[UIFont systemFontOfSize:13] bgColor:[UIColor clearColor] layerFont:0 borderWith:0 textAligement:NSTextAlignmentLeft];
        [self.contentView addSubview:_desplabel];
        
        _addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _addBtn.backgroundColor = COLOR(0, 146, 79, 1);
        _addBtn.frame = CGRectMake(kDeviceWidth- kDeviceWidth* 128/750, (self.contentView.frame.size.height -31)/2,kDeviceWidth* 50/375, 31);
        [_addBtn.layer setMasksToBounds:YES];
        [_addBtn.layer setCornerRadius:4];
        [_addBtn setTitle:@"添加" forState:UIControlStateNormal];
        [_addBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_addBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
        _addBtn.tag = 1;
        [_addBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_addBtn];
        
        _sepline = [[UIView alloc]initWithFrame:CGRectMake(15, self.contentView.frame.size.height, self.contentView.frame.size.width -15, 0.5)];
        _sepline.backgroundColor = COLOR(217, 217, 217, 1);
        [self.contentView addSubview:_sepline];
        
    }
    return self;
}

#pragma mark -点击事件
-(void)buttonClick:(UIButton *)sender
{
    if (sender.tag ==1)
    {
        [sender setBackgroundColor:[UIColor clearColor]];
        [sender setTitleColor:COLOR(179, 179, 179, 1) forState:UIControlStateNormal];
        [sender setTitle:@"已添加" forState:UIControlStateNormal];
        [sender setEnabled:NO];
        [_delegate addFriendsBtnDidClick:sender];
    }
    else if (sender.tag ==2)
    {
        NSLog(@"cell头像按钮点击事件");
    }
}

-(void)setSeplineX:(CGFloat)x isHidden:(BOOL)isHidden
{
    _sepline.frame = CGRectMake(x, _sepline.frame.origin.y, kDeviceWidth -x, 0.5);
    if (isHidden==YES)
    {
        [_sepline setHidden:YES];
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
