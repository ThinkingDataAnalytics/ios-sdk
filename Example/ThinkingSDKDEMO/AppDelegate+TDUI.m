//
//  AppDelegate+TDUI.m
//  ThinkingSDKDEMO
//
//  Created by syj on 2019/6/24.
//  Copyright © 2019年 thinking. All rights reserved.
//

#import "AppDelegate+TDUI.h"
#import "TrackAPIViewController.h"
#import "APIEntry.h"
#import "ThinkingSDKAPI.h"
#import "WEBViewController.h"
#import "WKWebViewController.h"
#import "AutoTrackViewController.h"
#import "AutoTableViewController.h"
#import "AutoCollectionViewController.h"
#import "NTPViewController.h"
#import <ThinkingSDK/ThinkingAnalyticsSDK.h>

@interface AppDelegate () <UIGestureRecognizerDelegate>

@end

@implementation AppDelegate (TDUI)

-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    return YES;
}

- (UIViewController *)createRootViewController {
    TrackAPIViewController *trackController = [self trackAPIVCWithApis:[self manageAPIs]];
    trackController.getTitleBlock = ^NSString * (__unused UIViewController *controller)
    {
        return @"ThinkingSDK DEMO";
    };
    UINavigationController *navC = [[UINavigationController alloc] initWithRootViewController:trackController];
    navC.interactivePopGestureRecognizer.enabled = YES;
    navC.interactivePopGestureRecognizer.delegate = self;
    return navC;
}

- (TrackAPIViewController *)trackAPIVCWithApis:(NSArray *)commands {
    TrackAPIViewController *apiController = [[TrackAPIViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [apiController.apis addObjectsFromArray:commands];
    return apiController;
}

- (void)setBackButton:(UIViewController *)controller {
    controller.navigationItem.backBarButtonItem =
    [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                     style:UIBarButtonItemStyleDone
                                    target:nil
                                    action:nil];
}

- (NSArray *)manageAPIs {
    NSMutableArray *commands = [NSMutableArray array];
    
    // MARK: track
    NSMutableArray *trackArray = [NSMutableArray array];
    [trackArray addObject:
     [APIEntry commandWithName:@"Track"
                 accessoryType:UITableViewCellAccessoryNone
                         block:^(UIViewController *controller)
      {
        [ThinkingSDKAPI testTrack];
    }]];
    
    [trackArray addObject:
     [APIEntry commandWithName:@"Track_EventID"
                 accessoryType:UITableViewCellAccessoryNone
                         block:^(UIViewController *controller)
      {
        [ThinkingSDKAPI testTrackWithEventID];
    }]];
    
    [trackArray addObject:
     [APIEntry commandWithName:@"Track_FirstCheckID"
                 accessoryType:UITableViewCellAccessoryNone
                         block:^(UIViewController *controller)
      {
        [ThinkingSDKAPI testTrackWithFirstCheckID];
    }]];
    
    [trackArray addObject:
     [APIEntry commandWithName:@"Track_Update"
                 accessoryType:UITableViewCellAccessoryNone
                         block:^(UIViewController *controller)
      {
        [ThinkingSDKAPI testTrackUpdate];
    }]];
    
    [trackArray addObject:
     [APIEntry commandWithName:@"Track_Overwrite"
                 accessoryType:UITableViewCellAccessoryNone
                         block:^(UIViewController *controller)
      {
        [ThinkingSDKAPI testTrackOverwrite];
    }]];
    
    [trackArray addObject:
     [APIEntry commandWithName:@"Track with property"
                 accessoryType:UITableViewCellAccessoryNone
                         block:^(UIViewController *controller)
      {
        [ThinkingSDKAPI testTrackWithProperty];
    }]];
    
    [trackArray addObject:
     [APIEntry commandWithName:@"Track With Timezone"
                 accessoryType:UITableViewCellAccessoryNone
                         block:^(UIViewController *controller)
      {
        [ThinkingSDKAPI testTrackWithTimezone];
    }]];
    
    // MARK: user
    NSMutableArray *userArray = [NSMutableArray array];
    [userArray addObject:
     [APIEntry commandWithName:@"User Set"
                 accessoryType:UITableViewCellAccessoryNone
                         block:^(UIViewController *controller)
      {
        [ThinkingSDKAPI testUserSet];
    }]];
    
    [userArray addObject:
     [APIEntry commandWithName:@"User Unset"
                 accessoryType:UITableViewCellAccessoryNone
                         block:^(UIViewController *controller)
      {
        [ThinkingSDKAPI testUserUnset];
    }]];
    
    [userArray addObject:
     [APIEntry commandWithName:@"User Set Once"
                 accessoryType:UITableViewCellAccessoryNone
                         block:^(UIViewController *controller)
      {
        [ThinkingSDKAPI testUserSetonce];
    }]];
    
    [userArray addObject:
     [APIEntry commandWithName:@"User Del"
                 accessoryType:UITableViewCellAccessoryNone
                         block:^(UIViewController *controller)
      {
        [ThinkingSDKAPI testUserDel];
    }]];
    
    [userArray addObject:
     [APIEntry commandWithName:@"User ADD"
                 accessoryType:UITableViewCellAccessoryNone
                         block:^(UIViewController *controller)
      {
        [ThinkingSDKAPI testUserAdd];
    }]];
    
    [userArray addObject:
     [APIEntry commandWithName:@"User APPEND"
                 accessoryType:UITableViewCellAccessoryNone
                         block:^(UIViewController *controller)
      {
        [ThinkingSDKAPI testUserAppend];
    }]];
    
    [userArray addObject:
     [APIEntry commandWithName:@"Login"
                 accessoryType:UITableViewCellAccessoryNone
                         block:^(UIViewController *controller)
      {
        [ThinkingSDKAPI testLogin];
    }]];
    
    [userArray addObject:
     [APIEntry commandWithName:@"Logout"
                 accessoryType:UITableViewCellAccessoryNone
                         block:^(UIViewController *controller)
      {
        [ThinkingSDKAPI testLogout];
    }]];
    
    // MARK: options
    NSMutableArray *optionArray = [NSMutableArray array];
    [optionArray addObject:
     [APIEntry commandWithName:@"Set SuperProperty"
                 accessoryType:UITableViewCellAccessoryNone
                         block:^(UIViewController *controller)
      {
        [ThinkingSDKAPI testSetsuper];
    }]];
    
    [optionArray addObject:
     [APIEntry commandWithName:@"Unset SuperProperty"
                 accessoryType:UITableViewCellAccessoryNone
                         block:^(UIViewController *controller)
      {
        [ThinkingSDKAPI testUnsetsuper];
    }]];
    
    [optionArray addObject:
     [APIEntry commandWithName:@"Clear SuperProperty"
                 accessoryType:UITableViewCellAccessoryNone
                         block:^(UIViewController *controller)
      {
        [ThinkingSDKAPI testClearsuper];
    }]];
    
    [optionArray addObject:
     [APIEntry commandWithName:@"Time Event"
                 accessoryType:UITableViewCellAccessoryNone
                         block:^(UIViewController *controller)
      {
        [ThinkingSDKAPI testTimedEvent];
    }]];
    
    [optionArray addObject:
     [APIEntry commandWithName:@"Time Event End"
                 accessoryType:UITableViewCellAccessoryNone
                         block:^(UIViewController *controller)
      {
        [ThinkingSDKAPI testTrackEventEnd];
    }]];
    
    [optionArray addObject:
     [APIEntry commandWithName:@"Identify"
                 accessoryType:UITableViewCellAccessoryNone
                         block:^(UIViewController *controller)
      {
        [ThinkingSDKAPI testIdentify];
    }]];
    
    [optionArray addObject:
     [APIEntry commandWithName:@"Flush"
                 accessoryType:UITableViewCellAccessoryNone
                         block:^(UIViewController *controller)
      {
        [ThinkingSDKAPI testFlush];
    }]];
    
    [optionArray addObject:
     [APIEntry commandWithName:@"Enable"
                 accessoryType:UITableViewCellAccessoryNone
                         block:^(UIViewController *controller)
      {
        [ThinkingSDKAPI testEnable];
    }]];
    
    [optionArray addObject:
     [APIEntry commandWithName:@"DisEnable"
                 accessoryType:UITableViewCellAccessoryNone
                         block:^(UIViewController *controller)
      {
        [ThinkingSDKAPI testDisEnable];
    }]];
    
    [optionArray addObject:
     [APIEntry commandWithName:@"optOutTracking"
                 accessoryType:UITableViewCellAccessoryNone
                         block:^(UIViewController *controller)
      {
        [ThinkingSDKAPI optOutTracking];
    }]];
    
    [optionArray addObject:
     [APIEntry commandWithName:@"optOutTrackingAndDeleteUser"
                 accessoryType:UITableViewCellAccessoryNone
                         block:^(UIViewController *controller)
      {
        [ThinkingSDKAPI optOutTrackingAndDeleteUser];
    }]];
    
    [optionArray addObject:
     [APIEntry commandWithName:@"optInTracking"
                 accessoryType:UITableViewCellAccessoryNone
                         block:^(UIViewController *controller)
      {
        [ThinkingSDKAPI optInTracking];
    }]];
    
    [optionArray addObject:
     [APIEntry commandWithName:@"More (AutoTrack,h5,轻实例...)"
                 accessoryType:UITableViewCellAccessoryNone
                         block:^(UIViewController *controller)
      {
        TrackAPIViewController *cmdController = [self trackAPIVCWithApis:[self autoTrackAPIs]];
        cmdController.getTitleBlock = ^NSString * (__unused UIViewController *controllerInner)
        {
            return @"AutoTrack";
        };
        [controller.navigationController pushViewController:cmdController animated:YES];
    }]];
    
    [commands addObject:trackArray];
    [commands addObject:userArray];
    [commands addObject:optionArray];

    return commands;
}

- (NSArray *)autoTrackAPIs {
    NSMutableArray *commands = [NSMutableArray array];
    NSMutableArray *autoTrackArray = [NSMutableArray array];
    [autoTrackArray addObject:
     [APIEntry commandWithName:@"H5 打通 UIWebView"
                 accessoryType:UITableViewCellAccessoryNone
                         block:^(UIViewController *controller)
      {
        WEBViewController *webVC = [[WEBViewController alloc] init];
        [controller.navigationController pushViewController:webVC animated:YES];
    }]];
    
    [autoTrackArray addObject:
     [APIEntry commandWithName:@"H5 打通 WKWebView"
                 accessoryType:UITableViewCellAccessoryNone
                         block:^(UIViewController *controller)
      {
        WKWebViewController *webVC = [[WKWebViewController alloc] init];
        [controller.navigationController pushViewController:webVC animated:YES];
    }]];
    
    [autoTrackArray addObject:
     [APIEntry commandWithName:@"autotrack UIViewControllor"
                 accessoryType:UITableViewCellAccessoryNone
                         block:^(UIViewController *controller)
      {
        AutoTrackViewController *autoTrackVc = [[AutoTrackViewController alloc] init];
        [controller.navigationController pushViewController:autoTrackVc animated:YES];
    }]];
    
    [autoTrackArray addObject:
     [APIEntry commandWithName:@"autotrack UITableView"
                 accessoryType:UITableViewCellAccessoryNone
                         block:^(UIViewController *controller)
      {
        AutoTableViewController *autoTrackTVC = [[AutoTableViewController alloc] init];
        [controller.navigationController pushViewController:autoTrackTVC animated:YES];
    }]];
    
    [autoTrackArray addObject:
     [APIEntry commandWithName:@"autotrack UICollectionView"
                 accessoryType:UITableViewCellAccessoryNone
                         block:^(UIViewController *controller)
      {
        AutoCollectionViewController *autoCollectionVC = [[AutoCollectionViewController alloc] init];
        [controller.navigationController pushViewController:autoCollectionVC animated:YES];
    }]];
    
    [autoTrackArray addObject:
     [APIEntry commandWithName:@"轻实例"
                 accessoryType:UITableViewCellAccessoryNone
                         block:^(UIViewController *controller)
      {
        ThinkingAnalyticsSDK *light = [[ThinkingAnalyticsSDK sharedInstance] createLightInstance];
        [light track:@"lighttest"];
    }]];
    
    [autoTrackArray addObject:
     [APIEntry commandWithName:@"校准时间"
                 accessoryType:UITableViewCellAccessoryNone
                         block:^(UIViewController *controller)
      {
        NTPViewController *autoCollectionVC = [[NTPViewController alloc] init];
        [controller.navigationController pushViewController:autoCollectionVC animated:YES];
    }]];
    
    [commands addObject:autoTrackArray];
    return commands;
}

@end
