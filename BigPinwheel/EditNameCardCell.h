//
//  EditNameCardCell.h
//  BigPinwheel
//
//  Created by xuwei on 16/3/3.
//  Copyright © 2016年 leita. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditNameCardCell : UITableViewCell

@property(strong,nonatomic)UITextField *textField;
@property(strong,nonatomic)UILabel *label;
@property(strong,nonatomic)UILabel *descrilabel;
@property(strong,nonatomic)UIView *sepline;

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;


@end
