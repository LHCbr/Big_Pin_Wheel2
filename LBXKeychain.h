//
//  CHKeychain.h
//  leita
//
//  Created by a on 4/13/15.
//
//

#import <Foundation/Foundation.h>

@interface LBXKeychain : NSObject

+ (void)save:(NSString *)service data:(id)data;
+ (id)load:(NSString *)service;
+ (void)delete_data:(NSString *)service;

@end
