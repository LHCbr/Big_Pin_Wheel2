//
//  HPHeaderView.h
//  BigPinwheel
//
//  Created by xuwei on 16/4/13.
//  Copyright © 2016年 leita. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HPHeaderViewDelegate <NSObject>

-(void)segementDidSelectIndex:(UISegmentedControl *)sender;

@end

@interface HPHeaderView : UIView

@property(strong,nonatomic)UIButton *mapBtn;

@property(weak,nonatomic)id<HPHeaderViewDelegate> delegate;
@end
