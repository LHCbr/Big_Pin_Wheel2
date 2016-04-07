//
//  SexIdentityPickerView.h
//  BigPinwheel
//
//  Created by xuwei on 16/3/17.
//  Copyright © 2016年 leita. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SexIdentityPickerView : UIView<UIPickerViewDataSource,UIPickerViewDelegate>

@property(strong,nonatomic)UIPickerView *pickerView;
@property(strong,nonatomic)UIButton *confirmBtn;
@property(strong,nonatomic)UIButton *cancelBtn;
@property(strong,nonatomic)NSMutableArray *dataArray;
@property(assign,nonatomic)BOOL isSex;

-(instancetype)initWithFrame:(CGRect)frame isSex:(BOOL)isSex;

@end
