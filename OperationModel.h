//
//  OperationModel.h
//  LuLu
//
//  Created by a on 11/23/15.
//  Copyright © 2015 lbx. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    ModelTypeNormal = 0,    // 普通类型， info为空
    ModelTypeChat,          // 聊天类型， info为ChatObject类型(包含发送视频)
    ModelTypeVideo,         // 视频类型， info为视频的类型，（除了聊天视频的其他视频）
    ModelTypeOther          // 其他类型， 暂时没有
}ModelType;

@interface OperationModel : NSObject
{
    ModelType _modelType;
    NSInvocationOperation *_operation;
    id _aBlock;
}
@property (nonatomic, strong)NSInvocationOperation *operation;  // 上传的线程
@property (nonatomic, copy) id aBlock;                          // 传进来的block
@property (nonatomic, assign) ModelType modelType;              // 上传的文件是聊天还是视频还是其他
@end
