//
//  UploadingModel.h
//  LuLu
//
//  Created by a on 11/16/15.
//  Copyright © 2015 lbx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OperationModel.h"



@interface UploadingModel : OperationModel

@property (nonatomic, copy) NSString *fileName; // 上传名字
@property (nonatomic, strong) NSData *data;     // 上传数据
@property (nonatomic, assign) int time;         // 上传计时
@property (nonatomic, assign) int count;        // 目前上传次数
@property (nonatomic, assign) int fileType;     // 上传的文件类型

@property (nonatomic, copy) NSString *serialId; // 上传文件的ID

@property (nonatomic, strong) id  info;         // 上传的文件的所有的信息 目前有视频、聊天

- (instancetype)initWithFileName:(NSString *)fileName
                            data:(NSData *)data
                        fileType:(int)fileType
                            time:(int)time
                           count:(int)count
                           block:(id)block
                        serialId:(NSString *)serialId
                       modelType:(ModelType)modelType
                            info:(id)info;

@end
