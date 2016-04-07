//
//  CusFriendCell.h
//  LuLu
//
//  Created by a on 1/8/16.
//  Copyright © 2016 lbx. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CusFriendCell : UITableViewCell
@property (nonatomic, strong)UIButton *avatarButton;
@property (nonatomic, strong)UILabel *nameLabel;
@property (nonatomic, strong)UILabel *descLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier isMin:(BOOL)isMin;

@end

