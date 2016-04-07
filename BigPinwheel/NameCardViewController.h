//
//  NameCardViewController.h
//  BigPinwheel
//
//  Created by 徐伟 on 16/2/15.
//  Copyright © 2016年 leita. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DFCUserInfo.h"


@interface NameCardViewController : UIViewController<UIScrollViewDelegate,UITextFieldDelegate,UIBarPositioningDelegate,UINavigationBarDelegate>

@property(strong,nonatomic)UIScrollView *scrollView;
@property(strong,nonatomic)NSMutableArray *dataArray;
@property(assign,nonatomic)BOOL isDriver;

@property(strong,nonatomic)DFCUserInfo *userinfo;


@end
