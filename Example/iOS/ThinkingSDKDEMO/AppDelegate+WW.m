//
//  AppDelegate+WW.m
//  ThinkingSDKDEMO
//
//  Created by wwango on 2021/11/26.
//  Copyright © 2021 thinking. All rights reserved.
//

#import "AppDelegate+WW.h"
#import <objc/message.h>

@implementation AppDelegate (WW)

+ (void)load {
    SEL origSEL = @selector(application:continueUserActivity:restorationHandler:);
    SEL newSEL = @selector(xxxx_application:continueUserActivity:restorationHandler:);
    Method origMethod = class_getInstanceMethod([self class], origSEL);
    Method newMethod = class_getInstanceMethod([self class], newSEL);
    method_exchangeImplementations(origMethod, newMethod);
}

- (BOOL)xxxx_application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler {
    NSLog(@" [THINKING] %@_%@",@"DEMO_",NSStringFromSelector(_cmd));
    return [self xxxx_application:application continueUserActivity:userActivity restorationHandler:restorationHandler];
}

@end
