//
//  ThinkingAnalyticsCocoAPI.h
//  CocosGame
//
//  Created by Hale Wang on 2021/4/1.
//

#import <Foundation/Foundation.h>
@class ThinkingAnalyticsSDK;
NS_ASSUME_NONNULL_BEGIN
@interface ThinkingAnalyticsCocosAPI : NSObject
+ (ThinkingAnalyticsSDK*)shareInstance:(NSString*)appid server:(NSString*)server;
+ (void)track:(NSString*) eventName;
+ (void)track:(NSString *)eventName properties:(nullable NSDictionary *)propertieDict;
+ (void)track:(NSString*)eventName properties:(nullable NSDictionary*)properties extraId:(NSString*)extraId type:(int)type;
+ (void)timeEvent:(NSString*)eventName;
+ (void)login:(NSString*)accountID;
+ (void)logout;
+ (void)identify:(NSString*)distinctId;
+ (NSString*)getDistinctId;
+ (void)user_set:(NSDictionary*)userProperties;
+ (void)user_setOnce:(NSDictionary*)userProperties;
+ (void)user_add:(NSDictionary*)userProperties;
+ (void)user_append:(NSDictionary*)userProperties;
+ (void)user_delete;
+ (void)user_unset:(NSString*)propertyName;
+ (void)setSuperProperties:(NSDictionary*)supperProperties;
+ (void)clearSuperProperties;
+ (void)unsetSuperProperty:(NSString*)supperPropertyName;
+ (void)enableAutoTrack;
+ (void)flush;
+ (NSString*)getDeviceId;
+ (void)enableTracking:(BOOL)enabled;
+ (void)optOutTrackingAndDeleteUser;
+ (void)optOutTracking;
+ (void)optInTracking;
+ (void)enableTrackLog:(BOOL)enableLog;
@end

NS_ASSUME_NONNULL_END
