//
//  HomeDriverListCell.m
//  BigPinwheel
//
//  Created by xuwei on 16/4/9.
//  Copyright © 2016年 leita. All rights reserved.
//

#import "HomeDriverListCell.h"

@implementation HomeDriverListCell

-(void)dealloc
{
    NSLog(@"首页司机列表cell释放");
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self){
        self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
        
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
