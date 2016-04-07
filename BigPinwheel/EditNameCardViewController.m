//
//  EditNameCardViewController.m
//  BigPinwheel
//
//  Created by xuwei on 16/3/3.
//  Copyright © 2016年 leita. All rights reserved.
//

#import "EditNameCardViewController.h"
#import "EditNameCardCell.h"
#import "WSocket.h"
#import "SexIdentityPickerView.h"
#import "TipView.h"
#import <MBProgressHUD.h>


@interface EditNameCardViewController ()<UIPickerViewDataSource,UIPickerViewDelegate,tipViewDelegate>

@property(strong,nonatomic)WSocket *wSocket;
@property(strong,nonatomic)UIButton *avatarBtn;
@property(assign,nonatomic)BOOL isSelectPhoto;
@property(assign,nonatomic)BOOL isSelectCity;
@property(assign,nonatomic)BOOL isSelectPhone;

@property(strong,nonatomic)UITextField *nickTF;
@property(strong,nonatomic)UITextField *phoneTF;
@property(strong,nonatomic)UITextField *signatureTF;
@property(strong,nonatomic)UILabel *isShowPhonelabel;

@property(strong,nonatomic)NSDictionary *keyboardDict;

@property (strong,nonatomic)UIView *PVBgView;
@property (strong,nonatomic)UIView *normalBGView;
@property(strong,nonatomic)UIActionSheet *myActionSheet;

//-------四个要用到的pickerView
@property(strong,nonatomic)UIPickerView *sexPickerView;

@property (strong,nonatomic)UIDatePicker *BirthdayPickerView;

@property (strong,nonatomic)UIPickerView *permanentPickerView;//常住地pickerView

@property (strong,nonatomic)UIPickerView *identifierPickerView;

@property (strong,nonatomic)UITapGestureRecognizer *tap;

@property(strong,nonatomic)NSArray *areaArray;

@property (strong,nonatomic)TipView *tipView;

//----四个滚轮选中的文本
@property (copy,nonatomic)NSString *selectedSex;

@property (copy,nonatomic)NSString *selectedBirthday;

@property(copy,nonatomic)NSString *selectedNickName; //修改后的昵称

@property(copy,nonatomic)NSString *temDateStr;

@property (copy,nonatomic)NSString *selectedPermanent;

@property (copy,nonatomic)NSString *selectedIdentifier;

@property (copy,nonatomic)NSString *selectedSegement;   //修改后的需求签名

@property (copy,nonatomic)NSString *selectedPhone;      //修改后的电话号码

@property (strong,nonatomic)UIWindow *keyWindow;

@property(strong,nonatomic)MBProgressHUD *hudProcess;

@property(strong,nonatomic)NSTimer *saveTimer;

@property(assign,nonatomic)BOOL isStartTimer;


@end

@implementation EditNameCardViewController

- (void)dealloc
{
    NSLog(@"编辑名片界面释放");
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

static int countIndex = 40;
-(void)checkBtnStatus:(NSTimer *)timer
{
    if (_isStartTimer==YES)
    {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        self.navigationItem.rightBarButtonItem.enabled = NO;
        
        countIndex --;
        if (countIndex ==0)
        {
            [_hudProcess hide:YES];
            [_wSocket.lbxManager showHubAction:1 showView:self.view];
            [_wSocket.lbxManager showHudViewLabelText:@"网络环境较差，未能更新成功" detailsLabelText:nil afterDelay:1];
            [self resetTimer];
        }
    }
    else
    {
        [_hudProcess hide:YES];
        [_wSocket.lbxManager showHubAction:1 showView:self.view];
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        self.navigationItem.rightBarButtonItem.enabled = YES;

        [_saveTimer setFireDate:[NSDate distantFuture]];
    }
}

-(void)resetTimer
{
    countIndex =30;
    [_saveTimer setFireDate:[NSDate distantFuture]];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    self.navigationItem.rightBarButtonItem.enabled = YES;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (_saveTimer ==nil)
    {
        _saveTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(checkBtnStatus:) userInfo:nil repeats:YES];
        [_saveTimer setFireDate:[NSDate distantFuture]];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (_saveTimer) {
        [_saveTimer invalidate];
        _saveTimer = nil;
    }
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
        _isSelectPhoto = NO;
        _isSelectCity = NO;
        _isSelectPhone = NO;
        _wSocket = [WSocket sharedWSocket];
        _info = [[NSMutableDictionary alloc]init];
        _isStartTimer = NO;
        
        DFCUserInfo *tempinfo = _wSocket.lbxManager.dfcInfo;
        [_info setObject:tempinfo.sex forKey:@"sex"];
        [_info setObject:tempinfo.identity forKey:@"identity"];
        [_info setObject:tempinfo.head_portrait forKey:@"head_portrait"];
        [_info setObject:tempinfo.birthday forKey:@"birthday"];
        [_info setObject:[_wSocket.lbxManager stringFromHexString:tempinfo.nick_name] forKey:@"nick_name"];
        [_info setObject:[_wSocket.lbxManager stringFromHexString:tempinfo.signature] forKey:@"signature"];
        
        NSLog(@"默认提交的userinfo = %@",_info);
        
        _placeInfo = [[NSMutableDictionary alloc]init];
        [_placeInfo setObject:@"中国" forKey:@"country"];
        [_placeInfo setObject:_wSocket.lbxManager.dfcInfo.provice forKey:@"province"];
        [_placeInfo setObject:_wSocket.lbxManager.dfcInfo.city forKey:@"city"];
        [_placeInfo setObject:_wSocket.lbxManager.dfcInfo.region forKey:@"region"];
        [_placeInfo setObject:_wSocket.lbxManager.dfcInfo.remaining_addr forKey:@"remaining_addr"];
        [_placeInfo setObject:_wSocket.lbxManager.dfcInfo.longitude forKey:@"longitude"];
        [_placeInfo setObject:_wSocket.lbxManager.dfcInfo.latitude forKey:@"latitude"];
        [_placeInfo setObject:_wSocket.lbxManager.dfcInfo.phone_num forKey:@"phone"];
        [_placeInfo setObject:_wSocket.lbxManager.dfcInfo.phone_show_flag forKey:@"phone_show_flag"];
        
        NSLog(@"默认提交的placeinfo = %@",_placeInfo);
        
        _properArray = [NSMutableArray arrayWithObjects:@"昵称",
                                                        @"性别",
                                                        @"出生日期",
                                                        @"常住地",
                                                        @"联系方式",
                                                        @"身份",
                                                        @"需求签名",
                                                        nil];
        
        NSString *placeStr = [NSString stringWithFormat:@"%@",tempinfo.city];
        _dataArray = [NSMutableArray arrayWithObjects:[_wSocket.lbxManager stringFromHexString:tempinfo.nick_name],
                                                      tempinfo.sex,
                                                      tempinfo.birthday,
                                                      placeStr,
                                                      tempinfo.phone_num,
                                                      [NSString stringWithFormat:@"%@",tempinfo.identity] ,
                                                      tempinfo.signature,
                                                      nil];
        
        NSString *path=[[NSBundle mainBundle]pathForResource:@"area" ofType:@"plist"];
        _areaArray=[[NSArray alloc]initWithContentsOfFile:path];
    }
    return self;
}

-(UIView *)tipView
{
    if (!_tipView)
    {
        _tipView=[[TipView alloc]initWithFrame:CGRectMake(0,0,kDeviceWidth,42)];
        _tipView.delegate=self;
    }
    return _tipView;
}

-(void)cancelBtnClicked
{
    [self hiddenCoverView];
}

-(void)sureBtnClicked
{
    if (!_selectedSex) {
        _selectedSex=@"男";
        [_info setObject:@"1" forKey:@"sex"];
    }
    [self hiddenCoverView];

    [_tableView reloadData];
}

-(UITapGestureRecognizer *)tap
{
    if (!_tap) {
        _tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hiddenCoverView)];
    }
    return _tap;
}

-(UIView *)normalBGView
{
    if (!_normalBGView)
    {
        _normalBGView=[[UIView alloc]initWithFrame:CGRectMake(0,0,kDeviceWidth,kDeviceHeight-216)];
        _normalBGView.backgroundColor=[UIColor blackColor];
        _normalBGView.alpha=0.6;
        _normalBGView.userInteractionEnabled=YES;
        [_normalBGView addGestureRecognizer:self.tap];
    }
    return _normalBGView;
}

-(UIView *)PVBgView
{
    if (!_PVBgView)
    {
        _PVBgView=[[UIView alloc]initWithFrame:CGRectMake(0,kDeviceHeight-216,kDeviceWidth,216)];
        _PVBgView.backgroundColor=[UIColor whiteColor];
    }
    return _PVBgView;
}

-(UIPickerView *)sexPickerView
{
    if (!_sexPickerView)
    {
        _sexPickerView=[[UIPickerView alloc]initWithFrame:CGRectMake(0,0,kDeviceWidth,216)];
        _sexPickerView.delegate=self;
        _sexPickerView.dataSource=self;
        _sexPickerView.tag=100;
        _sexPickerView.backgroundColor=[UIColor whiteColor];
        _sexPickerView.userInteractionEnabled=YES;
        [_sexPickerView addSubview:self.tipView];
    }
    return _sexPickerView;
}

-(UIPickerView *)permanentPickerView
{
    if (!_permanentPickerView)
    {
        
        _permanentPickerView=[[UIPickerView alloc]initWithFrame:CGRectMake(0,0,kDeviceWidth,216)];
        _permanentPickerView.delegate=self;
        _permanentPickerView.dataSource=self;
        _permanentPickerView.tag=101;
        _permanentPickerView.backgroundColor=[UIColor whiteColor];
        [_permanentPickerView addSubview:self.tipView];
    }
    return _permanentPickerView;
}

-(UIPickerView *)identifierPickerView
{
    if (!_identifierPickerView) {
        _identifierPickerView=[[UIPickerView alloc]initWithFrame:CGRectMake(0,0,kDeviceWidth, 216)];
        _identifierPickerView.delegate=self;
        _identifierPickerView.dataSource=self;
        _identifierPickerView.tag=102;
        _identifierPickerView.backgroundColor=[UIColor whiteColor];
        _identifierPickerView.userInteractionEnabled=YES;
        [_identifierPickerView addSubview:self.tipView];
    }
    return _identifierPickerView;
}

-(UIDatePicker *)BirthdayPickerView
{
    if (!_BirthdayPickerView)
    {
        _BirthdayPickerView=[[UIDatePicker alloc]initWithFrame:CGRectMake(0,0,kDeviceWidth,216)];
        NSLocale *locale=[[NSLocale alloc]initWithLocaleIdentifier:@"zh_CN"];
        _BirthdayPickerView.locale=locale;
        _BirthdayPickerView.backgroundColor=[UIColor whiteColor];
        [_BirthdayPickerView setDatePickerMode:UIDatePickerModeDate];
        [_BirthdayPickerView addSubview:self.tipView];
        
        [_BirthdayPickerView addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _BirthdayPickerView;
}

-(void)datePickerValueChanged:(UIDatePicker*)sender
{
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc]init];
    
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];

    NSDate *date=sender.date;
    
    [dateFormatter setDateFormat:@"YYYY-MM-dd"];
    _selectedBirthday=[dateFormatter stringFromDate:date];
    
    [dateFormatter setDateFormat:@"YYYY-MM-dd"];
    _temDateStr = [dateFormatter stringFromDate:date];
    
    [_info setObject:_temDateStr forKey:@"birthday"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"我的名片";
    
    
    [self customNavBar];
    
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kDeviceWidth, kDeviceHeight) style:UITableViewStylePlain];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.tableHeaderView = [[UIView alloc]init];
    _tableView.tableFooterView = [[UIView alloc]init];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
    
    [self customHeaderView];
    
    UITapGestureRecognizer *endEditingTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideTap)];
    [self.view addGestureRecognizer:endEditingTap];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
}

#pragma mark - View创建工具
//初始化NavBar
-(void)customNavBar
{
    UIBarButtonItem *saveBarItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"0328_save"] style:UIBarButtonItemStylePlain target:self action:@selector(saveBarBtnClick:)];
    self.navigationItem.rightBarButtonItem = saveBarItem;
}

//创建HeaderView
-(void)customHeaderView
{
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kDeviceWidth, 171/2)];
    headerView.backgroundColor = [UIColor whiteColor];
    _tableView.tableHeaderView = headerView;

    UILabel *label = [self createLabelWithTextColor:COLOR(128, 128, 128, 1) frame:CGRectMake(12, (headerView.frame.size.height -14)/2, headerView.frame.size.width -12, 14) textFont:[UIFont systemFontOfSize:14] bgColor:[UIColor clearColor] layerFont:0 borderWith:0 textAligement:NSTextAlignmentLeft];
    label.text = @"头像";
    [headerView addSubview:label];
    
    _avatarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _avatarBtn.backgroundColor = [UIColor clearColor];
    _avatarBtn.frame =CGRectMake(kDeviceWidth* 175/750, (headerView.frame.size.height -61)/2, 61, 61);
    [_avatarBtn setImage:kDefaultAvatarImage forState:UIControlStateNormal];
    [_avatarBtn.layer setMasksToBounds:YES];
    [_avatarBtn.layer setCornerRadius:6];
    [_avatarBtn addTarget:self action:@selector(takePhotoAndUpdate) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:_avatarBtn];
    
        __weak EditNameCardViewController *weakSelf = self;
        __weak WSocket *weakSocket = _wSocket;
    
        [_wSocket addDownFileOperationWithFileUrlString:_wSocket.lbxManager.dfcInfo.head_portrait serialId:@"-1" modelType:ModelTypeNormal info:nil downBlock:^(int ret, int isSave, NSData *data, NSString *fileUrl) {
            dispatch_async(dispatch_get_main_queue(), ^{
    
                if (ret>=0) {
                    [weakSelf.avatarBtn setImage:[UIImage imageWithData:data] forState:UIControlStateNormal];
                    if (isSave) {
                        [data writeToFile:[NSString stringWithFormat:@"%@/%@",kPathAvatar,[weakSocket.lbxManager upper16_MD5:fileUrl]] atomically:YES];
                    }
                }
                else
                    [weakSelf.avatarBtn setImage:kDefaultAvatarImage forState:UIControlStateNormal];
            });
        }];

    UIView *sepline = [[UIView alloc]initWithFrame:CGRectMake(_avatarBtn.frame.origin.x+0.5, headerView.frame.size.height-0.5, kDeviceWidth-(_avatarBtn.frame.origin.x+0.5), 0.5)];
    sepline.backgroundColor = COLOR(221, 221, 221, 1);
    [headerView addSubview:sepline];
    
}

#pragma mark -点击事件
-(BOOL)checkInfo
{
    if (_nickTF.text.length<=0)
    {
        [_wSocket.lbxManager showHudViewLabelText:@"请填写你的昵称" detailsLabelText:nil afterDelay:1];
        return NO;
    }
    else if (_phoneTF.text.length<=0)
    {
        [_wSocket.lbxManager showHudViewLabelText:@"请填写你的手机号" detailsLabelText:nil afterDelay:1];
        return NO;
    }
    return YES;
}

-(void)saveBarBtnClick:(UIButton *)sender
{
    [self.view endEditing:YES];
    
    if ([self checkInfo]==NO)
    {
        return;
    }
    _isStartTimer = YES;
    [_saveTimer setFireDate:[NSDate distantPast]];
    [_wSocket.lbxManager showHubAction:0 showView:self.view];
    _hudProcess = [_wSocket.lbxManager ShowHubProgress:@""];
    
        if (_isSelectPhoto)
        {
            NSString *filename = [NSString stringWithFormat:@"%.0f",[[NSDate date]timeIntervalSince1970]];
            __weak EditNameCardViewController *weakSelf = self;
            __weak WSocket *weakSocket = _wSocket;
            
            [[WSocket sharedWSocket]addUploadFileOperationWithFilePath:nil data:UIImageJPEGRepresentation(_avatarBtn.imageView.image, 1) isFilePath:NO fileType:LBX_IM_DATA_TYPE_PICTURE fileName:filename serialId:@"-1" modelType:ModelTypeNormal info:nil uploadBlock:^(int ret, NSString *fileName, NSString *fileUrl) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if (ret >=0) {
                        NSLog(@"个人头像上传完成，开始上传资料");
                        [_hudProcess hide:YES];
                        [weakSelf.info setObject:fileUrl forKey:@"head_portrait"];
                        [weakSelf updateMyInfo:fileUrl];
                    }
                    else
                    {
                        [_hudProcess hide:YES];
                        [weakSocket.lbxManager showHudViewLabelText:@"个人头像上传失败，请稍后再试" detailsLabelText:nil afterDelay:kAfterDelayTime];
                        [weakSocket.lbxManager showHubAction:1 showView:self.view];
                        _isStartTimer = NO;
                        [weakSelf checkBtnStatus:nil];
                    }
                });
            }];
        }
        else
        {
            [self updateMyInfo:nil];
        }
}

-(void)updateMyInfo:(NSString *)fileUrl
{
    NSLog(@"提交之前的info字典  =%@",_info);
    __weak EditNameCardViewController *weakSelf = self;
    __weak WSocket *weakSocket = _wSocket;
    [[WSocket sharedWSocket]updateUserInfo:_info updateUserInfoBlock:^(int success) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (success >=0) {
                
                if (_isSelectCity==YES||_isSelectPhone ==YES)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self updateMyPlace];
                    });
                }else
                {
                    _isStartTimer = NO;
                    [weakSelf checkBtnStatus:nil];
                    [weakSocket.lbxManager showHubAction:1 showView:nil];
                    [weakSocket.lbxManager showHudViewLabelText:@"更新个人资料成功" detailsLabelText:nil afterDelay:1];
                }
            }
            else
            {
                _isStartTimer = NO;
                [weakSelf checkBtnStatus:nil];
                [_saveTimer setFireDate:[NSDate distantFuture]];
                [weakSocket.lbxManager showHudViewLabelText:@"更新个人资料失败" detailsLabelText:nil afterDelay:kAfterDelayTime];
                [weakSocket.lbxManager showHubAction:1 showView:nil];
            }
        });
        
    }];
 }

-(void)updateMyPlace
{
    
    NSLog(@"提交之前的placeinfo = %@",_placeInfo);
    __weak WSocket *weakSocket = _wSocket;
    
    [[WSocket sharedWSocket]updateUserInfo:_placeInfo updateUserInfoBlock:^(int success) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSLog(@"successsss = %d",success);
            
            if (success >=0) {
                _isStartTimer = NO;
                [weakSocket.lbxManager showHudViewLabelText:@"更新个人地址成功" detailsLabelText:nil afterDelay:1];
                [weakSocket.lbxManager showHubAction:1 showView:nil];
            }
            else
            {
                _isStartTimer = NO;
                [weakSocket.lbxManager showHudViewLabelText:@"更新个人地址失败" detailsLabelText:nil afterDelay:1];
                [weakSocket.lbxManager showHubAction:1 showView:nil];
            }
            
        });
    }];
}

-(void)hiddenCoverView
{
    [self.normalBGView removeFromSuperview];
    [self.PVBgView removeFromSuperview];
    [self.sexPickerView removeFromSuperview];
    [self.BirthdayPickerView removeFromSuperview];
    [self.permanentPickerView removeFromSuperview];
    [self.identifierPickerView removeFromSuperview];
}

-(void)hideTap
{
    [self.view endEditing:YES];
}


//结束编辑
-(void)endEditing:(UITapGestureRecognizer *)tap
{
    [self.view endEditing:YES];
}

-(void)keyBoardWillShow:(NSNotification *)noti
{
    _keyboardDict = [noti userInfo];
    CGSize kbSize = [[_keyboardDict objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue].size;
    CGFloat duration = [[_keyboardDict objectForKey:UIKeyboardAnimationDurationUserInfoKey]floatValue];
    if ([_phoneTF isFirstResponder]==YES)
    {
        [UIView animateWithDuration:duration animations:^{
            [_tableView setContentOffset:CGPointMake(0, 22)];
        }];
    }
    if ([_signatureTF isFirstResponder]==YES) {
        [UIView animateWithDuration:duration animations:^{
            [_tableView setContentOffset:CGPointMake(0, 66)];
        }];
    }
}

/// 键盘收起
- (void)keyboardWillHide:(NSNotification *)noti
{
    if ([_phoneTF resignFirstResponder]==YES) {
        [_tableView setContentOffset:CGPointMake(0, -66)];
    }
    if ([_signatureTF resignFirstResponder]==YES) {
        [_tableView setContentOffset:CGPointMake(0, -66)];
    }
}

#pragma mark - UITabelViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}


#pragma mark - UITableViewDataSource

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"normalcell";
    EditNameCardCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell ==nil) {
        cell = [[EditNameCardCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        
        UISwitch *boolSwith = [[UISwitch alloc]initWithFrame:CGRectMake(0, 0, 50, 30)];
        [boolSwith setHidden:YES];
        [boolSwith addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = boolSwith;
    }
    cell.label.text = [_properArray objectAtIndex:indexPath.row];
    cell.textField.text = [NSString stringWithFormat:@"%@",[_dataArray objectAtIndex:indexPath.row]];
    cell.textField.tag = indexPath.row;
    cell.textField.delegate=self;
    
    if (indexPath.row ==0)
    {
        _nickTF = cell.textField;
        if (_selectedNickName)
        {
            cell.textField.text=_selectedNickName;
        }
        cell.textField.returnKeyType = UIReturnKeyDone;
    }
    else if (indexPath.row==1) {
        
        cell.textField.placeholder=@"点击选择性别";
        cell.textField.text = [[_dataArray objectAtIndex:indexPath.row] integerValue] == 1 ? @"男" :@"女";
        if (_selectedSex)
        {
            cell.textField.text=_selectedSex;
        }
        
    }else if (indexPath.row==2)
    {
        cell.textField.placeholder=@"点击选择出生日期";
        
        if(_selectedBirthday.length)
        {
            cell.textField.text=_selectedBirthday;
        }
        
    }else if (indexPath.row==3)
    {
        cell.textField.placeholder=@"点击选择常住地";
        if (_selectedPermanent)
        {
            cell.textField.text=[NSString stringWithFormat:@"%@",_selectedPermanent];
        }
    }
    else if (indexPath.row==5)
    {
        cell.textField.placeholder=@"点击选择身份";
        cell.textField.text = [[_dataArray objectAtIndex:indexPath.row]integerValue] ==1 ?@"农民":@"司机";
        if (_selectedIdentifier) {
            cell.textField.text=_selectedIdentifier;
        }
    }
    else if (indexPath.row==6)
    {
        cell.textField.returnKeyType=UIReturnKeyDone;
        //[cell.sepline setHidden:YES];
        if (_selectedSegement) {
            cell.textField.text=_selectedSegement;
        }
    }
    else if (indexPath.row ==_properArray.count -3)
    {
        cell.textField.keyboardType = UIKeyboardTypeNumberPad;
        cell.textField.placeholder = @"请输入联系方式";
        UISwitch *swit = (UISwitch *)cell.accessoryView;
        [swit setHidden:NO];
        BOOL ison = [_wSocket.lbxManager.dfcInfo.phone_show_flag intValue] == 0 ? NO : YES;
        [swit setOn:ison];
        _isShowPhonelabel = cell.descrilabel;
        [cell.descrilabel setHidden:NO];
        if (swit.on ==NO)
        {
            cell.descrilabel.text = @"不公开";
        }
        else
        {
            cell.descrilabel.text = @"公开";
        }
        cell.textField.text = _wSocket.lbxManager.dfcInfo.phone;
        if (_selectedPhone)
        {
            cell.textField.text =_selectedPhone;
        }
        
        cell.textField.delegate = self;
        _phoneTF = cell.textField;
    }
    
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArray.count;
}

-(void)switchValueChanged:(UISwitch *)swit
{
    _isSelectPhone = YES;
    if (swit.on ==YES)
    {
        _isShowPhonelabel.text = @"公开";
        [_placeInfo setObject:@"1" forKey:@"phone_show_flag"];
    }
    else
    {
        _isShowPhonelabel.text = @"不公开";
        [_placeInfo setObject:@"0" forKey:@"phone_show_flag"];
    }
}

#pragma mark -四个pickerView的点击事件

-(void)addSexPickerView
{
//    _selectedSex=@"男";
    [self.view endEditing:YES];
    self.keyWindow=[UIApplication sharedApplication].keyWindow;
    [self.PVBgView addSubview:self.sexPickerView];
    [self.PVBgView addSubview:self.tipView];
    
    [self.keyWindow addSubview:self.normalBGView];
    [self.keyWindow addSubview:self.PVBgView];
}

-(void)addBirthDayPickerView
{
    
      [self.view endEditing:YES];
    self.keyWindow=[UIApplication sharedApplication].keyWindow;

    [self.PVBgView addSubview:self.BirthdayPickerView];
    [self.PVBgView addSubview:self.tipView];
    
    [self.keyWindow addSubview:self.normalBGView];
    [self.keyWindow addSubview:self.PVBgView];
}

-(void)addPermanent
{
//    _selectedPermanent=@"北京 通州";
    [self.view endEditing:YES];
    self.keyWindow=[UIApplication sharedApplication].keyWindow;

    [self.PVBgView addSubview:self.permanentPickerView];
    [self.PVBgView addSubview:self.tipView];
    
    [self.keyWindow addSubview:self.normalBGView];
    [self.keyWindow addSubview:self.PVBgView];
}

-(void)addIdentifierPickerView
{
//    _selectedIdentifier=@"司机";

     [self.view endEditing:YES];
    self.keyWindow=[UIApplication sharedApplication].keyWindow;

    [self.PVBgView addSubview:self.identifierPickerView];
    [self.PVBgView addSubview:self.tipView];
    [self.keyWindow addSubview:self.normalBGView];
    [self.keyWindow addSubview:self.PVBgView];
}

#pragma mark -UIPickerViewDelegate

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if (pickerView.tag==100||pickerView.tag==102) {
        return 1;
    }
    else if (pickerView.tag==101)
    {
        return 2;
    }
    return 0;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    
    if (pickerView.tag==100||pickerView.tag==102) {
        
        return 2;
    }
    else if(pickerView.tag==101)
    {
        if (component==0)
        {
            return _areaArray.count;
        }
        else if(component==1)
        {
            NSInteger row=[pickerView selectedRowInComponent:0];
           
            NSArray *tempArray=[[_areaArray objectAtIndex:row]objectForKey:@"cities"];
            return tempArray.count;
        }
    }
    return 0;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (pickerView.tag==100) {
        
        if (row==0) {
            return @"男";
        }
        else
        {
            return @"女";
        }
        
    }else if(pickerView.tag==101)
    {
        if (component==0) {
            
            return [[_areaArray objectAtIndex:row]objectForKey:@"state"];
            
        }
        else if(component==1)
        {
            NSInteger row0=[pickerView selectedRowInComponent:0];
            
            
            NSArray *temparr=[[_areaArray objectAtIndex:row0]objectForKey:@"cities"];
            
            if (temparr.count<=row) {
                return 0;
            }
            else
            {
                NSDictionary *tempDict=[temparr objectAtIndex:row];
                
                return [tempDict objectForKey:@"city"];
            }
        }
    }
    else if(pickerView.tag==102)
    {
        if (row==0) {
            return @"司机";
        }
        else
            return @"农民";
    }
    return 0;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (pickerView.tag==100) {
        
        if (row==0) {
            _selectedSex=@"男";
        }else if (row==1)
        {
            _selectedSex=@"女";
        }
        
        if ([_selectedSex isEqualToString:@"男"])
        {
            [_info setObject:@"1" forKey:@"sex"];
        }else
        {
            [_info setObject:@"2" forKey:@"sex"];
        }
        
        
    }
    else if (pickerView.tag==101)
    {
        _isSelectCity = YES;
        NSString *selectProvince = @"";
        NSString *selectCity = @"";
        if (component==0) {
            
            [pickerView reloadComponent:1];
            
            NSInteger row0=[pickerView selectedRowInComponent:0];
            NSInteger row1=[pickerView selectedRowInComponent:1];
            
//            _selectedPermanent=[NSString stringWithFormat:@"%@ %@",[[_areaArray objectAtIndex:row0] objectForKey:@"state"],[[[[_areaArray objectAtIndex:row0]objectForKey:@"cities"] objectAtIndex:row1] objectForKey:@"city"]];
            _selectedPermanent=[NSString stringWithFormat:@"%@",[[[[_areaArray objectAtIndex:row0]objectForKey:@"cities"] objectAtIndex:row1] objectForKey:@"city"]];
            
            selectProvince = [[_areaArray objectAtIndex:row0]objectForKey:@"state"];
            selectCity = [[[[_areaArray objectAtIndex:row0]objectForKey:@"cities"]objectAtIndex:row1]objectForKey:@"city"];
        }
        else if (component==1)
        {
            NSInteger row0=[pickerView selectedRowInComponent:0];
            NSInteger row1=[pickerView selectedRowInComponent:1];
            
            
//            _selectedPermanent=[NSString stringWithFormat:@"%@ %@",[[_areaArray objectAtIndex:row0] objectForKey:@"state"],[[[[_areaArray objectAtIndex:row0]objectForKey:@"cities"] objectAtIndex:row1] objectForKey:@"city"]];
            
            _selectedPermanent=[NSString stringWithFormat:@"%@",[[[[_areaArray objectAtIndex:row0]objectForKey:@"cities"] objectAtIndex:row1] objectForKey:@"city"]];
            
            selectProvince = [[_areaArray objectAtIndex:row0]objectForKey:@"state"];
            selectCity = [[[[_areaArray objectAtIndex:row0]objectForKey:@"cities"]objectAtIndex:row1]objectForKey:@"city"];
        }
        
        [_placeInfo setObject:selectProvince forKey:@"province"];
        [_placeInfo setObject:selectCity forKey:@"city"];
        
    }else if (pickerView.tag==102)
    {
        if (row==0) {
            _selectedIdentifier=@"司机";
        }else if (row==1)
        {
            _selectedIdentifier=@"农民";
        }
        
        if ([_selectedIdentifier isEqualToString:@"司机"])
        {
            [_info setObject:@"2" forKey:@"identity"];
        }else
        {
            [_info setObject:@"1" forKey:@"identity"];
        }
    }
}


#pragma mark -UITextFieldDelegate
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if ([textField.placeholder isEqualToString:@"点击选择性别"])
    {
        [self addSexPickerView];
        return NO;
    }
    else if ([textField.placeholder isEqualToString:@"点击选择出生日期"])
    {
        [self addBirthDayPickerView];
        return NO;
        
    }else if ([textField.placeholder isEqualToString:@"点击选择常住地"])
    {
        [self addPermanent];
        return NO;
    }else if ([textField.placeholder isEqualToString:@"点击选择身份"])
    {
//        [self addIdentifierPickerView];
        return NO;
    }
    else if ([textField.placeholder isEqualToString:@"请输入联系方式"])
    {
        return YES;
    }
    else if (textField.tag==6)
    {
        _signatureTF = textField;
        return YES;
    }
    return YES;
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if (textField.tag ==4)
    {
        BOOL checkPhone = [_wSocket.lbxManager checkPhoneNum:textField.text];
        if (checkPhone ==NO)
        {
            [_wSocket.lbxManager showHudViewLabelText:@"手机号码有误，请重新输入" detailsLabelText:nil afterDelay:1];
        }
        return checkPhone;
    }
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField;
{
    if (textField.tag ==0)
    {
        [_info setObject:textField.text forKey:@"nick_name"];
        _selectedNickName=textField.text;
    }
    else if (textField.tag ==4)
    {
        [_placeInfo setObject:textField.text forKey:@"phone"];
        _selectedPhone = textField.text;
    }
    else if (textField.tag ==6)
    {
        [_info setObject:textField.text forKey:@"signature"];
        _signatureTF = textField;
        _selectedSegement=textField.text;
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return YES;
}

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
    
    UIImage *img = [UIImage imageWithData:data];
    NSLog(@"img = %@",img);
    
    [_avatarBtn setImage:img forState:UIControlStateNormal];
    _isSelectPhoto = YES;
    
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    NSLog(@"您取消了选择图片");
    [picker dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark -自定义转场动画
-(NSTimeInterval)transitionDuration:(id)transitionContext
{
    return 0.3;
}

-(void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIView *toView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    UIView *containerView = [transitionContext containerView];
    [containerView addSubview:toVC.view];
    [UIView animateWithDuration:duration animations:^{
        toVC.view.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:YES];
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
