//
//  NotificationService.m
//  notification
//
//  Created by Charles on 6.3.23.
//

#import "NotificationService.h"
//#import <ThinkingSDK/ThinkingSDK.h>

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
    
//    if ([self.bestAttemptContent.userInfo.allKeys containsObject:@"te_extras"]) {
//        NSString *appid = @"22e445595b0f42bd8c5fe35bc44b88d6";
//        NSString *url = @"https://receiver.ta.thinkingdata.cn/";
//        [ThinkingAnalyticsSDK setLogLevel:TDLoggingLevelDebug];
//        [ThinkingAnalyticsSDK startWithAppId:appid withUrl:url];
//        
//        @try {
//            NSString *response = self.bestAttemptContent.userInfo[@"te_extras"];
//            NSData *jsonData = [response dataUsingEncoding:NSUTF8StringEncoding];
//            NSError *err;
//            NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
//            [[ThinkingAnalyticsSDK sharedInstance] track:@"ops_push_receiver" properties:responseDic];
//            [[ThinkingAnalyticsSDK sharedInstance] flush];
//           
//        } @catch (NSException *exception) {
//            
//        }
//    }
    
    // Modify the notification content here...
    self.bestAttemptContent.title = [NSString stringWithFormat:@"%@ [modified]", self.bestAttemptContent.title];
    
    self.contentHandler(self.bestAttemptContent);
}

- (void)serviceExtensionTimeWillExpire {
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
    self.contentHandler(self.bestAttemptContent);
}

@end
