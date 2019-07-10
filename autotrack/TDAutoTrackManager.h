

#import "ThinkingAnalyticsSDKPrivate.h"

@interface TDAutoTrackManager : NSObject

+ (instancetype)sharedManager;
- (void)trackWithAppid:(NSString *)appid withOption:(ThinkingAnalyticsAutoTrackEventType)type;
- (void)viewControlWillAppear:(UIViewController *)controller;
- (void)trackEventView:(UIView *)view withIndexPath:(NSIndexPath*)indexPath;
- (void)trackEventView:(UIView *)view;

@end

