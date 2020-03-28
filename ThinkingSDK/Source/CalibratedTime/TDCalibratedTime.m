#import "TDCalibratedTime.h"

@implementation TDCalibratedTime

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

+ (instancetype)sharedInstanceWithTimeInterval:(NSTimeInterval)timestamp {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] initWithInterval:timestamp];
    });
    return sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        self.serverTime = [[NSDate date] timeIntervalSince1970];
        self.systemUptime = [[NSProcessInfo processInfo] systemUptime];
    }

    return self;
}

- (instancetype)initWithInterval:(NSTimeInterval)timestamp {
    if (self = [super init]) {
        self.serverTime = timestamp;
        self.systemUptime = [[NSProcessInfo processInfo] systemUptime];
    }

    return self;
}

@end
