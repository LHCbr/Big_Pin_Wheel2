//
//  MyCustom.h
//  lbx_lib
//
//  Created by a on 5/13/15.
//  Copyright (c) 2015 js. All rights reserved.
//

/* 自定义的类，在简单的cell中使用 忽略没有用的字段*/

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MyCustom : NSObject

@property (nonatomic, copy) NSString    *aTitle;      // 标题
@property (nonatomic, copy) NSString *descTitle;      // 子标题
@property (nonatomic, copy) NSString *imageName;      // 图标名字
@property (nonatomic, assign) int        aValue;      // title对应的值


- (instancetype)initWithTitle:(NSString *)aTitle descTitle:(NSString *)descTitle imageName:(NSString *)imageName aValue:(int)aValue;

@end
