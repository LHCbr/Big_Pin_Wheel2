//
//  CityAndOnlineBtn.m
//  BigPinwheel
//
//  Created by 徐伟 on 16/2/17.
//  Copyright © 2016年 leita. All rights reserved.
//

#import "CityAndOnlineBtn.h"

@implementation CityAndOnlineBtn

-(CGRect)titleRectForContentRect:(CGRect)contentRect
{
    return CGRectMake(_imageSize.width+17/2, 2, contentRect.size.width -_imageSize.width -9, 11);
}

-(CGRect)imageRectForContentRect:(CGRect)contentRect
{
    return CGRectMake(0, 0, _imageSize.width, _imageSize.height);
}


@end
