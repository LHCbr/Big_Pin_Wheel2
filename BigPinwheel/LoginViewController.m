//
//  LoginViewController.m
//  BigPinwheel
//
//  Created by 徐伟 on 16/2/25.
//  Copyright © 2016年 leita. All rights reserved.
//

#import "LoginViewController.h"
#import "InscriptionManager.h"
#import "WSocket.h"
#import "ForgetPassWordStep1.h"


@interface LoginViewController ()

@property(strong,nonatomic)UITextField *phoneTF;      //用户账户
@property(strong,nonatomic)UITextField *passwardTF;   //用户密码

@property(strong,nonatomic)UIButton *loginBtn;        //登录按钮
@property(strong,nonatomic)UIButton *forgetPwdBtn;    //忘记密码按钮

@property(assign,nonatomic)NSInteger length;          //手机号码长度

@property(strong,nonatomic)InscriptionManager *inspManager;


@end

@implementation LoginViewController

-(void)dealloc
{
    NSLog(@"登录界面释放");
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSString *phone = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:kUserName]];
    
    if (phone.length==11&&_inspManager.wJid.phone.length!=11) {
        _inspManager.wJid.phone = phone;
    }
    
    if (phone.length==11&&_inspManager.wJid.phone.length==11 ) {
        NSMutableString *insertphone =[[NSMutableString alloc]initWithString:_inspManager.wJid.phone];
        [insertphone insertString:@"" atIndex:3];
        [insertphone insertString:@"" atIndex:8];
        
        _phoneTF.text = insertphone;
        [_passwardTF becomeFirstResponder];
    }
    else
    {
        if (_phoneTF&&_inspManager.wJid.phone.length<=0){
            [_phoneTF becomeFirstResponder];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.view endEditing:YES];
    self.navigationController.interactivePopGestureRecognizer.enabled =YES;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

#pragma mark -本类接受的通知
-(void)loginSuccess:(NSNotification *)noti
{
    __weak WSocket *weakSocket =[WSocket sharedWSocket];
    __weak LoginViewController *weakSelf = self;
    __weak UIButton *weakBtn = _loginBtn;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [weakSocket showAlertWithTag:0];
        [weakBtn setEnabled:YES];
        [weakSocket.lbxManager showHubAction:1 showView:self.view];
        weakSelf.navigationController.interactivePopGestureRecognizer.enabled =YES;
        [weakSelf.navigationItem setHidesBackButton:NO];
        
        NSString *username = [_phoneTF.text stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSString *passward = [_passwardTF.text stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        [[NSUserDefaults standardUserDefaults]setObject:username forKey:kUserName];
        [[NSUserDefaults standardUserDefaults]setObject:passward forKey:kPassword];
        NSDictionary *user = [[NSDictionary alloc]initWithObjectsAndKeys:username,kUserName,passward,kPassword ,nil];
        
        NSMutableDictionary *alluser = [[NSMutableDictionary alloc]initWithDictionary:[[NSUserDefaults standardUserDefaults]objectForKey:kUserInfo]];
        [alluser setObject:user forKey:username];
        [[NSUserDefaults standardUserDefaults]setObject:alluser forKey:kUserInfo];
        [[NSUserDefaults standardUserDefaults]synchronize];
        
        [self initSelfInfo];
        [weakSocket.lbxManager showHudViewLabelText:@"登录成功" detailsLabelText:nil afterDelay:1];
        [weakSelf.navigationController popToRootViewControllerAnimated:YES];
        
    });
    
}


/// 登陆成功后先从本地寻找个人信息，找到后发送通知，更新个人信息
- (void)initSelfInfo
{
    InscriptionManager *lbxManager = [InscriptionManager sharedManager];
    WJID *uJid = [lbxManager getUserInfoWithPhone:lbxManager.wJid.phone];
    uJid.password = lbxManager.wJid.password;
    if (uJid) {
        lbxManager.wJid = uJid;
    }
    
    DFCUserInfo *dfcUserInfo = [lbxManager getDFCInfoFromSqlWithPhone:lbxManager.wJid.phone];

    if (dfcUserInfo) {
        lbxManager.dfcInfo = dfcUserInfo;
    }
    
    NSLog(@"lbxManager.dfcUsrInfo = %@ ,wjid = %@",lbxManager.dfcInfo,lbxManager.wJid);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kBackSelfInfo object:nil];
    
}


-(instancetype)init
{
    self = [super init];
    if (self)
    {
        _inspManager = [InscriptionManager sharedManager];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(loginSuccess:) name:kLoginSuccess object:nil];
        
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    NAVBAR(@"登录");
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.backBarButtonItem.title = @"返回";
    
    //初始化HeaderView
    [self customHeaderView];
    
    //初始化TextField
    [self customTextField];
    
    //初始化登录按钮相关
    [self customLoginBtn];
    
    //初始化忘记密码按钮
    [self customForgetPasswordBtn];

    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(endEditing:)];
    [self.view addGestureRecognizer:tap];

}

#pragma mark -View创建工具
//初始化HeaderView
-(void)customHeaderView
{
    UIView *headSepView = [self creatLineWithFrame:CGRectMake(0, 64, kDeviceWidth, 8.5) BGColor:kBGColor];
    [self.view addSubview:headSepView];
    
    UIView *sepLine = [self creatLineWithFrame:CGRectMake(0, headSepView.frame.size.height+headSepView.frame.origin.y,kDeviceWidth,0.5) BGColor:COLOR(220, 222, 216, 1)];
    [self.view addSubview:sepLine];
}

//初始化TextField
-(void)customTextField
{
    //_phoneTF _passwardTF sepline
    _phoneTF = [self creatTextFieldWithY:64+8.5 PlaceHolder:@"请输入手机号" isScure:NO ImageName:@"0225_phone"];
    [_phoneTF addTarget:self action:@selector(limitLength:) forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:_phoneTF];
    
    _passwardTF = [self creatTextFieldWithY:_phoneTF.frame.size.height+_phoneTF.frame.origin.y+0.5 PlaceHolder:@"请输入密码" isScure:YES ImageName:@"0225_pwd"];
    [self.view addSubview:_passwardTF];
    
    UIView *sepline0 = [self creatLineWithFrame:CGRectMake(111/2,_phoneTF.frame.origin.y+_phoneTF.frame.size.height, kDeviceWidth -111/2, 0.5) BGColor:COLOR(220, 222, 216, 1)];
    [self.view addSubview:sepline0];
    
    UIView *sepline1 = [self creatLineWithFrame:CGRectMake(sepline0.frame.origin.x, _passwardTF.frame.size.height+_passwardTF.frame.origin.y, sepline0.frame.size.width, 0.5) BGColor:COLOR(220, 222, 216, 1)];
    [self.view addSubview:sepline1];
    
}

//初始化登录按钮
-(void)customLoginBtn
{
    _loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _loginBtn.backgroundColor = COLOR(238, 187, 69, 1);
    _loginBtn.frame = CGRectMake(14, 117+_passwardTF.frame.size.height+_passwardTF.frame.origin.y, kDeviceWidth -28, 52);
    [_loginBtn.layer setMasksToBounds:YES];
    [_loginBtn.layer setCornerRadius:2];
    [_loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_loginBtn.titleLabel setFont:[UIFont systemFontOfSize:17]];
    [_loginBtn.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [_loginBtn setTitle:@"登录" forState:UIControlStateNormal];
    [_loginBtn addTarget:self action:@selector(loginBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_loginBtn];
    
}

-(void)customForgetPasswordBtn
{
    UILabel *forgetPassWordLabel=[[UILabel alloc]initWithFrame:CGRectMake(kDeviceWidth/2-32.5,_loginBtn.frame.origin.y+52+30,80,15)];
    forgetPassWordLabel.text=@"忘记密码?";
    forgetPassWordLabel.font=[UIFont systemFontOfSize:15];
    forgetPassWordLabel.textColor=COLOR(130,130,129, 1);
    
    CGSize size=[[InscriptionManager sharedManager] getSizeWithContent:@"忘记密码?" size:forgetPassWordLabel.frame.size font:15];
    
    UIView *UnderlineView=[[UIView alloc]initWithFrame:CGRectMake(0,15,size.width,1)];
    UnderlineView.backgroundColor=COLOR(130,130,129, 1);
    [forgetPassWordLabel addSubview:UnderlineView];
    
    self.view.userInteractionEnabled=YES;
    forgetPassWordLabel.userInteractionEnabled=YES;
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(forgetPwdLabelClicked)];
    [forgetPassWordLabel addGestureRecognizer:tap];
    [self.view addSubview:forgetPassWordLabel];
}

//创建seplineView
-(UIView *)creatLineWithFrame:(CGRect)frame BGColor:(UIColor *)color
{
    UIView *line = [[UIView alloc]initWithFrame:frame];
    line.backgroundColor = color;
    return line;
}

//TextField创建工具
-(UITextField *)creatTextFieldWithY:(CGFloat)y PlaceHolder:(NSString *)placeHoler isScure:(BOOL)isScure ImageName:(NSString *)imageName
{
    UITextField *textfield = [[UITextField alloc]initWithFrame:CGRectMake(0, y, kDeviceWidth, 56.5)];
    textfield.backgroundColor = [UIColor whiteColor];
    textfield.placeholder = placeHoler;
    textfield.secureTextEntry = isScure;
    textfield.keyboardType = UIKeyboardTypePhonePad;
    [textfield setFont:[UIFont systemFontOfSize:15]];
    textfield.leftViewMode = UITextFieldViewModeAlways;
    textfield.rightViewMode = UITextFieldViewModeAlways;
    textfield.delegate = self;
    
    UIView *leftView = [self creatLineWithFrame:CGRectMake(0, 0,115/2 ,textfield.frame.size.height ) BGColor:[UIColor clearColor]];
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(22, (textfield.frame.size.height-17)/2, 16, 17)];
    imageView.backgroundColor = [UIColor clearColor];
    [imageView setImage:[UIImage imageNamed:imageName]];
    [leftView addSubview:imageView];
    textfield.leftView = leftView;
    
    UIView *rightView =[self creatLineWithFrame:CGRectMake(0, textfield.frame.origin.y, 40, textfield.frame.size.height) BGColor:[UIColor clearColor]];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, (rightView.frame.size.height-17)/2, 16, 17);
    button.backgroundColor = [UIColor clearColor];
    button.contentMode = UIViewContentModeScaleAspectFit;
    [button setImage:[UIImage imageNamed:@"0225_scure0"] forState:UIControlStateNormal];
    button.tag =0;
    [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [rightView addSubview:button];
    
    if ([placeHoler isEqualToString:@"请输入密码"])
    {
        textfield.rightView = rightView;
        textfield.keyboardType = UIKeyboardTypeNamePhonePad;
        textfield.clearButtonMode = UITextFieldViewModeWhileEditing;
    }
    return textfield;
    
}

#pragma mark -点击事件
///_passwordTF点击事件
-(void)buttonClick:(UIButton *)sender
{
    if (sender.tag%2==0)
    {
        [sender setImage:[UIImage imageNamed:@"0225_scure0"] forState:UIControlStateNormal];
        _passwardTF.secureTextEntry = YES;
    }else
    {
        [sender setImage:[UIImage imageNamed:@"0225_scure1"] forState:UIControlStateNormal];
        _passwardTF.secureTextEntry = NO;
    }
    sender.tag = sender.tag+1;
}

/// 监视手机号码输入
- (void)limitLength:(UITextField *)sender
{
    if (sender == _phoneTF)
    {
        NSString *str = [sender.text stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSInteger len = sender.text.length;
        
        if (sender.text.length == 3)
        {
            if (len > _length)
            {
                sender.text = [NSString stringWithFormat:@"%@ ",sender.text];
            }
        }
        else if (sender.text.length == 8)
        {
            if (len > _length)
            {
                sender.text = [NSString stringWithFormat:@"%@ ",sender.text];
            }
        }
        else if (sender.text.length >= 11)
        {
            NSLog(@"到了改换行的时候了");
            if ([[InscriptionManager sharedManager] checkPhoneNum:str])
            {
                NSMutableString *phone = [[NSMutableString alloc] initWithString:str];
                [phone insertString:@" " atIndex:3];
                [phone insertString:@" " atIndex:8];
                sender.text = phone;
                [_passwardTF becomeFirstResponder];
            }
        }
        _length = len;
    }
}

//结束编辑
-(void)endEditing:(UITapGestureRecognizer *)tap
{
    [self.view endEditing:YES];
}

///登录前的检查
-(BOOL)checkInfo
{
    NSString *phone =[_phoneTF.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (phone.length<=0)
    {
        [_inspManager showHudViewLabelText:@"请输入手机号" detailsLabelText:nil afterDelay:1];
        return NO;
    }
    
    if ([_inspManager checkPhoneNum:phone]==NO) {
        [_inspManager showHudViewLabelText:@"手机号码输入有误" detailsLabelText:nil afterDelay:kAfterDelayTime];
        return NO;
    }
    
    NSRange range = [_passwardTF.text rangeOfString:@" "];
    if (_passwardTF.text.length<=0) {
        [_inspManager showHudViewLabelText:@"请输入密码" detailsLabelText:nil afterDelay:kAfterDelayTime];
        return NO;
    }
    if (range.length>0) {
        [_inspManager showHudViewLabelText:@"密码中不能有空格" detailsLabelText:nil afterDelay:kAfterDelayTime];
        return NO;
    }
    
    return YES;
    
}

///登录按钮点击事件
-(void)loginBtnClick:(UIButton *)sender
{
    if ([self checkInfo]==NO) {
        return;
    }
    
    [self.view endEditing:YES];
    
    InscriptionManager *inspManger = [InscriptionManager sharedManager];
    if ([inspManger checkIsHasNetwork:YES]==NO) {
        [inspManger showHudViewLabelText:@"无网络连接" detailsLabelText:nil afterDelay:kAfterDelayTime];
        return;
    }

    self.navigationController.interactivePopGestureRecognizer.enabled =NO;
    [self.navigationItem setHidesBackButton:YES];
    [_loginBtn setEnabled:NO];
    
    NSString *username = [_phoneTF.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *passward = [_passwardTF.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    inspManger.wJid.phone = username;
    inspManger.wJid.password = passward;
    
    __weak WSocket *weakSocket = [WSocket sharedWSocket];
    __weak LoginViewController *weakSelf = self;
    __weak UIButton *weakBtn = _loginBtn;
    

    [[WSocket sharedWSocket]logining:username password:passward isAuto:NO loginBlock:^(int success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (success !=0)
            {
                [weakSocket showAlertWithTag:success];
                
                [weakBtn setEnabled:YES];
                [weakSocket.lbxManager showHubAction:1 showView:self.view];
                weakSelf.navigationController.interactivePopGestureRecognizer.enabled =YES;
                [weakSelf.navigationItem setHidesBackButton:NO];
                
                weakSocket.lbxManager.wJid.phone = @"";
                weakSocket.lbxManager.wJid.password = @"";
                [weakSocket.lbxManager showHudViewLabelText:@"登录失败" detailsLabelText:nil afterDelay:kAfterDelayTime];
            }
        });
    }];
}


//忘记密码点击事件
-(void)forgetPwdLabelClicked
{
    ForgetPassWordStep1 *step1=[[ForgetPassWordStep1 alloc]init];
    [self.navigationController pushViewController:step1 animated:YES];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
