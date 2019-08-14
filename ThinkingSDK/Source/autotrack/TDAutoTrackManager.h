#import "ThinkingAnalyticsSDK.h"

static NSString * const TD_EVENT_PROPERTY_TITLE = @"#title";
static NSString * const TD_EVENT_PROPERTY_URL_PROPERTY = @"#url";
static NSString * const TD_EVENT_PROPERTY_SCREEN_NAME = @"#screen_name";
static NSString * const TD_EVENT_PROPERTY_ELEMENT_ID = @"#element_id";
static NSString * const TD_EVENT_PROPERTY_ELEMENT_TYPE = @"#element_type";
static NSString * const TD_EVENT_PROPERTY_ELEMENT_CONTENT = @"#element_content";
static NSString * const TD_EVENT_PROPERTY_ELEMENT_POSITION = @"#element_position";

@interface TDAutoTrackManager : NSObject

+ (instancetype)sharedManager;
- (void)trackEventView:(UIView *)view;
- (void)trackEventView:(UIView *)view withIndexPath:(NSIndexPath*)indexPath;
- (void)viewControlWillAppear:(UIViewController *)controller;
- (void)trackWithAppid:(NSString *)appid withOption:(ThinkingAnalyticsAutoTrackEventType)type;

@end

