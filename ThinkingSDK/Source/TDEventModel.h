
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSInteger, TimeValueType) {
    TDTimeValueTypeNone      = 0,
    TDTimeValueTypeTimeOnly  = 1 << 0,
    TDTimeValueTypeAll       = 1 << 1,
};

typedef NSString *kEDEventTypeName;

FOUNDATION_EXTERN kEDEventTypeName const TD_EVENT_TYPE_TRACK; /// @"track"

FOUNDATION_EXTERN kEDEventTypeName const TD_EVENT_TYPE_TRACK_UPDATE; /// @"track_update"

FOUNDATION_EXTERN kEDEventTypeName const TD_EVENT_TYPE_TRACK_OVERWRITE; /// @"track_overwrite"


@interface TDEventModel : NSObject

@property (nonatomic, copy) NSString *eventName;
@property (nonatomic, copy) kEDEventTypeName eventType; // Default is TD_EVENT_TYPE_TRACK

/**
 额外参数
 当 eventType 为 TD_EVENT_TYPE_TRACK 时, 会添加此字段为 #first_check_id
 当 eventType 为 TD_EVENT_TYPE_TRACK_UPDATE 或 TD_EVENT_TYPE_TRACK_OVERWRITE 时, 为添加此字段为 #event_id
 */
@property (nonatomic, copy) NSString *extraID;

@property (nonatomic, strong) NSDictionary *properties;

@property (nonatomic, assign) BOOL persist;

- (void)configTime:(NSDate *)time timeZone:(NSTimeZone * _Nullable)timeZone;

@end

NS_ASSUME_NONNULL_END
