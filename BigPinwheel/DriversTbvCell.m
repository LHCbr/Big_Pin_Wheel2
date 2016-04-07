//
//  DriversTbvCell.m
//  BigPinwheel
//
//  Created by MZero on 16/3/1.
//  Copyright © 2016年 leita. All rights reserved.
//

#import "DriversTbvCell.h"

#define SideWith  15

@interface DriversTbvCell()

@property(nonatomic,strong)UIView  *line;

@end

@implementation DriversTbvCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor clearColor];
        [self addSubview];
    }
    return self;
}

-(void)addSubview{
    _label0 = [UILabel new];
    _label0.font = [UIFont boldSystemFontOfSize:15.0];
    [self addSubview:_label0];
    
    _label1 = [UILabel new];
    _label1.font = [UIFont systemFontOfSize:13.0];
    _label1.textColor = [UIColor darkTextColor];
    [self addSubview:_label1];
    
    _label2 = [UILabel new];
    _label2.font = [UIFont systemFontOfSize:13.0];
    _label2.textColor = [UIColor colorWithRed:14/255.0 green:166/255.0 blue:163/255.0 alpha:1.0];
    [self addSubview:_label2];
    
    _label3 = [UILabel new];
    _label3.font = [UIFont systemFontOfSize:13.0];
    //_label3.backgroundColor = [[UIColor lightGrayColor]colorWithAlphaComponent:0.85];
    _label3.backgroundColor = COLOR(217, 217, 217, 1);
    _label3.textAlignment = NSTextAlignmentCenter;
    _label3.textColor = [UIColor redColor];
    [self addSubview:_label3];
    
    _line = [UIView new];
    //_line.backgroundColor = [[UIColor lightGrayColor]colorWithAlphaComponent:0.85];
    _line.backgroundColor = COLOR(217, 217, 217, 1);
    [self addSubview:_line];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    _line.frame = CGRectMake(SideWith, CGRectGetHeight(self.bounds)-1.0*[UIScreen mainScreen].scale, CGRectGetWidth(self.bounds)-SideWith, 1.0*[UIScreen mainScreen].scale);
    
    _label3.frame = CGRectMake(CGRectGetWidth(self.bounds)-CGRectGetHeight(self.bounds)*1.2, 0, CGRectGetHeight(self.bounds)*1.2, CGRectGetHeight(self.bounds));
    
    _label0.frame = CGRectMake(SideWith, 0, CGRectGetWidth(self.bounds)-SideWith-CGRectGetWidth(_label3.bounds), CGRectGetHeight(self.bounds)*0.4);
    
    _label1.frame = CGRectMake(SideWith, CGRectGetHeight(self.bounds)*0.4, CGRectGetWidth(self.bounds)-SideWith-CGRectGetWidth(_label3.bounds), CGRectGetHeight(self.bounds)*0.25);
    
    _label2.frame = CGRectMake(SideWith, CGRectGetHeight(self.bounds)*0.65, CGRectGetWidth(self.bounds)-SideWith-CGRectGetWidth(_label3.bounds), CGRectGetHeight(self.bounds)*0.3);
}

@end
