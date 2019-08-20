
#ifndef TDConfigPrivate_h
#define TDConfigPrivate_h

#import "TDConfig.h"
#import "ThinkingAnalyticsSDK.h"

typedef NS_OPTIONS(NSInteger, ThinkingNetworkType) {
    ThinkingNetworkTypeNONE     = 0,
    ThinkingNetworkType2G       = 1 << 0,
    ThinkingNetworkType3G       = 1 << 1,
    ThinkingNetworkType4G       = 1 << 2,
    ThinkingNetworkTypeWIFI     = 1 << 3,
    ThinkingNetworkTypeALL      = 0xFF,
};

@interface TDConfig ()

+ (TDConfig *)defaultTDConfig;
- (void)setNetworkType:(ThinkingAnalyticsNetworkType)type;
@property (assign, nonatomic) ThinkingAnalyticsAutoTrackEventType autoTrackEventType;
@property (assign, nonatomic) ThinkingNetworkType networkTypePolicy;
@property (assign, nonatomic) NSInteger uploadInterval;
@property (assign, nonatomic) NSInteger uploadSize;
@property (atomic, copy) NSString *appid;
@property (atomic, copy) NSString *configureURL;

@end


#endif /* TDConfigPrivate_h */
