#import <Foundation/Foundation.h>

#if TARGET_OS_IOS
#import <UIKit/UIKit.h>

#if __has_include(<ThinkingSDK/TAAutoTrackPublicHeader.h>)
#import <ThinkingSDK/TAAutoTrackPublicHeader.h>
#else
#import "TAAutoTrackPublicHeader.h"
#endif

#elif TARGET_OS_OSX
#import <AppKit/AppKit.h>
#endif

#if __has_include(<ThinkingSDK/TDFirstEventModel.h>)
#import <ThinkingSDK/TDFirstEventModel.h>
#else
#import "TDFirstEventModel.h"
#endif

#if __has_include(<ThinkingSDK/TDEditableEventModel.h>)
#import <ThinkingSDK/TDEditableEventModel.h>
#else
#import "TDEditableEventModel.h"
#endif


#if __has_include(<ThinkingSDK/TDConfig.h>)
#import <ThinkingSDK/TDConfig.h>
#else
#import "TDConfig.h"
#endif

#if __has_include(<ThinkingSDK/TDPresetProperties.h>)
#import <ThinkingSDK/TDPresetProperties.h>
#else
#import "TDPresetProperties.h"
#endif


NS_ASSUME_NONNULL_BEGIN

/**
 SDK VERSION = 2.8.3.2
 ThinkingData API
 
 ## 初始化API
 
 ```objective-c
 ThinkingAnalyticsSDK *instance = [ThinkingAnalyticsSDK startWithAppId:@"YOUR_APPID" withUrl:@"YOUR_SERVER_URL"];
 ```
 
 ## 事件埋点
 
 ```objective-c
 instance.track("some_event");
 ```
 或者
 ```objective-c
 [[ThinkingAnalyticsSDK sharedInstanceWithAppid:@"YOUR_APPID"] track:@"some_event"];
 ```
 如果项目中只有一个实例，也可以使用
 ```objective-c
 [[ThinkingAnalyticsSDK sharedInstance] track:@"some_event"];
 ```
 ## 详细文档
 http://doc.thinkingdata.cn/tgamanual/installation/ios_sdk_installation.html

 */
@interface ThinkingAnalyticsSDK : NSObject

#pragma mark - Tracking

/**
 获取实例

 @return SDK 实例
 */
+ (nullable ThinkingAnalyticsSDK *)sharedInstance;

/**
 根据 APPID 或者 instanceName 获取实例

 @param appid APP ID 或者 instanceName
 @return SDK 实例
 */
+ (nullable ThinkingAnalyticsSDK *)sharedInstanceWithAppid:(NSString *)appid;

/**
 初始化方法

 @param appId APP ID
 @param url 接收端地址
 @return SDK 实例
 */
+ (ThinkingAnalyticsSDK *)startWithAppId:(NSString *)appId withUrl:(NSString *)url;

/**
 初始化方法

 @param config 初始化配置
 @return SDK实例
 */
+ (ThinkingAnalyticsSDK *)startWithConfig:(nullable TDConfig *)config;

/**
 初始化方法

 @param appId APP ID
 @param url 接收端地址
 @param config 初始化配置
 @return SDK实例
 */
+ (ThinkingAnalyticsSDK *)startWithAppId:(NSString *)appId withUrl:(NSString *)url withConfig:(nullable TDConfig *)config;


#pragma mark - Action Track

/**
 自定义事件埋点

 @param event         事件名称
 */
- (void)track:(NSString *)event;


/**
 自定义事件埋点

 @param event         事件名称
 @param propertieDict 事件属性
 */
- (void)track:(NSString *)event properties:(nullable NSDictionary *)propertieDict;

/**
 自定义事件埋点

 @param event         事件名称
 @param propertieDict 事件属性
 @param time          事件触发时间
 */
- (void)track:(NSString *)event properties:(nullable NSDictionary *)propertieDict time:(NSDate *)time __attribute__((deprecated("使用 track:properties:time:timeZone: 方法传入")));

/**
 自定义事件埋点
 
 @param event         事件名称
 @param propertieDict 事件属性
 @param time          事件触发时间
 @param timeZone      事件触发时间时区
 */
- (void)track:(NSString *)event properties:(nullable NSDictionary *)propertieDict time:(NSDate *)time timeZone:(NSTimeZone *)timeZone;

- (void)trackWithEventModel:(TDEventModel *)eventModel;

/// 获取在App Extension 中采集的事件，并上报
/// @param appGroupId 数据共享所需要的 app group id
- (void)trackFromAppExtensionWithAppGroupId:(NSString *)appGroupId;

#pragma mark -

/**
 记录事件时长

 @param event 事件名称
 */
- (void)timeEvent:(NSString *)event;

/**
 设置访客ID

 @param distinctId 访客 ID
 */
- (void)identify:(NSString *)distinctId;

/**
 获取访客ID

 @return 获取访客 ID
 */
- (NSString *)getDistinctId;

/**
 获取SDK版本号

 @return 获取 SDK 版本号
 */
+ (NSString *)getSDKVersion;

/**
 设置账号 ID

 @param accountId 账号 ID
 */
- (void)login:(NSString *)accountId;

/**
 清空账号 ID
 */
- (void)logout;

/**
 设置用户属性

 @param properties 用户属性
 */
- (void)user_set:(NSDictionary *)properties;

/**
 设置用户属性

 @param properties 用户属性
 @param time 事件触发时间
*/
- (void)user_set:(NSDictionary *)properties withTime:(NSDate * _Nullable)time;

/**
 重置用户属性
 
 @param propertyName 用户属性
 */
- (void)user_unset:(NSString *)propertyName;

/**
 重置用户属性

 @param propertyName 用户属性
 @param time 事件触发时间
*/
- (void)user_unset:(NSString *)propertyName withTime:(NSDate * _Nullable)time;

/**
 设置单次用户属性

 @param properties 用户属性
 */
- (void)user_setOnce:(NSDictionary *)properties;

/**
 设置单次用户属性

 @param properties 用户属性
 @param time 事件触发时间
*/
- (void)user_setOnce:(NSDictionary *)properties withTime:(NSDate * _Nullable)time;

/**
 对数值类型用户属性进行累加操作

 @param properties 用户属性
 */
- (void)user_add:(NSDictionary *)properties;

/**
 对数值类型用户属性进行累加操作

 @param properties 用户属性
 @param time 事件触发时间
*/
- (void)user_add:(NSDictionary *)properties withTime:(NSDate * _Nullable)time;

/**
  对数值类型用户属性进行累加操作

  @param propertyName  属性名称
  @param propertyValue 属性值
 */
- (void)user_add:(NSString *)propertyName andPropertyValue:(NSNumber *)propertyValue;

/**
 对数值类型用户属性进行累加操作

 @param propertyName  属性名称
 @param propertyValue 属性值
 @param time 事件触发时间
*/
- (void)user_add:(NSString *)propertyName andPropertyValue:(NSNumber *)propertyValue withTime:(NSDate * _Nullable)time;

/**
 删除用户 该操作不可逆 需慎重使用
 */
- (void)user_delete;

/**
 删除用户 该操作不可逆 需慎重使用
 
 @param time 事件触发时间
 */
- (void)user_delete:(NSDate * _Nullable)time;

/**
 对 Array 类型的用户属性进行追加操作
 
 @param properties 用户属性
*/
- (void)user_append:(NSDictionary<NSString *, NSArray *> *)properties;

/**
 对 Array 类型的用户属性进行追加操作
 
 @param properties 用户属性
 @param time 事件触发时间
*/
- (void)user_append:(NSDictionary<NSString *, NSArray *> *)properties withTime:(NSDate * _Nullable)time;


- (void)user_uniqAppend:(NSDictionary<NSString *, NSArray *> *)properties;

- (void)user_uniqAppend:(NSDictionary<NSString *, NSArray *> *)properties withTime:(NSDate * _Nullable)time;

/**
 谨慎调用此接口, 此接口用于使用第三方框架或者游戏引擎的场景中, 更准确的设置上报方式.
 @param libName     对应事件表中 #lib预制属性, 默认为 "iOS".
 @param libVersion  对应事件表中 #lib_version 预制属性, 默认为当前SDK版本号.
 */
+ (void)setCustomerLibInfoWithLibName:(NSString *)libName libVersion:(NSString *)libVersion;

/**
 设置公共事件属性

 @param properties 公共事件属性
 */
- (void)setSuperProperties:(NSDictionary *)properties;

/**
 清除一条公共事件属性

 @param property 公共事件属性名称
 */
- (void)unsetSuperProperty:(NSString *)property;

/**
 清除所有公共事件属性
 */
- (void)clearSuperProperties;

/**
 获取公共属性

 @return 公共事件属性
 */
- (NSDictionary *)currentSuperProperties;

/**
 设置动态公共属性

 @param dynamicSuperProperties 动态公共属性
 */
- (void)registerDynamicSuperProperties:(NSDictionary<NSString *, id> *(^)(void))dynamicSuperProperties;

/**
 获取预置属性

 @return  获取预置属性
 */
- (TDPresetProperties *)getPresetProperties;

/**
  设置上传的网络条件，默认情况下，SDK 将会网络条件为在 3G、4G 及 Wifi 时上传数据

 @param type 上传数据的网络类型
 */
- (void)setNetworkType:(ThinkingAnalyticsNetworkType)type;

#if TARGET_OS_IOS

/**
 开启自动采集事件功能

 @param eventType 枚举 ThinkingAnalyticsAutoTrackEventType 的列表，表示需要开启的自动采集事件类型
 
 详细文档 http://doc.thinkingdata.cn/tgamanual/installation/ios_sdk_installation/ios_sdk_autotrack.html
 */
- (void)enableAutoTrack:(ThinkingAnalyticsAutoTrackEventType)eventType;

/**
 开启自动采集事件功能

 @param eventType 枚举 ThinkingAnalyticsAutoTrackEventType 的列表，表示需要开启的自动采集事件类型
 @param properties 自定义属性
 */
- (void)enableAutoTrack:(ThinkingAnalyticsAutoTrackEventType)eventType properties:(NSDictionary *)properties;

/**
 开启自动采集事件功能

 @param eventType 枚举 ThinkingAnalyticsAutoTrackEventType 的列表，表示需要开启的自动采集事件类型
 @param callback 事件回调
 回调中eventType表示自动采集类型，properties表示入库前的事件属性，该block可返回一个字典，用于新增属性
 */
- (void)enableAutoTrack:(ThinkingAnalyticsAutoTrackEventType)eventType callback:(NSDictionary *(^)(ThinkingAnalyticsAutoTrackEventType eventType, NSDictionary *properties))callback;

/**
 设置和更新自动采集事件的自定义属性的值
 
 @param eventType 枚举 ThinkingAnalyticsAutoTrackEventType 的列表，表示需要开启的自动采集事件类型
 @param properties 自定义属性
 */
- (void)setAutoTrackProperties:(ThinkingAnalyticsAutoTrackEventType)eventType properties:(NSDictionary *)properties;

/**
 忽略某个页面的自动采集事件

 @param controllers 忽略 UIViewController 的名称
 */
- (void)ignoreAutoTrackViewControllers:(NSArray *)controllers;

/**
 忽略某个类型控件的点击事件

 @param aClass 忽略的控件 Class
 */
- (void)ignoreViewType:(Class)aClass;

#endif

//MARK: -

/**
 获取设备 ID

 @return 设备 ID
 */
- (NSString *)getDeviceId;

/**
 H5 与原生 APP SDK 打通，配合 addWebViewUserAgent 接口使用

 @param webView 需要打通H5的控件
 @param request NSURLRequest 网络请求
 @return YES：处理此次请求 NO：未处理此次请求
 
 详细文档 http://doc.thinkingdata.cn/tgamanual/installation/h5_app_integrate.html
 */
- (BOOL)showUpWebView:(id)webView WithRequest:(NSURLRequest *)request;

/**
 与 H5 打通数据时需要调用此接口配置 UserAgent
 */
- (void)addWebViewUserAgent;

/**
 开启 Log 功能

 @param level 打印日志级别
 */
+ (void)setLogLevel:(TDLoggingLevel)level;

/**
 上报数据
 */
- (void)flush;

/// 数据上报状态
/// @param status 数据上报状态
- (void)setTrackStatus: (TATrackStatus)status;

/**
 暂停/开启上报

 @param enabled YES：开启上报 NO：暂停上报
 */
- (void)enableTracking:(BOOL)enabled DEPRECATED_MSG_ATTRIBUTE("Please use instance method setTrackStatus: TATrackStatusPause");

/**
 停止上报，后续的上报和设置都无效，数据将清空
 */
- (void)optOutTracking DEPRECATED_MSG_ATTRIBUTE("Please use instance method setTrackStatus: TATrackStatusStop");

/**
 停止上报，后续的上报和设置都无效，数据将清空，并且发送 user_del
 */
- (void)optOutTrackingAndDeleteUser DEPRECATED_MSG_ATTRIBUTE("Please use instance method setTrackStatus: TATrackStatusStop");

/**
 允许上报
 */
- (void)optInTracking DEPRECATED_MSG_ATTRIBUTE("Please use instance method setTrackStatus: TATrackStatusNormal");

/**
 创建轻实例

 @return SDK 实例
 */
- (ThinkingAnalyticsSDK *)createLightInstance;

/**
 使用指定NTP Server 校准时间
 @param ntpServer NTP Server
*/
+ (void)calibrateTimeWithNtp:(NSString *)ntpServer;

/**
 校准时间
 
 @param timestamp 当前时间戳，单位毫秒
*/
+ (void)calibrateTime:(NSTimeInterval)timestamp;

- (NSString *)getTimeString:(NSDate *)date;

#if TARGET_OS_IOS
- (void)enableThirdPartySharing:(TAThirdPartyShareType)type;

- (void)enableThirdPartySharing:(TAThirdPartyShareType)type customMap:(NSDictionary<NSString *, NSObject *> *)customMap;
#endif

// 获取系统的国家地区信息
+ (nullable NSString *)getLocalRegion;

@end

NS_ASSUME_NONNULL_END
