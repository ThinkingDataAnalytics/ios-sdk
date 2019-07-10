#import "UIViewController+AutoTrack.h"
#import "ThinkingAnalyticsSDKPrivate.h" 
#import "TDAutoTrackManager.h"

@implementation UIViewController (AutoTrack)

- (void)td_autotrack_viewWillAppear:(BOOL)animated {
    @try {
        [[TDAutoTrackManager sharedManager] viewControlWillAppear:self];
    } @catch (NSException *exception) {
        TDLogError(@"%@ error: %@", self, exception);
    }
    [self td_autotrack_viewWillAppear:animated];
}

@end
