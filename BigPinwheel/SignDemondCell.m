//
//  SignDemondCell.m
//  BigPinwheel
//
//  Created by xuwei on 16/2/28.
//  Copyright © 2016年 leita. All rights reserved.
//

#import "SignDemondCell.h"

@implementation SignDemondCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        self.contentView.frame = CGRectMake(0, 0, kDeviceWidth, 159.5);
        
        _signBtn = [signBtn buttonWithType:UIButtonTypeCustom];
        _signBtn.backgroundColor = [UIColor clearColor];
        _signBtn.imgeSize = CGSizeMake(15, 15);
        _signBtn.frame =CGRectMake(19/2, 59/2,kDeviceWidth/4 , 15);
        [_signBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_signBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [_signBtn setTitle:@"需求签名" forState:UIControlStateNormal];
        [_signBtn setImage:[UIImage imageNamed:@"0229_demondSign"] forState:UIControlStateNormal];
        _signBtn.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:_signBtn];
        
        _demondlabel = [[UILabel alloc]initWithFrame:CGRectMake(31,_signBtn.frame.size.height+_signBtn.frame.origin.y, kPopOffSetX -31*2,self.contentView.frame.size.height -66-1)];
        _demondlabel.backgroundColor = [UIColor clearColor];
        _demondlabel.numberOfLines = 3;
        _demondlabel.font = [UIFont systemFontOfSize:14];
        _demondlabel.textColor = [UIColor whiteColor];
        _demondlabel.textAlignment = NSTextAlignmentLeft;
        
        
        [self.contentView addSubview:_demondlabel];
        
        UIView *sepline = [[UIView alloc]initWithFrame:CGRectMake(9.5,self.contentView.frame.size.height, kPopOffSetX -19, 0.5)];
        sepline.backgroundColor = COLOR(158, 147, 116, 1);
        [self.contentView addSubview:sepline];
        
    }
    return self;
}






- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
