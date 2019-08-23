//
//  AutoTrackSecViewController.m
//  ThinkingSDKDEMO
//
//  Created by syj on 2019/8/21.
//  Copyright © 2019 thinking. All rights reserved.
//

#import "AutoTrackSecViewController.h"
#import <ThinkingSDK/ThinkingAnalyticsSDK.h>

@interface AutoTrackSecViewController () <TDScreenAutoTracker>

@end

@implementation AutoTrackSecViewController

- (NSString *)getScreenUrl {
    return @"APP://testSecond";
}

- (void)viewDidLoad {
    [super viewDidLoad];
     self.view.backgroundColor = [UIColor whiteColor];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(50, 100, 300, 30)];
    label.text = @"UIViewController 自动埋点 二级页面";
    [self.view addSubview:label];
}

@end
