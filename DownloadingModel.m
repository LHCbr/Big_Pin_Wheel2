//
//  DownloadingModel.m
//  LuLu
//
//  Created by a on 11/16/15.
//  Copyright © 2015 lbx. All rights reserved.
//

#import "DownloadingModel.h"

@implementation DownloadingModel

- (instancetype)initWithFileUrl:(NSString *)fileUrl
                           time:(int)time
                          count:(int)count
                          block:(id)block
                       serialId:(NSString *)serialId
                      modelType:(ModelType)modelType
                           info:(id)info
{
    self = [super init];
    if (self) {
        _fileUrl = fileUrl;
        _time = time;
        _count = count;
        _aBlock = block;
        _serialId = serialId;
        _modelType = modelType;
        _info = info;
    }
    return self;
}

@end
