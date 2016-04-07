//
//  UserInfoViewController.m
//  BigPinwheel
//
//  Created by xuwei on 16/2/26.
//  Copyright © 2016年 leita. All rights reserved.
//

#import "UserInfoViewController.h"
#import "WSocket.h"
#import "InscriptionManager.h"
#import "SexBtn.h"

@interface UserInfoViewController ()

@property(strong,nonatomic)UIButton *avatarBtn;     //头像
@property(strong,nonatomic)UITextField *nameTF;     //姓名
@property(strong,nonatomic)UIButton *farmBtn;       //农民
@property(strong,nonatomic)UIButton *driverBtn;     //司机
@property(strong,nonatomic)UIButton *boyBtn;        //性别男
@property(strong,nonatomic)UIButton *girlBtn;       //性别女
@property(assign,nonatomic)BOOL isSelectPhoto;     //是否选择了头像

@property(strong,nonatomic)NSMutableDictionary *info;    //个人信息总结

@property(strong,nonatomic)InscriptionManager *inspManager;
@property(strong,nonatomic)WSocket *wSocket;
@property(strong,nonatomic)UIActionSheet *myActionSheet;


@end

@implementation UserInfoViewController

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

-(instancetype)init
{
    self = [super init];
    if (self)
    {
        _inspManager = [InscriptionManager sharedManager];
        _wSocket = [WSocket sharedWSocket];
        _isSelectPhoto = NO;
        
        _info = [[NSMutableDictionary alloc]init];
        [_info setObject:@"1" forKey:@"sex"];
        [_info setObject:@"1" forKey:@"identity"];
        [_info setObject:@"1970-1-1" forKey:@"birthday"];
        [_info setObject:@"" forKey:@"signature"];
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NAVBAR(@"完善个人资料");
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(completeBtnClick:)];
    self.navigationItem.rightBarButtonItem = rightItem;
    self.view.backgroundColor = [UIColor whiteColor];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideTap)];
    [self.view addGestureRecognizer:tap];
    
    
    //头像avatarlabel avatarBtn sepline
    UILabel *avatarlabel = [self createLabelWithTextColor:[UIColor blackColor] frame:CGRectMake(23,64+44 , 124/2, 15) textFont:[UIFont systemFontOfSize:15] bgColor:[UIColor clearColor] layerFont:0 borderWith:0 textAligement:NSTextAlignmentLeft];
    avatarlabel.text = @"头像";
    [self.view addSubview:avatarlabel];
    
    _avatarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _avatarBtn.frame = CGRectMake(avatarlabel.frame.size.width+avatarlabel.frame.origin.x,64+ 20, 124/2, 124/2);
    _avatarBtn.backgroundColor = [UIColor whiteColor];
    [_avatarBtn.layer setMasksToBounds:YES];
    [_avatarBtn.layer setCornerRadius:124/4];
    [_avatarBtn.layer setBorderWidth:0.5];
    [_avatarBtn.layer setBorderColor:COLOR(225, 226, 228, 1).CGColor];
    [_avatarBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [_avatarBtn addTarget:self action:@selector(takePhotoAndUpdate) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_avatarBtn];
    
    UIView *sepline0 = [self creatLineWithFrame:CGRectMake(16, _avatarBtn.frame.size.height+_avatarBtn.frame.origin.y+18, kDeviceWidth -16, 0.5) BGColor:COLOR(226, 226, 226, 1)];
    [self.view addSubview:sepline0];
    
    //用户名 namelabel _nameTF
    UILabel *nameLabel = [self createLabelWithTextColor:[UIColor blackColor] frame:CGRectMake(19, sepline0.frame.size.height+sepline0.frame.origin.y+21,kDeviceWidth* 148/750, 14) textFont:[UIFont systemFontOfSize:14] bgColor:[UIColor clearColor] layerFont:0 borderWith:0 textAligement:NSTextAlignmentLeft];
    nameLabel.text = @"用户名";
    [self.view addSubview:nameLabel];
    _nameTF = [[UITextField alloc]initWithFrame:CGRectMake(nameLabel.frame.size.width+nameLabel.frame.origin.x,sepline0.frame.origin.y+sepline0.frame.size.height , kDeviceWidth -(nameLabel.frame.size.width+nameLabel.frame.origin.x), 56)];
    _nameTF.backgroundColor = [UIColor clearColor];
    _nameTF.keyboardType = UIKeyboardTypeDefault;
    [_nameTF setFont:[UIFont systemFontOfSize:14]];
    _nameTF.placeholder = @"请输入您的用户名";
    _nameTF.delegate = self;
    [self.view addSubview:_nameTF];
    
    UIView *sepline1 =[self creatLineWithFrame:CGRectMake(sepline0.frame.origin.x, _nameTF.frame.size.height+_nameTF.frame.origin.y, sepline0.frame.size.width, 0.5) BGColor:COLOR(226, 226, 226, 1)];
    [self.view addSubview:sepline1];
    
    //身份label _farmBtn _driverBtn
    UILabel *identifierLabel = [self createLabelWithTextColor:[UIColor blackColor] frame:CGRectMake(nameLabel.frame.origin.x,sepline1.frame.origin.y+0.5+20 , nameLabel.frame.size.width, nameLabel.frame.size.height) textFont:[UIFont systemFontOfSize:14] bgColor:[UIColor clearColor] layerFont:0 borderWith:0 textAligement:NSTextAlignmentLeft];
    identifierLabel.text = @"身份";
    [self.view addSubview:identifierLabel];
    
    _farmBtn = [self creatBtnWithFrame:CGRectMake(_nameTF.frame.origin.x-1, sepline1.frame.origin.y+0.5+36/2,kDeviceWidth* 169/750, 18) Title:@"农民"];
    _farmBtn.selected = YES;
    [_farmBtn addTarget:self action:@selector(identifierBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_farmBtn];
    _driverBtn = [self creatBtnWithFrame:CGRectMake(_farmBtn.frame.size.width+_farmBtn.frame.origin.x, _farmBtn.frame.origin.y, _farmBtn.frame.size.width, _farmBtn.frame.size.height) Title:@"司机"];
    [_driverBtn addTarget:self action:@selector(identifierBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_driverBtn];
    
    UIView *sepline2 = [self creatLineWithFrame:CGRectMake(sepline1.frame.origin.x, _farmBtn.frame.size.height+_farmBtn.frame.origin.y+39/2, sepline1.frame.size.width, 0.5) BGColor:COLOR(226, 226, 226, 1)];
    [self.view addSubview:sepline2];
    
    //性别sexLabel _boyBtn _girlBtn
    UILabel *sexLabel = [self createLabelWithTextColor:[UIColor blackColor] frame:CGRectMake(identifierLabel.frame.origin.x, sepline2.frame.origin.y+0.5+20, identifierLabel.frame.size.width, identifierLabel.frame.size.height) textFont:[UIFont systemFontOfSize:14] bgColor:[UIColor clearColor] layerFont:0 borderWith:0 textAligement:NSTextAlignmentLeft];
    sexLabel.text = @"性别";
    [self.view addSubview:sexLabel];
    
    _boyBtn = [self creatBtnWithFrame:CGRectMake(_farmBtn.frame.origin.x, sepline2.frame.origin.y+0.5+36/2, _farmBtn.frame.size.width, _farmBtn.frame.size.height) Title:@"男"];
    _boyBtn.selected = YES;
    [_boyBtn addTarget:self action:@selector(sexBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_boyBtn];
    _girlBtn = [self creatBtnWithFrame:CGRectMake(_driverBtn.frame.origin.x, _boyBtn.frame.origin.y, _driverBtn.frame.size.width, _driverBtn.frame.size.height) Title:@"女"];
    [_girlBtn addTarget:self action:@selector(sexBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_girlBtn];
    
    UIView *sepline3 = [self creatLineWithFrame:CGRectMake(sepline2.frame.origin.x, _boyBtn.frame.origin.y+_boyBtn.frame.size.height+39/2, sepline2.frame.size.width, 0.5) BGColor:COLOR(226, 226, 226, 1)];
    [self.view addSubview:sepline3];
    
}

#pragma mark -View创建工具

/// 有layerFont就设置没有为0   有border宽就设置，没有为0
- (UILabel *)createLabelWithTextColor:(UIColor *)textColor
                                frame:(CGRect)frame
                             textFont:(UIFont *)textFont
                              bgColor:(UIColor *)bgColor
                            layerFont:(CGFloat)layerFont
                           borderWith:(CGFloat)borderWith
                        textAligement:(NSTextAlignment)textAligement

{
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = bgColor == nil ? [UIColor clearColor] : bgColor;
    label.textColor = textColor;
    label.font = textFont;
    label.textAlignment = textAligement;
    
    if (layerFont > 0) {
        [label.layer setCornerRadius:layerFont];
        [label.layer setMasksToBounds:YES];
    }
    
    if (borderWith > 0) {
        [label.layer setBorderColor:COLOR(226, 144, 33, 1).CGColor];
        [label.layer setBorderWidth:borderWith];
    }
    
    return label;
}

//创建seplineView
-(UIView *)creatLineWithFrame:(CGRect)frame BGColor:(UIColor *)color
{
    UIView *line = [[UIView alloc]initWithFrame:frame];
    line.backgroundColor = color;
    return line;
}

//button创建工具
-(SexBtn *)creatBtnWithFrame:(CGRect)frame Title:(NSString *)title
{
    SexBtn *button = [SexBtn buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor clearColor];
    button.frame =frame;
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont systemFontOfSize:14]];
    button.imageSize = CGSizeMake(18, 18);
    [button setImage:[UIImage imageNamed:@"0230_unselect"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"0230_select"] forState:UIControlStateSelected];
    button.userInteractionEnabled = YES;
    return button;
    
}

#pragma mark -UItextFieldDelegate
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [_info setObject:[_inspManager hexStringFromString:textField.text] forKey:@"nick_name"];
}


#pragma mark -点击事件
///完成按钮点击
-(void)completeBtnClick:(UIButton *)sender
{
    if ([self checkInfo]==NO)
    {
        return;
    }
    
    [_info setObject:[_inspManager hexStringFromString:_nameTF.text] forKey:@"nick_name"];
    
    if ([_inspManager checkIsHasNetwork:YES]==NO)
    {
        return;
    }
    
    [self.view endEditing:YES];
    
    [_inspManager showHubAction:0 showView:self.view];
    
    if (_isSelectPhoto)
    {
        NSString *fileName = [NSString stringWithFormat:@"%.0f",[[NSDate date]timeIntervalSince1970]];
        
        __weak UserInfoViewController *weakSelf = self;
        __weak InscriptionManager *weakInspManger = _inspManager;
        
        [[WSocket sharedWSocket]addUploadFileOperationWithFilePath:nil data:UIImageJPEGRepresentation(_avatarBtn.imageView.image, 1) isFilePath:NO fileType:LBX_IM_DATA_TYPE_PICTURE fileName:fileName serialId:@"-1" modelType:ModelTypeNormal info:nil uploadBlock:^(int ret, NSString *fileName, NSString *fileUrl)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (ret>=0)
                {
                    NSLog(@"个人头像上传完成，开始上传个人资料");
                    [weakSelf.info setObject:fileUrl forKey:@"head_portrait"];
                    [weakSelf updateMyInfo];
                }else
                {
                    [weakInspManger showHudViewLabelText:@"资料上传失败，请稍后重试" detailsLabelText:nil afterDelay:1];
                    [weakInspManger showHubAction:1 showView:self.view];
                }
            });
        }];
    }else
    {
        [_wSocket.lbxManager showHudViewLabelText:@"请选择个人头像" detailsLabelText:nil afterDelay:1];
        //[self updateMyInfo];
    }
}

-(void)updateMyInfo
{
    
    __weak InscriptionManager *weakInspManager = [InscriptionManager sharedManager];
    __weak UserInfoViewController *weakSelf = self;
    __weak UITextField *weakNameTF = _nameTF;
    
    [[WSocket sharedWSocket]updateUserInfo:_info updateUserInfoBlock:^(int success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success ==0)
            {
                [weakInspManager showHudViewLabelText:@"资料上传成功，开始你的大丰车之旅吧" detailsLabelText:nil afterDelay:1];
                [weakInspManager getWJid].phone = [[NSUserDefaults standardUserDefaults]objectForKey:kUserName];
                [weakInspManager getWJid].password = [[NSUserDefaults standardUserDefaults]objectForKey:kPassword];
                [weakInspManager getWJid].identity = [[weakSelf.info objectForKey:@"identity"]intValue] ==2 ? @"司机": @"农民";
                [weakInspManager getWJid].sex = [[weakSelf.info objectForKey:@"sex"]intValue] ==2 ? @"女":@"男";
                [weakInspManager getWJid].nickname = weakNameTF.text;
                
                weakInspManager.dfcInfo.phone_num = [[NSUserDefaults standardUserDefaults]objectForKey:kUserName];
                weakInspManager.dfcInfo.nick_name = weakNameTF.text;
                weakInspManager.dfcInfo.identity = [NSString stringWithFormat:@"%@",[weakSelf.info objectForKey:@"identity"]];
                weakInspManager.dfcInfo.sex = [NSString stringWithFormat:@"%@",[weakSelf.info objectForKey:@"sex"]];
                
                [weakInspManager showHubAction:1 showView:weakSelf.view];
                [[NSUserDefaults standardUserDefaults]setObject:weakNameTF.text forKey:kNickName];
                [[NSUserDefaults standardUserDefaults]synchronize];
                [weakSelf.navigationController popToRootViewControllerAnimated:YES];
            }else
                     [weakInspManager showHudViewLabelText:@"资料上传失败，请稍后再试" detailsLabelText:nil afterDelay:1];
                     [weakInspManager showHubAction:1 showView:weakSelf.view];
        });
    }];

}

-(void)identifierBtnClick:(UIButton *)sender
{
    if (sender ==_farmBtn)
    {
        if (_farmBtn.selected ==YES)
        {
            return;
        }
        _farmBtn.selected = YES;
        _driverBtn.selected = NO;
        [self setValue:@"1" Key:@"identity"];
    }else if (sender ==_driverBtn)
    {
        if (_driverBtn.selected ==YES)
        {
            return;
        }
        _driverBtn.selected = YES;
        _farmBtn.selected = NO;
        [self setValue:@"2" Key:@"identity"];
    }
}
-(void)sexBtnClick:(UIButton *)sender
{
    if (sender ==_boyBtn) {
        if (_boyBtn.selected ==YES) {
            return;
        }
        _boyBtn.selected = YES;
        _girlBtn.selected = NO;
        [self setValue:@"1" Key:@"sex"];
    }else if (sender ==_girlBtn)
    {
        if (sender ==_girlBtn) {
            if (_girlBtn.selected ==YES) {
                return;
            }
            _girlBtn.selected = YES;
            _boyBtn.selected = NO;
            [self setValue:@"2" Key:@"sex"];
        }
    }
    
}

-(BOOL)checkInfo
{
    if (_nameTF.text.length<=0) {
        [_inspManager showHudViewLabelText:@"请填写一个昵称" detailsLabelText:nil afterDelay:1];
        return NO;
    }
    return YES;
}

-(void)setValue:(NSString *)value Key:(NSString *)key
{
    [_info setValue:value forKey:key];
}

-(void)hideTap
{
    [self.view endEditing:YES];
}

#pragma mark - 相册相机
- (void)takePhotoAndUpdate
{
    [self hideTap];
    
    //在这里呼出下方菜单按钮项
    _myActionSheet = [[UIActionSheet alloc]
                      initWithTitle:nil
                      delegate:self
                      cancelButtonTitle:@"取消"
                      destructiveButtonTitle:@"拍照"
                      otherButtonTitles: @"系统相册", nil];
    if (inspIsPad) {
        [_myActionSheet showInView:self.view];
    } else {
        [_myActionSheet showInView:[UIApplication sharedApplication].keyWindow];
    }
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //呼出的菜单按钮点击后的响应
    if (buttonIndex == _myActionSheet.cancelButtonIndex)
    {
        NSLog(@"取消");
    }
    
    switch (buttonIndex)
    {
        case 0:  //打开照相机拍照
            [self takePhoto];
            break;
        case 1:  //打开本地相册
            [self LocalPhoto];
            break;
    }
}

/// 开始拍照
-(void)takePhoto
{
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
    {
        if ([[InscriptionManager sharedManager] isCanUseCamera] == NO) {
            return;
        }
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        //设置拍照后的图片可被编辑
        picker.allowsEditing = YES;
        picker.sourceType = sourceType;
        
        if (inspIsPad) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self presentViewController:picker animated:NO completion:nil];
            }];
        } else {
            [self presentViewController:picker animated:NO completion:nil];
        }
    } else {
        NSLog(@"模拟其中无法打开照相机,请在真机中使用");
    }
}

/// 打开本地相册
-(void)LocalPhoto
{
    if ([[InscriptionManager sharedManager] isCanUsePhotoLibrary] == NO) {
        return;
    }
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    //设置选择后的图片可被编辑
    picker.allowsEditing = YES;
    if (inspIsPad) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self presentViewController:picker animated:NO completion:nil];
        }];
    } else {
        [self presentViewController:picker animated:NO completion:nil];
    }
}
/// 当选择一张图片后进入这里
-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    
    NSData *data = UIImageJPEGRepresentation(image, 0.7);
    if (!data) {
        data = UIImagePNGRepresentation(image);
    }
    
    UIImage *avatarPic = [UIImage imageWithData:data];
    [_avatarBtn setImage:avatarPic forState:UIControlStateNormal];
    _isSelectPhoto = YES;
    
    [picker dismissViewControllerAnimated:YES completion:^{
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    NSLog(@"您取消了选择图片");
    [picker dismissViewControllerAnimated:NO completion:nil];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

@end
