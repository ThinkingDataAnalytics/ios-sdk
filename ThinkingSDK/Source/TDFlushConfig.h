#import <Foundation/Foundation.h>
#import "ThinkingAnalyticsSDK.h"

NS_ASSUME_NONNULL_BEGIN

@interface TDFlushConfig : NSObject

+ (TDFlushConfig *)sharedManagerWithAppid:(NSString *)appid withServerURL:(NSString *)url;

@property (atomic) NSInteger uploadInterval;
@property (atomic) NSInteger uploadSize;

@end

NS_ASSUME_NONNULL_END
