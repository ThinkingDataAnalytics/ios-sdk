//
//  TAAutoTrackEvent.m
//  ThinkingSDK
//
//  Created by 杨雄 on 2022/6/15.
//

#import "TAAutoTrackEvent.h"
#import "ThinkingAnalyticsSDKPrivate.h"
#import "TDPresetProperties+TDDisProperties.h"

@implementation TAAutoTrackEvent

- (NSMutableDictionary *)jsonObject {
    NSMutableDictionary *dict = [super jsonObject];    
    // 重新处理自动采集事件的时长，主要有 app_start， app_end
    // app_start app_end 事件是自动采集管理类采集到的。存在以下问题：自动采集管理类 和 timeTracker事件时长管理类 都是通过监听appLifeCycle的通知来做出处理，所以不在一个精确的统一的时间点。会存在有微小误差，需要消除。
    // 测试下来，误差都小于0.01s.
    CGFloat minDuration = 0.01;
    if (![TDPresetProperties disableDuration]) {
        if (self.foregroundDuration > minDuration) {
            self.properties[@"#duration"] = @([NSString stringWithFormat:@"%.3f", self.foregroundDuration].floatValue);
        }
    }
    if (![TDPresetProperties disableBackgroundDuration]) {
        if (self.backgroundDuration > minDuration) {
            self.properties[@"#background_duration"] = @([NSString stringWithFormat:@"%.3f", self.backgroundDuration].floatValue);
        }
    }
    
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
