//
//  SectionItem.h
//  BigPinwheel
//
//  Created by 徐伟 on 16/1/15.
//  Copyright © 2016年 leita. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SectionItem : NSObject

@property(copy,nonatomic)NSString *title;
@property(copy,nonatomic)NSString *subTitle;
@property(strong,nonatomic)NSMutableArray *imageArray;

-(instancetype)initWithTitle:(NSString *)title subTitle:(NSString *)subtitle imageArray:(NSMutableArray *)imageArray;

@end
