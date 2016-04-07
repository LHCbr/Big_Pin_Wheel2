//
//  PriceAreaCell.h
//  BigPinwheel
//
//  Created by xuwei on 16/2/29.
//  Copyright © 2016年 leita. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "signBtn.h"

@interface PriceAreaCell : UITableViewCell<UIScrollViewDelegate>

@property(strong,nonatomic)signBtn *priceAreaBtn;
@property(strong,nonatomic)UIButton *editBtn;
@property(strong,nonatomic)UILabel *priceLabel;

@property(strong,nonatomic)UIView *bGView;

@property(strong,nonatomic)NSMutableArray *priceAreaArray;     //报价区域Array
@property(strong,nonatomic)NSMutableArray *buttons;            //buttons


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier priceAreaArray:(NSMutableArray *)array;

///获取数据后刷新下报价区域
-(void)refreshPriceAreaWithArray:(NSMutableArray *)array;



@end
