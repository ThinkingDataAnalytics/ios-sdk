//
//  AppDelegate.m
//  ThinkingSDKDEMO
//
//  Created by syj on 2019/6/24.
//  Copyright © 2019年 thinking. All rights reserved.
//

#import "AppDelegate.h"
#import "AppDelegate+TDUI.h"
#import <ThinkingSDK/ThinkingAnalyticsSDK.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [self createRootViewController];
    [self.window makeKeyAndVisible];
    
//    ThinkingAnalyticsSDK *thinkingSDK = [ThinkingAnalyticsSDK startWithAppId:@"APPID" withUrl:@"URL"];
    
    TDConfig *config = [[TDConfig alloc] init];
    config.trackRelaunchedInBackgroundEvents = YES;
    ThinkingAnalyticsSDK *thinkingSDK =  [ThinkingAnalyticsSDK startWithAppId:@"b8976e6cf8fb4f1b8aa761cecbb423da" withUrl:@"http://sdk.tga.thinkinggame.cn:9080" withConfig:config];
    
    [thinkingSDK enableAutoTrack:
     ThinkingAnalyticsEventTypeAppStart |
     ThinkingAnalyticsEventTypeAppEnd |
     ThinkingAnalyticsEventTypeAppViewScreen |
     ThinkingAnalyticsEventTypeAppClick |
     ThinkingAnalyticsEventTypeAppInstall //|
//     ThinkingAnalyticsEventTypeAppViewCrash
     ];
    [ThinkingAnalyticsSDK setLogLevel:TDLoggingLevelDebug];
    
    
    // H5 需要打通时  需要配置
    [[ThinkingAnalyticsSDK sharedInstance] addWebViewUserAgent];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
