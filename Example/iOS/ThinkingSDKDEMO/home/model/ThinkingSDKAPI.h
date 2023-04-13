//
//  ThinkingSDKAPI.h
//  ThinkingSDKDEMO
//
//  Created by syj on 2019/6/24.
//  Copyright © 2019 thinking. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ThinkingSDK/ThinkingSDK.h>
NS_ASSUME_NONNULL_BEGIN

@interface ThinkingSDKAPI : NSObject

+ (void)testTrack;
+ (void)testTrackWithProperty;
+ (void)testTrackWithTimezone;
+ (void)testUserSet;
+ (void)testUserUnset;
+ (void)testUserSetonce;
+ (void)testUserDel;
+ (void)testUserAdd;
+ (void)testUserAppend;
+ (void)testLogin;
+ (void)testLogout;
+ (void)testSetsuper;
+ (void)testUnsetsuper;
+ (void)testClearsuper;
+ (void)testSetDynamicsuper;
+ (void)testTimedEvent;
+ (void)testTrackEventEnd;
+ (void)testIdentify;
+ (void)testEnable;
+ (void)testDisEnable;
+ (void)optOutTracking;
+ (void)optInTracking;
+ (void)testSaveonly;
+ (void)testFlush;

+ (void)testTrackWithDefaultFirstCheckID;
+ (void)testTrackWithFirstCheckID;
+ (void)testTrackUpdate;
+ (void)testTrackOverwrite;

+ (void)testChangeLibNameAndLibVersion;
+ (void)setInstance:(ThinkingAnalyticsSDK*)instance;
+ (ThinkingAnalyticsSDK*)getInstance;
@end

NS_ASSUME_NONNULL_END
