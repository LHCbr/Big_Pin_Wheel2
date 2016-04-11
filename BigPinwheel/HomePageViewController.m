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
#import "HomePageHeaderView.h"
#import "HomeFarmerListCell.h"
#import "HomeDriverListCell.h"

@interface HomePageViewController ()

@property(strong,nonatomic)WSocket *wSocket;

@end

@implementation HomePageViewController

- (void)dealloc
{
    NSLog(@"首页界面释放");
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
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
        _wSocket = [WSocket sharedWSocket];
        _dataArray = [[NSMutableArray alloc]init];
        
        NSMutableArray *temp1 = [NSMutableArray arrayWithArray:@[@"1",@"2"]];
        NSMutableArray *temp2 = [NSMutableArray arrayWithArray:@[@"3",@"4"]];
        
        [temp2 addObjectsFromArray:temp1];
        
        NSLog(@"temp =%@",temp2);
        
        
        
        
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshSomeView:) name:kLoginSuccess object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
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
/*初始化tableHeaderView*/
-(void)customTableHeaderView
{
    
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
    static NSString *identifier = @"normalcell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell ==nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    return cell;
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
/*headerView2个按钮点击事件 自己的身份*/
-(void)headViewBtnClick:(UIButton *)button WithSelfIdentity:(int)myIdentity
{
    if (myIdentity ==0)
    {
        
    }else
    {
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
