//
//  ChatListDateBtn.m
//  LuLu
//
//  Created by 徐伟 on 16/1/6.
//  Copyright © 2016年 lbx. All rights reserved.
//

#import "ChatListDateBtn.h"

@implementation ChatListDateBtn

-(CGRect)titleRectForContentRect:(CGRect)contentRect
{
    if (_imageSize.width) {
        return CGRectMake(_imageSize.width+5, 0, contentRect.size.width -5 -_imageSize.width, contentRect.size.height);
    }
    return CGRectMake(0, 0, contentRect.size.width - 20.0, contentRect.size.height);
}

-(CGRect)imageRectForContentRect:(CGRect)contentRect
{
    if (_imageSize.width) {
        return CGRectMake(0, (contentRect.size.height - _imageSize.height)/2.0,_imageSize.width , _imageSize.height);
    }
    
    return CGRectMake(contentRect.size.width - 14.0, 0, 14.0, contentRect.size.height);
}

@end
