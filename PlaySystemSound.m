//
//  PlaySystemSound.m
//  LuLu
//
//  Created by a on 11/26/15.
//  Copyright © 2015 lbx. All rights reserved.
//

#import "PlaySystemSound.h"
#import "InscriptionManager.h"

@interface PlaySystemSound()
@property (nonatomic, assign)BOOL isMute;                    // 系统是否设置静音
@property (nonatomic, strong)NSMutableArray *playArray;      // 需要播放的音频数组
@property (nonatomic, strong)NSTimer *playerTimer;

@end

@implementation PlaySystemSound

/// 获取单例
+ (PlaySystemSound *)sharedManager
{
    static PlaySystemSound *_playSystemSound = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        _playSystemSound = [[self alloc] init];
    });
    return _playSystemSound;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _isMute = NO;
        _playArray = [[NSMutableArray alloc] init];
    }
    return self;
}

/// 发送本地通知 即时发送
- (void)showNotificationWithContent:(NSString *)content soundName:(NSString *)soundName
{
    [self isMuted];
    
    NSDictionary *setting = [[InscriptionManager sharedManager] getSetting];
    int isMute = [[setting objectForKey:@"mute"] intValue];
    BOOL isSound = isMute ? NO : YES;
    
    if ([[InscriptionManager sharedManager]isBackGroundOperation ]) {
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.alertBody = content;
        NSLog(@"isMute = %d, isSound = %d, soundName = %@",isMute,isSound, soundName);
        if (soundName.length && isSound && isMute == NO) {
            notification.soundName = soundName;
        } else {
            if (isSound && isMute == NO) {
                notification.soundName = UILocalNotificationDefaultSoundName;
            } else {
                notification.soundName = soundName;
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);//震动
            }
        }
        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
        [UIApplication sharedApplication].applicationIconBadgeNumber += 1;
    } else {
        NSLog(@"在线,播放音乐soundName = %@  isSound = %d",soundName,isSound);
        
        if (isSound && isMute == NO) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self playAudioWithSoundName:soundName];
            });
        } else {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);//震动
        }
    }
}

static long long soundDuration = 0;
- (void)isMuted
{
    CFURLRef		soundFileURLRef;
    SystemSoundID	soundFileObject;
    
    // Get the main bundle for the app
    CFBundleRef mainBundle;
    mainBundle = CFBundleGetMainBundle();
    
    // Get the URL to the sound file to play
    soundFileURLRef  =	CFBundleCopyResourceURL(
                                                mainBundle,
                                                CFSTR ("detection"),
                                                CFSTR ("aiff"),
                                                NULL
                                                );
    
    // Create a system sound object representing the sound file
    AudioServicesCreateSystemSoundID (
                                      soundFileURLRef,
                                      &soundFileObject
                                      );
    
    AudioServicesAddSystemSoundCompletion (soundFileObject,NULL,NULL,
                                           soundCompletionCallback,
                                           (__bridge void*) self);
    

    soundDuration = [self getTimeNow];
    
    AudioServicesPlaySystemSound(soundFileObject);
}

static void soundCompletionCallback (SystemSoundID mySSID, void* myself) {
    AudioServicesRemoveSystemSoundCompletion (mySSID);
    [[PlaySystemSound sharedManager] playbackComplete];
}

- (void)playbackComplete {
    long long spaceTime = [self getTimeNow] - soundDuration;
    if (spaceTime > 0 && spaceTime < 100) {
        _isMute = YES;
        return;
    }
    _isMute = NO;
    return;
}

- (long long)getTimeNow
{
    NSString* date;
    
    NSDateFormatter * formatter = [[NSDateFormatter alloc ] init];
    [formatter setDateFormat:@"SSS"];
    date = [formatter stringFromDate:[NSDate date]];
    NSString *timeNow = [[NSString alloc] initWithFormat:@"%@", date];
    NSLog(@"%@", timeNow);
    return [timeNow longLongValue];
}

#pragma mark - 下面是播放音频的代码
- (void)playAudioWithSoundName:(NSString *)soundName
{
    if (_playArray.count < 3) {
        [_playArray addObject:soundName];
    }
    
    if (_playerTimer) {
        [_playerTimer setFireDate:[NSDate distantPast]];
    } else {
        _playerTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(checkPlayArray) userInfo:nil repeats:YES];
    }
}

- (void)checkPlayArray
{
    if (_playArray.count) {
        if (_avAudioPlayer == nil) {
            [self playMusic:[_playArray objectAtIndex:0]];
            [_playArray removeObjectAtIndex:0];
        }
    } else {
        [_playerTimer setFireDate:[NSDate distantFuture]];
    }
}

- (void)playMusic:(NSString *)name
{
    // 默认情况下扬声器播放
    [self handleNotification:YES];
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:name ofType:nil];
    _avAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:filePath] error:nil];
    _avAudioPlayer.delegate=self;
    [_avAudioPlayer play];
}

#pragma mark - AVAudioPlayerDelegate
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [_avAudioPlayer stop];
    _avAudioPlayer=nil;
    
    NSLog(@"播放结束");
    [self handleNotification:NO];
}

#pragma mark - 监听听筒or扬声器
- (void)handleNotification:(BOOL)state
{
    [[UIDevice currentDevice] setProximityMonitoringEnabled:state]; //建议在播放之前设置yes，播放结束设置NO，这个功能是开启红外感应
    
    if(state)//添加监听
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(sensorStateChange:) name:@"UIDeviceProximityStateDidChangeNotification"
                                                   object:nil];
    else//移除监听
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UIDeviceProximityStateDidChangeNotification" object:nil];
}

//处理监听触发事件
-(void)sensorStateChange:(NSNotificationCenter *)notification;
{
    //如果此时手机靠近面部放在耳朵旁，那么声音将通过听筒输出，并将屏幕变暗（省电啊）
    if ([[UIDevice currentDevice] proximityState] == YES)
    {
        NSLog(@"Device is close to user");
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    }
    else
    {
        NSLog(@"Device is not close to user");
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    }
}


@end
