//
//  ThinkingAnalyticsCocoAPI.h
//  CocosGame
//
//  Created by Hale Wang on 2021/4/1.
//

#import <Foundation/Foundation.h>
#import "TDConfig.h"
#import "TDPresetProperties.h"
@class ThinkingAnalyticsSDK;
NS_ASSUME_NONNULL_BEGIN
@interface ThinkingAnalyticsCocosAPI : NSObject
+ (ThinkingAnalyticsSDK *)sharedInstance:(NSString *)appid server:(NSString *)server;
+ (ThinkingAnalyticsSDK *)sharedInstance:(TDConfig *)config;
+ (void)track:(NSString *)eventName appid:(NSString *)appid;
+ (void)track:(NSString *)eventName properties:(nullable NSDictionary *)properties appid:(NSString *)appid;
+ (void)track:(NSString *)eventName properties:(nullable NSDictionary *)properties extraId:(NSString *)extraId type:(int)type appid:(NSString *)appid;
+ (void)timeEvent:(NSString *)eventName appid:(NSString *)appid;
+ (void)login:(NSString *)accountID appid:(NSString *)appid;
+ (void)logout:(NSString *)appid;
+ (void)identify:(NSString *)distinctId appid:(NSString *)appid;
+ (NSString *)getDistinctId:(NSString *)appid;
+ (void)user_set:(NSDictionary *)userProperties appid:(NSString *)appid;
+ (void)user_setOnce:(NSDictionary *)userProperties appid:(NSString *)appid;
+ (void)user_add:(NSDictionary *)userProperties appid:(NSString *)appid;
+ (void)user_append:(NSDictionary *)userProperties appid:(NSString *)appid;
+ (void)user_delete:(NSString *)appid;
+ (void)user_unset:(NSString *)propertyName appid:(NSString *)appid;
+ (void)setSuperProperties:(NSDictionary *)supperProperties appid:(NSString *)appid;
+ (NSDictionary*)getSuperProperties:(NSString *)appid;
+ (void)clearSuperProperties:(NSString *)appid;
+ (void)unsetSuperProperty:(NSString *)supperPropertyName appid:(NSString *)appid;
+ (void)enableAutoTrack:(NSString *)appid;
+ (void)flush:(NSString *)appid;

+ (void)enableTracking:(BOOL)enabled appid:(NSString *)appid;
+ (void)optOutTrackingAndDeleteUser:(NSString *)appid;
+ (void)optOutTracking:(NSString *)appid;
+ (void)optInTracking:(NSString *)appid;
+ (NSString*)createLightInstance:(NSString *)appid;

+ (TDPresetProperties*)getPresetProperties:(NSString *)appid;
+ (void)calibrateTimeWithNtp:(NSString *)ntpServer;
+ (void)calibrateTime:(long)timestamp;
+ (void)enableTrackLog:(BOOL)enableLog;
+ (NSString*)getDeviceId;
+ (void)setCustomerLibInfoWithLibName:(NSString *)libName libVersion:(nonnull NSString *)libVersion;
+ (NSString*)currentAppId:(NSString*)appId;
+ (nullable NSString *)getLocalRegion;

+ (void)setTrackStatus: (int)status appid:(NSString *)appid;
+ (void)enableThirdPartySharing:(int)type customMap:(NSDictionary<NSString *, NSObject *> *)customMap appid:(NSString *)appid;
+ (void)user_uniqAppend:(NSDictionary<NSString *, NSArray *> *)properties appid:(NSString *)appid;
+ (void)enableAutoTrack:(NSString *)appid customMap:(NSDictionary *)customMap;
+ (void)enableAutoTrack:(NSString *)appid eventType:(int)eventType customMap:(NSDictionary *)customMap;

@end

NS_ASSUME_NONNULL_END
