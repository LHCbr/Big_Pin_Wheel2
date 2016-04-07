//
//  GroupListViewController.m
//  LuLu
//
//  Created by lbx on 16/2/21.
//  Copyright © 2016年 lbx. All rights reserved.
//

#import "GroupListViewController.h"
#import "WSocket.h"
#import "AppDelegate.h"
#import "SendSomeViewController.h"

@interface GroupListViewController ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>
@property (strong, nonatomic)UITableView *tableView;
@property (strong, nonatomic)NSMutableArray *dataArray;

@property (nonatomic, strong)UISearchBar *searchBar;   // 搜索
@property (nonatomic, strong)UIView *searchHiddenView;

@end

@implementation GroupListViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)getMyGroupListReceive:(NSNotification *)noti
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"获取群列表成功");
        NSDictionary *dict = [noti object];
        NSLog(@"dict = %@",dict);
        _dataArray = [dict objectForKey:@"group_list"];
       
        [_tableView reloadData];
    });
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _dataArray = [[NSMutableArray alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getMyGroupListReceive:) name:@"getMyGroupListReceive" object:nil];
        [[WSocket sharedWSocket] getMyGroupList];
    }
    return self;
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

- (void)newGroupCli:(UIBarButtonItem *)btn
{
    SendSomeViewController *sendVC = [[SendSomeViewController alloc] init];
    sendVC.fromType = FromCreateGroup;
    sendVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:sendVC animated:YES];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    NAVBAR(@"群聊");
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"建群" style:UIBarButtonItemStylePlain target:self action:@selector(newGroupCli:)];
    
    self.navigationItem.rightBarButtonItem = rightButtonItem;

    
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 64)];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    _tableView.tableFooterView = [[UIView alloc] init];

    [self addHeader];
}

- (void)addHeader
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kDeviceWidth, 38)];
    view.backgroundColor = [UIColor whiteColor];
    
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(5, 4, self.view.frame.size.width - 10, 30)];
    _searchBar.keyboardType = UIKeyboardTypeDefault;
    _searchBar.delegate = self;
    _searchBar.placeholder = @"搜索";
    
    _searchBar.layer.cornerRadius = 5.0f;
    _searchBar.layer.masksToBounds = YES;
    [view addSubview:_searchBar];
    
    UIImage* clearImg = [self imageWithColor:[UIColor clearColor] andHeight:30.0f];
    [_searchBar setBackgroundImage:clearImg];
    UIImage *grayImg = [self imageWithColor:COLOR(232, 232, 232, 1) andHeight:30.0f];
    [_searchBar setSearchFieldBackgroundImage:grayImg forState:UIControlStateNormal];
    [_searchBar setBackgroundColor:[UIColor clearColor]];
    
    for (UIView *subview in _searchBar.subviews) {
        for(UIView* grandSonView in subview.subviews){
            if([grandSonView isKindOfClass:NSClassFromString(@"UISearchBarTextField")] ){
                [grandSonView.layer setCornerRadius:5.0f];
                [grandSonView.layer setMasksToBounds:YES];
                
                //                [((UITextField *)grandSonView) setValue:[UIColor redColor] forKeyPath:@"_placeholderLabel.textColor"];
                break;
            }
        }
    }
    
    _searchHiddenView = [[UIView alloc] initWithFrame:CGRectMake(0, 64.0+38.0, self.view.frame.size.width, 1000)];
    _searchHiddenView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_searchHiddenView];
    _searchHiddenView.alpha = 0;
    
    UITapGestureRecognizer *hi = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideSearch:)];
    [_searchHiddenView addGestureRecognizer:hi];
    
    
    _tableView.tableHeaderView = view;

}

- (void)hideSearch:(UITapGestureRecognizer *)tap
{
    _searchHiddenView.alpha = 0;
    if ([_searchBar isFirstResponder]) {
        [_searchBar resignFirstResponder];
    }
}

- (UIImage*) imageWithColor:(UIColor*)color andHeight:(CGFloat)height
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

#pragma mark - Table view datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"meassage_list_cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
      
    }
    cell.imageView.image = [UIImage imageNamed:@"0107_shezhi_select"];
    NSDictionary *subDict = _dataArray[indexPath.row];
    NSString *name = [[[WSocket sharedWSocket] lbxManager] stringFromHexString:[subDict objectForKey:@"group_name"]];
    cell.textLabel.text = name;
    
    return cell;
    
}

#pragma mark - Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_searchBar resignFirstResponder];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *subDict = _dataArray[indexPath.row];
    NSString *groupId = [subDict objectForKey:@"group_id"];

    groupId = [NSString stringWithFormat:@"%@Q",groupId];
    
    WJID *uJid = [[WJID alloc] init];
    uJid = [[[WSocket sharedWSocket] lbxManager] getUserInfoWithPhone:groupId];
    [self.navigationController popToRootViewControllerAnimated:NO];
    
//    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
//    app.tabBarC.selectedIndex = 1;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"goChat" object:uJid];
}

#pragma mark - UISearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    _searchHiddenView.alpha = 0;
    NSLog(@"点击了搜索");
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    _searchHiddenView.alpha = 0;
    [_searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    _searchHiddenView.alpha = 1;
    [_searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [_searchBar setShowsCancelButton:NO animated:YES];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchBar.text.length) {
        NSLog(@"执行搜索");
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
