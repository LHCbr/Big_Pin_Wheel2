//
//  NewFriendViewController.m
//  BigPinwheel
//
//  Created by xuwei on 16/3/4.
//  Copyright © 2016年 leita. All rights reserved.
//

#import "NewFriendViewController.h"
#import "addFriendsCell.h"
#import "addTelContBtn.h"
#import <AddressBook/AddressBook.h>
#import "WSocket.h"

@interface NewFriendViewController ()

@property(strong,nonatomic) WSocket *wSocket;

@end

@implementation NewFriendViewController

- (void)dealloc
{
    NSLog(@"新的朋友界面释放");
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
        _wSocket = [WSocket sharedWSocket];
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    NAVBAR(@"新的朋友");
    
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, kDeviceWidth, kDeviceHeight-64) style:UITableViewStylePlain];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.tableHeaderView = [[UIView alloc]init];
    _tableView.tableFooterView = [[UIView alloc]init];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
    
    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc]initWithTitle:@"添加朋友" style:UIBarButtonItemStylePlain target:self action:@selector(rightBarBtnClick:)];
    self.navigationItem.rightBarButtonItem = rightBarItem;
    
    [self customHeaderView];
    
    [self cusutomFooterView];
    
}

#pragma mark - View创建工具
//初始化tableHeaderView
-(void)customHeaderView
{
    UIView *view = [self creatLineWithFrame:CGRectMake(0, 0, kDeviceWidth, 80+21) BGColor:[UIColor clearColor]];
    _tableView.tableHeaderView = view;
    
    addTelContBtn *addBtn = [addTelContBtn buttonWithType:UIButtonTypeCustom];
    addBtn.backgroundColor = [UIColor whiteColor];
    addBtn.frame = CGRectMake(0, 0, kDeviceWidth, 80);
    addBtn.imageSize = CGSizeMake(21, 32);
    [addBtn setImage:[UIImage imageNamed:@"0304_addTel"] forState:UIControlStateNormal];
    [addBtn setTitle:@"添加手机联系人" forState:UIControlStateNormal];
    [addBtn setTitleColor:COLOR(141, 141, 141, 1) forState:UIControlStateNormal];
    [addBtn.titleLabel setFont:[UIFont systemFontOfSize:13]];
    [addBtn.titleLabel setTextAlignment:NSTextAlignmentCenter];
    addBtn.tag = 0;
    [addBtn addTarget:self action:@selector(addFriendsBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:addBtn];
    
    UIView *sepline0 = [self creatLineWithFrame:CGRectMake(0, addBtn.frame.size.height+addBtn.frame.origin.y, kDeviceWidth, 1) BGColor:COLOR(225, 225, 228, 1)];
    [view addSubview:sepline0];
    UIView *sepline1 = [self creatLineWithFrame:CGRectMake(0, view.frame.size.height+view.frame.origin.y -1, kDeviceWidth, 1) BGColor:COLOR(225, 225, 228, 1)];
    [view addSubview:sepline1];
    
}

-(void)cusutomFooterView
{
    UIView *view = [self creatLineWithFrame:CGRectMake(0, 0, kDeviceWidth,500) BGColor:[UIColor whiteColor]];
    _tableView.tableFooterView = view;
}

//创建seplineView
-(UIView *)creatLineWithFrame:(CGRect)frame BGColor:(UIColor *)color
{
    UIView *line = [[UIView alloc]initWithFrame:frame];
    line.backgroundColor = color;
    return line;
}

#pragma mark -点击事件
///Button点击事件 根据send.tag判断
-(void)addFriendsBtnDidClick:(addTelContBtn *)sender
{
    if (sender.tag ==0) {
        
        if ([_wSocket.lbxManager isCanAddressBook]==YES)
        {
            PhoneContactViewController *phoneContactVC = [[PhoneContactViewController alloc]init];
            [self.navigationController pushViewController:phoneContactVC animated:NO];
        }
    }
    else if (sender.tag ==1)
    {
        NSLog(@"cell右侧添加好友按钮点击事件");
    }
    else if (sender.tag ==2)
    {
        NSLog(@"cell头像按钮点击事件");
    }
}

-(void)rightBarBtnClick:(UIButton *)sender
{
    NSLog(@"rightNavBar点击事件");
}


#pragma mark - UITabelViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 120/2;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - UITableViewDataSource

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"identifier0";
    
    addFriendsCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell ==nil) {
        cell = [[addFriendsCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSeparatorStyleNone;
        
    }
    cell.namelabel.text = @"北极大头";
    cell.desplabel.text = @"我是大表姐，南京的，加一下";
    cell.delegate = self;
    
    return cell;
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




@end
