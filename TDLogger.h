//
//  TDLogger.h
//  TDAnalyticsSDK
//
//  Created by thinkingdata on 2017/6/22.
//  Copyright © 2017年 thinkingdata. All rights reserved.
//

#import <UIKit/UIKit.h>

static inline void TDSDKLog(NSString *format, ...) {
    __block va_list arg_list;
    va_start (arg_list, format);
    NSString *formattedString = [[NSString alloc] initWithFormat:format arguments:arg_list];
    va_end(arg_list);
    NSLog(@"[ThinkingAnalytics] %@", formattedString);
}

#define MYTDSDKLog(fmt, ...)  NSLog((@"[func :%s]" fmt), __FUNCTION__, ##__VA_ARGS__);

#define TDSDKError(...) TDSDKLog(__VA_ARGS__)

#if (TDLogEnable)
#define TDSDKDebug(...) TDSDKLog(__VA_ARGS__)
#else
#define TDSDKDebug(...)
#endif

