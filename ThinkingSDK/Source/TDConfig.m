#import "TDConfig.h"

#import "TDNetwork.h"
#import "ThinkingAnalyticsSDKPrivate.h"
#import "TDSecurityPolicy.h"

#define TDSDKSETTINGS_PLIST_SETTING_IMPL(TYPE, PLIST_KEY, GETTER, SETTER, DEFAULT_VALUE, ENABLE_CACHE) \
static TYPE *g_##PLIST_KEY = nil; \
+ (TYPE *)GETTER \
{ \
  if (!g_##PLIST_KEY && ENABLE_CACHE) { \
    g_##PLIST_KEY = [[[NSUserDefaults standardUserDefaults] objectForKey:@#PLIST_KEY] copy]; \
  } \
  if (!g_##PLIST_KEY) { \
    g_##PLIST_KEY = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@#PLIST_KEY] copy] ?: DEFAULT_VALUE; \
  } \
  return g_##PLIST_KEY; \
} \
+ (void)SETTER:(TYPE *)value { \
  g_##PLIST_KEY = [value copy]; \
  if (ENABLE_CACHE) { \
    if (value) { \
      [[NSUserDefaults standardUserDefaults] setObject:value forKey:@#PLIST_KEY]; \
    } else { \
      [[NSUserDefaults standardUserDefaults] removeObjectForKey:@#PLIST_KEY]; \
    } \
  } \
}

static TDConfig * _defaultTDConfig;

@implementation TDConfig

TDSDKSETTINGS_PLIST_SETTING_IMPL(NSNumber, ThinkingSDKMaxCacheSize, _maxNumEventsNumber, _setMaxNumEventsNumber, @10000, NO);
TDSDKSETTINGS_PLIST_SETTING_IMPL(NSNumber, ThinkingSDKExpirationDays, _expirationDaysNumber, _setExpirationDaysNumber, @10, NO);

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
        _securityPolicy = [TDSecurityPolicy defaultPolicy];
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

#pragma mark - NSCopying
- (id)copyWithZone:(NSZone *)zone {
    TDConfig *config = [[[self class] allocWithZone:zone] init];
    config.trackRelaunchedInBackgroundEvents = self.trackRelaunchedInBackgroundEvents;
    config.autoTrackEventType = self.autoTrackEventType;
    config.networkTypePolicy = self.networkTypePolicy;
    config.launchOptions = [self.launchOptions copyWithZone:zone];
    config.debugMode = self.debugMode;
    config.securityPolicy = [self.securityPolicy copyWithZone:zone];
    return config;
}

+ (NSInteger)maxNumEvents {
    NSInteger maxNumEvents = [self _maxNumEventsNumber].integerValue;
    if (maxNumEvents < 5000) {
        maxNumEvents = 5000;
    }
    return maxNumEvents;
}

+ (void)setMaxNumEvents:(NSInteger)maxNumEventsNumber {
    [self _setMaxNumEventsNumber:@(maxNumEventsNumber)];
}

+ (NSInteger)expirationDays {
    NSInteger maxNumEvents = [self _expirationDaysNumber].integerValue;
    return maxNumEvents >= 0 ? maxNumEvents : 10;
}

+ (void)setExpirationDays:(NSInteger)expirationDays {
    [self _setExpirationDaysNumber:@(expirationDays)];
}

@end
