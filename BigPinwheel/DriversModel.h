//
//  DriversModel.h
//  BigPinwheel
//
//  Created by MZero on 16/3/1.
//  Copyright © 2016年 leita. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MAMapKit/MAMapKit.h>

@interface DriversModel : NSObject

+ (DriversModel *)sharedManager;

- (NSMutableArray *)driversArrayWith:(MAUserLocation *)userLocation;

@end
