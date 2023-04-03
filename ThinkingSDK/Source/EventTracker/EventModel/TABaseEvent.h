//
//  TABaseEvent.h
//  ThinkingSDK
//
//  Created by 杨雄 on 2022/6/12.
//

#import <Foundation/Foundation.h>
#import "TAPropertyValidator.h"

NS_ASSUME_NONNULL_BEGIN

typedef NSString * kTAEventType;

typedef NS_OPTIONS(NSUInteger, TAEventType) {
    TAEventTypeNone = 0,
    TAEventTypeTrack = 1 << 0,
    TAEventTypeTrackFirst = 1 << 1,
    TAEventTypeTrackUpdate = 1 << 2,
    TAEventTypeTrackOverwrite = 1 << 3,
    TAEventTypeUserSet = 1 << 4,
    TAEventTypeUserUnset = 1 << 5,
    TAEventTypeUserAdd = 1 << 6,
    TAEventTypeUserDel = 1 << 7,
    TAEventTypeUserSetOnce = 1 << 8,
    TAEventTypeUserAppend = 1 << 9,
    TAEventTypeUserUniqueAppend = 1 << 10,
    TAEventTypeAll = 0xFFFFFFFF,
};

//extern kTAEventType const kTAEventTypeTrack;
//extern kTAEventType const kTAEventTypeTrackFirst;
//extern kTAEventType const kTAEventTypeTrackUpdate;
//extern kTAEventType const kTAEventTypeTrackOverwrite;
//extern kTAEventType const kTAEventTypeUserSet;
//extern kTAEventType const kTAEventTypeUserUnset;
//extern kTAEventType const kTAEventTypeUserAdd;
//extern kTAEventType const kTAEventTypeUserDel;
//extern kTAEventType const kTAEventTypeUserSetOnce;
//extern kTAEventType const kTAEventTypeUserAppend;
//extern kTAEventType const kTAEventTypeUserUniqueAppend;

typedef NS_OPTIONS(NSInteger, TAEventTimeValueType) {
    TAEventTimeValueTypeNone = 0, // 用户没有指定时间
    TAEventTimeValueTypeTimeOnly = 1 << 0, // 用户只指定时间，没有指定时区
    TAEventTimeValueTypeTimeAndZone = 1 << 1, // 用户指定时间+时区
};

@interface TABaseEvent : NSObject<TAEventPropertyValidating>
@property (nonatomic, assign) TAEventType eventType;
@property (nonatomic, copy) NSString *uuid;
@property (nonatomic, copy) NSString *accountId;
@property (nonatomic, copy) NSString *distinctId;
@property (nonatomic, strong) NSDate *time;
@property (nonatomic, strong) NSTimeZone *timeZone;
@property (nonatomic, strong, readonly) NSDateFormatter *timeFormatter;
/// 传入的时间类型
@property (nonatomic, assign) TAEventTimeValueType timeValueType;
@property (nonatomic, strong) NSMutableDictionary *properties;
/// 是否需要立即上传
@property (nonatomic, assign) BOOL immediately;

/// 标识是否暂停网络上报，默认 NO 上报网络正常流程；YES 入本地数据库但不网络上报
@property (atomic, assign, getter=isTrackPause) BOOL trackPause;
/// 标识SDK是否继续采集事件
@property (nonatomic, assign) BOOL isEnabled;
/// 标识SDK是否停止
@property (atomic, assign) BOOL isOptOut;

- (instancetype)initWithType:(TAEventType)type;

/// 验证事件对象是否合法
/// @param error 错误信息
- (void)validateWithError:(NSError **)error;

/// 用于上报的json对象
- (NSMutableDictionary *)jsonObject;

/// 将dict数据源中，NSDate格式的value值格式化为字符串
/// @param dict 数据源
- (NSMutableDictionary *)formatDateWithDict:(NSDictionary *)dict;

- (NSString *)eventTypeString;

/// 获取事件类型
+ (TAEventType)typeWithTypeString:(NSString *)typeString;

@end

NS_ASSUME_NONNULL_END
