//
//  ThinkingAnalyticsCocoAPI.m
//  CocosGame
//
//  Created by Hale Wang on 2021/4/1.
//

#import "ThinkingAnalyticsCocosAPI.h"
#import "ThinkingAnalyticsSDK.h"
#import "TDLogging.h"
static ThinkingAnalyticsSDK* instance;

static NSMutableDictionary* sInstances;
static NSMutableArray*      sAppIds;
@implementation ThinkingAnalyticsCocosAPI
+ (NSString*)currentAppId:(NSString*)appId
{
    NSString *token = @"";
    if((appId == nil || appId.length == 0) && sAppIds.count > 0)
    {
        token = self.appIds[0];
    }else if(appId.length > 0){
        token = appId;
    }
    return token;
}
+(ThinkingAnalyticsSDK *)currentInstance:(NSString *)appid
{
    ThinkingAnalyticsSDK *instance;
    NSString *token = [self currentAppId:appid];
    if(token.length > 0)
    {
        instance = [self.instances objectForKey:token];
    }
    if(instance == nil)
    {
        TDLogInfo(@"Instance does not exist");
    }
    return  instance;
}
+ (BOOL)isInit
{
    return self.appIds.count > 0;
}
+ (NSMutableArray* )appIds
{
    if(sAppIds == nil)
    {
        sAppIds = [NSMutableArray new];
    }
    return  sAppIds;
}
+ (NSMutableDictionary *)instances
{
    if(sInstances == nil)
    {
        sInstances = [NSMutableDictionary new];
    }
    return sInstances;
}
+ (void)setCustomerLibInfoWithLibName:(NSString *)libName libVersion:(nonnull NSString *)libVersion
{
    [ThinkingAnalyticsSDK setCustomerLibInfoWithLibName:libName libVersion:libVersion];
}
+ (ThinkingAnalyticsSDK *)sharedInstance:(NSString *)appid server:(NSString *)server
{
    TDConfig *config = [[TDConfig alloc] initWithAppId:appid serverUrl:server];
    return [self sharedInstance:config];
}
+ (ThinkingAnalyticsSDK *)sharedInstance:(TDConfig *)config
{
    NSString* name = config.name.length == 0 ? config.appid : config.name;
    ThinkingAnalyticsSDK *instance = self.instances[name];
    if(instance == nil)
    {
        instance = [ThinkingAnalyticsSDK startWithConfig:config];
        [self.instances setValue:instance forKey:name];
        [self.appIds addObject:name];
    }
    return instance;
}
+ (NSString*)createLightInstance:(NSString *)appid
{
    if([self currentInstance:appid] != nil)
    {
        ThinkingAnalyticsSDK *lightInstance =  [[self currentInstance:appid] createLightInstance];
        NSString *uuid = [NSUUID UUID].UUIDString;
        self.instances[uuid] = lightInstance;
        return uuid;
    }else
    {
        return @"";
    }
}
+ (TDPresetProperties *)getPresetProperties:(NSString *)appid
{
    if([self currentInstance:appid] != nil)
    {
        return [[self currentInstance:appid] getPresetProperties];
    }else
    {
        return [TDPresetProperties new];
    }
}

+ (void)track:(NSString*)eventName appid:(NSString*)appid
{
    if([self currentInstance:appid] != nil)
    {
        [[self currentInstance:appid] track:eventName];
    }
}

+ (void)track:(NSString *)eventName properties:(nullable NSDictionary *)properties appid:(NSString *)appid
{
    if([self currentInstance:appid] != nil)
    {
        [[self currentInstance:appid] track:eventName properties:properties];
    }
    
}

+ (void)track:(NSString *)eventName properties:(nullable NSDictionary *)properties extraId:(NSString *)extraId type:(int)type appid:(NSString *)appid
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
        if([self currentInstance:appid] != nil)
        {
           [[self currentInstance:appid] trackWithEventModel:eventModel];
        }
    }
}

+ (void)timeEvent:(NSString *)eventName appid:(NSString *)appid
{
    if([self currentInstance:appid] != nil)
    {
        [[self currentInstance:appid] timeEvent:eventName];
    }
}

+ (void)login:(NSString *)accountID appid:(NSString *)appid
{
    if([self currentInstance:appid] != nil)
    {
        [[self currentInstance:appid] login:accountID];
    }
}

+ (void)logout:(NSString *)appid
{
    if([self currentInstance:appid] != nil)
    {
        [[self currentInstance:appid] logout];
    }
}

+ (void)identify:(NSString *)distinctId appid:(NSString *)appid
{
   if([self currentInstance:appid] != nil)
   {
       [[self currentInstance:appid] identify:distinctId];
   }
}

+ (NSString *)getDistinctId:(NSString *)appid
{
    if([self currentInstance:appid] != nil)
    {
        return  [[self currentInstance:appid] getDistinctId];
    }
    return @"";
}

+ (void)user_set:(NSDictionary *)userProperties appid:(NSString *)appid
{
    if([self currentInstance:appid] != nil)
    {
       [[self currentInstance:appid] user_set:userProperties];
    }
}

+ (void)user_setOnce:(NSDictionary *)userProperties appid:(NSString *)appid
{
    if([self currentInstance:appid] != nil)
    {
        [[self currentInstance:appid] user_setOnce:userProperties];
    }
}

+ (void)user_add:(NSDictionary *)userProperties appid:(NSString *)appid
{
    if([self currentInstance:appid] != nil)
    {
        [[self currentInstance:appid] user_add:userProperties];
    }
}

+ (void)user_append:(NSDictionary *)userProperties appid:(NSString *)appid
{
    if([self currentInstance:appid] != nil)
    {
        [[self currentInstance:appid]user_append:userProperties];
    }
}

+ (void)user_delete:(NSString *)appid
{
    if([self currentInstance:appid] != nil)
    {
        [[self currentInstance:appid] user_delete];
    }
}

+ (void)user_unset:(NSString *)propertyName appid:(NSString *)appid
{
    if([self currentInstance:appid] != nil)
    {
        [[self currentInstance:appid] user_unset:propertyName];
    }
}

+ (void)setSuperProperties:(NSDictionary *)supperProperties appid:(NSString *)appid
{
    if([self currentInstance:appid] != nil)
    {
        [[self currentInstance:appid] setSuperProperties:supperProperties];
    }
}

+ (NSDictionary *)getSuperProperties:(NSString *)appid
{
    if([self currentInstance:appid] != nil)
    {
        return [[self currentInstance:appid] currentSuperProperties];
    }
    
    return @{};
    
}
+ (void)clearSuperProperties:(NSString *)appid
{
    if([self currentInstance:appid] != nil)
    {
        [[self currentInstance:appid] clearSuperProperties];
    }
}

+ (void)unsetSuperProperty:(NSString *)supperPropertyName appid:(NSString *)appid
{
    if([self currentInstance:appid] != nil)
    {
        [[self currentInstance:appid] unsetSuperProperty:supperPropertyName];
    }
}

+ (void)enableAutoTrack:(NSString *)appid
{
    if([self currentInstance:appid] != nil)
    {
        [[self currentInstance:appid] enableAutoTrack:ThinkingAnalyticsEventTypeAppStart | ThinkingAnalyticsEventTypeAppInstall |
         ThinkingAnalyticsEventTypeAppEnd |
         ThinkingAnalyticsEventTypeAppViewCrash];
    }
}

+ (void)flush:(NSString *)appid
{
    if([self currentInstance:appid] != nil)
    {
        [[self currentInstance:appid] flush];
    }
}

+ (void)enableTracking:(BOOL)enabled appid:(NSString *)appid
{
    if([self currentInstance:appid] != nil)
    {
        [[self currentInstance:appid] enableTracking:enabled];
    }
}

+ (void)optOutTrackingAndDeleteUser:(NSString *)appid
{
    if([self currentInstance:appid] != nil)
    {
       [[self currentInstance:appid] optOutTrackingAndDeleteUser];
    }
}

+ (void)optOutTracking:(NSString *)appid
{
    if([self currentInstance:appid] != nil)
    {
        [[self currentInstance:appid] optOutTracking];
    }
    
}

+ (void)optInTracking:(NSString *)appid
{
    if([self currentInstance:appid] != nil)
    {
        [[self currentInstance:appid] optInTracking];
    }
    
}

+ (void)enableTrackLog:(BOOL)enableLog
{
    [ThinkingAnalyticsSDK setLogLevel:TDLoggingLevelDebug];
}
+ (void)calibrateTime:(long)timestamp
{
    [ThinkingAnalyticsSDK calibrateTime:timestamp];
}
+ (void)calibrateTimeWithNtp:(NSString *)ntpServer
{
    [ThinkingAnalyticsSDK calibrateTimeWithNtp:ntpServer];
}
+ (NSString *)getDeviceId
{
    if([self currentInstance:@""] != nil)
    {
        return [self currentInstance:@""].getDeviceId;
    }
    return @"";
}
+ (NSString *)getLocalRegion
{
//    return [ThinkingAnalyticsSDK getLocalRegion];
    return @"";
}

+ (void)setTrackStatus: (int)status appid:(NSString *)appid {
    if([self currentInstance:appid] != nil)
    {
        [[self currentInstance:appid] setTrackStatus:status];
    }
}

+ (void)enableThirdPartySharing:(int)type customMap:(NSDictionary<NSString *, NSObject *> *)customMap appid:(NSString *)appid {
    if([self currentInstance:appid] != nil)
    {
        [[self currentInstance:appid] enableThirdPartySharing:type customMap:customMap];
    }
}


+ (void)user_uniqAppend:(NSDictionary<NSString *, NSArray *> *)properties appid:(NSString *)appid {
    if([self currentInstance:appid] != nil)
    {
        [[self currentInstance:appid] user_uniqAppend:properties];
    }
}

+ (void)enableAutoTrack:(NSString *)appid customMap:(NSDictionary *)customMap
{
    if([self currentInstance:appid] != nil)
    {
        [[self currentInstance:appid] enableAutoTrack:ThinkingAnalyticsEventTypeAppStart | ThinkingAnalyticsEventTypeAppInstall |
         ThinkingAnalyticsEventTypeAppEnd | ThinkingAnalyticsEventTypeAppViewCrash properties:customMap];
    }
}

+ (void)enableAutoTrack:(NSString *)appid eventType:(int)eventType customMap:(NSDictionary *)customMap
{
    if([self currentInstance:appid] != nil)
    {
        [[self currentInstance:appid] enableAutoTrack:eventType properties:customMap];
    }
}

@end
