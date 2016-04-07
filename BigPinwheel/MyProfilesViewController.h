//
//  MyProfilesViewController.h
//  BigPinwheel
//
//  Created by 徐伟 on 16/1/25.
//  Copyright © 2016年 leita. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PriceAreaEditViewController.h"
#import "DFCUserInfo.h"


@protocol MyProfilesViewControllerDelegate <NSObject>

-(void)priceAreaCellDidSelectedWithIndex:(NSInteger)index;

-(void)changePriceLabelFrame:(NSArray *)array;

@end

@interface MyProfilesViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextViewDelegate>

@property(strong,nonatomic)UITableView *tableView;
@property(strong,nonatomic)NSMutableArray *dataArray;

@property(weak,nonatomic)id<MyProfilesViewControllerDelegate>delegate;


@end
