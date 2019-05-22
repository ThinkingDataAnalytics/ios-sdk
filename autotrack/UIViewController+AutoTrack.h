#import <UIKit/UIKit.h>

@interface UIViewController (AutoTrack)

- (void)td_autotrack_viewWillAppear:(BOOL)animated;
- (void)td_autotrack_viewWillDisappear:(BOOL)animated;

@end
