//
//  AddressBookTableViewCell.h
//  BDMapDemo
//
//  Created by tw001 on 14-10-8.
//  Copyright (c) 2014年 ESX. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddressBookTableViewCell : UITableViewCell

@property (nonatomic, strong) UIButton *avatarButton;
@property (nonatomic, strong) UILabel *contentLabel;

@property (nonatomic, strong) UIButton *deleteButton;
@property (nonatomic, strong) UIButton *chatButton;
@property (nonatomic, strong) UIButton *snacksButton;
@property (nonatomic, strong) UILabel *locationLabel;

@end
