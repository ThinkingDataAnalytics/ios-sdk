
#import "TDConfig.h"
#import "TDConfigPrivate.h"
#import "TDNetwork.h"
#import "ThinkingAnalyticsSDKPrivate.h"

static NSString * const TA_USER_UPLOADINTERVAL = @"thinkingdata_uploadInterval";
static NSString * const TA_USER_UPLOADSIZE = @"thinkingdata_uploadSize";
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
        _autoTrackEventType = ThinkingAnalyticsEventTypeNone;
        _networkTypePolicy = ThinkingNetworkType3G | ThinkingNetworkType4G | ThinkingNetworkTypeWIFI;
        [self getBatchSizeAndInterval];
    }
    return self;
}

- (void)updateConfig {
    TDNetwork *network = [[TDNetwork alloc] initWithServerURL:[NSURL URLWithString:self.configureURL] withAutomaticData:nil];
    [network fetchFlushConfig:self.appid handler:^(NSDictionary * _Nonnull result, NSError * _Nullable error) {
        if(!error) {
            NSInteger uploadInterval = [[[result copy] objectForKey:@"sync_interval"] integerValue];
            NSInteger uploadSize = [[[result copy] objectForKey:@"sync_batch_size"] integerValue];
            if(uploadInterval != self->_uploadInterval || uploadSize != self->_uploadSize) {
                if(uploadInterval > 0) {
                    self->_uploadInterval = uploadInterval;
                    [[NSUserDefaults standardUserDefaults] setInteger:uploadInterval forKey:TA_USER_UPLOADINTERVAL];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    [ThinkingAnalyticsSDK restartFlushTimer];
                }
                if(uploadSize > 0) {
                    self->_uploadSize = uploadSize;
                    [[NSUserDefaults standardUserDefaults] setInteger:uploadSize forKey:TA_USER_UPLOADSIZE];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
            }
        }
    }];
}

- (void)getBatchSizeAndInterval {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger interval = [userDefaults integerForKey:TA_USER_UPLOADINTERVAL];
    if (interval <= 0) {
        _uploadInterval = 60;
    } else {
        _uploadInterval = interval;
    }
    NSInteger size = [userDefaults integerForKey:TA_USER_UPLOADSIZE];
    if (size <= 0) {
        _uploadSize = 100;
    } else {
        _uploadSize = size;
    }
}

- (void)setNetworkType:(ThinkingAnalyticsNetworkType)type {
    if (type == TDNetworkTypeDefault) {
        _networkTypePolicy = ThinkingNetworkTypeWIFI | ThinkingNetworkType3G | ThinkingNetworkType4G;
    } else if (type == TDNetworkTypeOnlyWIFI) {
        _networkTypePolicy = ThinkingNetworkTypeWIFI;
    } else if (type == TDNetworkTypeALL) {
        _networkTypePolicy = ThinkingNetworkTypeWIFI | ThinkingNetworkType3G | ThinkingNetworkType4G | ThinkingNetworkType2G;
    }
}

- (id)copyWithZone:(NSZone *)zone {
    TDConfig *config = [[[self class] allocWithZone:zone] init];
    config.trackRelaunchedInBackgroundEvents = self.trackRelaunchedInBackgroundEvents;
    config.autoTrackEventType = self.autoTrackEventType;
    config.networkTypePolicy = self.networkTypePolicy;
    
    return config;
}

@end
