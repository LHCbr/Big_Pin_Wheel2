//
//  TipView.h
//  BigPinwheel
//
//  Created by xumckay on 16/3/21.
//  Copyright © 2016年 leita. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol tipViewDelegate <NSObject>

@optional

-(void)cancelBtnClicked;

-(void)sureBtnClicked;


@end

@interface TipView : UIView

@property(assign,nonatomic)id<tipViewDelegate>delegate;

@end
