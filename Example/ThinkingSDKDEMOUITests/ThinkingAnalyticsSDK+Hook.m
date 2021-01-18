//
//  ThinkingAnalyticsSDK+Hook.m
//  ThinkingSDKDEMOUITests
//
//  Created by Hale on 2020/11/25.
//  Copyright © 2020 thinking. All rights reserved.
//
#import <objc/runtime.h>
#import "ThinkingAnalyticsSDK+Hook.h"
@implementation ThinkingAnalyticsSDK (Hook)
+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method orignMethod = class_getInstanceMethod(self, @selector(saveEventsData:));
        Method exchangeMethod = class_getInstanceMethod(self, @selector(hook_saveEventsData:));
        method_exchangeImplementations(orignMethod, exchangeMethod);
    });
}
//- (NSInteger)saveEventsData:(NSDictionary *)data
- (NSInteger)hook_saveEventsData:(NSDictionary *)data
{
    NSLog(@"data=%@",data);
    [[NSNotificationCenter defaultCenter] postNotificationName:kSENDDATA object:nil userInfo:data];
    return 0;
}
@end
