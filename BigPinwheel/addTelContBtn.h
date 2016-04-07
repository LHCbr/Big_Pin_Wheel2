//
//  addTelContBtn.h
//  BigPinwheel
//
//  Created by xuwei on 16/3/5.
//  Copyright © 2016年 leita. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface addTelContBtn : UIButton

@property(assign,nonatomic)CGSize imageSize;

-(CGRect)titleRectForContentRect:(CGRect)contentRect;
-(CGRect)imageRectForContentRect:(CGRect)contentRect;

@end
