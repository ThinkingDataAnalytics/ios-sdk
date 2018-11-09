//
//  TDAutoTrackUtils.m
//  TDAnalyticsSDK
//
//  Created by THINKINGDATA on 2018/5/3.
//  Copyright © 2018年 thinkingdata. All rights reserved.
//

#import "TDAutoTrackUtils.h"
#import "TDLogger.h"
#import "ThinkingAnalyticsSDK.h"

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
                    if ([button currentTitle] != nil && ![@"" isEqualToString:[button currentTitle]]) {
                        [elementContent appendString:[button currentTitle]];
                        [elementContent appendString:@"-"];
                    }
                } else if ([subView isKindOfClass:[UILabel class]]) {
                    UILabel *label = (UILabel *)subView;
                    if (label.text != nil && ![@"" isEqualToString:label.text]) {
                        [elementContent appendString:label.text];
                        [elementContent appendString:@"-"];
                    }
                } else if ([subView isKindOfClass:[UITextView class]]) {
                    UITextView *textView = (UITextView *)subView;
                    if (textView.text != nil && ![@"" isEqualToString:textView.text]) {
                        [elementContent appendString:textView.text];
                        [elementContent appendString:@"-"];
                    }
                } else if ([subView isKindOfClass:NSClassFromString(@"RTLabel")]) {//RTLabel:https://github.com/honcheng/RTLabel
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                    if ([subView respondsToSelector:NSSelectorFromString(@"text")]) {
                        NSString *title = [subView performSelector:NSSelectorFromString(@"text")];
                        if (title != nil && ![@"" isEqualToString:title]) {
                            [elementContent appendString:title];
                            [elementContent appendString:@"-"];
                        }
                    }
#pragma clang diagnostic pop
                } else if ([subView isKindOfClass:NSClassFromString(@"YYLabel")]) {//RTLabel:https://github.com/ibireme/YYKit
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                    if ([subView respondsToSelector:NSSelectorFromString(@"text")]) {
                        NSString *title = [subView performSelector:NSSelectorFromString(@"text")];
                        if (title != nil && ![@"" isEqualToString:title]) {
                            [elementContent appendString:title];
                            [elementContent appendString:@"-"];
                        }
                    }
#pragma clang diagnostic pop
                }
                else {
                    NSString *temp = [self contentFromView:subView];
                    if (temp != nil && ![@"" isEqualToString:temp]) {
                        [elementContent appendString:temp];
                    }
                }
            }
        }
        return elementContent;
    } @catch (NSException *exception) {
        TDSDKError(@"%@ error: %@", self, exception);
        return nil;
    }
}

+ (void)trackAppClickWithUICollectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    @try {
        if (![[ThinkingAnalyticsSDK sharedInstance] isAutoTrackEnabled]) {
            return;
        }
        
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
        
        if (view.thinkingAnalyticsViewID != nil) {
            [properties setValue:view.thinkingAnalyticsViewID forKey:@"#element_id"];
        }
        
        UIViewController *viewController = [view viewController];
        
        if (viewController == nil ||
            [@"UINavigationController" isEqualToString:NSStringFromClass([viewController class])]) {
            viewController = [[ThinkingAnalyticsSDK sharedInstance] currentViewController];
        }
        
        if (viewController != nil) {
            if ([[ThinkingAnalyticsSDK sharedInstance] isViewControllerIgnored:viewController]) {
                return;
            }
            
            NSString *screenName = NSStringFromClass([viewController class]);
            [properties setValue:screenName forKey:@"#screen_name"];
            
            NSString *controllerTitle = viewController.navigationItem.title;
            if (controllerTitle != nil) {
                [properties setValue:viewController.navigationItem.title forKey:@"#title"];
            }
            NSString *elementContent = [[ThinkingAnalyticsSDK sharedInstance] getUIViewControllerTitle:viewController];
            if (elementContent != nil && [elementContent length] > 0) {
                elementContent = [elementContent substringWithRange:NSMakeRange(0,[elementContent length] - 1)];
                [properties setValue:elementContent forKey:@"#title"];
            }
        }
        
        if (indexPath) {
            [properties setValue:[NSString stringWithFormat: @"%ld:%ld", (unsigned long)indexPath.section,(unsigned long)indexPath.row] forKey:@"#element_position"];
        }
        
        UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
        if (cell==nil) {
            [collectionView layoutIfNeeded];
            cell = [collectionView cellForItemAtIndexPath:indexPath];
        }
        
        NSString *elementContent = [[NSString alloc] init];
        elementContent = [self contentFromView:cell];
        if (elementContent != nil && [elementContent length] > 0) {
            elementContent = [elementContent substringWithRange:NSMakeRange(0,[elementContent length] - 1)];
            [properties setValue:elementContent forKey:@"#element_content"];
        }
        
        NSDictionary* propDict = view.thinkingAnalyticsViewProperties;
        if (propDict != nil) {
            [properties addEntriesFromDictionary:propDict];
        }
        
        @try {
            if (view.thinkingAnalyticsDelegate) {
                if ([view.thinkingAnalyticsDelegate conformsToProtocol:@protocol(TDUIViewAutoTrackDelegate)]) {
                    if ([view.thinkingAnalyticsDelegate respondsToSelector:@selector(thinkingAnalytics_collectionView:autoTrackPropertiesAtIndexPath:)]) {
                        [properties addEntriesFromDictionary:[view.thinkingAnalyticsDelegate thinkingAnalytics_collectionView:collectionView autoTrackPropertiesAtIndexPath:indexPath]];
                    }
                }
            }
        } @catch (NSException *exception) {
            TDSDKError(@"%@ error: %@", self, exception);
        }
        
        NSArray *array = [NSArray arrayWithObjects:@"ta_app_click" ,properties, nil];
        [TDAutoTrackUtils autoTrack:array];
    } @catch (NSException *exception) {
        TDSDKError(@"%@ error: %@", self, exception);
    }
}

+ (void)trackAppClickWithUITableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    @try {
        if (![[ThinkingAnalyticsSDK sharedInstance] isAutoTrackEnabled]) {
            return;
        }
        
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
        
        if (view.thinkingAnalyticsViewID != nil) {
            [properties setValue:view.thinkingAnalyticsViewID forKey:@"#element_id"];
        }
        
        UIViewController *viewController = [tableView viewController];
        
        if (viewController == nil ||
            [@"UINavigationController" isEqualToString:NSStringFromClass([viewController class])]) {
            viewController = [[ThinkingAnalyticsSDK sharedInstance] currentViewController];
        }
        
        if (viewController != nil) {
            if ([[ThinkingAnalyticsSDK sharedInstance] isViewControllerIgnored:viewController]) {
                return;
            }
            
            NSString *screenName = NSStringFromClass([viewController class]);
            [properties setValue:screenName forKey:@"#screen_name"];
            
            NSString *controllerTitle = viewController.navigationItem.title;
            if (controllerTitle != nil) {
                [properties setValue:viewController.navigationItem.title forKey:@"#title"];
            }
            
            NSString *elementContent = [[ThinkingAnalyticsSDK sharedInstance] getUIViewControllerTitle:viewController];
            if (elementContent != nil && [elementContent length] > 0) {
                elementContent = [elementContent substringWithRange:NSMakeRange(0,[elementContent length] - 1)];
                [properties setValue:elementContent forKey:@"#title"];
            }
        }
        
        if (indexPath) {
            [properties setValue:[NSString stringWithFormat: @"%ld:%ld", (unsigned long)indexPath.section,(unsigned long)indexPath.row] forKey:@"#element_position"];
        }
        
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if (cell == nil) {
            [tableView layoutIfNeeded];
            cell = [tableView cellForRowAtIndexPath:indexPath];
        }
        NSString *elementContent = [[NSString alloc] init];
        
        elementContent = [self contentFromView:cell];
        if (elementContent != nil && [elementContent length] > 0) {
            elementContent = [elementContent substringWithRange:NSMakeRange(0,[elementContent length] - 1)];
            [properties setValue:elementContent forKey:@"#element_content"];
        }
        
        NSDictionary* propDict = view.thinkingAnalyticsViewProperties;
        if (propDict != nil) {
            [properties addEntriesFromDictionary:propDict];
        }
        
        @try {
            if (view.thinkingAnalyticsDelegate) {
                if ([view.thinkingAnalyticsDelegate conformsToProtocol:@protocol(TDUIViewAutoTrackDelegate)]) {
                    if ([view.thinkingAnalyticsDelegate respondsToSelector:@selector(thinkingAnalytics_tableView:autoTrackPropertiesAtIndexPath:)]) {
                        NSDictionary *dic = [view.thinkingAnalyticsDelegate thinkingAnalytics_tableView:tableView autoTrackPropertiesAtIndexPath:indexPath];
                        if([[ThinkingAnalyticsSDK sharedInstance] checkProperties:dic])
                        {
                            [properties addEntriesFromDictionary:[view.thinkingAnalyticsDelegate thinkingAnalytics_tableView:tableView autoTrackPropertiesAtIndexPath:indexPath]];
                        }
                    }
                }
            }
        } @catch (NSException *exception) {
            TDSDKError(@"%@ error: %@", self, exception);
        }
        
        NSArray *array = [NSArray arrayWithObjects:@"ta_app_click" ,properties, nil];
        [TDAutoTrackUtils autoTrack:array];
    } @catch (NSException *exception) {
        TDSDKError(@"%@ error: %@", self, exception);
    }
}

+ (void)autoTrack:(NSArray *)parameter {
    SEL aSelector = @selector(autotrack: properties:);
    NSMethodSignature *signature = [[ThinkingAnalyticsSDK sharedInstance] methodSignatureForSelector:aSelector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation setTarget:[ThinkingAnalyticsSDK sharedInstance]];
    [invocation setSelector:aSelector];
    [invocation retainArguments];

    NSString *para1 = parameter[0];
    NSDictionary *para2 = parameter[1];

    [invocation setArgument:&para1 atIndex:2];
    [invocation setArgument:&para2 atIndex:3];

    [invocation invoke];
}

@end
