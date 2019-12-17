#import "TDConfig.h"

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
    }
    return self;
}

- (void)updateConfig {
    TDNetwork *network = [[TDNetwork alloc] init];
    network.serverURL = [NSURL URLWithString:self.configureURL];
    [network fetchFlushConfig:self.appid handler:^(NSDictionary * _Nonnull result, NSError * _Nullable error) {
        if (!error) {
            NSInteger uploadInterval = [[result objectForKey:@"sync_interval"] integerValue];
            NSInteger uploadSize = [[result objectForKey:@"sync_batch_size"] integerValue];
            if (uploadInterval != [self->_uploadInterval integerValue] || uploadSize != [self->_uploadSize integerValue]) {
                if (uploadInterval > 0) {
                    self->_uploadInterval = [NSNumber numberWithInteger:uploadInterval];
                    [[ThinkingAnalyticsSDK sharedInstanceWithAppid:self.appid] archiveUploadInterval:self->_uploadInterval];
                    [[ThinkingAnalyticsSDK sharedInstanceWithAppid:self.appid] startFlushTimer];
                }
                if (uploadSize > 0) {
                    self->_uploadSize = [NSNumber numberWithInteger:uploadSize];
                    [[ThinkingAnalyticsSDK sharedInstanceWithAppid:self.appid] archiveUploadSize:self->_uploadSize];
                }
            }
        }
    }];
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
    config.launchOptions = [self.launchOptions copyWithZone:zone];
    config.debugMode = self.debugMode;
    return config;
}

@end
