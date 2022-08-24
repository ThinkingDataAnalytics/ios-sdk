//
//  TDAutoTracker.h
//  ThinkingSDK
//
//  Created by wwango on 2021/10/13.
//  Copyright © 2021 thinkingdata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ThinkingAnalyticsSDK.h"
#import "TAAutoTrackEvent.h"

NS_ASSUME_NONNULL_BEGIN

@interface TDAutoTracker : NSObject

// 自动采集事件是否只发送一次
@property (atomic, assign) BOOL isOneTime;

// 事件是否立马发送
@property (atomic, assign) BOOL autoFlush;

// 事件的额外发送条件
@property (atomic, assign) BOOL additionalCondition;

/// 发送事件
/// @param instanceName 实例标识
/// @param event 事件
/// @param params params
- (void)trackWithInstanceTag:(NSString *)instanceName event:(TAAutoTrackEvent *)event params:(nullable NSDictionary *)params;


@end

NS_ASSUME_NONNULL_END
