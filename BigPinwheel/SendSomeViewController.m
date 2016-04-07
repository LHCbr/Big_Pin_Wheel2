//
//  SendSomeViewController.m
//  leita
//
//  Created by tw001 on 15/5/26.
//
//

#import "SendSomeViewController.h"
//#import "NewFriendsViewController.h"
#import "AddressBookTableViewCell2.h"
#import "AppDelegate.h"
#import "WSocket.h"

@interface SendSomeViewController ()

{
    WSocket *ws;
    NSIndexPath *_selectIndexPath;
}

@end

@implementation SendSomeViewController

- (void)backButtonClick
{
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)addressBook:(NSNotification *)notifi
{
//    int res = [[notifi object] intValue];
//    if (res == 1) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"好友列表刷新完成！" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
//            [alertView show];
//            _refrashState = NO;
//            _refrashCount = 0;
//            _refrashContentLabel.text = @"刷新好友列表";
//            [_timer setFireDate:[NSDate distantFuture]];
//            _refrashImageView.image = [UIImage imageNamed:@"refrash_friend"];
//            _refrashView.backgroundColor = [UIColor whiteColor];
//            
//            UIView *vvv = [self.view viewWithTag:82];
//            if (vvv) { [vvv removeFromSuperview]; }
//        });
//    }else if (res == 2){
//        dispatch_async(dispatch_get_main_queue(), ^{
//            _dataArray = nil;
//            _groups = nil;
//            [_tableView reloadData];
//            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"没有任何好友！" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
//            [alertView show];
//            _refrashState = NO;
//            _refrashCount = 0;
//            _refrashContentLabel.text = @"刷新好友列表";
//            [_timer setFireDate:[NSDate distantFuture]];
//            _refrashImageView.image = [UIImage imageNamed:@"refrash_friend"];
//            _refrashView.backgroundColor = [UIColor whiteColor];
//        });
//    }else{
//        
//        NSMutableDictionary *new_dataArray = [ws getAddressBook];
//        NSMutableArray *new_groups = [ws sortAddressBook:new_dataArray];
//        _dataArray = new_dataArray;
//        _groups = new_groups;
//        NSLog(@"dataArray.count = %d",(int)_dataArray.count);
//        NSLog(@"_groups.count = %d",(int)_groups.count);
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self tipcount];
//            [_tableView reloadData];
//            UIView *vvv = [self.view viewWithTag:82];
//            if (vvv) { [vvv removeFromSuperview]; }
//        });
//    }
}

- (void)getRecentFriendsArray
{
//    NSMutableArray *array = [[NSMutableArray alloc] init];
//    for (Message *mes in ws.msgRemindList) {
//        WJID *wJid = [ws getSingleFriendInfo:mes.phone];
//        if (wJid) {
//            [array addObject:wJid];
//        }
//    }
//    
//    [_dataArray setObject:array forKey:@"#"];
//    [_groups insertObject:@"#" atIndex:0];
//    if (_fromType == FromVideo) {
//        WJID *wjid = [[WJID alloc]init];
//        wjid.nickname = @"我的地图";
//        NSMutableArray *mapArr = [NSMutableArray arrayWithObjects:wjid, nil];
//        [_dataArray setObject:mapArr forKey:@"☆"];
//        [_groups insertObject:@"☆" atIndex:0];
//    }
//
//    [_tableView reloadData];
}
- (void)goAddNewFriend:(UIButton *)btn
{
//    _searchBar.showsCancelButton = NO;
//    [_searchBar resignFirstResponder];
//    [_searchTextField resignFirstResponder];
//    NewAddNFViewController *newAddNFVC = [[NewAddNFViewController alloc] init];
//    [self.navigationController pushViewController:newAddNFVC animated:YES];
    
    //    AddNewViewController *addNewVC = [[AddNewViewController alloc] init];
    //    [self.navigationController pushViewController:addNewVC animated:YES];
}

- (void)newFriends
{
    //    _searchBar.showsCancelButton = NO;
    [_searchTextField resignFirstResponder];
//    NewFriendsViewController *newFVC = [[NewFriendsViewController alloc] init];
//    [self.navigationController pushViewController:newFVC animated:YES];
}

- (void)responseUpdateNoteName:(NSNotification *)notifi
{
//    dispatch_async(dispatch_get_main_queue(), ^{
//        int res = [[notifi object] intValue];
//        if (res >= 0) {
//            if (_nIndexPath.section >= 0 && _nIndexPath.row >= 0) {
//                NSString *key = [_groups objectAtIndex:_nIndexPath.section];
//                NSMutableArray *array = [_dataArray objectForKey:key];
//                WJID *uJid = [array objectAtIndex:_nIndexPath.row];
//                uJid.nickname = _notename;
//                [_tableView reloadData];
//                [[WSocket shareWSocket] getFriendInfo:uJid.phone selectDb:NO];
//            }
//            
//        }else{
//            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"设置备注信息失败" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
//            [alertView show];
//        }
//    });
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _userListDict = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"选择通讯录界面释放");

    [_sendList removeAllObjects];
    self.delegate = nil;
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
}

- (void)setIndexPathZero
{
    _selectIndexPath = [NSIndexPath indexPathForRow:-1 inSection:-1];
}

/// 建群
- (void)createGroupNext
{
    if (_sendList.count <= 0 || _userListDict.count <= 0) {
        return;
    }
    
    [[[WSocket sharedWSocket] lbxManager] showHudViewLabelText:@"创建中..." detailsLabelText:nil afterDelay:15];
    
    NSMutableString *memberList = [[NSMutableString alloc] initWithString:@""];
    NSMutableString *nameList = [[NSMutableString alloc] initWithString:@""];
    
    NSArray *_userList = [[NSMutableArray alloc] initWithArray:[_userListDict allValues]];

    
    for (WJID *uJid in _userList) {
        [memberList appendFormat:@"86%@,",uJid.phone];
        [nameList appendFormat:@"%@,",uJid.nickname];
    }
    NSString *endNameList = [nameList substringToIndex:nameList.length - 1];
    
    WSocket *wwsww = [WSocket sharedWSocket];
    
    NSString *sendMessage = [NSString stringWithFormat:@"%@邀请了%@加入了群",[wwsww.lbxManager stringFromHexString:wwsww.lbxManager.wJid.nickname],endNameList];
    NSLog(@"sendMessage = %@",sendMessage);
    
    NSString *groupName = endNameList;
    if (groupName.length > 15) {
        groupName = [endNameList substringToIndex:15];
    }
    
    [[WSocket sharedWSocket] createNewGroupWithGroupName:groupName groupDesc:@"" memberList:memberList isSuccess:^(int groupId) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (groupId > 0) {
                [[[WSocket sharedWSocket] lbxManager] showHudViewLabelText:@"创建成功" detailsLabelText:nil afterDelay:0.1];
                
                [self.navigationController popToRootViewControllerAnimated:NO];
                
                WJID *uJid = [[WJID alloc] init];
                uJid.phone = [NSString stringWithFormat:@"%dQ",groupId];
                uJid.nickname = groupName;
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"goChat" object:uJid];
                
                [wwsww sendText:sendMessage foreignUser:[NSString stringWithFormat:@"%dQ",groupId] area:@"86" messageType:LBX_IM_DATA_TYPE_SYSTEM destoryTime:0 serialIndex:[wwsww getSerialId]];
                
            } else {
                NSString *str = @"群创建失败，请稍后重试";
                if (groupId == -3) {
                    str = @"群名字已经存在";
                } else if (groupId == -99) {
                    str = @"网络连接失败";
                }
                [[[WSocket sharedWSocket] lbxManager] showHudViewLabelText:str detailsLabelText:nil afterDelay:1];
            }
        });
    }];
    
}

/// 群发图片
- (void)sendSomeData
{
    if (_sendList.count <= 0) {
        return;
    }
    if (_delegate) {
        [_delegate sendEndImage:_sendImage destoryTime:_destoryTime sendList:_sendList sendNickname:_names];
    }
    [self.navigationController popToRootViewControllerAnimated:YES];
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
//    [app.messageVC.subScrollView setContentOffset:CGPointMake(0, 0)];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _sendList = [NSMutableArray array];
    
    
    _sendList = [[NSMutableArray alloc] init];
    _sendSearchList = [[NSMutableArray alloc]init];
    
    [self setIndexPathZero];
    
    _isSearch = NO;
    
    float tHeight = 20.0f;

    _atTop = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, tHeight)];
    _atTop.backgroundColor = [UIColor whiteColor];
    _atTop.hidden = YES;
    [self.view addSubview:_atTop];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    // 通知中心键盘即将显示时刻触发事件
    [center addObserver:self selector:@selector(handleKeyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    // 通知中心键盘即将消失时刻触发事件
    [center addObserver:self selector:@selector(handleKeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, _atTop.frame.size.height, self.view.frame.size.width, 44)];
    _searchBar.placeholder = @"请输入昵称";
    _searchBar.delegate = self;
    _searchBar.hidden = YES;
    _searchBar.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_searchBar];
    
    NSString *str = @"发送至...";
    if (_fromType == FromCreateGroup) {
        str = @"选择联系人";
    } else if (_fromType == FromGroupAddMember) {
        str = @"Add Participant...";
    }
    
    NAVBAR(str);
    self.view.backgroundColor = [UIColor whiteColor];
    _navHeight = 64.0;


    if (_fromType == FromCreateGroup) {

        UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(sendBtnClicked:)];
        self.navigationItem.rightBarButtonItem = rightButton;
    }
    
    _nIndexPath = [NSIndexPath indexPathForRow:-1 inSection:-1];
    
    ws = [WSocket sharedWSocket];
    _dataArray = [ws getAddressBook];
    _groups = [ws sortAddressBook:_dataArray];
    
    float catHeight = 0;
    
    if (_fromType != FromGroupAddMember) {
        [self getRecentFriendsArray];
        catHeight = 56;
    }
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, _navHeight, self.view.frame.size.width, self.view.frame.size.height - _navHeight-catHeight) style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40 + 0.5)];
    
    float searchBarWidth = self.view.frame.size.width - 15;

    _searchTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, 0, searchBarWidth - 20, 40)];
    _searchTextField.placeholder = @"搜索";
    _searchTextField.delegate = self;
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 10, 25, 20)];
    UIImageView *searchImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 19, 18)];
    searchImageView.image = [UIImage imageNamed:@"nn_ditu_sousuo"];
    [leftView addSubview:searchImageView];
    _searchTextField.leftView = leftView;
    _searchTextField.leftViewMode = UITextFieldViewModeAlways;
    _searchTextField.backgroundColor = [UIColor whiteColor];
    [headerView addSubview:_searchTextField];
    
    UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(0, 40, self.view.frame.size.width, 0.5)];
    line1.backgroundColor = COLOR(235, 235, 235, 1);
    [headerView addSubview:line1];
    
    _refrashState = NO;
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(detectionRefrash) userInfo:nil repeats:YES];
    [_timer setFireDate:[NSDate distantFuture]];
    
    _tableView.tableHeaderView = headerView;
    _tableView.tableFooterView = [[UIView alloc] init];
    
    _resultTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, _navHeight, self.view.frame.size.width, self.view.frame.size.height - _navHeight-catHeight)];
    _resultTableView.dataSource = self;
    _resultTableView.delegate = self;
    _resultTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _resultTableView.hidden = YES;
    [self.view addSubview:_resultTableView];
    
    if (_fromType == FromGroupAddMember) {
        return;
    }
    
    UIView *selectedView = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height - 56, self.view.frame.size.width, 56)];
    selectedView.backgroundColor = COLOR(3, 165, 136, 1);
    [self.view addSubview:selectedView];

    _namesLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width-56, 56)];
    _namesLabel.backgroundColor = [UIColor clearColor];
    _namesLabel.textColor = [UIColor whiteColor];
    _namesLabel.textAlignment = NSTextAlignmentLeft;
    [selectedView addSubview:_namesLabel];
    
    UIButton *sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    sendBtn.frame =  CGRectMake(self.view.frame.size.width-56, 0, 56, 56);
    [sendBtn setImage:[UIImage imageNamed:@"tuya_queding"] forState:UIControlStateNormal];
    [sendBtn addTarget:self action:@selector(sendBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [selectedView addSubview:sendBtn];
    
    if (_fromType == FromVideo) {
        _names = @"我的地图";
        CGRect rect = [_names boundingRectWithSize:CGSizeMake(1000, 56) options:NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]} context:nil];
//        _namesLabel.frame = CGRectMake((kWidth-56)-rect.size.width, 0, rect.size.width, 56);
        _namesLabel.text = _names;
        [_sendList addObject:@"我的地图"];
    }else{
        _names = @"";
    }
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
    if (_refrashState == NO) {
        
        }else{
            [_timer setFireDate:[NSDate date]];
            _refrashState = YES;
            _refrashContentLabel.text = @"正在刷新中...";
            _refrashView.backgroundColor = COLOR(38, 165, 162, 1);
//            _refrashImageView.image = [UIImage imageNamed:@"refrash_friend_high"];
            
            //            [ws refrashFriendList];
    }
}

- (void)detectionRefrash
{
    _refrashCount++;
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
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    _searchBar.showsCancelButton = YES;
//    if (isIos7) {
        UIView *view = [searchBar.subviews objectAtIndex:0];
        UIButton *cancelButton = [view.subviews objectAtIndex:2];
        [cancelButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
//    }
    
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchText.length > 0) {
        _resultTableView.hidden = NO;
        _resultDataArray = [[WSocket sharedWSocket] fuzzySearchFriends:searchText];
        [_resultTableView reloadData];
    }else{
        _resultTableView.hidden = YES;
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    _isSearch = NO;
    _tableView.hidden = NO;
    [_HUD hide:YES];
    [_timer setFireDate:[NSDate distantFuture]];
    _searchBar.showsCancelButton = NO;
    [_searchBar resignFirstResponder];
    [UIView animateWithDuration:.3 animations:^{
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationCurve:7];
        _aNav.frame = CGRectMake(0, 0, self.aNav.frame.size.width, self.aNav.frame.size.height);
        _atTop.hidden = YES;
        _searchBar.hidden = YES;
        _resultTableView.hidden = YES;
    }];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [_searchBar resignFirstResponder];
}

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
        NSString *identifier = @"xuanzhong";
        SendSomeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[SendSomeTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.nikeNameLabel.text = wJid.nickname;
        [cell.selectedBtn setImage:[UIImage imageNamed:@"tongxun_weixuanzhong"] forState:UIControlStateNormal];
        [cell.selectedBtn setImage:[UIImage imageNamed:@"tongxun_xuanzhong"] forState:UIControlStateSelected];
        [cell.selectedBtn addTarget:self action:@selector(changeState:) forControlEvents:UIControlEventTouchUpInside];
        cell.selectedBtn.tag = indexPath.section*10000+indexPath.row;
       
        if ([wJid.sex isEqualToString:@"男"]) {
            [cell.sexImgView setImage:[UIImage imageNamed:@"tongxun_nan"] forState:UIControlStateNormal];
            cell.nikeNameLabel.textColor = [UIColor blackColor];
        } else if ([wJid.sex isEqualToString:@"女"]){
            [cell.sexImgView setImage:[UIImage imageNamed:@"tongxun_nv"] forState:UIControlStateNormal];
            cell.nikeNameLabel.textColor = [UIColor blackColor];
        }else{
            [cell.sexImgView setImage:nil forState:UIControlStateNormal];
            cell.nikeNameLabel.textColor = [UIColor redColor];
        }
        
        if ([_sendList containsObject:wJid.phone]) {
            cell.selectedBtn.selected = YES;
        }else{
            cell.selectedBtn.selected = NO;
            if (_fromType == FromVideo) {
                if ([_sendList containsObject:@"我的地图"]&&[wJid.nickname isEqualToString:@"我的地图"]&&wJid.phone.length <= 0) {
                    cell.selectedBtn.selected = YES;
                }
            }
        }
        
        if (_fromType == FromGroupAddMember) {
            [cell.selectedBtn setHidden:YES];
            
            if ([self isContainsObjectFromPhone:wJid.phone]) {
                cell.userInteractionEnabled = NO;
                cell.nikeNameLabel.textColor = [UIColor lightGrayColor];
            } else {
                if ([wJid.sex isEqualToString:@"男"] || [wJid.sex isEqualToString:@"女"]) {
                    cell.userInteractionEnabled = YES;
                    cell.nikeNameLabel.textColor = [UIColor blackColor];
                }
            }
        }
        
        return cell;
    }else{
        static NSString *identifier = @"search_friends_cell";
        WJID *wJid = [_resultDataArray objectAtIndex:indexPath.row];
        SendSomeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil) {
            cell = [[SendSomeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.nikeNameLabel.text = wJid.nickname;
        [cell.selectedBtn setImage:[UIImage imageNamed:@"tongxun_weixuanzhong"] forState:UIControlStateNormal];
        [cell.selectedBtn setImage:[UIImage imageNamed:@"tongxun_xuanzhong"] forState:UIControlStateSelected];
        [cell.selectedBtn addTarget:self action:@selector(changeSearchResultState:) forControlEvents:UIControlEventTouchUpInside];
        cell.selectedBtn.tag = 10*indexPath.row;
        if ([wJid.sex isEqualToString:@"男"]) {
            [cell.sexImgView setImage:[UIImage imageNamed:@"tongxun_nan"] forState:UIControlStateNormal];
            cell.nikeNameLabel.textColor = [UIColor blackColor];
        } else if ([wJid.sex isEqualToString:@"女"]){
            [cell.sexImgView setImage:[UIImage imageNamed:@"tongxun_nv"] forState:UIControlStateNormal];
            cell.nikeNameLabel.textColor = [UIColor blackColor];
        }else{
            [cell.sexImgView setImage:nil forState:UIControlStateNormal];
            cell.nikeNameLabel.textColor = [UIColor redColor];
        }
        
        if ([_sendList containsObject:wJid.phone]) {
            cell.selectedBtn.selected = YES;
        }else{
            cell.selectedBtn.selected = NO;
        }
        if (_fromType == FromGroupAddMember) {
            [cell.selectedBtn setHidden:YES];
            
            if ([self isContainsObjectFromPhone:wJid.phone]) {
                cell.userInteractionEnabled = NO;
                cell.nikeNameLabel.textColor = [UIColor lightGrayColor];
            } else {
                if ([wJid.sex isEqualToString:@"男"] || [wJid.sex isEqualToString:@"女"]) {
                    cell.userInteractionEnabled = YES;
                    cell.nikeNameLabel.textColor = [UIColor blackColor];
                }
            }
        }
        return cell;
    }
}

/// 获取这个人的phone和已经加入群组的所有的人的iphone进行比对
- (BOOL)isContainsObjectFromPhone:(NSString *)phone
{
    if ([_memberList containsObject:phone]) {
        return YES;
    }
    return NO;
}

#pragma mark --- 搜索页面的搜索状态的改变
- (void)changeSearchResultState:(UIButton *)sender
{
    [_searchBar endEditing:YES];
    WJID *wjid = [_resultDataArray objectAtIndex:sender.tag/10];
    if (_fromType == FromCreateGroup) {
        if (![wjid.sex isEqualToString:@"男"] && ![wjid.sex isEqualToString:@"女"]) {
            return;
        }
    }
    if (sender.selected) {
        [self removeNamesWithWjid:wjid];
        [_sendList removeObject:wjid.phone];
    }else{
        [self addnamesWithWjid:wjid];
        [_sendList addObject:wjid.phone];
    }

    CGRect rect = [_names boundingRectWithSize:CGSizeMake(1000, 56) options:NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]} context:nil];
    _namesLabel.frame = CGRectMake((self.view.frame.size.width-56)-rect.size.width, 0, rect.size.width, 56);
    _namesLabel.text = _names;
    
    [_tableView reloadData];
    sender.selected = !sender.selected;

}
- (void)changeState:(UIButton *)sender
{
    long  section = sender.tag/10000;
    NSString *key = @"null";
    if (_groups.count > section) {
        key = [_groups objectAtIndex:section];
    }
    
    NSMutableArray *array = [_dataArray objectForKey:key];
    WJID *wJid = [[WJID alloc] init];
   
    wJid = [array objectAtIndex:sender.tag%10000];
    
    if (_fromType == FromCreateGroup) {
        if (![wJid.sex isEqualToString:@"男"] && ![wJid.sex isEqualToString:@"女"]) {
            return;
        }
    }
    
    NSLog(@"%@",wJid.nickname);
    if (sender.selected) {
        [self removeNamesWithWjid:wJid];
        if (![wJid.nickname isEqualToString:@"我的地图"]) {
            [_sendList removeObject:wJid.phone];
        }else{
            [_sendList removeObject:@"我的地图"];
        }
        
        
    }else{
        [self addnamesWithWjid:wJid];
        if (![wJid.nickname isEqualToString:@"我的地图"]) {
            [_sendList addObject:wJid.phone];
        }else{
            [_sendList addObject:@"我的地图"];
        }
    }
    
    CGRect rect = [_names boundingRectWithSize:CGSizeMake(1000, 56) options:NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]} context:nil];
    _namesLabel.frame = CGRectMake((self.view.frame.size.width-56)-rect.size.width, 0, rect.size.width, 56);
    _namesLabel.text = _names;
    
    [_tableView reloadData];
    sender.selected = !sender.selected;
}
#pragma mark----- 移除姓名从发送条
- (void)removeNamesWithWjid:(WJID *)wJid
{
    NSArray *arr = [_names componentsSeparatedByString:@","];
    if (arr.count == 1) {
        _names = [_names stringByReplacingOccurrencesOfString:wJid.nickname withString:@""];
    }else if (arr.count > 1){
        if ([[arr firstObject] isEqualToString:wJid.nickname]) {
            _names = [_names stringByReplacingOccurrencesOfString:[wJid.nickname stringByAppendingString:@","] withString:@""];
        }else{
            _names = [_names stringByReplacingOccurrencesOfString:[@"," stringByAppendingString:wJid.nickname] withString:@""];
        }
    }
    
    if (_fromType == FromCreateGroup) {
        [_userListDict removeObjectForKey:wJid.phone];
    }
}

#pragma mark -- 添加姓名到发送条
- (void)addnamesWithWjid:(WJID *)wJid
{
    if (![_names isEqualToString:@""]) {
        _names = [_names stringByAppendingString:@","];
    }
    _names = [_names stringByAppendingString:wJid.nickname];
    
    if (_fromType == FromCreateGroup) {
        [_userListDict setObject:wJid forKey:wJid.phone];
    }
}

#pragma mark - uialertViewDelgate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
//    if (buttonIndex == alertView.cancelButtonIndex) {
//        [_tableView reloadData];
//        return;
//    }
//    
//    if (alertView.tag == 54) {
//        WJID *wJid = [[WJID alloc] init];
//        
//        if (_isSearch == NO) {
//            NSString *key = @"null";
//            if (_groups.count > _selectIndexPath.section) {
//                key = [_groups objectAtIndex:_selectIndexPath.section];
//            }
//            NSMutableArray *array = [_dataArray objectForKey:key];
//            if (array.count > _selectIndexPath.row) {
//                wJid = [array objectAtIndex:_selectIndexPath.row];
//            }
//        } else {
//            wJid = [_resultDataArray objectAtIndex:_selectIndexPath.row];
//        }
//        
//        [self setIndexPathZero];
//        
//        __block SendSomeViewController *weakSelf = self;
//        __block NSString *aGroupId = self.groupId;
//                
//        [ws addFriendMemberWithGroupId:_groupId memberId:[NSString stringWithFormat:@"%@,",wJid.phone] isSuccess:^(int ret) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                if (ret == -3) {
//                    [[WSocket sharedWSocket] showHudViewLabelText:@"此群不存在" detailsLabelText:nil afterDelay:1];
//                } else if (ret == -1) {
//                    [[WSocket sharedWSocket] showHudViewLabelText:@"邀请出错" detailsLabelText:nil afterDelay:1];
//                } else if (ret == -99) {
//                    [[WSocket sharedWSocket] showHudViewLabelText:@"网络连接失败" detailsLabelText:nil afterDelay:1];
//                } else {
//                    [[WSocket sharedWSocket] getGroupMemberList:aGroupId lastId:@"0"];
//                    [weakSelf backButtonClick];
//                    
//                    int mIndex = [[WSocket shareWSocket] getIndex];
//                    
//                    [[WSocket shareWSocket] sendMsgToUser:aGroupId mType:MsgSystemTip msg:[NSString stringWithFormat:@"%@邀请了%@进群",[WSocket shareWSocket].wJid.nickname,wJid.nickname] destroyImageTime:0 mmid:mIndex foreignNickname:[WSocket shareWSocket].wJid.nickname foreignAvatar:nil];
//                }
//            });
//        }];
//    }
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
        view.backgroundColor = [UIColor whiteColor];
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 100, 20)];
        NSString *headerTitle = [_groups objectAtIndex:section];
        if ([headerTitle isEqualToString:@"#"]) {
            headerTitle = @"最近的";
        }
        titleLabel.text = headerTitle;
        titleLabel.font = [UIFont systemFontOfSize:14.0f];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = COLOR(36, 157, 117, 1);
        [view addSubview:titleLabel];
        return view;
    }else{
        return nil;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _tableView) {////这里目的是实现点击cell也能选中，点击选中按钮也能选中
        SendSomeTableViewCell *cell = (SendSomeTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        [self changeState:cell.selectedBtn];
    }
    
    if (_fromType == FromGroupAddMember) {
        _selectIndexPath = indexPath;
        WJID *wJid = [[WJID alloc] init];
        
        if (_isSearch == NO) {
            NSString *key = @"null";
            if (_groups.count > indexPath.section) {
                key = [_groups objectAtIndex:indexPath.section];
            }
            NSMutableArray *array = [_dataArray objectForKey:key];
            if (array.count > indexPath.row) {
                wJid = [array objectAtIndex:indexPath.row];
            }
        } else {
            wJid = [_resultDataArray objectAtIndex:indexPath.row];
        }
        
        if (![wJid.sex isEqualToString:@"男"] && ![wJid.sex isEqualToString:@"女"]) {
            return;
        }
        
        NSString *str = [NSString stringWithFormat:@"确定邀请%@加入?",wJid.nickname];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:str delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alert.tag = 54;
        [alert show];
    }
}

- (void)sendBtnClicked:(UIButton *)sender
{
    if (_fromType == FromVideo) {///如果是视频就发送到地图，不管有没有选择好友
//        GDMapManager *gdMap = [GDMapManager sharedGDMapManager];
//        NSString *resultPath = [_path stringByReplacingOccurrencesOfString:@".mp4" withString:@"-output.mp4"];
//        gdMap.uploadLock = YES;   ///把上传锁打开
//        ///上传视频到地图
//       [[WSocket shareWSocket]sendVideo:_videoName filePath:resultPath latitude:gdMap.lastCoor.latitude longtitude:gdMap.lastCoor.longitude];
//        
//        AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
//
//        [self.navigationController popToRootViewControllerAnimated:YES];
//    
//        [app.messageVC.subScrollView setContentOffset:CGPointMake(self.view.frame.size.width*2, 0)];
//        app.rootVC.mapManager.isFromSendVideo = YES;
//        [app.rootVC.mapManager updateMapVideoAnnotationWithVideos:app.rootVC.mapManager.movieArray tag:@"video"];///开始更新地图上的视频
//        
    }else{
        if (_fromType == FromCreateGroup) {
            [self createGroupNext];
        } else {
            [self sendSomeData];
        }
    }
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
