//
//  EditNameCardViewController.h
//  BigPinwheel
//
//  Created by xuwei on 16/3/3.
//  Copyright © 2016年 leita. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditNameCardViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UIImagePickerControllerDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,UIPickerViewDelegate,UIViewControllerTransitioningDelegate>

@property(strong,nonatomic)UITableView *tableView;
@property(strong,nonatomic)NSMutableArray *dataArray;
@property(strong,nonatomic)NSMutableArray *properArray;
@property(strong,nonatomic)NSMutableDictionary *info;
@property(strong,nonatomic)NSMutableDictionary *placeInfo;



@end
