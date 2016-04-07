//
//  signBtn.m
//  BigPinwheel
//
//  Created by xuwei on 16/3/1.
//  Copyright © 2016年 leita. All rights reserved.
//

#import "signBtn.h"

@implementation signBtn

-(CGRect)imageRectForContentRect:(CGRect)contentRect
{
    return CGRectMake(0, 0, _imgeSize.width, _imgeSize.height);
}

-(CGRect)titleRectForContentRect:(CGRect)contentRect
{
    return CGRectMake(_imgeSize.width+9, 1, contentRect.size.width -(_imgeSize.width+9), 14);
}



@end
