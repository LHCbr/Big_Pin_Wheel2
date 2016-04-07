//
//  CheckReportViewController.m
//  SimpleDemo
//
//  Created by tw001 on 15/8/10.
//  Copyright (c) 2015年 wave. All rights reserved.
//

#import "CheckReportViewController.h"
#import "InscriptionManager.h"
#import "WSocket.h"

@interface CheckReportViewController ()

@property (nonatomic, strong)UIScrollView *scrollView;
@property (nonatomic, strong)UIScrollView *lastScrollView;
@property (nonatomic, assign)BOOL isOpen;

@end

@implementation CheckReportViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    _isOpen = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [[InscriptionManager sharedManager] showHubAction:0 showView:self.view];

    _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height )];
    _scrollView.contentSize = CGSizeMake(self.view.frame.size.width*_imgArray.count, _scrollView.frame.size.height);
    _scrollView.alwaysBounceHorizontal = YES;
    _scrollView.delegate = self;
    _scrollView.pagingEnabled = YES;
    [self.view addSubview:_scrollView];
    for (int i = 0; i < _imgArray.count; i ++) {
        UIScrollView *scroll = [[UIScrollView alloc]initWithFrame:CGRectMake(self.view.frame.size.width*i, 0, self.view.frame.size.width, _scrollView.frame.size.height)];
        [_scrollView addSubview:scroll];
        scroll.delegate = self;
        scroll.maximumZoomScale = 4;
        scroll.minimumZoomScale = 1;
        UIImageView *imgView = [[UIImageView alloc]init];
        imgView.frame = CGRectMake(0, 20, self.view.frame.size.width, _scrollView.frame.size.height);
        imgView.contentMode = UIViewContentModeScaleAspectFit;
        imgView.tag = 10;
        
        [scroll addSubview:imgView];
        if (i == 0) {
            _lastScrollView = scroll;
        }
        scroll.tag = i+1;
        
        id data = [_imgArray objectAtIndex:i];
        if ([data isKindOfClass:[UIImage class]]) {
            UIImage *image = (UIImage *)data;
            imgView.image = image;
            [[InscriptionManager sharedManager] showHubAction:1 showView:self.view];
        } else {
            NSString *str = (NSString *)data;
            __weak UIImageView *iv = imgView;
            [[WSocket sharedWSocket] addDownFileOperationWithFileUrlString:str serialId:@"-1" modelType:ModelTypeNormal info:nil downBlock:^(int ret, int isSave, NSData *data, NSString *fileUrl) {
               dispatch_async(dispatch_get_main_queue(), ^{
                   [[InscriptionManager sharedManager] showHubAction:1 showView:self.view];
                   if (ret >= 0) {
                       iv.image = [UIImage imageWithData:data];
                   } else {
                       [[InscriptionManager sharedManager] showHudViewLabelText:@"图片加载失败" detailsLabelText:nil afterDelay:1];
                   }
               });
            }];
        }
        
        ///点击返回手势
        UITapGestureRecognizer *single_click = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backBtnClicked:)];
        single_click.numberOfTapsRequired = 1;
        [scroll addGestureRecognizer:single_click];
        
        UITapGestureRecognizer *double_click = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(double_tap:)];
        double_click.numberOfTapsRequired = 2;
        [scroll addGestureRecognizer:double_click];
        
        [single_click requireGestureRecognizerToFail:double_click];

        
    }
    ////返回按钮
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(5, 25, 50, 50);
    [backBtn setImage:[UIImage  imageNamed:@"0804_backbtn"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
    ///显示第几张检查报告
    self.navigationItem.title = [NSString stringWithFormat:@"1/%ld",(unsigned long)_imgArray.count];
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    if (scrollView != _scrollView) {
        for (UIView *v in scrollView.subviews){
            return v;
        }
    }
    return nil;
}

-(void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{

}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView != _scrollView) {
        
    }else{
       CGFloat y = scrollView.contentOffset.x;
        int a = y/self.view.frame.size.width;
        self.navigationItem.title = [NSString stringWithFormat:@"%d/%ld",a+1,(unsigned long)_imgArray.count];
        NSLog(@"%f",y);
        
        UIScrollView *curScrollView = (UIScrollView *)[_scrollView viewWithTag:a+1];
        if (curScrollView != _lastScrollView) {
            _lastScrollView.zoomScale = 1;
            _isOpen = NO;
            _lastScrollView = curScrollView;
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{

}

- (void)backBtnClicked:(UIButton *)sender
{
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:NO];
    } else {
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}

- (void)double_tap:(UITapGestureRecognizer *)doubleTap
{
    UIScrollView *sub_scrollView = (UIScrollView *)doubleTap.view;
    UIImageView *imageView = (UIImageView *)[sub_scrollView viewWithTag:10];
    if (_isOpen == NO)
    {
        CGSize maxSize = imageView.frame.size;
        CGFloat widthRatio = imageView.image.size.width/maxSize.width;
        CGFloat heightRatio = imageView.image.size.height/maxSize.height;
        CGFloat initialZoom = (widthRatio > heightRatio) ? heightRatio : widthRatio;
        sub_scrollView.zoomScale = initialZoom;
        _isOpen = YES;
    } else {
        sub_scrollView.zoomScale = 1;
        _isOpen = NO;
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
