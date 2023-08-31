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
    NSLog(@"系统收到推送");

    self.contentHandler = contentHandler;
    self.bestAttemptContent = [request.content mutableCopy];

    // Modify the notification content here...
//    NSLog(@"title: %@", self.bestAttemptContent.title);
//    NSLog(@"subtitle: %@", self.bestAttemptContent.subtitle);
//    NSLog(@"body: %@", self.bestAttemptContent.body);
//    NSLog(@"userInfo: %@", self.bestAttemptContent.userInfo);

    self.contentHandler(self.bestAttemptContent);
}

- (void)serviceExtensionTimeWillExpire {
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
    self.contentHandler(self.bestAttemptContent);
}

@end
