//
//  LeftVoiceTableViewCell.m
//  BDMapDemo
//
//  Created by tw001 on 14-9-29.
//  Copyright (c) 2014年 ESX. All rights reserved.
//

#import "LeftVoiceTableViewCell.h"

@implementation LeftVoiceTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _voiceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_voiceBtn addTarget:self action:@selector(clickPlayVoice:) forControlEvents:UIControlEventTouchUpInside];
        [_msgView addSubview:_voiceBtn];
        
        _voiceImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ReceiverVoiceNodePlaying"]];
        [_voiceBtn addSubview:_voiceImage];
        _voiceBtn.layer.cornerRadius = 5.0f;
        
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _timeLabel.textColor = [UIColor darkGrayColor];
        _timeLabel.font = [UIFont systemFontOfSize:13.0f];
        _timeLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_timeLabel];
        
        _noReadImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _noReadImageView.image = [UIImage imageNamed:@"tip"];
        _noReadImageView.layer.masksToBounds = YES;
        _noReadImageView.layer.cornerRadius = 4.0f;
        [self.contentView addSubview:_noReadImageView];
        
        self.bgImageView.image = _roundWhiteImage;

        
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}


- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

/// 播放语音
- (void)clickPlayVoice:(UIButton *)btn
{
    [_delegate playVoice:_indexPath];
}

/// 设置消息内容
- (void)setMsgContent:(ChatObject *)msgObj
{
    NSLog(@"timeLabel = %d %d",msgObj.voice_time, msgObj.destoryTime);
    float timeWidth = 16.0f;
    if (msgObj.destoryTime >= 10) {
        timeWidth = 24.0f;
    }
    _timeLabel.text = [NSString stringWithFormat:@"%d\"", msgObj.destoryTime];
    
    float voiceWidth = 40.0f;
    if (msgObj.destoryTime > 1) {
        voiceWidth = voiceWidth + msgObj.destoryTime * 2.66f;
    }
    
    float orginX = kLeftAvatarWidthZero+5.0;
    _msgView.frame = CGRectMake(orginX, _msgView.frame.origin.y, voiceWidth + 15, 40);
    _timeLabel.frame = CGRectMake(orginX + _msgView.frame.size.width + 2, 20, timeWidth, 20);
    _bgImageView.frame = CGRectMake(0, 0, voiceWidth + 15, 40);
    _voiceBtn.frame = CGRectMake(11, 1.5, _msgView.frame.size.width - 18, _msgView.frame.size.height - 3);
    _voiceImage.frame = CGRectMake(0, 9, 20, 20);
    if (msgObj.isRead) {
        _noReadImageView.hidden = YES;
    }else{
        _noReadImageView.hidden = NO;
        _noReadImageView.frame = CGRectMake(orginX + _msgView.frame.size.width + 5, 8, 8, 8);
    }
}

/// 获得高度
+ (float)getMsgHeight:(ChatObject *)msgObj
{
    return 50.0f;
}

@end
