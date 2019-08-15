#import <Foundation/Foundation.h>
#import <ThinkingSDK/ThinkingAnalyticsSDK.h>

#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <SystemConfiguration/SystemConfiguration.h>

static NSString * const APP_START_EVENT = @"ta_app_start";
static NSString * const APP_START_BACKGROUND_EVENT = @"ta_app_bg_start";
static NSString * const APP_END_EVENT = @"ta_app_end";
static NSString * const APP_VIEW_SCREEN_EVENT = @"ta_app_view";
static NSString * const APP_CLICK_EVENT = @"ta_app_click";
static NSString * const APP_CRASH_EVENT = @"ta_app_crash";
static NSString * const APP_INSTALL_EVENT = @"ta_app_install";
static NSString * const RESUME_FROM_BACKGROUND_PROPERTY = @"#resume_from_background";
static NSString * const TD_EVENT_PROPERTY_ELEMENT_ID_CRASH_REASON = @"#app_crashed_reason";


#ifndef td_dispatch_main_sync_safe
#define td_dispatch_main_sync_safe(block)\
if (dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL) == dispatch_queue_get_label(dispatch_get_main_queue())) {\
block();\
} else {\
dispatch_sync(dispatch_get_main_queue(), block);\
}
#endif

@interface ThinkingAnalyticsSDK()

@property (atomic, copy) NSString *appid;
@property (atomic, copy) NSString *serverURL;
@property (atomic, copy) NSString *accountId;
@property (atomic, copy) NSString *identifyId;
@property (atomic, strong) NSPredicate *regexKey;
@property (atomic, strong) NSDictionary *superPropertie;
@property (atomic, strong) NSMutableSet *ignoredViewTypeList;
@property (atomic, strong) NSMutableSet *ignoredViewControllers;
@property (nonatomic, assign) BOOL relaunchInBackGround;
@property (nonatomic, assign) BOOL isEnabled;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSMutableDictionary *trackTimer;
@property (nonatomic, assign) UIBackgroundTaskIdentifier taskId;
@property (nonatomic, assign) SCNetworkReachabilityRef reachability;
@property (nonatomic, strong) CTTelephonyNetworkInfo *telephonyInfo;
@property (nonatomic, copy) NSDictionary<NSString *, id> *(^dynamicSuperProperties)(void);

- (void)autotrack:(NSString *)event
       properties:(NSDictionary *)propertieDict
         withTime:(NSDate *)date;
- (void)deleteAll;
+ (void)restartFlushTimer;
- (BOOL)checkAutoTrackProperties:(NSDictionary**)dic;
+ (BOOL)checkAutoTrackProperties:(NSDictionary**)dic;
- (BOOL)isViewControllerIgnored:(UIViewController *)viewController;
- (BOOL)isAutoTrackEventTypeIgnored:(ThinkingAnalyticsAutoTrackEventType)eventType;
- (BOOL)isViewTypeIgnored:(Class)aClass;
+ (dispatch_queue_t)serialQueue;
+ (dispatch_queue_t)networkQueue;
+ (UIApplication *)sharedUIApplication;
- (NSInteger)saveClickData:(NSDictionary *)data;

@end

