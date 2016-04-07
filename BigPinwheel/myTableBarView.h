//
//  myTableBarView.h
//  BigPinwheel
//
//  Created by 徐伟 on 16/2/19.
//  Copyright © 2016年 leita. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TableBarBtn.h"
#import "pop/POP.h"

@protocol myTableBarViewDelegate <NSObject>

-(void)barBtnClick:(UIButton *)sender;

@end

@interface myTableBarView : UIView

@property(strong,nonatomic)TableBarBtn *findDriverBtn;
@property(strong,nonatomic)TableBarBtn *findFarmerBtn;
@property(strong,nonatomic)TableBarBtn *emblemBtn;

@property(strong,nonatomic)POPBasicAnimation *shrinkAnimation;
@property(strong,nonatomic)POPSpringAnimation *springBackHoriAnimation;
@property(strong,nonatomic)POPSpringAnimation *springBackVertiAnimation;

@property(strong,nonatomic)POPBasicAnimation *fadeOutAnim;
@property(strong,nonatomic)POPSpringAnimation *fadeInAnim;

@property(assign,nonatomic)NSInteger clickCount;

@property(assign,nonatomic)CGPoint vertiPoint;  //初始farmCGPoint
@property(assign,nonatomic)CGPoint horiPoint;   //初始driverCGPoint
@property(assign,nonatomic)CGPoint unifyPoint;  //2个button归一后的CGPoint

@property(strong,nonatomic)NSMutableArray *tableBtns;



@property(assign,nonatomic)id<myTableBarViewDelegate>delegate;

-(void)shrinkInAnim;             //button收缩动画
-(void)springBackAnim;           //button返回动画



@end
