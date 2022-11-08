//
//  TAAutoTrackSuperProperty.m
//  ThinkingSDK
//
//  Created by 杨雄 on 2022/6/19.
//

#import "TAAutoTrackSuperProperty.h"
#import "ThinkingAnalyticsSDKPrivate.h"

@interface TAAutoTrackSuperProperty ()
@property (atomic, strong) NSMutableDictionary<NSString *, NSDictionary *> *eventProperties;
@property (nonatomic, copy) NSDictionary *(^dynamicSuperProperties)(ThinkingAnalyticsAutoTrackEventType type, NSDictionary *properties);

@end

@implementation TAAutoTrackSuperProperty

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.eventProperties = [NSMutableDictionary dictionary];
    }
    return self;
}

/// 设置公共事件属性
/// @param properties 公共事件属性
- (void)registerSuperProperties:(NSDictionary *)properties withType:(ThinkingAnalyticsAutoTrackEventType)type {
    // 自动采集，枚举值和事件名 映射关系
    NSDictionary<NSNumber *, NSString *> *autoTypes = @{
        @(ThinkingAnalyticsEventTypeAppStart) : TD_APP_START_EVENT,
        @(ThinkingAnalyticsEventTypeAppEnd) : TD_APP_END_EVENT,
        @(ThinkingAnalyticsEventTypeAppClick) : TD_APP_CLICK_EVENT,
        @(ThinkingAnalyticsEventTypeAppInstall) : TD_APP_INSTALL_EVENT,
        @(ThinkingAnalyticsEventTypeAppViewCrash) : TD_APP_CRASH_EVENT,
        @(ThinkingAnalyticsEventTypeAppViewScreen) : TD_APP_VIEW_EVENT
    };
    
    NSArray<NSNumber *> *typeKeys = autoTypes.allKeys;
    for (NSInteger i = 0; i < typeKeys.count; i++) {
        NSNumber *key = typeKeys[i];
        ThinkingAnalyticsAutoTrackEventType eventType = key.integerValue;
        if ((type & eventType) == eventType) {
            NSString *eventName = autoTypes[key];
            if (properties) {
                // 覆盖之前的，先取出之前的属性进行覆盖；之前没有该属性就直接设置
                NSDictionary *oldProperties = self.eventProperties[eventName];
                if (oldProperties && [oldProperties isKindOfClass:[NSDictionary class]]) {
                    NSMutableDictionary *mutiOldProperties = [oldProperties mutableCopy];
                    [mutiOldProperties addEntriesFromDictionary:properties];
                    self.eventProperties[eventName] = mutiOldProperties;
                } else {
                    self.eventProperties[eventName] = properties;
                }
                
                // 后台自启动事件，保证和appStart事件一样的属性
                if (eventType == ThinkingAnalyticsEventTypeAppStart) {
                    NSDictionary *startParam = self.eventProperties[TD_APP_START_EVENT];
                    if (startParam && [startParam isKindOfClass:[NSDictionary class]]) {
                        self.eventProperties[TD_APP_START_BACKGROUND_EVENT] = startParam;
                    }
                }
            }
        }
    }
}

/// 获取公共属性
- (NSDictionary *)currentSuperPropertiesWithEventName:(NSString *)eventName {
    NSDictionary *autoEventProperty = [self.eventProperties objectForKey:eventName];
    // 验证属性
    NSDictionary *validProperties = [TAPropertyValidator validateProperties:[autoEventProperty copy]];
    return validProperties;
}

/// 设置动态公共属性
/// @param dynamicSuperProperties 动态公共属性
- (void)registerDynamicSuperProperties:(NSDictionary<NSString *, id> *(^)(ThinkingAnalyticsAutoTrackEventType, NSDictionary *))dynamicSuperProperties {
    @synchronized (self) {
        self.dynamicSuperProperties = dynamicSuperProperties;
    }
}

/// 获取动态公共属性
- (NSDictionary *)obtainDynamicSuperPropertiesWithType:(ThinkingAnalyticsAutoTrackEventType)type currentProperties:(NSDictionary *)properties {
    @synchronized (self) {
        if (self.dynamicSuperProperties) {
            NSDictionary *result = self.dynamicSuperProperties(type, properties);
            // 验证属性
            NSDictionary *validProperties = [TAPropertyValidator validateProperties:[result copy]];
            return validProperties;
        }
        return nil;
    }
}

- (void)clearSuperProperties {
    self.eventProperties = [@{} mutableCopy];
}

//MARK: - Private Methods



@end
