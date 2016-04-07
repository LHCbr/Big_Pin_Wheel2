//
//  FrindsApplyViewController.m
//  BigPinwheel
//
//  Created by xuwei on 16/3/4.
//  Copyright © 2016年 leita. All rights reserved.
//

#import "FrindsApplyViewController.h"
#import "MyCustom.h"

@interface FrindsApplyViewController ()

@property(strong,nonatomic)UILabel *footlabel;

@end

@implementation FrindsApplyViewController

- (void)dealloc
{
    NSLog(@"界面释放");
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
        MyCustom *custom0 = [[MyCustom alloc]initWithTitle:@"大表姐" descTitle:@"女 28岁 中国 江苏 南京" imageName:nil aValue:0];
        MyCustom *custom1 = [[MyCustom alloc]initWithTitle:@"附加信息" descTitle:@"我是大表姐" imageName:nil aValue:0];
        MyCustom *custom2 = [[MyCustom alloc]initWithTitle:@"来源" descTitle:@"精确查找" imageName:nil aValue:0];
        _dataArray = [NSMutableArray arrayWithObjects:custom0,custom1,custom2, nil];
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    NAVBAR(@"好友申请");
    
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, kDeviceWidth, kDeviceHeight-64) style:UITableViewStylePlain];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.tableHeaderView = [[UIView alloc]init];
    _tableView.tableFooterView = [[UIView alloc]init];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
    
    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc]initWithTitle:@"好友申请" style:UIBarButtonItemStylePlain target:self action:@selector(addFriendsBtn)];
    self.navigationItem.rightBarButtonItem = rightBarItem;
    
    [self cusutomFooterView];
    
}

#pragma mark - View创建工具

-(void)cusutomFooterView
{
    _footlabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 10, kDeviceWidth, 50)];
    _footlabel.backgroundColor = [UIColor clearColor];
    _footlabel.font = [UIFont systemFontOfSize:12];
    _footlabel.textColor = COLOR(119, 119, 119, 1);
    _footlabel.textAlignment = NSTextAlignmentCenter;
    _footlabel.text = @"已同意该申请";
    _tableView.tableFooterView = _footlabel;
}

#pragma mark -点击事件
-(void)addFriendsBtn
{
    NSLog(@"好友申请按钮点击");
}

-(void)backMSG:(UIButton *)sender
{
    NSLog(@"回复Button按钮点击");
}



#pragma mark - UITabelViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row ==0)
    {
        return 139/2;
    }else
    {
        return 101/2;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - UITableViewDataSource

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier0 = @"identifier0";
    static NSString *identifier1 = @"identifier1";
    MyCustom *custom = [_dataArray objectAtIndex:indexPath.row];
    
    if (indexPath.row ==0)
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier0];
        if (cell ==nil)
        {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier0];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        [cell.imageView setImage:[UIImage imageNamed:@"0304_add"]];
        cell.textLabel.text = @"大表姐";
        cell.detailTextLabel.font = [UIFont systemFontOfSize:11];
        cell.detailTextLabel.textColor = COLOR(133, 133, 133, 1);
        cell.detailTextLabel.text = @"女 28岁 中国 江苏 南京";
        
        return cell;
    }
    
    else if ([custom.aTitle isEqualToString:@"附加信息"])
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier1];
        if (cell ==nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier1];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            backBtn.backgroundColor = COLOR(0, 146, 79, 1);
            backBtn.frame = CGRectMake(0, 0, 50, 29);
            [backBtn.layer setMasksToBounds:YES];
            [backBtn.layer setCornerRadius:4];
            [backBtn setTitle:@"回复" forState:UIControlStateNormal];
            [backBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [backBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
            [backBtn addTarget:self action:@selector(backMSG:) forControlEvents:UIControlEventTouchUpInside];
            cell.accessoryView = backBtn;
        }
        NSMutableAttributedString *addStr =[[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"附加信息   %@",@"我是大表姐"]];
        [addStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(0, addStr.length)];
        [addStr addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, addStr.length -4)];
        [addStr addAttribute:NSForegroundColorAttributeName value:COLOR(133, 133, 133, 1) range:NSMakeRange(0, 4)];
        
        cell.textLabel.attributedText = addStr;
        return cell;
    }
    else
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier1];
        if (cell ==nil)
        {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier1];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        NSMutableAttributedString *addStr =[[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"来源          %@",@"精确查找"]];
        [addStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(0, addStr.length)];
        [addStr addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, addStr.length -2)];
        [addStr addAttribute:NSForegroundColorAttributeName value:COLOR(133, 133, 133, 1) range:NSMakeRange(0, 2)];
        
        cell.textLabel.attributedText = addStr;
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
