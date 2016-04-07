//
//  ChatListTableViewCell.h
//  BigPinwheel
//
//  Created by 徐伟 on 16/1/19.
//  Copyright © 2016年 leita. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CLPlaceBtn.h"

@interface ChatListCell : UITableViewCell                  //聊天列表cell

@property(strong,nonatomic)UIImageView *avatarView;

@property(strong,nonatomic)UILabel *nameLabel;             //名称label
@property(strong,nonatomic)UILabel *timeLabel;             //消息事件label
@property(strong,nonatomic)UILabel *lastMSGLabel;          //最近一条消息label

@property(strong,nonatomic)UIView *sepline;                //底部分割线

@property(strong,nonatomic)UILabel *tipLabel;              //小圆圈提示
@property(strong,nonatomic)UIImageView *failedImageView;   //失败的标志
@property(assign,nonatomic)CGRect defaultRect;             //最后一条的默认尺寸

@property(strong,nonatomic)CLPlaceBtn *placeBtn;           //地址Btn

-(void)setSeplineX:(BOOL)isEtch;

@end

