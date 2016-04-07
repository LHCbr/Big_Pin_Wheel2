//
//  AddViewController.m
//  LuLu
//
//  Created by lbx on 16/1/10.
//  Copyright © 2016年 lbx. All rights reserved.
//

#import "AddViewController.h"
#import "WSocket.h"
#import "ChatViewController.h"
#import "ContactViewController.h"


@interface AddViewController ()<UITextFieldDelegate>

@property (nonatomic, strong)UITextField *textField;

@property (nonatomic, strong)WSocket *wSocket;

@end


@implementation AddViewController

- (void)dealloc
{
    NSLog(@"朋友验证界面释放");
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.33 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self setEditing:NO animated:YES];
    });
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _wSocket = [WSocket sharedWSocket];
    NAVBAR(@"朋友验证");
    self.view.frame = CGRectMake(0, 64, kDeviceWidth, kDeviceHeight-64);
    
    UITapGestureRecognizer *endTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(endTap:)];
    [self.view addGestureRecognizer:endTap];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(30/2, 36/2+64,kDeviceWidth* 450/750, 14)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = COLOR(136, 136, 136, 1);
    label.font = [UIFont systemFontOfSize:12.5];
    label.textAlignment = NSTextAlignmentLeft;
    label.text = @"你需要发送验证申请, 等对方通过";
    [self.view addSubview:label];
    
    UIView *sepline0 = [[UIView alloc]initWithFrame:CGRectMake(0, label.frame.size.height+label.frame.origin.y+19/2, kDeviceWidth, 0.5)];
    sepline0.backgroundColor = COLOR(217, 217, 217, 1);
    [self.view addSubview:sepline0];
    
    _textField = [[UITextField alloc] initWithFrame:CGRectMake(0, sepline0.frame.size.height+sepline0.frame.origin.y, self.view.frame.size.width, 86/2)];
    _textField.backgroundColor = [UIColor whiteColor];
    _textField.delegate = self;
    
    UIView *leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 33/2, _textField.frame.size.height)];
    leftView.backgroundColor = [UIColor clearColor];
    _textField.leftViewMode = UITextFieldViewModeAlways;
    _textField.leftView = leftView;
    
    NSString *nickname = _wSocket.lbxManager.wJid.nickname;
    if (nickname.length<=0 || [nickname isEqualToString:@"(null)"])
    {
        if (_wSocket.lbxManager.wJid.phone.length ==11)
        {
            nickname = [NSString stringWithFormat:@"+%@ %@",_wSocket.lbxManager.wJid.area,_wSocket.lbxManager.wJid.phone];
        }
    }
    _textField.text = [NSString stringWithFormat:@"我是\"%@\"",[_wSocket.lbxManager stringFromHexString:nickname]];
    
    _textField.keyboardType = UIKeyboardTypeNamePhonePad;
    _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.view addSubview:_textField];
    [_textField becomeFirstResponder];
    
    UIView *sepline1 = [[UIView alloc]initWithFrame:CGRectMake(0, _textField.frame.size.height+_textField.frame.origin.y, kDeviceWidth, 0.5)];
    sepline1.backgroundColor = COLOR(217, 217, 217, 1);
    [self.view addSubview:sepline1];
    
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(doneClick)];

    self.navigationItem.rightBarButtonItem = rightButtonItem;
    
    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];

    self.navigationItem.leftBarButtonItem = leftButtonItem;
    
}

/// 完成添加
- (void)doneClick
{
    
//    if (_phone.length ==11)
//    {
        if ([_phone isEqualToString:_wSocket.lbxManager.dfcInfo.user_id])
        {
            return;
        }
        
        int response = [_wSocket addFriend_Force:_phone];
        
        NSLog(@"addResponse = %d",response);
        
        if (response >0)
        {
            [_wSocket.lbxManager showHudViewLabelText:@"添加好友成功" detailsLabelText:nil afterDelay:1];
            WJID *uJid = [_wSocket.lbxManager getUserInfoWithPhone:_phone];
            [self goChat:uJid];
        }
        else
        {
            [_wSocket.lbxManager showHudViewLabelText:@"添加好友失败" detailsLabelText:nil afterDelay:1];
            [self cancel];
        }
    //}
}

/// 去聊天
- (void)goChat:(WJID *)uJid
{
    ChatViewController *chatVC = [[ChatViewController alloc] init];
    chatVC.uJid = uJid;
    [chatVC createDirectory:uJid.phone];
    chatVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:chatVC animated:YES];
}

- (void)cancel
{
    CATransition* transition = [CATransition animation];
    transition.duration = 0.33;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    transition.type = kCATransitionReveal;
    transition.subtype = kCATransitionFade;
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    [self.navigationController popViewControllerAnimated:NO];
}

-(void)endTap:(UITapGestureRecognizer *)tap
{
    [self.view endEditing:YES];
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
