//
//  AppDelegate.m
//  ThinkingSDKDEMO
//
//  Created by syj on 2019/6/24.
//  Copyright © 2019 thinking. All rights reserved.
//

#import "AppDelegate.h"
#import "AppDelegate+TDUI.h"
#import <ThinkingSDK/ThinkingAnalyticsSDK.h>
#import <ThinkingSDK/TDLogging.h>
#import "TDDemoLocation.h"

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
#import <UserNotifications/UserNotifications.h>
#endif

@interface AppDelegate () <UNUserNotificationCenterDelegate>

@property(nonatomic, strong) TDDemoLocation *location1;
@property(nonatomic, strong) TDDemoLocation *location2;

@property(nonatomic, strong) ThinkingAnalyticsSDK *instance1;
@property(nonatomic, strong) ThinkingAnalyticsSDK *instance2;
@property(nonatomic, strong) ThinkingAnalyticsSDK *instance3;
@property(nonatomic, strong) ThinkingAnalyticsSDK *instance4;
@property(nonatomic, strong) ThinkingAnalyticsSDK *instance5;

@property(nonatomic, strong)dispatch_group_t group;

@property(nonatomic, strong)dispatch_queue_t queue1;
@property(nonatomic, strong)dispatch_queue_t queue2;
@property(nonatomic, strong)dispatch_queue_t queue3;
@property(nonatomic, strong)dispatch_queue_t queue4;

@property (nonatomic, assign) NSInteger retryAttempt;

@end

@implementation AppDelegate
 NSInteger __index = 0;
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    NSLog(@" [THINKING] home: %@", NSHomeDirectory());
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [self createRootViewController];
    [self.window makeKeyAndVisible];
    NSLog(@" [THINKING] %@_%@",@"DEMO_",NSStringFromSelector(_cmd));
    
    NSLog(@" [THINKING]  %@", launchOptions);
    
    
    [ThinkingAnalyticsSDK calibrateTime:1680600003000];
    //[ThinkingAnalyticsSDK calibrateTimeWithNtp:@"ntp.aliyun.com"];
    
//    [self test_eventTime];
        
//    _group = dispatch_group_create();
//    _queue1 = dispatch_queue_create("queue1", DISPATCH_QUEUE_SERIAL);
//    _queue2 = dispatch_queue_create("queue2", DISPATCH_QUEUE_SERIAL);
//    _queue3 = dispatch_queue_create("queue3", DISPATCH_QUEUE_SERIAL);
//    _queue4 = dispatch_queue_create("queue4", DISPATCH_QUEUE_SERIAL);
//
//
//    dispatch_group_async(_group, _queue1, ^{
////        NSLog(@"#####_queue1-currnet_thread: %@", [NSThread currentThread]);
//        for (int i=0; i<100; i++) {
//            [self test_eventTime];
//        }
//
//    });


//    dispatch_group_async(_group, _queue2, ^{
////        NSLog(@"#####_queue2-currnet_thread: %@", [NSThread currentThread]);
//        for (int i=0; i<100; i++) {
//            [self test_eventTime];
//        }
//    });
//
//    dispatch_group_async(_group, _queue3, ^{
////        NSLog(@"#####_queue3-currnet_thread: %@", [NSThread currentThread]);
//        for (int i=0; i<100; i++) {
//            [self test_eventTime];
//        }
//    });
//
//    dispatch_group_async(_group, _queue4, ^{
////        NSLog(@"#####_queue4-currnet_thread: %@", [NSThread currentThread]);
//        for (int i=0; i<100; i++) {
//            [self test_eventTime];
//        }
//    });
//
//    dispatch_group_notify(_group, dispatch_get_main_queue(), ^{
//        NSLog(@"######### ---%d", __index);
//        [[ThinkingAnalyticsSDK sharedInstance] track:@""];
//        NSLog(@"#########");
//    });

//    [self test_AppCrash];
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        raise(SIGABRT);
////        raise(SIGPIPE);
//    });
    
    [self testAPPPush:application launchOptions:launchOptions];
    
//    [self test_trackStatus];

//    [self test_SecretKey];

    return YES;
}

- (void)test_multipleInstance {
    [ThinkingAnalyticsSDK setLogLevel:TDLoggingLevelDebug];
    
    NSString *appid1 = @"aaaa";
    NSString *url1 = @"https://receiver-ta-dev.thinkingdata.cn";
    TDConfig *config1 = [TDConfig new];
    config1.appid = appid1;
    config1.configureURL = url1;
//    config1.debugMode = ThinkingAnalyticsDebug;
    ThinkingAnalyticsSDK *instance1 = [ThinkingAnalyticsSDK startWithConfig:config1];
    
    [instance1 setSuperProperties:@{@"property_static": @"aaa"}];
    
//    [instance1 enableAutoTrack:ThinkingAnalyticsEventTypeAll];
    
    
    [instance1 timeEvent:@"ssss"];
    [instance1 timeEvent:@"aaaa"];

    sleep(5);
    
    [instance1 track:@"ssss"];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [instance1 track:@"aaaa"];
    });

    
}


- (void)test_autoTrack {
    [ThinkingAnalyticsSDK setLogLevel:TDLoggingLevelDebug];
    NSString *appid = @"22e445595b0f42bd8c5fe35bc44b88d6";
    NSString *url = @"https://receiver-ta-dev.thinkingdata.cn";
    TDConfig *config = [TDConfig new];
    config.appid = appid;
    config.configureURL = url;
    config.debugMode = ThinkingAnalyticsDebug;
    [ThinkingAnalyticsSDK startWithConfig:config];
    
    [[ThinkingAnalyticsSDK sharedInstance] enableAutoTrack:ThinkingAnalyticsEventTypeAppStart | ThinkingAnalyticsEventTypeAppEnd | ThinkingAnalyticsEventTypeAppInstall callback:^NSDictionary * _Nonnull(ThinkingAnalyticsAutoTrackEventType eventType, NSDictionary * _Nonnull properties) {
        if (eventType == ThinkingAnalyticsEventTypeAppStart) {
            return @{@"addkey":@"addvalue"};
        }
        if (eventType == ThinkingAnalyticsEventTypeAppEnd) {
            return @{@"updatekey":@"updatevalue"};
        }
        return @{};
    }];
}

    
- (void)test_eventTime {
    
    __index++;
    [ThinkingAnalyticsSDK setLogLevel:TDLoggingLevelDebug];
    NSString *appid = @"1b1c1fef65e3482bad5c9d0e6a823356";
    NSString *url = @"https://receiver.ta.thinkingdata.cn/";
    TDConfig *config = [TDConfig new];
    config.appid = appid;
    config.configureURL = url;
    ThinkingAnalyticsSDK *instance = [ThinkingAnalyticsSDK startWithConfig:config];
    [instance login:@"wangdaji1"];
    
    
//    TDUpdateEventModel *updateModel = [[TDUpdateEventModel alloc] initWithEventName:@"UPDATABLE_EVENT" eventID:@"test_event_id"];
//    updateModel.properties = @{@"status": @3, @"price": @100};
//    [updateModel configTime:[NSDate dateWithTimeIntervalSince1970:1667360394] timeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
//    [instance trackWithEventModel:updateModel];
//
    
    [instance track:@"wangdaji"];
    [instance track:@"wangdaji1" properties:nil time:[NSDate dateWithTimeIntervalSince1970:1667360394] timeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    
    
//    [instance enableAutoTrack:ThinkingAnalyticsEventTypeAll];
    
//    [instance timeEvent:@"yxiong"];
//    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
//    
//    NSLog(@"!!!! 1 %f", [[NSDate date] timeIntervalSince1970]);
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        NSLog(@"!!!! 2 %f", [[NSDate date] timeIntervalSince1970]);
//        dispatch_semaphore_signal(semaphore);
//    });
//    
//    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
//    NSLog(@"!!!! 3 %f", [[NSDate date] timeIntervalSince1970]);
    
//    [instance track:@"yxiong" properties:@{} time:[NSDate dateWithTimeIntervalSince1970:1667360394] timeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
}

- (void)test_AppCrash {
    [ThinkingAnalyticsSDK setLogLevel:TDLoggingLevelDebug];
    NSString *appid = @"cf918051b394495ca85d1b7787ad7243";
    NSString *url = @"https://receiver-ta-dev.thinkingdata.cn";
    TDConfig *config = [TDConfig new];
    config.appid = appid;
    config.configureURL = url;
    ThinkingAnalyticsSDK *instance = [ThinkingAnalyticsSDK startWithConfig:config];
//    [instance optInTracking];
    [instance enableAutoTrack:ThinkingAnalyticsEventTypeAll];
    
    [instance getPresetProperties];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        @try {
            NSArray.new[0];
//        } @catch (NSException *exception) {
//            
//        } @finally {
//            
//        }
    });
}

- (void)test_trackStatus {
    [ThinkingAnalyticsSDK setLogLevel:TDLoggingLevelDebug];
    NSString *appid = @"cf918051b394495ca85d1b7787ad7243";
    NSString *url = @"https://receiver-ta-dev.thinkingdata.cn";
    TDConfig *config = [TDConfig new];
    config.appid = appid;
    config.configureURL = url;
    ThinkingAnalyticsSDK *instance = [ThinkingAnalyticsSDK startWithConfig:config];
//    [instance setTrackStatus: TATrackStatusPause];
    [instance optOutTracking];
    [instance login:@"shpyoucan"];
 
    
    NSString *appid2 = @"22e445595b0f42bd8c5fe35bc44b88d6";
    NSString *url2 = @"https://receiver-ta-dev.thinkingdata.cn";
    TDConfig *config2 = [TDConfig new];
    config2.appid = appid2;
    config2.configureURL = url2;
   ThinkingAnalyticsSDK *instance2 = [ThinkingAnalyticsSDK startWithConfig:config2];
    [instance2 login:@"shpyoucan"];


    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(50 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        ThinkingAnalyticsSDK *lightInstance  = [instance createLightInstance];
        [lightInstance login:@"123ABCabc@thinkingdata.cn"];
        [lightInstance optOutTracking];
        [lightInstance setTrackStatus:TATrackStatusPause];
        
        
        [lightInstance flush];
    });

    
}

- (void)test_SecretKey  {
    [ThinkingAnalyticsSDK setLogLevel:TDLoggingLevelDebug];
    NSString *appid = @"cf918051b394495ca85d1b7787ad7243";
    NSString *url = @"https://receiver-ta-dev.thinkingdata.cn";
    TDConfig *config = [TDConfig new];
    config.appid = appid;
    config.configureURL = url;
    config.enableEncrypt = YES;
//    config.secretKey = [[TDSecretKey alloc] initWithVersion:1 publicKey:@"MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAh4AUF0aQaJ4HE3zihwu4Vmrq2trw0Mjfef0STWipkU//tVn/v4rR74woWJWwwYpz14u48P2mgpmMa1nQ3BFLy/nzzKejDT/wQLNs+U71dOEJL/fytIqNph7qib4xxmdh9kQtaec0+0TDjgTkyoSr39BOON1Rv4koq+cRAYVyR2WBqGyjIXEXrKqz78po9cIgMHwADzZZTq65aeYMy42g0jIIzK7SGpRne4hC20BpBtJWSvxBiJvcbUXtbc4QJ1zkErYq5YgiGM7u7EDIMOBxkxtNAXHLhiz/7FWjlm2OFfqh/RR34F7k0XZ4G9YYWwotDsf7f7dQTjpLB3Svm5GfdQIDAQAB"];
    [ThinkingAnalyticsSDK startWithConfig:config];
    [[ThinkingAnalyticsSDK sharedInstance] enableAutoTrack:ThinkingAnalyticsEventTypeAll];
    
    [[ThinkingAnalyticsSDK sharedInstance] track:@"test"];
//    [[ThinkingAnalyticsSDK sharedInstance] login:@"login1"];

//    [[ThinkingAnalyticsSDK sharedInstance] user_uniqAppend:@{@"abc":@[@"aaa",@"bbb",@"ccc"]}];
//    [[ThinkingAnalyticsSDK sharedInstance] flush];
    
    
    
//    [ThinkingAnalyticsSDK setLogLevel:TDLoggingLevelDebug];
//    NSString *appid1 = @"22e445595b0f42bd8c5fe35bc44b88d6";
//    NSString *url1 = @"https://receiver-ta-dev.thinkingdata.cn";
//    TDConfig *config1 = [TDConfig new];
//    config1.appid = appid1;
//    config1.configureURL = url1;
//    config1.enableEncrypt = NO;
//    ThinkingAnalyticsSDK *ins = [ThinkingAnalyticsSDK startWithConfig:config1];
//    [ins login:@"j9nb91876thmct8"];

//    [ins user_uniqAppend:@{@"abc":@[@"aaa",@"bbb",@"ccc"]}];
//    [ins flush];
}

- (void)testAPPPush:(UIApplication *)application launchOptions:(NSDictionary *)launchOptions {
//    [ThinkingAnalyticsSDK setLogLevel:TDLoggingLevelDebug];
//    NSString *appid = @"1b1c1fef65e3482bad5c9d0e6a823356";
//    NSString *url = @"http://receiver.ta.thinkingdqata.cn121/";
//    TDConfig *config = [TDConfig new];
//    config.appid = appid;
//    config.configureURL = url;
//    config.debugMode = ThinkingAnalyticsDebug;
//    config.launchOptions = launchOptions;
//    [ThinkingAnalyticsSDK startWithConfig:config];
//    [[ThinkingAnalyticsSDK sharedInstance] setSuperProperties:@{@"wangdaji#123":@"2342#aa"}];
//    
//    [[ThinkingAnalyticsSDK sharedInstance] enableAutoTrack:ThinkingAnalyticsEventTypeAll];

//    [self registerLocalNotice];
    [self registerRemoteNotifications:application];
}

- (void)test1:(UIApplication *)application launchOptions:(NSDictionary *)launchOptions {
    [ThinkingAnalyticsSDK setLogLevel:TDLoggingLevelDebug];
    NSString *appid = @"1b1c1fef65e3482bad5c9d0e6a823356";
    NSString *url = @"http://receiver.ta.thinkingdqata.cn121/";
    TDConfig *config = [TDConfig new];
    config.appid = appid;
    config.configureURL = url;
//    config.debugMode = ThinkingAnalyticsDebug;
    config.launchOptions = launchOptions;
    [ThinkingAnalyticsSDK startWithConfig:config];
    [[ThinkingAnalyticsSDK sharedInstance] login:@"j9nb91876thmct8"];
    
    [[ThinkingAnalyticsSDK sharedInstance] enableAutoTrack:ThinkingAnalyticsEventTypeAll callback:^NSDictionary * _Nonnull(ThinkingAnalyticsAutoTrackEventType eventType, NSDictionary * _Nonnull properties) {
        if (eventType == ThinkingAnalyticsEventTypeAppStart) {
            return @{@"addkey":@"addvalue"};
        }
        if (eventType == ThinkingAnalyticsEventTypeAppEnd) {
            return @{@"updatekey":@"updatevalue"};
        }
        return @{};
    }];
    [[ThinkingAnalyticsSDK sharedInstance] flush];
    [ThinkingAnalyticsSDK calibrateTimeWithNtp:@"ntp.aliyun.com"];
    [self appLaunchAction:application launchOptions:launchOptions];
    
    [[ThinkingAnalyticsSDK sharedInstance] timeEvent:@"timeEvent"];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[ThinkingAnalyticsSDK sharedInstance] track:@"timeEvent"];
    });
    
    [[ThinkingAnalyticsSDK sharedInstance] track:@"timeEvent" properties:@{@"a":@"b", @"aa":@{@"a1":@"b1"}}];
    
//    [[NSArray new] objectAtIndex:1];
    _queue1 = dispatch_queue_create("queue1", DISPATCH_QUEUE_SERIAL);
    _queue2 = dispatch_queue_create("queue2", DISPATCH_QUEUE_SERIAL);
    
}

- (void)appLaunchAction:(UIApplication *)application launchOptions:(NSDictionary *)launchOptions {
    
    [ThinkingAnalyticsSDK setLogLevel:TDLoggingLevelDebug];
    NSString *appid = @"d265efeedb2d469ca275fc3bfe569631";
    NSString *url = @"https://receiver-ta-demo.thinkingdata.cn";
    TDConfig *config = [TDConfig new];
    config.appid = appid;
    config.configureURL = url;
    config.launchOptions = launchOptions;
    [ThinkingAnalyticsSDK startWithConfig:config];
//    [ThinkingAnalyticsSDK setLogLevel:TDLoggingLevelDebug];
    
    [[ThinkingAnalyticsSDK sharedInstance] enableAutoTrack:ThinkingAnalyticsEventTypeAppStart];


    if (launchOptions && launchOptions[UIApplicationLaunchOptionsLocationKey]) {
        NSString *string = [self td_TDJSONUtil:launchOptions];
        NSArray *array = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        
        
        NSString *document = [array lastObject];

        
        NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
        timeFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
        timeFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        timeFormatter.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSString *time = [timeFormatter stringFromDate:[NSDate date]];
        NSString *documentPath = [document stringByAppendingPathComponent:time];
        [string writeToFile:documentPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
    
//    [TDToastView1 showInWindow:UIApplication.sharedApplication.keyWindow text:@"1" duration:1];
}


- (void)testOutTracking {
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    for (int i=1000; i>0; i--) {
        [[ThinkingAnalyticsSDK sharedInstance] optOutTracking];
        [[ThinkingAnalyticsSDK sharedInstance] optInTracking];
        
        BOOL isOptOut = (BOOL)[[ThinkingAnalyticsSDK sharedInstance] performSelector:@selector(isOptOut)];
        NSAssert(isOptOut == NO, @"isOptOut must equal to NO");
        
        
        dispatch_queue_t serialQueue = [ThinkingAnalyticsSDK performSelector:@selector(serialQueue)];
        dispatch_async(serialQueue, ^{
            id file = [[ThinkingAnalyticsSDK sharedInstance] performSelector:@selector(file)];
            BOOL isOptOut = (BOOL)[file performSelector:@selector(unarchiveOptOut)];
            NSAssert(isOptOut == NO, @"isOptOut must equal to NO");
        });
    }
#pragma clang diagnostic pop
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

- (void)instanceNameTest {
    
    [ThinkingAnalyticsSDK setLogLevel:TDLoggingLevelDebug];
    
    TDConfig *config1 = [[TDConfig alloc] init];
    config1.name = @"instanceName1";
    [ThinkingAnalyticsSDK startWithAppId:@"xxxx" withUrl:@"xxx" withConfig:config1];
    
    TDConfig *config2 = [[TDConfig alloc] init];
    config2.name = @"instanceName2";
    [ThinkingAnalyticsSDK startWithAppId:@"1b1c1fef65e3482bad5c9d0e6a823356"
                                 withUrl:@"http://receiver.ta.thinkingdata.cn/"
                              withConfig:config2];
    
    TDConfig *config3 = [[TDConfig alloc] init];
    config3.name = @"instanceName3";
    [ThinkingAnalyticsSDK startWithAppId:@"1b1c1fef65e3482bad5c9d0e6a823356"
                                 withUrl:@"https://receiver-ta-dev.thinkingdata.cn"
                              withConfig:config3];

    TDConfig *config4 = [[TDConfig alloc] init];
    [ThinkingAnalyticsSDK startWithAppId:@"22e445595b0f42bd8c5fe35bc44b88d6"
                                 withUrl:@"https://receiver-ta-dev.thinkingdata.cn"
                              withConfig:config4];
    
    _instance1 = [ThinkingAnalyticsSDK sharedInstanceWithAppid: @"instanceName1"];
    _instance2 = [ThinkingAnalyticsSDK sharedInstanceWithAppid: @"instanceName2"];
    _instance3 = [ThinkingAnalyticsSDK sharedInstanceWithAppid: @"instanceName3"];
    _instance4 = [ThinkingAnalyticsSDK sharedInstanceWithAppid: @"22e445595b0f42bd8c5fe35bc44b88d6"];
    _instance5 = [ThinkingAnalyticsSDK sharedInstanceWithAppid: @"1b1c1fef65e3482bad5c9d0e6a823356"];
    
    
//    [_instance1 enableAutoTrack:ThinkingAnalyticsEventTypeAll];
//    [_instance2 enableAutoTrack:ThinkingAnalyticsEventTypeAll];
    
    // login
////    [self.instance1 login:@"account_1"];
//    [self.instance2 login:@"account_2"];
//    [self.instance3 login:@"account_3"];
//    [self.instance4 login:@"account_4"];
//
    // distinctid
//    [self.instance1 identify:@"distinctId_1"];
    [self.instance2 identify:@"distinctId_2"];
    [self.instance3 identify:@"distinctId_3"];
    [self.instance4 identify:@"distinctId_4"];
//

////    [self.instance1 track:@"instanceName1_event"];
//    [self.instance2 track:@"instanceName2_event"];
//    [self.instance3 track:@"instanceName3_event"];
//    [self.instance4 track:@"instance4_event"];
    
//    [self.instance1 enableAutoTrack:ThinkingAnalyticsEventTypeAll];
    [_instance2 enableAutoTrack:ThinkingAnalyticsEventTypeAppStart];
    [_instance3 enableAutoTrack:ThinkingAnalyticsEventTypeAppStart];
    [self.instance4 enableAutoTrack:ThinkingAnalyticsEventTypeAppStart];
    
    [self.instance2 enableAutoTrack:ThinkingAnalyticsEventTypeAppStart];
    [self.instance3 enableAutoTrack:ThinkingAnalyticsEventTypeAppStart];
    [self.instance4 enableAutoTrack:ThinkingAnalyticsEventTypeAppStart];
    
//    [self.instance1 flush];
//    [self.instance2 flush];
//    [self.instance3 flush];
//    [self.instance4 flush];
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self.instance1 track:@"instance_event_1"];
//    });
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self.instance2 track:@"instance_event_2"];
//    });
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self.instance3 track:@"instance_event_3"];
//    });
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self.instance4 track:@"instance_event_4"];
//    });
    
//    [self.instance1 optInTracking];
}


- (void)applicationWillResignActive:(UIApplication *)application {
    NSLog(@" [THINKING] %@_%@",@"DEMO_",NSStringFromSelector(_cmd));
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    NSLog(@" [THINKING] %@_%@",@"DEMO_",NSStringFromSelector(_cmd));
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    NSLog(@" [THINKING] %@_%@",@"DEMO_",NSStringFromSelector(_cmd));
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    NSLog(@" [THINKING] %@_%@",@"DEMO_",NSStringFromSelector(_cmd));
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    NSLog(@" [THINKING] %@_%@",@"DEMO_",NSStringFromSelector(_cmd));
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark DeepLink

//// ios(8.0)
//- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler {
//    NSLog(@" [THINKING] %@_%@",@"DEMO_",NSStringFromSelector(_cmd));
////    [ThinkingAnalyticsSDK application:application continueUserActivity:userActivity restorationHandler:restorationHandler];
//    return YES;
//}

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

// ios(4.0, 10.0)
//- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
//    NSLog(@" [THINKING] %@_%@",@"DEMO_",NSStringFromSelector(_cmd));
//}

// ios(10.0)
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
    NSLog(@" [THINKING] 1234 %@_%@_%@",@"DEMO_",NSStringFromSelector(_cmd), error.userInfo);
}

#pragma mark 3d touch
// ios(9.0)
//- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler  API_AVAILABLE(ios(9.0)){
//    NSLog(@" [THINKING] %@_%@",@"DEMO_",NSStringFromSelector(_cmd));
//}



#pragma mark - 

- (NSString *)td_TDJSONUtil:(NSDictionary *)dic {
    Class cls = NSClassFromString(@"TDJSONUtil");
    SEL selector = NSSelectorFromString(@"JSONStringForObject:");
    IMP imp = [cls methodForSelector:selector];
    NSString * (*func)(id, SEL, id) = (void *)imp;
    NSString *string = func(self, selector, dic);
    return  string;
}

@end
