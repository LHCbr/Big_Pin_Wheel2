//
//  LeftImageTableViewCell.m
//  BDMapDemo
//
//  Created by tw001 on 14-9-29.
//  Copyright (c) 2014年 ESX. All rights reserved.
//

#import "LeftImageTableViewCell.h"

@implementation LeftImageTableViewCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _bgImageView.frame = CGRectMake(5+kLeftAvatarWidthZero, 0, (kDeviceWidth * 0.66), (kDeviceWidth * 0.66));
        
        _picView = [[UIView alloc] initWithFrame:CGRectMake(kLeftAvatarWidthZero+8.0, 3.0, (kDeviceWidth * 0.66) - 6, (kDeviceWidth * 0.66) - 6)];
        [self.contentView addSubview:_picView];
        
        _picImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _picView.frame.size.width, _picView.frame.size.height - 5)];
        _picImageView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.7];
        [_picImageView.layer setCornerRadius:15];
        [_picImageView.layer setMasksToBounds:YES];
        [_picView addSubview:_picImageView];
        
        _picImageView.userInteractionEnabled = YES;

        UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickPic:)];
        [_picImageView addGestureRecognizer:tapGes];

        _progressLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _picView.frame.size.width, _picView.frame.size.height - 5)];
        _progressLabel.backgroundColor = [UIColor colorWithRed:233/255.0 green:233/255.0 blue:233/255.0 alpha:0.5];
        _progressLabel.text = @"0%";
        _progressLabel.textAlignment = NSTextAlignmentCenter;
        [_picView addSubview:_progressLabel];
        
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

/// 设置消息内容
- (void)setMsgContent:(ChatObject *)msgObj
{
    NSString *foreignDirectory = [NSString stringWithFormat:@"%@/%@",kPathChat,msgObj.phone];
    
    if (msgObj.downloadProgress < 100) {
        _bgImageView.frame = CGRectMake(5+kLeftAvatarWidthZero, 0, (kDeviceWidth * 0.66), (kDeviceWidth * 0.66));
        _picView.frame = CGRectMake(kLeftAvatarWidthZero+3, _bgImageView.frame.size.height+3, (kDeviceWidth * 0.66), (kDeviceWidth * 0.66) );
        _progressLabel.frame = CGRectMake(0, 0, _picView.frame.size.width, _picView.frame.size.height - 5);
        
        _progressLabel.hidden = NO;
        _picImageView.hidden = YES;
        _progressLabel.text = [NSString stringWithFormat:@"%d%%", msgObj.downloadProgress];
    }else{
        _picImageView.hidden = NO;
        _progressLabel.hidden = YES;
        
        WSocket *wSocket = [WSocket sharedWSocket];
        
        UIImage *image = nil;
        if (msgObj.filePath.length) {
            image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",foreignDirectory,[wSocket.lbxManager upper16_MD5:msgObj.filePath]]];
            _picImageView.image = image;
        }
        
        if (image == nil) {
            image = [UIImage imageNamed:@"0107_bg_2"];
            _picImageView.image = image;
        }
        
        float w = _picImageView.image.size.width;
        float h = _picImageView.image.size.height;
        float sw = _picImageView.image.size.width / (kDeviceWidth * 0.66);
        float sh = _picImageView.image.size.height / (kDeviceWidth * 0.66);
        float scaleSize = sw > sh ? sw : sh;
        if (scaleSize > 1) {
            w = _picImageView.image.size.width / scaleSize;
            h = _picImageView.image.size.height / scaleSize;
        }
        
        if (image == nil) {
            w = (kDeviceWidth * 0.66);
            h = (kDeviceWidth * 0.66);
        }
        
        _bgImageView.frame = CGRectMake(_bgImageView.frame.origin.x, _bgImageView.frame.origin.y, w+6, h+6);
        _picView.frame = CGRectMake(_picView.frame.origin.x, _bgImageView.frame.origin.y+8, w, h);
        _picImageView.frame = CGRectMake(0, 0, w, h);
        
        _msgTime.frame = CGRectMake(_bgImageView.frame.size.width+_bgImageView.frame.origin.x - 40, _bgImageView.frame.size.height + _bgImageView.frame.origin.y - 14, 50, 10);
        [_msgTime.titleLabel setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.5]];
        [_msgTime.titleLabel.layer setCornerRadius:5.0];
        [_msgTime.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [_msgTime.titleLabel.layer setMasksToBounds:YES];
        [self.contentView bringSubviewToFront:_msgTime];
        
        NSString *timeSt = [[[WSocket sharedWSocket] lbxManager] turnTime:msgObj.time formatType:1 isEnglish:NO];
        
        NSDictionary *attrDict3 = @{ NSObliquenessAttributeName: @(0.1),
                                     NSFontAttributeName: [UIFont systemFontOfSize:9],
                                     NSForegroundColorAttributeName: [UIColor whiteColor]};
        [_msgTime setAttributedTitle:[[NSAttributedString alloc] initWithString:timeSt attributes: attrDict3] forState:UIControlStateNormal];


    }

}

/// 获得高度
+ (float)getMsgHeight:(ChatObject *)msgObj
{
    NSString *foreignDirectory = [NSString stringWithFormat:@"%@/%@",kPathChat,msgObj.phone];
    
    WSocket *wSocket = [WSocket sharedWSocket];
    UIImage *picImage = nil;
    if (msgObj.filePath.length) {
        picImage = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",foreignDirectory,[wSocket.lbxManager upper16_MD5:msgObj.filePath]]];
    }
    
    if (picImage == nil) {
        picImage = [UIImage imageNamed:@"0107_bg_2"];
    }
    
    float w = picImage.size.width;
    float h = picImage.size.height;
    float sw = picImage.size.width / (kDeviceWidth * 0.66);
    float sh = picImage.size.height / (kDeviceWidth * 0.66);
    float scaleSize = sw > sh ? sw : sh;
    if (scaleSize > 1) {
        w = picImage.size.width / scaleSize;
        h = picImage.size.height / scaleSize;
    }
    
    return h + 17.0f;
}

/// 点击图片
- (void)clickPic:(id)ges
{
    [_delegate lookImage:_rowIndex];
}

@end
