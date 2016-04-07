//
//  NameCardViewController.m
//  BigPinwheel
//
//  Created by 徐伟 on 16/2/15.
//  Copyright © 2016年 leita. All rights reserved.
//

#import "NameCardViewController.h"
#import "NameCardHeaderView.h"
#import "InscriptionManager.h"
#import "WSocket.h"
#import "AddViewController.h"
#import "EditNameCardViewController.h"

#define kGrayLineColor COLOR(221,221,221,1)
#define kBtnWidth (kDeviceWidth-44-47)/2

@interface NameCardViewController ()

@property(strong,nonatomic)UITextField *signTF;        //需求签名textField
@property(strong,nonatomic)UITextField *sexTF;         //性别textField
@property(strong,nonatomic)UITextField *birthTF;       //生日
@property(strong,nonatomic)UITextField *identifyTF;    //身份
@property(strong,nonatomic)UITextField *cityTF;        //城市
@property(strong,nonatomic)UITextField *contactTF;     //联系方式
@property(strong,nonatomic)UITextField *harvPriceTF;   //收割价格
@property(strong,nonatomic)UIView *sepline7;           //分隔线

@property(strong,nonatomic)UIButton *phoneBtn;         //打电话Btn
@property(strong,nonatomic)UIButton *sendMSGBtn;       //发短信Btn

@property(strong,nonatomic)UIButton *rightBarBtn;      //NavBarRightBtn

@property(strong,nonatomic)NameCardHeaderView *headerView;   //HeaderView

@property(strong,nonatomic)WSocket *wSocket;

@end

@implementation NameCardViewController


-(void)dealloc
{
    NSLog(@"名片界面释放");
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
    [self.navigationController.navigationBar setBackgroundImage:nil forBarPosition:UIBarPositionTopAttached barMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:nil];
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
        _userinfo = [[DFCUserInfo alloc]init];
        _wSocket = [WSocket sharedWSocket];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NAVBAR(@"");
    _isDriver = [_userinfo.identity intValue] ==2 ? YES : NO;
    
    //初始化NavBar相关
    [self initializeNavBar];
    
    _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, kDeviceWidth, kDeviceHeight)];
    _scrollView.backgroundColor = [UIColor clearColor];
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.delegate = self;
    _scrollView.bounces = YES;
    [self.view addSubview:_scrollView];
    
    UITapGestureRecognizer *endTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(endTapEditing:)];
    [_scrollView addGestureRecognizer:endTap];
    
    
    //初始化HeaderView
    [self initializeHeaderView];
    //初始化textField
    [self initializeTextField];
    //初始化footerBtnView
    [self initializeFooterBtnView];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self refreshData:_userinfo];
    });
    
}

#pragma mark -View创建工具
//初始化NavBar
-(void)initializeNavBar
{
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"0216_navBarBGImage"] forBarPosition:UIBarPositionTopAttached barMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc]init];
    
     _rightBarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _rightBarBtn.backgroundColor = [UIColor clearColor];
    _rightBarBtn.frame = CGRectMake(0, 0, 20, 5);
    
    if (![_userinfo.phone_num isEqualToString:_wSocket.lbxManager.dfcInfo.phone_num])
    {
        [_rightBarBtn setImage:[UIImage imageNamed:@"0216_dian"] forState:UIControlStateNormal];
        _rightBarBtn.tag = 0;
    }else
    {
        _rightBarBtn.frame = CGRectMake(0, 0, 37/2, 37/2);
        [_rightBarBtn setImage:[UIImage imageNamed:@"0222_edit"] forState:UIControlStateNormal];
        _rightBarBtn.tag = 1;
    }
    
    [_rightBarBtn addTarget:self action:@selector(rightBarBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:_rightBarBtn];
}
//初始化HeaderView
-(void)initializeHeaderView
{
    _headerView = [[NameCardHeaderView alloc]initWithFrame:CGRectMake(0, 0, kDeviceWidth, 212)];
    [_scrollView addSubview:_headerView];
}

//初始化textField
-(void)initializeTextField
{
    //签名_signTF sepline
    UIView *sepline0 = [self creatLineWithFrame:CGRectMake(0, 212+9.5, kDeviceWidth, 0.5) BGColor:kGrayLineColor];
    [_scrollView addSubview:sepline0];
    _signTF = [self creatTextFieldWithFrame:CGRectMake(0,222, kDeviceWidth, 60) Title:@"需求签名" PlaceHolder:@"签名"];
    [_scrollView addSubview:_signTF];
    UIView *sepline1 = [self creatLineWithFrame:CGRectMake(0, _signTF.frame.origin.y+_signTF.frame.size.height, kDeviceWidth, 0.5) BGColor:kGrayLineColor];
    [_scrollView addSubview:sepline1];
    
    //性别 _sexTF 生日 _birthTF sepline
    UIView *sepline2 = [self creatLineWithFrame:CGRectMake(0, sepline1.frame.origin.y+sepline1.frame.size.height+9, kDeviceWidth, 0.5) BGColor:kGrayLineColor];
    [_scrollView addSubview:sepline2];
    _sexTF = [self creatTextFieldWithFrame:CGRectMake(0, sepline2.frame.origin.y+sepline2.frame.size.height, kDeviceWidth/2, 38) Title:@"性别" PlaceHolder:@"性别"];
    [_scrollView addSubview:_sexTF];
    _birthTF = [self creatTextFieldWithFrame:CGRectMake(kDeviceWidth/2, _sexTF.frame.origin.y, kDeviceWidth/2, _sexTF.frame.size.height) Title:@"生日" PlaceHolder:@"生日"];
    [_scrollView addSubview:_birthTF];
    UIView *sepline3 = [self creatLineWithFrame:CGRectMake(0, _sexTF.frame.origin.y+_sexTF.frame.size.height, kDeviceWidth, 0.5) BGColor:kGrayLineColor];
    [_scrollView addSubview:sepline3];
    
    //身份_identifyTF 城市_cityTF 联系方式_contactTF sepline
    UIView *sepline4 = [self creatLineWithFrame:CGRectMake(0, sepline3.frame.size.height+sepline3.frame.origin.y+9, kDeviceWidth, 0.5) BGColor:kGrayLineColor];
    [_scrollView addSubview:sepline4];
    _identifyTF = [self creatTextFieldWithFrame:CGRectMake(0, sepline4.frame.size.height+sepline4.frame.origin.y, kDeviceWidth, 95/2) Title:@"身份" PlaceHolder:@"身份"];
    [_scrollView addSubview:_identifyTF];
    UIView *sepline5 = [self creatLineWithFrame:CGRectMake(0, _identifyTF.frame.origin.y+_identifyTF.frame.size.height, kDeviceWidth, 0.5) BGColor:kGrayLineColor];
    [_scrollView addSubview:sepline5];
    _cityTF = [self creatTextFieldWithFrame:CGRectMake(0, sepline5.frame.size.height+sepline5.frame.origin.y, kDeviceWidth, 192/4) Title:@"城市" PlaceHolder:@"城市"];
    [_scrollView addSubview:_cityTF];
    UIView *sepline6 = [self creatLineWithFrame:CGRectMake(102, _cityTF.frame.origin.y+_cityTF.frame.size.height-0.5, kDeviceWidth-102, 0.5) BGColor:kGrayLineColor];
    [_scrollView addSubview:sepline6];
    _contactTF = [self creatTextFieldWithFrame:CGRectMake(0, _cityTF.frame.size.height+_cityTF.frame.origin.y, kDeviceWidth, 192/4) Title:@"联系方式" PlaceHolder:@"联系方式"];
    [_scrollView addSubview:_contactTF];
    _sepline7 = [self creatLineWithFrame:CGRectMake(0, _contactTF.frame.size.height+_contactTF.frame.origin.y, kDeviceWidth, 0.5) BGColor:kGrayLineColor];
    [_scrollView addSubview:_sepline7];
    
}
//如果是司机，添加_harvPriceTF
-(void)appendHarvPriceView
{
    
    UIView *sepline8 = [self creatLineWithFrame:CGRectMake(0, _sepline7.frame.size.height+_sepline7.frame.origin.y+19/2, kDeviceWidth, 0.5) BGColor:kGrayLineColor];
    [_scrollView addSubview:sepline8];
    _harvPriceTF = [self creatTextFieldWithFrame:CGRectMake(0, sepline8.frame.origin.y+0.5, kDeviceWidth, 38) Title:@"收割价格" PlaceHolder:@"收割价格"];
    [_scrollView addSubview:_harvPriceTF];
    UIView *sepline9 = [self creatLineWithFrame:CGRectMake(0, _harvPriceTF.frame.origin.y+_harvPriceTF.frame.size.height, kDeviceWidth, 0.5)BGColor:kGrayLineColor];
    [_scrollView addSubview:sepline9];
    
}

//创建FooterBtnView
-(void)initializeFooterBtnView
{
    if (_isDriver == YES) {
        _phoneBtn = [self creatBtnWithX:47/2 BGColor:COLOR(0, 146, 79, 1) titleColor:[UIColor whiteColor] titleFont:18 title:@"打电话" Index:0];
        _sendMSGBtn = [self creatBtnWithX:47/2+kBtnWidth+44 BGColor:[UIColor whiteColor] titleColor:COLOR(100, 100, 100, 1) titleFont:18 title:@"发消息" Index:1];
        [_sendMSGBtn.layer setBorderWidth:0.5];
        [_sendMSGBtn.layer setBorderColor:COLOR(181, 181, 181, 1).CGColor];
    }else
    {
        UIButton *sendMSGBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        sendMSGBtn.backgroundColor = COLOR(0, 146, 79, 1);
        sendMSGBtn.frame = CGRectMake(23, _contactTF.frame.size.height+_contactTF.frame.origin.y +90, kDeviceWidth -46, 40);
        [sendMSGBtn.layer setMasksToBounds:YES];
        [sendMSGBtn.layer setCornerRadius:4];
        [sendMSGBtn setTitle:@"发消息" forState:UIControlStateNormal];
        [sendMSGBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [sendMSGBtn.titleLabel setFont:[UIFont systemFontOfSize:18]];
        [sendMSGBtn.titleLabel setTextAlignment:NSTextAlignmentCenter];
        sendMSGBtn.tag =1;
        [sendMSGBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [_scrollView addSubview:sendMSGBtn];
    }
    
}


//textField创建工具
-(UITextField *)creatTextFieldWithFrame:(CGRect)frame Title:(NSString *)title PlaceHolder:(NSString *)placeHolder
{
    UITextField *textField = [[UITextField alloc]initWithFrame:frame];
    textField.backgroundColor = [UIColor whiteColor];
    textField.textColor = [UIColor blackColor];
    textField.font = [UIFont systemFontOfSize:14];
    textField.placeholder = placeHolder;
    textField.delegate = self;
    if ([placeHolder isEqualToString:@"请输入生日"]||[placeHolder isEqualToString:@"请输入联系方式"]) {
        textField.keyboardType = UIKeyboardTypePhonePad;
    }else{
        textField.keyboardType = UIKeyboardTypeAlphabet;
    }
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 103,textField.frame.size.height)];
    view.backgroundColor = [UIColor clearColor];
    textField.leftViewMode = UITextFieldViewModeAlways;
    textField.leftView = view;
    
    UILabel *leftLabel = [[UILabel alloc]initWithFrame:CGRectMake(13, (view.frame.size.height-14)/2, 90, 13)];
    leftLabel.backgroundColor = [UIColor clearColor];
    leftLabel.textColor = COLOR(128, 128, 128, 1);
    leftLabel.font = [UIFont systemFontOfSize:12.5];
    leftLabel.textAlignment = NSTextAlignmentLeft;
    leftLabel.text = title;
    [view addSubview:leftLabel];
    
    return textField;
}

//创建seplineView
-(UIView *)creatLineWithFrame:(CGRect)frame BGColor:(UIColor *)color
{
    UIView *line = [[UIView alloc]initWithFrame:frame];
    line.backgroundColor = color;
    return line;
}

//创建FooterBtn
-(UIButton *)creatBtnWithX:(CGFloat)x BGColor:(UIColor *)bGColor titleColor:(UIColor *)titleColor titleFont:(CGFloat)font title:(NSString *)title Index:(NSInteger)tag
{
    CGFloat y = _scrollView.frame.size.height - 186/2;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(x, y,kBtnWidth , 79/2);
    button.backgroundColor = bGColor;
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:titleColor forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont systemFontOfSize:font]];
    [button.layer setMasksToBounds:YES];
    [button.layer setCornerRadius:2];
    button.tag = tag;
    [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:button];
    return button;
}

#pragma mark 数据请求相关

-(void)refreshData:(DFCUserInfo *)info
{
    
    NSLog(@"usrino = %@",info);
    
    NSString *nickName = [_wSocket.lbxManager stringFromHexString:info.nick_name];
    if (nickName.length<=0||[nickName isEqualToString:@"(null)"])
    {
        nickName = [NSString stringWithFormat:@"+%@ %@",info.area_code,info.phone_num];
    }
    
    __weak NameCardViewController *weakSelf = self;
    __weak WSocket *weakSocket =_wSocket;
    
    
    [_wSocket addDownFileOperationWithFileUrlString:info.head_portrait serialId:@"-1" modelType:ModelTypeNormal info:nil downBlock:^(int ret, int isSave, NSData *data, NSString *fileUrl) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (ret>=0)
            {
                [weakSelf.headerView.avatarView setImage:[UIImage imageWithData:data]];
                if (isSave)
                {
                    [data writeToFile:[NSString stringWithFormat:@"%@/%@",kPathAvatar,[weakSocket.lbxManager upper16_MD5:fileUrl]]
                           atomically:YES];
                }
            }
            else
            {
                [weakSelf.headerView.avatarView setImage:kDefaultAvatarImage];
            }
        });
       
    }];
    
    NSString *placeStr = [NSString stringWithFormat:@"%@%@%@%@",info.provice,info.city,info.region,info.remaining_addr];
    if (placeStr.length<=0||[placeStr isEqualToString:@"(null)"]) {
        placeStr = @"";
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
       weakSelf.headerView.nameLabel.text = nickName;
       [weakSelf.headerView.cityBtn setTitle:placeStr forState:UIControlStateNormal];
        weakSelf.signTF.text = info.signature;
        weakSelf.sexTF.text = [info.sex intValue] ==1 ? @"男" : @"女";
        weakSelf.birthTF.text = info.birthday;
        weakSelf.identifyTF.text = [info.identity intValue] ==1 ? @"农民" : @"司机" ;
        weakSelf.isDriver = [info.identity intValue] ==2 ? YES : NO;
        weakSelf.cityTF.text = [NSString stringWithFormat:@"%@",info.city];
        weakSelf.contactTF.text = info.phone;
        
        
        if (weakSelf.isDriver==YES) {
            [weakSelf appendHarvPriceView];
            NSInteger price = [[[info.quoted_price_list lastObject]objectForKey:@"quoted_price"]intValue];
            weakSelf.harvPriceTF.text = [NSString stringWithFormat:@"%ld元/亩",price/100];
        }
    });
}

#pragma mark 按钮点击事件
//右navBarBtn点击事件
-(void)rightBarBtnClick:(UIButton *)sender
{
    if (sender.tag ==0)
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *addFriendListAC = [UIAlertAction actionWithTitle:@"加为好友" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                                          {
                                              AddViewController *verfiVC = [[AddViewController alloc]init];
                                              verfiVC.phone = _userinfo.phone_num;
                                              NSLog(@"_userinfo.userid = %@",_userinfo.user_id);
                                              [self.navigationController pushViewController:verfiVC animated:YES];
                                          }];
        UIAlertAction *sendReportAC = [UIAlertAction actionWithTitle:@"举报" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        UIAlertAction *addBlackListAC = [UIAlertAction actionWithTitle:@"加入黑名单" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        UIAlertAction *cancelAC = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:addFriendListAC];
        [alert addAction:sendReportAC];
        [alert addAction:addBlackListAC];
        [alert addAction:cancelAC];
        
        for (UIAlertAction *action in alert.actions){
            [action setValue:COLOR(1, 1, 1, 1) forKey:@"_titleTextColor"];
        }
        [self  presentViewController:alert animated:YES completion:nil];
    }else if (sender.tag ==1)
    {
        EditNameCardViewController *editVC = [[EditNameCardViewController alloc]init];
        [self.navigationController pushViewController:editVC animated:YES];
        
    }
}

///footView 打电话发短信点击事件
-(void)buttonClick:(UIButton *)sender
{
    if (sender.tag ==0)
    {
        NSString *phoneStr = [NSString stringWithFormat:@"tel:%@",_userinfo.phone_num];
        if (_contactTF.text.length !=11)
        {
            [_wSocket.lbxManager showHudViewLabelText:@"手机号有误" detailsLabelText:nil afterDelay:kAfterDelayTime];
            return;
        }
        
        UIWebView *phoneCallView = [[UIWebView alloc]init];
        [phoneCallView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:phoneStr]]];
        [self.view addSubview:phoneCallView];
    }
    else if (sender.tag ==1)
    {
        
    }
}

-(void)endTapEditing:(UITapGestureRecognizer *)tap
{
    [self.view endEditing:YES];
}

#pragma mark -UITextFieldDelegate
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return NO;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
