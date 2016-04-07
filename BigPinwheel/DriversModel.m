//
//  DriversModel.m
//  BigPinwheel
//
//  Created by MZero on 16/3/1.
//  Copyright © 2016年 leita. All rights reserved.
//

#import "DriversModel.h"

#define sj (((arc4random() % 21) - 10)*0.01)

@interface DriversModel ()

@property(nonatomic,strong)NSMutableArray *driversArray;

@end

@implementation DriversModel

+ (DriversModel *)sharedManager
{
    static DriversModel *dm = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        dm = [[self alloc] init];
    });
    return dm;
}

//假数据
- (NSMutableArray *)driversArrayWith:(MAUserLocation *)userLocation
{
    if (!_driversArray) {
        
        double latitude = userLocation.coordinate.latitude;
        double longitude = userLocation.coordinate.longitude;
        
        _driversArray = [NSMutableArray array];
        while (_driversArray.count < 20) {
            
            NSArray *array = @[[NSNumber numberWithFloat:(latitude+sj)],[NSNumber numberWithFloat:(longitude+sj)],@"dsfs",@"2"];
            [_driversArray addObject:array];
        }
        NSLog(@"%@",_driversArray);
    }
    return _driversArray;
}


@end
