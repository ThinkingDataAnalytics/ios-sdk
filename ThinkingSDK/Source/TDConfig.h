#import <Foundation/Foundation.h>

#import "ThinkingAnalyticsSDK.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSInteger, ThinkingNetworkType) {
    ThinkingNetworkTypeNONE     = 0,
    ThinkingNetworkType2G       = 1 << 0,
    ThinkingNetworkType3G       = 1 << 1,
    ThinkingNetworkType4G       = 1 << 2,
    ThinkingNetworkTypeWIFI     = 1 << 3,
    ThinkingNetworkTypeALL      = 0xFF,
};

@interface TDConfig () <NSCopying>

+ (TDConfig *)defaultTDConfig;
- (void)setNetworkType:(ThinkingAnalyticsNetworkType)type;
@property (assign, nonatomic) ThinkingAnalyticsAutoTrackEventType autoTrackEventType;
@property (assign, nonatomic) ThinkingNetworkType networkTypePolicy;
@property (assign, nonatomic) NSInteger uploadInterval;
@property (assign, nonatomic) NSInteger uploadSize;
@property (atomic, copy) NSString *appid;
@property (atomic, copy) NSString *configureURL;
- (void)updateConfig;

@end
NS_ASSUME_NONNULL_END
