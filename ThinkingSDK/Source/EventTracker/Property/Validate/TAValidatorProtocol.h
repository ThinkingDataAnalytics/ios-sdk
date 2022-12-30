//
//  TAValidatorProtocol.h
//  ThinkingSDK
//
//  Created by 杨雄 on 2022/7/1.
//

#ifndef TAValidatorProtocol_h
#define TAValidatorProtocol_h

#import <Foundation/Foundation.h>

#if __has_include(<ThinkingSDK/TDLogging.h>)
#import <ThinkingSDK/TDLogging.h>
#else
#import "TDLogging.h"
#endif

#define TAPropertyError(errorCode, errorMsg) \
    [NSError errorWithDomain:@"ThinkingAnalyticsErrorDomain" \
                        code:errorCode \
                    userInfo:@{NSLocalizedDescriptionKey:errorMsg}] \


/// 属性名字的验证器协议，用来验证属性名
@protocol TAPropertyKeyValidating <NSObject>

- (void)ta_validatePropertyKeyWithError:(NSError **)error;

@end

/// 属性值的验证器协议，用来验证属性值
@protocol TAPropertyValueValidating <NSObject>

- (void)ta_validatePropertyValueWithError:(NSError **)error;

@end

/// 事件属性的验证器协议，用来验证某一条属性的key-value
@protocol TAEventPropertyValidating <NSObject>

- (void)ta_validateKey:(NSString *)key value:(id)value error:(NSError **)error;

@end

#endif /* TAValidatorProtocol_h */
