//
//  ThinkingAnalyticsCocoAPI.m
//  CocosGame
//
//  Created by Hale Wang on 2021/4/1.
//

#import "ThinkingAnalyticsCocosAPI.h"
#import "ThinkingAnalyticsSDK.h"
static ThinkingAnalyticsSDK* instance;
#define LIB_NAME @"Cocos2d-x"
#define LIB_VERSION @"1.0"
@implementation ThinkingAnalyticsCocosAPI
+(ThinkingAnalyticsSDK*)currentInstance
{
    return  instance;
}
+ (ThinkingAnalyticsSDK*)shareInstance:(NSString*)appid server:(NSString*)server
{
    [ThinkingAnalyticsSDK setCustomerLibInfoWithLibName:LIB_NAME libVersion:LIB_VERSION];
    instance = [ThinkingAnalyticsSDK startWithAppId:appid withUrl:server];
    return instance;
}
+ (void)track:(NSString*) eventName
{
    [[self currentInstance] track:eventName];
}
+ (void)track:(NSString *)eventName properties:(nullable NSDictionary *)propertie
{
    [[self currentInstance] track:eventName properties:propertie];
}
+ (void)track:(NSString*)eventName properties:(nullable NSDictionary*)properties extraId:(NSString*)extraId type:(int)type
{
    
    TDEventModel *eventModel = nil;
    switch (type) {
        case 1:
        {
            if(extraId != nil && extraId.length > 0)
            {
                eventModel = [[TDFirstEventModel alloc] initWithEventName:eventName firstCheckID:extraId];
            }else
            {
                eventModel = [[TDFirstEventModel alloc] initWithEventName:eventName];
            }
        }
            break;
        case 2:
        {
            eventModel = [[TDUpdateEventModel alloc] initWithEventName:eventName eventID:extraId];
        }
            break;
        case  3:
        {
            eventModel = [[TDOverwriteEventModel alloc] initWithEventName:eventName eventID:extraId];
        }
            break;
        default:
            break;
    }
    if(eventModel != nil)
    {
        eventModel.properties = properties;
        [[self currentInstance] trackWithEventModel:eventModel];
    }
}
+ (void)timeEvent:(NSString*)eventName
{
    [[self currentInstance]timeEvent:eventName];
}
+ (void)login:(NSString *)accountID
{
    [[self currentInstance] login:accountID];
}
+ (void)logout
{
    [[self currentInstance] logout];
}
+ (void)identify:(NSString*)distinctId
{
    [[self currentInstance] identify:distinctId];
}
+ (NSString*)getDistinctId
{
    return  [[self currentInstance] getDistinctId];
}
+ (void)user_set:(NSDictionary*)userProperties
{
    [[self currentInstance] user_set:userProperties];
}
+ (void)user_setOnce:(NSDictionary*)userProperties
{
    [[self currentInstance]user_setOnce:userProperties];
}
+ (void)user_add:(NSDictionary*)userProperties
{
    [[self currentInstance] user_add:userProperties];
}
+ (void)user_append:(NSDictionary *)userProperties
{
    [[self currentInstance] user_append:userProperties];
}
+ (void)user_delete
{
    [[self currentInstance] user_delete];
}
+ (void)user_unset:(NSString*)propertyName
{
    [[self currentInstance] user_unset:propertyName];
}
+ (void)setSuperProperties:(NSDictionary*)supperProperties
{
    [[self currentInstance] setSuperProperties:supperProperties];
}
+ (void)clearSuperProperties
{
    [[self currentInstance] clearSuperProperties];
}
+ (void)unsetSuperProperty:(NSString*)supperPropertyName
{
    [[self currentInstance] unsetSuperProperty:supperPropertyName];
}
+ (void)enableAutoTrack
{
     [[ThinkingAnalyticsSDK sharedInstance] enableAutoTrack:ThinkingAnalyticsEventTypeAppStart | ThinkingAnalyticsEventTypeAppInstall |
     ThinkingAnalyticsEventTypeAppEnd];
}
+ (void)flush
{
    [[self currentInstance] flush];
}
+ (NSString*)getDeviceId
{
    return [self currentInstance].getDeviceId;
}
+ (void)enableTracking:(BOOL)enabled
{
    [[self currentInstance] enableTracking:enabled];
}
+ (void)optOutTrackingAndDeleteUser
{
    [[self currentInstance] optOutTrackingAndDeleteUser];
}
+ (void)optOutTracking
{
    [[self currentInstance] optOutTracking];
}
+ (void)optInTracking
{
    [[self currentInstance] optInTracking];
}
+ (void)enableTrackLog:(BOOL)enableLog
{
    [ThinkingAnalyticsSDK setLogLevel:TDLoggingLevelDebug];
}
@end
