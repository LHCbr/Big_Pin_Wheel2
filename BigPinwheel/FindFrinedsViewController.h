//
//  FindFrinedsViewController.h
//  BigPinwheel
//
//  Created by 徐伟 on 16/2/20.
//  Copyright © 2016年 leita. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyFriendsHeaderView.h"
#import "QualifyFilterView.h"

@interface FindFrinedsViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,MyFriendsHeaderViewDelegate,QualifyFilterViewDelegate>
@property(strong,nonatomic)UITableView *tableView;
@property(strong,nonatomic)NSMutableArray *dataArray;

@property(strong,nonatomic)NSMutableDictionary *UserInfoDict;

@end
