//
//  FindFrinedsViewController.m
//  BigPinwheel
//
//  Created by 徐伟 on 16/2/20.
//  Copyright © 2016年 leita. All rights reserved.
//

#import "FindFrinedsViewController.h"
#import "InscriptionManager.h"
#import "ChatListCell.h"
#import "QualifyFilterView.h"
#import "MyFriendsHeaderView.h"
#import "NameCardViewController.h"
#import "WSocket.h"
#import <CoreLocation/CoreLocation.h>
#import "MBProgressHUD.h"

@interface FindFrinedsViewController ()<CLLocationManagerDelegate>

@property(strong,nonatomic)InscriptionManager *inspManager;
@property(strong,nonatomic)WSocket *wSocket;
@property(strong,nonatomic)MyFriendsHeaderView *headerView;
@property(strong,nonatomic)QualifyFilterView *filterView;

@property(strong,nonatomic)POPBasicAnimation *downAnimation;
@property(strong,nonatomic)POPBasicAnimation *upAnimation;
@property(strong,nonatomic)POPBasicAnimation *fadeInAnimaiton;
@property(strong,nonatomic)POPBasicAnimation *fadeOutAnimation;

@property(assign,nonatomic)int sex;
@property(assign,nonatomic)int identity;
@property(assign,nonatomic)int place;
@property(assign,nonatomic)int fromprice;
@property(assign,nonatomic)int endprice;
@property(assign,nonatomic)int pageNum;

//保存定位的省份和城市
@property (copy,nonatomic)NSString *currentCity;
@property (copy,nonatomic)NSString *currentProvince;

@property (strong, nonatomic) CLLocationManager* locationManager;//用来获取当前城市和省份

@end

@implementation FindFrinedsViewController

- (void)dealloc
{
    NSLog(@"朋友筛选界面释放");
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.locationManager requestAlwaysAuthorization];
    [self.locationManager startUpdatingLocation];
    
    _dataArray = [NSMutableArray arrayWithArray:[_wSocket.lbxManager getTheLastFilterFarmListWithCuridx:0]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

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

-(instancetype)init
{
    self = [super init];
    if (self)
    {
        _inspManager = [InscriptionManager sharedManager];
        _wSocket = [WSocket sharedWSocket];
        _dataArray = [[NSMutableArray alloc]init];
        _fromprice = 0;
        _endprice = 0;
        
        [self initializePopAnimation];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(loginSuccessft:) name:kLoginSuccess object:nil];
        
        [[NSNotificationCenter defaultCenter]addObserver:self
                                                selector:@selector(refreshHeaderLabel)
                                                    name:kFilterDataChange
                                                  object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NAVBAR(@"朋友筛选");
    
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, kDeviceWidth, kDeviceHeight-64) style:UITableViewStylePlain];
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.estimatedRowHeight = kCellHeight;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.tableHeaderView = [[UIView alloc]init];
    _tableView.tableFooterView = [[UIView alloc]init];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
    
    [self customHeaderView];
    
    [self refreshIntializingView];
    
   // _dataArray = [NSMutableArray arrayWithArray:[_wSocket.lbxManager getTheLastFilterFarmListWithCuridx:0]];
    
}

#pragma mark - View创建工具

-(void)customHeaderView
{
    _headerView = [[MyFriendsHeaderView alloc]initWithFrame:CGRectMake(0, 0, kDeviceWidth, 35.5)];
    _headerView.delegate = self;
    _tableView.tableHeaderView = _headerView;
    
    _filterView = [[QualifyFilterView alloc]initWithFrame:CGRectMake(0, 35-kDeviceHeight, kDeviceWidth, kDeviceHeight-99.5)];
    _filterView.alpha = 0;
    _filterView.delegate = self;
    [_tableView addSubview:_filterView];
    
   // [self refreshHeaderLabel];
    
}

#pragma mark -pop动画效果
-(void)initializePopAnimation
{
    _downAnimation = [_inspManager creatAnimationWithPropName:kPOPViewFrame FunctionName:kCAMediaTimingFunctionEaseIn FromValue:nil ToValue:[NSValue valueWithCGRect:CGRectMake(0, 35, kDeviceWidth, kDeviceHeight-99.5)] Duration:0.1];
    _fadeInAnimaiton = [_inspManager creatAnimationWithPropName:kPOPViewAlpha FunctionName:kCAMediaTimingFunctionEaseIn FromValue:nil ToValue:@(1) Duration:0.2];
    _upAnimation = [_inspManager creatAnimationWithPropName:kPOPViewFrame FunctionName:kCAMediaTimingFunctionDefault FromValue:nil ToValue:[NSValue valueWithCGRect:CGRectMake(0, 35-kDeviceHeight, kDeviceWidth, kDeviceHeight-99.5)] Duration:0.2];
    _fadeOutAnimation = [_inspManager creatAnimationWithPropName:kPOPViewAlpha FunctionName:kCAMediaTimingFunctionEaseOut FromValue:nil ToValue:@(0) Duration:0.1];
    
    __weak FindFrinedsViewController *weakSelf = self;
    [_downAnimation setCompletionBlock:^(POPAnimation *anim, BOOL finished)
    {
        if (finished ==YES)
        {
            [weakSelf.headerView.filterDBtn setEnabled:NO];
        }
    }];
    [_upAnimation setCompletionBlock:^(POPAnimation *anim, BOOL finished)
    {
        if (finished ==YES)
        {
            [weakSelf.headerView.filterDBtn setEnabled:YES];
        }
    }];
}

#pragma mark -CLLcoationManagerDelegate

//定位代理经纬度回调
-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    [self.locationManager stopUpdatingLocation];
    
    CLGeocoder * geoCoder = [[CLGeocoder alloc] init];
    [geoCoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        for (CLPlacemark * placemark in placemarks) {
            
            NSDictionary *test = [placemark addressDictionary];
            NSLog(@"currentPlace = %@",test);
            _currentCity=[test objectForKey:@"City"];
            _currentProvince=[test objectForKey:@"State"];
        }
    }];
}


#pragma mark - UITabelViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kCellHeight;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    DFCUserInfo *userinfo = [_dataArray objectAtIndex:indexPath.row];
    NameCardViewController *nameCardVC = [[NameCardViewController alloc]init];
    nameCardVC.userinfo = userinfo;
    [self.navigationController pushViewController:nameCardVC animated:YES];
    
}

#pragma mark - UITableViewDataSource

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"chatlistCell";
    ChatListCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    DFCUserInfo *dfcinfo = [_dataArray objectAtIndex:indexPath.row];
    
    if (cell ==nil){
        cell = [[ChatListCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    __weak WSocket *weakSocket = _wSocket;
    [[WSocket sharedWSocket]addDownFileOperationWithFileUrlString:dfcinfo.head_portrait serialId:@"-1" modelType:ModelTypeNormal info:nil downBlock:^(int ret, int isSave, NSData *data, NSString *fileUrl)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (ret>=0)
            {
                [cell.avatarView setImage:[UIImage imageWithData:data]];
                if (isSave)
                {
                    [data writeToFile:[NSString stringWithFormat:@"%@/%@",kPathAvatar,[weakSocket.lbxManager upper16_MD5:fileUrl]]
                           atomically:YES];
                }
            }
            else
            {
                [cell.avatarView setImage:kDefaultAvatarImage];
            }
        });
    }];
    
    cell.nameLabel.text = [NSString stringWithFormat:@"%@",[_inspManager stringFromHexString:dfcinfo.nick_name]];
    cell.lastMSGLabel.text = [NSString stringWithFormat:@"%@",[_inspManager stringFromHexString:dfcinfo.signature]];
    NSString *placeStr = [NSString stringWithFormat:@"%@%@%@%@",@"8.0km",dfcinfo.city,dfcinfo.region,dfcinfo.remaining_addr];
    [cell.placeBtn setTitle:placeStr forState:UIControlStateNormal];
    [cell.placeBtn setHidden:NO];
    
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArray.count;
}

#pragma mark -按钮点击事件
//筛选按钮点击事件
-(void)filterButtonClick:(UIButton *)sender
{
        [_filterView pop_addAnimation:_downAnimation forKey:@"downAnimation"];
        [_filterView pop_addAnimation:_fadeInAnimaiton forKey:@"fadeInAnim"];
}

-(void)filterConfrimButtonClick:(UIButton *)sender
{
     [_dataArray removeAllObjects];
    if (sender.tag ==0)
    {
        [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];

        NSString *Province=@"";
        NSString *City=@"";
        if (_place==1) {
            Province=_currentProvince;
            City=_currentCity;
        }
        NSLog(@" 地区:%d 性别:%d 身份:%d 省份:%@ 城市:%@ %d-%d",_place,_sex,_identity,Province,City,_fromprice,_endprice);
        
//        __weak FindFrinedsViewController *weakSelf = self;
//        [[WSocket sharedWSocket]QueryUsersByLocationIsAllCity:_place Sex:_sex Identity:_identity Province:Province City:City PriceStart:_fromprice PriceEnd:_endprice PageNum:0 PageSize:10 DfcQueryUsersByLocationBlock:^(int ret, NSMutableArray *filtedList) {
//            if (ret>=0) {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    weakSelf.dataArray = [NSMutableArray arrayWithArray:filtedList];
//                    NSLog(@"weakdataArray = %@",weakSelf.dataArray);
//                    [_tableView reloadData];
//                });
//            }else
//            {
//                NSLog(@"ret = %d",ret);
//            }
//        }];
    [MBProgressHUD hideAllHUDsForView:[UIApplication sharedApplication].keyWindow animated:YES];
    }else if (sender.tag ==1)
    {
        
    }
    [_filterView pop_addAnimation:_upAnimation forKey:@"upAnimation"];
    [_filterView pop_addAnimation:_fadeOutAnimation forKey:@"fadeOutAnim"];
}

/*每次进界面根据userdefault刷新下界面*/
-(void)refreshIntializingView
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *propArray = [NSMutableArray arrayWithArray:[defaults objectForKey:kFilterData]];
    NSLog(@"propArray = %@",propArray);
    
    if (propArray.count>0)
    {
        MBProgressHUD *hud = [_wSocket.lbxManager ShowHubProgress:@""];
        int sex = -1;
        if (![[propArray objectAtIndex:0]isEqualToString:@"全部"])
        {
            sex = [[propArray objectAtIndex:0]isEqualToString:@"女"] ? 2 : 1;
        }
        
        NSString *province = @"";
        NSString *city = @"";
        int getAllCity = [[propArray objectAtIndex:1]isEqualToString:@"全部"] ? 0 : 1;
        if (getAllCity ==1)
        {
            province = _currentProvince;
            city = _currentCity;
        }
        
        int identity = [[propArray objectAtIndex:2]isEqualToString:@"农民"] ? 1 : 2;
        
//        __weak WSocket *weakSocket = _wSocket;
//        __weak FindFrinedsViewController *weakSelf = self;
//        [_wSocket QueryUsersByLocationIsAllCity:getAllCity Sex:sex Identity:identity Province:province City:city PriceStart:0 PriceEnd:65534 PageNum:0 PageSize:10 DfcQueryUsersByLocationBlock:^(int ret, NSMutableArray *filtedList) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                
//                if (ret>=0)
//                {
//                    [hud hide:YES];
//                    [weakSocket.lbxManager showHubAction:1 showView:nil];
//                    weakSelf.dataArray = [NSMutableArray arrayWithArray:filtedList];
//                    [_tableView reloadData];
//                    NSLog(@"刷新成功");
//                }
//                else
//                {
//                    [hud hide:YES];
//                    [weakSocket.lbxManager showHubAction:1 showView:nil];
//                    NSLog(@"刷新失败 ,ret = %d",ret);
//                }
//            });
//        }];
    }
}

/*本类接受的通知*/
-(void)refreshHeaderLabel
{
    NSUserDefaults *defaluts = [NSUserDefaults standardUserDefaults];
    NSMutableArray *propArray = [NSMutableArray arrayWithArray:[defaluts objectForKey:kFilterData]];
    NSString *str0 = [NSString stringWithFormat:@"%@,%@",[propArray objectAtIndex:0],[propArray objectAtIndex:1]];
    NSMutableAttributedString *strLabel = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"最近在线(%@)",str0]];
    [strLabel addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15] range:NSMakeRange(0, 4)];
    
    _headerView.fileterLabel.attributedText =strLabel;
    
    _sex = -1;
    if (![[propArray objectAtIndex:0]isEqualToString:@"全部"])
    {
        _sex = [[propArray objectAtIndex:0]isEqualToString:@"女"] ? 2 : 1;
    }
    _place = [[propArray objectAtIndex:1]isEqualToString:@"全部"] ? 0 :1;
    
    _fromprice = 0;
    _endprice = 65534;
    
    if ([[propArray objectAtIndex:2]isEqualToString:@"农民"]) {
        _identity=1;
    }
    else if ([[propArray objectAtIndex:2]isEqualToString:@"司机"])
    {
        _identity=2;
        
        NSString *pricestr = [NSString stringWithFormat:@"%@",[propArray objectAtIndex:3]];
        NSLog(@"pricestr = %@",pricestr);
        
        if ([pricestr isEqualToString:@"全部"])
        {
            _fromprice =_endprice = 0;
        }else if ([pricestr isEqualToString:@"0-50"])
        {
            _fromprice = 0;
            _endprice = 50;
        }else if ([pricestr isEqualToString:@"50-100"])
        {
            _fromprice =50;
            _endprice = 100;
        }else if ([pricestr isEqualToString:@"100-150"])
        {
            _fromprice = 100;
            _endprice = 150;
        }else if ([pricestr isEqualToString:@"150-200"])
        {
            _fromprice = 150;
            _endprice =200;
        }
    }
    else
    {
        _identity=3;
    }
    
    NSLog(@"sex = %d,place = %d,_identity =%d,fromprice = %d,endprice = %d",_sex,_place,_identity,_fromprice,_endprice);
}

-(void)loginSuccessft:(NSNotification *)noti
{
    NSMutableArray *filterlist = [NSMutableArray arrayWithArray:[_wSocket.lbxManager getTheLastFilterFarmListWithCuridx:0]];
    _dataArray = filterlist;
    dispatch_async(dispatch_get_main_queue(), ^{
        [_tableView reloadData];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
