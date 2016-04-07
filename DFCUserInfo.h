//
//  DFCUserInfo.h
//  BigPinwheel
//
//  Created by xuwei on 16/3/10.
//  Copyright © 2016年 leita. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DFCUserInfo : NSObject

@property(copy,nonatomic)NSString *area_code;
@property(copy,nonatomic)NSString *birthday;
@property(copy,nonatomic)NSString *country;
@property(copy,nonatomic)NSString *provice;
@property(copy,nonatomic)NSString *city;
@property(copy,nonatomic)NSString *region;
@property(copy,nonatomic)NSString *remaining_addr;
@property(copy,nonatomic)NSString *head_portrait;
@property(copy,nonatomic)NSString *identity;
@property(copy,nonatomic)NSString *sex;
@property(copy,nonatomic)NSString *latitude;
@property(copy,nonatomic)NSString *longitude;
@property(copy,nonatomic)NSString *nick_name;
@property(copy,nonatomic)NSString *phone_num;
@property(copy,nonatomic)NSString *postion_update_time;
@property(copy,nonatomic)NSString *signature;
@property(copy,nonatomic)NSString *phone;
@property(copy,nonatomic)NSString *phone_show_flag;
@property(copy,nonatomic)NSString *user_id;
@property(copy,nonatomic)NSString *address;

@property(strong,nonatomic)NSMutableArray *quoted_price_list;

@end
