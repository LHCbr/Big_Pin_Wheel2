//
//  MapManager.h
//  LuLu
//
//  Created by a on 10/27/15.
//  Copyright © 2015 lbx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <AVFoundation/AVFoundation.h>
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import <UIKit/UIKit.h>

@interface MapManager : NSObject<MAMapViewDelegate, AMapSearchDelegate>

@property (nonatomic, strong)MAMapView *mapView;                  // 高德地图
@property (nonatomic, strong)AMapSearchAPI *search;               // 搜索句柄

@property (nonatomic, strong)CLLocationManager *locationManager;  // 定位句柄

@property (nonatomic,   copy)NSString *lastCity;                  // 最后一次定位的城市
@property (nonatomic,   copy)NSString *lastFormatterAddress;      // 最后一次定位的详细地址
@property (nonatomic, assign)CLLocationCoordinate2D lastCoor;     // 最后一次定位的经纬度

@property (nonatomic, assign)int getAddressType;                  // 获取地址的类型

/// 地图单例
+ (id)sharedMap;

/// 判断是否定位成功，如果成功，查看是否找到城市
- (void)setLocationNewCity;

/// 获取最后一次定位的经纬度
- (CLLocationCoordinate2D)getLastCoor;

/// 获取最后一次定位的地址  yes为城市，no为详细地址
- (NSString *)getLastCityOrAddress:(BOOL)isCity;

/// 输入提示搜索
- (void)inputTipsWithKeyword:(NSString *)keyword city:(NSString *)city;

/// 正向地理编码请求
- (void)getCoorWithAddress:(NSString *)address;

/// 反向地理编码请求
- (void)getAddressWithCoor:(CLLocationCoordinate2D)coor;

/// 执行搜索 searchType   0 是关键字搜索  1 是周边搜索  2 多边形搜索
- (void)searchWithCoor:(CLLocationCoordinate2D)coor
               keyWord:(NSString *)keyWord
            searchType:(int)searchType;

/// Giraffe请求，显示地图经纬度，并且显示特定图标
- (void)showGiraffeIconWithCoor:(CLLocationCoordinate2D)coor;
@end
