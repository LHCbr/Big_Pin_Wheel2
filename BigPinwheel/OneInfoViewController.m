//
//  OneInfoViewController.m
//  LuLu
//
//  Created by lbx on 16/1/10.
//  Copyright © 2016年 lbx. All rights reserved.
//

#import "OneInfoViewController.h"

@interface OneInfoViewController ()

@end

@implementation OneInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NAVBAR(@"info");
    self.view.backgroundColor = [UIColor whiteColor];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
