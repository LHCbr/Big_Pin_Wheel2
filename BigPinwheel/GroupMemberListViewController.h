//
//  GroupMemberListViewController.h
//  leita
//
//  Created by a on 7/22/15.
//
//

#import <UIKit/UIKit.h>

@interface GroupMemberListViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,UIActionSheetDelegate>
@property (copy, nonatomic) NSString *groupId;  // 群的ID
@property (strong, nonatomic) NSMutableArray *userList;
@property (strong, nonatomic) NSMutableArray *memberList;
@property (strong, nonatomic) UITableView *tableView;

@end
