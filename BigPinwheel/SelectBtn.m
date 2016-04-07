//
//  SelectBtn.m
//  BigPinwheel
//
//  Created by 徐伟 on 16/2/26.
//  Copyright © 2016年 leita. All rights reserved.
//

#import "SelectBtn.h"

@implementation SelectBtn

-(CGRect)titleRectForContentRect:(CGRect)contentRect
{
    return CGRectMake(_imageSize.width+7, 1.5, contentRect.size.width -_imageSize.width-7, contentRect.size.height -1.5 );
}

-(CGRect)imageRectForContentRect:(CGRect)contentRect
{
    return CGRectMake(0, 3, _imageSize.width, _imageSize.height);
}



@end
