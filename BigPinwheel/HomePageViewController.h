//
//  HomePageViewController.h
//  BigPinwheel
//
//  Created by xuwei on 16/4/7.
//  Copyright © 2016年 leita. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HPHeaderView.h"

@interface HomePageViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,HPHeaderViewDelegate>

@property(strong,nonatomic)UITableView *tableView;
@property(strong,nonatomic)NSMutableArray *dataArray;


@end
