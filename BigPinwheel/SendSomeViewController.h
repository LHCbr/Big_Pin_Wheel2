//
//  SendSomeViewController.h
//  leita
//
//  Created by tw001 on 15/5/26.
//
//

#import <UIKit/UIKit.h>
#import "WJID.h"
#import "MBProgressHUD.h"
#import "SendSomeTableViewCell.h"

typedef enum : NSUInteger {
    FromDefaultPic = 0,
    FromVideo,
    FromCreateGroup,
    FromGroupAddMember
} FromType;

@protocol SendSomeViewControllerDelegate <NSObject>

@optional
- (void)sendEndImage:(UIImage *)image destoryTime:(int)destoryTime sendList:(NSArray *)userList sendNickname:(NSString *)nicknames;

@end

@interface SendSomeViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UISearchBarDelegate, UIAlertViewDelegate>

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
@property (assign, nonatomic) id<SendSomeViewControllerDelegate>delegate;
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

#pragma mark - 新加的群发的图片
@property (strong, nonatomic) UIImage *sendImage;
@property (strong, nonatomic) NSMutableArray *sendList;
@property (strong, nonatomic)NSMutableArray *sendSearchList;
@property (assign, nonatomic) int destoryTime;

@property (nonatomic, strong)UILabel *namesLabel;
@property (nonatomic, copy)NSString *names;

@property (nonatomic, assign)FromType fromType;  // 来源界面

@property (nonatomic, copy)NSString *videoName;///视频名字

@property (nonatomic, copy)NSString *path;   ///视频路径（压缩后的视频路径）

/// 创建群选择的人
@property (nonatomic, strong) NSMutableDictionary *userListDict; // 建群所选的人（WJID）

/// 邀请人进群，群的id
@property (nonatomic, copy)NSString *groupId;
/// 已经加入群的人的列表
@property (nonatomic, strong)NSArray *memberList;
@end
