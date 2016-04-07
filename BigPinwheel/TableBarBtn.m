//
//  TableBarBtn.m
//  BigPinwheel
//
//  Created by 徐伟 on 16/2/19.
//  Copyright © 2016年 leita. All rights reserved.
//

#import "TableBarBtn.h"

@implementation TableBarBtn

-(CGRect)titleRectForContentRect:(CGRect)contentRect
{
    if (_titleSize.width==0)
    {
        return CGRectZero;
    }
    return CGRectMake(0, contentRect.size.height-11, contentRect.size.width, 11);
}

-(CGRect)imageRectForContentRect:(CGRect)contentRect
{
    return CGRectMake(0, 0, _imageSize.width, _imageSize.height);
}

@end
