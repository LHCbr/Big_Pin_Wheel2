//
//  AppDelegate.h
//  BigPinwheel
//
//  Created by 徐伟 on 16/1/15.
//  Copyright © 2016年 leita. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomePageViewController.h"
#import "HomeViewController.h"
#import "MineViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic)HomePageViewController *homePageVC;
@property (strong, nonatomic)HomeViewController *messageVC;
@property (strong, nonatomic)MineViewController *mineVC;
@property (strong, nonatomic)UITabBarController *tabarC;


@end

