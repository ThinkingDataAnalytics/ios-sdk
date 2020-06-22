#import <Foundation/Foundation.h>

#import "ThinkingAnalyticsSDKPrivate.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^TDFlushConfigBlock)(NSDictionary *result, NSError * _Nullable error);

@interface TDNetwork : NSObject <NSURLSessionTaskDelegate, NSURLSessionDataDelegate>

@property (nonatomic, copy) NSString *appid;
@property (nonatomic, strong) NSURL *serverURL;
@property (nonatomic, strong) NSURL *serverDebugURL;
@property (nonatomic, strong) NSDictionary *automaticData;
@property (nonatomic, assign) ThinkingAnalyticsDebugMode debugMode;
@property (nonatomic, strong) TDSecurityPolicy *securityPolicy;
@property (nonatomic, copy) TDURLSessionDidReceiveAuthenticationChallengeBlock sessionDidReceiveAuthenticationChallenge;

- (BOOL)flushEvents:(NSArray<NSDictionary *> *)events;
- (void)fetchRemoteConfig:(NSString *)appid handler:(TDFlushConfigBlock)handler;
- (int)flushDebugEvents:(NSDictionary *)record withAppid:(NSString *)appid;

@end

NS_ASSUME_NONNULL_END
