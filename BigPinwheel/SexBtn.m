//
//  SexBtn.m
//  BigPinwheel
//
//  Created by xuwei on 16/3/1.
//  Copyright © 2016年 leita. All rights reserved.
//

#import "SexBtn.h"

@implementation SexBtn

-(CGRect)imageRectForContentRect:(CGRect)contentRect
{
    return CGRectMake(0, 0, _imageSize.width, _imageSize.height);
}

-(CGRect)titleRectForContentRect:(CGRect)contentRect
{
    return CGRectMake(_imageSize.width+10.5, 2, contentRect.size.width -(_imageSize.width+10.5), contentRect.size.height-2-2);
}



@end
