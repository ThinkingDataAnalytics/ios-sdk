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
    [[ThinkingAnalyticsSDK sharedInstance] track:@"testProperty" properties:@{@"properKey":@"properValue", @"arrKey":@[@1, @2]}];
}

+ (void)testTrackWithTimezone {
    [[ThinkingAnalyticsSDK sharedInstance] track:@"test" properties:nil time:[NSDate date] timeZone:[NSTimeZone localTimeZone]];
}

+ (void)testTrackWithDefaultFirstCheckID {
    [[ThinkingAnalyticsSDK sharedInstance] timeEvent:@"eventName_unique_default"];
    TDFirstEventModel *uniqueModel = [[TDFirstEventModel alloc] initWithEventName:@"eventName_unique_default"];
    uniqueModel.properties = @{ @"TestProKey": @"TestProValue"};
    [[ThinkingAnalyticsSDK sharedInstance] trackWithEventModel:uniqueModel];
}

+ (void)testTrackWithFirstCheckID {
    [[ThinkingAnalyticsSDK sharedInstance] timeEvent:@"eventName_unique"];
    sleep(1);
    TDFirstEventModel *uniqueModel = [[TDFirstEventModel alloc] initWithEventName:@"eventName_unique" firstCheckID:@"customFirstCheckID"];
    uniqueModel.properties = @{ @"TestProKey": @"TestProValue"};
    [[ThinkingAnalyticsSDK sharedInstance] trackWithEventModel:uniqueModel];
}

+ (void)testTrackUpdate {
    [[ThinkingAnalyticsSDK sharedInstance] timeEvent:@"eventName_edit"];
    sleep(1);
    
    TDUpdateEventModel *updateModel = [[TDUpdateEventModel alloc] initWithEventName:@"eventName_edit" eventID:@"eventIDxxx"];
    updateModel.properties = @{ @"eventKeyEdit": @"eventKeyEdit_update", @"eventKeyEdit2": @"eventKeyEdit_update2" };
    [[ThinkingAnalyticsSDK sharedInstance] trackWithEventModel:updateModel];
}

+ (void)testTrackOverwrite {
    TDOverwriteEventModel *overwriteModel = [[TDOverwriteEventModel alloc] initWithEventName:@"eventName_edit" eventID:@"eventIDxxx"];
    overwriteModel.properties = @{ @"eventKeyEdit": @"eventKeyEdit_overwrite" };
    [[ThinkingAnalyticsSDK sharedInstance] trackWithEventModel:overwriteModel];
}

+ (void)testChangeLibNameAndLibVersion {
    [ThinkingAnalyticsSDK setCustomerLibInfoWithLibName:@"changeLibName" libVersion:@"0.00.001"];
    [[ThinkingAnalyticsSDK sharedInstance] track:@"trackNameCustomLibName"];
}

+ (void)testUserSet {
    [[ThinkingAnalyticsSDK sharedInstance] user_set:@{
                                                     @"UserName":@"TA1",
                                                     @"Age":[NSNumber numberWithInt:20]
                                                     }];
    [[ThinkingAnalyticsSDK sharedInstance] user_set:@{
                                                      @"UserName":@"TA1",
                                                      @"Age":[NSNumber numberWithInt:20]
                                                      } withTime:[NSDate date]];
}

+ (void)testUserUnset {
    [[ThinkingAnalyticsSDK sharedInstance] user_unset:@"key1"];
    [[ThinkingAnalyticsSDK sharedInstance] user_unset:@"key1" withTime:[NSDate date]];
}

+ (void)testUserSetonce {
    [[ThinkingAnalyticsSDK sharedInstance] user_setOnce:@{@"setOnce":@"setonevalue1"}];
    [[ThinkingAnalyticsSDK sharedInstance] user_setOnce:@{@"setOnce":@"setonevalue1"} withTime:[NSDate date]];
}

+ (void)testUserDel {
    [[ThinkingAnalyticsSDK sharedInstance] user_delete];
    [[ThinkingAnalyticsSDK sharedInstance] user_delete:[NSDate date]];
}

+ (void)testUserAdd {
    [[ThinkingAnalyticsSDK sharedInstance] user_add:@{@"key1":[NSNumber numberWithInt:6]}];
    [[ThinkingAnalyticsSDK sharedInstance] user_add:@{@"key1":[NSNumber numberWithInt:6]} withTime:[NSDate date]];
    [[ThinkingAnalyticsSDK sharedInstance] user_add:@"key1" andPropertyValue:[NSNumber numberWithInt:6]];
    [[ThinkingAnalyticsSDK sharedInstance] user_add:@"key1" andPropertyValue:[NSNumber numberWithInt:6] withTime:[NSDate date]];
}

+ (void)testUserAppend {
    [[ThinkingAnalyticsSDK sharedInstance] user_append:@{@"product_buy": @[@"product_name1", @"product_name2"]}];
    [[ThinkingAnalyticsSDK sharedInstance] user_append:@{@"product_buy": @[@"product_name1", @"product_name2"]} withTime:[NSDate date]];
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

+ (void)testTimedEvent {
    [[ThinkingAnalyticsSDK sharedInstance] timeEvent:@"TimedEvent"];
}

+ (void)testTrackEventEnd {
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
