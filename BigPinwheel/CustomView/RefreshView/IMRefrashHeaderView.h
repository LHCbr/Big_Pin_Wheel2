//
//  IMRefrashHeaderView.h
//  LeiRen
//
//  Created by tw001 on 14-9-22.
//  Copyright (c) 2014年 wave. All rights reserved.
//

#import "WaveRefrash.h"
#import "WaveRefrash.h"

@protocol IMRefrashHeadeDelegate <NSObject>

@optional
- (void)HeaderTriggerRefresh;
- (void)EndTriggerRefresh;

@end

@interface IMRefrashHeaderView : WaveRefrash
{
    UIActivityIndicatorView *_activityView;
}

@property (nonatomic, retain) UIActivityIndicatorView *activityView;    // 风火轮
@property (nonatomic, assign) id<IMRefrashHeadeDelegate>delegate;

#pragma mark - 实例方法
/// 更新最后更新时间
- (void)refreshLastUpdatedDate;
/// 返回格式化时间
- (NSString *)getFormatterDate:(NSDate *)date;
/// scroll contentInset
- (void)scrollContentInset;

#pragma mark - ScrollView Methods
/// 滚动
- (void)waveScrollViewDidScroll;
/// 结束刷新
- (void)waveRefreshDidFinishedLoading;
/// 结束刷新
- (void)waveRefreshDidFinishedLoading2;

@end
