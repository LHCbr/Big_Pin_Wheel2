//
//  TableBarBtn.h
//  BigPinwheel
//
//  Created by 徐伟 on 16/2/19.
//  Copyright © 2016年 leita. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TableBarBtn : UIButton
@property(assign,nonatomic)CGSize imageSize;
@property(assign,nonatomic)CGSize titleSize;


-(CGRect)titleRectForContentRect:(CGRect)contentRect;
-(CGRect)imageRectForContentRect:(CGRect)contentRect;

@end
