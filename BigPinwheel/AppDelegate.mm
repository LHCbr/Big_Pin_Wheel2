//
//  AppDelegate.m
//  BigPinwheel
//
//  Created by 徐伟 on 16/1/15.
//  Copyright © 2016年 leita. All rights reserved.
//

#import "AppDelegate.h"
#import "WSocket.h"

@interface AppDelegate ()
{
    UIBackgroundTaskIdentifier BGTask;
}

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    UIUserNotificationType localType = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeBadge;
    UIUserNotificationSettings *localSettings = [UIUserNotificationSettings settingsForTypes:localType categories:nil];
    [[UIApplication sharedApplication]registerUserNotificationSettings:localSettings];
    
    // 设置默认聊天背景图
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *imageName = [userDefaults objectForKey:kSelectedBgName];
    if (imageName.length <= 0) {
        [userDefaults setObject:@"0107_bg_1" forKey:kSelectedBgName];
        [userDefaults synchronize];
    }
    
    
    [WSocket sharedWSocket];

    
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = kBGColor;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    
    _rootVC = [[RootViewController alloc]init];
    UINavigationController *rootNav = [[UINavigationController alloc]initWithRootViewController:_rootVC];
    rootNav.navigationBar.tintColor = [UIColor blackColor];
    rootNav.navigationBar.barTintColor = kThemeColor;
    self.window.rootViewController = rootNav;
    [self.window makeKeyAndVisible];
    
    return YES;
}

//本地设置通知
-(void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
}

- (void)applicationWillResignActive:(UIApplication *)application {
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
    WSocket *wSocket = [WSocket sharedWSocket];
    wSocket.lbxManager.isBackGroundOperation = YES;
    
    UIApplication *appLication=[UIApplication sharedApplication];
    if (BGTask !=UIBackgroundTaskInvalid)
    {
        [appLication endBackgroundTask:BGTask];
        BGTask =UIBackgroundTaskInvalid;
    }
    BGTask=[appLication  beginBackgroundTaskWithExpirationHandler:^(void){
        NSLog(@"申请的时间结束了");
        if (wSocket.longTimer) {
            [wSocket.longTimer setFireDate:[NSDate distantFuture]];
        }
        [appLication endBackgroundTask:BGTask];
        BGTask=UIBackgroundTaskInvalid;
    }];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    WSocket *wSocket = [WSocket sharedWSocket];
    if (wSocket.longTimer) {
        [wSocket.longTimer setFireDate:[NSDate distantPast]];
    }
    wSocket.lbxManager.isBackGroundOperation = NO;
    [wSocket tellCIsBackground:0];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


- (void)application:(UIApplication *)application performActionForShortcutItem:(nonnull UIApplicationShortcutItem *)shortcutItem completionHandler:(nonnull void (^)(BOOL))completionHandler {
    
    NSString *text = [NSString stringWithFormat:@"点击了 %@按钮",shortcutItem.localizedTitle];
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:text delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [av show];
}


@end
