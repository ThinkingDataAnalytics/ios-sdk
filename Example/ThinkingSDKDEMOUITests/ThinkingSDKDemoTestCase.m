//
//  ThinkingSDKDemoTestCase.m
//  ThinkingSDKDEMOUITests
//
//  Created by Hale on 2020/11/26.
//  Copyright © 2020 thinking. All rights reserved.
//

#import "ThinkingSDKDemoTestCase.h"
ThinkingAnalyticsSDK* instance;
@implementation ThinkingSDKDemoTestCase
+ (ThinkingAnalyticsSDK*)instance
{
    if(instance == nil)
    {
        
//        _mConfig = [TDConfig new];
//        _mConfig.appid = TA_APP_ID;
//        _mConfig.configureURL = TA_SERVER_URL;
//        _mConfig.trackRelaunchedInBackgroundEvents = true;
        instance = [ThinkingAnalyticsSDK startWithAppId:TA_APP_ID withUrl:TA_SERVER_URL];
        [ThinkingAnalyticsSDK setLogLevel:TDLoggingLevelDebug];
        [ThinkingSDKAPI setInstance:instance];
    }
    return instance;
}
@end
