//
//  IMRefrashHeaderView.m
//  LeiRen
//
//  Created by tw001 on 14-9-22.
//  Copyright (c) 2014年 wave. All rights reserved.
//

#import "IMRefrashHeaderView.h"

@implementation IMRefrashHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _edgeInsetsTop = 40.0f;
        _edgeInsetsBottom = 0.0f;
        _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		[self addSubview:_activityView];
        
        _activityView.frame = CGRectMake((self.frame.size.width - _edgeInsetsTop) / 2, 0, _edgeInsetsTop, _edgeInsetsTop);
        
        [self setState:WavePullRefreshNormal];
        
    }
    return self;
}

#pragma mark - Setters
- (void)setState:(WavePullRefreshState)aState
{
    switch (aState) {
		case WavePullRefreshPulling:
//			[CATransaction begin];
//			[CATransaction setAnimationDuration:kFlipAnimationDuration];
//			[CATransaction commit];
			break;
		case WavePullRefreshNormal:
			if (_state == WavePullRefreshPulling) {
//				[CATransaction begin];
//				[CATransaction setAnimationDuration:kFlipAnimationDuration];
//				[CATransaction commit];
			}
			[_activityView stopAnimating];
//			[CATransaction begin];
//			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
//			[CATransaction commit];
//			[self refreshLastUpdatedDate];
			break;
            
		case WavePullRefreshLoading:
			[_activityView startAnimating];
//			[CATransaction begin];
//			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
//			[CATransaction commit];
			break;
		default:
			break;
	}
	
	_state = aState;
}

#pragma mark - 实例方法
/// 更新最后更新时间
- (void)refreshLastUpdatedDate
{
    
}

/// 返回格式化时间
- (NSString *)getFormatterDate:(NSDate *)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:[NSString stringWithFormat:@"%@", kDateFormat]];
    NSString *dateString = [NSString stringWithFormat:@"%@", [formatter stringFromDate:date]];
    
    return dateString;
}

/// scroll contentInset
- (void)scrollContentInset
{
    [self setState:WavePullRefreshLoading];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2];
    _scrollView.contentInset = UIEdgeInsetsMake(_edgeInsetsTop, 0.0f, _edgeInsetsBottom, 0.0f);
    [UIView commitAnimations];
}

#pragma mark - ScrollView Methods
/// 滚动
- (void)waveScrollViewDidScroll
{
    if (_state == WavePullRefreshLoading) {
        
    }else{
        if (_scrollView.contentOffset.y <= -5.0f && !_isLoading) {
            if (_delegate != nil) {
                [_delegate HeaderTriggerRefresh];
            }
            [self scrollContentInset];
        }
    }
}

/// 结束刷新
- (void)waveRefreshDidFinishedLoading
{
    //[UIView beginAnimations:nil context:NULL];
    //[UIView setAnimationDuration:.1];
    //[_scrollView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, _edgeInsetsBottom, 0.0f)];
    //[UIView commitAnimations];
	
	[self setState:WavePullRefreshNormal];
    if (_delegate != nil) {
        [_delegate EndTriggerRefresh];
    }
}

/// 结束刷新
- (void)waveRefreshDidFinishedLoading2
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:.3];
    [_scrollView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, _edgeInsetsBottom, 0.0f)];
    [UIView commitAnimations];
    
    [self setState:WavePullRefreshNormal];
}

@end
