//
//  WJID.m
//  BigPinwheel
//
//  Created by 徐伟 on 16/1/15.
//  Copyright © 2016年 leita. All rights reserved.
//

#import "WJID.h"

@implementation WJID

-(instancetype)init
{
    self = [super init];
    if (self)
    {
        _phone = @"";
        _password =@"";
        _nickname = @"";
        _sex = @"男";
        _birthday = @"";
        _notename = @"";
        _signature = @"";
        _personalityBg = @"";
        _avatarUrl = @"";
        _area = kPhoneArea;
        _idolCount = 0;
        _fansCount = 0;
        _videoCount = 0;
        _identity = @"司机";
        _address = @"";
        _contactNum = @"";
        _otherOne = @"";
        _otherTwo = @"";
        _otherThree = @"";
        
    }
    return self;
}

-(void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    
}

-(NSString *)description
{
    NSString *str = [NSString stringWithFormat:@"area = %@,phone = %@,password =%@,sex =%@,identity =%@,nickname = %@,avatarUrl =%@,contactNum = %@,birthday = %@,address = %@,signature = %@,notename = %@", _area,_phone,_password,_sex,_identity,_nickname,_avatarUrl,_contactNum,_birthday,_address,_signature,_notename];
    return str;
}

@end
