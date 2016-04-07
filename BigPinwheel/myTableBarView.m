//
//  myTableBarView.m
//  BigPinwheel
//
//  Created by 徐伟 on 16/2/19.
//  Copyright © 2016年 leita. All rights reserved.
//

#import "myTableBarView.h"
#import "InscriptionManager.h"

@interface myTableBarView ()

@property(strong,nonatomic)InscriptionManager *inspManager;

@end


@implementation myTableBarView


-(void)dealloc
{
    NSLog(@"自定义TableBar界面释放");
    self.delegate = nil;
    _clickCount = 0;
}


-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.frame = frame;
        _inspManager = [InscriptionManager sharedManager];
        _clickCount = 0;
        
        //findFarmerBtn findDriverBtn emblemBtn
        _findFarmerBtn = [self creatBtnWithFrame:CGRectMake(frame.size.width-49 -18, 0, 49, 131/2) Image:[UIImage imageNamed:@"0219_findFarmer"] imageSize:CGSizeMake(49, 49) Title:@"找同乡" Index:3];
        _findFarmerBtn.imageSize = CGSizeMake(49, 49);
        [self addSubview:_findFarmerBtn];
        
        _findDriverBtn = [self creatBtnWithFrame:CGRectMake(_findFarmerBtn.frame.origin.x -20.5-49, 55, 49, 131/2) Image:[UIImage imageNamed:@"0219_findDriver"] imageSize:CGSizeMake(49, 49) Title:@"找收割机" Index:4];
        _findFarmerBtn.imageSize = CGSizeMake(49, 49);
        [self addSubview:_findDriverBtn];
        
        _emblemBtn = [self creatBtnWithFrame:CGRectMake(frame.size.width-74, self.frame.size.height -123/2 -10.5, 123/2, 123/2) Image:[UIImage imageNamed:@"0219_emblem"] imageSize:CGSizeMake(123/2, 123/2) Title:nil Index:5];
        [self addSubview:_emblemBtn];
        
        _tableBtns = [NSMutableArray arrayWithObjects:_findFarmerBtn,_findDriverBtn,_emblemBtn, nil];
        
//        CGPoint vertiPoint = _findFarmerBtn.center;
//        CGPoint horiPoint = _findDriverBtn.center;
        _vertiPoint = _findFarmerBtn.center;
        _horiPoint = _findDriverBtn.center;
        
        _findDriverBtn.center = _findFarmerBtn.center = _emblemBtn.center;
        _unifyPoint = CGPointMake(_emblemBtn.center.x+10, _emblemBtn.center.y+10);
        _findDriverBtn.alpha  = _findFarmerBtn.alpha = 0;
        
        
        _shrinkAnimation = [_inspManager creatAnimationWithPropName:kPOPViewCenter FunctionName:kCAMediaTimingFunctionEaseIn FromValue:nil ToValue:[NSValue valueWithCGPoint:_unifyPoint] Duration:0.25];
        _springBackHoriAnimation = [_inspManager creatSpringAnimationWithPropName:kPOPViewCenter ToValue:[NSValue valueWithCGPoint:_horiPoint] SpringBounciness:1  SpringSpeed:61.8];
        _springBackVertiAnimation = [_inspManager creatSpringAnimationWithPropName:kPOPViewCenter ToValue:[NSValue valueWithCGPoint:_vertiPoint] SpringBounciness:1 SpringSpeed:61.8];
        
        _fadeOutAnim = [_inspManager creatAnimationWithPropName:kPOPViewAlpha FunctionName:kCAMediaTimingFunctionEaseIn FromValue:nil ToValue:@(0) Duration:0.25];
        _fadeInAnim = [_inspManager creatSpringAnimationWithPropName:kPOPViewAlpha ToValue:@(1) SpringBounciness:1 SpringSpeed:61.8];
        
    }
    return self;
}

-(TableBarBtn *)creatBtnWithFrame:(CGRect)frame Image:(UIImage *)image imageSize:(CGSize)imgesize Title:(NSString *)title Index:(NSInteger)index
{
    TableBarBtn *button = [TableBarBtn buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor clearColor];
    button.frame =frame;
    button.tag = index;
    button.imageSize = imgesize;
    button.titleSize = CGSizeMake(1, 1);
    [button.titleLabel setTextAlignment:NSTextAlignmentCenter];
    if (title ==nil) {
        button.titleSize = CGSizeZero;
    }
    [button setImage:image forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:COLOR(110, 110, 110, 1) forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont systemFontOfSize:11]];
    [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

-(void)buttonClick:(UIButton *)sender
{
    if (sender.tag ==5)
    {
        if (_clickCount %2 ==1)
        {
            [self shrinkInAnim];
            
        }else
        {
            [self springBackAnim];
        }
        
        _clickCount = _clickCount +1;
    }
    [_delegate barBtnClick:sender];
}

-(void)shrinkInAnim
{
    [_findDriverBtn pop_addAnimation:_shrinkAnimation forKey:@"driverShrink"];
    [_findFarmerBtn pop_addAnimation:_shrinkAnimation forKey:@"farmerShrink"];
    
    
    [_findDriverBtn pop_addAnimation:_fadeOutAnim forKey:@"_fadeOut"];
    [_findFarmerBtn pop_addAnimation:_fadeOutAnim forKey:@"_fadeOut"];
    
    NSLog(@"driverBtn.center = %@,farmerBtn.center = %@,embtn.center = %@,horiPoint = %@",NSStringFromCGPoint(_findDriverBtn.center),NSStringFromCGPoint(_findFarmerBtn.center),NSStringFromCGPoint(_emblemBtn.center),NSStringFromCGPoint(_horiPoint));
    
}

-(void)springBackAnim
{
    [_findFarmerBtn pop_addAnimation:_springBackVertiAnimation forKey:@"farmerBack"];
    [_findDriverBtn pop_addAnimation:_springBackHoriAnimation forKey:@"driverBack"];
    
    [_findDriverBtn pop_addAnimation:_fadeInAnim forKey:@"_fadeIn"];
    [_findFarmerBtn pop_addAnimation:_fadeInAnim forKey:@"_fadeIn"];
    
    NSLog(@"backAnim drivebtn.center = %@,faremerBtn.center = %@,embtn.center = %@",NSStringFromCGPoint(_findDriverBtn.center),NSStringFromCGPoint(_findFarmerBtn.center),NSStringFromCGPoint(_emblemBtn.center));

    
    
    
}



@end
