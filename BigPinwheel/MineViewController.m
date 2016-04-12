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
#import "SettingsViewController.h"
#import "MineHeaderView.h"

@interface MineViewController ()

@property(strong,nonatomic)WSocket *wSocket;

@end

@implementation MineViewController

-(void)dealloc
{
    NSLog(@"界面释放");
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO];
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
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kDeviceWidth, kDeviceHeight) style:UITableViewStyleGrouped];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.estimatedRowHeight = 44.0f;
    _tableView.tableHeaderView = [[UIView alloc]init];
    _tableView.tableFooterView = [[UIView alloc]init];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
    
    [self customTableHeaderView];
    
}

#pragma mark -View创建工具
/*初始化tableHeaderView*/
-(void)customTableHeaderView
{
    MineHeaderView *headerView = [[MineHeaderView alloc]initWithFrame:CGRectMake(0, 0, kDeviceWidth, 200)];
    [headerView.settingBtn addTarget:self action:@selector(headerViewBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    _tableView.tableHeaderView = headerView;
    
}

#pragma mark -点击方法执行函数
/*HeaderViewBtn点击事件*/
-(void)headerViewBtnClick:(UIButton *)sender
{
    SettingsViewController *settingVC = [[SettingsViewController alloc]init];
    [self.navigationController pushViewController:settingVC animated:YES];
}

#pragma mark - UITabelViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _dataArray.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *idenitifer = @"normalSectionCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:idenitifer];
    if (cell==nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:idenitifer];
    }
    return cell;
}



#pragma mark - UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    static NSString *identifier = @"headerIdentifier";
    UITableViewHeaderFooterView *headerView = [[UITableViewHeaderFooterView alloc]initWithReuseIdentifier:identifier];
    if (headerView == nil) {
        headerView = [[UITableViewHeaderFooterView alloc]initWithReuseIdentifier:identifier];
        headerView.backgroundColor = kBGColor;
        headerView.frame = CGRectMake(0, 0, kDeviceWidth, 30);
    }
    return headerView;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
