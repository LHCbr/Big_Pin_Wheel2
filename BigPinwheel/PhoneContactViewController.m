//
//  PhoneContactViewController.m
//  BigPinwheel
//
//  Created by xuwei on 16/4/1.
//  Copyright © 2016年 leita. All rights reserved.
//

#import "PhoneContactViewController.h"
#import "WSocket.h"
#import <AddressBook/AddressBook.h>

@interface PhoneContactViewController ()
@property(strong,nonatomic)WSocket *wSocket;

@end

@implementation PhoneContactViewController

#pragma mark -本类接受的通知
///检查手机通讯录好友是否已经在服务器注册过
-(void)checkContcFriendIsRegister:(NSNotification *)noti
{
    _isUpdateContactList = YES;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sleep(2);
        [self getContactList];
        
        if ([[noti.object objectForKey:@"ret"]intValue] ==0)
        {
            [[NSUserDefaults standardUserDefaults]setObject:noti.object forKey:@"localFriends"];
            [[NSUserDefaults standardUserDefaults]synchronize];
            _backFriends = [NSMutableArray arrayWithArray:[noti.object objectForKey:@"list"]];
            NSLog(@"_backFriends = %@",_backFriends);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [_tableView reloadData];
            });
        }
    });
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self getContactList];
}

-(instancetype)init
{
    self = [super init];
    if (self)
    {
        _wSocket = [WSocket sharedWSocket];
        _isUpdateContactList = NO;
        [[NSNotificationCenter defaultCenter]addObserver: self selector:@selector(checkContcFriendIsRegister:) name:kPhoneContactsResponse object:nil];
        NSDictionary *dict = [[NSUserDefaults standardUserDefaults]objectForKey:@"localFriends"];
        _backFriends = [dict objectForKey:@"list"];
    }
    return self;
}

#pragma mark -本类执行的方法

/// 获取手机联系人的方法
- (void)getContactList
{
    NSMutableString *phoneList = [[NSMutableString alloc] init];
    
    NSMutableDictionary *allInfo = [[NSMutableDictionary alloc] init];
    
    ABAddressBookRef addressBook = nil;
    __block BOOL accessGranted = NO;
    if (ABAddressBookRequestAccessWithCompletion != NULL) {
        addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
        //等待同意后向下执行
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error)
                                                 {
                                                     accessGranted = granted;
                                                     dispatch_semaphore_signal(sema);
                                                 });
        
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    }else{
        accessGranted = YES;
    }
    
    if (accessGranted) {
        CFArrayRef results = ABAddressBookCopyArrayOfAllPeople(addressBook);
        NSArray *arrays = (__bridge NSArray *)results;
        
        NSString *regex = kPhoneRegex;
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
        
        unsigned long count = arrays.count;
        if (count > 0) {
            for (int i = 0; i < count; i++) {
                NSMutableDictionary *dicInfoLocal = [[NSMutableDictionary alloc] init];
                ABRecordRef person = CFArrayGetValueAtIndex(results, i);
                NSString *first = (__bridge NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty);
                if (first == nil) {
                    first = @" ";
                }
                NSString *last = (__bridge NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
                if (last == nil) {
                    last = @" ";
                }
                NSString *username = @" ";
                if ([first isEqualToString:@" "]) {
                    username = last;
                }else{
                    username = [NSString stringWithFormat:@"%@%@", last, first];
                }
                
                if (last.length <= 0 || last == nil) {
                    last = @"#";
                }
                
                if (last.length) {
                    last = [last substringToIndex:1];
                }
                
                [dicInfoLocal setObject:username forKey:@"name"];
                
                ABMultiValueRef tmlphone = ABRecordCopyValue(person, kABPersonPhoneProperty);
                NSString *telphone = (__bridge NSString*)ABMultiValueCopyValueAtIndex(tmlphone, 0);
                if (telphone != nil) {
                    NSMutableString *phone = [[NSMutableString alloc] initWithString:telphone];
                    NSMutableString *tephone = [[NSMutableString alloc] initWithString:[phone stringByReplacingOccurrencesOfString:@"-" withString:@""]];
                    int length = 11;
                    unsigned long location = tephone.length - length;
                    NSRange range = NSMakeRange(location, length);
                    NSString *phone2 = [tephone substringWithRange:range];
                    
                    BOOL isMatch = [pred evaluateWithObject:phone2];
                    if (isMatch == NO) {
                        continue;
                    }
                    
                    [dicInfoLocal setObject:phone2 forKey:@"phone"];
                    
                    if ([_wSocket.lbxManager isSelfFriend:phone2 area:@"+86"]) {
                        continue;
                    }
                    
                    [phoneList appendString:@"86"];
                    [phoneList appendString:phone2];
                    [phoneList appendString:@"*"];
                    
                    NSMutableDictionary *oneUser = [allInfo objectForKey:last];
                    if (!oneUser) {
                        oneUser = [[NSMutableDictionary alloc] init];
                    }
                    
                    NSMutableArray *users = [oneUser objectForKey:@"array"];
                    if (!users) {
                        users = [[NSMutableArray alloc] init];
                    }
                    
                    [users addObject:dicInfoLocal];
                    
                    
                    [oneUser setObject:users forKey:@"array"];
                    [allInfo setObject:oneUser forKey:last];
                    
                    CFRelease(tmlphone);
                }
                
            }
            
            NSMutableArray *aArray = [[NSMutableArray alloc] init];
            for (NSString *key in allInfo.allKeys) {
                NSDictionary *di = [allInfo objectForKey:key];
                NSMutableDictionary *newUser = [[NSMutableDictionary alloc] init];
                [newUser setObject:[di objectForKey:@"array"] forKey:key];
                [aArray addObject:newUser];
            }
            
            NSDictionary *contactPlist = [NSDictionary dictionaryWithObjectsAndKeys:aArray,@"contact", nil];
            [contactPlist writeToFile:[NSString stringWithFormat:@"%@/contact.plist",kRootFilePath] atomically:YES];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                
                
                
                
                
                if (phoneList.length > 0) {
                    _cacheList = [phoneList substringToIndex:phoneList.length - 1];
                    [self updateContact:nil];
                }
            });
            
            CFRelease(results);
            CFRelease(addressBook);
            
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [_wSocket.lbxManager isCanAddressBook];
            });
        }
    }
}

/// 上传通讯录
- (void)updateContact:(NSNotification *)noti
{
    if (_cacheList.length && _isUpdateContactList == NO) {
        int response = [[WSocket sharedWSocket] addContact:_cacheList];
        NSLog(@"上传通讯录的返回结果 %d", response);
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    NAVBAR(@"通讯录朋友");
    
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, kDeviceWidth, kDeviceHeight-64) style:UITableViewStylePlain];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.tableHeaderView = [[UIView alloc]init];
    _tableView.tableFooterView = [[UIView alloc]init];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 120/2;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - UITableViewDataSource

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"identifier0";
    
    addFriendsCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell ==nil) {
        cell = [[addFriendsCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSeparatorStyleNone;
        
    }
    cell.namelabel.text = [[_backFriends objectAtIndex:indexPath.row]objectForKey:@"user_id"];
    int style = [[[_backFriends objectAtIndex:indexPath.row]objectForKey:@"style"]intValue];
    if (style ==0)
    {
        cell.desplabel.text = @"邀请该用户";
    }
    else if (style ==1)
    {
        cell.desplabel.text = @"添加用户";
    }
    cell.delegate = self;
    
    return cell;
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _backFriends.count;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
