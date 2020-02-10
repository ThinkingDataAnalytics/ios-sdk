//
//  AppDelegate+TDUI.m
//  ThinkingSDKDEMO
//
//  Created by syj on 2019/6/24.
//  Copyright © 2019年 thinking. All rights reserved.
//

#import "AppDelegate+TDUI.h"
#import "TrackAPIVC.h"
#import "APIEntry.h"
#import "ThinkingSDKAPI.h"
#import "WEBViewController.h"
#import "WKWebViewController.h"
#import "AutoTrackViewController.h"
#import "AutoTableViewController.h"
#import "AutoCollectionViewController.h"
#import "NTPViewController.h"
#import <ThinkingSDK/ThinkingAnalyticsSDK.h>

@implementation AppDelegate (TDUI)

- (UIViewController *)createRootViewController {
    TrackAPIVC *trackController = [self trackAPIVCWithApis:[self manageAPIs]];
    trackController.getTitleBlock = ^NSString * (__unused UIViewController *controller)
    {
        return @"ThinkingSDK DEMO";
    };
    return [[UINavigationController alloc] initWithRootViewController:trackController];
}

- (TrackAPIVC *)trackAPIVCWithApis:(NSArray *)commands {
    TrackAPIVC *apiController = [[TrackAPIVC alloc] initWithStyle:UITableViewStylePlain];
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
    [commands addObject:
     [APIEntry commandWithName:@"Track"
                 accessoryType:UITableViewCellAccessoryNone
                         block:^(UIViewController *controller)
      {
          [ThinkingSDKAPI testTrack];
      }]];
    
    [commands addObject:
     [APIEntry commandWithName:@"Track with property"
                 accessoryType:UITableViewCellAccessoryNone
                         block:^(UIViewController *controller)
      {
          [ThinkingSDKAPI testTrackWithProperty];
      }]];
    
    [commands addObject:
     [APIEntry commandWithName:@"Track With Timezone"
                 accessoryType:UITableViewCellAccessoryNone
                         block:^(UIViewController *controller)
      {
          [ThinkingSDKAPI testTrackWithTimezone];
      }]];
    
    [commands addObject:
     [APIEntry commandWithName:@"User Set"
                 accessoryType:UITableViewCellAccessoryNone
                         block:^(UIViewController *controller)
      {
          [ThinkingSDKAPI testUserSet];
      }]];
    
    [commands addObject:
     [APIEntry commandWithName:@"User Unset"
                 accessoryType:UITableViewCellAccessoryNone
                         block:^(UIViewController *controller)
      {
          [ThinkingSDKAPI testUserUnset];
      }]];
    
    [commands addObject:
     [APIEntry commandWithName:@"User Set Once"
                 accessoryType:UITableViewCellAccessoryNone
                         block:^(UIViewController *controller)
      {
          [ThinkingSDKAPI testUserSetonce];
      }]];
    
    [commands addObject:
     [APIEntry commandWithName:@"User Del"
                 accessoryType:UITableViewCellAccessoryNone
                         block:^(UIViewController *controller)
      {
          [ThinkingSDKAPI testUserDel];
      }]];
    
    [commands addObject:
     [APIEntry commandWithName:@"User ADD"
                 accessoryType:UITableViewCellAccessoryNone
                         block:^(UIViewController *controller)
      {
          [ThinkingSDKAPI testUserAdd];
      }]];
    
    [commands addObject:
     [APIEntry commandWithName:@"User APPEND"
                accessoryType:UITableViewCellAccessoryNone
                        block:^(UIViewController *controller)
      {
          [ThinkingSDKAPI testUserAppend];
      }]];

    [commands addObject:
     [APIEntry commandWithName:@"Login"
                 accessoryType:UITableViewCellAccessoryNone
                         block:^(UIViewController *controller)
      {
          [ThinkingSDKAPI testLogin];
      }]];
    
    [commands addObject:
     [APIEntry commandWithName:@"Logout"
                 accessoryType:UITableViewCellAccessoryNone
                         block:^(UIViewController *controller)
      {
          [ThinkingSDKAPI testLogout];
      }]];
    
    [commands addObject:
     [APIEntry commandWithName:@"Set SuperProperty"
                 accessoryType:UITableViewCellAccessoryNone
                         block:^(UIViewController *controller)
      {
          [ThinkingSDKAPI testSetsuper];
      }]];
    
    [commands addObject:
     [APIEntry commandWithName:@"Unset SuperProperty"
                 accessoryType:UITableViewCellAccessoryNone
                         block:^(UIViewController *controller)
      {
          [ThinkingSDKAPI testUnsetsuper];
      }]];
    
    [commands addObject:
     [APIEntry commandWithName:@"Clear SuperProperty"
                 accessoryType:UITableViewCellAccessoryNone
                         block:^(UIViewController *controller)
      {
          [ThinkingSDKAPI testClearsuper];
      }]];
    
    [commands addObject:
     [APIEntry commandWithName:@"Time Event"
                 accessoryType:UITableViewCellAccessoryNone
                         block:^(UIViewController *controller)
      {
          [ThinkingSDKAPI testTimedEvent];
      }]];
    
    [commands addObject:
     [APIEntry commandWithName:@"Time Event End"
                 accessoryType:UITableViewCellAccessoryNone
                         block:^(UIViewController *controller)
      {
          [ThinkingSDKAPI testTrackEventEnd];
      }]];
    
    [commands addObject:
     [APIEntry commandWithName:@"Identify"
                 accessoryType:UITableViewCellAccessoryNone
                         block:^(UIViewController *controller)
      {
          [ThinkingSDKAPI testIdentify];
      }]];
    
    [commands addObject:
       [APIEntry commandWithName:@"Flush"
                   accessoryType:UITableViewCellAccessoryNone
                           block:^(UIViewController *controller)
        {
            [ThinkingSDKAPI testFlush];
        }]];
    
    [commands addObject:
     [APIEntry commandWithName:@"Enable"
                 accessoryType:UITableViewCellAccessoryNone
                         block:^(UIViewController *controller)
      {
          [ThinkingSDKAPI testEnable];
      }]];
    
    [commands addObject:
     [APIEntry commandWithName:@"DisEnable"
                 accessoryType:UITableViewCellAccessoryNone
                         block:^(UIViewController *controller)
      {
          [ThinkingSDKAPI testDisEnable];
      }]];
    
    [commands addObject:
     [APIEntry commandWithName:@"optOutTracking"
                 accessoryType:UITableViewCellAccessoryNone
                         block:^(UIViewController *controller)
      {
          [ThinkingSDKAPI optOutTracking];
      }]];
    
    [commands addObject:
     [APIEntry commandWithName:@"optOutTrackingAndDeleteUser"
                 accessoryType:UITableViewCellAccessoryNone
                         block:^(UIViewController *controller)
      {
          [ThinkingSDKAPI optOutTrackingAndDeleteUser];
      }]];
    
    [commands addObject:
     [APIEntry commandWithName:@"optInTracking"
                 accessoryType:UITableViewCellAccessoryNone
                         block:^(UIViewController *controller)
      {
          [ThinkingSDKAPI optInTracking];
      }]];
    
     [commands addObject:
      [APIEntry commandWithName:@"More (AutoTrack,h5,轻实例...)"
                  accessoryType:UITableViewCellAccessoryNone
                          block:^(UIViewController *controller)
     {
         TrackAPIVC *cmdController = [self trackAPIVCWithApis:[self autoTrackAPIs]];
         cmdController.getTitleBlock = ^NSString * (__unused UIViewController *controllerInner)
         {
             return @"AutoTrack";
         };
         [controller.navigationController pushViewController:cmdController animated:YES];
     }]];
     return commands;
}

- (NSArray *)autoTrackAPIs {
    NSMutableArray *commands = [NSMutableArray array];
    [commands addObject:
     [APIEntry commandWithName:@"H5 打通 UIWebView"
                 accessoryType:UITableViewCellAccessoryNone
                         block:^(UIViewController *controller)
      {
          WEBViewController *webVC = [[WEBViewController alloc] init];
          [controller.navigationController pushViewController:webVC animated:YES];
      }]];
    
    [commands addObject:
     [APIEntry commandWithName:@"H5 打通 WKWebView"
                 accessoryType:UITableViewCellAccessoryNone
                         block:^(UIViewController *controller)
      {
          WKWebViewController *webVC = [[WKWebViewController alloc] init];
          [controller.navigationController pushViewController:webVC animated:YES];
      }]];
    
    [commands addObject:
    [APIEntry commandWithName:@"autotrack UIViewControllor"
                accessoryType:UITableViewCellAccessoryNone
                        block:^(UIViewController *controller)
     {
         AutoTrackViewController *autoTrackVc = [[AutoTrackViewController alloc] init];
         [controller.navigationController pushViewController:autoTrackVc animated:YES];
     }]];
    
    [commands addObject:
     [APIEntry commandWithName:@"autotrack UITableView"
                 accessoryType:UITableViewCellAccessoryNone
                         block:^(UIViewController *controller)
      {
          AutoTableViewController *autoTrackTVC = [[AutoTableViewController alloc] init];
          [controller.navigationController pushViewController:autoTrackTVC animated:YES];
      }]];
    
    [commands addObject:
     [APIEntry commandWithName:@"autotrack UICollectionView"
                 accessoryType:UITableViewCellAccessoryNone
                         block:^(UIViewController *controller)
      {
          AutoCollectionViewController *autoCollectionVC = [[AutoCollectionViewController alloc] init];
          [controller.navigationController pushViewController:autoCollectionVC animated:YES];
      }]];
    
    [commands addObject:
     [APIEntry commandWithName:@"轻实例"
                 accessoryType:UITableViewCellAccessoryNone
                         block:^(UIViewController *controller)
      {
          ThinkingAnalyticsSDK *light = [[ThinkingAnalyticsSDK sharedInstance] createLightInstance];
          [light track:@"lighttest"];
      }]];
    
    [commands addObject:
     [APIEntry commandWithName:@"校准时间"
                 accessoryType:UITableViewCellAccessoryNone
                         block:^(UIViewController *controller)
      {
          NTPViewController *autoCollectionVC = [[NTPViewController alloc] init];
          [controller.navigationController pushViewController:autoCollectionVC animated:YES];
      }]];
    return commands;
}

@end
