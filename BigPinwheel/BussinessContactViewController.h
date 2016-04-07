//
//  BussinessContactViewController.h
//  BigPinwheel
//
//  Created by 徐伟 on 16/2/14.
//  Copyright © 2016年 leita. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BussinessContactViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property(strong,nonatomic)UITableView *tableView;
@property(strong,nonatomic)NSMutableArray *dataArray;

@end
