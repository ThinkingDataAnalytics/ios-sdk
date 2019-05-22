#import "TDAutoTrackUtils.h"
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

+ (void)trackAppClickWithUICollectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    @try {
        if ([[ThinkingAnalyticsSDK sharedInstance] isAutoTrackEventTypeIgnored:ThinkingAnalyticsEventTypeAppClick]) {
            return;
        }
        
        if ([[ThinkingAnalyticsSDK sharedInstance] isViewTypeIgnored:[UICollectionView class]]) {
            return;
        }
        
        if (!collectionView) {
            return;
        }
        
        UIView *view = (UIView *)collectionView;
        if (!view) {
            return;
        }
        
        if (view.thinkingAnalyticsIgnoreView) {
            return;
        }
        
        NSMutableDictionary *properties = [[NSMutableDictionary alloc] init];
        
        [properties setValue:@"UICollectionView" forKey:@"#element_type"];
        
        if (view.thinkingAnalyticsViewID.length > 0) {
            [properties setValue:view.thinkingAnalyticsViewID forKey:@"#element_id"];
        }
        
        UIViewController *viewController = [view viewController];
        
        if (viewController == nil ||
            [viewController isKindOfClass:UINavigationController.class]) {
            viewController = [[ThinkingAnalyticsSDK sharedInstance] currentViewController];
        }
        
        if (viewController != nil) {
            if ([[ThinkingAnalyticsSDK sharedInstance] isViewControllerIgnored:viewController]) {
                return;
            }
            
            NSString *screenName = NSStringFromClass([viewController class]);
            [properties setValue:screenName forKey:@"#screen_name"];
            
            NSString *controllerTitle = viewController.navigationItem.title;
            if (controllerTitle.length > 0) {
                [properties setValue:viewController.navigationItem.title forKey:@"#title"];
            }
            NSString *elementContent = [[ThinkingAnalyticsSDK sharedInstance] getUIViewControllerTitle:viewController];
            if (elementContent.length > 0) {
                elementContent = [elementContent substringWithRange:NSMakeRange(0,[elementContent length] - 1)];
                [properties setValue:elementContent forKey:@"#title"];
            }
        }
        
        if (indexPath) {
            [properties setValue:[NSString stringWithFormat: @"%ld:%ld", (unsigned long)indexPath.section,(unsigned long)indexPath.row] forKey:@"#element_position"];
        }
        
        UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
        NSString *elementContent = [self contentFromView:cell];
        if (elementContent.length > 0) {
            [properties setValue:elementContent forKey:@"#element_content"];
        }
        
        NSDictionary* propDict = view.thinkingAnalyticsViewProperties;
        if (propDict != nil) {
            [properties addEntriesFromDictionary:propDict];
        }
        
        @try {
            if ([collectionView.thinkingAnalyticsDelegate conformsToProtocol:@protocol(TDUIViewAutoTrackDelegate)]) {
                if ([collectionView.thinkingAnalyticsDelegate respondsToSelector:@selector(thinkingAnalytics_collectionView:autoTrackPropertiesAtIndexPath:)]) {
                    [properties addEntriesFromDictionary:[view.thinkingAnalyticsDelegate thinkingAnalytics_collectionView:collectionView autoTrackPropertiesAtIndexPath:indexPath]];
                }
            }
        } @catch (NSException *exception) {
            TDLogError(@"%@ error: %@", self, exception);
        }
        
        [[ThinkingAnalyticsSDK sharedInstance] autotrack:@"ta_app_click" properties:properties];
    } @catch (NSException *exception) {
        TDLogError(@"%@ error: %@", self, exception);
    }
}

+ (void)trackAppClickWithUITableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    @try {
        if ([[ThinkingAnalyticsSDK sharedInstance] isAutoTrackEventTypeIgnored:ThinkingAnalyticsEventTypeAppClick]) {
            return;
        }
        
        if ([[ThinkingAnalyticsSDK sharedInstance] isViewTypeIgnored:[UITableView class]]) {
            return;
        }
        
        if (!tableView) {
            return;
        }
        
        UIView *view = (UIView *)tableView;
        if (!view) {
            return;
        }
        
        if (view.thinkingAnalyticsIgnoreView) {
            return;
        }
        
        NSMutableDictionary *properties = [[NSMutableDictionary alloc] init];
        
        [properties setValue:@"UITableView" forKey:@"#element_type"];
        
        if (view.thinkingAnalyticsViewID.length > 0) {
            [properties setValue:view.thinkingAnalyticsViewID forKey:@"#element_id"];
        }
        
        UIViewController *viewController = [tableView viewController];
        
        if (viewController == nil ||
            [viewController isKindOfClass:UINavigationController.class]) {
            viewController = [[ThinkingAnalyticsSDK sharedInstance] currentViewController];
        }
        
        if (viewController != nil) {
            if ([[ThinkingAnalyticsSDK sharedInstance] isViewControllerIgnored:viewController]) {
                return;
            }
            
            NSString *screenName = NSStringFromClass([viewController class]);
            [properties setValue:screenName forKey:@"#screen_name"];
            
            NSString *controllerTitle = viewController.navigationItem.title;
            if (controllerTitle.length > 0) {
                [properties setValue:controllerTitle forKey:@"#title"];
            }
            
            NSString *elementContent = [[ThinkingAnalyticsSDK sharedInstance] getUIViewControllerTitle:viewController];
            if (elementContent.length > 0) {
                [properties setValue:elementContent forKey:@"#title"];
            }
        }
        
        if (indexPath) {
            [properties setValue:[NSString stringWithFormat: @"%ld:%ld", (unsigned long)indexPath.section,(unsigned long)indexPath.row] forKey:@"#element_position"];
        }
        
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        NSString *elementContent = [self contentFromView:cell];
        if (elementContent.length > 0) {
            elementContent = [elementContent substringWithRange:NSMakeRange(0,[elementContent length] - 1)];
            [properties setValue:elementContent forKey:@"#element_content"];
        }
        
        NSDictionary* propDict = view.thinkingAnalyticsViewProperties;
        if (propDict != nil) {
            [properties addEntriesFromDictionary:propDict];
        }
        
        @try {
            if ([tableView.thinkingAnalyticsDelegate conformsToProtocol:@protocol(TDUIViewAutoTrackDelegate)]) {
                if ([tableView.thinkingAnalyticsDelegate respondsToSelector:@selector(thinkingAnalytics_tableView:autoTrackPropertiesAtIndexPath:)]) {
                    NSDictionary *dic = [view.thinkingAnalyticsDelegate thinkingAnalytics_tableView:tableView autoTrackPropertiesAtIndexPath:indexPath];
                    if([[ThinkingAnalyticsSDK sharedInstance] checkProperties:dic])
                    {
                        [properties addEntriesFromDictionary:[view.thinkingAnalyticsDelegate thinkingAnalytics_tableView:tableView autoTrackPropertiesAtIndexPath:indexPath]];
                    }
                }
            }
        } @catch (NSException *exception) {
            TDLogError(@"%@ error: %@", self, exception);
        }
        
        [[ThinkingAnalyticsSDK sharedInstance] autotrack:@"ta_app_click" properties:properties];
    } @catch (NSException *exception) {
        TDLogError(@"%@ error: %@", self, exception);
    }
}

@end
