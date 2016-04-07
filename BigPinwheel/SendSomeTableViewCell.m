//
//  SendSomeTableViewCell.m
//  leita
//
//  Created by tw001 on 15/5/26.
//
//

#import "SendSomeTableViewCell.h"

@implementation SendSomeTableViewCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _sexImgView = [UIButton buttonWithType:UIButtonTypeCustom];
        _sexImgView.frame = CGRectMake(10, 28-10, 20, 20);
//        [self.contentView addSubview:_sexImgView];
        
        _nikeNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(40, 13, [UIScreen mainScreen].bounds.size.width-40-56-10, 30)];
        [self.contentView addSubview:_nikeNameLabel];
        
        _selectedBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _selectedBtn.frame = CGRectMake(5, 0, 30, 56);
        [_selectedBtn setImage:[UIImage imageNamed:@"tongxun_weixuanzhong"] forState:UIControlStateNormal];
        [self.contentView addSubview:_selectedBtn];
        
        UIView *seperate = [[UIView alloc]initWithFrame:CGRectMake(0, 56-0.5, [UIScreen mainScreen].bounds.size.width-20, 0.5)];
        seperate.backgroundColor = COLOR(236, 236, 236, 1);
        [self.contentView addSubview:seperate];
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
