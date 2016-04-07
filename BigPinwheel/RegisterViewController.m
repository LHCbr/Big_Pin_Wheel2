//
//  RegisterViewController.m
//  BigPinwheel
//
//  Created by 徐伟 on 16/2/25.
//  Copyright © 2016年 leita. All rights reserved.
//

#import "RegisterViewController.h"
#import "InscriptionManager.h"
#import "WSocket.h"
#import "SelectBtn.h"
#import "VerficationCodeViewController.h"

@interface RegisterViewController ()

@property(strong,nonatomic)UITextField *phoneTF;
@property(strong,nonatomic)UITextField *passwardTF;

@property(strong,nonatomic)SelectBtn *selectBtn;            //协议按钮

@property(strong,nonatomic)InscriptionManager *inspManager;

@property(assign,nonatomic)NSInteger length;

@property(assign,nonatomic)BOOL isSelectCategory;          //是否去查看协议而离开界面

@end

@implementation RegisterViewController


-(void)dealloc
{
    NSLog(@"登录界面释放");
    [self.view endEditing:YES];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (_phoneTF){
        [_phoneTF becomeFirstResponder];
    }
    if (_isSelectCategory){
        _isSelectCategory = NO;
    }
    return;
    
    _isSelectCategory = NO;
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

-(instancetype)init
{
    self = [super init];
    if (self)
    {
        _isSelectCategory = NO;
        _inspManager = [InscriptionManager sharedManager];
        
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    NAVBAR(@"注册");
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc]initWithTitle:@"下一步" style:UIBarButtonItemStylePlain target:self action:@selector(BarBtnClick:)];
    self.navigationItem.rightBarButtonItem = rightBarItem;
    
    //初始化HeaderView
    [self customHeaderView];
    
    //初始化TextField
    [self customTextField];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(endEditing:)];
    [self.view addGestureRecognizer:tap];
    
}

#pragma mark -View创建工具

-(void)customHeaderView
{
    UIView *headSepView = [self creatLineWithFrame:CGRectMake(0, 64, kDeviceWidth, 8.5) BGColor:kBGColor];
    [self.view addSubview:headSepView];
    
    UIView *sepLine = [self creatLineWithFrame:CGRectMake(0, headSepView.frame.size.height+headSepView.frame.origin.y,kDeviceWidth,0.5) BGColor:COLOR(220, 222, 216, 1)];
    [self.view addSubview:sepLine];
    
}

-(void)customTextField
{
    //_phoneTF _passwardTF sepline
    _phoneTF = [self creatTextFieldWithY:64+8.5 PlaceHolder:@"请输入手机号" isScure:NO ImageName:@"0225_phone"];
    [_phoneTF addTarget:self action:@selector(limitLength:) forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:_phoneTF];
    
    _passwardTF = [self creatTextFieldWithY:_phoneTF.frame.size.height+_phoneTF.frame.origin.y+0.5 PlaceHolder:@"请输入6-20位密码" isScure:YES ImageName:@"0225_pwd"];
    [self.view addSubview:_passwardTF];
    
    UIView *sepline0 = [self creatLineWithFrame:CGRectMake(111/2,_phoneTF.frame.origin.y+_phoneTF.frame.size.height, kDeviceWidth -111/2, 0.5) BGColor:COLOR(220, 222, 216, 1)];
    [self.view addSubview:sepline0];
    
    UIView *sepline1 = [self creatLineWithFrame:CGRectMake(sepline0.frame.origin.x, _passwardTF.frame.size.height+_passwardTF.frame.origin.y, sepline0.frame.size.width, 0.5) BGColor:COLOR(220, 222, 216, 1)];
    [self.view addSubview:sepline1];
    
    //同意协议按钮
    _selectBtn = [SelectBtn buttonWithType:UIButtonTypeCustom];
    _selectBtn.backgroundColor = [UIColor clearColor];
   
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc]initWithString:@"我已阅读并同意 注册协议"];
    [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(0, str.length)];
    [str addAttribute:NSForegroundColorAttributeName value:COLOR(153, 153, 153, 1) range:NSMakeRange(0, str.length -5)];
    [str addAttribute:NSForegroundColorAttributeName value:COLOR(26, 103, 182, 1) range:NSMakeRange(str.length-5, 5)];
    
    CGRect rect = [str boundingRectWithSize:CGSizeMake(200, 20) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    _selectBtn.imageSize = CGSizeMake(15, 15);
    _selectBtn.frame = CGRectMake(116/2, CGRectGetMaxY(sepline1.frame)+22,rect.size.width +7+15, 20);
    
    [_selectBtn setAttributedTitle:str forState:UIControlStateNormal];
    [_selectBtn setImage:[UIImage imageNamed:@"0226_select"] forState:UIControlStateNormal];
    _selectBtn.tag =0;
    [_selectBtn addTarget:self action:@selector(selectBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_selectBtn];
    
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
    
    if ([placeHoler isEqualToString:@"请输入6-20位密码"])
    {
        textfield.rightView = rightView;
        textfield.keyboardType = UIKeyboardTypeNamePhonePad;
        textfield.clearButtonMode = UITextFieldViewModeWhileEditing;
    }
    return textfield;
}

#pragma mark -点击事件
//_passwordTF点击事件
-(void)buttonClick:(UIButton *)sender
{
    if (sender.tag%2==1)
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

///同意按钮点击事件
-(void)selectBtnClick:(SelectBtn *)sender
{
    if (sender.tag%2==1) {
        [sender setImage:[UIImage imageNamed:@"0226_select"] forState:UIControlStateNormal];
    }
    else
    {
        [sender setImage:[UIImage imageNamed:@"0226_unselect"] forState:UIControlStateNormal];
    }
    sender.tag = sender.tag +1;
}

//结束编辑
-(void)endEditing:(UITapGestureRecognizer *)tap
{
    [self.view endEditing:YES];
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

///提交前的检查
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
        [_inspManager showHudViewLabelText:@"请输入6-20位密码" detailsLabelText:nil afterDelay:kAfterDelayTime];
        return NO;
    }
    if (_passwardTF.text.length<6||_passwardTF.text.length>20)
    {
        [_inspManager showHudViewLabelText:@"密码长度6-20为密码" detailsLabelText:nil afterDelay:1];
        return NO;
    }
    
    if (range.length>0) {
        [_inspManager showHudViewLabelText:@"密码中不能有空格" detailsLabelText:nil afterDelay:kAfterDelayTime];
        return NO;
    }
    
    if (_selectBtn.tag %2==1) {
        [_inspManager showHudViewLabelText:@"请选择同意协议" detailsLabelText:nil afterDelay:1];
        return NO;
    }
    
    return YES;
    
}

///RightNavBar按钮点击事件
-(void)BarBtnClick:(UIButton *)sender
{
    if ([self checkInfo]==NO) {
        return;
    }
    
    [self.view endEditing:YES];
    
    self.navigationController.interactivePopGestureRecognizer.enabled =NO;
    
    NSString *username = [_phoneTF.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *passward = [_passwardTF.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    _inspManager.wJid.phone = username;
    _inspManager.wJid.password = passward;
    
    VerficationCodeViewController *verfiCodeVC = [[VerficationCodeViewController alloc]init];
    [self.navigationController pushViewController:verfiCodeVC animated:YES];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
