#import <Foundation/Foundation.h>
#import "ThinkingAnalyticsSDK.h"
#import "TDLogging.h"
#import "ThinkingExceptionHandler.h"
#import "TDAutoTrackUtils.h"

static NSString * const APP_START_EVENT = @"ta_app_start";
static NSString * const APP_END_EVENT = @"ta_app_end";
static NSString * const APP_VIEW_SCREEN_EVENT = @"ta_app_view";
static NSString * const APP_CLICK_EVENT = @"ta_app_click";
static NSString * const APP_CRASH_EVENT = @"ta_app_crash";
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

@interface ThinkingAnalyticsSDK()

- (void)autotrack:(NSString *)event
       properties:(NSDictionary *)propertieDict
         withTime:(NSDate *)date;
- (void)viewControlWillDisappear:(UIViewController*)controller;
- (void)viewControlWillAppear:(UIViewController *)controller;
- (BOOL)isAutoTrackEventTypeIgnored:(ThinkingAnalyticsAutoTrackEventType)eventType;
- (BOOL)checkProperties:(NSDictionary*)dic;
- (void)trackViewScreen:(UIViewController *)controller;
- (BOOL)isViewControllerIgnored:(UIViewController *)viewController;
- (UIViewController *)currentViewController;
- (BOOL)isViewTypeIgnored:(Class)aClass;
+ (void)restartFlushTimer;
+ (dispatch_queue_t)serialQueue;
+ (dispatch_queue_t)networkQueue;

@end

