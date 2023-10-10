//
//  TDAPMViewController.m
//  ThinkingSDKDEMO
//
//  Created by Charles on 6.2.23.
//  Copyright © 2023 thinking. All rights reserved.
//

#import "TDAPMViewController.h"

@interface TDAPMViewController (){
    dispatch_semaphore_t semaphore;
}

@end

@implementation TDAPMViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 100, 44)];
    [btn setTitle:@"卡顿主线程" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(testStuck) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}
- (void)testStuck {
    NSLog(@"卡住 ----- %@", [NSThread currentThread]);
    semaphore = dispatch_semaphore_create(0);
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, 7 * NSEC_PER_SEC));
    NSLog(@"结束卡 ----- %@", [NSThread currentThread]);
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
