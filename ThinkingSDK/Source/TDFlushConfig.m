#import "TDFlushConfig.h"
#import "TDLogging.h"
#import "ThinkingAnalyticsSDKPrivate.h"

@interface TDFlushConfig ()

@property (atomic, copy) NSString *appid;
@property (atomic, copy) NSString *configureURL;

@end

@implementation TDFlushConfig

+ (TDFlushConfig *)sharedManagerWithAppid:(NSString *)appid withServerURL:(NSString *)url {
    static dispatch_once_t onceToken;
    static TDFlushConfig *manager;
    dispatch_once(&onceToken, ^{
        manager = [[TDFlushConfig alloc] initWithAppid:appid withServerURL:url];
    });
    return manager;
}

- (instancetype)initWithAppid:(NSString *)appid withServerURL:(NSString *)url {
    self = [super init];
    if (self) {
        _appid = appid;
        _configureURL = [NSString stringWithFormat:@"%@/config", url];
    }
    return self;
}

@end
