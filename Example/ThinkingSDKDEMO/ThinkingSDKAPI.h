//
//  ThinkingSDKAPI.h
//  ThinkingSDKDEMO
//
//  Created by syj on 2019/6/24.
//  Copyright © 2019年 thinking. All rights reserved.
//

#import <Foundation/Foundation.h>

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
+ (void)testLogin;
+ (void)testLogout;
+ (void)testSetsuper;
+ (void)testUnsetsuper;
+ (void)testClearsuper;
+ (void)testTimedEvent;
+ (void)testTrackEventEnd;
+ (void)testIdentify;
+ (void)testEnable;
+ (void)testDisEnable;
+ (void)optOutTracking;
+ (void)optOutTrackingAndDeleteUser;
+ (void)optInTracking;
+ (void)testFlush;

@end

NS_ASSUME_NONNULL_END
