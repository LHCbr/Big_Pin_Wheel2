//
//  CalloutView.m
//  BigPinwheel
//
//  Created by MZero on 16/3/1.
//  Copyright © 2016年 leita. All rights reserved.
//

#import "CalloutView.h"

#define kArrorHeight        10

#define kPortraitMargin     0
#define kPortraitWidth      62
#define kPortraitHeight     60

#define kTitleWidth         120
#define kTitleHeight        25

@interface CalloutView ()

@end

@implementation CalloutView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 6.0;
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews
{
    // 添加图片
    self.portraitView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kPortraitWidth, kPortraitHeight)];
    self.portraitView.image = [UIImage imageNamed:@"找司机-位置"];
    self.portraitView.backgroundColor = [UIColor blackColor];
//    self.portraitView.layer.masksToBounds = YES;
//    self.portraitView.layer.cornerRadius = 6.0;
    [self addSubview:self.portraitView];
    
    // 添加标题
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kPortraitMargin * 2 + kPortraitWidth, kPortraitMargin+5, kTitleWidth, kTitleHeight)];
    self.titleLabel.font = [UIFont systemFontOfSize:12];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.text = @"当前位置有:";
    [self addSubview:self.titleLabel];
    
    // 添加副标题
    self.subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kPortraitMargin * 2 + kPortraitWidth, kPortraitMargin * 2 + kTitleHeight+5, kTitleWidth, kTitleHeight)];
    self.subtitleLabel.font = [UIFont systemFontOfSize:12];
    self.subtitleLabel.textAlignment = NSTextAlignmentCenter;
    self.subtitleLabel.text = @"1位收割师傅正在收割";
    [self addSubview:self.subtitleLabel];
}

- (void)drawRect:(CGRect)rect
{
    
    [self drawInContext:UIGraphicsGetCurrentContext()];
    
    self.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.layer.shadowOpacity = 1.0;
    self.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    
}

- (void)drawInContext:(CGContextRef)context
{
    
    CGContextSetLineWidth(context, 1.0);
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    [self getDrawPath:context];
    CGContextFillPath(context);
}

- (void)getDrawPath:(CGContextRef)context
{
    CGRect rrect = self.bounds;
    CGFloat radius = 6.0;
    CGFloat minx = CGRectGetMinX(rrect),
    midx = CGRectGetMidX(rrect),
    maxx = CGRectGetMaxX(rrect);
    CGFloat miny = CGRectGetMinY(rrect),
    maxy = CGRectGetMaxY(rrect)-kArrorHeight;
    
    CGContextMoveToPoint(context, midx+kArrorHeight, maxy);
    CGContextAddLineToPoint(context,midx, maxy+kArrorHeight);
    CGContextAddLineToPoint(context,midx-kArrorHeight, maxy);
    
    CGContextAddArcToPoint(context, minx, maxy, minx, miny, radius);
    CGContextAddArcToPoint(context, minx, minx, maxx, miny, radius);
    CGContextAddArcToPoint(context, maxx, miny, maxx, maxx, radius);
    CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
    CGContextClosePath(context);
    
}

@end
