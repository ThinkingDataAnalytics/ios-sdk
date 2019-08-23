//
//  ThinkingSDKAPI.m
//  ThinkingSDKDEMO
//
//  Created by syj on 2019/6/24.
//  Copyright © 2019年 thinking. All rights reserved.
//

#import "ThinkingSDKAPI.h"
#import <ThinkingSDK/ThinkingAnalyticsSDK.h>

@implementation ThinkingSDKAPI

+ (void)testTrack {
    [[ThinkingAnalyticsSDK sharedInstance] track:@"test"];
}

+ (void)testTrackWithProperty {
    [[ThinkingAnalyticsSDK sharedInstance] track:@"testProperty" properties:@{@"properKey":@"properValue"}];
}

+ (void)testTrackWithTime {
    [[ThinkingAnalyticsSDK sharedInstance] track:@"key1" properties:@{@"properKey1":@"properValue1"} time:[NSDate date]];
}

+ (void)testUserSet {
    [[ThinkingAnalyticsSDK sharedInstance] user_set:@{
                                                     @"UserName":@"TA1",
                                                     @"Age":[NSNumber numberWithInt:20]
                                                     }];
}

+ (void)testUserSetonce {
    [[ThinkingAnalyticsSDK sharedInstance] user_setOnce:@{@"setOnce":@"setonevalue1"}];
}

+ (void)testUserDel {
    [[ThinkingAnalyticsSDK sharedInstance] user_delete];
}

+ (void)testUserAdd {
    [[ThinkingAnalyticsSDK sharedInstance] user_add:@{@"key1":[NSNumber numberWithInt:6]}];
}

+ (void)testLogin {
    [[ThinkingAnalyticsSDK sharedInstance] login:@"logintest"];
}

+ (void)testLogout {
    [[ThinkingAnalyticsSDK sharedInstance] logout];
}

+ (void)testSetsuper {
    [[ThinkingAnalyticsSDK sharedInstance] setSuperProperties:@{@"superkey":@"supervalue1",@"superkey2":@"supervalue3"}];
}

+ (void)testUnsetsuper {
    [[ThinkingAnalyticsSDK sharedInstance] unsetSuperProperty:@"superkey"];
    [[ThinkingAnalyticsSDK sharedInstance] unsetSuperProperty:@""];
}

+ (void)testClearsuper {
    [[ThinkingAnalyticsSDK sharedInstance] clearSuperProperties];
}

+ (void)testTimedEvent
{
    [[ThinkingAnalyticsSDK sharedInstance] timeEvent:@"TimedEvent"];
}

+ (void)testTrackEventEnd
{
    [[ThinkingAnalyticsSDK sharedInstance] track:@"TimedEvent"];
}

+ (void)testIdentify {
    [[ThinkingAnalyticsSDK sharedInstance] identify:@"testIdentify1"];
}

+ (void)testFlush {
    [[ThinkingAnalyticsSDK sharedInstance] flush];
}

+ (void)testEnable {
    [[ThinkingAnalyticsSDK sharedInstance] enableTracking:YES];
}

+ (void)testDisEnable {
    [[ThinkingAnalyticsSDK sharedInstance] enableTracking:NO];
}

+ (void)optOutTracking {
    [[ThinkingAnalyticsSDK sharedInstance] optOutTracking];
}

+ (void)optOutTrackingAndDeleteUser {
    [[ThinkingAnalyticsSDK sharedInstance] optOutTrackingAndDeleteUser];
}

+ (void)optInTracking {
    [[ThinkingAnalyticsSDK sharedInstance] optInTracking];
}

// H5 打通 jsSDK 需要配置 useAppTrack: true,
// UIWebView 具体查看 WEBViewController.m 文件
+ (void)testAgent {
    [[ThinkingAnalyticsSDK sharedInstance] addWebViewUserAgent];
}

@end
