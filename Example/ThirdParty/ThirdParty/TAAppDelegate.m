//
//  TAAppDelegate.m
//  TAThirdParty
//
//  Created by wwango on 10/08/2022.
//  Copyright (c) 2022 wwango. All rights reserved.
//

#import "TAAppDelegate.h"
#import <ThinkingSDK/ThinkingAnalyticsSDK.h>
#import <AppsFlyerLib/AppsFlyerLib.h>
#import "IronSource/IronSource.h"
#import "Adjust.h"
#import "Branch/Branch.h"
#import <AnyThinkSDK/AnyThinkSDK.h>

// 目前ReYunFramework、TradPlusAds 的framework，在模拟器上不能运行
#if (TARGET_IPHONE_SIMULATOR == 0)
//#import <ReYunFramework/Tracking.h>
//#import <TradPlusAds/TradPlus.h>
#endif

# ifdef NSFoundationVersionNumber_iOS_9_x_Max
# import <UserNotifications/UserNotifications.h>
# endif
# import <AdSupport/AdSupport.h>

#import <AppLovinSDK/AppLovinSDK.h>

@implementation TAAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    [AppsFlyerLib shared].isDebug = 1;
    [[AppsFlyerLib shared] setIsDebug:YES];
    [AppsFlyerLib shared].appsFlyerDevKey = @"FVAvxeH7HPCVZ67QrjQPqQ";
    [AppsFlyerLib shared].appleAppID = @"1562111162";
    [AppsFlyerLib shared].delegate = self;

    
    
    [ThinkingAnalyticsSDK setLogLevel:TDLoggingLevelDebug];
    NSString *appid = @"1b1c1fef65e3482bad5c9d0e6a823356";
    NSString *url = @"http://receiver.ta.thinkingdata.cn/";
    TDConfig *config = [TDConfig new];
    config.appid = appid;
    config.configureURL = url;
    [ThinkingAnalyticsSDK startWithConfig:config];
    [[ThinkingAnalyticsSDK sharedInstance] login:@"j9nb91876thmct8"];
    [[ThinkingAnalyticsSDK sharedInstance] track:@"timeEvent" properties:@{@"a":@"b", @"aa":@{@"a1":@"b1"}}];

    
    //MARK: AF发事件
    [[ThinkingAnalyticsSDK sharedInstance] enableThirdPartySharing: TAThirdPartyShareTypeAPPSFLYER customMap:@{@"ta_data11":@"ta_value11"}];
    [[AppsFlyerLib shared] logEvent:@"af_eventname" withValues:@{@"key":@"value"}];
    [[AppsFlyerLib shared] start];

//    //MARK: IRON发事件
//    [[ThinkingAnalyticsSDK sharedInstance] enableThirdPartySharing: TAThirdPartyShareTypeIRONSOURCE];
//
//    [IronSource addImpressionDataDelegate:self];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self impressionDataDidSucceed:ISImpressionData.new];
//    });
//    
//    //MARK: Adjust
//    [[ThinkingAnalyticsSDK sharedInstance] enableThirdPartySharing:TAThirdPartyShareTypeADJUST];
//    NSString *yourAppToken = @"{YourAppToken}";
//    NSString *environment = ADJEnvironmentSandbox;
//    ADJConfig *adjustConfig = [ADJConfig configWithAppToken:yourAppToken
//                                      environment:environment];
//    
//    [Adjust appDidLaunch:adjustConfig];
//    
//    //MARK: Branch
//    [[ThinkingAnalyticsSDK sharedInstance] enableThirdPartySharing:TAThirdPartyShareTypeBRANCH];
//    // if you are using the TEST key
//    [Branch setUseTestBranchKey:YES];
//    // listener for Branch Deep Link data
//    [[Branch getInstance] initSessionWithLaunchOptions:launchOptions andRegisterDeepLinkHandler:^(NSDictionary * _Nonnull params, NSError * _Nullable error) {
//      // do stuff with deep link data (nav to page, display content, etc)
//      NSLog(@"%@", params);
//    }];
//    
//    //MARK: TopOn
//    [[ThinkingAnalyticsSDK sharedInstance] enableThirdPartySharing:TAThirdPartyShareTypeTOPON];
//    [ATAPI setLogEnabled:YES];//Turn on debug logs
//    [ATAPI integrationChecking];
//    [[ATAPI sharedInstance] startWithAppID:@"a5acc73c25fbf5" appKey:@"4f7b9ac17decb9babec83aac078742c7" error:nil];
//    
//    
//    // 目前ReYunFramework、TradPlusAds 的framework，在模拟器上不能运行
//#if (TARGET_IPHONE_SIMULATOR == 0)
//    //MARK: 热云
//    [[ThinkingAnalyticsSDK sharedInstance] enableThirdPartySharing:TAThirdPartyShareTypeTRACKING];
//    [Tracking initWithAppKey:@"475938c702f7451a88eaffb524962649"withChannelId:@"_default_"];
//    
//    
//    //MARK: TradPlus
//    [[ThinkingAnalyticsSDK sharedInstance] enableThirdPartySharing:TAThirdPartyShareTypeTRADPLUS];
//    [TradPlus initSDK:@"tradplus后台的应用对应appid" completionBlock:^(NSError *error){
//            if (!error)
//            {
//                MSLogInfo(@"tradplus sdk init success!");
//            }
//        }];
//#endif
//    
    
    
    return YES;
}





- (void)impressionDataDidSucceed:(ISImpressionData *)impressionData {
    NSLog(@"IronSource - impressionDataDidSucceed");
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
