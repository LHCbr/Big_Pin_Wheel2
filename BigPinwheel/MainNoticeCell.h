//
//  MainNoticeTableViewCell.h
//  BigPinwheel
//
//  Created by 徐伟 on 16/1/25.
//  Copyright © 2016年 leita. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainNoticeCell : UITableViewCell

@property(strong,nonatomic)UIImageView *avatarView;      //头像avatarView

@property(strong,nonatomic)UILabel *nameLabel;           //姓名label
@property(strong,nonatomic)UILabel *lastMSGLabel;        //最后一条消息label
@property(strong,nonatomic)UILabel *timeLabel;           //timeLabel

@property(strong,nonatomic)UIView *sepline;              //分割线

//设置自定义sepline宽度延伸到屏幕两边
-(void)setSeplineX:(BOOL)isEtch;

@end
