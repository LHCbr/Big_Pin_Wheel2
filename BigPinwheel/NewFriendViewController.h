//
//  NewFriendViewController.h
//  BigPinwheel
//
//  Created by xuwei on 16/3/4.
//  Copyright © 2016年 leita. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "addFriendsCell.h"
#import "PhoneContactViewController.h"


@interface NewFriendViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,addFriendsCellDelegate>

@property(strong,nonatomic)UIButton *addFrindBtn;

@property(strong,nonatomic)UITableView *tableView;
@property(strong,nonatomic)NSMutableArray *dataArray;

@end
