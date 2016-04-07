//
//  FindDriversV.m
//  BigPinwheel
//
//  Created by MZero on 16/3/1.
//  Copyright © 2016年 leita. All rights reserved.
//

#import "FindDriversV.h"
#import <MAMapKit/MAMapKit.h>

#define AMapKey @"6f209cf99a96b9aa21032edc643f3224"


@implementation FindDriversV

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        [self location];
        [self addAMapView];
    }
    return self;
}

/**
 *  定位
 */
- (void)location{
    
    _locationManager = [[AMapLocationManager alloc] init];
    //百米
    _locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    _locationManager.distanceFilter = 100;
//    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0)
//    {
//        [self.locationManager requestAlwaysAuthorization];
//    }
    // 开始定位
    [_locationManager startUpdatingLocation];
}

/**
 *  添加地图视图
 */
- (void)addAMapView{
    
    [MAMapServices sharedServices].apiKey = (NSString *)AMapKey;
    [AMapSearchServices sharedServices].apiKey = (NSString *)AMapKey;
    [AMapLocationServices sharedServices].apiKey = (NSString *)AMapKey;
    
    _mapView = [[MAMapView alloc] initWithFrame:self.bounds];
    _mapView.showsScale = NO; //隐藏比例尺
    _mapView.showsUserLocation = YES; //显示用户位置
    //地图跟着位置移动
    [_mapView setUserTrackingMode: MAUserTrackingModeFollow animated:YES];
    _mapView.zoomLevel = 16;
    [self addSubview:_mapView];
}

@end
