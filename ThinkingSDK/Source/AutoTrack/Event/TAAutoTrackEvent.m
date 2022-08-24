//
//  TAAutoTrackEvent.m
//  ThinkingSDK
//
//  Created by 杨雄 on 2022/6/15.
//

#import "TAAutoTrackEvent.h"
#import "ThinkingAnalyticsSDKPrivate.h"

@implementation TAAutoTrackEvent

- (NSMutableDictionary *)jsonObject {
    NSMutableDictionary *dict = [super jsonObject];
    [self.properties addEntriesFromDictionary:self.autoSuperProperties];
    [self.properties addEntriesFromDictionary:self.autoDynamicSuperProperties];
    return dict;
}

/// 根据eventName返回自动采集类型
- (ThinkingAnalyticsAutoTrackEventType)autoTrackEventType {
    if ([self.eventName isEqualToString:TD_APP_START_EVENT]) {
        return ThinkingAnalyticsEventTypeAppStart;
    } else if ([self.eventName isEqualToString:TD_APP_START_BACKGROUND_EVENT]) {
        return ThinkingAnalyticsEventTypeAppStart;
    } else if ([self.eventName isEqualToString:TD_APP_END_EVENT]) {
        return ThinkingAnalyticsEventTypeAppEnd;
    } else if ([self.eventName isEqualToString:TD_APP_VIEW_EVENT]) {
        return ThinkingAnalyticsEventTypeAppViewScreen;
    } else if ([self.eventName isEqualToString:TD_APP_CLICK_EVENT]) {
        return ThinkingAnalyticsEventTypeAppClick;
    } else if ([self.eventName isEqualToString:TD_APP_CRASH_EVENT]) {
        return ThinkingAnalyticsEventTypeAppViewCrash;
    } else if ([self.eventName isEqualToString:TD_APP_INSTALL_EVENT]) {
        return ThinkingAnalyticsEventTypeAppInstall;
    } else {
        return ThinkingAnalyticsEventTypeNone;
    }
}

- (void)ta_validateKey:(NSString *)key value:(id)value error:(NSError *__autoreleasing  _Nullable *)error {
    [TAPropertyValidator validateAutoTrackEventPropertyKey:key value:value error:error];
}

@end
