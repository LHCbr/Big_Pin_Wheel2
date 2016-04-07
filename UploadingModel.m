//
//  UploadingModel.m
//  LuLu
//
//  Created by a on 11/16/15.
//  Copyright © 2015 lbx. All rights reserved.
//

#import "UploadingModel.h"

@implementation UploadingModel

- (instancetype)initWithFileName:(NSString *)fileName
                            data:(NSData *)data
                        fileType:(int)fileType
                            time:(int)time
                           count:(int)count
                           block:(id)block
                        serialId:(NSString *)serialId
                       modelType:(ModelType)modelType
                            info:(id)info
{
    self = [super init];
    if (self) {
        _time = time;
        _count = count;
        _fileName = fileName;
        _data = data;
        _fileType = fileType;
        _aBlock = block;
        _serialId = serialId;
        _modelType = modelType;
        _info = info;
    }
    return self;
}

@end
