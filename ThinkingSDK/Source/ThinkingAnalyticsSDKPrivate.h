#import "ThinkingAnalyticsSDK.h"

#import <Foundation/Foundation.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <objc/runtime.h>

#if !THINKING_UIWEBVIEW_SUPPORT
#import <WebKit/WebKit.h>
#endif

#import "TDLogging.h"
#import "ThinkingExceptionHandler.h"
#import "TDNetwork.h"
#import "TDDeviceInfo.h"
#import "TDConfig.h"
#import "TDSqliteDataQueue.h"

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
static NSString * const TD_EVENT_TYPE_USER_UNSET            = @"user_unset";

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

#if !defined(THINKING_UIWEBVIEW_SUPPORT)
    #define THINKING_UIWEBVIEW_SUPPORT 0
#endif

static NSUInteger const kBatchSize = 50;
static NSUInteger const TA_PROPERTY_CRASH_LENGTH_LIMIT = 8191*2;
static NSString * const TA_JS_TRACK_SCHEME = @"thinkinganalytics://trackEvent";

typedef NS_OPTIONS(NSInteger, TimeValueType) {
    TDTimeValueTypeNone      = 0,
    TDTimeValueTypeTimeOnly  = 1 << 0,
    TDTimeValueTypeAll       = 1 << 1,
};

@interface ThinkingAnalyticsSDK ()

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
@property (nonatomic, assign) BOOL firstEnterForeground;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSPredicate *regexKey;
@property (nonatomic, strong) NSPredicate *regexAutoTrackKey;
@property (nonatomic, strong) NSMutableDictionary *trackTimer;
@property (nonatomic, assign) UIBackgroundTaskIdentifier taskId;
@property (nonatomic, assign) SCNetworkReachabilityRef reachability;
@property (nonatomic, strong) CTTelephonyNetworkInfo *telephonyInfo;
@property (nonatomic, copy) NSDictionary<NSString *, id> *(^dynamicSuperProperties)(void);
@property (nonatomic, strong) NSMutableArray *debugEventsQueue;

@property (atomic, strong) TDDeviceInfo *deviceInfo;
@property (atomic, strong) TDSqliteDataQueue *dataQueue;
@property (nonatomic, copy) TDConfig *config;
@property (nonatomic, strong) NSDateFormatter *timeFormatter;
@property (nonatomic, assign) BOOL applicationWillResignActive;
@property (nonatomic, assign) BOOL appRelaunched;
@property (nonatomic, assign) BOOL isEnableSceneSupport;

#if !THINKING_UIWEBVIEW_SUPPORT
@property (nonatomic, strong) WKWebView *wkWebView;
#endif

- (instancetype)initLight:(NSString *)appid withServerURL:(NSString *)serverURL withConfig:(TDConfig *)config;
- (void)autotrack:(NSString *)event properties:(NSDictionary *)propertieDict withTime:(NSDate *)date;
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
- (void)archiveUploadSize:(NSNumber *)uploadSize;
- (void)archiveUploadInterval:(NSNumber *)uploadInterval;
- (void)startFlushTimer;
- (void)degradeDebugMode;

@end

@interface TDEventData : NSObject

@property (nonatomic, copy) NSString *eventName;
@property (nonatomic, copy) NSString *eventType;
@property (nonatomic, copy) NSString *timeString;
@property (nonatomic, assign) BOOL autotrack;
@property (nonatomic, assign) BOOL persist;
@property (nonatomic, assign) double zoneOffset;
@property (nonatomic, assign) TimeValueType timeValueType;
@property (nonatomic, strong) NSDictionary *properties;

@end

@interface LightThinkingAnalyticsSDK : ThinkingAnalyticsSDK

- (instancetype)initWithAPPID:(NSString *)appID withServerURL:(NSString *)serverURL withConfig:(TDConfig *)config;

@end
