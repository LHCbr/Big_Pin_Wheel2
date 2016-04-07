//
//  HomeViewController.h
//  BigPinwheel
//
//  Created by 徐伟 on 16/1/19.
//  Copyright © 2016年 leita. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WJID.h"

@interface HomeViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property(strong,nonatomic)UITableView *tableView;
@property(strong,nonatomic)NSMutableArray *dataArray;

///进入聊天
-(void)goChatVC:(WJID *)uJid isSelectedInexPath:(BOOL)isSelected;

@end
