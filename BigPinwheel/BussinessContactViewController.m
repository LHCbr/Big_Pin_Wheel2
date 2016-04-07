//
//  BussinessContactViewController.m
//  BigPinwheel
//
//  Created by 徐伟 on 16/2/14.
//  Copyright © 2016年 leita. All rights reserved.
//

#import "BussinessContactViewController.h"
#import "MyCustom.h"
#import "SubNoticeCell.h"
#import "NewFriendViewController.h"

@interface BussinessContactViewController ()

@end

@implementation BussinessContactViewController

- (void)dealloc
{
    NSLog(@"业务电话界面释放");
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
        MyCustom *custom0 = [[MyCustom alloc]initWithTitle:@"大丰车团队" descTitle:@"欢迎来到大丰车，问题请找我!" imageName:@"0223_team" aValue:0];
        MyCustom *custom1 = [[MyCustom alloc]initWithTitle:@"大丰车招商咨询" descTitle:@"农业投资？众筹？找我" imageName:@"0223_consult" aValue:0];
        MyCustom *custom2 = [[MyCustom alloc]initWithTitle:@"收割捷径通道" descTitle:@"快速定位到你的区域,快速与我们的收割团队联系" imageName:@"0223_harvest" aValue:0];
        MyCustom *custom3 = [[MyCustom alloc]initWithTitle:@"任务中心" descTitle:@"向邻里乡亲推荐你的收割师傅,优惠5元/亩" imageName:@"0223_taskcenter" aValue:0];
        _dataArray = [NSMutableArray arrayWithObjects:custom0,custom1,custom2,custom3, nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"业务电话";
    
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kDeviceWidth, kDeviceHeight) style:UITableViewStylePlain];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.tableHeaderView = [[UIView alloc]init];
    _tableView.tableFooterView = [[UIView alloc]init];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
    
}

#pragma mark - View创建工具

#pragma mark - UITabelViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65.0f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NewFriendViewController *frindVC = [[NewFriendViewController alloc]init];
    [self.navigationController pushViewController:frindVC animated:YES];
}

#pragma mark - UITableViewDataSource

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"normalcell";
    static NSString *taskIdentifier = @"taskIdentifier";
    MyCustom *custom = _dataArray[indexPath.row];
    
    if ([custom.aTitle isEqualToString:@"任务中心"]) {
        SubNoticeCell *cell = [tableView dequeueReusableCellWithIdentifier:taskIdentifier];
        if (cell ==nil) {
            cell = [[SubNoticeCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:taskIdentifier isTaskCenter:YES];
        }
        [cell.avatarView setImage:[UIImage imageNamed:custom.imageName]];
        cell.nameLabel.text = custom.aTitle;
        cell.lastMSGLabel .text = custom.descTitle;
       
        return cell;
    }
    else
    {
        SubNoticeCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell ==nil) {
            cell = [[SubNoticeCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier isTaskCenter:NO];
        }
        [cell.avatarView setImage:[UIImage imageNamed:custom.imageName]];
        cell.nameLabel.text = custom.aTitle;
        cell.lastMSGLabel.text = custom.descTitle;
        
        return cell;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArray.count;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
