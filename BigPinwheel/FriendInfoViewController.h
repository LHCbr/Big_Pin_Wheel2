//
//  FriendInfoViewController.h
//  LuLu
//
//  Created by a on 1/15/16.
//  Copyright © 2016 lbx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSocket.h"

@interface FriendInfoViewController : UIViewController

@property (strong, nonatomic) WJID *uJid;

@property (copy, nonatomic) NSString *showTitle;
@end
