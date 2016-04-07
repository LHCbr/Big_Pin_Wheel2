//
//  MyProfilesViewController.m
//  BigPinwheel
//
//  Created by 徐伟 on 16/1/25.
//  Copyright © 2016年 leita. All rights reserved.
//

#import "MyProfilesViewController.h"
#import "MyCustom.h"
#import "ProfileAvatarCell.h"
#import "SignDemondCell.h"
#import "PriceAreaCell.h"
#import "WSocket.h"
#import "InscriptionManager.h"
#import "EditNameCardViewController.h"
#import "signBtn.h"

@interface MyProfilesViewController ()

@property(strong,nonatomic)WSocket *wSocket;
@property(strong,nonatomic)InscriptionManager *inspManager;
@property (strong, nonatomic)UIImageView *avatarImageView;

@property(strong,nonatomic)PriceAreaCell *priceCell;

@property(strong,nonatomic)MyCustom *custom0;
@property(strong,nonatomic)MyCustom *cusomt1;
@property(strong,nonatomic)MyCustom *cusomt2;

@end

@implementation MyProfilesViewController

- (void)dealloc
{
    NSLog(@"myprofiles界面释放");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

#pragma mark -本类接受的通知
/// 登陆成功 获取自己的大风车用户资料  nickname place配置一下
- (void)loginSuccessed:(NSNotification *)noti
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (_inspManager.dfcInfo.nick_name.length<=0||[_inspManager.dfcInfo.nick_name isEqualToString:@"(null)"]) {
            
            _inspManager.dfcInfo.nick_name = [NSString stringWithFormat:@"+%@ %@",_inspManager.dfcInfo.area_code,_inspManager.dfcInfo.phone_num];
        }
        
        NSString *placeStr = [NSString stringWithFormat:@"%@%@%@%@",_inspManager.dfcInfo.provice,_inspManager.dfcInfo.city,_inspManager.dfcInfo.region,_inspManager.dfcInfo.remaining_addr];
        _inspManager.dfcInfo.address = placeStr;
        _inspManager.wJid.address = placeStr;
        
        [_tableView reloadData];
        
    });
}
///获取PriceAreaEditVC执行添加删除操作以后发出的通知，刷新_priceCell的界面
-(void)refreshPriceCell:(NSNotification *)noti
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSLog(@"refreshedquotedlist = %@",_inspManager.dfcInfo.quoted_price_list);
        [_priceCell refreshPriceAreaWithArray:_inspManager.dfcInfo.quoted_price_list];
        NSString *placeStr = [NSString stringWithFormat:@"%@%@%@%@",_inspManager.dfcInfo.provice,_inspManager.dfcInfo.city,_inspManager.dfcInfo.region,_inspManager.dfcInfo.remaining_addr];
        _inspManager.dfcInfo.address = placeStr;
        _inspManager.wJid.address = placeStr;

        [_tableView reloadData];
    });
      
}

-(instancetype)init
{
    self = [super init];
    if (self)
    {
        _wSocket = [WSocket sharedWSocket];
        _inspManager = [InscriptionManager sharedManager];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(loginSuccessed:) name:kBackDFCSelfInfo object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(loginSuccessed:) name:kBackSelfInfo object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshPriceCell:) name:kBackDFCSelfInfo object:nil];
        
        if (_inspManager.dfcInfo.nick_name.length<=0||[_inspManager.dfcInfo.nick_name isEqualToString:@"(null)"]) {
            
            _inspManager.dfcInfo.nick_name = [NSString stringWithFormat:@"+%@ %@",_inspManager.dfcInfo.area_code,_inspManager.dfcInfo.phone_num];
        }
        
        NSString *placeStr = [NSString stringWithFormat:@"%@%@%@%@",_inspManager.dfcInfo.provice,_inspManager.dfcInfo.city,_inspManager.dfcInfo.region,_inspManager.dfcInfo.remaining_addr];
        _inspManager.wJid.address = placeStr;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = COLOR(126, 112, 77, 1);
    
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, -64, kPopOffSetX, kDeviceHeight) style:UITableViewStylePlain];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.tableHeaderView = [[UIView alloc]init];
    _tableView.tableFooterView = [[UIView alloc]init];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
    
    [self customFooterView];
    
}

#pragma mark - View创建工具

-(void)customFooterView
{
    signBtn *settingBtn = [signBtn buttonWithType:UIButtonTypeCustom];
    settingBtn.backgroundColor = [UIColor clearColor];
    settingBtn.imgeSize = CGSizeMake(15, 15);
    settingBtn.frame = CGRectMake(11.5, self.view.frame.size.height-60, kDeviceWidth/4, 60);
    [settingBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [settingBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [settingBtn.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [settingBtn setTitle:@"设置" forState:UIControlStateNormal];
    [settingBtn setImage:[UIImage imageNamed:@"0229_settings"] forState:UIControlStateNormal];
    settingBtn.contentMode = UIViewContentModeScaleAspectFit;
    [settingBtn addTarget:self action:@selector(setttingBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    settingBtn.titleLabel.textAlignment=NSTextAlignmentLeft;
    [self.view addSubview:settingBtn];
}

#pragma mark - UITabelViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row==0)
    {
        return 271/2.0f;
    }else if (indexPath.row ==1)
    {
       return 160.0f;
    }
    else
   {
       return 379/2.0f;
   }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row ==0) {
        [_delegate priceAreaCellDidSelectedWithIndex:1];
    }
    else if (indexPath.row ==2&&[_inspManager.dfcInfo.identity intValue]==2)
    {
        [self.view endEditing:YES];
        
        [_delegate priceAreaCellDidSelectedWithIndex:0];
    }
}

#pragma mark - UITableViewDataSource

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"normalcell";
    static NSString *signIdentifier =@"signidenitifier";
    static NSString *priceIdentifier = @"priceIdentifier";
    
    if (indexPath.row ==0) {
        ProfileAvatarCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        
        if (cell ==nil) {
            cell = [[ProfileAvatarCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.nameLabel.text = [_inspManager stringFromHexString:_inspManager.dfcInfo.nick_name];
        [cell.placeBtn setTitle:_inspManager.dfcInfo.address forState:UIControlStateNormal];
        [cell.avatarBtn setImage:kDefaultAvatarImage forState:UIControlStateNormal];
        __weak ProfileAvatarCell *weakCell = cell;
        __weak WSocket *weakSocket = _wSocket;
        
        [[WSocket sharedWSocket]addDownFileOperationWithFileUrlString:_inspManager.dfcInfo.head_portrait serialId:@"-1" modelType:ModelTypeNormal info:nil downBlock:^(int ret, int isSave, NSData *data, NSString *fileUrl) {
            
            NSLog(@"head_partira = %@",_inspManager.dfcInfo.head_portrait);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (ret>=0) {
                    [weakCell.avatarBtn setImage:[UIImage imageWithData:data] forState:UIControlStateNormal];
                    
                    if (isSave && data.length>0) {
                        [data writeToFile:[NSString stringWithFormat:@"%@/%@",kPathAvatar,[weakSocket.lbxManager upper16_MD5:fileUrl]] atomically:YES];
                    }
                }
            });
        }];
        
        return cell;
        
    }else if (indexPath.row ==1)
    {
        SignDemondCell *cell = [tableView dequeueReusableCellWithIdentifier:signIdentifier];
        if (cell ==nil) {
            cell = [[SignDemondCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:signIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;

        }
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc]initWithString:_inspManager.dfcInfo.signature];
        NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc]init];
        [paraStyle setLineSpacing:8];
        [str addAttribute:NSParagraphStyleAttributeName value:paraStyle range:NSMakeRange(0, str.length)];
        cell.demondlabel.attributedText = str;
        return cell;
    }
    else
    {
        _priceCell = [tableView dequeueReusableCellWithIdentifier:priceIdentifier];
        if (_priceCell ==nil)
        {
            _priceCell = [[PriceAreaCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:priceIdentifier priceAreaArray:_inspManager.dfcInfo.quoted_price_list];
            _priceCell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        return _priceCell;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([_inspManager.dfcInfo.identity intValue]==2) {
        return 3;
    }else
    {
        return 2;
    }
}

#pragma mark -点击事件
-(void)endTapEditing:(UITapGestureRecognizer *)tap
{
    [self.view endEditing:YES];
}

-(void)setttingBtnClick:(UIButton *)sender
{
    [_delegate priceAreaCellDidSelectedWithIndex:2];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
