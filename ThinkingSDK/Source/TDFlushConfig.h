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

@interface TDFlushConfig : NSObject

+ (TDFlushConfig *)sharedManagerWithAppid:(NSString *)appid withServerURL:(NSString *)url;
- (void)setNetworkType:(ThinkingAnalyticsNetworkType)type;

@property (atomic) NSInteger uploadInterval;
@property (atomic) NSInteger uploadSize;
@property (atomic) ThinkingNetworkType networkTypePolicy;

@end

NS_ASSUME_NONNULL_END
