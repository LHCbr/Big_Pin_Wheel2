//
//  GroupMemberListViewController.m
//  leita
//
//  Created by a on 7/22/15.
//
//

#import "GroupMemberListViewController.h"
#import "AddressBookTableViewCell.h"
#import "AppDelegate.h"
#import "SendSomeViewController.h"
#import "WSocket.h"

@interface GroupMemberListViewController ()
@property (assign, nonatomic) NSInteger deleteRow;
@property (assign, nonatomic) BOOL isSelfCreate;
@end

@implementation GroupMemberListViewController

- (void)dealloc
{
    NSLog(@"Member List 界面释放");
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _isSelfCreate = NO;
        _userList = [[NSMutableArray alloc] init];
        _memberList = [[NSMutableArray alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getGroupMemberListRet:) name:kGetGroupMemberListRet object:nil];
    }
    return self;
}

/// 获取群的人员列表回调
- (void)getGroupMemberListRet:(NSNotification *)noti
{
    NSDictionary *dict = [noti object];
    _userList = [dict objectForKey:@"dataArray"];
    _memberList = [dict objectForKey:@"memberList"];
    if (_userList.count) {
        WJID *wJid = [_userList firstObject];
        WSocket *ws = [WSocket sharedWSocket];
        if ([wJid.phone isEqualToString:ws.lbxManager.wJid.phone]) {
            _isSelfCreate = YES;
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [_tableView reloadData];
    });
}

- (void)backButtonClick
{
    [self.navigationController popViewControllerAnimated:NO];
}

/// 添加成员
- (void)AddMemberClick:(UIButton *)sender
{
    SendSomeViewController *sendVC = [[SendSomeViewController alloc] init];
    sendVC.fromType = FromGroupAddMember;
    sendVC.groupId = _groupId;
    sendVC.memberList = _memberList;
    [self.navigationController pushViewController:sendVC animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NAVBAR(@"群聊信息");
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Add" style:UIBarButtonItemStylePlain target:self action:@selector(AddMemberClick:)];

    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64.0, self.view.frame.size.width, self.view.frame.size.height - 64.0) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    _tableView.tableFooterView = [[UIView alloc] init];
    
    [self addExitGroupLabel];
    
}

/// 添加退出群按钮
- (void)addExitGroupLabel
{
    // 退出按钮
    UIView *logOutView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 36)];
    logOutView.backgroundColor = [UIColor lightGrayColor];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0.5, self.view.frame.size.width, 35);
    btn.backgroundColor = [UIColor whiteColor];
    [btn setTitle:@"Delete and Exit" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(deleteAndExit) forControlEvents:UIControlEventTouchUpInside];
    [logOutView addSubview:btn];
    
    _tableView.tableFooterView = logOutView;
}

/// 退出群
- (void)deleteAndExit
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"You will delete and exit this group." delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete and Exit" otherButtonTitles:nil, nil];
    actionSheet.tag = 14;
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 14) {
        if (buttonIndex == 0) {
            [[WSocket sharedWSocket] exitGroupWithGroupId:_groupId isSuccess:^(int ret) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSString *str = @"退群成功";
                    switch (ret) {
                        case -1:
                            str = @"退群失败";
                            break;
                        case -3:
                            str = @"你要退出的群不存在";
                            break;
                        case -4:
                            str = @"你不在该群";
                            break;
                        case -99:
                            str = @"网络连接失败";
                        default:
                            break;
                    }
                    
                    
                    if (ret == -99) {
                        [[WSocket sharedWSocket] showHudViewLabelText:@"网络连接失败" detailsLabelText:nil afterDelay:1];
                        return;
                    }
                    
                    if (ret >= 0) {
                        AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;

                        dispatch_time_t time1 = dispatch_time(DISPATCH_TIME_NOW, (0.1 * NSEC_PER_SEC));
                        dispatch_after(time1, dispatch_get_main_queue(), ^{
//                            [[WSocket sharedWSocket] delFriendChatMsg:_groupId removeFrom:3];
                            [self.navigationController popToRootViewControllerAnimated:NO];
//                            [app.messageVC.chatVC backButtonClick];
                        });

                        
                        dispatch_time_t time2 = dispatch_time(DISPATCH_TIME_NOW, (0.35 * NSEC_PER_SEC));
                        dispatch_after(time2, dispatch_get_main_queue(), ^{
//                            if ([app.messageVC.chatVC.msgTextView isFirstResponder]) {
//                                [app.messageVC.chatVC.msgTextView resignFirstResponder];
//                            }
                        });
                    }
                });
            }];
        }
    }
}

#pragma mark - Table view datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [_userList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"user_list_cell";
    AddressBookTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[AddressBookTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    WJID *uJid = [_userList objectAtIndex:indexPath.row];
    if ([uJid.sex isEqualToString:@"男"]) {
        [cell.avatarButton setImage:kDefaultAvatarImage forState:UIControlStateNormal];
    } else {
        [cell.avatarButton setImage:kDefaultAvatarImage forState:UIControlStateNormal];
        
    }
    cell.contentLabel.text = uJid.nickname;
    cell.contentLabel.textColor = [UIColor blackColor];
//    [cell.chatButton setHidden:NO];
//    [cell.deleteButton setHidden:NO];
//    cell.chatButton.tag = indexPath.row;
//    cell.deleteButton.tag = indexPath.row;
//    [cell.chatButton addTarget:self action:@selector(chatButtonClick:) forControlEvents:UIControlEventTouchUpInside];
//    [cell.deleteButton addTarget:self action:@selector(deleteButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    if (_isSelfCreate) {
        if ([uJid.phone isEqualToString:[[WSocket sharedWSocket] lbxManager].wJid.phone]) {
            cell.contentLabel.textColor = COLOR(36, 157, 117, 1);
            [cell.chatButton setHidden:YES];
            [cell.deleteButton setHidden:YES];
        }
    } else {
        [cell.deleteButton setHidden:YES];
        if ([uJid.phone isEqualToString:[[WSocket sharedWSocket] lbxManager].wJid.phone]) {
            cell.contentLabel.textColor = COLOR(36, 157, 117, 1);
            [cell.chatButton setHidden:YES];
        }
    }
    
    if (indexPath.row == 0) {
        cell.contentLabel.textColor = COLOR(36, 157, 117, 1);
        cell.contentLabel.text = [NSString stringWithFormat:@"%@ -- 创建者",uJid.nickname];
    }

    return cell;
}

#pragma mark - Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 56.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WJID *uJid = [_userList objectAtIndex:indexPath.row];
    if ([uJid.phone isEqualToString:[[WSocket sharedWSocket] lbxManager].wJid.phone]) {
        return;
    }
    [self.navigationController popToRootViewControllerAnimated:NO];
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (uJid.phone.length) {
        int sex = 1;
        if ([uJid.sex isEqualToString:@"女"]) {
            sex = 2;
        }
        
        
//        [app.messageVC jumpChatWithPhone:uJid.phone nickname:uJid.nickname foreignHeadPortrait:@"" animation:YES sex:sex];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return NO;
    }
    
    if (!_isSelfCreate) {
        return NO;
    }
    return YES;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        _deleteRow = indexPath.row;
        WJID *wJid = [_userList objectAtIndex:indexPath.row];
        
        NSString *message = [NSString stringWithFormat:@"确定要移除%@",wJid.nickname];
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        av.tag = 45;
        [av show];
        return;
    }
}

/// 聊天
- (void)chatButtonClick:(UIButton *)sender
{
    WJID *wJid = [_userList objectAtIndex:sender.tag];
    
    [self.navigationController popToRootViewControllerAnimated:NO];
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (wJid.phone.length) {
        int sex = 1;
        if ([wJid.sex isEqualToString:@"女"]) {
            sex = 2;
        }
//        [app.messageVC jumpChatWithPhone:wJid.phone nickname:wJid.nickname foreignHeadPortrait:@"" animation:YES sex:sex];
    }
}

/// 移除群组
- (void)deleteButtonClick:(UIButton *)sender
{
    _deleteRow = sender.tag;
    WJID *wJid = [_userList objectAtIndex:sender.tag];

    NSString *message = [NSString stringWithFormat:@"确定要移除%@",wJid.nickname];
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    av.tag = 45;
    [av show];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == alertView.cancelButtonIndex) {
        return;
    }
    
    __block NSMutableArray *weakArray = _userList;
    __block UITableView *weakTableView = _tableView;
    
    if (alertView.tag == 45) {
        WJID *wJid = [_userList objectAtIndex:_deleteRow];
        [[WSocket sharedWSocket] removeOneMember:wJid.phone fromGroupId:_groupId isSuccess:^(int ret) {
            NSLog(@"移除某人出群");
            dispatch_async(dispatch_get_main_queue(), ^{
                if (ret == -3) {
                    [[WSocket sharedWSocket] showHudViewLabelText:@"你没有权限" detailsLabelText:nil afterDelay:1];
                } else if (ret == -1) {
                    [[WSocket sharedWSocket] showHudViewLabelText:@"移除出错" detailsLabelText:nil afterDelay:1];
                } else if (ret == -99) {
                    [[WSocket sharedWSocket] showHudViewLabelText:@"网络连接失败" detailsLabelText:nil afterDelay:1];
                } else {
                    [weakArray removeObjectAtIndex:_deleteRow];
                    [weakTableView reloadData];
                    
                    NSString *mIndex = [[WSocket sharedWSocket] getSerialId];
                    
                    WSocket *ws = [WSocket sharedWSocket];
                    
                    [ws sendText:[NSString stringWithFormat:@"%@移除了%@", ws.lbxManager.wJid.nickname,wJid.nickname] foreignUser:_groupId area:@"86" messageType:LBX_IM_DATA_TYPE_SYSTEM destoryTime:0 serialIndex:mIndex];
                    

                }
            });
        }];
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
