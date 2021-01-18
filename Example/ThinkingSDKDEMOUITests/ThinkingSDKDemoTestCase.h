//
//  ThinkingSDKDemoTestCase.h
//  ThinkingSDKDEMOUITests
//
//  Created by Hale on 2020/11/26.
//  Copyright © 2020 thinking. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <ThinkingSDK/ThinkingSDK.h>
#import "ThinkingAnalyticsSDK+Hook.h"
#import "ThinkingSDKAPI.h"
NS_ASSUME_NONNULL_BEGIN
NSString* TA_APP_ID = @"22e445595b0f42bd8c5fe35bc44b88d6";
NSString* TA_SERVER_URL = @"https://receiver-ta-dev.thinkingdata.cn";
NSString* EVENT_NAME = @"test";
int FLUSH_INTERVAL = 5000;
int FLUSH_BULK_SIZE = 5;
int SIZE_OF_EVENT_DATA = 6;
int SIZE_OF_EVENT_DATA_LOGIN = 7;
int SIZE_OF_USER_DATA = 5;
int SIZE_OF_USER_DATA_LOGIN = 6;
int SIZE_OF_SYSTEM_PROPERTY = 12;
int WAIT_TIME = 1;
NSString* mVersionName = @"1.0";
typedef void(^MHandle)(NSInvocation *);

@interface ThinkingSDKDemoTestCase : XCTestCase
@property(strong,nonatomic) TDConfig *mConfig;
@property(strong,nonatomic)id mock;
@property(assign,nonatomic)MHandle handle;

+ (ThinkingAnalyticsSDK*)instance;
@end

NS_ASSUME_NONNULL_END
