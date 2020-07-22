//
//  TDEventModel.m
//  ThinkingSDK
//
//  Created by LiHuanan on 2020/7/22.
//  Copyright © 2020 thinkingdata. All rights reserved.
//

#import "TDEventModel.h"
#import "ThinkingAnalyticsSDKPrivate.h"

kEDEventTypeName const TD_EVENT_TYPE_TRACK              = @"track";
kEDEventTypeName const TD_EVENT_TYPE_TRACK_UPDATE       = @"track_update";
kEDEventTypeName const TD_EVENT_TYPE_TRACK_OVERWRITE    = @"track_overwrite";

@implementation TDEventModel

- (instancetype)init {
    if (self = [super init]) {
        self.persist = YES;
        self.autotrack = NO;
    }
    return self;
}

#pragma mark - Public

- (void)configTime:(NSDate *)time timeZone:(NSTimeZone *)timeZone {
    if (!time) {
        self.timeValueType = TDTimeValueTypeNone;
    } else {
        NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
        timeFormatter.dateFormat = kDefaultTimeFormat;
        timeFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        timeFormatter.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        if (timeZone) {
            self.timeValueType = TDTimeValueTypeAll;
            timeFormatter.timeZone = timeZone;
        } else {
            self.timeValueType = TDTimeValueTypeTimeOnly;
        }
        self.timeString = [timeFormatter stringFromDate:time];
    }
}

@end
