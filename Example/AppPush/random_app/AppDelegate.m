//
//  AppDelegate.m
//  random_app
//
//  Created by Charles on 6.3.23.
//

#import "AppDelegate.h"
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
#import <UserNotifications/UserNotifications.h>
#endif
#import <ThinkingSDK/ThinkingSDK.h>

// iOS10 注册 APNs 所需头文件
# ifdef NSFoundationVersionNumber_iOS_9_x_Max
# import <UserNotifications/UserNotifications.h>
# endif
// 如果需要使用 idfa 功能所需要引入的头文件（可选）
# import <AdSupport/AdSupport.h>
#import <AppTrackingTransparency/AppTrackingTransparency.h>
@import FirebaseCore;
@import FirebaseMessaging;
#import "TDAppDelegateProxyManager.h"

@interface AppDelegate () <UNUserNotificationCenterDelegate, FIRMessagingDelegate>


@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
//    [self registerRemoteNotifications:launchOptions];
    

    [UNUserNotificationCenter currentNotificationCenter].delegate = self;
    UNAuthorizationOptions authOptions = UNAuthorizationOptionAlert |
        UNAuthorizationOptionSound | UNAuthorizationOptionBadge;
    [[UNUserNotificationCenter currentNotificationCenter]
        requestAuthorizationWithOptions:authOptions
        completionHandler:^(BOOL granted, NSError * _Nullable error) {

        }];

    [application registerForRemoteNotifications];
    
    [FIRApp configure];
    [FIRMessaging messaging].delegate = self;
    [[FIRMessaging messaging] tokenWithCompletion:^(NSString *token, NSError *error) {
      if (error != nil) {
        NSLog(@"Error getting FCM registration token: %@", error);
      } else {
        NSLog(@"FCM registration token: %@", token);
      }
    }];
    
    NSString *appid = @"preview-demo";
    NSString *url = @"https://receiver-ta-preview.thinkingdata.cn";
    [ThinkingAnalyticsSDK setLogLevel:TDLoggingLevelDebug];
    [ThinkingAnalyticsSDK startWithAppId:appid withUrl:url];
    [[ThinkingAnalyticsSDK sharedInstance] enableAutoTrack:ThinkingAnalyticsEventTypeAll];
    

    [self addShortCut:application];
    [self registerLocalNotice];
    
    
    
    return YES;
}

- (void)addShortCut:(UIApplication *)application {
    if (@available(iOS 9.0, *)) {
        application.shortcutItems=@[];
        NSMutableArray *arr = [NSMutableArray arrayWithArray:application.shortcutItems];
        UIMutableApplicationShortcutItem *shortItem1=[[UIMutableApplicationShortcutItem alloc] initWithType:@"UIApplicationShortcutIconTypePlay" localizedTitle:@"shortcut" localizedSubtitle:@"shortcut" icon:[UIApplicationShortcutIcon iconWithType: UIApplicationShortcutIconTypePlay]userInfo:@{@"firstShortcutKey1":@"fristShorcut"}];
        [arr addObject:shortItem1];
        application.shortcutItems=arr;
    }
}

- (void)registerLocalNotice {
    if (@available(iOS 10.0, *)) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];

        content.title = @"local push title";
        content.subtitle = @"local push subtitle";
        content.body = @"local push content";
        content.sound = [UNNotificationSound defaultSound];
        content.badge = @1;
        NSTimeInterval time = [[NSDate dateWithTimeIntervalSinceNow:10] timeIntervalSinceNow];

        UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:time repeats:NO];

        
        NSString *identifier = @"noticeId";
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:identifier content:content trigger:trigger];

        [center addNotificationRequest:request withCompletionHandler:^(NSError *_Nullable error) {
            
        }];
    }else {
        UILocalNotification *notif = [[UILocalNotification alloc] init];
        notif.fireDate = [NSDate dateWithTimeIntervalSinceNow:5];
        
        notif.userInfo = @{@"noticeId":@"00001"};
        notif.applicationIconBadgeNumber = 1;
        notif.soundName = UILocalNotificationDefaultSoundName;
        notif.repeatInterval = NSCalendarUnitWeekOfYear;
        [[UIApplication sharedApplication] scheduleLocalNotification:notif];
        
        
        UIUserNotificationSettings *setting = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:setting];
    }
    
//    [[ThinkingAnalyticsSDK sharedInstance] addWebViewUserAgent];
    
}


- (void)registerRemoteNotifications:(UIApplication *)application {

    if (@available(iOS 10, *)) {
        UNUserNotificationCenter *notificationCenter = [UNUserNotificationCenter currentNotificationCenter];
        notificationCenter.delegate = self;
        [notificationCenter requestAuthorizationWithOptions:UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound completionHandler:^(BOOL granted, NSError * _Nullable error) {

            if (!error && granted) {
                
            } else {
                
            }
        }];

        [notificationCenter getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
            NSLog(@" [THINKING] settings = %@", settings);
        }];

    } else if (@available(iOS 8.0, *)) {
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeSound | UIUserNotificationTypeBadge categories:nil]];
    }
    
    
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    
}

#pragma mark DeepLink

// ios(8.0)
- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler {
    NSLog(@" [THINKING] %@_%@",@"DEMO_",NSStringFromSelector(_cmd));
//    [ThinkingAnalyticsSDK application:application continueUserActivity:userActivity restorationHandler:restorationHandler];
    return YES;
}

// ios(9.0)
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    NSLog(@" [THINKING] %@_%@",@"DEMO_",NSStringFromSelector(_cmd));
    return YES;
}

// ios(2.0, 9.0)
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    NSLog(@" [THINKING] %@_%@",@"DEMO_",NSStringFromSelector(_cmd));
    return YES;
}


- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(nullable NSString *)sourceApplication annotation:(id)annotation {
    NSLog(@" [THINKING] %@_%@",@"DEMO_",NSStringFromSelector(_cmd));
    return YES;
}

#pragma mark push

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    NSLog(@" [THINKING] %@_%@",@"DEMO_",NSStringFromSelector(_cmd));
}
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    completionHandler(UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionAlert|UNNotificationPresentationOptionSound);
}
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)(void))completionHandler {
    NSLog(@" [THINKING] %@_%@",@"DEMO_",NSStringFromSelector(_cmd));
    completionHandler();
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {

    NSLog(@" [THINKING] %@_%@",@"DEMO_",NSStringFromSelector(_cmd));
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *token;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 13.0) {
        const unsigned *tokenBytes = [deviceToken bytes];
        token = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
                 ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
                 ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
                 ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];
    }else{
        token = [[deviceToken description] stringByReplacingOccurrencesOfString:@"<" withString:@""];
        token = [token stringByReplacingOccurrencesOfString:@">" withString:@""];
        token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    }
    
    NSLog(@" [THINKING] @@@@@@deviceToken==%@",token);

}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@" [THINKING] %@_%@_%@",@"DEMO_",NSStringFromSelector(_cmd), error.userInfo);
}

#pragma mark 3d touch
// ios(9.0)
- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler  API_AVAILABLE(ios(9.0)){
    NSLog(@" [THINKING] %@_%@",@"DEMO_",NSStringFromSelector(_cmd));
}

- (void)messaging:(FIRMessaging *)messaging didReceiveRegistrationToken:(NSString *)fcmToken {
    NSLog(@"FCM registration token: %@", fcmToken);
    // Notify about received token.
    NSDictionary *dataDict = [NSDictionary dictionaryWithObject:fcmToken forKey:@"token"];
    [[NSNotificationCenter defaultCenter] postNotificationName:
     @"FCMToken" object:nil userInfo:dataDict];
    // TODO: If necessary send token to application server.
    // Note: This callback is fired at each app startup and whenever a new token is generated.
}





@end
