//
//  ThinkingAnalyticsSDK+Hook.h
//  ThinkingSDKDEMOUITests
//
//  Created by Hale on 2020/11/25.
//  Copyright © 2020 thinking. All rights reserved.
//

#import <ThinkingSDK/ThinkingSDK.h>
#define kSENDDATA  @"kSENDDATA"
NS_ASSUME_NONNULL_BEGIN
typedef void(^HookHanlde)(NSDictionary*);
@interface ThinkingAnalyticsSDK (Hook)

@end

NS_ASSUME_NONNULL_END
