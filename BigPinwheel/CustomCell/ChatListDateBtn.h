//
//  ChatListDateBtn.h
//  LuLu
//
//  Created by 徐伟 on 16/1/6.
//  Copyright © 2016年 lbx. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatListDateBtn : UIButton

@property(assign,nonatomic)CGSize imageSize;          // 普通的

-(CGRect)titleRectForContentRect:(CGRect)contentRect;
-(CGRect)imageRectForContentRect:(CGRect)contentRect;


@end
