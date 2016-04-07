//
//  VerficationCodeViewController.m
//  BigPinwheel
//
//  Created by 徐伟 on 16/2/26.
//  Copyright © 2016年 leita. All rights reserved.
//

#import "VerficationCodeViewController.h"
#import "WSocket.h"
#import "InscriptionManager.h"
#import "AFNetworking.h"
#import "UserInfoViewController.h"

@interface VerficationCodeViewController ()

@property(strong,nonatomic)UITextField *verfCodeTF;  //获取验证码VerfCodeTF

@property(strong,nonatomic)UIButton *verfCodeBtn;    //获取验证码button
@property(strong,nonatomic)UIButton *helpBtn;        //联系客服

@property(strong,nonatomic)NSTimer *codeTimer;       //获取验证码的计数器

@property(strong,nonatomic)InscriptionManager *inspManager;

@end

@implementation VerficationCodeViewController

- (void)dealloc
{
    NSLog(@"获取验证码界面释放");
    
    [_codeTimer invalidate];
    _codeTimer = nil;
    timeCount = 60;
    [self.view endEditing:YES];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!_codeTimer) {
        _codeTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(verfCodeStatus:) userInfo:nil repeats:YES];
        [_codeTimer setFireDate:[NSDate distantFuture]];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [_verfCodeTF becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [_codeTimer invalidate];
    _codeTimer = nil;
}

-(instancetype)init
{
    self = [super init];
    if (self)
    {
        _inspManager = [InscriptionManager sharedManager];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NAVBAR(@"输入验证码");
    
    
    [self customHeaderView];
    
    [self customTextField];
    
    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc]initWithTitle:@"下一步" style:UIBarButtonItemStylePlain target:self action:@selector(nextBtnClick:)];
    self.navigationItem.rightBarButtonItem = rightBarItem;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(endEditing:)];
    [self.view addGestureRecognizer:tap];
    
}

#pragma mark -View创建工具
/// 创建HeaderView
-(void)customHeaderView
{
    UIView *headSepView = [self creatLineWithFrame:CGRectMake(0, 64, kDeviceWidth, 8.5) BGColor:kBGColor];
    [self.view addSubview:headSepView];
    
    UIView *sepLine = [self creatLineWithFrame:CGRectMake(0, headSepView.frame.size.height+headSepView.frame.origin.y,kDeviceWidth,0.5) BGColor:COLOR(220, 222, 216, 1)];
    [self.view addSubview:sepLine];
}

///初始化TextField
-(void)customTextField
{
    _verfCodeTF = [[UITextField alloc]initWithFrame:CGRectMake(0, 64+8.5+0.5, kDeviceWidth,54)];
    _verfCodeTF.backgroundColor = [UIColor whiteColor];
    _verfCodeTF.keyboardType = UIKeyboardTypePhonePad;
    [_verfCodeTF setFont:[UIFont systemFontOfSize:14]];
    _verfCodeTF.placeholder = @"请输入验证码";
    _verfCodeTF.leftViewMode = UITextFieldViewModeAlways;
    _verfCodeTF.rightViewMode = UITextFieldViewModeAlways;
    _verfCodeTF.delegate = self;
    [self.view addSubview:_verfCodeTF];
    
    UIView *leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 58, CGRectGetHeight(_verfCodeTF.frame))];
    leftView.backgroundColor = [UIColor clearColor];
    _verfCodeTF.leftView = leftView;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor clearColor];
    button.frame = CGRectMake((CGRectGetWidth(leftView.frame)-16)/2, (CGRectGetHeight(leftView.frame)-17)/2, 16, 17);
    [button setImage:[UIImage imageNamed:@"0226_message"] forState:UIControlStateNormal];
    [button setEnabled:NO];
    [leftView addSubview:button];
    
    UIView *rightView = [self creatLineWithFrame:CGRectMake(0, 0,kDeviceWidth* 257/750, button.frame.size.height) BGColor:[UIColor clearColor]];
    UIView *vertline = [self creatLineWithFrame:CGRectMake(0, (button.frame.size.height -23)/2, 0.5, 23) BGColor:COLOR(191, 191, 191, 1)];
    [rightView addSubview:vertline];
    _verfCodeTF.rightView = rightView;
    
    _verfCodeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _verfCodeBtn.backgroundColor = [UIColor clearColor];
    _verfCodeBtn.frame = CGRectMake(7, 0, rightView.frame.size.width-7 -11, rightView.frame.size.height);
    [_verfCodeBtn setTitleColor:COLOR(237, 195, 117, 1) forState:UIControlStateNormal];
    [_verfCodeBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [_verfCodeBtn.titleLabel setTextAlignment:NSTextAlignmentLeft];
    [_verfCodeBtn setTitle:@"获取验证码(60s)" forState:UIControlStateNormal];
    [_verfCodeBtn addTarget:self action:@selector(vertifCodeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [rightView addSubview:_verfCodeBtn];
    
    UIView *sepline = [self creatLineWithFrame:CGRectMake(0, CGRectGetMaxY(_verfCodeBtn.frame), kDeviceWidth, 0.5) BGColor:COLOR(220, 222, 216, 1)];
    [self.view addSubview:sepline];
    
}

/// 创建seplineView
-(UIView *)creatLineWithFrame:(CGRect)frame BGColor:(UIColor *)color
{
    UIView *line = [[UIView alloc]initWithFrame:frame];
    line.backgroundColor = color;
    return line;
}

#pragma mark -按钮点击事件
//获取验证码
-(void)vertifCodeBtnClick:(UIButton *)sender
{
    
    if ([_inspManager checkIsHasNetwork:YES]==NO)
    {
        return;
    }
    
    [_codeTimer setFireDate:[NSDate distantPast]];
    [_verfCodeBtn setEnabled:NO];
    [_verfCodeBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    static NSString *callUrl = @"http://115.28.49.135/telegram/msg/send_sms_utf8.php";
    NSString *phone = [_inspManager.wJid.phone stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSMutableDictionary *para = [[NSMutableDictionary alloc]init];
    [para setObject:phone forKey:@"phone"];
    [para setObject:@"1" forKey:@"codetype"];
    [para setObject:kPhoneArea forKey:@"area"];
    [para setObject:@"1" forKey:@"msgtype"];
    [para setObject:@"D20CC38753F4759417F4F37B5248C3F7" forKey:@"msgkey"];
    
    __weak VerficationCodeViewController *weakSelf = self;
    __weak InscriptionManager *weakInspManager = [InscriptionManager sharedManager];
    
    [manager POST:callUrl parameters:para success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        NSDictionary *dict =[weakSelf fixData:responseObject];
        if ([[dict objectForKey:@"ret"]intValue]!=0 ) {
            [weakSelf resetTimer];
        }
        [weakInspManager showHudViewLabelText:[dict objectForKey:@"msg"] detailsLabelText:nil afterDelay:1];
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        
        NSLog(@"请求失败error =%@",error);
        [weakSelf resetTimer];
    }];
    
}

- (NSDictionary *)fixData:(NSData *)jsonData
{
    NSString *responseString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    responseString = [responseString stringByReplacingOccurrencesOfString:@"\r" withString:@"\\r"];
    responseString = [responseString stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
    responseString = [responseString stringByReplacingOccurrencesOfString:@"\t" withString:@"\\t"];
    responseString = [responseString stringByReplacingOccurrencesOfString:@"\r\n" withString:@"\\r\n"];
    NSData *newJsonData = [responseString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSDictionary *rootDict = nil;
    if (newJsonData.length) {
        rootDict = [NSJSONSerialization JSONObjectWithData:newJsonData options:NSJSONReadingMutableContainers error:&error];
    }
    if (error) {
        NSLog(@"error = %@    =%@",error,responseString);
    }
    NSLog(@"rootDict = %@",rootDict);
    return rootDict;
}

-(void)resetTimer
{
    [_verfCodeBtn setTitle:@"获取验证码(60s)" forState:UIControlStateNormal];
    [_verfCodeBtn setEnabled:YES];
    [_verfCodeBtn setTitleColor:COLOR(237, 195, 117, 1) forState:UIControlStateNormal];
    [_codeTimer setFireDate:[NSDate distantFuture]];
    
    timeCount =60;
}

//验证码计时器
static int timeCount = 60;
-(void)verfCodeStatus:(NSTimer *)timer
{
    if (timeCount >0)
    {
       [_verfCodeBtn setTitle:[NSString stringWithFormat:@"获取验证码(%ds)",timeCount] forState:UIControlStateNormal];
        timeCount --;
    }
    else
    {
        [_verfCodeBtn setEnabled:YES];
        [_verfCodeBtn setTitle:@"获取验证码(60s)" forState:UIControlStateNormal];
        [_verfCodeBtn setTitleColor:COLOR(237, 195, 117, 1) forState:UIControlStateNormal];
        [_codeTimer setFireDate:[NSDate distantFuture]];
        
        timeCount =60;
    }
}

//下一步按钮点击
-(void)nextBtnClick:(UIButton *)sender
{
    if (_verfCodeTF.text.length !=5)
    {
        [_inspManager showHudViewLabelText:@"您输入的验证码不符合要求" detailsLabelText:nil afterDelay:1];
        return;
    }
    
    NSString *verfCode = [_verfCodeTF.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    _inspManager.wJid.otherOne = verfCode;

    __weak WSocket *weakSocket = [WSocket sharedWSocket];
    __weak VerficationCodeViewController *weakSelf = self;
    __block NSString *weakPhone = _inspManager.wJid.phone;
    __block NSString *weakPwd = _inspManager.wJid.password;
    
    [[WSocket sharedWSocket]registing:_inspManager.wJid.phone passwd:_inspManager.wJid.password code:verfCode registingBlock:^(int success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [weakSocket showAlertWithTag:success];
            [weakSelf resetTimer];
            weakSelf.navigationController.interactivePopGestureRecognizer.enabled = YES;
            NSLog(@"注册结果是 %d",success);
            
            if (success == 0) {
                weakSocket.lbxManager.wJid.phone = weakPhone;
                weakSocket.lbxManager.wJid.password = weakPwd;
                [[NSUserDefaults standardUserDefaults]setObject:weakPhone forKey:kUserName];
                [[NSUserDefaults standardUserDefaults]setObject:weakPwd forKey:kPassword];
                [[NSUserDefaults standardUserDefaults]synchronize];
                [weakSocket connectToServerAndLogin];
                [weakSocket.lbxManager showHudViewLabelText:@"注册成功，请完善你的信息" detailsLabelText:nil afterDelay:1];
                [self jumpToUserInfoVC];
                
            }else if (success ==kConnectFailue)
            {
                weakSocket.lbxManager.wJid.phone = @"";
                weakSocket.lbxManager.wJid.password = @"";
                [weakSocket.lbxManager showHudViewLabelText:@"注册失败" detailsLabelText:nil afterDelay:1];
            }
        });
    }];
    
}

-(void)jumpToUserInfoVC
{
    WSocket *wSocket = [WSocket sharedWSocket];
    WJID *wJid = wSocket.lbxManager.wJid;
    
    wJid.phone = [[NSUserDefaults standardUserDefaults]objectForKey:kUserName];
    wJid.password = [[NSUserDefaults standardUserDefaults]objectForKey:kPassword];
    wJid.sex = @"男";
    wJid.identity = @"司机";
    
    UserInfoViewController *userInfoVC = [[UserInfoViewController alloc]init];
    [self.navigationController pushViewController:userInfoVC animated:YES];

}

//结束编辑
-(void)endEditing:(UITapGestureRecognizer *)tap
{
    [self.view endEditing:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
