//
//  BIZContactableViewCell.h
//  BigPinwheel
//
//  Created by 徐伟 on 16/2/14.
//  Copyright © 2016年 leita. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SubNoticeCell : UITableViewCell              //此cell用作通讯录界面头部通知cell与商业合作界面cell

@property(strong,nonatomic)UIImageView *avatarView;     //头像View
@property(strong,nonatomic)UILabel *tipLabel;           //头像上面的小圆点

@property(strong,nonatomic)UILabel *nameLabel;          //姓名label
@property(strong,nonatomic)UILabel *lastMSGLabel;       //最后一条消息
@property(strong,nonatomic)UILabel *timeLabel;          //timeLabel

@property(strong,nonatomic)UIView *sepline;             //分割线

//Task==YES时,商业合作界面最后一个cell
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier isTaskCenter:(BOOL)isTaskCenter;

//设置自定义sepline宽度延伸到屏幕两边
-(void)setSeplineX:(BOOL)isEtch;

@end
