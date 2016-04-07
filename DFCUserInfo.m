//
//  DFCUserInfo.m
//  BigPinwheel
//
//  Created by xuwei on 16/3/10.
//  Copyright © 2016年 leita. All rights reserved.
//

#import "DFCUserInfo.h"

@implementation DFCUserInfo

-(instancetype)init
{
    if (self) {
        _area_code = @"";
        _birthday = @"";
        _city = @"";
        _country = @"";
        _head_portrait = @"";
        _identity = @"";
        _latitude = @"";
        _longitude = @"";
        _nick_name = @"";
        _phone_num = @"";
        _postion_update_time = @"";
        _provice = @"";
        _region = @"";
        _remaining_addr = @"";
        _sex = @"";
        _signature = @"";
        _phone_show_flag = @"";
        _phone = @"";
        _user_id = @"";
        _address = @"";
        _quoted_price_list = [[NSMutableArray alloc]init];
        
    }
    return self;
}

-(NSString *)description
{
    NSString *str = [NSString stringWithFormat:@"area_code = %@, birthday = %@, city =%@ ,country = %@, head_portrait = %@,identity = %@, latitude = %@, longtitude = %@, nick_name = %@, phone_num = %@,postion_update_time = %@, provice = %@ region = %@, remaining_addr =%@ ,address = %@,sex = %@ ,signature =%@,phone_show_flag = %@,quoted_price_list = %@",_area_code,_birthday,_city,_country,_head_portrait,_identity,_latitude,_longitude,_nick_name,_phone_num,_postion_update_time,_provice,_region,_remaining_addr,_address,_sex,_signature,_phone_show_flag,_quoted_price_list];
    return str;
}

-(void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    
}

@end
