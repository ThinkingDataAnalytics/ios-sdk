#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
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

@interface ThinkingAnalyticsSDK : NSObject

+ (ThinkingAnalyticsSDK *)sharedInstance;
+ (ThinkingAnalyticsSDK *)startWithAppId:(NSString *)appId withUrl:(NSString *)url;

typedef NS_OPTIONS(NSInteger, TDLoggingLevel) {
    TDLoggingLevelNone  = 0,
    TDLoggingLevelError = 1 << 0,
    TDLoggingLevelInfo  = 1 << 1,
    TDLoggingLevelDebug = 1 << 2,
};

typedef NS_OPTIONS(NSInteger, ThinkingAnalyticsNetworkType) {
    TDNetworkTypeDefault  = 0,
    TDNetworkTypeOnlyWIFI = 1 << 0,
    TDNetworkTypeALL      = 1 << 1,
};

typedef NS_OPTIONS(NSInteger, ThinkingAnalyticsAutoTrackEventType) {
    ThinkingAnalyticsEventTypeNone          = 0,
    ThinkingAnalyticsEventTypeAppStart      = 1 << 0,
    ThinkingAnalyticsEventTypeAppEnd        = 1 << 1,
    ThinkingAnalyticsEventTypeAppClick      = 1 << 2,
    ThinkingAnalyticsEventTypeAppViewScreen = 1 << 3,
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

- (void)enableAutoTrack:(ThinkingAnalyticsAutoTrackEventType)eventType;
- (void)ignoreAutoTrackViewControllers:(NSArray *)controllers;
- (void)ignoreViewType:(Class)aClass;

- (BOOL)showUpWebView:(id)webView WithRequest:(NSURLRequest *)request;
- (void)addWebViewUserAgent;
- (void)setLogLevel:(TDLoggingLevel)level;

@end

@interface UIView (ThinkingAnalytics)

- (nullable UIViewController *)viewController;

@property (copy,nonatomic) NSString* thinkingAnalyticsViewID;

@property (nonatomic,assign) BOOL thinkingAnalyticsIgnoreView;

@property (strong,nonatomic) NSDictionary* thinkingAnalyticsViewProperties;

@property (nonatomic, weak, nullable) id thinkingAnalyticsDelegate;

@end

NS_ASSUME_NONNULL_END
