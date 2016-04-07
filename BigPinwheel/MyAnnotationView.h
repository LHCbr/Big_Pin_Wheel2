//
//  MyAnnotationView.h
//  BigPinwheel
//
//  Created by MZero on 16/3/1.
//  Copyright © 2016年 leita. All rights reserved.
//

#import <MAMapKit/MAMapKit.h>
#import "CalloutView.h"
#import "DFCUserInfo.h"

@interface MyAnnotationView : MAPinAnnotationView

@property (nonatomic, strong,readwrite) CalloutView *myCalloutView;
@property (nonatomic, strong)DFCUserInfo *info;

@end
