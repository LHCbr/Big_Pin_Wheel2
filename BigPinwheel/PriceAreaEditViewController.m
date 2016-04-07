//
//  PriceAreaEditViewController.m
//  BigPinwheel
//
//  Created by xuwei on 16/3/1.
//  Copyright © 2016年 leita. All rights reserved.
//

#import "PriceAreaEditViewController.h"
#import "DYCAddress.h"
#import "DYCAddressPickerView.h"
#import "Address.h"
#import "WSocket.h"
#import <CoreLocation/CoreLocation.h>

@interface PriceAreaEditViewController ()<DYCAddressDelegate,DYCAddressPickerViewDelegate,CLLocationManagerDelegate>

@property (strong,nonatomic) UIView *BGView;

@property (strong,nonatomic)DYCAddressPickerView *pickerView;
@property(strong,nonatomic)NSMutableDictionary *areaDict;             //PickView选择好字段以后上传给wsocket的字典

@property(strong,nonatomic)WSocket *wSocket;
@property (strong, nonatomic) CLLocationManager* locationManager;
@end

@implementation PriceAreaEditViewController

-(CLLocationManager *)locationManager
{
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.distanceFilter = 10.0f;
    }
    return _locationManager;
}

-(UIButton *)saveBtn
{
    if (!_saveBtn) {
        _saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _saveBtn.backgroundColor = COLOR(238, 187, 69, 1);
        _saveBtn.frame = CGRectMake(29/2,_rootScollView.contentSize.height-52-10, kDeviceWidth - 29, 52);
        [_saveBtn.layer setMasksToBounds:YES];
        [_saveBtn.layer setCornerRadius:2];
        [_saveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_saveBtn.titleLabel setFont:[UIFont systemFontOfSize:20]];
        [_saveBtn.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [_saveBtn setTitle:@"保存" forState:UIControlStateNormal];
        [_saveBtn addTarget:self action:@selector(saveBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _saveBtn;
}

-(UIView *)BGView
{
    if (!_BGView) {
        _BGView=[self creatLineWithFrame:CGRectMake(0.5,41+10+10, kDeviceWidth-1, 326/2) BGColor:[UIColor whiteColor]];
        [_BGView.layer setMasksToBounds:YES];
        [_BGView.layer setBorderWidth:0.5];
        [_BGView.layer setBorderColor:COLOR(220, 220, 220, 1).CGColor];
        [_rootScollView addSubview:_BGView];
    }
    return _BGView;
}

- (void)dealloc
{
    NSLog(@"报价区域界面释放");
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self startLocation];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.navigationController.navigationBar.userInteractionEnabled = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

#pragma mark -本类接受的通知
///执行删除添加操作后，刷新界面
-(void)refreshAreaView:(NSNotification *)noti
{
    __weak PriceAreaEditViewController *weakSelf = self;
    __weak WSocket *weakSocket = _wSocket;
    [[WSocket sharedWSocket]getUserDFCInfoBlock:_wSocket.lbxManager.wJid.phone getUserDFCInfoBlock:^(int ret, DFCUserInfo *DFCInfo) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (ret>=0){
                weakSelf.tempQuotedList = [NSMutableArray arrayWithArray:weakSocket.lbxManager.dfcInfo.quoted_price_list];
                [weakSelf.tempQuotedList addObject:@""];
                [weakSelf customPriceAreaView];
            }
            
        });
    }];
}
-(instancetype)init
{
    self = [super init];
    if (self)
    {
        _wSocket = [WSocket sharedWSocket];
        _tempQuotedList = [[NSMutableArray alloc]init];
        _areaDict = [[NSMutableDictionary alloc]init];
        [_areaDict setObject:@"北京市" forKey:@"provinc"];
        [_areaDict setObject:@"北京市" forKey:@"city"];
        [_areaDict setObject:@"东城区" forKey:@"region"];
        _tempQuotedList = [NSMutableArray arrayWithArray:_wSocket.lbxManager.dfcInfo.quoted_price_list];
        [_tempQuotedList addObject:@""];
        NSLog(@"initialized_tempQuotedList = %@",_tempQuotedList);
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshAreaView:) name:kUpdateDFCInfoSuccess object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = kBGColor;
    self.view.frame = CGRectMake(0, 0, kDeviceWidth, kDeviceHeight);
    self.navigationItem.title = @"报价区域";
    
    _rootScollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, kDeviceWidth, kDeviceHeight)];
    _rootScollView.backgroundColor = [UIColor clearColor];
    [_rootScollView setContentSize:CGSizeMake(kDeviceWidth, kDeviceHeight)];
    _rootScollView.showsHorizontalScrollIndicator = NO;
    _rootScollView.showsVerticalScrollIndicator = NO;
    _rootScollView.delegate = self;
    [self.view addSubview:_rootScollView];
    
//    [self customSearchBarView];
    
    [self customGPSLabel];
    
    [self customPriceAreaView];
    
    [self customHarvestPriceView];
    
//    [self customFooterView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(endTap:)];
    [self.view addGestureRecognizer:tap];
    
}

-(void)endTap:(UIGestureRecognizer *)tap
{
    [self.view endEditing:YES];
}

#pragma mark -View创建工具
//-(void)customSearchBarView
//{
//    _searchBGView= [[UIView alloc]initWithFrame:CGRectMake(0, 0, kDeviceWidth, 44)];
//    _searchBGView.backgroundColor = [UIColor clearColor];
//    [_rootScollView addSubview:_searchBGView];
//    
//    _searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(15, 6, kDeviceWidth -30, 33)];
//    _searchBar.backgroundColor = [UIColor whiteColor];
//    [_searchBar.layer setMasksToBounds:YES];
//    [_searchBar.layer setCornerRadius:3.5];
//    _searchBar.keyboardType = UIKeyboardTypeDefault;
//    _searchBar.placeholder = @"输入城市名或者拼音查询";
//    _searchBar.delegate = self;
//    [_searchBGView addSubview:_searchBar];
//    
//    UIImage* clearImg = [self imageWithColor:[UIColor clearColor] andHeight:33.0f];
//    [_searchBar setBackgroundImage:clearImg];
//    UIImage *grayImg = [self imageWithColor:[UIColor whiteColor] andHeight:33.0f];
//    [_searchBar setSearchFieldBackgroundImage:grayImg forState:UIControlStateNormal];
//    [_searchBar setBackgroundColor:[UIColor clearColor]];
//    
//    for (UIView *subview in _searchBar.subviews) {
//        for(UIView* grandSonView in subview.subviews){
//            if([grandSonView isKindOfClass:NSClassFromString(@"UISearchBarTextField")] ){
//                [grandSonView.layer setCornerRadius:5.0f];
//                [grandSonView.layer setMasksToBounds:YES];
//                break;
//            }
//        }
//    }
//}

- (UIImage*) imageWithColor:(UIColor*)color andHeight:(CGFloat)height
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

///初始化GPS定位Label
-(void)customGPSLabel
{
    UIView *view =[self creatLineWithFrame:CGRectMake(1,10, kDeviceWidth-2, 41) BGColor:[UIColor whiteColor]];
    [view.layer setMasksToBounds:YES];
    [view.layer setBorderWidth:0.5];
    [view.layer setBorderColor:COLOR(220, 220, 220, 1).CGColor];
    [_rootScollView addSubview:view];
    
    _locationLabel = [self createLabelWithTextColor:[UIColor blackColor] frame:CGRectMake(15, (view.frame.size.height -14)/2, view.frame.size.width -30, 14) textFont:[UIFont systemFontOfSize:14] bgColor:[UIColor whiteColor] layerFont:0 borderWith:0 textAligement:NSTextAlignmentLeft];
    NSMutableAttributedString *placeStr = [[NSMutableAttributedString alloc]initWithString:@"     GPS定位"];
    [placeStr addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, placeStr.length -5)];
    [placeStr addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:NSMakeRange(placeStr.length-5, 5)];
    [placeStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(0, placeStr.length-5)];
    [placeStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13] range:NSMakeRange(placeStr.length-5, 5)];
    _locationLabel.attributedText = placeStr;
    [view addSubview:_locationLabel];
    
}

///初始化报价区域View
-(void)customPriceAreaView
{
    for (UIView *subView in self.BGView.subviews) {
       
        [subView removeFromSuperview];
    }
    
    UILabel *priceDespLabel = [self createLabelWithTextColor:COLOR(153, 153, 153, 1) frame:CGRectMake(31/2, 21, kDeviceWidth/3, 14) textFont:[UIFont systemFontOfSize:14] bgColor:[UIColor clearColor] layerFont:0 borderWith:0 textAligement:NSTextAlignmentLeft];
    priceDespLabel.text = @"已选择报价区域";
    [_BGView addSubview:priceDespLabel];
    
    NSInteger btnCount = _tempQuotedList.count;
    
    CGFloat btnWidth =(kDeviceWidth-70)/3;
    if (btnCount>6||btnCount<=0)
    {
        return;
    }

    for (NSInteger i=0; i<btnCount; i++)
    {
        NSMutableDictionary *dict = [_tempQuotedList objectAtIndex:i];
        NSMutableString *cityStr = [[NSMutableString alloc]init];
        if (i<btnCount-1) {
        cityStr = [NSMutableString stringWithFormat:@"%@%@",[dict objectForKey:@"city"],[dict objectForKey:@"region"]];
        }else
        {
            cityStr = [NSMutableString stringWithString:@""];
        }
        
        PriceAreaBtn *button = [self creatBtnWithFrame:CGRectMake(30/2+(btnWidth+20)*(i%3), 14+21+55/2+(i/3)*53, btnWidth, 35-2) Titie:cityStr index:i];
        button.dict = dict;
        [self.BGView addSubview:button];
        [button addTarget:self action:@selector(priceAreaBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        UIImageView *delView = [[UIImageView alloc]initWithFrame:CGRectMake(button.frame.size.width+button.frame.origin.x-21/2, button.frame.origin.y+(button.frame.size.height-21)/2, 21, 21)];
        delView.backgroundColor = [UIColor clearColor];
        [delView setImage:[UIImage imageNamed:@"0230_delete"]];
        [delView setContentMode:UIViewContentModeScaleAspectFit];
        [self.BGView addSubview:delView];
        
        if (i ==btnCount-1)
        {
            [delView setHidden:YES];
            [button setImage:[UIImage imageNamed:@"0230_add"] forState:UIControlStateNormal];
            [button.imageView setContentMode:UIViewContentModeScaleAspectFit];
        }
        if (i>=5)
        {
            [button setHidden:YES];
        }
    }
}

///初始化收割价格View
-(void)customHarvestPriceView
{
    _havestTF = [[UITextField alloc]initWithFrame:CGRectMake(0.5,_BGView.frame.origin.y+_BGView.frame.size.height+10, kDeviceWidth-1, 41)];
    _havestTF.backgroundColor = [UIColor whiteColor];
    [_havestTF.layer setMasksToBounds:YES];
    [_havestTF.layer setBorderWidth:0.5];
    [_havestTF.layer setBorderColor:COLOR(220, 220, 220, 1).CGColor];
    _havestTF.placeholder = @"";
    _havestTF.keyboardType = UIKeyboardTypePhonePad;
    _havestTF.leftViewMode = UITextFieldViewModeAlways;
    _havestTF.rightViewMode = UITextFieldViewModeAlways;
    _havestTF.delegate = self;
    [_rootScollView addSubview:_havestTF];
    
    UIView *leftview = [self creatLineWithFrame:CGRectMake(0, 0, 156/2, _havestTF.frame.size.height) BGColor:[UIColor clearColor]];
    _havestTF.leftView = leftview;
    
    UILabel *priceDespLabel = [self createLabelWithTextColor:[UIColor blackColor] frame:CGRectMake(0, 0, leftview.frame.size.width, leftview.frame.size.height) textFont:[UIFont systemFontOfSize:14] bgColor:[UIColor clearColor] layerFont:0 borderWith:0 textAligement:NSTextAlignmentCenter];
    priceDespLabel.text = @"收割价:";
    [leftview addSubview:priceDespLabel];
    
    UIView *rightView = [self creatLineWithFrame:CGRectMake(0, 0, kDeviceWidth*490/750, _havestTF.frame.size.height) BGColor:[UIColor clearColor]];
    _havestTF.rightView = rightView;
    
    UILabel *inchesLabel = [self createLabelWithTextColor:[UIColor blackColor] frame:CGRectMake(0, 0, rightView.frame.size.width, rightView.frame.size.height) textFont:[UIFont systemFontOfSize:14] bgColor:[UIColor clearColor] layerFont:0 borderWith:0 textAligement:NSTextAlignmentLeft];
    inchesLabel.text = @"元/亩";
    [rightView addSubview:inchesLabel];
}

-(void)startLocation
{
    [self.locationManager requestAlwaysAuthorization];
    [self.locationManager startUpdatingLocation];
}

#pragma mark -CLLcoationManagerDelegate

//定位代理经纬度回调
-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    [self.locationManager stopUpdatingLocation];
    NSLog(@"location ok");
    
    NSLog(@"%@",[NSString stringWithFormat:@"经度:%3.5f\n纬度:%3.5f",newLocation.coordinate.latitude,newLocation.coordinate.longitude]);
    
    CLGeocoder * geoCoder = [[CLGeocoder alloc] init];
    [geoCoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        for (CLPlacemark * placemark in placemarks) {
            
            NSDictionary *test = [placemark addressDictionary];
            NSLog(@"test = %@",test);
            NSString *textStr= [NSString stringWithFormat:@"%@ GPS定位",[test objectForKey:@"City"]];
            NSMutableAttributedString *atriStr = [[NSMutableAttributedString alloc]initWithString:textStr];
            [atriStr addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:NSMakeRange(textStr.length -5, 5)];
            _locationLabel.attributedText = atriStr;
        }
    }];
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

//创建seplineView
-(UIView *)creatLineWithFrame:(CGRect)frame BGColor:(UIColor *)color
{
    UIView *line = [[UIView alloc]initWithFrame:frame];
    line.backgroundColor = color;
    return line;
}

//创建Button
-(PriceAreaBtn *)creatBtnWithFrame:(CGRect)frame Titie:(NSString *)title index:(NSInteger )tag
{
    PriceAreaBtn *button = [PriceAreaBtn buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor clearColor];
    button.frame = frame;
    [button.layer setMasksToBounds:YES];
    [button.layer setBorderWidth:1];
    [button.layer setBorderColor:COLOR(117, 111, 124, 1).CGColor];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:COLOR(51, 51, 51, 1) forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont systemFontOfSize:11]];
    [button.titleLabel setTextAlignment:NSTextAlignmentCenter];
    button.tag = tag;
    
    return button;
    
}

#pragma mark - UISearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"点击了搜索");
}

//- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
//{
//    [_searchBar setShowsCancelButton:NO animated:YES];
//    [searchBar resignFirstResponder];
//}
//
//- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
//{
//    [_searchBar setShowsCancelButton:YES animated:YES];
//}
//
//- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
//{
//    [_searchBar setShowsCancelButton:NO animated:YES];
//}
//
//- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
//{
//    if (searchBar.text.length) {
//        NSLog(@"执行搜索");
//    }
//}

#pragma mark -点击事件

///提交之前的检查
-(BOOL)checkInfo
{
    if ([_wSocket.lbxManager checkIsHasNetwork:YES]==NO) {
        [_wSocket.lbxManager showHudViewLabelText:@"无网络连接,提交失败" detailsLabelText:nil afterDelay:1];
        return NO;
    }
    else if (_havestTF.text.length<=0)
    {
        [_wSocket.lbxManager showHudViewLabelText:@"请输入您的收割价格" detailsLabelText:nil afterDelay:1];
        [_havestTF becomeFirstResponder];
        return NO;
    }
    else
    {
        [_saveBtn setEnabled:YES];
        return YES;
    }
}

///报价区域按钮点击事件
-(void)priceAreaBtnClick:(PriceAreaBtn *)sender
{
   
    
    for (UIView *subview in self.view.subviews) {
        if ([subview isKindOfClass:[DYCAddressPickerView class]]) {
            return;
        }
    }

    if (sender.tag<_tempQuotedList.count -1)
    {
        if ([_wSocket.lbxManager checkIsHasNetwork:YES]==NO) {
            [_wSocket.lbxManager showHudViewLabelText:@"无网络连接,提交失败" detailsLabelText:nil afterDelay:1];
            return;
        }
        
        

        NSDictionary *dict = sender.dict;
        NSMutableString* cityStr = [NSMutableString stringWithFormat:@"%@%@%@",[dict objectForKey:@"provinc"],[dict objectForKey:@"city"],[dict objectForKey:@"region"]];
        NSLog(@"sender.dict = %@,cityStr = %@",sender.dict,cityStr);
        
        __weak WSocket *weakSocket = _wSocket;
        __weak PriceAreaEditViewController *weakSelf = self;
        [[WSocket sharedWSocket]DelQuotedPriceWithId:[sender.dict objectForKey:@"price_id"] DelQuotedPriceBlock:^(int success) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (success ==0) {
                    
                    [weakSelf.tempQuotedList removeObjectAtIndex:sender.tag];
                    [weakSelf customPriceAreaView];
                    [weakSocket.lbxManager.dfcInfo.quoted_price_list removeObjectAtIndex:sender.tag];
                    [weakSocket.lbxManager showHudViewLabelText:@"删除报价成功" detailsLabelText:nil afterDelay:1];
                    
                    [[NSNotificationCenter defaultCenter]postNotificationName:kUpdateDFCInfoSuccess object:nil];
                }
                else
                {
                    [weakSocket.lbxManager showHudViewLabelText:@"删除报价失败" detailsLabelText:nil afterDelay:1];
                }
            });
            
}];
        
    }else if (sender.tag ==_tempQuotedList.count -1)
    {
        [self addAreaPickerView];
         [_rootScollView addSubview:self.saveBtn];
        [_rootScollView setContentOffset:CGPointMake(0, 184/4) animated:NO];
    }
}

///保存按钮点击事件
-(void)saveBtnClick:(UIButton *)sender
{
    if ([self checkInfo]==NO) {
        return;
    }
    _rootScollView.contentOffset=CGPointMake(0,-64);
    [_pickerView removeFromSuperview];
    [self.view endEditing:YES];
    [_areaDict setObject:_havestTF.text forKey:@"quoted_price"];
    
    __weak WSocket *weakSocket = _wSocket;

    [[WSocket sharedWSocket]updateDriverQuotedPriceWithProvince:[_areaDict objectForKey:@"provinc"] City:[_areaDict objectForKey:@"city"] Region:[_areaDict objectForKey:@"region"] Price:[_areaDict objectForKey:@"quoted_price"] driverQuotedPriceBlock:^(int success) {
        
       dispatch_async(dispatch_get_main_queue(), ^{
        
            if (success ==0)
            {
                [weakSocket.lbxManager showHudViewLabelText:@"添加报价成功" detailsLabelText:nil afterDelay:1];
                [[NSNotificationCenter defaultCenter]postNotificationName:kUpdateDFCInfoSuccess object:nil];
            }
            else
            {
                [weakSocket.lbxManager showHudViewLabelText:@"添加报价失败" detailsLabelText:nil afterDelay:1];
            }
        }
     );
    }];
    [self.saveBtn removeFromSuperview];
    
}

#pragma mark  - 选择报价区域的pickerView
-(void)addAreaPickerView
{
    DYCAddress *address=[[DYCAddress alloc]init];
    address.dataDelegate=self;
    [address handlerAddress];

}

#pragma mark -DYCAddressPickerView 

-(void)addressList:(NSArray *)array
{
    if (!_pickerView) {
        _pickerView = [[DYCAddressPickerView alloc] initWithFrame:CGRectMake(0,_havestTF.frame.size.height+_havestTF.frame.origin.y,kDeviceWidth,kDeviceHeight/2-52) withAddressArray:array];
        _pickerView.DYCDelegate = self;
        _pickerView.backgroundColor = [UIColor clearColor];
    }
     [_rootScollView addSubview:_pickerView];
}

-(void)selectAddressProvince:(Address *)province andCity:(Address *)city andCounty:(Address *)county
{
    
    [_areaDict setObject:province.name forKey:@"provinc"];
    [_areaDict setObject:city.name forKey:@"city"];
    [_areaDict setObject:county.name forKey:@"region"];
    NSLog(@"_areaDict = %@",_areaDict);
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
