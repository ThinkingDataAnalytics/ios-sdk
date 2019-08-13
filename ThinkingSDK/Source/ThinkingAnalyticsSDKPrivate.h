#import <Foundation/Foundation.h>
#import <ThinkingSDK/ThinkingAnalyticsSDK.h>

static NSString * const APP_START_EVENT = @"ta_app_start";
static NSString * const APP_START_BACKGROUND_EVENT = @"ta_app_bg_start";
static NSString * const APP_END_EVENT = @"ta_app_end";
static NSString * const APP_VIEW_SCREEN_EVENT = @"ta_app_view";
static NSString * const APP_CLICK_EVENT = @"ta_app_click";
static NSString * const APP_CRASH_EVENT = @"ta_app_crash";
static NSString * const APP_INSTALL_EVENT = @"ta_app_install";
static NSString * const RESUME_FROM_BACKGROUND_PROPERTY = @"#resume_from_background";
static NSString * const TD_EVENT_PROPERTY_ELEMENT_CONTENT = @"#element_content";
static NSString * const TD_EVENT_PROPERTY_ELEMENT_POSITION = @"#element_position";
static NSString * const TD_EVENT_PROPERTY_TITLE = @"#title";
static NSString * const TD_EVENT_PROPERTY_SCREEN_NAME = @"#screen_name";
static NSString * const TD_EVENT_PROPERTY_ELEMENT_TYPE = @"#element_type";
static NSString * const TD_EVENT_PROPERTY_ELEMENT_ID = @"#element_id";
static NSString * const TD_EVENT_PROPERTY_ELEMENT_ID_CRASH_REASON = @"#app_crashed_reason";
static NSString * const TD_EVENT_PROPERTY_URL_PROPERTY = @"#url";
static NSString * const TD_EVENT_PROPERTY_REFERRER_URL_PROPERTY = @"#referrer";

#ifndef td_dispatch_main_sync_safe
#define td_dispatch_main_sync_safe(block)\
if (dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL) == dispatch_queue_get_label(dispatch_get_main_queue())) {\
block();\
} else {\
dispatch_sync(dispatch_get_main_queue(), block);\
}
#endif

@interface ThinkingAnalyticsSDK()

- (void)autotrack:(NSString *)event
       properties:(NSDictionary *)propertieDict
         withTime:(NSDate *)date;
- (BOOL)isAutoTrackEventTypeIgnored:(ThinkingAnalyticsAutoTrackEventType)eventType;
- (BOOL)checkAutoTrackProperties:(NSDictionary**)dic;
+ (BOOL)checkAutoTrackProperties:(NSDictionary**)dic;
- (BOOL)isViewControllerIgnored:(UIViewController *)viewController;
- (BOOL)isViewTypeIgnored:(Class)aClass;
+ (void)restartFlushTimer;
+ (dispatch_queue_t)serialQueue;
+ (dispatch_queue_t)networkQueue;
- (void)deleteAll;
+ (UIApplication *)sharedUIApplication;

- (NSInteger)saveClickData:(NSDictionary *)data;

@end

