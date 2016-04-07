//
//  ContactCell.h
//  BigPinwheel
//
//  Created by xuwei on 16/3/4.
//  Copyright © 2016年 leita. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ContactCellDelegate <NSObject>

-(void)cellAvatarBtnClick:(UIButton *)sender;

@end

@interface ContactCell : UITableViewCell

@property(strong,nonatomic)UIButton *avatarBtn;    //头像
@property(strong,nonatomic)UILabel *namelabel;     //姓名
@property(strong,nonatomic)UIView *sepline;        //分割线

@property(assign,nonatomic)id<ContactCellDelegate>delegate;




-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;


@end
