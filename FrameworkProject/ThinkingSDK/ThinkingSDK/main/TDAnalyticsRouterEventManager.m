//
//  TDAnalyticsRouterEventManager.m
//  ThinkingSDK.default-TDCore-iOS
//
//  Created by 杨雄 on 2023/7/3.
//

#import "TDAnalyticsRouterEventManager.h"

static NSString * const kTDAnalyticsSDKName = @"ThinkingDataAnalytics";
static NSString * const kTDAnalyticsEventInit = @"TDAnalyticsInit";
static NSString * const kTDAnalyticsEventLogin = @"TDAnalyticsLogin";
static NSString * const kTDAnalyticsEventLogout = @"TDAnalyticsLogout";

@implementation TDAnalyticsRouterEventManager

+ (NSDictionary *)sdkInitEvent {
    NSDictionary *initEventParams = @{
        @"module": kTDAnalyticsSDKName,
        @"params": @{
            @"type": kTDAnalyticsEventInit,
        }
    };
    return initEventParams;
}

+ (NSDictionary *)sdkLoginEvent {
    NSDictionary *loginEventParams = @{
        @"module": kTDAnalyticsSDKName,
        @"params": @{
            @"type": kTDAnalyticsEventLogin,
        }
    };
    return loginEventParams;
}

@end
