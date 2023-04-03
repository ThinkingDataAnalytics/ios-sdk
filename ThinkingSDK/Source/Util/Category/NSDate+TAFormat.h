//
//  NSDate+TAFormat.h
//  ThinkingSDK
//
//  Created by 杨雄 on 2022/6/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDate (TAFormat)

/// 传入时区，获取时区偏移
/// @param timeZone 时区
- (double)ta_timeZoneOffset:(NSTimeZone *)timeZone;

/// 格式化 NSDate 为字符串
/// @param timeZone 时区
/// @param formatString 格式
- (NSString *)ta_formatWithTimeZone:(NSTimeZone *)timeZone formatString:(NSString *)formatString;

@end

NS_ASSUME_NONNULL_END
