//
//  FriendApplyCell.m
//  BigPinwheel
//
//  Created by xuwei on 16/3/4.
//  Copyright © 2016年 leita. All rights reserved.
//

#import "FriendApplyCell.h"

@implementation FriendApplyCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.contentView.backgroundColor = [UIColor whiteColor];
        //self.contentView.frame = CGRectMake(0, 0, kDeviceWidth, <#CGFloat height#>)
        
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
