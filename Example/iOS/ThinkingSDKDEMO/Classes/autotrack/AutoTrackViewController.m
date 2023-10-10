//
//  AutoTrackViewController.m
//  ThinkingSDKDEMO
//
//  Created by syj on 2019/6/25.
//  Copyright © 2019 thinking. All rights reserved.
//

#import "AutoTrackViewController.h"
#import <ThinkingSDK/ThinkingAnalyticsSDK.h>
#import "AutoTrackSecViewController.h"

@interface AutoTrackViewController () <TDScreenAutoTracker>

@end

@implementation AutoTrackViewController

- (NSDictionary *)getTrackProperties {
    return @{@"PageName" : @"detail page", @"ProductId" : @12345};
}

- (NSString *)getScreenUrl {
    return @"APP://test";
}
- (NSString*)rightTitle
{
    return @"UIViewController";
}
- (void)setView
{
    [super setView];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(50, 100, 300, 30)];
    label.text = @"UIViewController auto-tracking";
    [self.view addSubview:label];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(50, 200, 300, 30)];
    button.backgroundColor = [UIColor lightGrayColor];
    [button setTitle:@"inter the second level page" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(showView) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:button];
}

- (void)showView {
    AutoTrackSecViewController *vc = [[AutoTrackSecViewController alloc] init];
    [self.navigationController pushViewController:vc animated:NO];
}

@end
