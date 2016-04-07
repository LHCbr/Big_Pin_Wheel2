//
//  VersionsCheckView.h
//  XMPPEnd
//
//  Created by a on 8/29/14.
//  Copyright (c) 2014 WZY. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>


@interface VersionsCheckView : NSObject<NSXMLParserDelegate,UIAlertViewDelegate>
+(id)sharedVersionCheck;
- (void)checkVersions;
@property(nonatomic,strong)NSMutableDictionary *verision_dict;
@end
