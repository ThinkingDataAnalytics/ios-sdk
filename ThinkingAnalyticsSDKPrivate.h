#import <Foundation/Foundation.h>
#import "ThinkingAnalyticsSDK.h"
#import "TDLogging.h"

@interface ThinkingAnalyticsSDK()

- (void)autotrack:(NSString *)event
       properties:(NSDictionary *)propertieDict;

- (void)viewControlWillDisappear:(UIViewController*)controller;
- (void)viewControlWillAppear:(UIViewController *)controller;
- (BOOL)isAutoTrackEventTypeIgnored:(ThinkingAnalyticsAutoTrackEventType)eventType;
- (NSString *)getUIViewControllerTitle:(UIViewController *)controller;
- (BOOL)checkProperties:(NSDictionary*)dic;
- (void)trackViewScreen:(UIViewController *)controller;
- (BOOL)isViewControllerIgnored:(UIViewController *)viewController;
- (UIViewController *)currentViewController;
- (BOOL)isViewTypeIgnored:(Class)aClass;

@end

