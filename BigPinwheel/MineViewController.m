//
//  MineViewController.m
//  BigPinwheel
//
//  Created by xuwei on 16/4/7.
//  Copyright © 2016年 leita. All rights reserved.
//

#import "WSocket.h"
#import "MineViewController.h"
#import <MBProgressHUD.h>

@interface MineViewController ()

@property(strong,nonatomic)WSocket *wSocket;


@end

@implementation MineViewController

-(instancetype)init
{
    if (self)
    {
        _wSocket = [WSocket sharedWSocket];
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)viewDidDisappear:(BOOL)animated
{
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.frame = CGRectMake(0, 0, kDeviceWidth, kDeviceHeight);
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
