//
//  AppDelegate+TDUI.m
//  ThinkingSDKDEMO
//
//  Created by syj on 2019/6/24.
//  Copyright © 2019年 thinking. All rights reserved.
//

#import "AppDelegate+TDUI.h"
#import "TDHomeVC.h"
#import "APIEntry.h"
#import "ThinkingSDKAPI.h"
#import "WEBViewController.h"
#import "WKWebViewController.h"
#import "AutoTrackViewController.h"
#import "AutoTableViewController.h"
#import "AutoCollectionViewController.h"
#import <ThinkingSDK/ThinkingAnalyticsSDK.h>
#import "TDUtil.h"

@interface AppDelegate () <UIGestureRecognizerDelegate>

@end

@implementation AppDelegate (TDUI)

-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    return YES;
}

- (UIViewController *)createRootViewController {
    TDHomeVC *trackController = [TDHomeVC new];
    UINavigationController *navC = [[UINavigationController alloc] initWithRootViewController:trackController];
    navC.navigationBar.barTintColor = UIColor.mainColor;
    navC.navigationBar.tintColor = UIColor.whiteColor;
    return navC;
}

- (void)setBackButton:(UIViewController *)controller {
    controller.navigationItem.backBarButtonItem =
    [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                     style:UIBarButtonItemStyleDone
                                    target:nil
                                    action:nil];
}


@end
