//
//  FrindsApplyViewController.h
//  BigPinwheel
//
//  Created by xuwei on 16/3/4.
//  Copyright © 2016年 leita. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FrindsApplyViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>

@property(strong,nonatomic)UITableView *tableView;
@property(strong,nonatomic)NSMutableArray *dataArray;

@end
