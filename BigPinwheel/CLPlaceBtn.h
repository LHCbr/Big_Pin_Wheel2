//
//  CellPlaceBtn.h
//  BigPinwheel
//
//  Created by 徐伟 on 16/1/25.
//  Copyright © 2016年 leita. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CLPlaceBtn : UIButton

@property(assign,nonatomic)CGSize imageSize;

-(CGRect)titleRectForContentRect:(CGRect)contentRect;
-(CGRect)imageRectForContentRect:(CGRect)contentRect;

@end
