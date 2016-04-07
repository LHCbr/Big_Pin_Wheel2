//
//  NormalContactViewController.h
//  LuLu
//
//  Created by lbx on 16/2/22.
//  Copyright © 2016年 lbx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddressBookTableViewCell.h"
#import "WJID.h"
#import "MBProgressHUD.h"

@protocol AddressBookViewControllerDelegate <NSObject>

@optional
- (void)selectedUser:(WJID *)uJid;

@end


@interface NormalContactViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UISearchBarDelegate, UIAlertViewDelegate,UIGestureRecognizerDelegate>

@property (assign, nonatomic) float navHeight;
@property (strong, nonatomic) UIImageView *aNav;
@property (strong, nonatomic) UIView *atTop;
@property (assign, nonatomic) BOOL isSearch;
@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UITextField *searchTextField;
@property (strong, nonatomic) NSMutableDictionary *dataArray;
@property (strong, nonatomic) NSMutableArray *groups;
@property (strong, nonatomic) UIButton *tipBtn;
@property (strong, nonatomic) NSFileManager *fileManager;
@property (strong, nonatomic) MBProgressHUD *HUD;
@property (assign, nonatomic) int fromType;
@property (assign, nonatomic) id<AddressBookViewControllerDelegate>delegate;
@property (strong, nonatomic) UILabel *refrashContentLabel;
@property (strong, nonatomic) UIImageView *refrashImageView;
@property (strong, nonatomic) UIView *refrashView;
@property (assign, nonatomic) BOOL refrashState;    // 是否在刷新中
@property (strong, nonatomic) NSTimer *timer;       // 刷新时间
@property (assign, nonatomic) int refrashCount;     // 刷新计时
@property (strong, nonatomic) NSIndexPath *nIndexPath;
@property (copy, nonatomic) NSString *notename;
@property (strong, nonatomic) UITableView *resultTableView;
@property (strong, nonatomic) NSMutableArray *resultDataArray;

@end
