//
//  FilterDespBtn.m
//  BigPinwheel
//
//  Created by 徐伟 on 16/2/21.
//  Copyright © 2016年 leita. All rights reserved.
//

#import "FilterDespBtn.h"

@implementation FilterDespBtn

-(CGRect)titleRectForContentRect:(CGRect)contentRect
{
    return CGRectMake(0,(contentRect.size.height-10.5)/2, 29, 14);
}

-(CGRect)imageRectForContentRect:(CGRect)contentRect
{
    return CGRectMake(contentRect.size.width -11, (contentRect.size.height -6.5)/2, 11, 7);
}

@end
