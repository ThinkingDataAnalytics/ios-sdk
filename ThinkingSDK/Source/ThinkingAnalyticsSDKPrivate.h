#import <Foundation/Foundation.h>
#import <ThinkingSDK/ThinkingAnalyticsSDK.h>

#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <SystemConfiguration/SystemConfiguration.h>

static NSString * const TD_APP_START_EVENT                  = @"ta_app_start";
static NSString * const TD_APP_START_BACKGROUND_EVENT       = @"ta_app_bg_start";
static NSString * const TD_APP_END_EVENT                    = @"ta_app_end";
static NSString * const TD_APP_VIEW_EVENT                   = @"ta_app_view";
static NSString * const TD_APP_CLICK_EVENT                  = @"ta_app_click";
static NSString * const TD_APP_CRASH_EVENT                  = @"ta_app_crash";
static NSString * const TD_APP_INSTALL_EVENT                = @"ta_app_install";

static NSString * const TD_CRASH_REASON                     = @"#app_crashed_reason";
static NSString * const TD_RESUME_FROM_BACKGROUND           = @"#resume_from_background";

static NSString * const TD_EVENT_TYPE_TRACK                 = @"track";
static NSString * const TD_EVENT_TYPE_USER_DEL              = @"user_del";
static NSString * const TD_EVENT_TYPE_USER_ADD              = @"user_add";
static NSString * const TD_EVENT_TYPE_USER_SET              = @"user_set";
static NSString * const TD_EVENT_TYPE_USER_SETONCE          = @"user_setOnce";

static NSString * const TD_EVENT_START                      = @"eventStart";
static NSString * const TD_EVENT_DURATION                   = @"eventDuration";

static char TD_AUTOTRACK_VIEW_ID;
static char TD_AUTOTRACK_VIEW_ID_APPID;
static char TD_AUTOTRACK_VIEW_IGNORE;
static char TD_AUTOTRACK_VIEW_IGNORE_APPID;
static char TD_AUTOTRACK_VIEW_PROPERTIES;
static char TD_AUTOTRACK_VIEW_PROPERTIES_APPID;
static char TD_AUTOTRACK_VIEW_DELEGATE;

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
@property (atomic, strong) NSDictionary *superProperty;
@property (atomic, strong) NSMutableSet *ignoredViewTypeList;
@property (atomic, strong) NSMutableSet *ignoredViewControllers;
@property (nonatomic, assign) BOOL relaunchInBackGround;
@property (nonatomic, assign) BOOL isEnabled;
@property (nonatomic, assign) BOOL isOptOut;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSPredicate *regexKey;
@property (nonatomic, strong) NSPredicate *regexAutoTrackKey;
@property (nonatomic, strong) NSMutableDictionary *trackTimer;
@property (nonatomic, assign) UIBackgroundTaskIdentifier taskId;
@property (nonatomic, assign) SCNetworkReachabilityRef reachability;
@property (nonatomic, strong) CTTelephonyNetworkInfo *telephonyInfo;
@property (nonatomic, copy) NSDictionary<NSString *, id> *(^dynamicSuperProperties)(void);

- (instancetype)initLight:(NSString *)appid;
- (void)autotrack:(NSString *)event properties:(NSDictionary *)propertieDict withTime:(NSDate *)date;
+ (void)restartFlushTimer;
- (BOOL)isViewControllerIgnored:(UIViewController *)viewController;
- (BOOL)isAutoTrackEventTypeIgnored:(ThinkingAnalyticsAutoTrackEventType)eventType;
- (BOOL)isViewTypeIgnored:(Class)aClass;
+ (dispatch_queue_t)serialQueue;
+ (dispatch_queue_t)networkQueue;
+ (UIApplication *)sharedUIApplication;
- (NSInteger)saveEventsData:(NSDictionary *)data;
- (void)flushImmediately:(NSDictionary *)dataDic;
- (BOOL)hasDisabled;
- (BOOL)checkEventProperties:(NSDictionary *)properties withEventType:(NSString *)eventType haveAutoTrackEvents:(BOOL)haveAutoTrackEvents;

@end

@interface LightThinkingAnalyticsSDK : ThinkingAnalyticsSDK

- (instancetype)initWithAPPID:(NSString *)appID;

@end
