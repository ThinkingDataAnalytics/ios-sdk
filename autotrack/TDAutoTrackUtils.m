//#import "TDAutoTrackUtils.h"
#import "ThinkingAnalyticsSDKPrivate.h"

@implementation TDAutoTrackUtils

+ (NSString *)contentFromView:(UIView *)rootView {
    @try {
        NSMutableString *elementContent = [NSMutableString string];
        for (UIView *subView in [rootView subviews]) {
            if (subView) {
                if (subView.thinkingAnalyticsIgnoreView) {
                    continue;
                }
                
                if (subView.isHidden) {
                    continue;
                }
                
                if ([subView isKindOfClass:[UIButton class]]) {
                    UIButton *button = (UIButton *)subView;
                    if ([button currentTitle].length > 0) {
                        [elementContent appendString:[button currentTitle]];
                        [elementContent appendString:@"-"];
                    }
                } else if ([subView isKindOfClass:[UILabel class]]) {
                    UILabel *label = (UILabel *)subView;
                    if (label.text.length > 0) {
                        [elementContent appendString:label.text];
                        [elementContent appendString:@"-"];
                    }
                } else if ([subView isKindOfClass:[UITextView class]]) {
                    UITextView *textView = (UITextView *)subView;
                    if (textView.text.length > 0) {
                        [elementContent appendString:textView.text];
                        [elementContent appendString:@"-"];
                    }
                } else {
                    NSString *temp = [self contentFromView:subView];
                    if (temp.length > 0) {
                        [elementContent appendString:temp];
                    }
                }
            }
        }
        return elementContent;
    } @catch (NSException *exception) {
        TDLogError(@"%@ error: %@", self, exception);
        return nil;
    }
}

+ (NSString *)titleFromViewController:(UIViewController *)viewController {
    if (!viewController) {
        return nil;
    }
    NSString *controllerTitle = viewController.navigationItem.title;
    UIView *titleView = viewController.navigationItem.titleView;
    
    NSString *elementContent = nil;
    if (titleView) {
        elementContent = [TDAutoTrackUtils contentFromView:titleView];
    }
    
    if (elementContent.length > 0) {
        return elementContent;
    } else {
        return controllerTitle;
    }
}

@end
