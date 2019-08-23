//
//  AutoTrackViewController.m
//  ThinkingSDKDEMO
//
//  Created by syj on 2019/6/25.
//  Copyright © 2019年 thinking. All rights reserved.
//

#import "AutoTrackViewController.h"
#import <ThinkingSDK/ThinkingAnalyticsSDK.h>
#import "AutoTrackSecViewController.h"

@interface AutoTrackViewController () <TDScreenAutoTracker>

@end

@implementation AutoTrackViewController

- (NSDictionary *)getTrackProperties {
    return @{@"PageName" : @"商品详情页", @"ProductId" : @12345};
}

- (NSString *)getScreenUrl {
    return @"APP://test";
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(50, 100, 300, 30)];
    label.text = @"UIViewController 自动埋点";
    [self.view addSubview:label];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(50, 200, 300, 30)];
    button.backgroundColor = [UIColor lightGrayColor];
    [button setTitle:@"进入二级页面" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(showView) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:button];
}

- (void)showView {
    AutoTrackSecViewController *vc = [[AutoTrackSecViewController alloc] init];
    [self.navigationController pushViewController:vc animated:NO];
}

@end
