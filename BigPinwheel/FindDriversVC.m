//
//  FindDriversVC.m
//  BigPinwheel
//
//  Created by MZero on 16/3/1.
//  Copyright © 2016年 leita. All rights reserved.
//

#import "FindDriversVC.h"
#import "FindDriversV.h"
#import "DriversModel.h"
#import "DriversTbvCell.h"
#import "MyAnnotationView.h"
#import <MAMapKit/MAMapKit.h>
#import "WSocket.h"
#import "NameCardViewController.h"

@interface FindDriversVC ()<MAMapViewDelegate,AMapLocationManagerDelegate,AMapSearchDelegate,UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate>

// 根视图
@property(nonatomic, strong) FindDriversV *fDiversView;
// 用户地理位置
@property(nonatomic, strong) MAUserLocation *userLocation;
// 搜索栏
@property(nonatomic, strong) UISearchBar *searchBar;
@property(nonatomic, strong) AMapSearchAPI *search;
// tbv
@property(nonatomic, strong) UITableView *tbv;
// 上下拉按钮
@property(nonatomic, strong) UIButton *sxBtn;

@property(strong,nonatomic)WSocket *wSocket;

@end

@implementation FindDriversVC

-(instancetype)init
{
    if (self)
    {
        _dataArray = [[NSMutableArray alloc]init];
        _wSocket = [WSocket sharedWSocket];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"找司机";
    self.view.backgroundColor = [UIColor whiteColor];
    [self addSubViews];
    
}

/**
 *  添加子视图
 */
-(void)addSubViews{
    _fDiversView = [[FindDriversV alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds))];
    [self.view addSubview:_fDiversView];
    // 两个代理
    _fDiversView.mapView.delegate = self;
    _fDiversView.locationManager.delegate = self;
    
    //搜索
    _searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(50, 14, CGRectGetWidth(self.view.bounds)-100, 40)];
    [self.view addSubview:_searchBar];
    _searchBar.delegate = self;
    
    _search = [[AMapSearchAPI alloc]init];
    _search.delegate = self;
    
    UITapGestureRecognizer *tap= [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handTap)];
    tap.delegate = self;
    [_fDiversView.mapView addGestureRecognizer:tap];
    
    [self addTbv];
}

- (void)addTbv{
    _tbv = [[UITableView alloc]initWithFrame:CGRectMake(0, CGRectGetHeight(_fDiversView.bounds)-64, CGRectGetWidth(self.view.bounds), CGRectGetHeight(_fDiversView.bounds)*0.5) style:UITableViewStylePlain];
    _tbv.delegate = self;
    _tbv.dataSource = self;
    _tbv.backgroundColor = COLOR(245, 242, 241, 0.85);
    [_fDiversView addSubview:_tbv];
    _tbv.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    _sxBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_tbv.bounds), 50)];
    [_sxBtn setBackgroundColor:[UIColor clearColor]];
    [_sxBtn setImage:[UIImage imageNamed:@"sl"] forState:UIControlStateNormal];
    _sxBtn.imageEdgeInsets = UIEdgeInsetsMake(0, (CGRectGetWidth(_tbv.bounds)-32)*0.5, 0, (CGRectGetWidth(_tbv.bounds)-32)*0.5);
    [_sxBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    _tbv.tableHeaderView = _sxBtn;
    
    
    [UIView animateWithDuration:0.4 animations:^{
        _tbv.frame = CGRectMake(0, CGRectGetHeight(_fDiversView.bounds)-50-64, CGRectGetWidth(self.view.bounds), CGRectGetHeight(_fDiversView.bounds)*0.5);
    }];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (void)handTap{
    [_searchBar resignFirstResponder];
    if (_tbv.frame.origin.y == CGRectGetHeight(_fDiversView.bounds)-50-64) {
        return;
    }
    [UIView animateWithDuration:0.4 animations:^{
        _tbv.frame = CGRectMake(0, CGRectGetHeight(_fDiversView.bounds)-50-64, CGRectGetWidth(self.view.bounds), CGRectGetHeight(_fDiversView.bounds)*0.5);
        _searchBar.frame = CGRectMake(50, -64, CGRectGetWidth(self.view.bounds)-100, 40);
    } completion:^(BOOL finished) {
        [_tbv reloadData];
    }];
}

- (void)btnClick:(UIButton *)btn{

    if (btn == _sxBtn) {
        if (_tbv.frame.origin.y == CGRectGetHeight(_fDiversView.bounds)-50-64) {
            [_sxBtn setImage:[UIImage imageNamed:@"sl"] forState:UIControlStateNormal];
            [UIView animateWithDuration:0.4 animations:^{
                _tbv.frame = CGRectMake(0, CGRectGetHeight(_fDiversView.bounds)*0.5, CGRectGetWidth(self.view.bounds), CGRectGetHeight(_fDiversView.bounds)*0.5);
                _searchBar.frame = CGRectMake(50, 74-64, CGRectGetWidth(self.view.bounds)-100, 40);
            }completion:^(BOOL finished) {
                [_tbv reloadData];
            }];
            
        }else{
            [_sxBtn setImage:[UIImage imageNamed:@"xl"] forState:UIControlStateNormal];
            [UIView animateWithDuration:0.4 animations:^{
                _tbv.frame = CGRectMake(0, CGRectGetHeight(_fDiversView.bounds)-50-64, CGRectGetWidth(self.view.bounds), CGRectGetHeight(_fDiversView.bounds)*0.5);
                _searchBar.frame = CGRectMake(50, 0-64
                                              , CGRectGetWidth(self.view.bounds)-100, 40);
            }completion:^(BOOL finished) {
                [_tbv reloadData];
            }];
        }
        
    }
}

#pragma mark - 地图方面的代理
-(void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation
updatingLocation:(BOOL)updatingLocation
{
    if(updatingLocation && !_userLocation)
    {
        _userLocation = userLocation;
        //取出当前位置的坐标
        NSLog(@"latitude : %f,longitude: %f",userLocation.coordinate.latitude,userLocation.coordinate.longitude);
    }
}

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *reuseIndetifier = @"annotationReuseIndetifier";
        MyAnnotationView *annotationView = (MyAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:reuseIndetifier];
        if (annotationView == nil)
        {
            annotationView = [[MyAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseIndetifier];
        }
        //调用自定义的calloutView
        annotationView.canShowCallout = NO;
        
        // 设置中心点偏移，使得标注底部中间点成为经纬度对应点
        annotationView.centerOffset = CGPointMake(0, -18);
        
        
        if (_dataArray.count>0)
        {
        DFCUserInfo *info = [_dataArray objectAtIndex:[annotation.title integerValue]];
        annotationView.info = info;
        }
        
        return annotationView;
    }
    return nil;
}

#pragma mark - 搜索方面的代理
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    if (!_tbv) {
//        [self addTbv];
    }
    
    [self searchWithCoor:CLLocationCoordinate2DMake(0, 0) keyWord:searchBar.text searchType:0];
}

-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
//    if (_tbv) {
//        [_tbv removeFromSuperview];
//        _tbv = nil;
//    }
    
    [UIView animateWithDuration:0.4 animations:^{
        _tbv.frame = CGRectMake(0, CGRectGetHeight(_fDiversView.bounds)-50-64, CGRectGetWidth(self.view.bounds), CGRectGetHeight(_fDiversView.bounds)*0.5);
    }];

    return YES;
}


#pragma mark - tbv方面的代理
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    DFCUserInfo *tempInfo = [_dataArray objectAtIndex:indexPath.row];
    DriversTbvCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DriversTbvCell"];
    if (!cell) {
        cell = [[DriversTbvCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DriversTbvCell"];
    }
    cell.label0.text = tempInfo.remaining_addr;
    cell.label1.text = [NSString stringWithFormat:@"%@%@%@",tempInfo.city,tempInfo.region,tempInfo.remaining_addr];
    cell.label2.text = [NSString stringWithFormat:@"%@正在收割",tempInfo.nick_name];
    cell.label3.text = [NSString stringWithFormat:@"%@元/亩",[[tempInfo.quoted_price_list firstObject]objectForKey:@"quoted_price"]];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DFCUserInfo *info = [_dataArray objectAtIndex:indexPath.row];
    NameCardViewController *nameVC = [[NameCardViewController alloc]init];
    nameVC.userinfo = info;
    [self.navigationController pushViewController:nameVC animated:YES];
    
}

-(void)dealloc{
    [_fDiversView.locationManager stopUpdatingLocation];
}

#pragma mark - 地图区域改变的时候调用的方法
/// 地图区域即将改变的时候调用此方法
- (void)mapView:(MAMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
    NSLog(@"地图将要移动");
}

/// 地图区域改变完成的时候调用此方法
- (void)mapView:(MAMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    NSLog(@"地图移动结束");
    // 将坐标转化为经纬度
    CLLocationCoordinate2D start_location = [_fDiversView.mapView convertPoint:CGPointMake(0, 0) toCoordinateFromView:_fDiversView.mapView];
    CLLocationCoordinate2D stop_location = [_fDiversView.mapView convertPoint:CGPointMake(_fDiversView.mapView.frame.size.width, _fDiversView.mapView.frame.size.height) toCoordinateFromView:_fDiversView.mapView];
    NSLog(@"x1 = %f,x2 = %f,y1 = %f,y2 = %f",start_location.longitude,stop_location.longitude,stop_location.latitude,start_location.latitude);
    
    [[WSocket sharedWSocket]GetRangeDriverStartLongitude:start_location.longitude StartLatitude:start_location.latitude EndLongitude:stop_location.longitude EndLatitude:stop_location.latitude pageSize:10 GetRangeDriversBlock:^(int ret, NSDictionary *roodDcit) {
        if (ret == kConnectFailue) {
            NSLog(@"请求失败，请重试");
        }
        else
        {
            [self addBig:roodDcit];
            NSLog(@"请求成功了，数据是 %@",roodDcit);
        }
    }];
}

#pragma mark - 地图搜索的所有功能
/// 执行搜索 searchType   0 是关键字搜索  1 是周边搜索  2 多边形搜索
- (void)searchWithCoor:(CLLocationCoordinate2D)coor
               keyWord:(NSString *)keyWord
            searchType:(int)searchType
{
    // types属性表示限定搜索POI的类别，默认为：餐饮服务|商务住宅|生活服务
    // POI的类型共分为20种大类别，分别为：
    // 汽车服务|汽车销售|汽车维修|摩托车服务|餐饮服务|购物服务|生活服务|体育休闲服务|
    // 医疗保健服务|住宿服务|风景名胜|商务住宅|政府机构及社会团体|科教文化服务|
    // 交通设施服务|金融保险服务|公司企业|道路附属设施|地名地址信息|公共设施
    
    [[[WSocket sharedWSocket] lbxManager] showHubAction:0 showView:self.view];
    
    if (searchType == 0) {
        
        AMapPOIKeywordsSearchRequest *request = [[AMapPOIKeywordsSearchRequest alloc] init];
        request.types = @"餐饮服务|商务住宅|生活服务";
        request.sortrule = 0;
        request.requireExtension = YES;
        request.keywords = keyWord;
        request.page = 1;
        request.offset = 30;
        [_search AMapPOIKeywordsSearch:request];
        
    } else if (searchType == 1) {
        
        AMapPOIAroundSearchRequest *request = [[AMapPOIAroundSearchRequest alloc] init];
        request.location = [AMapGeoPoint locationWithLatitude:coor.latitude longitude:coor.longitude];
        request.keywords = keyWord;
        request.types = @"餐饮服务|商务住宅|生活服务";
        request.sortrule = 0;
        request.requireExtension = YES;
        request.page = 1;
        request.offset = 30;
        [_search AMapPOIAroundSearch: request];
        
    } else if (searchType == 2) {
        NSLog(@"周边搜索");
    }
}

/// POI检索失败
- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error
{
    NSLog(@"%s: searchRequest = %@, errInfo= %@", __func__, [request class], error);
}

/// POI检索的结果返回
- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response
{
    [[[WSocket sharedWSocket] lbxManager] showHubAction:1 showView:nil];
    if (response.pois.count == 0) {
        [[[WSocket sharedWSocket] lbxManager] showHudViewLabelText:@"没有检索到输数据" detailsLabelText:nil afterDelay:1];
        return;
    }
    
    if ([request isKindOfClass:[AMapPOIKeywordsSearchRequest class]]) {
        NSLog(@"关键字搜索返回结果");
    } else if ([request isKindOfClass:[AMapPOIAroundSearchRequest class]]) {
        NSLog(@"周边搜索");
    }
    
    NSString *strCount = [NSString stringWithFormat:@"count: %d",(int)response.count];
    NSString *strSuggestion = [NSString stringWithFormat:@"Suggestion: %@", response.suggestion];
    NSString *strPoi = @"";
    
    for (AMapPOI *p in response.pois) {
        strPoi = [NSString stringWithFormat:@"%@\nPOI: %@", strPoi, p.description];
    }
    NSString *result = [NSString stringWithFormat:@"%@ \n %@ \n %@", strCount, strSuggestion, strPoi];
    NSLog(@"Place: %@", result);
    
    if (response.pois.count) {
        AMapPOI *mapPoi = [response.pois firstObject];

        /// 设置地图显示的中心点
        [_fDiversView.mapView setCenterCoordinate:CLLocationCoordinate2DMake(mapPoi.location.latitude, mapPoi.location.longitude) animated:YES];
    }
}

/// 添加地图上的大头针
- (void)addBig:(NSDictionary *)rootDict
{
    if (rootDict) {
        NSLog(@"有数据");
        if (_dataArray)
        {
            [_dataArray removeAllObjects];
        }
        
        NSMutableArray *tempArray = [NSMutableArray arrayWithArray:[rootDict objectForKey:@"dfc_range_drivers"]];
        
        for (NSDictionary *dict in tempArray)
        {
            DFCUserInfo *info =[[DFCUserInfo alloc]init];
            info.longitude = [dict objectForKey:@"location_j"];
            info.latitude = [dict objectForKey:@"location_w"];
            info.nick_name = [dict objectForKey:@"nick_name"];
            info.phone_num = [dict objectForKey:@"user_id"];
            info.quoted_price_list = [dict objectForKey:@"price_list"];
            [_dataArray addObject:info];
        }
        
        int index = 0;
        for (DFCUserInfo *info in _dataArray)
        {
            MAPointAnnotation *pointAnnotation = [[MAPointAnnotation alloc] init];
            pointAnnotation.coordinate = CLLocationCoordinate2DMake([info.latitude floatValue],[info.longitude floatValue]);
            pointAnnotation.title = [NSString stringWithFormat:@"%d",index];
            [_fDiversView.mapView addAnnotation:pointAnnotation];
            index ++;
        }
    } else
    {
        NSLog(@"没有数据");
    }
}

@end
