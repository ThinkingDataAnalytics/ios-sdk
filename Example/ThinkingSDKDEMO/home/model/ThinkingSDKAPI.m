//
//  ThinkingSDKAPI.m
//  ThinkingSDKDEMO
//
//  Created by syj on 2019/6/24.
//  Copyright © 2019年 thinking. All rights reserved.
//

#import "ThinkingSDKAPI.h"
#import <ThinkingSDK/ThinkingAnalyticsSDK.h>
ThinkingAnalyticsSDK* _instance;
@implementation ThinkingSDKAPI

+ (void)setInstance:(ThinkingAnalyticsSDK*)instance
{
    _instance = instance;
}
+ (ThinkingAnalyticsSDK*)getInstance
{
    return _instance;
}
+ (void)testTrack {
    [_instance track:@"a"];

}

+ (void)testTrackWithProperty {
    [_instance track:@"testProperty" properties:@{@"properKey":@"properValue", @"arrKey":@[@1, @2],@"event_time":@"2020-10-20 18:00:51.125",@"xx":@NO,@"level":@"level-1"}];
}

+ (void)testTrackWithTimezone {
    [_instance track:@"test" properties:nil time:[NSDate date] timeZone:[NSTimeZone localTimeZone]];
}

+ (void)testTrackWithDefaultFirstCheckID {
    [_instance timeEvent:@"eventName_unique_default"];
    TDFirstEventModel *uniqueModel = [[TDFirstEventModel alloc] initWithEventName:@"eventName_unique_default"];
    uniqueModel.properties = @{ @"TestProKey": @"TestProValue"};
    [_instance trackWithEventModel:uniqueModel];
}

+ (void)testTrackWithFirstCheckID {
    [_instance timeEvent:@"eventName_unique"];
    sleep(1);
    TDFirstEventModel *uniqueModel = [[TDFirstEventModel alloc] initWithEventName:@"eventName_unique" firstCheckID:@"customFirstCheckID"];
    uniqueModel.properties = @{ @"TestProKey": @"TestProValue"};
    [_instance trackWithEventModel:uniqueModel];
}

+ (void)testTrackUpdate {
    [_instance timeEvent:@"eventName_edit"];
    sleep(1);
    
    TDUpdateEventModel *updateModel = [[TDUpdateEventModel alloc] initWithEventName:@"eventName_edit" eventID:@"eventIDxxx"];
    updateModel.properties = @{ @"eventKeyEdit": @"eventKeyEdit_update", @"eventKeyEdit2": @"eventKeyEdit_update2" };
    [_instance trackWithEventModel:updateModel];
}

+ (void)testTrackOverwrite {
    TDOverwriteEventModel *overwriteModel = [[TDOverwriteEventModel alloc] initWithEventName:@"eventName_edit" eventID:@"eventIDxxx"];
    overwriteModel.properties = @{ @"eventKeyEdit": @"eventKeyEdit_overwrite" };
    [_instance trackWithEventModel:overwriteModel];
}

+ (void)testChangeLibNameAndLibVersion {
    [ThinkingAnalyticsSDK setCustomerLibInfoWithLibName:@"changeLibName" libVersion:@"0.00.001"];
    [_instance track:@"trackNameCustomLibName"];
}

+ (void)testUserSet {
    [_instance user_set:@{
                                                     @"UserName":@"TA1",
                                                     @"Age":[NSNumber numberWithInt:20]
                                                     }];
    [_instance user_set:@{
                                                      @"UserName":@"TA1",
                                                      @"Age":[NSNumber numberWithInt:20]
                                                      } withTime:[NSDate date]];
}

+ (void)testUserUnset {
    [_instance user_unset:@"key1"];
    [_instance user_unset:@"key1" withTime:[NSDate date]];
}

+ (void)testUserSetonce {
    [_instance user_setOnce:@{@"setOnce":@"setonevalue1"}];
    [_instance user_setOnce:@{@"setOnce":@"setonevalue1"} withTime:[NSDate date]];
}

+ (void)testUserDel {
    [_instance user_delete];
    [_instance user_delete:[NSDate date]];
}

+ (void)testUserAdd {
    [_instance user_add:@{@"key1":[NSNumber numberWithInt:6]}];
    [_instance user_add:@{@"key1":[NSNumber numberWithInt:6]} withTime:[NSDate date]];
    [_instance user_add:@"key1" andPropertyValue:[NSNumber numberWithInt:6]];
    [_instance user_add:@"key1" andPropertyValue:[NSNumber numberWithInt:6] withTime:[NSDate date]];
}

+ (void)testUserAppend {
    [_instance user_append:@{@"product_buy": @[@"product_name1", @"product_name2"]}];
    [_instance user_append:@{@"product_buy": @[@"product_name1", @"product_name2"]} withTime:[NSDate date]];
}

+ (void)testLogin {
    [_instance login:@"logintest"];
}

+ (void)testLogout {
    [_instance logout];
}

+ (void)testSetsuper {
    [_instance setSuperProperties:@{@"superkey":@"supervalue1",@"superkey2":@"数数科技👍",@"superkey3":@(YES),@"level":@"level-3"}];
}

+ (void)testUnsetsuper {
    [_instance unsetSuperProperty:@"superkey"];
    [_instance unsetSuperProperty:@""];
}

+ (void)testClearsuper {
    [_instance clearSuperProperties];
}

+ (void)testSetDynamicsuper {
    [_instance registerDynamicSuperProperties:^NSDictionary<NSString *,id> * _Nonnull{
        return @{@"dynamicsuperkey":@"dynamicsupervalue",@"level":@"level-2"};
    }];
}

+ (void)testTimedEvent {
    [_instance timeEvent:@"TimedEvent"];
}

+ (void)testTrackEventEnd {
    [_instance track:@"TimedEvent"];
}

+ (void)testIdentify {
    [_instance identify:@"testIdentify1"];
}

+ (void)testFlush {
    [_instance flush];
}

+ (void)testEnable {
    [_instance enableTracking:YES];
}

+ (void)testDisEnable {
    [_instance enableTracking:NO];
}

+ (void)optOutTracking {
    [_instance optOutTracking];
}

+ (void)optOutTrackingAndDeleteUser {
    [_instance optOutTrackingAndDeleteUser];
}

+ (void)optInTracking {
    [_instance optInTracking];
}

// H5 打通 jsSDK 需要配置 useAppTrack: true,
// UIWebView 具体查看 WEBViewController.m 文件
+ (void)testAgent {
    [_instance addWebViewUserAgent];
}

@end
