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
 SDK VERSION = 2.8.3.1
 ThinkingData API
 
 ## Initialization
 
 ```objective-c
 ThinkingAnalyticsSDK *instance = [ThinkingAnalyticsSDK startWithAppId:@"YOUR_APPID" withUrl:@"YOUR_SERVER_URL"];
 ```
 
 ## Track Event
 
 ```objective-c
 instance.track("some_event");
 ```
or
 ```objective-c
 [[ThinkingAnalyticsSDK sharedInstanceWithAppid:@"YOUR_APPID"] track:@"some_event"];
 ```
 If you only have one instance in your project, you can also use
 ```objective-c
 [[ThinkingAnalyticsSDK sharedInstance] track:@"some_event"];
 ```
 ## Detailed Documentation
 http://doc.thinkingdata.cn/tgamanual/installation/ios_sdk_installation.html

 */
@interface ThinkingAnalyticsSDK : NSObject

#pragma mark - Tracking

/**
 Get default instance

 @return SDK instance
 */
+ (nullable ThinkingAnalyticsSDK *)sharedInstance;

/**
  Get one instance according to appid or instanceName

  @param appid APP ID or instanceName
  @return SDK instance
  */
+ (nullable ThinkingAnalyticsSDK *)sharedInstanceWithAppid:(NSString *)appid;

/**
  Initialization method

  @param appId appId
  @param url server url
  @return one instance
  */
+ (ThinkingAnalyticsSDK *)startWithAppId:(NSString *)appId withUrl:(NSString *)url;

/**
  Initialization method

  @param config initialization configuration
  @return one instance
  */
+ (ThinkingAnalyticsSDK *)startWithConfig:(nullable TDConfig *)config;

/**
  Initialization method

  @param appId appId
  @param url server url
  @param config initialization configuration object
  @return one instance
  */
+ (ThinkingAnalyticsSDK *)startWithAppId:(NSString *)appId withUrl:(NSString *)url withConfig:(nullable TDConfig *)config;


#pragma mark - Action Track

/**
 Track Events

 @param event         event name
 */
- (void)track:(NSString *)event;


/**
 Track Events

 @param event         event name
 @param propertieDict event properties
 */
- (void)track:(NSString *)event properties:(nullable NSDictionary *)propertieDict;

/**
 Track Events

 @param event         event name
 @param propertieDict event properties
 @param time          event trigger time
 */
- (void)track:(NSString *)event properties:(nullable NSDictionary *)propertieDict time:(NSDate *)time __attribute__((deprecated("please use track:properties:time:timeZone: method")));

/**
 Track Events
 
  @param event event name
  @param propertieDict event properties
  @param time event trigger time
  @param timeZone event trigger time time zone
  */
- (void)track:(NSString *)event properties:(nullable NSDictionary *)propertieDict time:(NSDate *)time timeZone:(NSTimeZone *)timeZone;

- (void)trackWithEventModel:(TDEventModel *)eventModel;

/// Get the events collected in the App Extension and report them
/// @param appGroupId The app group id required for data sharing
- (void)trackFromAppExtensionWithAppGroupId:(NSString *)appGroupId;

#pragma mark -

/**
 Timing Events
 */
- (void)timeEvent:(NSString *)event;

/**
 Identify
 */
- (void)identify:(NSString *)distinctId;

/**
 Get Distinctid
 */
- (NSString *)getDistinctId;

/**
 Get sdk version
 */
+ (NSString *)getSDKVersion;

/**
 Login

 @param accountId account ID
 */
- (void)login:(NSString *)accountId;

/**
 Logout
 clear account ID
 */
- (void)logout;

/**
 User_Set

 @param properties user properties
 */
- (void)user_set:(NSDictionary *)properties;

/**
 User_Set

 @param properties user properties
 @param time event trigger time
*/
- (void)user_set:(NSDictionary *)properties withTime:(NSDate * _Nullable)time;

/**
 User_Unset
 
 @param propertyName user properties
 */
- (void)user_unset:(NSString *)propertyName;

/**
 User_Unset

 @param propertyName user properties
 @param time event trigger time
*/
- (void)user_unset:(NSString *)propertyName withTime:(NSDate * _Nullable)time;

/**
 User_SetOnce

 @param properties user properties
 */
- (void)user_setOnce:(NSDictionary *)properties;

/**
 User_SetOnce

 @param properties user properties
 @param time event trigger time
*/
- (void)user_setOnce:(NSDictionary *)properties withTime:(NSDate * _Nullable)time;

/**
 User_Add

 @param properties user properties
 */
- (void)user_add:(NSDictionary *)properties;

/**
 User_Add

 @param properties user properties
 @param time event trigger time
*/
- (void)user_add:(NSDictionary *)properties withTime:(NSDate * _Nullable)time;

/**
 User_Add

  @param propertyName  propertyName
  @param propertyValue propertyValue
 */
- (void)user_add:(NSString *)propertyName andPropertyValue:(NSNumber *)propertyValue;

/**
 User_Add

 @param propertyName  propertyName
 @param propertyValue propertyValue
 @param time event trigger time
*/
- (void)user_add:(NSString *)propertyName andPropertyValue:(NSNumber *)propertyValue withTime:(NSDate * _Nullable)time;

/**
 User_Delete
 */
- (void)user_delete;

/**
 User_Delete
 
 @param time event trigger time
 */
- (void)user_delete:(NSDate * _Nullable)time;

/**
 User_Append
 
 @param properties user properties
*/
- (void)user_append:(NSDictionary<NSString *, NSArray *> *)properties;

/**
 User_Append
 
 @param properties user properties
 @param time event trigger time
*/
- (void)user_append:(NSDictionary<NSString *, NSArray *> *)properties withTime:(NSDate * _Nullable)time;

/**
 User_UniqAppend
 
 @param properties user properties
*/
- (void)user_uniqAppend:(NSDictionary<NSString *, NSArray *> *)properties;

/**
 User_UniqAppend
 
 @param properties user properties
 @param time event trigger time
*/
- (void)user_uniqAppend:(NSDictionary<NSString *, NSArray *> *)properties withTime:(NSDate * _Nullable)time;

+ (void)setCustomerLibInfoWithLibName:(NSString *)libName libVersion:(NSString *)libVersion;

/**
 Static Super Properties
 */
- (void)setSuperProperties:(NSDictionary *)properties;

/**
 Unset Super Property
 */
- (void)unsetSuperProperty:(NSString *)property;

/**
 Clear Super Properties
 */
- (void)clearSuperProperties;

/**
 Get Static Super Properties
 */
- (NSDictionary *)currentSuperProperties;

/**
 Dynamic super properties
 */
- (void)registerDynamicSuperProperties:(NSDictionary<NSString *, id> *(^)(void))dynamicSuperProperties;

/**
 Get Preset Properties
 */
- (TDPresetProperties *)getPresetProperties;

/**
 Set the network conditions for uploading. By default, the SDK will set the network conditions as 3G, 4G and Wifi to upload data
 */
- (void)setNetworkType:(ThinkingAnalyticsNetworkType)type;

#if TARGET_OS_IOS

/**
 Enable Auto-Tracking

 @param eventType Auto-Tracking type
 
 detailed documentation http://doc.thinkingdata.cn/tgamanual/installation/ios_sdk_installation/ios_sdk_autotrack.html
 */
- (void)enableAutoTrack:(ThinkingAnalyticsAutoTrackEventType)eventType;

/**
 Enable Auto-Tracking

 @param eventType  Auto-Tracking type
 @param properties properties
 */
- (void)enableAutoTrack:(ThinkingAnalyticsAutoTrackEventType)eventType properties:(NSDictionary *)properties;

/**
 Enable Auto-Tracking

 @param eventType  Auto-Tracking type
 @param callback callback
 In the callback, eventType indicates the type of automatic collection, properties indicates the event properties before storage, and this block can return a dictionary for adding new properties
 */
- (void)enableAutoTrack:(ThinkingAnalyticsAutoTrackEventType)eventType callback:(NSDictionary *(^)(ThinkingAnalyticsAutoTrackEventType eventType, NSDictionary *properties))callback;

/**
 Set and Update the value of a custom property for Auto-Tracking
 
 @param eventType  A list of ThinkingAnalyticsAutoTrackEventType, indicating the types of automatic collection events that need to be enabled
 @param properties properties
 */
- (void)setAutoTrackProperties:(ThinkingAnalyticsAutoTrackEventType)eventType properties:(NSDictionary *)properties;

/**
 Ignore the Auto-Tracking of a page

 @param controllers Ignore the name of the UIViewController
 */
- (void)ignoreAutoTrackViewControllers:(NSArray *)controllers;

/**
 Ignore the Auto-Tracking  of click event

 @param aClass ignored controls  Class
 */
- (void)ignoreViewType:(Class)aClass;

#endif

//MARK: -

/**
 Get DeviceId
 */
- (NSString *)getDeviceId;

/**
 H5 is connected with the native APP SDK and used in conjunction with the addWebViewUserAgent interface

 @param webView webView
 @param request NSURLRequest request
 @return YES：Process this request NO: This request has not been processed
 
 detailed documentation http://doc.thinkingdata.cn/tgamanual/installation/h5_app_integrate.html
 */
- (BOOL)showUpWebView:(id)webView WithRequest:(NSURLRequest *)request;

/**
 When connecting data with H5, you need to call this interface to configure UserAgent
 */
- (void)addWebViewUserAgent;

/**
 Set Log level

 */
+ (void)setLogLevel:(TDLoggingLevel)level;

/**
 Flush data
 */
- (void)flush;

/// update status
/// @param status Data reporting status
- (void)setTrackStatus: (TATrackStatus)status;

- (void)enableTracking:(BOOL)enabled DEPRECATED_MSG_ATTRIBUTE("Please use instance method setTrackStatus: TATrackStatusPause");

- (void)optOutTracking DEPRECATED_MSG_ATTRIBUTE("Please use instance method setTrackStatus: TATrackStatusStop");

- (void)optOutTrackingAndDeleteUser DEPRECATED_MSG_ATTRIBUTE("Please use instance method setTrackStatus: TATrackStatusStop");

- (void)optInTracking DEPRECATED_MSG_ATTRIBUTE("Please use instance method setTrackStatus: TATrackStatusNormal");

/**
 Create a light instance
 */
- (ThinkingAnalyticsSDK *)createLightInstance;

+ (void)calibrateTimeWithNtp:(NSString *)ntpServer;

+ (void)calibrateTime:(NSTimeInterval)timestamp;

- (NSString *)getTimeString:(NSDate *)date;

#if TARGET_OS_IOS
- (void)enableThirdPartySharing:(TAThirdPartyShareType)type;

- (void)enableThirdPartySharing:(TAThirdPartyShareType)type customMap:(NSDictionary<NSString *, NSObject *> *)customMap;
#endif

+ (nullable NSString *)getLocalRegion;

@end

NS_ASSUME_NONNULL_END
