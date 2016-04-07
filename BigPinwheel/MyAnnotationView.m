//
//  MyAnnotationView.m
//  BigPinwheel
//
//  Created by MZero on 16/3/1.
//  Copyright © 2016年 leita. All rights reserved.
//

#import "MyAnnotationView.h"

@implementation MyAnnotationView

#define kCalloutWidth       200.0
#define kCalloutHeight      70.0

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    if (self.selected == selected)
    {
        return;
    }
    
    if (selected)
    {
        if (self.myCalloutView == nil)
        {
            self.myCalloutView = [[CalloutView alloc]initWithFrame:CGRectMake(0, 0, kCalloutWidth, kCalloutHeight)];
            self.myCalloutView.center = CGPointMake(CGRectGetWidth(self.bounds) / 2.f + self.calloutOffset.x,
                                                  -CGRectGetHeight(self.myCalloutView.bounds) / 2.f + self.calloutOffset.y);
            
            self.myCalloutView.subtitleLabel.text = [NSString stringWithFormat:@"1位收割师傅正在收割"];
        }
        
        [self addSubview:self.myCalloutView];
    }
    else
    {
        [self.myCalloutView removeFromSuperview];
    }
    
    [super setSelected:selected animated:animated];
}

@end
