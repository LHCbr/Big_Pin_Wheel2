//
//  FindDriversV.h
//  BigPinwheel
//
//  Created by MZero on 16/3/1.
//  Copyright © 2016年 leita. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import <AMapLocationKit/AMapLocationKit.h>



@interface FindDriversV : UIView

/**
 *  地图视图
 */
@property(nonatomic, strong) MAMapView *mapView;
/**
 *  定位管理
 */
@property (nonatomic, strong) AMapLocationManager *locationManager;


@end
