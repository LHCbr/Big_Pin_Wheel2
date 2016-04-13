//
//  SettingsViewController.m
//  BigPinwheel
//
//  Created by xuwei on 16/3/26.
//  Copyright © 2016年 leita. All rights reserved.
//

#import "SettingsViewController.h"
#import "WSocket.h"
#import "RootViewController.h"

@interface SettingsViewController ()

@property(strong,nonatomic)WSocket *wSocket;
@property(strong,nonatomic)NSTimer *logOutTimer;
@property(assign,nonatomic)int logOutIndex;

@end

@implementation SettingsViewController
- (void)dealloc
{
    NSLog(@"设置界面释放");
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (_logOutTimer)
    {
        [_logOutTimer invalidate];
        _logOutTimer = nil;
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

-(instancetype)init
{
    self = [super init];
    if (self)
    {
        _logOutIndex = 0;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    NAVBAR(@"设置");
    self.view.backgroundColor = [UIColor whiteColor];
    
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kDeviceWidth, kDeviceHeight) style:UITableViewStylePlain];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.tableHeaderView = [[UIView alloc]init];
    _tableView.tableFooterView = [[UIView alloc]init];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
    
    [self customFooterView];
    
}

#pragma mark - View创建工具
-(void)customFooterView
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0,64, kDeviceWidth, kDeviceHeight/2)];
    view.backgroundColor = [UIColor whiteColor];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame =CGRectMake(25,kDeviceHeight/4, kDeviceWidth-50, 38);
    button.backgroundColor = kThemeColor;
    [button.layer setMasksToBounds:YES];
    [button.layer setCornerRadius:3.0];
    [button setTintColor:[UIColor whiteColor]];
    [button.titleLabel setFont:[UIFont systemFontOfSize:18]];
    [button setTitle:@"退 出" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(logOutAciton) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:button];
    _tableView.tableFooterView = view;
}

#pragma mark -点击事件
-(void)logOutAciton
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"确认退出?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定退出", nil];
    alert.tag = 3;
    alert.delegate = self;
    [alert show];
}

#pragma mark -UIAlertDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex ==alertView.cancelButtonIndex)
    {
        return;
    }
    if (alertView.tag ==3)
    {
        __weak SettingsViewController *weakSelf = self;
        [[WSocket sharedWSocket]logOutIsSuccess:^(int success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (success==0)
                {
                    [weakSelf logOutSuccess];
                }
            });
        }];
        
        if (_logOutTimer)
        {
            [_logOutTimer setFireDate:[NSDate distantPast]];
        }else
        {
            _logOutTimer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(logOutTime) userInfo:nil repeats:YES];
        }
    }
}

-(void)logOutTime
{
    if (_logOutIndex>60)
    {
        _logOutIndex = 0;
        [self logOutSuccess];
        
        [_logOutTimer setFireDate:[NSDate distantFuture]];
        [_logOutTimer invalidate];
        _logOutTimer = nil;
    }
    _logOutIndex += 3;
}

-(void)logOutSuccess
{
    [_wSocket.lbxManager showHubAction:1 showView:self.view];
    
    NSString *key = [NSString stringWithFormat:@"%@%@",kFriendLastUpdateTime,_wSocket.lbxManager.wJid.phone];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:key];
    
    _wSocket.lbxManager.wJid = [[WJID alloc]init];
    _wSocket.lbxManager.dfcInfo = [[DFCUserInfo alloc]init];
    
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:kUserName];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:kPassword];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:kNickName];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:kLogOutNotification object:nil];

    [self.tableView setContentOffset:CGPointZero animated:YES];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - UITabelViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

#pragma mark - UITableViewDataSource

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"normalcell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell ==nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
            [cell setSeparatorInset:UIEdgeInsetsZero];
        }
        if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
            [cell setLayoutMargins:UIEdgeInsetsZero];
        }
    }
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArray.count;
}


/// cell分割线贯穿左右
-(void)viewDidLayoutSubviews
{
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        
        [self.tableView setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
    }
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        
        [self.tableView setLayoutMargins:UIEdgeInsetsMake(0,0,0,0)];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
