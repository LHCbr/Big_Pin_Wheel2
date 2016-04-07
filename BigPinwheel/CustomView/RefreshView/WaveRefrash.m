//
//  WaveRefrash.m
//  Shop
//
//  Created by 许 萍 on 14-5-13.
//  Copyright (c) 2014年 许 萍. All rights reserved.
//

#import "WaveRefrash.h"

@interface WaveRefrash()

- (void)setState:(WavePullRefreshState)aState;

@end

@implementation WaveRefrash

- (void)dealloc
{

}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.edgeInsetsTop = 65.0f;
        self.edgeInsetsBottom = 44.0f;
    }
    
    return self;
}

#pragma mark - Setters
- (void)setState:(WavePullRefreshState)aState
{
	_state = aState;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
