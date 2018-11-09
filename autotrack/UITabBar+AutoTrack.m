//
//  UITabBar+AutoTrack.m
//  TDAnalyticsSDK
//
//  Created by THINKINGDATA on 2018/5/4.
//  Copyright © 2018年 thinkingdata. All rights reserved.
//

#import "UITabBar+AutoTrack.h"
#import "ThinkingAnalyticsSDK.h"
#import "TDLogger.h"
#import "NSObject+TDSwizzle.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "TDAutoTrackUtils.h"

@implementation UITabBar (AutoTrack)

#ifndef THINKING_ANALYTICS_DISABLE_AUTOTRACK_UITABBAR

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        @try {
            NSError *error = NULL;
            [[self class] td_swizzleMethod:@selector(setDelegate:)
                                withMethod:@selector(td_uiTabBarSetDelegate:)
                                     error:&error];
            if (error) {
                TDSDKError(@"Failed to swizzle setDelegate: on UITabBar. Details: %@", error);
                error = NULL;
            }
        } @catch (NSException *exception) {
            TDSDKError(@"%@ error: %@", self, exception);
        }
    });
}

void td_uiTabBarDidSelectRowAtIndexPath(id self, SEL _cmd, id tabBar, UITabBarItem* item) {
    SEL selector = NSSelectorFromString(@"td_uiTabBarDidSelectRowAtIndexPath");
    ((void(*)(id, SEL, id, id))objc_msgSend)(self, selector, tabBar, item);
    
    @try {
        if (![[ThinkingAnalyticsSDK sharedInstance] isAutoTrackEnabled]) {
            return;
        }
        
        if ([[ThinkingAnalyticsSDK sharedInstance] isAutoTrackEventTypeIgnored:ThinkingAnalyticsEventTypeAppClick]) {
            return;
        }
        
        if ([[ThinkingAnalyticsSDK sharedInstance] isViewTypeIgnored:[UITabBar class]]) {
            return;
        }
        
        if (!tabBar) {
            return;
        }
        
        UIView *view = (UIView *)tabBar;
        if (!view) {
            return;
        }
        
        if (view.thinkingAnalyticsIgnoreView) {
            return;
        }
        
        NSMutableDictionary *properties = [[NSMutableDictionary alloc] init];
        
        [properties setValue:@"UITabBar" forKey:@"#element_type"];
        
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
            } else {
                @try {
                    UIView *titleView = viewController.navigationItem.titleView;
                    if (titleView != nil) {
                        if (titleView.subviews.count > 0) {
                            NSString *elementContent = [[NSString alloc] init];
                            for (UIView *subView in [titleView subviews]) {
                                if (subView) {
                                    if (subView.thinkingAnalyticsIgnoreView) {
                                        continue;
                                    }
                                    if ([subView isKindOfClass:[UIButton class]]) {
                                        UIButton *button = (UIButton *)subView;
                                        if ([button currentTitle] != nil && ![@"" isEqualToString:[button currentTitle]]) {
                                            elementContent = [elementContent stringByAppendingString:[button currentTitle]];
                                            elementContent = [elementContent stringByAppendingString:@"-"];
                                        }
                                    } else if ([subView isKindOfClass:[UILabel class]]) {
                                        UILabel *label = (UILabel *)subView;
                                        if (label.text != nil && ![@"" isEqualToString:label.text]) {
                                            elementContent = [elementContent stringByAppendingString:label.text];
                                            elementContent = [elementContent stringByAppendingString:@"-"];
                                        }
                                    }
                                }
                            }
                            if (elementContent != nil && [elementContent length] > 0) {
                                elementContent = [elementContent substringWithRange:NSMakeRange(0,[elementContent length] - 1)];
                                [properties setValue:elementContent forKey:@"#title"];
                            }
                        }
                    }
                } @catch (NSException *exception) {
                    TDSDKError(@"%@: %@", self, exception);
                }
            }
        }
        
        if (item) {
            [properties setValue:item.title forKey:@"#element_content"];
        }
        
        NSDictionary* propDict = view.thinkingAnalyticsViewProperties;
        if (propDict != nil) {
            [properties addEntriesFromDictionary:propDict];
        }
        
        NSArray *array = [NSArray arrayWithObjects:@"ta_app_click" ,properties, nil];
        [TDAutoTrackUtils autoTrack:array];
    } @catch (NSException *exception) {
        TDSDKError(@"%@ error: %@", self, exception);
    }
}

- (void)td_uiTabBarSetDelegate:(id<UITabBarDelegate>)delegate {
    [self td_uiTabBarSetDelegate:delegate];
    
    @try {
        Class class = [delegate class];
        if (class_addMethod(class, NSSelectorFromString(@"td_uiTabBarDidSelectRowAtIndexPath"), (IMP)td_uiTabBarDidSelectRowAtIndexPath, "v@:@@")) {
            Method dis_originMethod = class_getInstanceMethod(class, NSSelectorFromString(@"td_uiTabBarDidSelectRowAtIndexPath"));
            Method dis_swizzledMethod = class_getInstanceMethod(class, @selector(tabBar:didSelectItem:));
            method_exchangeImplementations(dis_originMethod, dis_swizzledMethod);
        }
    } @catch (NSException *exception) {
        TDSDKError(@"%@ error: %@", self, exception);
    }
}

#endif

@end
