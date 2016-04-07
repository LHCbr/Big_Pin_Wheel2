//
//  DownloadingModel.h
//  LuLu
//
//  Created by a on 11/16/15.
//  Copyright © 2015 lbx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OperationModel.h"

@interface DownloadingModel : OperationModel

@property (nonatomic, copy) NSString *fileUrl;    // 下载地址
@property (nonatomic, assign) int time;           // 下载计时
@property (nonatomic, assign) int count;          // 目前下载次数

@property (nonatomic, copy) NSString *serialId;   // 下载文件的ID

@property (nonatomic, strong) id  info;           // 下载的文件的所有的信息 目前有视频、聊天

- (instancetype)initWithFileUrl:(NSString *)fileUrl
                            time:(int)time
                           count:(int)count
                           block:(id)block
                        serialId:(NSString *)serialId
                       modelType:(ModelType)modelType
                            info:(id)info;

@end
