//
//  addTelContBtn.m
//  BigPinwheel
//
//  Created by xuwei on 16/3/5.
//  Copyright © 2016年 leita. All rights reserved.
//

#import "addTelContBtn.h"

@implementation addTelContBtn

-(CGRect)imageRectForContentRect:(CGRect)contentRect
{
    return CGRectMake(contentRect.size.width/2 -_imageSize.width/2 , 12, _imageSize.width, _imageSize.height);
    
}

-(CGRect)titleRectForContentRect:(CGRect)contentRect
{
    return CGRectMake(0, 12+_imageSize.height+11.5,kDeviceWidth, 14);
}


@end
