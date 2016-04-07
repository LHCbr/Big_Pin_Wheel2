//
//  MyCustom.m
//  lbx_lib
//
//  Created by a on 5/13/15.
//  Copyright (c) 2015 js. All rights reserved.
//

#import "MyCustom.h"

@implementation MyCustom

- (instancetype)initWithTitle:(NSString *)aTitle descTitle:(NSString *)descTitle imageName:(NSString *)imageName aValue:(int)aValue
{
    self = [self init];
    if (self) {
        self.aTitle = aTitle;
        self.descTitle = descTitle;
        self.imageName = imageName;
        self.aValue = aValue;
    }
    return self;
}
@end
