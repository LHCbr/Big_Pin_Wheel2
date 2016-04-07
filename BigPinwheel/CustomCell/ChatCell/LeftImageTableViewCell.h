//
//  LeftImageTableViewCell.h
//  BDMapDemo
//
//  Created by tw001 on 14-9-29.
//  Copyright (c) 2014年 ESX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LeftTableViewCell.h"

@protocol LeftImageTableViewCellDelegate <NSObject>

@optional
/// 重新发送消息
- (void)resendMsg:(NSInteger)rowIndex;
/// 查看图片
- (void)lookImage:(NSInteger)rowIndex;
/// 销毁图片
- (void)destroyImage:(NSInteger)rowIndex;
@end

@interface LeftImageTableViewCell : LeftTableViewCell

@property (assign, nonatomic) NSInteger rowIndex;
@property (strong, nonatomic) UIView *picView;
@property (strong, nonatomic) UILabel *progressLabel;
@property (strong, nonatomic) UIImageView *picImageView;

@property (assign, nonatomic) id<LeftImageTableViewCellDelegate>delegate;

/// 设置消息内容
- (void)setMsgContent:(ChatObject *)msgObj;

/// 获得高度
+ (float)getMsgHeight:(ChatObject *)msgObj;

@end
