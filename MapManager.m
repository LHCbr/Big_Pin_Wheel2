//
//  MapManager.m
//  LuLu
//
//  Created by a on 10/27/15.
//  Copyright © 2015 lbx. All rights reserved.
//

#import "MapManager.h"
#import "WSocket.h"

#define MaxMapLevel 18
#define MinMapLevel 18
#define SetMapLevel 15

#define kDefaultUserLocation [UIImage imageNamed:@"kClearUserLocation"];

const static NSString *APIKey = @"6f209cf99a96b9aa21032edc643f3224";

@interface MapManager()

@property (strong, nonatomic)WSocket *wSocket;          // 类工具句柄

@end

@implementation MapManager

/// 地图句柄
static MapManager *mapManager = nil;
+ (id)sharedMap
{
    if (mapManager == nil) {
        mapManager = [[MapManager alloc] init];
    }
    return mapManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _wSocket = [WSocket sharedWSocket];
        [self initMapView];
    }
    return self;
}

/// 实例化地图
- (void)initMapView
{
    _getAddressType = 0;
    _lastCity = @"定位中";
    _lastFormatterAddress = @"定位中";
    _lastCoor = CLLocationCoordinate2DMake(39.904987, 116.405281);
    
    /// 地图的基本配置
    _mapView = [[MAMapView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _mapView.delegate = self;
    _mapView.zoomLevel = MaxMapLevel;
    _mapView.mapType = MAMapTypeStandard;
    _mapView.showsUserLocation = YES;
    _mapView.showTraffic = NO;
    _mapView.showsScale = NO;
    _mapView.showsCompass = NO;
    [_mapView setUserTrackingMode:MAUserTrackingModeNone animated:YES];
    _mapView.distanceFilter = 20.0;
    _mapView.desiredAccuracy = kCLLocationAccuracyBest;
    _mapView.headingFilter = 90;
    
    self.locationManager = [[CLLocationManager alloc] init];

    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0)
    {
        [self.locationManager requestAlwaysAuthorization];
    }
    
    [AMapSearchServices sharedServices].apiKey = (NSString *)APIKey;
    self.search = [[AMapSearchAPI alloc] init];
    _search.delegate = self;
    [self.locationManager startUpdatingLocation];
    
    // 开启后台定位
//    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0) {
//        _mapView.allowsBackgroundLocationUpdates = YES;
//    } else {
//        _mapView.pausesLocationUpdatesAutomatically = NO;
//    }
}

/// 判断是否定位成功，如果成功，查看是否找到城市
- (void)setLocationNewCity
{
    if (_lastCoor.latitude != 0) {
        [self getAddressWithCoor:_lastCoor];

    } else {
        [self.locationManager startUpdatingLocation];
    }

}

/// 获取最后一次定位的经纬度
- (CLLocationCoordinate2D)getLastCoor
{
    return _lastCoor;
}

/// 获取最后一次定位的地址  yes为城市，no为详细地址
- (NSString *)getLastCityOrAddress:(BOOL)isCity
{
    if (isCity) {
        return _lastCity;
    }
    return _lastFormatterAddress;
}

#pragma mark - 添加大头针 && 选中大头针 && 取消选中大头针
/// 自定义添加大头针的样式
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MAPointAnnotation class]]) {
        static NSString *pointReuseIndetifier = @"pointReuseIndetifier";
        MAPinAnnotationView *view = (MAPinAnnotationView*)[_mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndetifier];
        if (view == nil) {
            view = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndetifier];
        }
        view.image = [UIImage imageNamed:@"touch_focus_x"];

        // 显示详细信息(左视图，右视图，主标题，副标题)
        view.canShowCallout = YES;
        view.animatesDrop = NO;
        view.draggable = NO;
        if ([annotation.title isEqualToString:@"ReceiveGiraffe"]) {
            NSLog(@"响应别人的Giraffe的请求");
        }
        
        return view;
    }

    return nil;
}

/// 添加大头针
- (void)mapView:(MAMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    MAAnnotationView *view = views[0];
    
    // 由于自己的定位取消不了，所以弄一张透明的图片作为定位图片
    if ([view.annotation isKindOfClass:[MAUserLocation class]])
    {
        view.canShowCallout = NO;

        MAUserLocationRepresentation *pre = [[MAUserLocationRepresentation alloc] init];
        pre.fillColor = [UIColor clearColor];
        pre.strokeColor = [UIColor clearColor];
        pre.image = kDefaultUserLocation;
        pre.lineWidth = 0;
        [self.mapView updateUserLocationRepresentation:pre];
    }
}

/// 选中大头针
- (void)mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view
{
    MAPointAnnotation *pointAnnotation = view.annotation;
    NSLog(@"title = %@",pointAnnotation.title);
    if ([pointAnnotation.title isEqualToString:@"当前位置"]) {
        [self mapView:mapView didDeselectAnnotationView:view];

    }
}

/// 取消选中大头针
- (void)mapView:(MAMapView *)mapView didDeselectAnnotationView:(MAAnnotationView *)view
{
    NSLog(@"deselected = %@",@"aaa");
}

#pragma mark - 地图的移动、缩放等基本功能
/// 长按地图
- (void)mapView:(MAMapView *)mapView didLongPressedAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    NSLog(@"长按地图");
}

/// 单机地图
- (void)mapView:(MAMapView *)mapView didSingleTappedAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    NSLog(@"单击地图");
    [[NSNotificationCenter defaultCenter] postNotificationName:kTapMapAction object:@"1"];
}

/// 地图平移
- (void)pan:(CLLocationCoordinate2D)center
{
    [_mapView setCenterCoordinate:center animated:YES];
}

/// 地图缩放 0是最小级别， -1是最大级别
- (void)zoom:(CGFloat)level
{
    if (level == -1) {
        level = _mapView.maxZoomLevel;
    } else if (level == 0) {
        level = _mapView.minZoomLevel;
    }
    [_mapView setZoomLevel:level animated:YES];
}

/// 地图倾斜加缩放
- (void)panAndZoom:(CLLocationCoordinate2D)center withSpan:(MACoordinateSpan)span
{
    MACoordinateRegion region;
    region.center = center;
    region.span = span;
    [_mapView setRegion:region animated:YES];
}

/// 截图功能，我没有实现，没有研究，有需要在看
- (void)captureAction:(CGRect)inRect
{
    UIImage *screenshotImage = [self.mapView takeSnapshotInRect:inRect];
    NSLog(@"screenshotImage = %@",screenshotImage);
}

#pragma mark - 正向地理编码 反向地理编码
/// 正向地理编码请求
- (void)getCoorWithAddress:(NSString *)address
{
    //构造AMapGeocodeSearchRequest对象，address为必选项，city为可选项
    AMapGeocodeSearchRequest *geo = [[AMapGeocodeSearchRequest alloc] init];
    geo.address = address;
    
    //发起正向地理编码
    [_search AMapGeocodeSearch:geo];
}

/// 反向地理编码请求
- (void)getAddressWithCoor:(CLLocationCoordinate2D)coor
{
    //构造AMapReGeocodeSearchRequest对象
    AMapReGeocodeSearchRequest *regeo = [[AMapReGeocodeSearchRequest alloc] init];
    regeo.location = [AMapGeoPoint locationWithLatitude:coor.latitude longitude:coor.longitude];
    regeo.radius = 10000;
    
    regeo.requireExtension = YES;
    
    [_search AMapReGoecodeSearch:regeo];
}

/// 正向地理编码 从城市获取到经纬度，然后根据经纬度更改地图显示的区域
- (void)onGeocodeSearchDone:(AMapGeocodeSearchRequest *)request response:(AMapGeocodeSearchResponse *)response
{
    [_wSocket.lbxManager showHubAction:1 showView:0];
    
    if (response.geocodes.count == 0)
    {
        [_wSocket.lbxManager showHudViewLabelText:@"未获取到经纬度" detailsLabelText:nil afterDelay:1];
        return;
    }
    
    if (response.geocodes.count) {
        AMapGeocode *geocode = [response.geocodes objectAtIndex:0];
        NSLog(@"从地址获取到的经纬度是%f %f",geocode.location.latitude,geocode.location.longitude);
        [self pan:CLLocationCoordinate2DMake(geocode.location.latitude, geocode.location.longitude)];
    }
}

/// 反向地理编码，从经纬度获取到城市详细信息的回调
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response
{
    NSString *city = response.regeocode.addressComponent.city;
    if (city.length <= 1) {
        city = response.regeocode.addressComponent.province;
    }
    
    if (_getAddressType == 0) {
        if (city.length) {
            if ([city isEqualToString:_lastCity] == NO) {
                _lastCity = city;
                [[NSNotificationCenter defaultCenter] postNotificationName:kLocationNewCity object:nil];
            }
        }
        _lastFormatterAddress = response.regeocode.formattedAddress;
    } else if (_getAddressType == 1) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateRequestAddress object:response.regeocode.formattedAddress];
    }
    _getAddressType = 0;

    NSLog(@"lastCity = %@",_lastCity);
}

#pragma mark - 地图定位的代理
/// 方向更改后
- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation
{
    NSLog(@"方向更新后---- %f  %f",userLocation.location.coordinate.latitude, userLocation.location.coordinate.longitude);
}

/// 定位成功的回调
-(void)mapView:(MAMapView*)mapView didUpdateUserLocation:(MAUserLocation*)userLocation updatingLocation:(BOOL)updatingLocation
{
    if(updatingLocation)
    {
        //取出当前位置的坐标
        NSLog(@"latitude : %f,longitude: %f",userLocation.coordinate.latitude,userLocation.coordinate.longitude);
        _lastCoor = CLLocationCoordinate2DMake(userLocation.location.coordinate.latitude, userLocation.location.coordinate.longitude);
        static int first = 0;
        if (first == 0) {
            [self pan:userLocation.coordinate];
        }
        first++;
        _getAddressType = 0;
        [self getAddressWithCoor:_lastCoor];
        
        [self reportSelfLocation];
    }
}

/// 提交给服务器定位
- (void)reportSelfLocation
{
    static int count = 0;
    
    if (count == 1) {
        return;
    }
    
    count = 1;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        count = 0;
        [[WSocket sharedWSocket] reportLocation:_lastCoor];
    });
}

/// 定位失败的回调
-(void)mapView:(MAMapView*)mapView didFailToLocateUserWithError:(NSError*)error
{
    NSLog(@"定位失败");
}

/// 将要开始定位
- (void)mapViewWillStartLocatingUser:(MAMapView *)mapView
{
    NSLog(@"将要开始定位");
}

/// 将要关闭定位
- (void)mapViewDidStopLocatingUser:(MAMapView *)mapView
{
    NSLog(@"将要关闭定位");
}

/// 更改了用户追踪模式
- (void)mapView:(MAMapView *)mapView didChangeUserTrackingMode:(MAUserTrackingMode)mode animated:(BOOL)animated
{
    NSLog(@"更改了用户的定位追踪模式");
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
//    NSLog(@"地图移动结束");
//    // 将坐标转化为经纬度
//    CLLocationCoordinate2D start_location = [_mapView convertPoint:CGPointMake(0, 0) toCoordinateFromView:_mapView];
//    CLLocationCoordinate2D stop_location = [_mapView convertPoint:CGPointMake(self.mapView.frame.size.width, _mapView.frame.size.height) toCoordinateFromView:_mapView];
//    
//    __weak WSocket *weakSocket = _wSocket;
    
//    [_wSocket getRangeUserCount:YES rangeVideoList:YES lastVideoId:@"0" startCoor:start_location stopCoor:stop_location getBlock:^(int ret, NSDictionary *rootDict) {
//        if (ret == kConnectFailue) {
//            [weakSocket.lbxManager showHudViewLabelText:@"请求失败，请重试" detailsLabelText:nil afterDelay:1];
//        } else {
//            [[NSNotificationCenter defaultCenter] postNotificationName:kFirstRangeVideoList object:rootDict];
//        }
//    }];
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
    
    [_wSocket.lbxManager showHubAction:0 showView:[[UIApplication sharedApplication] keyWindow]];

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
    [_wSocket.lbxManager showHubAction:1 showView:nil];
    if (response.pois.count == 0) {
        [_wSocket.lbxManager showHudViewLabelText:@"没有检索到输数据" detailsLabelText:nil afterDelay:1];
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
}

#pragma mark - 输入提示搜索
/// 输入提示搜索
- (void)inputTipsWithKeyword:(NSString *)keyword city:(NSString *)city
{
    AMapInputTipsSearchRequest *tipsRequest = [[AMapInputTipsSearchRequest alloc] init];
    tipsRequest.keywords = keyword;
    if (city.length) {
        tipsRequest.city = city;
    }
    
    //发起输入提示搜索
    [_search AMapInputTipsSearch: tipsRequest];
}

//实现输入提示的回调函数
-(void)onInputTipsSearchDone:(AMapInputTipsSearchRequest*)request response:(AMapInputTipsSearchResponse *)response
{
    if(response.tips.count == 0)
    {
        return;
    }
    
    /*
     @property (nonatomic, copy) NSString *uid; //!< poi的id
     @property (nonatomic, copy) NSString *name; //!< 名称
     @property (nonatomic, copy) NSString *adcode; //!< 区域编码
     @property (nonatomic, copy) NSString *district; //!< 所属区域
     @property (nonatomic, copy) AMapGeoPoint *location; //!< 位置
     */
    
    //通过AMapInputTipsSearchResponse对象处理搜索结果
    NSString *strCount = [NSString stringWithFormat:@"count: %d", (int)response.count];
    NSString *strtips = @"";
    for (AMapTip *p in response.tips) {
        strtips = [NSString stringWithFormat:@"%@\nTip: %@", strtips, p.name];
    }
    NSString *result = [NSString stringWithFormat:@"%@ \n %@", strCount, strtips];
    NSLog(@"InputTips: %@", result);
}

#pragma mark - 下面是针对的方法
/// Giraffe请求，显示地图经纬度，并且显示特定图标
- (void)showGiraffeIconWithCoor:(CLLocationCoordinate2D)coor
{
    [self pan:CLLocationCoordinate2DMake(coor.latitude, coor.longitude)];
    
//    /// 这里封装个view，获取组装好的view
//    MAPointAnnotation *pointAnnotation = [[MAPointAnnotation alloc] init];
//    pointAnnotation.coordinate = coor;
//    pointAnnotation.title = @"想知道苏州观前街现在变成什么样子了......";
//    [_mapView addAnnotation:pointAnnotation];
}

@end
