#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ThinkingExceptionHandler : NSObject

+ (instancetype)sharedHandler;
- (void)addThinkingInstance:(ThinkingAnalyticsSDK *)instance;

@end

NS_ASSUME_NONNULL_END
