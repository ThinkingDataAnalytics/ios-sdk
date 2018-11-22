//
//  TDAgent.h
//  TDAnalyticsSDK
//
//  Created by thinkingdata on 2017/6/22.
//  Copyright © 2017年 thinkingdata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIView (ThinkingAnalytics)
- (nullable UIViewController *)viewController;

@property (copy,nonatomic) NSString* thinkingAnalyticsViewID;

@property (nonatomic,assign) BOOL thinkingAnalyticsIgnoreView;

@property (nonatomic,assign) BOOL thinkingAnalyticsAutoTrackAfterSendAction;

@property (strong,nonatomic) NSDictionary* thinkingAnalyticsViewProperties;

@property (nonatomic, weak, nullable) id thinkingAnalyticsDelegate;
@end

@protocol TDUIViewAutoTrackDelegate

@optional
-(NSDictionary *) thinkingAnalytics_tableView:(UITableView *)tableView autoTrackPropertiesAtIndexPath:(NSIndexPath *)indexPath;

@optional
-(NSDictionary *) thinkingAnalytics_collectionView:(UICollectionView *)collectionView autoTrackPropertiesAtIndexPath:(NSIndexPath *)indexPath;

@end

@protocol TDAutoTracker

@required
-(NSDictionary *)getTrackProperties;

@end


@protocol TDScreenAutoTracker<TDAutoTracker>

@required
-(NSString *) getScreenUrl;

@end

@interface UIImage (ThinkingAnalytics)
@property (nonatomic,copy) NSString* thinkingAnalyticsImageName;
@end

@interface ThinkingAnalyticsSDK : NSObject

+ (ThinkingAnalyticsSDK *)startWithAppId:(NSString *)appId withUrl:(NSString *)url;
+ (ThinkingAnalyticsSDK *)sharedInstance;

typedef NS_OPTIONS(NSInteger, ThinkingAnalyticsNetworkType) {
    TDNetworkTypeDefault  = 0,
    TDNetworkTypeOnlyWIFI = 1 << 0,
    TDNetworkTypeALL      = 1 << 1,
};

- (void)setNetworkType:(ThinkingAnalyticsNetworkType)type;

- (void)setSuperProperties:(NSDictionary *)propertyDict;
- (void)unsetSuperProperty:(NSString *)property;
- (void)clearSuperProperties;

- (void)track:(NSString *)event;
- (void)track:(NSString *)event
   properties:(NSDictionary *)propertieDict;
- (void)track:(NSString *)event
   properties:(NSDictionary *)propertieDict
         time:(NSDate *)time;

- (void)identify:(NSString *)distinctId;
- (void)login:(NSString *)accountId;
- (void)logout;

- (void)user_add:(NSDictionary *)property;
- (void)user_add:(NSString *)propertyName andPropertyValue:(NSNumber *)propertyValue;
- (void)user_setOnce:(NSDictionary *)property;
- (void)user_set:(NSDictionary *)property;
- (void)user_delete;

- (void)timeEvent:(NSString *)event;

- (NSString *)getDeviceId;
- (NSString *)getDistinctId;

typedef NS_OPTIONS(NSInteger, ThinkingAnalyticsAutoTrackEventType) {
    ThinkingAnalyticsEventTypeNone          = 0,
    ThinkingAnalyticsEventTypeAppStart      = 1 << 0,
    ThinkingAnalyticsEventTypeAppEnd        = 1 << 1,
    ThinkingAnalyticsEventTypeAppClick      = 1 << 2,
    ThinkingAnalyticsEventTypeAppViewScreen = 1 << 3,
};

@property (atomic) BOOL flushBeforeEnterBackground;
- (void)enableAutoTrack:(ThinkingAnalyticsAutoTrackEventType)eventType;
- (BOOL)isAutoTrackEnabled;
- (BOOL)isAutoTrackEventTypeIgnored:(ThinkingAnalyticsAutoTrackEventType)eventType;
- (BOOL)isViewTypeIgnored:(Class)aClass ;
- (UIViewController *)currentViewController;
- (BOOL)isViewControllerIgnored:(UIViewController *)viewController;
- (NSString *)getUIViewControllerTitle:(UIViewController *)controller ;
- (void)trackViewScreen:(UIViewController *)controller;
- (void)trackViewScreen:(NSString *)url withProperties:(NSDictionary *)properties;
- (void)ignoreAutoTrackViewControllers:(NSArray *)controllers;
- (void)ignoreViewType:(Class)aClass;
- (BOOL)checkProperties:(NSDictionary*)dic;

@end
