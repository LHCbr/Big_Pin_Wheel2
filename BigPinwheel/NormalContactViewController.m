//
//  AddressBookViewController.m
//  BDMapDemo
//
//  Created by tw001 on 14-10-8.
//  Copyright (c) 2014年 ESX. All rights reserved.
//

#import "NormalContactViewController.h"
#import "AddressBookTableViewCell2.h"
#import "AppDelegate.h"
#import "WSocket.h"

#import "CusFriendCell.h"
#import "ContactCell.h"
//#import "TelegramInviteInfoViewController.h"
#import <AddressBook/AddressBook.h>
#import "ChatViewController.h"
#import "AddViewController.h"
#import "GroupListViewController.h"
//#import "NewFriendsViewController.h"

@interface NormalContactViewController ()
{
    WSocket *ws;
    NSIndexPath *_selectIndexPath;
}
@end

@implementation NormalContactViewController

- (void)backButtonClick
{
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)addressBook:(NSNotification *)notifi
{
    int res = [[notifi object] intValue];
    if (res == 1) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"好友列表刷新完成！" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
            [alertView show];
            _refrashState = NO;
            _refrashCount = 0;
            _refrashContentLabel.text = @"刷新好友列表";
            [_timer setFireDate:[NSDate distantFuture]];
            //            _refrashImageView.image = [UIImage imageNamed:@"refrash_friend"];
            _refrashView.backgroundColor = [UIColor whiteColor];
            
            UIView *vvv = [self.view viewWithTag:82];
            if (vvv) { [vvv removeFromSuperview]; }
        });
    }else if (res == 2){
        dispatch_async(dispatch_get_main_queue(), ^{
            _dataArray = nil;
            _groups = nil;
            [_tableView reloadData];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"没有任何好友！" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
            [alertView show];
            _refrashState = NO;
            _refrashCount = 0;
            _refrashContentLabel.text = @"刷新好友列表";
            [_timer setFireDate:[NSDate distantFuture]];
            //            _refrashImageView.image = [UIImage imageNamed:@"refrash_friend"];
            _refrashView.backgroundColor = [UIColor whiteColor];
        });
    }else{
        
        NSMutableDictionary *new_dataArray = [ws getAddressBook];
        NSMutableArray *new_groups = [ws sortAddressBook:new_dataArray];
        _dataArray = new_dataArray;
        _groups = new_groups;
        NSLog(@"dataArray.count = %d",(int)_dataArray.count);
        NSLog(@"_groups.count = %d",(int)_groups.count);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self tipcount];
            [_tableView reloadData];
            UIView *vvv = [self.view viewWithTag:82];
            if (vvv) { [vvv removeFromSuperview]; }
        });
    }
}

- (void)goAddNewFriend:(UIButton *)btn
{
    _searchBar.showsCancelButton = NO;
    [_searchBar resignFirstResponder];
    [_searchTextField resignFirstResponder];
    
    AddViewController *addVC = [[AddViewController alloc] init];
    
    CATransition* transition = [CATransition animation];
    transition.duration = 0.33;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    transition.type = kCATransitionMoveIn;
    transition.subtype = kCATransitionFromTop;
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    [self.navigationController pushViewController:addVC animated:NO];

    
    
}

- (void)newFriends
{
    [_searchBar resignFirstResponder];
    [_searchTextField resignFirstResponder];
    
    
//    NewFriendsViewController *newFVC = [[NewFriendsViewController alloc] init];
//    newFVC.hidesBottomBarWhenPushed = YES;
//    [self.navigationController pushViewController:newFVC animated:YES];
}

- (void)responseUpdateNoteName:(NSNotification *)notifi
{
    dispatch_async(dispatch_get_main_queue(), ^{
        int res = [[notifi object] intValue];
        if (res >= 0) {
            if (_nIndexPath.section >= 0 && _nIndexPath.row >= 0) {
                NSString *key = [_groups objectAtIndex:_nIndexPath.section];
                NSMutableArray *array = [_dataArray objectForKey:key];
                WJID *uJid = [array objectAtIndex:_nIndexPath.row];
                uJid.nickname = _notename;
                [_tableView reloadData];
//                [[WSocket shareWSocket] getFriendInfo:uJid.phone selectDb:NO];
            }
            
        }else{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"设置备注信息失败" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
            [alertView show];
        }
    });
}

- (void)dealloc
{
    NSLog(@"通讯录界面释放");
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
}

- (void)setIndexPathZero
{
    _selectIndexPath = [NSIndexPath indexPathForRow:-1 inSection:-1];
}

/// 新建群
- (void)newGroupClick
{
    [_searchBar resignFirstResponder];
    
    GroupListViewController *groupListVC = [[GroupListViewController alloc] init];
    groupListVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:groupListVC animated:YES];
}

/// 登陆成功，清楚聊天列表，获取最新的
- (void)loginSuccess:(NSNotification *)noti
{
    dispatch_async(dispatch_get_main_queue(), ^{

    });
}

/// 退出登录成功
- (void)logOutNotification:(NSNotification *)noti
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [_dataArray removeAllObjects];
        [_tableView reloadData];
    });
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self setIndexPathZero];
    
    _isSearch = NO;
    
    float tHeight = 0.0f;
    tHeight = 20.0f;

    _atTop = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, tHeight)];
    _atTop.backgroundColor = [UIColor whiteColor];
    _atTop.hidden = YES;
    [self.view addSubview:_atTop];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    // 通知中心键盘即将显示时刻触发事件
    [center addObserver:self selector:@selector(handleKeyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    // 通知中心键盘即将消失时刻触发事件
    [center addObserver:self selector:@selector(handleKeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
//    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, _atTop.frame.size.height, self.view.frame.size.width, 44)];
//    _searchBar.placeholder = @"请输入昵称";
//    _searchBar.delegate = self;
//    _searchBar.hidden = YES;
//    _searchBar.backgroundColor = [UIColor clearColor];
//    [self.view addSubview:_searchBar];
//    
//    
//    
    NAVBAR(@"通讯录");
    self.view.backgroundColor = [UIColor whiteColor];
    
    _navHeight = 64.0;
    
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"0223_nr_jia"] style:UIBarButtonItemStylePlain target:self action:@selector(goAddNewFriend:)];
    self.navigationItem.rightBarButtonItem = rightButtonItem;

    _nIndexPath = [NSIndexPath indexPathForRow:-1 inSection:-1];
    
    ws = [WSocket sharedWSocket];
    _dataArray = [ws getAddressBook];
    _groups = [ws sortAddressBook:_dataArray];
    
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, _navHeight, self.view.frame.size.width, self.view.frame.size.height - _navHeight - self.tabBarController.tabBar.frame.size.height)];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    
    // 添加登陆成功的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccess:) name:kLoginSuccess object:nil];
    // 添加退出登陆的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logOutNotification:) name:kLogOutNotification object:nil];
    // 增加刷新好友列表的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addressBook:) name:@"updateFriendList" object:nil];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40 + 56 + 56 + 0.5 + 0.5  + 0.5 + 0.5)];
    
    float searchBarWidth = self.view.frame.size.width;
    searchBarWidth = self.view.frame.size.width - 15;
    
//    _searchTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, 0, searchBarWidth - 20, 56)];
//    _searchTextField.placeholder = @"搜索";
//    _searchTextField.delegate = self;
//    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 10, 25, 20)];
//    UIImageView *searchImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 19, 18)];
//    searchImageView.image = [UIImage imageNamed:@"nn_ditu_sousuo"];
//    [leftView addSubview:searchImageView];
//    _searchTextField.leftView = leftView;
//    _searchTextField.leftViewMode = UITextFieldViewModeAlways;
//    _searchTextField.backgroundColor = [UIColor whiteColor];
//    [headerView addSubview:_searchTextField];
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 1, kDeviceWidth, 38)];
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
    [headerView addSubview:view];
    
    UIButton *nBut = [UIButton buttonWithType:UIButtonTypeCustom];
    [nBut setBackgroundColor:[UIColor whiteColor]];
    nBut.frame = CGRectMake(0, 40, headerView.frame.size.width, 56);
    [headerView addSubview:nBut];
    [nBut addTarget:self action:@selector(newFriends) forControlEvents:UIControlEventTouchUpInside];
    [nBut setBackgroundImage:[self imageWithColor:COLOR(221, 221, 221, 1) andHeight:56] forState:UIControlStateHighlighted];
    [nBut setBackgroundImage:[self imageWithColor:[UIColor whiteColor] andHeight:56] forState:UIControlStateNormal];
    
    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn1.frame = CGRectMake(10, 10, 36, 36);
    [btn1 setImage:[UIImage imageNamed:@"0223_con_yong"] forState:UIControlStateNormal];
    [nBut addSubview:btn1];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(51, 0, 200, 56)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor blackColor];
    label.font = [UIFont systemFontOfSize:15];
    label.text = @"新的朋友";
    [nBut addSubview:label];
    
    _tipBtn = [[UIButton alloc] initWithFrame:CGRectMake(headerView.frame.size.width - 50, 10, 20, 20)];
    _tipBtn.backgroundColor = [UIColor redColor];
    _tipBtn.layer.cornerRadius = 10;
    _tipBtn.titleLabel.font = [UIFont systemFontOfSize:10.0f];
    _tipBtn.hidden = YES;
    [nBut addSubview:_tipBtn];
    
    UIButton *newGroupBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [newGroupBtn setBackgroundColor:[UIColor whiteColor]];
    newGroupBtn.frame = CGRectMake(0, 96, headerView.frame.size.width, 56);
    [headerView addSubview:newGroupBtn];
    [newGroupBtn addTarget:self action:@selector(newGroupClick) forControlEvents:UIControlEventTouchUpInside];
    [newGroupBtn setBackgroundImage:[self imageWithColor:COLOR(221, 221, 221, 1) andHeight:56] forState:UIControlStateHighlighted];
    [newGroupBtn setBackgroundImage:[self imageWithColor:[UIColor whiteColor] andHeight:56] forState:UIControlStateNormal];

    
    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn2.frame = CGRectMake(10, 10, 36, 36);
    [btn2 setImage:[UIImage imageNamed:@"0223_con_suo"] forState:UIControlStateNormal];
    [newGroupBtn addSubview:btn2];
    
    UILabel *newGroupLabel = [[UILabel alloc] initWithFrame:CGRectMake(51, 0, 200, 56)];
    newGroupLabel.backgroundColor = [UIColor clearColor];
    newGroupLabel.textColor = [UIColor blackColor];
    newGroupLabel.font = [UIFont systemFontOfSize:15];
    newGroupLabel.text = @"群聊";
    [newGroupBtn addSubview:newGroupLabel];
    
//    NSString *myname = [NSString stringWithFormat:@"   %@",ws.lbxManager.wJid.nickname];
//    UILabel *myName = [[UILabel alloc]initWithFrame:CGRectMake(0, 120, headerView.frame.size.width, 40)];
//    myName.text = myname;
//    myName.font = [UIFont systemFontOfSize:15];
//    myName.textColor = [[UIColor redColor]colorWithAlphaComponent:0.7];
//    [headerView addSubview:myName];
    
    UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(0, 40, self.view.frame.size.width, 0.5)];
    line1.backgroundColor = COLOR(235, 235, 235, 1);
    [headerView addSubview:line1];
    
    UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(0, 96, self.view.frame.size.width, 0.5)];
    line2.backgroundColor = COLOR(235, 235, 235, 1);
    [headerView addSubview:line2];
    
//    UIView *line3 = [[UIView alloc] initWithFrame:CGRectMake(0, 120, self.view.frame.size.width, 0.5)];
//    line3.backgroundColor = COLOR(235, 235, 235, 1);
//    [headerView addSubview:line3];
    
//    UIView *line4 = [[UIView alloc] initWithFrame:CGRectMake(0, 160, self.view.frame.size.width, 0.5)];
//    line4.backgroundColor = COLOR(235, 235, 235, 1);
//    [headerView addSubview:line4];
    //    UIView *line3 = [[UIView alloc] initWithFrame:CGRectMake(0, 120, self.view.frame.size.width, 0.5)];
    //    line3.backgroundColor = COLOR(235, 235, 235, 1);
    //    [headerView addSubview:line3];
    
    //    UIView *newFView = [[UIView alloc] initWithFrame:CGRectMake(0, 40.5, searchBarWidth, 56)];
    //    newFView.backgroundColor = [UIColor whiteColor];
    //    [headerView addSubview:newFView];
    //
    //    UIImageView *avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 36, 36)];
    //    avatarImageView.layer.masksToBounds = YES;
    //    avatarImageView.layer.cornerRadius = 18.0f;
    //    avatarImageView.image = [UIImage imageNamed:@"xiaoxi_lianxiren"];
    //    [newFView addSubview:avatarImageView];
    //
    //    UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(56, 10,  searchBarWidth - avatarImageView.frame.origin.x, 36)];
    //    contentLabel.font = [UIFont systemFontOfSize:16.0f];
    //    contentLabel.text = @"新的朋友";
    //    [newFView addSubview:contentLabel];
    //
    //    UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(0, 56, self.view.frame.size.width, 0.5)];
    //    line2.backgroundColor = COLOR(235, 235, 235, 1);
    //    [newFView addSubview:line2];
    //
    //    _tipBtn = [[UIButton alloc] initWithFrame:CGRectMake(avatarImageView.frame.origin.x + avatarImageView.frame.size.width - 8, avatarImageView.frame.origin.y - 3, 18, 18)];
    //    _tipBtn.backgroundColor = [UIColor redColor];
    //    _tipBtn.layer.cornerRadius = 10;
    //    _tipBtn.titleLabel.font = [UIFont systemFontOfSize:10.0f];
    //    _tipBtn.hidden = YES;
    //    [newFView addSubview:_tipBtn];
    //
    //    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(newFriends)];
    //    [newFView addGestureRecognizer:tapGes];
    
    //    _refrashView = [[UIView alloc] initWithFrame:CGRectMake(0, newFView.frame.origin.y + newFView.frame.size.height + 0.5, searchBarWidth, 56)];
    //    _refrashView.backgroundColor = [UIColor whiteColor];
    //    [headerView addSubview:_refrashView];
    //
    //    _refrashImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 36, 36)];
    //    _refrashImageView.layer.masksToBounds = YES;
    //    _refrashImageView.layer.cornerRadius = 18.0f;
    //    _refrashImageView.image = [UIImage imageNamed:@"refrash_friend"];
    //
    //    [_refrashView addSubview:_refrashImageView];
    //
    //    _refrashContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(56, _refrashImageView.frame.origin.y, searchBarWidth - avatarImageView.frame.origin.x, 36)];
    //    _refrashContentLabel.font = [UIFont systemFontOfSize:16.0f];
    //    _refrashContentLabel.text = @"刷新好友列表";
    //    [_refrashView addSubview:_refrashContentLabel];
    //
    //    UITapGestureRecognizer *refrashGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(refreshFriends:)];
    //    [_refrashView addGestureRecognizer:refrashGes];
    
    _refrashState = NO;
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(detectionRefrash) userInfo:nil repeats:YES];
    [_timer setFireDate:[NSDate distantFuture]];
    
    _tableView.tableHeaderView = headerView;
    _tableView.tableFooterView = [[UIView alloc] init];
    
    _resultTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, _navHeight, self.view.frame.size.width, self.view.frame.size.height - _navHeight - 49.0)];
    _resultTableView.dataSource = self;
    _resultTableView.delegate = self;
    _resultTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _resultTableView.hidden = YES;
    [self.view addSubview:_resultTableView];
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //    [_tableView reloadData];
    
    //    Message *msg = [[ws msgRemindList] objectAtIndex:0];
    //    UIViewController *tController = [self.tabBarController.viewControllers objectAtIndex:1];
    //    int badgeValue = [tController.tabBarItem.badgeValue intValue];
    //    int value = badgeValue - msg.tipCount;
    //    if (value <= 0) {
    //        tController.tabBarItem.badgeValue = nil;
    //    }else{
    //        tController.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d", value];
    //    }
    //    [ws changeBadgeValueTag:1 value:msg.tipCount isAdd:-1];
    //    msg.tipCount = 0;
    //
    //    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    //    [ws hideTabbarView:YES animation:NO];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    _nIndexPath = [NSIndexPath indexPathForRow:-1 inSection:-1];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self tipcount];
    
    if (_searchBar) {
        if (_searchBar.text.length) {
            [_searchBar becomeFirstResponder];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_timer invalidate];
    _timer = nil;
    
}

- (void)refreshFriends:(UITapGestureRecognizer *)tap
{
//    if (_refrashState == NO) {
//        if (ws.isConnect == kConnectFailue) {
//            [[WSocket shareWSocket] showHudViewLabelText:@"刷新失败" detailsLabelText:nil afterDelay:1];
//            
//        }else{
//            [_timer setFireDate:[NSDate date]];
//            _refrashState = YES;
//            _refrashContentLabel.text = @"正在刷新中...";
//            _refrashView.backgroundColor = COLOR(38, 165, 162, 1);
//            //            _refrashImageView.image = [UIImage imageNamed:@"refrash_friend_high"];
//            
//            //            [ws refrashFriendList];
//        }
//    }
}

- (void)detectionRefrash
{
//    _refrashCount++;
//    NSLog(@"_refrashCount====%d", _refrashCount);
//    if (_refrashCount > 60 || ws.isConnect == kConnectFailue) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"好友列表刷新完成！" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
//            [alertView show];
//            _refrashState = NO;
//            _refrashCount = 0;
//            _refrashContentLabel.text = @"刷新好友列表";
//            ws.isRefrashLocalFriends = NO;
//            [_timer setFireDate:[NSDate distantFuture]];
//        });
//    }
}

- (void)tipcount
{
//    if (ws.wJid.waitAcceptCount > 0) {
//        _tipBtn.hidden = NO;
//        if (ws.wJid.waitAcceptCount > 99) {
//            [_tipBtn setTitle:@"99+" forState:UIControlStateNormal];
//        }else{
//            [_tipBtn setTitle:[NSString stringWithFormat:@"%d", ws.wJid.waitAcceptCount] forState:UIControlStateNormal];
//        }
//    }else{
//        _tipBtn.hidden = YES;
//    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    //    SearchFriendViewController *searchFVC = [[SearchFriendViewController alloc] init];
    //    CATransition *animation = [CATransition animation];
    //    [animation setDuration:0.33];
    //    [animation setType:kCATransitionFade]; //淡入淡出
    //    [animation setSubtype:kCATransitionFromLeft];
    //    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
    //    [self.navigationController.view.layer addAnimation:animation forKey:nil];
    //    [self.navigationController pushViewController:searchFVC animated:NO];
    //    return NO;
    [self setIndexPathZero];
    [_tableView reloadData];
    _isSearch = YES;
    
    [_resultDataArray removeAllObjects];
    [_resultTableView reloadData];
    
    _tableView.hidden = YES;
    _resultTableView.hidden = NO;
    [UIView animateWithDuration:.3 animations:^{
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationCurve:7];
        _aNav.frame = CGRectMake(0, -64, self.aNav.frame.size.width, self.aNav.frame.size.height);
        _atTop.hidden = NO;
        _searchBar.hidden = NO;
        _searchBar.text = @"";
        [_searchBar becomeFirstResponder];
    }];
    
    return NO;
}

#pragma mark - UISearchBarDelegate

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

//- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
//{
//    _searchBar.showsCancelButton = YES;
//        UIView *view = [searchBar.subviews objectAtIndex:0];
//        UIButton *cancelButton = [view.subviews objectAtIndex:2];
//        [cancelButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
//        [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
//    
//    return YES;
//}
//
//- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
//{
//    if (searchText.length > 0) {
//        _resultTableView.hidden = NO;
////        _resultDataArray = [[WSocket shareWSocket] fuzzySearchFriends:searchText];
//        [_resultTableView reloadData];
//    }else{
//        _resultTableView.hidden = YES;
//    }
//}
//
//- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
//{
//    [self setIndexPathZero];
//    _isSearch = NO;
//    _tableView.hidden = NO;
//    [_HUD hide:YES];
//    [_timer setFireDate:[NSDate distantFuture]];
//    _searchBar.showsCancelButton = NO;
//    [_searchBar resignFirstResponder];
//    [UIView animateWithDuration:.3 animations:^{
//        [UIView setAnimationBeginsFromCurrentState:YES];
//        [UIView setAnimationCurve:7];
//        _aNav.frame = CGRectMake(0, 0, self.aNav.frame.size.width, self.aNav.frame.size.height);
//        _atTop.hidden = YES;
//        _searchBar.hidden = YES;
//        _resultTableView.hidden = YES;
//    }];
//}
//
//- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
//{
//    [_searchBar resignFirstResponder];
//}
//
#pragma mark - 排序
- (void)sortAddressBook
{
    for (NSString *key in _dataArray) {
        NSMutableArray *object = [_dataArray objectForKey:key];
        [object sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [[obj1 nickname] compare:[obj2 nickname]];
        }];
    }
    NSArray *allKeys = [_dataArray allKeys];
    NSArray *sortAllKeys = [allKeys sortedArrayUsingSelector:@selector(compare:)];
    [_groups removeAllObjects];
    _groups = nil;
    _groups = [NSMutableArray arrayWithArray:sortAllKeys];
    
    [_tableView reloadData];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == _tableView) {
        if (_groups.count == _dataArray.count) {
            return _groups.count;
        } else {
            return 0;
        }
    }else{
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _tableView) {
        if (_groups.count == _dataArray.count) {
            NSString *key = [_groups objectAtIndex:section];
            NSMutableArray *array = [_dataArray objectForKey:key];
            return [array count];
        } else {
            return 0;
        }
    }else{
        return _resultDataArray.count;
    }
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if (tableView == _tableView) {
            if (_groups.count == _dataArray.count) {
                return _groups;
            } else {
                return nil;
            }

    }else{
        return nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _tableView) {
        
        if (_dataArray.count != _groups.count) {
            return nil;
        }
        
        NSString *key = @"null";
        if (_groups.count > indexPath.section) {
            key = [_groups objectAtIndex:indexPath.section];
        }
        NSMutableArray *array = [_dataArray objectForKey:key];
        WJID *wJid = [[WJID alloc] init];
        if (array.count > indexPath.row) {
            wJid = [array objectAtIndex:indexPath.row];
        }
        
        static NSString *identifier = @"address book cell";
        //        if (isIos7) {
        AddressBookTableViewCell *cell = (AddressBookTableViewCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil) {
            cell = [[AddressBookTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            //                [cell setRightUtilityButtons:[self rightButtons] WithButtonWidth:128.0f];
            //            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            //            cell.delegate = self;
        }
        NSLog(@" ======= %@",wJid.area);
        cell.locationLabel.text = wJid.area;
        
        //        if (_selectIndexPath.section == indexPath.section && _selectIndexPath.row == indexPath.row) {
        //            [cell.chatButton setHidden:NO];
        //            [cell.locationLabel setHidden:NO];
        //            [cell.deleteButton setHidden:NO];
        //            [cell.chatButton addTarget:self action:@selector(chatButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        //            [cell.deleteButton addTarget:self action:@selector(deleteButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        //        } else {
        //            [cell.chatButton setHidden:YES];
        //            [cell.locationLabel setHidden:YES];
        //            [cell.deleteButton setHidden:YES];
        //        }
        
        cell.contentLabel.text = wJid.nickname;
        //        if ([wJid.sex isEqualToString:@"女"]) {
        //
        //            cell.contentLabel.textColor = COLOR(240, 120, 140, 1);
        //        } else {
        //            cell.contentLabel.textColor = COLOR(60, 178, 226, 1);
        //        }
        
        if (wJid.nickname.length <= 0 || [wJid.nickname isEqualToString:kDefaultNull]) {
//            [ws getFriendInfo:wJid.phone selectDb:NO];
        }
        
        if ([wJid.sex isEqualToString:@"女"]) {
            [cell.avatarButton setImage:kDefaultAvatarImage forState:UIControlStateNormal];
            cell.contentLabel.textColor = [UIColor blackColor];
        } else if ([wJid.sex isEqualToString:@"男"]){
            [cell.avatarButton setImage:kDefaultAvatarImage forState:UIControlStateNormal];
            cell.contentLabel.textColor = [UIColor blackColor];
        }else{
            [cell.avatarButton setImage:kDefaultAvatarImage forState:UIControlStateNormal];
            cell.contentLabel.textColor = [UIColor redColor];
            cell.deleteButton.hidden = YES;
        }
        
        __weak WSocket *weakSocket = ws;
        __weak AddressBookTableViewCell *weakCell = cell;
        
        [ws addDownFileOperationWithFileUrlString:wJid.avatarUrl serialId:@"-1" modelType:ModelTypeNormal info:nil downBlock:^(int ret, int isSave, NSData *data, NSString *fileUrl) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (ret >= 0) {
                    [weakCell.avatarButton setImage:[UIImage imageWithData:data] forState:UIControlStateNormal];
                    if (isSave) {
                        [data writeToFile:[NSString stringWithFormat:@"%@/%@",kPathAvatar,[weakSocket.lbxManager upper16_MD5:fileUrl]] atomically:YES];
                        [data writeToFile:[NSString stringWithFormat:@"%@/%@",kPathAvatar,wJid.phone] atomically:YES];

                    }
                }
            });
        }];

        
        return cell;
    }else{
        static NSString *identifier = @"search_friends_cell";
        WJID *wJid = [_resultDataArray objectAtIndex:indexPath.row];
        AddressBookTableViewCell2 *cell = (AddressBookTableViewCell2 *)[tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil) {
            cell = [[AddressBookTableViewCell2 alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        
        cell.locationLabel.text = wJid.area;
        
        if (_selectIndexPath.section == indexPath.section && _selectIndexPath.row == indexPath.row) {
            [cell.chatButton setHidden:NO];
            [cell.locationLabel setHidden:NO];
            [cell.deleteButton setHidden:NO];
            [cell.chatButton addTarget:self action:@selector(chatButtonClick:) forControlEvents:UIControlEventTouchUpInside];
            [cell.deleteButton addTarget:self action:@selector(deleteButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        } else {
            [cell.chatButton setHidden:YES];
            [cell.locationLabel setHidden:YES];
            [cell.deleteButton setHidden:YES];
        }
        
        cell.contentLabel.text = wJid.nickname;
        if ([wJid.sex isEqualToString:@"女"]) {
            [cell.avatarButton setImage:kDefaultAvatarImage forState:UIControlStateNormal];
            cell.contentLabel.textColor = [UIColor blackColor];
        } else if ([wJid.sex isEqualToString:@"男"]){
            [cell.avatarButton setImage:kDefaultAvatarImage forState:UIControlStateNormal];
            cell.contentLabel.textColor = [UIColor blackColor];
        }else{
            [cell.avatarButton setImage:kDefaultAvatarImage forState:UIControlStateNormal];
            cell.contentLabel.textColor = [UIColor redColor];
            cell.deleteButton.hidden = YES;
        }
        
        cell.lineView.frame = CGRectMake(8, cell.lineView.frame.origin.y, cell.contentView.frame.size.width - 6, 0.5);
        __weak WSocket *weakSocket = ws;
        __weak AddressBookTableViewCell2 *weakCell = cell;
        
        [ws addDownFileOperationWithFileUrlString:wJid.avatarUrl serialId:@"-1" modelType:ModelTypeNormal info:nil downBlock:^(int ret, int isSave, NSData *data, NSString *fileUrl) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (ret >= 0) {
                    [weakCell.avatarButton setImage:[UIImage imageWithData:data] forState:UIControlStateNormal];
                    if (isSave) {
                        [data writeToFile:[NSString stringWithFormat:@"%@/%@",kPathAvatar,[weakSocket.lbxManager upper16_MD5:fileUrl]] atomically:YES];
                        [data writeToFile:[NSString stringWithFormat:@"%@/%@",kPathAvatar,wJid.phone] atomically:YES];
                    }
                }
            });
        }];
        
        return cell;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    if (indexPath.section == 0) {
        return NO;
    }
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _tableView) {
        if (editingStyle == UITableViewCellEditingStyleDelete) {
            NSLog(@"已经删除");
            _selectIndexPath = indexPath;
            [self deleteButtonClick:nil];
        } else if (editingStyle == UITableViewCellEditingStyleInsert) {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
}
/// 删除好友
- (void)deleteButtonClick:(UIButton *)sender
{
    WJID *wJid = [[WJID alloc] init];
    
    if (_isSearch == NO) {
        NSString *key = @"null";
        if (_groups.count > _selectIndexPath.section) {
            key = [_groups objectAtIndex:_selectIndexPath.section];
        }
        NSMutableArray *array = [_dataArray objectForKey:key];
        if (array.count > _selectIndexPath.row) {
            wJid = [array objectAtIndex:_selectIndexPath.row];
        }
    } else {
        wJid = [_resultDataArray objectAtIndex:_selectIndexPath.row];
    }
    
    NSString *message = [NSString stringWithFormat:@"确定要删除%@",wJid.nickname];
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    av.tag = 42;
    [av show];
    
}

#pragma mark - uialertViewDelgate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == alertView.cancelButtonIndex) {
        [_tableView reloadData];
        return;
    }
    
    if (alertView.tag == 42) {
        WJID *wJid = [[WJID alloc] init];
        
        if (_isSearch == NO) {
            NSString *key = @"null";
            if (_groups.count > _selectIndexPath.section) {///分组数大于区，保证能取到这个区的东西
                key = [_groups objectAtIndex:_selectIndexPath.section];
            }
            NSMutableArray *array = [_dataArray objectForKey:key];
            if (array.count > _selectIndexPath.row) {
                wJid = [array objectAtIndex:_selectIndexPath.row];
            }
        } else {
            wJid = [_resultDataArray objectAtIndex:_selectIndexPath.row];
        }
        
//        if ([[WSocket shareWSocket] delFriend:wJid.phone] == kConnectFailue) {
//            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"网络连接失败，请检查网络！" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
//            [alertView show];
//        }
        if (_isSearch == NO) {
            [self setIndexPathZero];
            [_tableView reloadData];
        } else {
            [_resultDataArray removeObjectAtIndex:_selectIndexPath.row];
            [self setIndexPathZero];
            [_resultTableView reloadData];
        }
    }
}

/// 聊天
- (void)chatButtonClick:(UIButton *)sender
{
    WJID *wJid = [[WJID alloc] init];
    
    if (_isSearch == NO) {
        NSString *key = @"null";
        if (_groups.count > _selectIndexPath.section) {
            key = [_groups objectAtIndex:_selectIndexPath.section];
        }
        NSMutableArray *array = [_dataArray objectForKey:key];
        if (array.count > _selectIndexPath.row) {
            wJid = [array objectAtIndex:_selectIndexPath.row];
        }
    } else {
        wJid = [_resultDataArray objectAtIndex:_selectIndexPath.row];
    }
    
    [self.navigationController popToRootViewControllerAnimated:NO];
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (wJid.phone.length) {
        int sex = 1;
        if ([wJid.sex isEqualToString:@"女"]) {
            sex = 2;
        }
        
        ChatViewController *chatVC = [[ChatViewController alloc] init];
        chatVC.uJid = wJid;
        [chatVC createDirectory:wJid.phone];
        chatVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:chatVC animated:YES];
        
       //[app.messageVC jumpChatWithPhone:wJid.phone nickname:wJid.nickname foreignHeadPortrait:@"" animation:YES sex:sex];
    }
}

#pragma mark - Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 56.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView == _tableView) {
        return 22;//自定义高度
    }else{
        return 0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (tableView == _tableView) {
        if ((_dataArray.count != _groups.count) || _groups.count <= section) {
            return nil;
        }
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 20)];
        view.backgroundColor = COLOR(232, 232, 240, 1);
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 100, 20)];
        titleLabel.text = [_groups objectAtIndex:section];
        titleLabel.font = [UIFont systemFontOfSize:14.0f];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = COLOR(95, 95, 95, 1);
        [view addSubview:titleLabel];
        return view;
    }else{
        return nil;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([_searchBar isFirstResponder]) {
        [_searchBar resignFirstResponder];
        return;
    }

    
    if (tableView == _tableView) {
        _selectIndexPath = indexPath;
//        if (_selectIndexPath.section == indexPath.section && _selectIndexPath.row == indexPath.row) {
//            [self setIndexPathZero];
//        } else {
//            _selectIndexPath = indexPath;
//        }
//        [tableView reloadData];
        [self chatButtonClick:nil];
    } else {
        
        _selectIndexPath = indexPath;

//        if (_selectIndexPath.section == indexPath.section && _selectIndexPath.row == indexPath.row) {
//            [self setIndexPathZero];
//        } else {
//            _selectIndexPath = indexPath;
//        }
//        [_resultTableView reloadData];
    }
    
    //    if (tableView == _tableView) {
    //        NSString *key = [_groups objectAtIndex:indexPath.section];
    //        NSMutableArray *array = [_dataArray objectForKey:key];
    //        WJID *wJid = [array objectAtIndex:indexPath.row];
    //
    //        if (_fromType == 0) {
    //            [_searchTextField resignFirstResponder];
    //
    //        }else if (_fromType == 1) {
    //            [_delegate selectedUser:wJid];
    //            [self.navigationController popViewControllerAnimated:NO];
    //        }
    //    }else{
    //        WJID *wJid = [_resultDataArray objectAtIndex:indexPath.row];
    //        if (_fromType == 0) {
    //            [_searchTextField resignFirstResponder];
    //
    //        }else if (_fromType == 1) {
    //            [_delegate selectedUser:wJid];
    //            [self.navigationController popViewControllerAnimated:YES];
    //        }
    //    }
}

- (NSArray *)rightButtons
{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
//    [rightUtilityButtons sw_addUtilityButtonWithColor: [UIColor colorWithRed:0.78f green:0.78f blue:0.8f alpha:1.0] title:@"备注"];
    
    
    return rightUtilityButtons;
}

#pragma mark - NoteNameViewControllerDelegate
- (void)addressBookUpdateNoteName:(NSString *)note indexPath:(NSIndexPath *)indexPath
{
    _notename = note;
    _nIndexPath = indexPath;
}

#pragma mark - 键盘
/// 显示键盘
-(void)handleKeyboardWillShow:(NSNotification *)paramNotification
{
    CGRect keyboardBounds;
    NSDictionary *userInfo = [paramNotification userInfo];
    [[userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    
    _resultTableView.frame = CGRectMake(0, _navHeight, self.view.frame.size.width, self.view.frame.size.height - _atTop.frame.size.height - _searchBar.frame.size.height - keyboardBounds.size.height);
    
}

/// 隐藏键盘
- (void)handleKeyboardWillHide:(NSNotification *)paramNotification
{
    _resultTableView.frame = CGRectMake(0, _navHeight, self.view.frame.size.width, self.view.frame.size.height - _atTop.frame.size.height - _searchBar.frame.size.height);
}

@end

