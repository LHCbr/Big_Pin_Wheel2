//
//  MyFriendsHeaderView.h
//  BigPinwheel
//
//  Created by 徐伟 on 16/2/21.
//  Copyright © 2016年 leita. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FilterDespBtn.h"

@protocol MyFriendsHeaderViewDelegate <NSObject>
-(void)filterButtonClick:(UIButton *)sender;

@end

@interface MyFriendsHeaderView : UIView

@property(strong,nonatomic)UILabel *fileterLabel;        //筛选描述性label
@property(strong,nonatomic)FilterDespBtn *filterDBtn;    //filterDespBtn
@property(assign,nonatomic)id<MyFriendsHeaderViewDelegate>delegate;


@end
