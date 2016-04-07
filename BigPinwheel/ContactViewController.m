//
//  ContactViewController.m
//  BigPinwheel
//
//  Created by 徐伟 on 16/2/19.
//  Copyright © 2016年 leita. All rights reserved.
//

#import "ContactViewController.h"
#import "InscriptionManager.h"
#import "MyCustom.h"
#import "ChatViewController.h"
#import "NewFriendViewController.h"
#import "SectionItem.h"
#import "SectionModel.h"
#import "GroupListViewController.h"

#define kPhoneRegex @"^[1][3,4,5,7,8,9][\\d]{9}$"


@interface ContactViewController ()<UISearchBarDelegate>

@property(strong,nonatomic)InscriptionManager *inspManager;

@property (nonatomic, strong)UISearchBar *searchBar;       // 搜索
@property(strong,nonatomic)UIView *searchBGView;           //搜索背景View

@property(nonatomic,strong)WSocket *wSocket;               //工具句柄

@property(strong,nonatomic)SectionModel *section0;        //第一个section

@end

@implementation ContactViewController

- (void)dealloc
{
    NSLog(@"通讯录界面释放");
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

#pragma mark - 本类通知
/// 刷新好友列表
- (void)updateFriendList:(NSNotification *)noti
{
    dispatch_async(_wSocket.lbxManager.getFriendQueue, ^{
        _friendsList = [[NSMutableDictionary alloc]init];
        _friendsList = [_wSocket.lbxManager getAddressBook];
        _groups = [NSMutableArray arrayWithArray:[_wSocket.lbxManager sortAddressBook:_friendsList]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [_tableView reloadData];
            NSLog(@"刷新朋友列表完成");
        });
    });
    
}

/// 登陆成功，清楚聊天列表，获取最新的
- (void)loginSuccess:(NSNotification *)noti
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateFriendList:nil];
    });
}

/// 退出登录成功
- (void)logOutNotification:(NSNotification *)noti
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [_friendsList removeAllObjects];
        [_dataArray removeAllObjects];
        [_tableView reloadData];
    });
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
        _inspManager = [InscriptionManager sharedManager];
        _wSocket = [WSocket sharedWSocket];
        _dataArray = [[NSMutableArray alloc]init];
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(loginSuccess:) name:kLoginSuccess object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateFriendList:) name:kUpdateFriendList object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(logOutNotification:) name:kLogOutNotification object:nil];
        
        _section0 = [[SectionModel alloc]init];
        SectionItem *item0 = [[SectionItem alloc]initWithTitle:@"新的朋友" subTitle:@"0304_newFriends" imageArray:nil];
        SectionItem *item1 = [[SectionItem alloc]initWithTitle:@"群聊" subTitle:@"0304_groupchat" imageArray:nil];
        _section0.itemArray = [NSMutableArray arrayWithObjects:item0,item1, nil];
        
        [_dataArray addObject:_section0];
        
        _friendsList = [_wSocket.lbxManager getAddressBook];
        if (_friendsList)
        {
            _groups = [_wSocket.lbxManager sortAddressBook:_friendsList];
            [_dataArray addObjectsFromArray:_groups];
        }
}
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
       UIBarButtonItem *rightBtnItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"0304_add"] style:UIBarButtonItemStylePlain target:self action:@selector(addNewFriendBtnClick:)];
    self.navigationItem.rightBarButtonItem = rightBtnItem;
    
    NAVBAR(@"通讯录");
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, kDeviceWidth, kDeviceHeight-64) style:UITableViewStyleGrouped];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.estimatedRowHeight = 110/2;
    _tableView.estimatedSectionHeaderHeight = 11;
    _tableView.sectionIndexMinimumDisplayRowCount = _groups.count;
    _tableView.sectionIndexColor = [UIColor grayColor];
    _tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.tableHeaderView = [[UIView alloc]init];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
    
    [self customSearchBarView];
    
}

#pragma mark - View创建工具
-(void)customSearchBarView
{
    _searchBGView= [[UIView alloc]initWithFrame:CGRectMake(0, 64, kDeviceWidth, 44)];
    _searchBGView.backgroundColor = [UIColor clearColor];
    _tableView.tableHeaderView = _searchBGView;
    
    _searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(15, 6, kDeviceWidth -30, 33)];
    _searchBar.backgroundColor = [UIColor whiteColor];
    [_searchBar.layer setMasksToBounds:YES];
    [_searchBar.layer setCornerRadius:3.5];
    _searchBar.keyboardType = UIKeyboardTypeDefault;
    _searchBar.placeholder = @"搜索";
    _searchBar.delegate = self;
    [_searchBGView addSubview:_searchBar];
    
    UIImage* clearImg = [self imageWithColor:[UIColor clearColor] andHeight:33.0f];
    [_searchBar setBackgroundImage:clearImg];
    UIImage *grayImg = [self imageWithColor:[UIColor whiteColor] andHeight:33.0f];
    [_searchBar setSearchFieldBackgroundImage:grayImg forState:UIControlStateNormal];
    [_searchBar setBackgroundColor:[UIColor clearColor]];
    
    for (UIView *subview in _searchBar.subviews) {
        for(UIView* grandSonView in subview.subviews){
            
            
            if([grandSonView isKindOfClass:NSClassFromString(@"UISearchBarTextField")] ){
                [grandSonView.layer setCornerRadius:5.0f];
                [grandSonView.layer setMasksToBounds:YES];
                break;
            }
        }
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

#pragma mark -点击事件

///添加新朋友事件
-(void)addNewFriendBtnClick:(UIButton *)sender
{
    NSLog(@"进入新的朋友界面");
    NewFriendViewController *newFriendVC = [[NewFriendViewController alloc]init];
    [self.navigationController pushViewController:newFriendVC animated:YES];
}

///cell头像点击事件
-(void)cellAvatarBtnClick:(UIButton *)sender
{
    NSLog(@"你点击了cellAvatarBtn");
}

/// 去聊天
- (void)goChat:(WJID *)uJid
{
    ChatViewController *chatVC = [[ChatViewController alloc] init];
    chatVC.uJid = uJid;
    [chatVC createDirectory:uJid.phone];
    chatVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:chatVC animated:YES];
}


#pragma mark - UITabelViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 110/2;
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 110/2;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section==0) {
        return 0;
    }else
    {
        return 11;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.section ==0)
    {
        if (indexPath.row ==0)
        {
            NewFriendViewController *newFriendsVC = [[NewFriendViewController alloc]init];
            [self.navigationController pushViewController:newFriendsVC animated:YES];
        }
        else
        {
            GroupListViewController *groupListVC = [[GroupListViewController alloc]init];
            [self.navigationController pushViewController:groupListVC animated:YES];
        }
    }
    else
    {
        NSString *key = [NSString stringWithFormat:@"%@",[_dataArray objectAtIndex:indexPath.section]];
        NSArray *sectionArray = [_friendsList objectForKey:key];
        WJID *uJid = [sectionArray objectAtIndex:indexPath.row];
        [self goChat:uJid];
    }
}

#pragma mark - UITableViewDataSource
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identity = @"identity";
    static NSString *identityContact = @"identityContact";
    if (indexPath.section ==0) {
        SectionModel *sectionArea = [_dataArray objectAtIndex:0];
        ContactCell *cell = [tableView dequeueReusableCellWithIdentifier:identity];
        if (cell ==nil) {
            cell = [[ContactCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identity];
        }
        cell.namelabel.text = [[sectionArea.itemArray objectAtIndex:indexPath.row]title];
        [cell.avatarBtn setImage:[UIImage imageNamed:[[sectionArea.itemArray objectAtIndex:indexPath.row]subTitle]]forState:UIControlStateNormal];
        
        return cell;
    }else
    {
        
        NSString *key = [NSString stringWithFormat:@"%@",[_dataArray objectAtIndex:indexPath.section]];
        NSArray *sectionArray = [_friendsList objectForKey:key];
        WJID *uJid = [sectionArray objectAtIndex:indexPath.row];
        
        ContactCell *cell = [tableView dequeueReusableCellWithIdentifier:identityContact];
        if (cell ==nil) {
            cell = [[ContactCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identityContact];
        }
        
        __weak ContactCell *weakCell = cell;
        __weak WSocket *weakSocket = _wSocket;
        [[WSocket sharedWSocket]addDownFileOperationWithFileUrlString:uJid.avatarUrl serialId:@"-1" modelType:ModelTypeNormal info:nil downBlock:^(int ret, int isSave, NSData *data, NSString *fileUrl) {
            
            if (ret>=0)
            {
                [weakCell.avatarBtn setImage:[UIImage imageWithData:data] forState:UIControlStateNormal];
                if (isSave) {
                    
                    [data writeToFile:[NSString stringWithFormat:@"%@/%@",kPathAvatar,[weakSocket.lbxManager upper16_MD5:fileUrl]] atomically:YES];
                }
            }
            else
            {
                [weakCell.avatarBtn setImage:kDefaultAvatarImage forState:UIControlStateNormal];
            }
        }];
        
        if ([uJid.nickname isEqualToString:@"null"]||uJid.nickname.length<=0) {
            
            uJid.nickname = [NSString stringWithFormat:@"%@%@",uJid.area,uJid.phone];
        }
        
        weakCell.namelabel.text = [_wSocket.lbxManager stringFromHexString:uJid.nickname];
        
        if (indexPath.row == sectionArray.count-1) {
            [weakCell.sepline setHidden:YES];
        }
        
        return cell;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section==0)
    {
        return 2;
    }else
    {
        NSString *key = [NSString stringWithFormat:@"%@",[_dataArray objectAtIndex:section]];
        NSArray *sectionArray = [_friendsList objectForKey:key];
        return sectionArray.count;
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _dataArray.count;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section ==0) {
        return @"";
    }else
    {
        return [_dataArray objectAtIndex:section];
    }
}

- (nullable NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return _groups;
}


#pragma mark - UISearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"点击了搜索");
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [_searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
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



@end
