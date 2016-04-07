//
//  SectionItem.m
//  BigPinwheel
//
//  Created by 徐伟 on 16/1/15.
//  Copyright © 2016年 leita. All rights reserved.
//

#import "SectionItem.h"

@implementation SectionItem

-(instancetype)initWithTitle:(NSString *)title subTitle:(NSString *)subtitle imageArray:(NSMutableArray *)imageArray
{
    self = [super init];
    if (self)
    {
        _title = title;
        _subTitle = subtitle;
        _imageArray = imageArray;
    }
    return self;
}

@end
