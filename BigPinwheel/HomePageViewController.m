//
//  HomePageViewController.m
//  BigPinwheel
//
//  Created by xuwei on 16/4/7.
//  Copyright © 2016年 leita. All rights reserved.
//

#import "WSocket.h"
#import "HomePageViewController.h"
#import "LoginHomeViewController.h"
#import "HomeFarmerListCell.h"
#import "HomeDriverListCell.h"
#import "FindDriversVC.h"

@interface HomePageViewController ()

@property(strong,nonatomic)WSocket *wSocket;
@property(assign,nonatomic)NSInteger sgSelectedIndex;

@end

@implementation HomePageViewController

- (void)dealloc
{
    NSLog(@"首页界面释放");
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self checkIsfirstLogin];
    
    /*每次进界面获取实时司机农民列表   这里用回调刷新界面*/
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

#pragma mark -本类接受的通知
/*登录成功后,刷新一些View*/
-(void)refreshSomeView:(NSNotification *)noti
{
    
}

/*获取实时司机农民列表 这里用通知刷新界面*/
-(void)getRealTimeList:(NSNotification *)noti
{
    
}



/*在这里添加通知*/
-(instancetype)init
{
    self = [super init];
    if (self)
    {
        _sgSelectedIndex = 1;
        _wSocket = [WSocket sharedWSocket];
        _dataArray = [[NSMutableArray alloc]init];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshSomeView:) name:kLoginSuccess object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"大风车";
    self.view.backgroundColor = kBGColor;
    
    [self customNavBar];
    
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kDeviceWidth, kDeviceHeight) style:UITableViewStylePlain];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.tableHeaderView = [[UIView alloc]init];
    _tableView.tableFooterView = [[UIView alloc]init];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
    
    [self customTableHeaderView];
    
}

#pragma mark - View创建工具
/*初始化NavBar*/
-(void)customNavBar
{
    UIView *weatherView = [self creatWeatherView];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithCustomView:weatherView];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithTitle:@"发布" style:UIBarButtonItemStylePlain target:self action:@selector(releaseInfoBtnClick)];
    self.navigationItem.rightBarButtonItem = rightItem;
}

/*初始化tableHeaderView*/
-(void)customTableHeaderView
{
    HPHeaderView *headerView = [[HPHeaderView alloc]initWithFrame:CGRectMake(0, 0, kDeviceWidth, 112/2)];
    [headerView.mapBtn addTarget:self action:@selector(mapBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    headerView.delegate = self;
    _tableView.tableHeaderView = headerView;
}

/*创建天气WeatherView*/
-(UIView *)creatWeatherView
{
    UIView *weatherView = [[UIView alloc]init];
    return weatherView;
}

-(MBProgressHUD *)creatViewMBPHud
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.yOffset = -32.0f;
    hud.dimBackground = NO;
    hud.color = [UIColor clearColor];
    hud.activityIndicatorColor = [[UIColor grayColor]colorWithAlphaComponent:0.8];
    hud.transform = CGAffineTransformMakeScale(0.65, 0.65);
    hud.removeFromSuperViewOnHide = YES;
    return hud;
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
    if (_sgSelectedIndex ==1)
    {
        static NSString *identifier0 = @"farmerCell";
        HomeFarmerListCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier0];
        if (cell == nil) {
            cell = [[HomeFarmerListCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier0];
        }
        return cell;
    }else
    {
        static NSString *identifier1 = @"driverCell";
        HomeDriverListCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier1];
        if (cell == nil) {
            cell = [[HomeDriverListCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier1];
        }
        return cell;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArray.count;
}

#pragma mark -本类执行的方法
/*检查是否是第一次登录*/
-(void)checkIsfirstLogin
{
    if (_wSocket.lbxManager.wJid.phone.length<=0||_wSocket.lbxManager.wJid.password.length<=0)
    {
        LoginHomeViewController *loginHomeVC = [[LoginHomeViewController alloc]init];
        loginHomeVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:loginHomeVC animated:NO];
    }else
    {
        WSocket *wSocket =[WSocket sharedWSocket];
        if (![wSocket isLoginOK]) {
            [wSocket logining:_wSocket.lbxManager.wJid.phone password:_wSocket.lbxManager.wJid.password isAuto:YES loginBlock:^(int success) {
            }];
        }
    }
}

/*发布自己的需求*/
-(void)releaseInfoBtnClick
{
    
}

/*进入地图*/
-(void)mapBtnClick:(UIButton *)sender
{
    FindDriversVC *findDrVC = [[FindDriversVC alloc]init];
    findDrVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:findDrVC animated:YES];
    self.hidesBottomBarWhenPushed = NO;
}

/*切换SegmentControlSelectIndex*/
-(void)segementDidSelectIndex:(UISegmentedControl *)sender
{
    _sgSelectedIndex = sender.selectedSegmentIndex;
    if (sender.selectedSegmentIndex == 0)
    {
       // _dataArray = @"";
    }else
    {
        //_dataArray = @"";
    }
    [_tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
