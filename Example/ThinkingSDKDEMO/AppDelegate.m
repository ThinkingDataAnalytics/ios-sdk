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
    NSLog(@"%@_%@",@"DEMO_",NSStringFromSelector(_cmd));
    
    // 使用 NTP Server 校准时间
//    [ThinkingAnalyticsSDK calibrateTimeWithNtp:@"ntp.aliyun.com"];
    // 开启 Log
//    [ThinkingAnalyticsSDK setLogLevel:TDLoggingLevelDebug];
    // 初始化
    // 配置初始化方法
//    TDConfig *config = [[TDConfig alloc] init];
//    config.launchOptions = launchOptions;
//    config.trackRelaunchedInBackgroundEvents = YES;
//    //    config.debugMode = ThinkingAnalyticsDebugOnly;
//    //    config.debugMode = ThinkingAnalyticsDebug;
//    config.defaultTimeZone = [NSTimeZone timeZoneWithName:@"UTC+0900"];
    
//    [ThinkingAnalyticsSDK startWithAppId:@"7a055a4bd7ec423fa5294b4a2c1eff28"
//                                 withUrl:@"https://receiver-ta-dev.thinkingdata.cn"
//                              withConfig:config];
//    [ThinkingAnalyticsSDK startWithAppId:@"debug-appid"
//                                 withUrl:@"http://47.112.250.224"
//                             ];
//    [[ThinkingAnalyticsSDK sharedInstance] addWebViewUserAgent];
//    [[ThinkingAnalyticsSDK sharedInstance] enableAutoTrack:ThinkingAnalyticsEventTypeAppEnd];
//    [[ThinkingAnalyticsSDK sharedInstance] timeEvent:@"test"];

    
    
    // 配置初始化方法
//    TDConfig *config = [[TDConfig alloc] init];
//    config.trackRelaunchedInBackgroundEvents = YES;
//    config.debugMode = ThinkingAnalyticsDebugOnly;
//    config.debugMode = ThinkingAnalyticsDebug;
//    config.defaultTimeZone = [NSTimeZone timeZoneWithName:@"UTC+0900"];
//    ThinkingAnalyticsSDK *instance = [ThinkingAnalyticsSDK startWithAppId:@"APP" withUrl:@"https://sdk.tga.thinkinggame.cn:9443" withConfig:config];
    
    // 自动埋点
//    [[ThinkingAnalyticsSDK sharedInstance] enableAutoTrack:
//     ThinkingAnalyticsEventTypeAppStart |
//     ThinkingAnalyticsEventTypeAppEnd |
//     ThinkingAnalyticsEventTypeAppViewScreen |
//     ThinkingAnalyticsEventTypeAppClick |
//     ThinkingAnalyticsEventTypeAppInstall //|
////     ThinkingAnalyticsEventTypeAppViewCrash
//     ];
    
    // H5 需要打通时  需要配置
//    [[ThinkingAnalyticsSDK sharedInstance] addWebViewUserAgent];
 
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    NSLog(@"%@_%@",@"DEMO_",NSStringFromSelector(_cmd));
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
   NSLog(@"%@_%@",@"DEMO_",NSStringFromSelector(_cmd));
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    NSLog(@"%@_%@",@"DEMO_",NSStringFromSelector(_cmd));
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    NSLog(@"%@_%@",@"DEMO_",NSStringFromSelector(_cmd));
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
   NSLog(@"%@_%@",@"DEMO_",NSStringFromSelector(_cmd));
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
