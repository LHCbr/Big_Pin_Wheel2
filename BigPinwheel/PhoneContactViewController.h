//
//  PhoneContactViewController.h
//  BigPinwheel
//
//  Created by xuwei on 16/4/1.
//  Copyright © 2016年 leita. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "addFriendsCell.h"

#define kPhoneRegex @"^[1][3,4,5,7,8,9][\\d]{9}$"

@interface PhoneContactViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,addFriendsCellDelegate>

@property(copy,nonatomic)NSString *cacheList;
@property(assign,nonatomic)BOOL isUpdateContactList;

@property(strong,nonatomic) NSMutableArray *backFriends;

@property(strong,nonatomic)UITableView *tableView;

@end
