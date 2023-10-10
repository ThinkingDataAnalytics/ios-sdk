//
//  ThinkingSDKAPI.m
//  ThinkingSDKDEMO
//
//  Created by syj on 2019/6/24.
//  Copyright © 2019 thinking. All rights reserved.
//

#import "ThinkingSDKAPI.h"

@implementation ThinkingSDKAPI

+ (void)testTrack {
    [TDAnalytics track:@"a"];
}

+ (void)testTrackWithProperty {
    [TDAnalytics track:@"testProperty" properties:@{@"properKey":@"properValue", @"arrKey":@[@1, @2],@"event_time":@"2020-10-20 18:00:51.125",@"xx":@NO,@"level":@"level-1"}];
}

+ (void)testTrackWithTimezone {
    [TDAnalytics track:@"test" properties:nil time:[NSDate date] timeZone:[NSTimeZone localTimeZone]];
}

+ (void)testTrackWithDefaultFirstCheckID {
    [TDAnalytics timeEvent:@"eventName_unique_default"];
    TDFirstEventModel *uniqueModel = [[TDFirstEventModel alloc] initWithEventName:@"eventName_unique_default"];
    uniqueModel.properties = @{ @"TestProKey": @"TestProValue"};
    [TDAnalytics trackWithEventModel:uniqueModel];
}

+ (void)testTrackWithFirstCheckID {
    [TDAnalytics timeEvent:@"eventName_unique"];
    sleep(1);
    TDFirstEventModel *uniqueModel = [[TDFirstEventModel alloc] initWithEventName:@"eventName_unique" firstCheckID:@"customFirstCheckID"];
    uniqueModel.properties = @{ @"TestProKey": @"TestProValue"};
    [TDAnalytics trackWithEventModel:uniqueModel];
}

+ (void)testTrackUpdate {
    [TDAnalytics timeEvent:@"eventName_edit"];
    sleep(1);
    
    TDUpdateEventModel *updateModel = [[TDUpdateEventModel alloc] initWithEventName:@"eventName_edit" eventID:@"eventIDxxx"];
    updateModel.properties = @{ @"eventKeyEdit": @"eventKeyEdit_update", @"eventKeyEdit2": @"eventKeyEdit_update2" };
    [TDAnalytics trackWithEventModel:updateModel];
}

+ (void)testTrackOverwrite {
    TDOverwriteEventModel *overwriteModel = [[TDOverwriteEventModel alloc] initWithEventName:@"eventName_edit" eventID:@"eventIDxxx"];
    overwriteModel.properties = @{ @"eventKeyEdit": @"eventKeyEdit_overwrite" };
    [TDAnalytics trackWithEventModel:overwriteModel];
}

+ (void)testChangeLibNameAndLibVersion {
    [TDAnalytics setCustomerLibInfoWithLibName:@"changeLibName" libVersion:@"0.00.001"];
    [TDAnalytics track:@"trackNameCustomLibName"];
}

+ (void)testUserSet {
    [TDAnalytics userSet:@{
        @"UserName":@"TA1",
        @"Age":[NSNumber numberWithInt:20]
    }];
}

+ (void)testUserUnset {
    [TDAnalytics userUnset:@"key1"];
}

+ (void)testUserSetonce {
    [TDAnalytics userSetOnce:@{@"setOnce":@"setonevalue1"}];
}

+ (void)testUserDel {
    [TDAnalytics userDelete];
}

+ (void)testUserAdd {
    [TDAnalytics userAdd:@{
        @"key1":[NSNumber numberWithInt:6]
    }];
}

+ (void)testUserAppend {
    [TDAnalytics userAppend:@{
        @"product_buy": @[@"product_name1", @"product_name2"]
    }];
}

+ (void)testLogin {
    [TDAnalytics login:@"logintest"];
}

+ (void)testLogout {
    [TDAnalytics logout];
}

+ (void)testSetsuper {
    [TDAnalytics setSuperProperties:@{@"superkey":@"supervalue1",@"superkey2":@"shushu👍",@"superkey3":@(YES),@"level":@"level-3"}];
}

+ (void)testUnsetsuper {
    [TDAnalytics unsetSuperProperty:@"superkey"];
    [TDAnalytics unsetSuperProperty:@""];
}

+ (void)testClearsuper {
    [TDAnalytics clearSuperProperties];
}

+ (void)testSetDynamicsuper {
    [TDAnalytics setDynamicSuperProperties:^NSDictionary<NSString *,id> * _Nonnull{
        return @{@"dynamicsuperkey":@"dynamicsupervalue",@"level":@"level-2"};
    }];
}

+ (void)testTimedEvent {
    [TDAnalytics timeEvent:@"TimedEvent"];
}

+ (void)testTrackEventEnd {
    [TDAnalytics track:@"TimedEvent"];
}

+ (void)testIdentify {
    [TDAnalytics setDistinctId:@"testIdentify1"];
}

+ (void)testFlush {
    [TDAnalytics flush];
}

+ (void)testAgent {
    [TDAnalytics addWebViewUserAgent];
}

@end
