#import "UIViewController+AutoTrack.h"
#import "ThinkingAnalyticsSDKPrivate.h"

@implementation UIViewController (AutoTrack)

- (void)td_autotrack_viewWillAppear:(BOOL)animated {
    @try {
        [[ThinkingAnalyticsSDK sharedInstance] viewControlWillAppear:self];
    } @catch (NSException *exception) {
        TDLogError(@"%@ error: %@", self, exception);
    }
    [self td_autotrack_viewWillAppear:animated];
}

-(void)td_autotrack_viewWillDisappear:(BOOL)animated {
    @try {
        [[ThinkingAnalyticsSDK sharedInstance] viewControlWillDisappear:self];
    } @catch (NSException *exception) {
        TDLogError(@"%@ error: %@", self, exception);
    }
    [self td_autotrack_viewWillDisappear:animated];
}

@end
