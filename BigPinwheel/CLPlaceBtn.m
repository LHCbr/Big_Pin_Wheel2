//
//  CellPlaceBtn.m
//  BigPinwheel
//
//  Created by 徐伟 on 16/1/25.
//  Copyright © 2016年 leita. All rights reserved.
//

#import "CLPlaceBtn.h"

@implementation CLPlaceBtn

-(CGRect)imageRectForContentRect:(CGRect)contentRect
{
    if (_imageSize.width)
    {
        return CGRectMake(0, 1, _imageSize.width, _imageSize.height);
    }
    return CGRectMake(0, 0, 12, 15);
}

-(CGRect)titleRectForContentRect:(CGRect)contentRect
{
    if (_imageSize.width) {
        return CGRectMake(_imageSize.width+5.5, (contentRect.size.height -11)/2, contentRect.size.width -_imageSize.width -5.5, 11);
    }
    return CGRectMake(20,(contentRect.size.height-11)/2 , contentRect.size.width-20, 11);
}



@end
