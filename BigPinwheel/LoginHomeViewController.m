//
//  LoginHomeViewController.m
//  BigPinwheel
//
//  Created by 徐伟 on 16/2/25.
//  Copyright © 2016年 leita. All rights reserved.
//

#import "LoginHomeViewController.h"
#import "LoginViewController.h"
#import "RegisterViewController.h"

@interface LoginHomeViewController ()

@end

@implementation LoginHomeViewController

- (void)dealloc
{
    NSLog(@"登陆界面释放");
    
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self setNeedsStatusBarAppearanceUpdate];
    self.navigationController.interactivePopGestureRecognizer.enabled =NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled =YES;
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.barTintColor = kThemeColor;
    self.view.frame = CGRectMake(0, 0, kDeviceWidth, kDeviceHeight);
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:nil];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    imageView.backgroundColor = kThemeColor;
    imageView.userInteractionEnabled = YES;
    [imageView setImage:[UIImage imageNamed:@"0225_loginhome"]];
    [imageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.view addSubview:imageView];
    
    CGFloat btnWidth = (kDeviceWidth -42-15)/2;
    
    UIButton *registerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    registerBtn.backgroundColor = [UIColor whiteColor];
    registerBtn.frame = CGRectMake(21, imageView.frame.size.height -30-50, btnWidth, 50);
    [registerBtn.layer setMasksToBounds:YES];
    [registerBtn.layer setCornerRadius:4];
    [registerBtn setTitleColor:COLOR(24, 96, 0, 1) forState:UIControlStateNormal];
    [registerBtn.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [registerBtn.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [registerBtn setTitle:@"注册" forState:UIControlStateNormal];
    registerBtn.tag = 0;
    [registerBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [imageView addSubview:registerBtn];
    
    UIButton *loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    loginBtn.backgroundColor = COLOR(54, 146, 0, 1) ;
    loginBtn.frame = CGRectMake(kDeviceWidth/2+7.5, registerBtn.frame.origin.y, btnWidth, 50);
    [loginBtn.layer setMasksToBounds:YES];
    [loginBtn.layer setCornerRadius:4];
    [loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [loginBtn.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [loginBtn.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [loginBtn setTitle:@"登录" forState:UIControlStateNormal];
    loginBtn.tag =1;
    [loginBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [imageView addSubview:loginBtn];
    
}

- (void)buttonClick:(UIButton *)sender
{
    if (sender.tag == 1)
    {
        LoginViewController *loginVC = [[LoginViewController alloc] init];
        [self.navigationController pushViewController:loginVC animated:YES];
    } else if (sender.tag == 0)
    {
        RegisterViewController *registerVC = [[RegisterViewController alloc] init];
        [self.navigationController pushViewController:registerVC animated:YES];
    }
}

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
