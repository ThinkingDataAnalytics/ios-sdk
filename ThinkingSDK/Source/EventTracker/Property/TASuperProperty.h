//
//  TASuperProperty.h
//  ThinkingSDK
//
//  Created by 杨雄 on 2022/6/10.
//
//  本类静态公共属性相关的方法线程不安全；动态公共属性相关方法线程安全。

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TASuperProperty : NSObject

#pragma mark - UNAVAILABLE
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/// 初始化公共属性管理类
/// @param token 多实例的标识符
/// @param isLight 是否是轻实例
- (instancetype)initWithToken:(NSString *)token isLight:(BOOL)isLight;

/// 设置公共事件属性
/// @param properties 公共事件属性
- (void)registerSuperProperties:(NSDictionary *)properties;

/// 清除一条公共事件属性
/// @param property 公共事件属性名称
- (void)unregisterSuperProperty:(NSString *)property;

/// 清除所有公共事件属性
- (void)clearSuperProperties;

/// 获取公共属性
- (NSDictionary *)currentSuperProperties;

/// 设置动态公共属性
/// @param dynamicSuperProperties 动态公共属性
- (void)registerDynamicSuperProperties:(NSDictionary<NSString *, id> *(^ _Nullable)(void))dynamicSuperProperties;

/// 获取动态公共属性
- (NSDictionary *)obtainDynamicSuperProperties;

@end

NS_ASSUME_NONNULL_END
