//
//  ForgetPassWordStep3.m
//  BigPinwheel
//
//  Created by xumckay on 16/3/9.
//  Copyright © 2016年 leita. All rights reserved.
//

#import "ForgetPassWordStep3.h"
#import "InscriptionManager.h"
#import "WSocket.h"
#import "MBProgressHUD.h"
@interface ForgetPassWordStep3 ()

@property (strong,nonatomic)UIView *BGView;
@property (strong,nonatomic)UITextField *passWordField1;
@property (strong,nonatomic)UITextField *passWordField2;
@property (strong,nonatomic)UIImageView *picImageView;
@property (strong,nonatomic)UIButton *showOrHiddenTextBtn1;
@property (strong,nonatomic)UIButton *showOrHiddenTextBtn2;
@property (strong,nonatomic)InscriptionManager *InscriptManager;
@end

@implementation ForgetPassWordStep3

-(instancetype)init
{
    if (self) {
        _InscriptManager=[InscriptionManager sharedManager];
    }
    return self;
}

-(UIView *)BGView
{
    if (!_BGView) {
        _BGView=[[UIView alloc]initWithFrame:CGRectMake(0,10,kDeviceWidth,113)];
        _BGView.backgroundColor=[UIColor whiteColor];
        UIView *sep1=[[UIView alloc]initWithFrame:CGRectMake(0,0,kDeviceWidth,1)];
        sep1.backgroundColor=COLOR(220, 222, 216, 1);
        
        UIView *sep2=[[UIView alloc]initWithFrame:CGRectMake(55,56,kDeviceWidth-55,1)];
        sep2.backgroundColor=COLOR(220, 222, 216, 1);
        
        UIView *sep3=[[UIView alloc]initWithFrame:CGRectMake(0,112,kDeviceWidth,1)];
        sep3.backgroundColor=COLOR(220, 222, 216, 1);
        
        [_BGView addSubview:sep1];
        [_BGView addSubview:sep2];
        [_BGView addSubview:sep3];
    }
    return _BGView;
}

-(UITextField *)passWordField1
{
    if (!_passWordField1) {
        
        _passWordField1=[[UITextField alloc]initWithFrame:CGRectMake(55,1,kDeviceWidth-55-50,55)];
        _passWordField1.placeholder=@"请重置新密码";
        _passWordField1.keyboardType=UIKeyboardTypeNamePhonePad;
        _passWordField1.secureTextEntry=YES;
    }
   return  _passWordField1;
}

-(UITextField *)passWordField2
{
    if (!_passWordField2) {
        _passWordField2=[[UITextField alloc]initWithFrame:CGRectMake(55,55+2,kDeviceWidth-55-50,55)];
        _passWordField2.placeholder=@"请再次确认新密码";
        _passWordField2.keyboardType=UIKeyboardTypeNamePhonePad;
        _passWordField2.secureTextEntry=YES;
    }
    return  _passWordField2;
}

-(UIImageView *)picImageView
{
    if (!_picImageView) {
        _picImageView=[[UIImageView alloc]initWithFrame:CGRectMake(25,1+22.5-8.5+5, 16,17)];
        [_picImageView setImage:[UIImage imageNamed:@"0225_pwd"]];
    }
    return _picImageView;
}

-(UIButton *)showOrHiddenTextBtn1
{
    if (!_showOrHiddenTextBtn1) {
        _showOrHiddenTextBtn1=[[UIButton alloc]initWithFrame:CGRectMake(kDeviceWidth-50,16,25,25)];
        [_showOrHiddenTextBtn1 setImage:[UIImage imageNamed:@"0225_scure0"] forState:UIControlStateNormal];
        [_showOrHiddenTextBtn1 setImage:[UIImage imageNamed:@"0225_scure1"] forState:UIControlStateSelected];
        [_showOrHiddenTextBtn1 addTarget:self action:@selector(showOrHiddenTextBtn1Clicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _showOrHiddenTextBtn1;
}

-(UIButton *)showOrHiddenTextBtn2
{
    if (!_showOrHiddenTextBtn2) {
        _showOrHiddenTextBtn2=[[UIButton alloc]initWithFrame:CGRectMake(kDeviceWidth-50,55+2+15,25,25)];
        [_showOrHiddenTextBtn2 setImage:[UIImage imageNamed:@"0225_scure0"] forState:UIControlStateNormal];
        [_showOrHiddenTextBtn2 setImage:[UIImage imageNamed:@"0225_scure1"] forState:UIControlStateSelected];
        [_showOrHiddenTextBtn2 addTarget:self action:@selector(showOrHiddenTextBtn2Clicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _showOrHiddenTextBtn2;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NAVBAR(@"重新设置密码");
     self.view.backgroundColor=COLOR(241,242, 236, 1);
    
    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(finishBtnClicked)];
    self.navigationItem.rightBarButtonItem = rightBarItem;
    [self addCustomField];
    
}

-(void)addCustomField
{
    [self.BGView addSubview:self.showOrHiddenTextBtn1];
    [self.BGView addSubview:self.showOrHiddenTextBtn2];
    [self.BGView addSubview:self.picImageView];
    [self.BGView addSubview:self.passWordField1];
    [self.BGView addSubview:self.passWordField2];
    [self.view addSubview:self.BGView];
    [self.passWordField1 becomeFirstResponder];
}

-(void)showOrHiddenTextBtn1Clicked:(UIButton *)sender
{
    if (_passWordField1.text.length==0) {
        return;
    }
    sender.selected=!sender.selected;
    _passWordField1.secureTextEntry=!_passWordField1.secureTextEntry;
}

-(void)showOrHiddenTextBtn2Clicked:(UIButton *)sender
{
    if (_passWordField2.text.length==0) {
        return;
    }
    sender.selected=!sender.selected;
    _passWordField2.secureTextEntry=!_passWordField2.secureTextEntry;
}

-(void)finishBtnClicked
{
    [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
//    [self.navigationController popToRootViewControllerAnimated:YES];
    NSLog(@"finish");
    if ([self checkNewPassword]) {
        
        __weak WSocket *weakSocket = [WSocket sharedWSocket];
        __weak ForgetPassWordStep3 *weakSelf = self;
        __block NSString *weakPhone = _InscriptManager.wJid.phone;
        __block NSString *weakPwd = _passWordField1.text;
        __block NSString *weakCode=_codeString;
        
        [[WSocket sharedWSocket]resetPswWithPhone:weakPhone withPsw:weakPwd withCode:weakCode resetPswBlock:^(int success) {
            NSLog(@"STEP3==%d",success);
            dispatch_async(dispatch_get_main_queue(), ^{
                if (success==0) {
                    weakSocket.lbxManager.wJid.phone = weakPhone;
                    weakSocket.lbxManager.wJid.password = weakPwd;
                    [[NSUserDefaults standardUserDefaults]setObject:weakPhone forKey:kUserName];
                    [[NSUserDefaults standardUserDefaults]setObject:weakPwd forKey:kPassword];
                    [[NSUserDefaults standardUserDefaults]synchronize];
                    [weakSelf.navigationController popToRootViewControllerAnimated:YES];
                    
                }else if (success==kConnectFailue)
                {
                    weakSocket.lbxManager.wJid.phone = @"";
                    weakSocket.lbxManager.wJid.password = @"";
                    [weakSocket.lbxManager showHudViewLabelText:@"重置密码失败" detailsLabelText:nil afterDelay:1];
                }else
                {
                    [weakSocket.lbxManager showHudViewLabelText:@"网络不给力，请重试一下" detailsLabelText:nil afterDelay:1];
                }
            });
        }];
        [MBProgressHUD hideAllHUDsForView:[UIApplication sharedApplication].keyWindow animated:YES];
    }
}

-(BOOL)checkNewPassword
{
    if (_passWordField1.text.length==0 ||_passWordField2.text.length==0) {
        
        [_InscriptManager showHudViewLabelText:@"请填写密码" detailsLabelText:nil afterDelay:1];
        return NO;
    }
    else if(![_passWordField1.text isEqualToString:_passWordField2.text])
    {
        [_InscriptManager showHudViewLabelText:@"两次输入的密码不一致,请检查后重新输入" detailsLabelText:nil afterDelay:1];
        return NO;
    }
    else
    {
//        [_InscriptManager  wJid].password=_passWordField1.text;
        return YES;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
