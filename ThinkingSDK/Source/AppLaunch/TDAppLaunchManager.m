//
//  TDDeepLinkManager.m
//  ThinkingSDK
//
//  Created by wwango on 2021/9/22.
//  Copyright © 2021 thinkingdata. All rights reserved.
//

#import "TDAppLaunchManager.h"
#import "TDToastView.h"
#import <objc/runtime.h>
#import "TDAppState.h"
#import "NSObject+TDSwizzle.h"
#import <UserNotifications/UserNotifications.h>
#import "TDJSONUtil.h"
#import "NSObject+TDUtils.h"


static id<UIApplicationDelegate> td_appDelegate;
API_AVAILABLE(ios(10.0))
static id<UNUserNotificationCenterDelegate> td_userNotificationDelegate;

@interface TDAppLaunchManager ()

@property (nonatomic, strong) dispatch_queue_t queue;

@property (nonatomic, assign, readwrite) TDAppLaunchType launchType;
@property (nonatomic, strong, readwrite) id launchOptions;
@property (nonatomic, copy, readwrite) NSString *launchLink;
@property (nonatomic, strong, readwrite) NSDictionary *launchPush;
@property (nonatomic, copy, readwrite) id touch3DData;

@end

@implementation TDAppLaunchManager

+ (void)load {
    
    // 监听APP启动
//    [[NSNotificationCenter defaultCenter] addObserver:[TDAppLaunchManager sharedInstance]
//                                             selector:@selector(_applicationDidFinishLaunchingNotification:)
//                                                 name:UIApplicationDidFinishLaunchingNotification
//                                               object:nil];
//
//    // ios10
//    [[TDAppLaunchManager sharedInstance] observeNewNotificationSetDelegate];
    
}

+ (TDAppLaunchManager *)sharedInstance {
    static dispatch_once_t onceToken;
    static TDAppLaunchManager *appLaunchManager;
    
    dispatch_once(&onceToken, ^{
        appLaunchManager = [TDAppLaunchManager new];
    });
    
    return appLaunchManager;
}


- (void)_applicationDidFinishLaunchingNotification:(NSNotification *)notification {
    td_appDelegate = [[UIApplication sharedApplication] delegate];
    
    // ios8
    [self observeULink];
    
    // ios9
    [self observeSchemeLink];
    
    //  ios(2.0, 9.0)
    [self observeSchemeLink1];
    
    //  ios(4.2, 9.0)，共享文件，小于IOS9走这里，大于IOS9走application:openURL:options:
    [self observeSchemeLink2];
    
    
    // ios9
    [self observe3DTouch];
    
    
    // ios(4.0, 10.0) 老的本地推送
    [self observePush1];
    
    // ios(3.0, 10.0) 老的远程推送
    [self observePush2];// 支持静默推送
    [self observePush3];
    
}

#pragma mark - link

- (void)observeULink {
    
    if (!td_appDelegate) return;
    
    // ulink-----application:continueUserActivity:restorationHandler:
    NSString *oriSELStr = @"application:continueUserActivity:restorationHandler:";
    NSString *newSELStr = [NSString stringWithFormat:@"td_%@", oriSELStr];
    
    SEL newSEL = NSSelectorFromString(newSELStr);
    IMP newIMP = imp_implementationWithBlock(^(id _self, UIApplication *application, NSUserActivity *userActivity, id restorationHandler) {
        
        //执行原方法
        if ([_self respondsToSelector:newSEL]) {
            [NSObject performSelector:newSEL onTarget:_self withArguments:@[application, userActivity, restorationHandler]];
        }
        
        // 记录start事件
        dispatch_async([TDAppLaunchManager sharedInstance].queue, ^{
            [[TDAppLaunchManager sharedInstance] setLaunchOptions:userActivity launchType:TDAppLaunchTypeLink];
        });
    });
    
    __td_td_swizzleWithOriSELStr(td_appDelegate, oriSELStr, newSEL, newIMP);
}

- (void)observeSchemeLink {
    
    if (!td_appDelegate) return;
    
    // ulink------ application:openURL:options:
    NSString *oriSELStr = @"application:openURL:options:";
    NSString *newSELStr = [NSString stringWithFormat:@"td_%@", oriSELStr];
    
    SEL newSEL = NSSelectorFromString(newSELStr);
    IMP newIMP = imp_implementationWithBlock(^(id _self, UIApplication *application, NSURL *openURL, id options) {
        
        //执行原方法
        if ([_self respondsToSelector:newSEL]) {
            [NSObject performSelector:newSEL onTarget:_self withArguments:@[application, openURL, options]];
        }
        
        // 记录start事件
        dispatch_async([TDAppLaunchManager sharedInstance].queue, ^{
            [[TDAppLaunchManager sharedInstance] setLaunchOptions:openURL launchType:TDAppLaunchTypeLink];
        });
    });
    
    __td_td_swizzleWithOriSELStr(td_appDelegate, oriSELStr, newSEL, newIMP);
}


- (void)observeSchemeLink1 {
    
    if (!td_appDelegate) return;
    
    // ulink------ application:handleOpenURL:
    NSString *oriSELStr = @"application:handleOpenURL:";
    NSString *newSELStr = [NSString stringWithFormat:@"td_%@", oriSELStr];
    
    SEL newSEL = NSSelectorFromString(newSELStr);
    IMP newIMP = imp_implementationWithBlock(^(id _self, UIApplication *application, NSURL *openURL) {
        
        //执行原方法
        if ([_self respondsToSelector:newSEL]) {
            [NSObject performSelector:newSEL onTarget:_self withArguments:@[application, openURL]];
        }
        
        // 记录start事件
        dispatch_async([TDAppLaunchManager sharedInstance].queue, ^{
            [[TDAppLaunchManager sharedInstance] setLaunchOptions:openURL launchType:TDAppLaunchTypeLink];
        });
    });
    
    __td_td_swizzleWithOriSELStr(td_appDelegate, oriSELStr, newSEL, newIMP);
}

- (void)observeSchemeLink2 {
    
    if (!td_appDelegate) return;
    
    // ulink------application:openURL:sourceApplication:annotation:
    NSString *oriSELStr = @"application:openURL:sourceApplication:annotation:";
    NSString *newSELStr = [NSString stringWithFormat:@"td_%@", oriSELStr];
    
    SEL newSEL = NSSelectorFromString(newSELStr);
    IMP newIMP = imp_implementationWithBlock(^(id _self, UIApplication *application, NSURL *openURL, NSString *sourceApplication, id annotation) {
        
        //执行原方法
        if ([_self respondsToSelector:newSEL]) {
            [NSObject performSelector:newSEL onTarget:_self withArguments:@[application, openURL, sourceApplication, annotation]];
        }
        
        // 记录start事件
        dispatch_async([TDAppLaunchManager sharedInstance].queue, ^{
            [[TDAppLaunchManager sharedInstance] setLaunchOptions:openURL launchType:TDAppLaunchTypeLink];
        });
    });
    
    __td_td_swizzleWithOriSELStr(td_appDelegate, oriSELStr, newSEL, newIMP);
}

#pragma mark - 3d touch

- (void)observe3DTouch {
    
    if (!td_appDelegate) return;
    
    // ulink------application:performActionForShortcutItem:completionHandler:
    NSString *oriSELStr = @"application:performActionForShortcutItem:completionHandler:";
    NSString *newSELStr = [NSString stringWithFormat:@"td_%@", oriSELStr];
    
    SEL newSEL = NSSelectorFromString(newSELStr);
    if (@available(iOS 9.0, *)) {
        IMP newIMP = imp_implementationWithBlock(^(id _self, UIApplication *application, UIApplicationShortcutItem *shortcutItem, id completionHandler) {
            
            //执行原方法
            if ([_self respondsToSelector:newSEL]) {
                [NSObject performSelector:newSEL onTarget:_self withArguments:@[application, shortcutItem, completionHandler]];
            }
            
            // 记录start事件
            dispatch_async([TDAppLaunchManager sharedInstance].queue, ^{
                [[TDAppLaunchManager sharedInstance] setLaunchOptions:shortcutItem launchType:TDAppLaunchType3DTouch];
            });
        });
        
        __td_td_swizzleWithOriSELStr(td_appDelegate, oriSELStr, newSEL, newIMP);
    } else {
        // Fallback on earlier versions
    }
}

#pragma mark - push

- (void)observePush1 {
    
    if (!td_appDelegate) return;
    
    // ulink------application:didReceiveLocalNotification:
    NSString *oriSELStr = @"application:didReceiveLocalNotification:";
    NSString *newSELStr = [NSString stringWithFormat:@"td_%@", oriSELStr];
    
    SEL newSEL = NSSelectorFromString(newSELStr);
    IMP newIMP = imp_implementationWithBlock(^(id _self, UIApplication *application, UILocalNotification *notification) {
        
        //执行原方法
        if ([_self respondsToSelector:newSEL]) {
            [NSObject performSelector:newSEL onTarget:_self withArguments:@[application, notification]];
        }
        
        // 记录start事件
        dispatch_async([TDAppLaunchManager sharedInstance].queue, ^{
            [[TDAppLaunchManager sharedInstance] setLaunchOptions:notification launchType:TDAppLaunchTypePush];
        });
    });
    
    __td_td_swizzleWithOriSELStr(td_appDelegate, oriSELStr, newSEL, newIMP);
}

- (void)observePush2 {
    
    if (!td_appDelegate) return;
    
    // ulink------application:didReceiveRemoteNotification:fetchCompletionHandler:
    NSString *oriSELStr = @"application:didReceiveRemoteNotification:fetchCompletionHandler:";
    NSString *newSELStr = [NSString stringWithFormat:@"td_%@", oriSELStr];
    
    SEL newSEL = NSSelectorFromString(newSELStr);
    IMP newIMP = imp_implementationWithBlock(^(id _self, UIApplication *application, NSDictionary *userInfo, id completionHandler) {
        
        //执行原方法
        if ([_self respondsToSelector:newSEL]) {
            [NSObject performSelector:newSEL onTarget:_self withArguments:@[application, userInfo, completionHandler]];
        }
        
        // 记录start事件
        dispatch_async([TDAppLaunchManager sharedInstance].queue, ^{
            [[TDAppLaunchManager sharedInstance] setLaunchOptions:userInfo launchType:TDAppLaunchTypePush];
        });
    });
    
    __td_td_swizzleWithOriSELStr(td_appDelegate, oriSELStr, newSEL, newIMP);
}

- (void)observePush3 {
    
    if (!td_appDelegate) return;
    
    // ulink------application:didReceiveRemoteNotification:fetchCompletionHandler:
    NSString *oriSELStr = @"application:didReceiveRemoteNotification:";
    NSString *newSELStr = [NSString stringWithFormat:@"td_%@", oriSELStr];
    
    SEL newSEL = NSSelectorFromString(newSELStr);
    IMP newIMP = imp_implementationWithBlock(^(id _self, UIApplication *application, NSDictionary *userInfo) {
        
        //执行原方法
        if ([_self respondsToSelector:newSEL]) {
            [NSObject performSelector:newSEL onTarget:_self withArguments:@[application, userInfo]];
        }
        
        // 记录start事件
        dispatch_async([TDAppLaunchManager sharedInstance].queue, ^{
            [[TDAppLaunchManager sharedInstance] setLaunchOptions:userInfo launchType:TDAppLaunchTypePush];
        });
    });
    
    __td_td_swizzleWithOriSELStr(td_appDelegate, oriSELStr, newSEL, newIMP);
}

- (void)observeNewNotificationSetDelegate {
    
    if (@available(iOS 10.0, *)) {
        id userNotification = [UNUserNotificationCenter currentNotificationCenter];
        
        NSString *oriSELStr = @"setDelegate:";
        NSString *newSELStr = [NSString stringWithFormat:@"td_notification_%@", oriSELStr];
        
        SEL newSEL = NSSelectorFromString(newSELStr);
        IMP newIMP = imp_implementationWithBlock(^(id _self, id userNotificationDelegate) {
            
            //执行原方法
            if ([_self respondsToSelector:newSEL]) {
                [NSObject performSelector:newSEL onTarget:_self withArguments:@[userNotificationDelegate]];
            }
            
            // 记录start事件
            td_userNotificationDelegate = userNotificationDelegate;
            [self observeNewNotification];
        });
        
        __td_td_swizzleWithOriSELStr(userNotification, oriSELStr, newSEL, newIMP);
    } else {
        // Fallback on earlier versions
    }
}


- (void)observeNewNotification {
    if (@available(iOS 10.0, *)) {
        if (!td_userNotificationDelegate) return;
    }
    
    // ulink-------userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler:
    NSString *oriSELStr = @"userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler:";
    NSString *newSELStr = [NSString stringWithFormat:@"td_%@", oriSELStr];
    
    SEL newSEL = NSSelectorFromString(newSELStr);
    if (@available(iOS 10.0, *)) {
        IMP newIMP = imp_implementationWithBlock(^(id _self, UNUserNotificationCenter *center, UNNotificationResponse *response, id completionHandler) {
            
            //执行原方法
            if ([_self respondsToSelector:newSEL]) {
                [NSObject performSelector:newSEL onTarget:_self withArguments:@[center, response, completionHandler]];
            }
            
            // 记录start事件
            dispatch_async([TDAppLaunchManager sharedInstance].queue, ^{
                [[TDAppLaunchManager sharedInstance] setLaunchOptions:response.notification.request.content launchType:TDAppLaunchTypePush];
            });
        });
        
        __td_td_swizzleWithOriSELStr(td_userNotificationDelegate, oriSELStr, newSEL, newIMP);
    } else {
        // Fallback on earlier versions
    }
}



#pragma mark -

void __td_td_swizzleWithOriSELStr(id target, NSString *oriSELStr, SEL newSEL, IMP newIMP) {
    SEL origSEL = NSSelectorFromString(oriSELStr);
    Method origMethod = class_getInstanceMethod([target class], origSEL);
    
    if ([target respondsToSelector:origSEL]) {
        class_addMethod([target class], newSEL, newIMP, method_getTypeEncoding(origMethod));
        
        Method origMethod = class_getInstanceMethod([target class], origSEL);
        Method newMethod = class_getInstanceMethod([target class], newSEL);
        if(class_addMethod([target class], origSEL, method_getImplementation(newMethod), method_getTypeEncoding(newMethod)))
            class_replaceMethod([target class], newSEL, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
        else
            method_exchangeImplementations(origMethod, newMethod);
    } else {
        //If the original method doesn't exist at all, add it without needing to swizzle.
        class_addMethod([target class], origSEL, newIMP, method_getTypeEncoding(origMethod));
    }
}


- (void)setLaunchOptions:(NSDictionary *)launchOptions {
    
    if (!launchOptions) {
        // 用户点击icon启动
        return;
    }
    
    if (![launchOptions isKindOfClass:[NSDictionary class]]) {
        // 冷启动传入的是字典
        return;
    }
    
    _launchType = TDAppLaunchTypeUnknown;
    
    NSArray *allKeys = launchOptions.allKeys;
    
    if ([allKeys containsObject:UIApplicationLaunchOptionsURLKey]) {
        //通过 scheme 唤起 App
        [self setLaunchOptions:launchOptions[UIApplicationLaunchOptionsURLKey] launchType:TDAppLaunchTypeLink];
        //        // 相同的apple team，才有值
        //        NSString *sourceBundleID = launchOptions[UIApplicationLaunchOptionsSourceApplicationKey];
        //        // 用户自定义的数据， 返回的是一个数组
        //        NSArray *annotations = launchOptions[UIApplicationLaunchOptionsAnnotationKey];
    }
    
    if ([allKeys containsObject:UIApplicationLaunchOptionsUserActivityDictionaryKey]) {
        //通过 UniversalLink 唤起 App
        NSDictionary *userActivityDictionary = launchOptions[UIApplicationLaunchOptionsUserActivityDictionaryKey];
        NSString *type = userActivityDictionary[UIApplicationLaunchOptionsUserActivityTypeKey];
        if ([type isEqualToString:NSUserActivityTypeBrowsingWeb]) {
            //通过 UniversalLink 唤起 App
            [self setLaunchOptions:userActivityDictionary[@"UIApplicationLaunchOptionsUserActivityKey"] launchType:TDAppLaunchTypeLink];
        }
    }
    
    if ([allKeys containsObject:UIApplicationLaunchOptionsLocalNotificationKey]){
        //通过 本地推送 唤起 App
        UILocalNotification *localNotify = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
        [self setLaunchOptions:localNotify launchType:TDAppLaunchTypePush];
    }
    
    if ([allKeys containsObject:UIApplicationLaunchOptionsRemoteNotificationKey]){
        //通过 远程推送 唤起 App
        NSDictionary *notify = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        [self setLaunchOptions:notify launchType:TDAppLaunchTypePush];
    }
    
    //通过 3D Touch 唤起 App
    if (@available(iOS 9.0, *)) {
        if ([allKeys containsObject:UIApplicationLaunchOptionsShortcutItemKey]) {
            id data = launchOptions[UIApplicationLaunchOptionsShortcutItemKey];
            [self setLaunchOptions:data launchType:TDAppLaunchType3DTouch];
        }
    }
}

/// 设置启动参数， 针对热启动
- (void)setLaunchOptions:(id)launchOptions launchType:(TDAppLaunchType)launchType {
    
    _launchType |= launchType;
    
    if (launchType == TDAppLaunchTypeLink) {
        if ([launchOptions isKindOfClass:[NSURL class]]) {
            _launchLink = ((NSURL *)launchOptions).absoluteString;
        } else if ([launchOptions isKindOfClass:[NSUserActivity class]]) {
            NSUserActivity *userActivity = (NSUserActivity *)launchOptions;
            _launchLink = userActivity.webpageURL.absoluteString;
        } else if ([launchOptions isKindOfClass:[NSString class]]) {
            _launchLink = launchOptions;
        }
    } else if (launchType == TDAppLaunchTypePush) {
        
        if ([launchOptions isKindOfClass:[UILocalNotification class]]) {
            UILocalNotification *notification = (UILocalNotification *)launchOptions;
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            if (notification.userInfo.allKeys.count) {
                _launchPush = notification.userInfo;
            } else {
                if (@available(iOS 8.2, *)) {
                    if (notification.alertTitle.length) [dic setObject:notification.alertTitle forKey:@"alertTitle"];
                }
                if (notification.alertBody.length) [dic setObject:notification.alertBody forKey:@"alertBody"];
                _launchPush = dic;
            }
        } else if ([launchOptions isKindOfClass:NSClassFromString(@"UNNotificationContent")]) {
            if (@available(iOS 10.0, *)) {
                UNNotificationContent *content = (UNNotificationContent *)launchOptions;
                if (content.userInfo.allKeys.count) {
                    _launchPush = content.userInfo;
                } else {
                    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                    if (content.title) [dic setObject:content.title forKey:@"title"];
                    if (content.subtitle) [dic setObject:content.title forKey:@"subtitle"];
                    if (content.body) [dic setObject:content.title forKey:@"body"];
                    _launchPush = dic;
                }
            }
        } else if ([launchOptions isKindOfClass:[NSDictionary class]]) {
            _launchPush = launchOptions;
        }
        
    } else if (launchType == TDAppLaunchTypePush) {
        _launchPush = launchOptions;
    } else if (launchType == TDAppLaunchType3DTouch) {
        _touch3DData = launchOptions;
    }
}

- (void)setLaunchOptions:(TDAppLaunchType)launchType launchOptions:(id)items, ...
{
    NSMutableArray *arrs = [NSMutableArray array];
    va_list argumentList;
    id eachItem;
    va_start(argumentList, items);
    while((eachItem = va_arg(argumentList, id)))
    {
        [arrs addObject: eachItem];
    }
    va_end(argumentList);
}

- (nullable NSDictionary *)getLaunchDic {
    
    return nil;
    
    if (_launchType == TDAppLaunchTypeUnknown) {
        return nil;
    }
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    if ((_launchType & TDAppLaunchTypeLink) == TDAppLaunchTypeLink) {
        if (_launchLink && _launchLink.length) {
            [dic setObject:_launchLink forKey:@"url"];
        }
    }
    if ((_launchType & TDAppLaunchTypePush) == TDAppLaunchTypePush && _launchPush) {
        NSString *string = [TDJSONUtil JSONStringForObject:_launchPush];
        if (string) {
            [dic setObject:string forKey:@"data"];
        }
    }
    if ((_launchType & TDAppLaunchType3DTouch) == TDAppLaunchType3DTouch && _touch3DData) {
        if (@available(iOS 9.0, *)) {
            NSMutableDictionary *touchDic = [NSMutableDictionary dictionary];
            if ([_touch3DData isKindOfClass:[UIApplicationShortcutItem class]]) {
                NSDictionary *userInfo = [_touch3DData valueForKey:@"userInfo"];
                NSNumber *type = [_touch3DData valueForKey:@"type"];
                NSString *localizedTitle = [_touch3DData valueForKey:@"localizedTitle"];
                NSString *localizedSubtitle = [_touch3DData valueForKey:@"localizedSubtitle"];
                if (userInfo) [touchDic setObject:userInfo forKey:@"userInfo"];
                if (type) [touchDic setObject:type forKey:@"type"];
                if (localizedTitle) [touchDic setObject:localizedTitle forKey:@"localizedTitle"];
                if (localizedSubtitle) [touchDic setObject:localizedSubtitle forKey:@"localizedSubtitle"];
                [dic setObject:touchDic forKey:@"data"];
            }
        }
    }
    return dic;
}

- (void)clearData {
    _launchType = TDAppLaunchTypeUnknown;
    _launchOptions = nil;
    _launchLink = nil;
    _launchPush = nil;
}


- (dispatch_queue_t)queue {
    if (!_queue) {
        _queue = dispatch_queue_create("cn.thinking.startQueue", NULL);
        dispatch_set_target_queue(_queue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0));
    }
    return _queue;
}


@end
