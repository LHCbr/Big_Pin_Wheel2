//
//  RootViewController.h
//  BigPinwheel
//
//  Created by 徐伟 on 16/1/19.
//  Copyright © 2016年 leita. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeViewController.h"
#import "MyProfilesViewController.h"
#import "myTableBarView.h"
#import "LoginHomeViewController.h"
#import "FindDriversVC.h"

@interface RootViewController : UIViewController<UIScrollViewDelegate,UIGestureRecognizerDelegate,myTableBarViewDelegate,MyProfilesViewControllerDelegate,UINavigationControllerDelegate,UIViewControllerAnimatedTransitioning>

@property(strong,nonatomic)UIScrollView *rootScrollView;               //rootScrollView   设RootView为ScrollView以防以后框架改变
@property(strong,nonatomic)UIButton *leftBarBtn;                       //navBar左按钮
@property(strong,nonatomic)UIButton *rightBarBtnOne;                   //navBar右按钮One
@property(strong,nonatomic)UIButton *rightBarBtnTwo;                   //navBar右按钮Two

@property(strong,nonatomic)HomeViewController *homeVC;                 //主界面
@property(strong,nonatomic)MyProfilesViewController *profileVC;        //个人资料界面

@property(strong,nonatomic)myTableBarView *myTableBarView;             //自定义TableBarView


@end
