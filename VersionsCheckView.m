//
//  VersionsCheckView.m
//  XMPPEnd
//
//  Created by a on 8/29/14.
//  Copyright (c) 2014 WZY. All rights reserved.
//

#import "VersionsCheckView.h"

#define kCurrentVersion [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleVersionKey]

@implementation VersionsCheckView
{
    NSString *dict_key;
    
    NSMutableData *_mData;

}

+(id)sharedVersionCheck
{
    static VersionsCheckView *versionsCheck;
    if (versionsCheck == nil) {
        versionsCheck = [[VersionsCheckView alloc] init];
    }
    return versionsCheck;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _mData = [[NSMutableData alloc] init];
    }
    return self;
}


// 服务器检查版本更新
- (void)checkVersions
{
    _verision_dict = [NSMutableDictionary dictionary];
    dict_key = @"";

    NSURL *url = [NSURL URLWithString:@"http://115.28.49.135/yuhuan/freechat-ios.xml"];
//    NSString *str = [[NSBundle mainBundle] pathForResource:@"version-ios" ofType:@"xml"];
//    NSURL *url = [NSURL fileURLWithPath:str];
    
    NSURLRequest *req = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
    [NSURLConnection connectionWithRequest:req delegate:self];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:_mData]; //设置XML数据
    
    [parser setShouldProcessNamespaces:NO];
    
    [parser setShouldReportNamespacePrefixes:NO];
    
    [parser setShouldResolveExternalEntities:NO];
    
    [parser setDelegate:self];
    
    [parser parse];
    
    _mData = nil;
    _mData = [[NSMutableData alloc] init];

}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_mData appendData:data];
}

// 开始解析
- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    NSLog(@"开始解析");
}

// 进行XML解析的代理
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    dict_key = elementName;
}

//当xml节点有值时，则进入此句
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if (string.length && [string isEqualToString:@"\n "] == NO && [string isEqualToString:@"\n"] == NO) {
        [_verision_dict setObject:string forKey:dict_key];
    }
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    NSLog(@"error = %@",parseError.description);
}

// 结束解析
- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    NSLog(@"结束解析");
    NSLog(@"更新介绍 = %@",[_verision_dict objectForKey:@"description"]);
    NSLog(@"最后一个强制更新的版本号是 = %@",[_verision_dict objectForKey:@"importanttip"]);
    NSLog(@"最新的版本是 ＝ %@",[_verision_dict objectForKey:@"version"]);
    NSLog(@"下载的地址是 = %@",[_verision_dict objectForKey:@"url"]);
    NSLog(@"下载的应用的名字是 = %@",[_verision_dict objectForKey:@"name"]);
    NSLog(@"手机上当前的版本是 %@",[NSString stringWithFormat:@"%@",kCurrentVersion]);
    
    NSString *current_version = kCurrentVersion;
    NSString *new_version = [_verision_dict objectForKey:@"version"];
    NSString *compulsory_version = [_verision_dict objectForKey:@"importanttip"];
    NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleNameKey];
    appName = @"大丰车";

    NSLog(@"current_version = %@",current_version);
    NSLog(@"new_version = %@",new_version);
    NSLog(@"最后一个强制更新的版本号是 = %@",compulsory_version);
    
    if ([kCurrentVersion compare:new_version] != NSOrderedAscending) {
        
    } else {
        if ([current_version compare:compulsory_version] == NSOrderedAscending) {
            NSLog(@"当前需要强制更新");
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"发现新版本 %@",new_version]
                                                                message:[NSString stringWithFormat:@"A new version of %@ is available. Please update to version %@ now.", appName, new_version]
                                                               delegate:self
                                                      cancelButtonTitle:@"更新"
                                                      otherButtonTitles:nil, nil];
            alertView.tag = 127;
            [alertView show];
        } else {
            NSLog(@"不需要强制更新");
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"发现新版本 %@",new_version]
                                                                message:[NSString stringWithFormat:@"A new version of %@ is available. Please update to version %@ now.", appName, new_version]
                                                               delegate:self
                                                      cancelButtonTitle:@"一会更新"
                                                      otherButtonTitles:@"马上更新", nil];
            alertView.tag = 128;
            
            [alertView show];

        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 127) {
        NSString *iTunesString = [_verision_dict objectForKey:@"url"];
        NSString *updateUrl = [NSString stringWithFormat:@"itms-services://?action=download-manifest&url=%@",iTunesString];
        NSURL *iTunesURL = [NSURL URLWithString:updateUrl];
        [[UIApplication sharedApplication] openURL:iTunesURL];
        exit(0);
    } else if (alertView.tag == 128) {
        if (buttonIndex == alertView.cancelButtonIndex) {
            return;
        } else {
            NSString *iTunesString = [_verision_dict objectForKey:@"url"];
            NSString *updateUrl = [NSString stringWithFormat:@"itms-services://?action=download-manifest&url=%@",iTunesString];
            NSURL *iTunesURL = [NSURL URLWithString:updateUrl];
            [[UIApplication sharedApplication] openURL:iTunesURL];
            exit(0);
        }
    }
}

@end
