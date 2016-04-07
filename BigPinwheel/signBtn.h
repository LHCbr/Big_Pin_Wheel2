//
//  signBtn.h
//  BigPinwheel
//
//  Created by xuwei on 16/3/1.
//  Copyright © 2016年 leita. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface signBtn : UIButton

@property(assign,nonatomic)CGSize imgeSize;
-(CGRect)titleRectForContentRect:(CGRect)contentRect;
-(CGRect)imageRectForContentRect:(CGRect)contentRect;


@end
