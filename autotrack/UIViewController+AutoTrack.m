//
//  UIViewController+AutoTrack.m
//  TDAnalyticsSDK
//
//  Created by THINKINGDATA on 2018/5/3.
//  Copyright © 2018年 thinkingdata. All rights reserved.
//

#import "UIViewController+AutoTrack.h"
#import "ThinkingAnalyticsSDK.h"
#import "TDLogger.h"

@implementation UIViewController (AutoTrack)
- (void)td_autotrack_viewWillAppear:(BOOL)animated {
    @try {
        UIViewController *viewController = (UIViewController *)self;
        [[ThinkingAnalyticsSDK sharedInstance] trackViewScreen: viewController];
    } @catch (NSException *exception) {
        TDSDKError(@"%@ error: %@", self, exception);
    }
    [self td_autotrack_viewWillAppear:animated];
}
@end
