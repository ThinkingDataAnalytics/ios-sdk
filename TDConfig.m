
#import "TDConfig.h"

static TDConfig * _defaultTDConfig;

@implementation TDConfig

+ (TDConfig *)defaultTDConfig {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _defaultTDConfig = [TDConfig new];
    });
    return _defaultTDConfig;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _trackRelaunchedInBackgroundEvents = NO;
    }
    return self;
}

@end
