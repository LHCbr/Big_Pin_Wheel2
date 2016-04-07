//
//  FilterBtn.h
//  BigPinwheel
//
//  Created by 徐伟 on 16/2/20.
//  Copyright © 2016年 leita. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FilterBtn : UIButton

@property(copy,nonatomic)NSString *value_name;     //button的属性字典
@property(copy,nonatomic)NSString *proper_name;    //button所在筛选属性数组的名字
@property(assign,nonatomic)NSInteger customTag;    //button所在属性数组的tag

@property(copy,nonatomic)UIButton *selectBtn;      //所选中的Button

-(instancetype)initWithFrame:(CGRect)frame BtnName:(NSString *)btnName Property:(NSString *)property;

-(void)setSelfisHidden:(BOOL)isSelected;

@end
