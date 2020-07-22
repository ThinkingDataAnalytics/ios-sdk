//
//  TDEventModel.h
//  ThinkingSDK
//
//  Created by LiHuanan on 2020/7/22.
//  Copyright © 2020 thinkingdata. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSInteger, TimeValueType) {
    TDTimeValueTypeNone      = 0,
    TDTimeValueTypeTimeOnly  = 1 << 0,
    TDTimeValueTypeAll       = 1 << 1,
};

typedef NSString *kEDEventTypeName;

/// @"track"
FOUNDATION_EXTERN kEDEventTypeName const TD_EVENT_TYPE_TRACK;

/// @"track_update"
FOUNDATION_EXTERN kEDEventTypeName const TD_EVENT_TYPE_TRACK_UPDATE;

/// @"track_overwrite"
FOUNDATION_EXTERN kEDEventTypeName const TD_EVENT_TYPE_TRACK_OVERWRITE;


@interface TDEventModel : NSObject

@property (nonatomic, copy) NSString *eventID;
@property (nonatomic, copy) NSString *eventName;
@property (nonatomic, copy) kEDEventTypeName eventType;
@property (nonatomic, copy) NSString *firstCheckID;

@property (nonatomic, strong) NSDictionary *properties;

@property (nonatomic, assign) BOOL autotrack;
@property (nonatomic, assign) BOOL persist;

- (void)configTime:(NSDate *)time timeZone:(NSTimeZone * _Nullable)timeZone;

@end

NS_ASSUME_NONNULL_END
