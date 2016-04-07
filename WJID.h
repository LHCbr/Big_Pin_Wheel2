//
//  WJID.h
//  BigPinwheel
//
//  Created by 徐伟 on 16/1/15.
//  Copyright © 2016年 leita. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum: NSUInteger{
    mFriend = 1,
    mFans,
    mIdol,
    mOther
}Friend_type;

@interface WJID : NSObject

@property(copy,nonatomic)NSString *phone;            //登录名
@property(copy,nonatomic)NSString *password;         //密码
@property(copy,nonatomic)NSString *nickname;         //昵称
@property(copy,nonatomic)NSString *sex;              //性别 1男2女
@property(copy,nonatomic)NSString *identity;         //身份 1农民2司机
@property(copy,nonatomic)NSString *birthday;         //生日
@property(copy,nonatomic)NSString *notename;         //备注
@property(copy,nonatomic)NSString *signature;        //签名
@property(copy,nonatomic)NSString *personalityBg;    //个性背景图
@property(copy,nonatomic)NSString *avatarUrl;        //头像
@property(copy,nonatomic)NSString *area;             //区号
@property(copy,nonatomic)NSString *idolCount;        //关注个数
@property(copy,nonatomic)NSString *fansCount;        //粉丝个数
@property(copy,nonatomic)NSString *videoCount;       //视频个数
@property (assign, nonatomic)int waiteGiraffeCount;            // 千里眼未处理的个数

@property(copy,nonatomic)NSString *address;          //城市地址
@property(copy,nonatomic)NSString *contactNum;       //联系方式

@property(copy,nonatomic)NSString *otherOne;         //备用
@property(copy,nonatomic)NSString *otherTwo;         //备用
@property(copy,nonatomic)NSString *otherThree;       //备用

@property(assign,nonatomic)Friend_type friendType;   //1是我的好友 2为我的粉丝 3为我的关注


@property(copy,nonatomic)NSString *talkingUser;      //存储用户信息的目录
@property (assign, nonatomic)int waitAcceptCount;    // 等待接受好友申请的个数

@end
