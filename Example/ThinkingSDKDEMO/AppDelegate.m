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

@property(nonatomic, strong) ThinkingAnalyticsSDK *instance1;
@property(nonatomic, strong) ThinkingAnalyticsSDK *instance2;
@property(nonatomic, strong) ThinkingAnalyticsSDK *instance3;
@property(nonatomic, strong) ThinkingAnalyticsSDK *instance4;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    NSLog(@"home: %@", NSHomeDirectory());
    
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
    
    [self instanceNameTest];
 
    return YES;
}

- (void)instanceNameTest {
    
    [ThinkingAnalyticsSDK setLogLevel:TDLoggingLevelDebug];
    
//    TDConfig *config1 = [[TDConfig alloc] init];
//    config1.name = @"instanceName1";
//    [ThinkingAnalyticsSDK startWithAppId:@"xxxx" withUrl:@"xxx" withConfig:config1];
    
    TDConfig *config2 = [[TDConfig alloc] init];
    config2.name = @"instanceName2";
    [ThinkingAnalyticsSDK startWithAppId:@"1b1c1fef65e3482bad5c9d0e6a823356"
                                 withUrl:@"http://receiver.ta.thinkingdata.cn/"
                              withConfig:config2];
    
    TDConfig *config3 = [[TDConfig alloc] init];
    config3.name = @"instanceName3";
    [ThinkingAnalyticsSDK startWithAppId:@"1b1c1fef65e3482bad5c9d0e6a823356"
                                 withUrl:@"https://receiver-ta-dev.thinkingdata.cn"
                              withConfig:config3];
    
    TDConfig *config4 = [[TDConfig alloc] init];
    [ThinkingAnalyticsSDK startWithAppId:@"22e445595b0f42bd8c5fe35bc44b88d6"
                                 withUrl:@"https://receiver-ta-dev.thinkingdata.cn"
                              withConfig:config4];
    
//    self.instance1 = [ThinkingAnalyticsSDK sharedInstanceWithAppid: @"instanceName1"];
    self.instance2 = [ThinkingAnalyticsSDK sharedInstanceWithAppid: @"instanceName2"];
    self.instance3 = [ThinkingAnalyticsSDK sharedInstanceWithAppid: @"instanceName3"];
    self.instance4 = [ThinkingAnalyticsSDK sharedInstanceWithAppid: @"22e445595b0f42bd8c5fe35bc44b88d6"];
    
    // login
//    [self.instance1 login:@"account_1"];
    [self.instance2 login:@"account_2"];
    [self.instance3 login:@"account_3"];
    [self.instance4 login:@"account_4"];
    
    // distinctid
//    [self.instance1 identify:@"distinctId_1"];
    [self.instance2 identify:@"distinctId_2"];
    [self.instance3 identify:@"distinctId_3"];
    [self.instance4 identify:@"distinctId_4"];
    
    // 事件
//    [self.instance1 track:@"instanceName1_event"];
    [self.instance2 track:@"instanceName2_event"];
    [self.instance3 track:@"instanceName3_event"];
    [self.instance4 track:@"instance4_event"];
    
    // 自动化采集
//    [self.instance1 enableAutoTrack:ThinkingAnalyticsEventTypeAll];
    [self.instance2 enableAutoTrack:ThinkingAnalyticsEventTypeAll];
    [self.instance3 enableAutoTrack:ThinkingAnalyticsEventTypeAll];
    [self.instance4 enableAutoTrack:ThinkingAnalyticsEventTypeAll];
    
    
    
//    [self.instance1 flush];
//    [self.instance2 flush];
//    [self.instance3 flush];
//    [self.instance4 flush];
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self.instance1 track:@"instance_event_1"];
//    });
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self.instance2 track:@"instance_event_2"];
//    });
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self.instance3 track:@"instance_event_3"];
//    });
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self.instance4 track:@"instance_event_4"];
//    });
    
//    [self.instance1 optInTracking];
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
