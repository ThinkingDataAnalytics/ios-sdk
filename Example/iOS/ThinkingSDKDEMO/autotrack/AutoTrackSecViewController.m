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
- (void)setView
{
    [super setView];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(50, 100, 300, 30)];
    label.text = @"UIViewController the second level page";
    label.textColor = kTDColor;
    [self.view addSubview:label];
}
- (NSString*)rightTitle
{
    return @"the second level page";
}
@end
