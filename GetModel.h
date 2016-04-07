//
//  GetModel.h
//  LuLu
//
//  Created by a on 11/20/15.
//  Copyright © 2015 lbx. All rights reserved.
//

/*
    这个是用于从服务器上请求数据的一个综合的请求model，后续会不断的加字段
 
 */

#import <Foundation/Foundation.h>
#import "OperationModel.h"

@interface GetModel : OperationModel

@property (nonatomic,   copy)   NSString *phone;     // 手机号
@property (nonatomic,   copy)   NSString *area;      // 手机区号
@property (nonatomic,   copy)   NSString *lastId;    // 多页请求的时候的最后一个id
@property (nonatomic,   copy)   NSString *serialId;  // 用于服务器和本地交互的唯一id
@property (nonatomic, assign)   int count;           // 计时

@property (nonatomic,   copy)   NSString *startLongitude;   // 跟地图相关的经纬度
@property (nonatomic,   copy)   NSString *startLatitude;    // 跟地图相关的经纬度
@property (nonatomic,   copy)   NSString *stopLongitude;    // 跟地图相关的经纬度
@property (nonatomic,   copy)   NSString *stopLatitude;     // 跟地图相关的经纬度

- (instancetype)initWithInfo:(NSDictionary *)dict block:(id)block;

@end
