//
//  PlaySystemSound.h
//  LuLu
//
//  Created by a on 11/26/15.
//  Copyright © 2015 lbx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface PlaySystemSound : NSObject<AVAudioPlayerDelegate>

@property (nonatomic, strong)AVAudioPlayer *avAudioPlayer;

/// 获取单例
+ (PlaySystemSound *)sharedManager;

/// 发送本地通知 即时发送
- (void)showNotificationWithContent:(NSString *)content soundName:(NSString *)soundName;



@end
