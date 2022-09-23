//
//  TAAutoTrackSuperProperty.h
//  ThinkingSDK
//
//  Created by 杨雄 on 2022/6/19.
//

#import <Foundation/Foundation.h>
#import "TDConstant.h"

NS_ASSUME_NONNULL_BEGIN

@interface TAAutoTrackSuperProperty : NSObject

/// 设置公共事件属性
/// @param properties 公共事件属性
- (void)registerSuperProperties:(NSDictionary *)properties withType:(ThinkingAnalyticsAutoTrackEventType)type;

/// 获取公共属性
- (NSDictionary *)currentSuperPropertiesWithEventName:(NSString *)eventName;

/// 设置动态公共属性
/// @param dynamicSuperProperties 动态公共属性
- (void)registerDynamicSuperProperties:(NSDictionary<NSString *, id> *(^)(ThinkingAnalyticsAutoTrackEventType, NSDictionary *))dynamicSuperProperties;

/// 获取动态公共属性
- (NSDictionary *)obtainDynamicSuperPropertiesWithType:(ThinkingAnalyticsAutoTrackEventType)type currentProperties:(NSDictionary *)properties;

/// 清除所有公共事件属性
- (void)clearSuperProperties;

@end

NS_ASSUME_NONNULL_END
