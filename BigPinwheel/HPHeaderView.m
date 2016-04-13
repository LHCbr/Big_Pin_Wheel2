//
//  HPHeaderView.m
//  BigPinwheel
//
//  Created by xuwei on 16/4/13.
//  Copyright © 2016年 leita. All rights reserved.
//

#import "HPHeaderView.h"

@implementation HPHeaderView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        
        UISegmentedControl *segmentedControl = [[UISegmentedControl alloc]initWithItems:@[@"车主报价",@"地主需求"]];
        segmentedControl.frame = CGRectMake(kDeviceWidth/2 -100,10 , 200, frame.size.height - 20);
        segmentedControl.selectedSegmentIndex = 0;
        [segmentedControl addTarget:self action:@selector(segmentWillSelectIndex:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:segmentedControl];
        
        //地图btn
        _mapBtn =[UIButton buttonWithType:UIButtonTypeCustom];
        _mapBtn.backgroundColor = [UIColor purpleColor];
        _mapBtn.frame = CGRectMake(frame.size.width - 60, segmentedControl.frame.origin.y, 50, frame.size.height - 20);
        [_mapBtn setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        [self addSubview:_mapBtn];
    }
    return self;
}

-(void)segmentWillSelectIndex:(UISegmentedControl *)sender
{
    [_delegate segementDidSelectIndex:sender];
}



@end
