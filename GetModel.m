//
//  GetModel.m
//  LuLu
//
//  Created by a on 11/20/15.
//  Copyright © 2015 lbx. All rights reserved.
//

#import "GetModel.h"

@implementation GetModel

- (instancetype)initWithInfo:(NSDictionary *)dict block:(id)block
{
    self = [super init];
    if (self) {
        _aBlock = block;
        
        _phone = [NSString stringWithFormat:@"%@",[dict objectForKey:kModelPhone]];
        _lastId = [NSString stringWithFormat:@"%@",[dict objectForKey:kModelLastId]];
        _serialId = [NSString stringWithFormat:@"%@",[dict objectForKey:kModelSerialId]];
        _area = [NSString stringWithFormat:@"%@",[dict objectForKey:kModelArea]];
        _startLongitude = [NSString stringWithFormat:@"%@",[dict objectForKey:kModelStartLongitude]];
        _startLatitude = [NSString stringWithFormat:@"%@",[dict objectForKey:kModelStartLatitude]];
        _stopLongitude = [NSString stringWithFormat:@"%@",[dict objectForKey:kModelStopLongtidue]];
        _stopLatitude = [NSString stringWithFormat:@"%@",[dict objectForKey:kModelStopLatitude]];
        _count = 0;
        
    }
    return self;
}

@end


