//
//  TAEventTracker.h
//  ThinkingSDK
//
//  Created by 杨雄 on 2022/6/19.
//

#import <Foundation/Foundation.h>

#if __has_include(<ThinkingSDK/TDConstant.h>)
#import <ThinkingSDK/TDConstant.h>
#else
#import "TDConstant.h"
#endif

#import "TDSecurityPolicy.h"
#import "ThinkingAnalyticsSDKPrivate.h"

NS_ASSUME_NONNULL_BEGIN

@class TAEventTracker;

@interface TAEventTracker : NSObject

/// 弱引用持有 ThinkingAnalyticsSDK ，用于获取相关配置参数
@property (nonatomic, weak) ThinkingAnalyticsSDK *thinkingAnalyticsInstance;

+ (dispatch_queue_t)td_networkQueue;

- (instancetype)initWithQueue:(dispatch_queue_t)queue instanceToken:(NSString *)instanceToken;

- (void)flush;

- (void)track:(NSDictionary *)event immediately:(BOOL)immediately;

- (NSInteger)saveEventsData:(NSDictionary *)data;

- (void)_asyncWithCompletion:(void(^)(void))completion;

/// 同步把网络队列中的数据发送完毕
- (void)syncSendAllData;

#pragma mark - UNAVAILABLE
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
