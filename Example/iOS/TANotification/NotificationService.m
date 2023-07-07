//
//  NotificationService.m
//  TANotification
//
//  Created by Charles on 6.3.23.
//  Copyright © 2023 thinking. All rights reserved.
//

#import "NotificationService.h"

@interface NotificationService ()

@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;

@end

@implementation NotificationService

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
    self.contentHandler = contentHandler;
    self.bestAttemptContent = [request.content mutableCopy];
    
    // Modify the notification content here...
    NSLog(@"title: %@", self.bestAttemptContent.title);
    NSLog(@"subtitle: %@", self.bestAttemptContent.subtitle);
    NSLog(@"body: %@", self.bestAttemptContent.body);
    NSLog(@"userInfo: %@", self.bestAttemptContent.userInfo);
    
    if ([self.bestAttemptContent.userInfo valueForKeyPath:@"aps.alert.shushuPushTag"]) {
        NSString *appid = @"22e445595b0f42bd8c5fe35bc44b88d6";
        NSString *url = @"https://receiver-ta-dev.thinkingdata.cn";
//        [ThinkingAnalyticsSDK setLogLevel:TDLoggingLevelDebug];
//        [ThinkingAnalyticsSDK startWithAppId:appid withUrl:url];
//        [[ThinkingAnalyticsSDK sharedInstance] track:@"push_info" properties:self.bestAttemptContent.userInfo];
//        [[ThinkingAnalyticsSDK sharedInstance] flush];
    }
    
    self.contentHandler(self.bestAttemptContent);
}

- (void)serviceExtensionTimeWillExpire {
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
    self.contentHandler(self.bestAttemptContent);
}

@end
