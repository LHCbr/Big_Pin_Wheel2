//
//  addFriendsCell.h
//  BigPinwheel
//
//  Created by xuwei on 16/3/4.
//  Copyright © 2016年 leita. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol addFriendsCellDelegate <NSObject>

-(void)addFriendsBtnDidClick:(UIButton *)sender;

@end

@interface addFriendsCell : UITableViewCell

@property(strong,nonatomic)UIButton *avatarBtn;   //头像Btn
@property(strong,nonatomic)UILabel *namelabel;    //姓名label
@property(strong,nonatomic)UILabel *desplabel;    //描述性label

@property(strong,nonatomic)UIButton *addBtn;      //右侧添加好友btn

@property(strong,nonatomic)UIView *sepline;       //分隔线


@property(assign,nonatomic)id<addFriendsCellDelegate>delegate;

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

-(void)setSeplineX:(CGFloat)x isHidden:(BOOL)isHidden;    //设置分隔线的X坐标



@end
