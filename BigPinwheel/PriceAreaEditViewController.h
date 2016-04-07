//
//  PriceAreaEditViewController.h
//  BigPinwheel
//
//  Created by xuwei on 16/3/1.
//  Copyright © 2016年 leita. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PriceAreaBtn.h"

@interface PriceAreaEditViewController : UIViewController<UITextFieldDelegate,UIScrollViewDelegate>
@property(strong,nonatomic)UIScrollView *rootScollView;          //rootScollView
//@property(strong,nonatomic)UISearchBar *searchBar;               //搜索
@property(strong,nonatomic)UILabel *locationLabel;               //定位label
@property(strong,nonatomic)UITextField *havestTF;                //收割价格textfield
//@property(strong,nonatomic)UIView *searchBGView;                 //搜索背景View
@property(strong,nonatomic)UIButton *saveBtn;                    //保存按钮

@property(strong,nonatomic)NSMutableArray *tempQuotedList;       //对请求下来的quoted_price_list Array只保留最后5个元素


@end
