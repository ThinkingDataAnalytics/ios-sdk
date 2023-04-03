//
//  TAPropertyValidator.h
//  Adjust
//
//  Created by 杨雄 on 2022/6/10.
//

#import <Foundation/Foundation.h>
#import "TAValidatorProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface TAPropertyValidator : NSObject

/// 验证事件名字或者属性名字
/// @param name 名字
/// @param error 错误
+ (void)validateEventOrPropertyName:(NSString *)name withError:(NSError **)error;

+ (void)validateBaseEventPropertyKey:(NSString *)key value:(NSString *)value error:(NSError **)error;

+ (void)validateNormalTrackEventPropertyKey:(NSString *)key value:(NSString *)value error:(NSError **)error;

+ (void)validateAutoTrackEventPropertyKey:(NSString *)key value:(NSString *)value error:(NSError **)error;


/// 验证属性
/// @param properties 属性
+ (NSMutableDictionary *)validateProperties:(NSDictionary *)properties;

/// 验证属性，提供一个自定义的验证器
/// @param properties 属性
/// @param validator 验证器
+ (NSMutableDictionary *)validateProperties:(NSDictionary *)properties validator:(id<TAEventPropertyValidating>)validator;

@end

NS_ASSUME_NONNULL_END
