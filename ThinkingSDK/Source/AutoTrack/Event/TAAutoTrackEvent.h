//
//  TAAutoTrackEvent.h
//  ThinkingSDK
//
//  Created by 杨雄 on 2022/6/15.
//

#import "TATrackEvent.h"
#import "TDConstant.h"

NS_ASSUME_NONNULL_BEGIN

@interface TAAutoTrackEvent : TATrackEvent

/// 用于记录自动采集事件的动态公共属性，动态公共属性需要在事件发生的当前线程获取
@property (nonatomic, strong) NSDictionary *autoDynamicSuperProperties;

/// 用于记录自动采集事件的静态公共属性
@property (nonatomic, strong) NSDictionary *autoSuperProperties;

/// 返回自动采集类型
- (ThinkingAnalyticsAutoTrackEventType)autoTrackEventType;

@end

NS_ASSUME_NONNULL_END
