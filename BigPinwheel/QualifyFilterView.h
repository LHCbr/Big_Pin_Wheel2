//
//  QualifyFilterView.h
//  BigPinwheel
//
//  Created by 徐伟 on 16/2/19.
//  Copyright © 2016年 leita. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FilterBtn.h"

#define kPlace                  @"地区"
#define kGender                 @"想看的用户"
#define kIdenity                @"身份"
#define kOfferPrice             @"价格(元/亩)"

@protocol QualifyFilterViewDelegate <NSObject>

-(void)filterConfrimButtonClick:(UIButton *)sender;
-(void)refreshHeaderLabel;

@end

@interface QualifyFilterView : UIView

@property(strong,nonatomic)NSMutableArray *filterListArray;      //整个筛选属性列表数组
@property(strong,nonatomic)NSMutableArray *filterNameArray;      //属性筛选名称数组

@property(strong,nonatomic)NSMutableArray *propertyBtnArray;     //所有的button数组
@property(strong,nonatomic)NSMutableArray *selectBtnPropArray;   //选中Button的属性数组

@property(strong,nonatomic)UIView *bGView;

@property(strong,nonatomic)UIView *xbView;
@property(strong,nonatomic)UIButton *confrimBtn;
@property(strong,nonatomic)UIButton *cancelBtn;
@property(strong,nonatomic)UIView *verticalLine;
@property(strong,nonatomic)UIView *sepline;


@property(assign,nonatomic)id<QualifyFilterViewDelegate>delegate;




@end
