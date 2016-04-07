//
//  ForgetPassWordStep1.m
//  BigPinwheel
//
//  Created by xumckay on 16/3/9.
//  Copyright © 2016年 leita. All rights reserved.
//

#import "ForgetPassWordStep1.h"
#import "InscriptionManager.h"
#import "ForgetPassWordStep2.h"


@interface ForgetPassWordStep1 ()

@property(strong,nonatomic)UITextField *mobileNumber;

@property (strong,nonatomic)UIView *BGView;

@property (strong,nonatomic)UIImageView *picImageView;

@property(assign,nonatomic)NSInteger length;          //手机号码长度


@end

@implementation ForgetPassWordStep1

-(UITextField *)mobileNumber
{
    if (!_mobileNumber) {
        _mobileNumber=[[UITextField alloc]initWithFrame:CGRectMake(60,0,kDeviceWidth-60,53)];
        _mobileNumber.placeholder=@"请输入手机号";
        [_mobileNumber addTarget:self action:@selector(limitLength:) forControlEvents:UIControlEventEditingChanged];
        _mobileNumber.keyboardType=UIKeyboardTypePhonePad;
       
    }
    return _mobileNumber;
}

-(UIView *)BGView
{
    if (!_BGView) {
        _BGView=[[UIView alloc]initWithFrame:CGRectMake(0,64+10,kDeviceWidth,53)];
        _BGView.backgroundColor=[UIColor whiteColor];
    }
    return _BGView;
}

-(UIImageView *)picImageView
{
    if (!_picImageView) {
        
        _picImageView=[[UIImageView alloc]initWithFrame:CGRectMake(53-25,26.5-8.5,16,17)];
        [_picImageView setImage:[UIImage imageNamed:@"0225_phone"]];
        
    }
    return _picImageView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NAVBAR(@"忘记密码");
    self.view.backgroundColor=COLOR(241, 242, 236,1);
    
    
    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc]initWithTitle:@"下一步" style:UIBarButtonItemStylePlain target:self action:@selector(BarBtnClick)];
    self.navigationItem.rightBarButtonItem = rightBarItem;
    
    [self addTextField];
}

-(void)BarBtnClick
{
    NSString *phoneNumber=_mobileNumber.text;
    phoneNumber=[phoneNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([[InscriptionManager sharedManager]checkPhoneNum:phoneNumber]) {
        
        [[InscriptionManager sharedManager] wJid].phone=phoneNumber;
        ForgetPassWordStep2 *VC=[[ForgetPassWordStep2 alloc]init];
        [self.navigationController pushViewController:VC animated:YES];
    }
    else
    {
        [[InscriptionManager sharedManager]showHudViewLabelText:@"您输入的手机号格式不正确,请检查后再次输入" detailsLabelText:nil afterDelay:1];
    }
}


-(void)addTextField
{
    [self.BGView addSubview:self.picImageView];
    [self.BGView addSubview:self.mobileNumber];
    [self.view addSubview:self.BGView];
    [_mobileNumber becomeFirstResponder];
}

- (void)limitLength:(UITextField *)sender
{
    if (sender == _mobileNumber)
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
//                [_mobileNumber becomeFirstResponder];
            }
        }
        _length = len;
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
