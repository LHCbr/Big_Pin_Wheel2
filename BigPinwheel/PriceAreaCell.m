//
//  PriceAreaCell.m
//  BigPinwheel
//
//  Created by xuwei on 16/2/29.
//  Copyright © 2016年 leita. All rights reserved.
//

#import "PriceAreaCell.h"
#import "InscriptionManager.h"

@implementation PriceAreaCell

-(void)dealloc
{
    NSLog(@"左滑菜单报价区域cell释放");
}

-(UILabel *)priceLabel
{
    if (!_priceLabel) {
        _priceLabel = [[UILabel alloc]init];
        _priceLabel.backgroundColor = [UIColor clearColor];
        _priceLabel.textColor = [UIColor whiteColor];
        _priceLabel.font = [UIFont systemFontOfSize:12];
        _priceLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _priceLabel;
}


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier priceAreaArray:(NSMutableArray *)array
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.contentView.backgroundColor = [UIColor clearColor];
        self.contentView.frame = CGRectMake(0, 0, kPopOffSetX, 378/2);
        self.backgroundColor = [UIColor clearColor];
        
        _buttons = [[NSMutableArray alloc]init];
        
        _bGView = [self creatLineWithFrame:CGRectMake(0, 39/2, kDeviceWidth, self.contentView.frame.size.height -39) BGColor:COLOR(140, 127, 95, 1)];
        _bGView.userInteractionEnabled = NO;
        [self.contentView addSubview:_bGView];
        
        _priceAreaBtn = [signBtn buttonWithType:UIButtonTypeCustom];
        _priceAreaBtn.backgroundColor = [UIColor clearColor];
        _priceAreaBtn.imgeSize = CGSizeMake(15, 15);
        _priceAreaBtn.frame = CGRectMake(19/2, 11,kDeviceWidth/4 , 16);
        [_priceAreaBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_priceAreaBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [_priceAreaBtn setTitle:@"报价区域" forState:UIControlStateNormal];
        [_priceAreaBtn setImage:[UIImage imageNamed:@"0229_priceArea"] forState:UIControlStateNormal];
        [_bGView addSubview:_priceAreaBtn];
        
        _editBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _editBtn.backgroundColor = [UIColor clearColor];
        _editBtn.frame = CGRectMake(kPopOffSetX -14 -13, _priceAreaBtn.frame.origin.y, 14, 14);
        [_editBtn setImage:[UIImage imageNamed:@"0230_pencil"] forState:UIControlStateNormal];
        [_bGView addSubview:_editBtn];
        
        if (array.count>0)
        {
            _priceAreaArray = [[NSMutableArray alloc]initWithArray:array];
        }
        
        NSInteger btnCount = _priceAreaArray.count;
        if (_priceAreaArray.count>0)
        {
            CGFloat btnWidth = kDeviceWidth*140/750;
            for (NSInteger i=0; i<btnCount; i++)
            {
                NSString *phoneStr = [NSString stringWithFormat:@"%@%@",[[_priceAreaArray objectAtIndex:i]objectForKey:@"city"],[[_priceAreaArray objectAtIndex:i]objectForKey:@"region"]];
                
                UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                button.backgroundColor = [UIColor clearColor];
                button.frame = CGRectMake(65/2 +(btnWidth+10)*(i%3), CGRectGetMaxY(_priceAreaBtn.frame)+14+(25+14)*(i/3), btnWidth, 25);
                [button.layer setMasksToBounds:YES];
                [button.layer setCornerRadius:2.5];
                [button.layer setBorderWidth:0.5];
                [button.layer setBorderColor:[UIColor whiteColor].CGColor];
                [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [button.titleLabel setFont:[UIFont systemFontOfSize:11]];
                [button.titleLabel setTextAlignment:NSTextAlignmentCenter];
                [button setTitle:phoneStr forState:UIControlStateNormal];
                [_bGView addSubview:button];
                [_buttons addObject:button];
            }
        }

        self.priceLabel.frame=CGRectMake(65/2,CGRectGetMaxY(_priceAreaBtn.frame)+14+(25+14)*(1+btnCount/3) , kDeviceWidth -65/2, 12);
       
        if (_priceAreaArray.count <=0) {
            _priceLabel.text = @"收割价:0元/亩";
        }else
        {
            _priceLabel.text =[NSString stringWithFormat:@"收割价:%@元/亩",[[_priceAreaArray firstObject]objectForKey:@"quoted_price"]];
        }
        [_bGView addSubview:_priceLabel];
        
        UIView *sepline = [[UIView alloc]initWithFrame:CGRectMake(9.5,self.contentView.frame.size.height, kPopOffSetX -19, 0.5)];
        sepline.backgroundColor = COLOR(158, 147, 116, 1);
        [self.contentView addSubview:sepline];
        
    }
    return self;
}

//创建seplineView
-(UIView *)creatLineWithFrame:(CGRect)frame BGColor:(UIColor *)color
{
    UIView *line = [[UIView alloc]initWithFrame:frame];
    line.backgroundColor = color;
    return line;
}

///刷新报价区域
-(void)refreshPriceAreaWithArray:(NSMutableArray *)array
{
    for (UIButton *button in _buttons)
    {
        [button removeFromSuperview];
    }
    _buttons = nil;
    _buttons = [[NSMutableArray alloc]init];
    
    if (array)
    {
        _priceAreaArray = [[NSMutableArray alloc]initWithArray:array];
    }
    
    NSInteger btnCount = _priceAreaArray.count;
    if (_priceAreaArray)
    {
        CGFloat btnWidth = kDeviceWidth*140/750;
        for (NSInteger i=0; i<btnCount; i++)
        {
            NSString *phoneStr = [NSString stringWithFormat:@"%@%@",[[_priceAreaArray objectAtIndex:i]objectForKey:@"city"],[[_priceAreaArray objectAtIndex:i]objectForKey:@"region"]];
            
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.backgroundColor = [UIColor clearColor];
            button.frame = CGRectMake(65/2 +(btnWidth+10)*(i%3), CGRectGetMaxY(_priceAreaBtn.frame)+14+(25+14)*(i/3), btnWidth, 25);
            [button.layer setMasksToBounds:YES];
            [button.layer setCornerRadius:2.5];
            [button.layer setBorderWidth:0.5];
            [button.layer setBorderColor:[UIColor whiteColor].CGColor];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [button.titleLabel setFont:[UIFont systemFontOfSize:11]];
            [button.titleLabel setTextAlignment:NSTextAlignmentCenter];
            [button setTitle:phoneStr forState:UIControlStateNormal];
            [_bGView addSubview:button];
            [_buttons addObject:button];
        }
        
        [self.priceLabel removeFromSuperview];
        self.priceLabel.frame=CGRectMake(65/2,CGRectGetMaxY(_priceAreaBtn.frame)+14+(25+14)*(1+btnCount/3) , kDeviceWidth -65/2, 12);
        
        if (_priceAreaArray.count <=0) {
            _priceLabel.text = @"收割价:0元/亩";
        }else
        {
            _priceLabel.text =[NSString stringWithFormat:@"收割价:%@元/亩",[[_priceAreaArray firstObject]objectForKey:@"quoted_price"]];
        }
        [_bGView addSubview:_priceLabel];
        
        
    }
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
