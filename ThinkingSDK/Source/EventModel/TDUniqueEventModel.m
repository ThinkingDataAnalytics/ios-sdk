#import "TDUniqueEventModel.h"
#import "ThinkingAnalyticsSDKPrivate.h"

@implementation TDUniqueEventModel

- (instancetype)initWithEventName:(NSString *)eventName {
    return [self initWithEventName:eventName eventType:TD_EVENT_TYPE_TRACK_UNIQUE];
}

- (instancetype)initWithEventName:(NSString *)eventName firstCheckID:(NSString *)firstCheckID {
    if (self = [self initWithEventName:eventName eventType:TD_EVENT_TYPE_TRACK_UNIQUE]) {
        self.extraID = firstCheckID;
    }
    return self;
}

@end
