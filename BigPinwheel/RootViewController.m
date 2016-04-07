//
//  RootViewController.m
//  BigPinwheel
//
//  Created by 徐伟 on 16/1/19.
//  Copyright © 2016年 leita. All rights reserved.
//

#import "RootViewController.h"
#import <pop/POP.h>
#import "InscriptionManager.h"
#import "ContactViewController.h"
#import "FindFrinedsViewController.h"
#import "EditNameCardViewController.h"
#import "WSocket.h"
#import "UserInfoViewController.h"
#import "SettingsViewController.h"
#import "NormalContactViewController.h"
#import "NameCardViewController.h"

#define kBaseEastIn       @"basePopEastIn"
#define kBaseEastOut      @"basePopEastOut"
#define kbaseNavEaseOut   @"baseNavEaseOut"
#define kBackEastIn       @"kBackEastIn"
#define kBackNavEaseIn    @"kBackNavEaseIn"
#define kBackAdditionEO   @"kbackadditionEastOut"
#define kBtnFadeIn        @"kBtnFadeIn"
#define kBtnFadeOut       @"kBtnFadeOut"
#define kFirstPoint       CGPointMake(kDeviceWidth/2+kPopOffSetX, kDeviceHeight/2)

@interface RootViewController ()

@property(strong,nonatomic)POPBasicAnimation *baseAnimation;
@property(strong,nonatomic)POPBasicAnimation *baseNavAnimation;
@property(strong,nonatomic)POPBasicAnimation *baseAdditionAnimation;
@property(strong,nonatomic)POPBasicAnimation *btnFadeOutAnimation;

@property(strong,nonatomic)POPSpringAnimation *backAnimation;
@property(strong,nonatomic)POPSpringAnimation *backNavAnimation;
@property(strong,nonatomic)POPSpringAnimation *backAdditionAnimation;
@property(strong,nonatomic)POPBasicAnimation *btnFadeInAnimation;

@property(strong,nonatomic)UITapGestureRecognizer *ScrollViewTap;
@property(strong,nonatomic)UITapGestureRecognizer *navBarTap;
@property(strong,nonatomic)UIPanGestureRecognizer *panGesture;
@property(strong,nonatomic)UIScreenEdgePanGestureRecognizer *edgePanGesture;

@property(strong,nonatomic)InscriptionManager *inspManager;
@property(strong,nonatomic)WSocket *wSocket;

@end

@implementation RootViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self checkIsfirstLogin];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}


-(instancetype)init
{
    self = [super init];
    if (self)
    {
        _inspManager = [InscriptionManager sharedManager];
        _wSocket = [WSocket sharedWSocket];
        [self initializePopEastOutAnimation];
        [self initializePopEastInAnimation];
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handelUIApplicationWillChangeStatusBarFrameNoti:) name:UIApplicationStatusBarFrameUserInfoKey object:nil];
        
    }
    return self;
}

#pragma mark -本类接受的通知
///状态栏变化通知
-(void)handelUIApplicationWillChangeStatusBarFrameNoti:(NSNotification *)noti
{
    CGRect newStatusFrame = [(NSValue*)[noti.userInfo objectForKey:UIApplicationStatusBarFrameUserInfoKey]CGRectValue];
    NSLog(@"新的状态栏frame = %@",NSStringFromCGRect(newStatusFrame));
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //初始化NavBar相关
    [self customNavBar];
     //初始化myProfliesVC
    [self customMyProfilesVC];
    

    _rootScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, kDeviceWidth, kDeviceHeight)];
    _rootScrollView.backgroundColor = kBGColor;
    _rootScrollView.showsHorizontalScrollIndicator = NO;
    _rootScrollView.showsVerticalScrollIndicator = NO;
    _rootScrollView.contentSize = CGSizeMake(kDeviceWidth, kDeviceHeight);
    _rootScrollView.exclusiveTouch = YES;
    _rootScrollView.multipleTouchEnabled = YES;
    _rootScrollView.canCancelContentTouches = NO;
    _rootScrollView.alwaysBounceVertical = YES;
    _rootScrollView.alwaysBounceHorizontal = NO;
    _rootScrollView.decelerationRate = UIScrollViewDecelerationRateFast;
    _rootScrollView.delegate = self;
    [self.view addSubview:_rootScrollView];
    
    _ScrollViewTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleScrollViewTap:)];
    _ScrollViewTap.delegate = self;
    
    _navBarTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleScrollViewTap:)];
    _navBarTap.delegate = self;
    
    _panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handelScrollViewPanGesture:)];
    _panGesture.maximumNumberOfTouches = 1;
    _panGesture.delegate = self;
    [_rootScrollView addGestureRecognizer:_panGesture];
    
    _edgePanGesture = [[UIScreenEdgePanGestureRecognizer alloc]initWithTarget:self action:@selector(handelScrollViewPanGesture:)];
    _edgePanGesture.edges = UIRectEdgeLeft;
    _edgePanGesture.delegate = self;
    [_rootScrollView addGestureRecognizer:_edgePanGesture];
    
    //初始化HomeVC
    [self customHomeViewController];
    
    //初始化自定义MyTableBarView
    [self customMyTableBarView];
    

}

#pragma mark -View创建工具
//初始化NavBar相关
-(void)customNavBar
{
    self.navigationItem.title = @"大丰车";
    
    //初始化UIBarButtonItem
    _leftBarBtn = [self creatBtnWithFrame:CGRectMake(0, 0, 30, 30) Image:[UIImage imageNamed:@"0219_leftBtn"] Index:0];
    UIBarButtonItem *leftBarBtnItem = [[UIBarButtonItem alloc]initWithCustomView:_leftBarBtn];
    self.navigationItem.leftBarButtonItem = leftBarBtnItem;
    
    _rightBarBtnOne = [self creatBtnWithFrame:CGRectMake(0, 0, 30, 30) Image:[UIImage imageNamed:@"0219_rightMSG"] Index:1];
    UIBarButtonItem *rightBarBtnItemOne = [[UIBarButtonItem alloc]initWithCustomView:_rightBarBtnOne];
    _rightBarBtnTwo = [self creatBtnWithFrame:CGRectMake(0, 0, 30, 30) Image:[UIImage imageNamed:@"0219_QCRCode1"] Index:2];
    UIBarButtonItem *rightBarBtnItemTwo = [[UIBarButtonItem alloc]initWithCustomView:_rightBarBtnTwo];
    [rightBarBtnItemTwo setEnabled:NO];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:rightBarBtnItemOne,rightBarBtnItemTwo,nil];
}

//初始化主界面
-(void)customHomeViewController
{
    _homeVC = [[HomeViewController alloc]init];
    _homeVC.view.frame = CGRectMake(0, 0, _rootScrollView.frame.size.width, _rootScrollView.frame.size.height);
    [self addChildViewController:_homeVC];
    [_rootScrollView addSubview:_homeVC.view];
}

//初始化profilesVC  View在ViewInherits.index==0
-(void)customMyProfilesVC
{
    _profileVC = [[MyProfilesViewController alloc]init];
    _profileVC.view.frame = CGRectMake(-kPopOffSetX*0.618, 0, kPopOffSetX, kDeviceHeight);
    _profileVC.delegate = self;
    [self addChildViewController:_profileVC];
    [self.view insertSubview:_profileVC.view atIndex:0];
    
}

//初始化自定义TableBarView
-(void)customMyTableBarView
{
    _myTableBarView = [[myTableBarView alloc]initWithFrame:CGRectMake(kDeviceWidth/2,self.view.frame.size.height-150 , kDeviceWidth/2, 150)];
    _myTableBarView.backgroundColor = [UIColor clearColor];
    _myTableBarView.delegate = self;
    [self.view addSubview:_myTableBarView];
    
}

//button创建工具
-(UIButton *)creatBtnWithFrame:(CGRect)frame Image:(UIImage *)image Index:(NSInteger)index
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor clearColor];
    button.frame =frame;
    button.tag = index;
    [button setImage:image forState:UIControlStateNormal];
    [button addTarget:self action:@selector(barBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

#pragma mark -pop动画效果
-(void)initializePopEastOutAnimation
{
    __weak RootViewController *weakSelf = self;
    _baseAnimation = [_inspManager creatAnimationWithPropName:kPOPViewCenter FunctionName:kCAMediaTimingFunctionEaseInEaseOut FromValue:nil ToValue:[NSValue valueWithCGPoint:CGPointMake(kDeviceWidth/2+kPopOffSetX, kDeviceHeight/2)] Duration:0.3];
    [_baseAnimation setCompletionBlock:^(POPAnimation *anim, BOOL finished) {
        if (finished) {
            [weakSelf.rootScrollView addGestureRecognizer:weakSelf.ScrollViewTap];
        }
    }];

    _baseNavAnimation = [_inspManager creatAnimationWithPropName:kPOPViewCenter FunctionName:kCAMediaTimingFunctionEaseInEaseOut FromValue:nil ToValue:[NSValue valueWithCGPoint:CGPointMake(kDeviceWidth/2+kPopOffSetX, 22+20)] Duration:0.3];
    [_baseNavAnimation setCompletionBlock:^(POPAnimation *anim, BOOL finished) {
        if (finished) {
            [weakSelf.navigationController.navigationBar addGestureRecognizer:weakSelf.navBarTap];
        }
    }];
    
    _baseAdditionAnimation = [_inspManager creatAnimationWithPropName:kPOPViewCenter FunctionName:kCAMediaTimingFunctionEaseIn FromValue:[NSValue valueWithCGPoint:CGPointMake(kPopOffSetX/2-0.618*kPopOffSetX, kDeviceHeight/2)] ToValue:[NSValue valueWithCGPoint:CGPointMake(kPopOffSetX/2, kDeviceHeight/2)]Duration:0.2];

     _btnFadeOutAnimation = [_inspManager creatAnimationWithPropName:kPOPViewAlpha FunctionName:kCAMediaTimingFunctionEaseOut FromValue:nil ToValue:@(0.0) Duration:0.2];
    [_btnFadeOutAnimation setCompletionBlock:^(POPAnimation *anim, BOOL finished) {
        if (finished) {
            weakSelf.leftBarBtn.enabled = NO;
        }
    }];
    
    _btnFadeInAnimation = [_inspManager creatAnimationWithPropName:kPOPViewAlpha FunctionName:kCAMediaTimingFunctionEaseIn FromValue:nil ToValue:@(1.0) Duration:0.2];
    [_btnFadeInAnimation setCompletionBlock:^(POPAnimation *anim, BOOL finished) {
        if (finished) {
            weakSelf.leftBarBtn.enabled = YES;
        }
    }];
    
}

-(void)initializePopEastInAnimation
{
    __weak RootViewController *weakSelf = self;
    
    _backAnimation = [_inspManager creatSpringAnimationWithPropName:kPOPViewCenter ToValue:[NSValue valueWithCGPoint:CGPointMake(kDeviceWidth/2, kDeviceHeight/2)] SpringBounciness:1 SpringSpeed:14];
    [_backAnimation setCompletionBlock:^(POPAnimation *anim, BOOL finished) {
        
        if (finished) {
            [weakSelf.rootScrollView removeGestureRecognizer:weakSelf.ScrollViewTap];
        }
    }];
    
    _backNavAnimation = [_inspManager creatSpringAnimationWithPropName:kPOPViewCenter ToValue:[NSValue valueWithCGPoint:CGPointMake(kDeviceWidth/2, 22+20)] SpringBounciness:1 SpringSpeed:14];
    [_backNavAnimation setCompletionBlock:^(POPAnimation *anim, BOOL finished) {
       
        if (finished) {
            [weakSelf.navigationController.navigationBar removeGestureRecognizer:weakSelf.navBarTap];
        }
    }];
    
    _backAdditionAnimation = [_inspManager creatSpringAnimationWithPropName:kPOPViewCenter ToValue:[NSValue valueWithCGPoint:CGPointMake(kPopOffSetX/2 -kPopOffSetX*0.618, kDeviceHeight/2)] SpringBounciness:1 SpringSpeed:12];
}

#pragma mark -点击事件
//NavBarBtnItems点击事件 只负责右划EastOut
-(void)barBtnClick:(UIButton *)sender
{
    NSLog(@"你点击了第%ld个按钮",(long)sender.tag);
    
    
    if (sender.tag==0){
        
        if (_myTableBarView.findDriverBtn.center.x== _myTableBarView.horiPoint.x) {
            [_myTableBarView shrinkInAnim];
            _myTableBarView.clickCount = _myTableBarView.clickCount +1;
        }
         for (TableBarBtn *button in _myTableBarView.tableBtns)
         {
                [button setEnabled:NO];
                [button setAdjustsImageWhenDisabled:NO];
         }

        [_rootScrollView pop_addAnimation:_baseAnimation forKey:kBaseEastOut];
        [self.navigationController.navigationBar pop_addAnimation:_baseNavAnimation forKey:kbaseNavEaseOut];
        [_profileVC.view pop_addAnimation:_baseAdditionAnimation forKey:kBaseEastIn];
        [_leftBarBtn pop_addAnimation:_btnFadeOutAnimation forKey:kBtnFadeOut];
        
        [self.navigationController.navigationBar addGestureRecognizer:_navBarTap];
        
        //NSLog(@"scrollView.frame = %@,bar.frame = %@ , scrollview.center = %@",NSStringFromCGRect(_rootScrollView.frame),NSStringFromCGRect(self.navigationController.navigationBar.frame),NSStringFromCGPoint(_rootScrollView.center));
        
    }else if (sender.tag ==1)
    {
        ContactViewController *contactVC = [[ContactViewController alloc]init];
        [self.navigationController pushViewController:contactVC animated:YES];
        
    }else if (sender.tag ==2)
    {
        UserInfoViewController *userinfovc = [[UserInfoViewController alloc]init];
        [self.navigationController pushViewController:userinfovc animated:YES];
    }else if (sender.tag ==3)
    {
        FindFrinedsViewController *friendsVC = [[FindFrinedsViewController alloc]init];
        [self.navigationController pushViewController:friendsVC animated:YES];
        
    }else if (sender.tag ==4)
    {
        FindDriversVC *findDriverVC = [[FindDriversVC alloc]init];
        [self.navigationController pushViewController:findDriverVC animated:YES];
    }
}

//scrollViewTap事件 右划以后由附加到scrollView上的Tap动画负责往左划回去
-(void)handleScrollViewTap:(UITapGestureRecognizer *)tap
{
    if (tap.view.center.x<kDeviceWidth/2+kPopOffSetX) {
        return;
    }
    [_rootScrollView pop_addAnimation:_backAnimation forKey:kBackEastIn];
    [self.navigationController.navigationBar pop_addAnimation:_backNavAnimation forKey:kBackNavEaseIn];
    [_profileVC.view pop_addAnimation:_backAdditionAnimation forKey:kBackAdditionEO];
    [_leftBarBtn pop_addAnimation:_btnFadeInAnimation forKey:kBtnFadeIn];
    
    ///只要scrollview返回就删除scrollviewTap navBarTap
    [_rootScrollView removeGestureRecognizer:_ScrollViewTap];
    [self.navigationController.navigationBar removeGestureRecognizer:_navBarTap];
    
    
    for (TableBarBtn *button in _myTableBarView.tableBtns ) {
        [button setEnabled:YES];
    }
    
    NSLog(@"scrollView.backframe = %@,bar.backframe = %@,scrollview.center = %@",NSStringFromCGRect(_rootScrollView.frame),NSStringFromCGRect(self.navigationController.navigationBar.frame),NSStringFromCGPoint(_rootScrollView.center));

}

///priceAreaVCDidSelected事件
-(void)priceAreaCellDidSelectedWithIndex:(NSInteger)index
{
    if (index ==1)
    {
        [UIView animateWithDuration:0.3 animations:^{
            
//            EditNameCardViewController *editVC = [[EditNameCardViewController alloc]init];
//            [self.navigationController pushViewController:editVC animated:YES];
            NameCardViewController *nameCardVC = [[NameCardViewController alloc]init];
            nameCardVC.userinfo = _wSocket.lbxManager.dfcInfo;
            [self.navigationController pushViewController:nameCardVC animated:YES];
            _rootScrollView.center = CGPointMake(kDeviceWidth/2, kDeviceHeight/2);
            self.navigationController.navigationBar.center = CGPointMake(kDeviceWidth/2, 22+20);
            [_profileVC.view pop_addAnimation:_backAdditionAnimation forKey:kBackAdditionEO];
        }completion:^(BOOL finished) {
            if (finished)
            {
                [_leftBarBtn setEnabled:YES];
                [_rootScrollView removeGestureRecognizer:_ScrollViewTap];
                [self.navigationController.navigationBar removeGestureRecognizer:_navBarTap];
                
                for (TableBarBtn *button in _myTableBarView.tableBtns){
                    [button setEnabled:YES];
                }
            }
        }];
    }else if (index ==0)
    {
        [UIView animateWithDuration:0.3 animations:^{
            PriceAreaEditViewController *pAEidtVC = [[PriceAreaEditViewController alloc]init];
            [self.navigationController pushViewController:pAEidtVC animated:YES];
            _rootScrollView.center = CGPointMake(kDeviceWidth/2, kDeviceHeight/2);
            self.navigationController.navigationBar.center = CGPointMake(kDeviceWidth/2, 22+20);
            [_profileVC.view pop_addAnimation:_backAdditionAnimation forKey:kBackAdditionEO];
        }completion:^(BOOL finished) {
            if (finished)
            {
                [_leftBarBtn setEnabled:YES];
                [_rootScrollView removeGestureRecognizer:_ScrollViewTap];
                [self.navigationController.navigationBar removeGestureRecognizer:_navBarTap];
                
                for (TableBarBtn *button in _myTableBarView.tableBtns){
                    [button setEnabled:YES];
                }
            }
        }];
    }else if (index ==2)
    {
        [UIView animateWithDuration:0.3 animations:^{
            
            SettingsViewController *settingVC = [[SettingsViewController alloc]init];
            [self.navigationController pushViewController:settingVC animated:YES];
            _rootScrollView.center = CGPointMake(kDeviceWidth/2, kDeviceHeight/2);
            self.navigationController.navigationBar.center = CGPointMake(kDeviceWidth/2, 22+20);
            [_profileVC.view pop_addAnimation:_backAdditionAnimation forKey:kBackAdditionEO];
        }completion:^(BOOL finished) {
            if (finished)
            {
                [_leftBarBtn setEnabled:YES];
                [_rootScrollView removeGestureRecognizer:_ScrollViewTap];
                [self.navigationController.navigationBar removeGestureRecognizer:_navBarTap];
                for (TableBarBtn *button in _myTableBarView.tableBtns){
                    [button setEnabled:YES];
                }
            }
        }];
    }
 }

//scrollViewPan事件
-(void)handelScrollViewPanGesture:(UIPanGestureRecognizer *)panGesture
{
    CGPoint firstPoint = CGPointMake(kDeviceWidth/2+kPopOffSetX, kDeviceHeight/2);
    CGPoint translationPoint = [panGesture translationInView:self.view];
    
    panGesture.view.center = CGPointMake(panGesture.view.center.x+translationPoint.x, panGesture.view.center.y);
    
    if (panGesture.state ==UIGestureRecognizerStateBegan) {
        
    }else if (panGesture.state ==UIGestureRecognizerStateChanged)
    {
        CGFloat midX = panGesture.view.center.x;
        midX = MIN(midX, firstPoint.x);
        midX = MAX(midX, kDeviceWidth/2);
        
        CGFloat addiX = _profileVC.view.center.x+translationPoint.x*0.618;
        addiX = MIN(addiX, kPopOffSetX/2);
        addiX = MAX(addiX, kPopOffSetX/2-kPopOffSetX*0.618);
        CGFloat duration = fabs(translationPoint.x)/30;
        
        panGesture.view.center = CGPointMake(midX, panGesture.view.center.y);
        self.navigationController.navigationBar.center = CGPointMake(midX, 22+20);
        _profileVC.view.center = CGPointMake(addiX, _profileVC.view.center.y);
        
        POPBasicAnimation *btnAnimation = [_inspManager creatAnimationWithPropName:kPOPViewAlpha FunctionName:kCAMediaTimingFunctionDefault FromValue:nil ToValue:@(1-(midX-kDeviceWidth/2)/kPopOffSetX) Duration:duration];
        [_leftBarBtn pop_addAnimation:btnAnimation forKey:@"panBtnEastIn"];
        
        
    }else if (panGesture.state==UIGestureRecognizerStateEnded)
    {
        __weak RootViewController *weakSelf = self;
        
        if (panGesture.view.center.x>kDeviceWidth/2+kPopOffSetX/2)
        {
            [UIView animateWithDuration:0.2 animations:^{
                panGesture.view.center = firstPoint;
                self.navigationController.navigationBar.center = CGPointMake(firstPoint.x, 22+20);
                _profileVC.view.center = CGPointMake(kPopOffSetX/2, kDeviceHeight/2);
                [_rootScrollView addGestureRecognizer:_ScrollViewTap];
            }];
            
            if (_myTableBarView.findDriverBtn.center.x== _myTableBarView.horiPoint.x) {
                [_myTableBarView shrinkInAnim];
                _myTableBarView.clickCount = _myTableBarView.clickCount +1;
            }
            for (TableBarBtn *button in _myTableBarView.tableBtns)
            {
                [button setEnabled:NO];
                [button setAdjustsImageWhenDisabled:NO];
            }
            
            POPBasicAnimation *btnAnimation = [_inspManager creatAnimationWithPropName:kPOPViewAlpha FunctionName:kCAMediaTimingFunctionEaseOut FromValue:nil ToValue:@(0.0) Duration:0.2];
            [btnAnimation setCompletionBlock:^(POPAnimation *anim, BOOL finished) {
                if (finished) {
                    [weakSelf.leftBarBtn setEnabled:NO];
                }
            }];
            
            [_leftBarBtn pop_addAnimation:btnAnimation forKey:@"panBtnEastOutHalf"];
            
        }else
        {
            [UIView animateWithDuration:0.2 animations:^{
                panGesture.view.center = CGPointMake(kDeviceWidth/2, kDeviceHeight/2);
                self.navigationController.navigationBar.center = CGPointMake(kDeviceWidth/2, 22+20);
                _profileVC.view.center = CGPointMake(kPopOffSetX/2-kPopOffSetX*0.618, kDeviceHeight/2);
                [_rootScrollView removeGestureRecognizer:_ScrollViewTap];
            }];
            
            POPBasicAnimation *btnAnimation = [_inspManager creatAnimationWithPropName:kPOPViewAlpha FunctionName:kCAMediaTimingFunctionEaseOut FromValue:nil ToValue:@(1.0) Duration:0.2];
    
            [btnAnimation setCompletionBlock:^(POPAnimation *anim, BOOL finished)
            {
                if (finished)
                {
                    weakSelf.leftBarBtn.enabled = YES;
                }
            }];
            [_leftBarBtn pop_addAnimation:btnAnimation forKey:@"panBtnEastOutComp"];
            
            for (TableBarBtn *button in _myTableBarView.tableBtns) {
                [button setEnabled:YES];
            }

        }
    }
    [panGesture setTranslation:CGPointZero inView:self.view];
}

#pragma mark UIViewControllerTranslation



#pragma mark -UIGestureRecognizerDelegate
///当rootScrollview.center.x在kDeviceWidth/2时，只保留edagePan
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ((_rootScrollView.center.x ==kDeviceWidth/2)&&(gestureRecognizer ==_navBarTap|| gestureRecognizer ==_panGesture||gestureRecognizer ==_ScrollViewTap))
    {
        //NSLog(@"失效的手势 --- %@停止接受touch事件",gestureRecognizer);
        return NO;
    }
    else
    {
        //NSLog(@"手势作用的center坐标 == %@,有效的Gesture为%@",NSStringFromCGPoint(touch.view.center),gestureRecognizer);
        return YES;
    }
}

///检查是否是第一次登录
-(void)checkIsfirstLogin
{
    if (_wSocket.lbxManager.wJid.phone.length<=0||_wSocket.lbxManager.wJid.password.length<=0)
    {
        LoginHomeViewController *loginHomeVC = [[LoginHomeViewController alloc]init];
        [self.navigationController pushViewController:loginHomeVC animated:NO];
    }else
    {
        WSocket *wSocket =[WSocket sharedWSocket];
        if (![wSocket isLoginOK]) {
            [wSocket logining:_wSocket.lbxManager.wJid.phone password:_wSocket.lbxManager.wJid.password isAuto:YES loginBlock:^(int success) {
            }];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
