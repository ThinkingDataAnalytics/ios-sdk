//
//  TDConfigPrivate.h
//  Pods
//
//  Created by 杨雄 on 2023/8/15.
//

#if __has_include(<ThinkingSDK/TDConfig.h>)
#import <ThinkingSDK/TDConfig.h>
#else
#import "TDConfig.h"
#endif

#ifndef TDConfigPrivate_h
#define TDConfigPrivate_h

@interface TDConfig ()
@property (nonatomic, assign) BOOL innerEnableEncrypt;

#if TARGET_OS_IOS
@property (nonatomic, strong) TDSecretKey *innerSecretKey;
#endif

- (ThinkingNetworkType)getNetworkType;
- (void)innerUpdateConfig:(void(^)(NSDictionary *dict))block;
- (NSString *)innerGetMapInstanceToken;

@end

#endif /* TDConfigPrivate_h */
