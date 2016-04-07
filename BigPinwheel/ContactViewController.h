//
//  ContactViewController.h
//  BigPinwheel
//
//  Created by 徐伟 on 16/2/19.
//  Copyright © 2016年 leita. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactCell.h"

@interface ContactViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,ContactCellDelegate>

@property(strong,nonatomic)NSMutableArray *dataArray;
@property(strong,nonatomic)UITableView *tableView;

@property(strong,nonatomic)NSMutableArray *groups;
@property(strong,nonatomic)NSMutableDictionary *friendsList;

@end
