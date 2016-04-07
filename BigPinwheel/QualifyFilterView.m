//
//  QualifyFilterView.m
//  BigPinwheel
//
//  Created by 徐伟 on 16/2/19.
//  Copyright © 2016年 leita. All rights reserved.
//

#import "QualifyFilterView.h"
#import "UIView+Extension.h"
@implementation QualifyFilterView

-(void)dealloc
{
    self.delegate =nil;
    NSLog(@"资格筛选选项界面释放");
}

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = COLOR(75, 75, 75, 0.7);
        _bGView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kDeviceWidth, 330)];
        _bGView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_bGView];
        NSMutableArray *sexArray = [NSMutableArray arrayWithObjects:@{kGender:@"全部"},@{kGender:@"男"},@{kGender:@"女"}, nil];
        NSMutableArray *placeArray = [NSMutableArray arrayWithObjects:@{kPlace:@"全部"},@{kPlace:@"同城"}, nil];
        NSMutableArray *idArray = [NSMutableArray arrayWithObjects:@{kIdenity:@"农民"},@{kIdenity:@"司机"}, nil];
        NSMutableArray *priceArray = [NSMutableArray arrayWithObjects:@{kOfferPrice:@"面议"},@{kOfferPrice:@"0-50"},@{kOfferPrice:@"50-100"},@{kOfferPrice:@"100-150"},@{kOfferPrice:@"150-200"},nil];
        _filterListArray = [NSMutableArray arrayWithObjects:sexArray,placeArray,idArray,priceArray, nil];
        _filterNameArray = [NSMutableArray arrayWithObjects:kGender,kPlace,kIdenity,kOfferPrice, nil];
        _propertyBtnArray = [[NSMutableArray alloc]init];
        _selectBtnPropArray = [[NSMutableArray alloc]init];
        [self makeView];
    }
    return self;
}

-(void)makeView
{
    CGFloat btnWidth = 95.0f;
    CGFloat btnHeight = 34.0f;
    CGFloat spaceY =25.0f;
    
    for (NSInteger i=0; i<_filterListArray.count; i++)
    {
        NSString *propNmae = [_filterNameArray objectAtIndex:i];
        NSMutableArray *propArray = [_filterListArray objectAtIndex:i];
        NSMutableArray *oneButtons = [[NSMutableArray alloc]init];
        
        if (i == 3) {
            _xbView = [[UIView alloc]initWithFrame:CGRectMake(0, 11+i*59, kDeviceWidth, 102)];
            //_xbView.backgroundColor = [UIColor blueColor];
            [_bGView addSubview:_xbView];
        }
        
        //创建filterBtn
        NSInteger btnRow = 0;
        for (NSInteger j=0; j<propArray.count; j++)
        {
            btnRow = j/3;
            NSString *btnStr = [NSString stringWithFormat:@"%@",[[propArray objectAtIndex:j]objectForKey:propNmae]];
            FilterBtn *filterBtn = [[FilterBtn alloc]initWithFrame:CGRectMake(8+(8.5+btnWidth)*(j%3),26+i*(btnHeight+spaceY)+btnRow*(btnHeight+5), btnWidth, btnHeight) BtnName:btnStr Property:propNmae];
            filterBtn.tag = i*100+j;
            filterBtn.customTag = i;
            [filterBtn addTarget:self action:@selector(filterBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            
            [oneButtons addObject:filterBtn];
            if (j==0) {
                [_selectBtnPropArray addObject:@"全部"];
            }
            if (i != 3) {
                [_bGView addSubview:filterBtn];
            }else{
                filterBtn.y -= (i*(btnHeight+spaceY));
                [_xbView addSubview:filterBtn];
            }
        }
        [_propertyBtnArray addObject:oneButtons];
        
        //创建属性描述propLabel
        //UILabel *propLabel = [self creatlabelWithY:11+i*59 title:propNmae];
        if (i != 3) {
            UILabel *propLabel = [self creatlabelWithY:11+i*59 title:propNmae];
            [_bGView addSubview:propLabel];
        }else{
            UILabel *propLabel = [self creatlabelWithY:0 title:propNmae];
            [_xbView addSubview:propLabel];
        }
        
        
    }
    
    
    //确认取消button sepline
    UIView *sepline =[[UIView alloc]initWithFrame:CGRectMake(0, 580/2, kDeviceWidth, 0.5)];
    sepline.backgroundColor = COLOR(197, 197, 197, 1);
    [_bGView addSubview:sepline];
    
    UIButton *confrimBtn = [self creatBtnWithFrame:CGRectMake(0, sepline.frame.origin.y+0.5,kDeviceWidth/2-0.25, 39.5) BGColor:COLOR(247, 247, 247, 1) Title:@"确认" TitleColor:COLOR(245, 195, 40, 1) Font:16 Tag:0];
    [confrimBtn addTarget:self action:@selector(confirmBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_bGView addSubview:confrimBtn];
    
    UIView *verticalLine = [[UIView alloc]initWithFrame:CGRectMake(kDeviceWidth/2-0.25, confrimBtn.frame.origin.y, 0.5, confrimBtn.frame.size.height-1)];
    verticalLine.backgroundColor = COLOR(197, 197, 197, 1);
    [_bGView addSubview:verticalLine];
    
    UIButton *cancelBtn = [self creatBtnWithFrame:CGRectMake(kDeviceWidth/2+0.5,confrimBtn.frame.origin.y , confrimBtn.frame.size.width, confrimBtn.frame.size.height) BGColor:COLOR(247, 247, 247, 1) Title:@"取消" TitleColor:COLOR(245, 195, 40, 1) Font:16 Tag:1];
    [cancelBtn addTarget:self action:@selector(confirmBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_bGView addSubview:cancelBtn];
    _confrimBtn = confrimBtn;
    _cancelBtn = cancelBtn;
    _verticalLine = verticalLine;
    _sepline = sepline;
    
    _bGView.height = 228;
    [_xbView removeFromSuperview];
    confrimBtn.y = _bGView.height-39.5;
    cancelBtn.y = _bGView.height-39.5;
    verticalLine.y = confrimBtn.y;
    sepline.y = confrimBtn.y + confrimBtn.height;

}

-(void)filterBtnClick:(FilterBtn *)sender
{
    if (_propertyBtnArray.count <=0)
    {
        return;
    }
    
    NSMutableArray *oneButtons = [[NSMutableArray alloc]initWithArray:[_propertyBtnArray objectAtIndex:sender.customTag]];
    
    if (sender.tag == 200) {
        _bGView.height = 228;
        [_xbView removeFromSuperview];
        _confrimBtn.y = _bGView.height-39.5;
        _cancelBtn.y = _bGView.height-39.5;
        _verticalLine.y = _confrimBtn.y;
        _sepline.y = _confrimBtn.y + _confrimBtn.height;
    }
    if (sender.tag == 201) {
        _bGView.height = 330;
        [_bGView addSubview:_xbView];
        _confrimBtn.y = _bGView.height-39.5;
        _cancelBtn.y = _bGView.height-39.5;
        _verticalLine.y = _confrimBtn.y;
        _sepline.y = _confrimBtn.y + _confrimBtn.height;
        
    }

    for (FilterBtn *button in oneButtons) {
        if (button.tag ==sender.tag) {
            [button setSelfisHidden:YES];
            NSLog(@"%ld",button.tag);
            if (_selectBtnPropArray.count>0)
            {
                [_selectBtnPropArray replaceObjectAtIndex:sender.customTag withObject:sender.value_name];
            }else
            {
                [_selectBtnPropArray addObject:sender.value_name];
            }
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:_selectBtnPropArray forKey:kFilterData];
            [defaults synchronize];
            [[NSNotificationCenter defaultCenter]postNotificationName:kFilterDataChange object:nil];
            [_delegate refreshHeaderLabel];
        }
        else
        {
            [button setSelfisHidden:NO];
        }
    }
}

-(void)confirmBtnClick:(UIButton *)sender
{
    [_delegate filterConfrimButtonClick:sender];
}

-(UILabel *)creatlabelWithY:(CGFloat)y title:(NSString *)title
{
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(12, y, kDeviceWidth/2, 10)];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:10];
    label.textColor = COLOR(97, 97, 97, 1);
    label.textAlignment = NSTextAlignmentLeft;
    label.text = title;
    return label;
}

-(UIButton *)creatBtnWithFrame:(CGRect)frame BGColor:(UIColor *)bGcolor Title:(NSString *)title TitleColor:(UIColor *)titleColor Font:(CGFloat)font Tag:(NSInteger )tag
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = bGcolor;
    button.frame = frame;
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:titleColor forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont systemFontOfSize:font]];
    [button.titleLabel setTextAlignment:NSTextAlignmentCenter];
    button.tag =tag;
    return button;
}


@end
