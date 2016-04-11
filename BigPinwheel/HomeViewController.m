//
//  HomeViewController.m
//  BigPinwheel
//
//  Created by 徐伟 on 16/1/19.
//  Copyright © 2016年 leita. All rights reserved.
//

#import "HomeViewController.h"
#import "MainNoticeCell.h"
#import "ChatListCell.h"
#import "InscriptionManager.h"
#import "BussinessContactViewController.h"
#import "LoginHomeViewController.h"
#import "UserInfoViewController.h"
#import "ChatViewController.h"
#import "WSocket.h"
#import "NearMessageObject.h"

@interface HomeViewController ()
@property(strong,nonatomic)InscriptionManager *inspManager;
@property(strong,nonatomic)WSocket *wSocket;

@end
#pragma mark -本类接受的通知

@implementation HomeViewController
///刷新列表
-(void)refreshNearMessgaeList:(NSNotification *)noti
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [_tableView reloadData];
    });
}

///网络发生变化
-(void)networkChange:(NSNotification *)noti
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"网络发生变化了");
        [[WSocket sharedWSocket] connectToServerAndLogin];
    });
}

///进入聊天室
-(void)goChat:(NSNotification *)noti
{
    dispatch_async(dispatch_get_main_queue(), ^{
        WJID *uJid = [noti object];
        if (uJid)
        {
            [self goChatVC:uJid isSelectedInexPath:NO];
        }
    });
}

///连接状态的更改
-(void)updateOnlineStatus:(NSNotification *)noti
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        int select = [[noti object]intValue];
        if (select ==1) {
            self.navigationController.title = @"消息";
        }
        else
        {
            self.navigationItem.title = @"消息(未连接)";
        }
        
    });
}

/*登陆成功 获取最新的最近聊天列表*/
-(void)loginSuccess:(NSNotification *)noti
{
    dispatch_async(dispatch_get_main_queue(), ^{
        MBProgressHUD *hud = [self creatNavBarMBPHud];
        if (_wSocket.nearMessageList.count <=0) {
            self.navigationItem.title = @"接受中...";
            _wSocket.nearMessageList = [[NSMutableArray alloc]initWithArray:[_wSocket.lbxManager getAllMessage]];
            [_tableView reloadData];
        }
        self.navigationItem.title = @"消息";
        [hud hide:YES afterDelay:0.5];
    });
}

///退出登陆成功
-(void)logOutNotification:(NSNotification *)noti
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [_wSocket.nearMessageList removeAllObjects];
        [_tableView reloadData];
    });
}

///更新角标
-(void)badgeChange:(NSNotification *)noti
{
    int count = 0;
    
    for (NearMessageObject *object in _wSocket.nearMessageList)
    {
        if (object.noReadCount >0)
        {
            count += object.noReadCount;
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (count >0)
        {
            self.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d",count];
            self.navigationItem.title = [NSString stringWithFormat:@"消息(%d)",count];
        }else
        {
            self.tabBarItem.badgeValue = nil;
            self.navigationItem.title = @"消息";
        }
    });
}

- (void)dealloc
{
    NSLog(@"消息界面释放");
    
    [_wSocket.nearMessageList removeAllObjects];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_tableView reloadData];
    [self badgeChange:nil];
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
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(networkChange:) name:kNetworkChange object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(loginSuccess:) name:kLoginSuccess object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshNearMessgaeList:) name:kRefreshNearMessageList object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(goChat:) name:@"goChat" object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateOnlineStatus:) name:kUpdateOnlineStatus object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(badgeChange:) name:kBadgeChange object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(logOutNotification:) name:kLogOutNotification object:nil];
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kDeviceWidth, kDeviceHeight) style:UITableViewStylePlain];
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.estimatedRowHeight = kCellHeight;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.tableHeaderView = [[UIView alloc]init];
    _tableView.tableFooterView = [[UIView alloc]init];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
    
    MBProgressHUD *hud = [self creatNavBarMBPHud];
    _wSocket.nearMessageList = [[NSMutableArray alloc]initWithArray:[_wSocket.lbxManager getAllMessage]];
    [hud hide:YES afterDelay:0.5];
    
}

#pragma mark - View创建工具
-(MBProgressHUD *)creatNavBarMBPHud
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.navigationBar animated:YES];
    hud.margin = 0.5;
    hud.xOffset = -50;
    hud.dimBackground = NO;
    hud.color = [UIColor clearColor];
    hud.activityIndicatorColor = [UIColor purpleColor];
    hud.transform = CGAffineTransformMakeScale(0.57,0.57);
    hud.removeFromSuperViewOnHide = NO;
    
    return hud;
}

#pragma mark - 点击事件
-(void)goChatVC:(WJID *)uJid isSelectedInexPath:(BOOL)isSelected
{
    if (isSelected ==NO)
    {
        for (NSInteger i= _wSocket.nearMessageList.count -1; i>=0; i--)
        {
            NearMessageObject *object = [_wSocket.nearMessageList objectAtIndex:i];
            if ([object.phone isEqualToString:uJid.phone]) {
                object.noReadCount = -1;
                [_wSocket saveNearMessageWithObject:object];
                break;
            }
        }
        [_tableView reloadData];
    }
    
    ChatViewController *chatVC = [[ChatViewController alloc]init];
    chatVC.uJid = uJid;
    [chatVC createDirectory:uJid.phone];
    chatVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:chatVC animated:YES];
   
}

#pragma mark - UITabelViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kCellHeight;
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kCellHeight;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row==0) {
        BussinessContactViewController *BussContactVC = [[BussinessContactViewController alloc]init];
        [self.navigationController pushViewController:BussContactVC animated:YES];
    }
    else
    {
        NearMessageObject *object =[_wSocket.nearMessageList objectAtIndex:indexPath.row-1];
        object.noReadCount = -1;
        [_wSocket saveNearMessageWithObject:object];
        
        WJID *uJid = [[WJID alloc]init];
        uJid = [_wSocket.lbxManager getUserInfoWithPhone:object.phone];
        
        [self goChatVC:uJid isSelectedInexPath:YES];
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *str = [NSString stringWithFormat:@"%@",@"删除"];
    return str;
}



#pragma mark - UITableViewDataSource

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *notiIdentifier = @"notiIdenitfy";
    static NSString *chatlistIdentifier = @"chatlistIdentify";
    if (indexPath.row==0) {
        MainNoticeCell *cell = [tableView dequeueReusableCellWithIdentifier:notiIdentifier];
        if (cell==nil) {
            cell = [[MainNoticeCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:notiIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        }
        [cell.avatarView setImage:[UIImage imageNamed:@"0219_teamIcon"]];
        cell.lastMSGLabel.text = @"欢迎来到大丰车团队";
        return cell;
    }
    else
    {
        ChatListCell *cell = [tableView dequeueReusableCellWithIdentifier:chatlistIdentifier];
        if (cell ==nil) {
            cell = [[ChatListCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:chatlistIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            cell.showsReorderControl = YES;
        }
        
        [cell.tipLabel setHidden:YES];
        
        NearMessageObject *object = [_wSocket.nearMessageList objectAtIndex:indexPath.row-1];
        
        __weak WSocket *weakSocket = _wSocket;
        __weak ChatListCell *weakCell = cell;
        
        [_wSocket addDownFileOperationWithFileUrlString:object.avatarUrl serialId:@"-1" modelType:ModelTypeNormal info:nil downBlock:^(int ret, int isSave, NSData *data, NSString *fileUrl) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (ret>=0) {
                    
                    [weakCell.avatarView setImage:[UIImage imageWithData:data]];
                    
                    if (isSave) {
                        [data writeToFile:[NSString stringWithFormat:@"%@%@",kPathAvatar,[weakSocket.lbxManager upper16_MD5:fileUrl]] atomically:YES];
                    }
                }
                else
                {
                    [weakCell.avatarView setImage:kDefaultAvatarImage];
                }
            });
            
        }];
        
        [cell.nameLabel setText:[_wSocket.lbxManager stringFromHexString:object.nickname]];
        if ([object.nickname isEqualToString:@"(null)"]||object.nickname.length<=0)
        {
            
            NSMutableString *nickStr = [[NSMutableString alloc]initWithString:object.phone];
            
            if (nickStr.length ==11)
            {
                [nickStr insertString:@"-" atIndex:nickStr.length-4];
                [nickStr insertString:@"-" atIndex:3];
            }
            
            NSString *nickname = [NSString stringWithFormat:@"+86 %@",nickStr];
            cell.nameLabel.text = nickname;
        }
        
            if (object.type ==LBX_IM_DATA_TYPE_AMR) {
                cell.lastMSGLabel.text = @"[声音]";
            }else if (object.type == LBX_IM_DATA_TYPE_PICTURE){
                cell.lastMSGLabel.text = @"[图片]";
            }else if (object.type == LBX_IM_DATA_TYPE_MP4){
                cell.lastMSGLabel.text = @"[视频]";
            }else if (object.type == LBX_IM_DATA_TYPE_TEXT){
                cell.lastMSGLabel.text = [_wSocket.lbxManager stringFromHexString:object.message];
            }
        
            NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc]initWithString:[_wSocket.lbxManager stringFromHexString:object.message]];
            NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc]init];
            [paraStyle setLineSpacing:1];
            [paraStyle setLineBreakMode:NSLineBreakByTruncatingTail];
            
            [attributeString addAttribute:NSParagraphStyleAttributeName value:paraStyle range:NSMakeRange(0, attributeString.length)];
            cell.lastMSGLabel.attributedText = attributeString;
            cell.lastMSGLabel.frame = cell.defaultRect;
            
            NSString *time = [[[WSocket sharedWSocket]lbxManager]turnTime:object.time formatType:0 isEnglish:YES];
            cell.timeLabel.text = time;
            
            NSLog(@"status = %d",object.status);
            if (object.status ==2)
            {
                [cell.failedImageView setHidden:NO];
                [cell.tipLabel setHidden:YES];
            }
            else
            {
                [cell.failedImageView setHidden:YES];
                cell.tipLabel.text = [NSString stringWithFormat:@"%d",object.noReadCount];
                if ([cell.tipLabel.text intValue]>0)
                {
                    [cell.tipLabel setHidden:NO];
                }
            }
        
        return cell;
    }
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _wSocket.nearMessageList.count+1;
}

-(UITableViewCellEditingStyle )tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row ==0) {
        return UITableViewCellEditingStyleNone;
    }
    return UITableViewCellEditingStyleDelete;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle ==UITableViewCellEditingStyleDelete)
    {
            NearMessageObject *object = [_wSocket.nearMessageList objectAtIndex:indexPath.row-1];
            [_wSocket deleteNearMessageWithPhone:object.phone];
            [_wSocket.nearMessageList removeObjectAtIndex:indexPath.row-1];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
