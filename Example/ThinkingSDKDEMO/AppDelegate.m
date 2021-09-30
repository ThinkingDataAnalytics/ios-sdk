//
//  AppDelegate.m
//  ThinkingSDKDEMO
//
//  Created by syj on 2019/6/24.
//  Copyright © 2019年 thinking. All rights reserved.
//

#import "AppDelegate.h"
#import "AppDelegate+TDUI.h"
#import <ThinkingSDK/ThinkingAnalyticsSDK.h>

#import <ThinkingSDK/TDJSONUtil.h>
#import <CoreLocation/CoreLocation.h>
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
#import <UserNotifications/UserNotifications.h>
#endif

#import <PushKit/PushKit.h>
#import <CallKit/CallKit.h>


@interface AppDelegate () <UNUserNotificationCenterDelegate, PKPushRegistryDelegate, CLLocationManagerDelegate>

@property (nonatomic ,strong) CLLocationManager *locationMgr;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [self createRootViewController];
    [self.window makeKeyAndVisible];
    NSLog(@"%@_%@",@"DEMO_",NSStringFromSelector(_cmd));
    
    NSString *appid = @"22e445595b0f42bd8c5fe35bc44b88d6";
    NSString *url = @"https://thinkingdata_log.mm.blissgame.net/";
    TDConfig *config = [TDConfig new];
    config.appid = appid;
    config.configureURL = url;
    config.launchOptions = launchOptions;
    [ThinkingAnalyticsSDK startWithConfig:config];
    [ThinkingAnalyticsSDK setLaunchOptions:launchOptions];
    [ThinkingAnalyticsSDK setLogLevel:TDLoggingLevelDebug];
    [[ThinkingAnalyticsSDK sharedInstance] enableAutoTrack:ThinkingAnalyticsEventTypeAppStart];
    
    // 注册推送
    [self registerAPN];
    // 本地推送
    [self registerLocalNotice];
    // 远程推送
    [self registerRemoteNotifications:application];
    // voip
    [self voipRegistration];
    // 添加3D touch
    [self addShortCut:application];
    // 位置
    [self addLocation];

    if (launchOptions && launchOptions[UIApplicationLaunchOptionsLocationKey]) {
        NSString *string = [TDJSONUtil JSONStringForObject:launchOptions];
        NSArray *array = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        
        //得到文件的具体路径(默认在数组的最后一个)
        NSString *document = [array lastObject];
        
        //拼接我们自己创建的文件的路径
        NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
        timeFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
        timeFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        timeFormatter.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSString *time = [timeFormatter stringFromDate:[NSDate date]];
        NSString *documentPath = [document stringByAppendingPathComponent:time];
        [string writeToFile:documentPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        
    }
    
    return YES;
}

- (void)addShortCut:(UIApplication *)application {
    if (@available(iOS 9.0, *)) {
        application.shortcutItems=@[];
        NSMutableArray *arr = [NSMutableArray arrayWithArray:application.shortcutItems];
        UIMutableApplicationShortcutItem *shortItem1=[[UIMutableApplicationShortcutItem alloc] initWithType:@"UIApplicationShortcutIconTypePlay" localizedTitle:@"动态添加shortcut" localizedSubtitle:@"shortcut" icon:[UIApplicationShortcutIcon iconWithType: UIApplicationShortcutIconTypePlay]userInfo:@{@"firstShortcutKey1":@"fristShorcut"}];
        [arr addObject:shortItem1];
        application.shortcutItems=arr;
    }
}

- (void)registerAPN {
    
    if (@available(iOS 10.0, *)) {
        // iOS10+走UNUserNotificationCenter
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert + UNAuthorizationOptionSound) completionHandler:^(BOOL granted, NSError * _Nullable error) {
            
        }];
    } else if (@available(iOS 8.0, *)) {
        // iOS8+ 走老的推送
        UIUserNotificationSettings *setting = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:setting];
    }
}

- (void)registerRemoteNotifications:(UIApplication *)application {
    
    if (@available(iOS 10, *)) {
        UNUserNotificationCenter *notificationCenter = [UNUserNotificationCenter currentNotificationCenter];
        notificationCenter.delegate = self;
        [notificationCenter requestAuthorizationWithOptions:UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound completionHandler:^(BOOL granted, NSError * _Nullable error) {
            NSLog(@"申请权限granted = %d", granted);
            if (!error && granted) {
                NSLog(@"远程通知注册成功");
            } else {
                NSLog(@"远程通知注册失败error-%@", error);
            }
        }];
        
        [notificationCenter getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
            NSLog(@"settings = %@", settings);
        }];
        
    } else if (@available(iOS 8.0, *)) {
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeSound | UIUserNotificationTypeBadge categories:nil]];
    }
    
    // 注册远程通知，获得device Token
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    
}

- (void)registerLocalNotice {
    if (@available(iOS 10.0, *)) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
        
        content.title = @"本地推送--标题";
        content.subtitle = @"本地推送--副标题";
        content.body = @"本地推送--内容";
        content.sound = [UNNotificationSound defaultSound];
        content.badge = @1;
        NSTimeInterval time = [[NSDate dateWithTimeIntervalSinceNow:10] timeIntervalSinceNow];
        
        UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:time repeats:NO];
        
        // 添加通知的标识符，可以用于移除，更新等操作
        NSString *identifier = @"noticeId";
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:identifier content:content trigger:trigger];
        
        [center addNotificationRequest:request withCompletionHandler:^(NSError *_Nullable error) {
            NSLog(@"成功添加推送");
        }];
    }else {
        UILocalNotification *notif = [[UILocalNotification alloc] init];
        notif.fireDate = [NSDate dateWithTimeIntervalSinceNow:5];
        notif.alertBody = @"你已经10秒没出现了";
        notif.userInfo = @{@"noticeId":@"00001"};
        notif.applicationIconBadgeNumber = 1;
        notif.soundName = UILocalNotificationDefaultSoundName;
        notif.repeatInterval = NSCalendarUnitWeekOfYear;
        [[UIApplication sharedApplication] scheduleLocalNotification:notif];
    }
}


- (void)applicationWillResignActive:(UIApplication *)application {
    NSLog(@"%@_%@",@"DEMO_",NSStringFromSelector(_cmd));
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    NSLog(@"%@_%@",@"DEMO_",NSStringFromSelector(_cmd));
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    NSLog(@"%@_%@",@"DEMO_",NSStringFromSelector(_cmd));
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    NSLog(@"%@_%@",@"DEMO_",NSStringFromSelector(_cmd));
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    NSLog(@"%@_%@",@"DEMO_",NSStringFromSelector(_cmd));
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark DeepLink、文件分享

// ios(8.0)
- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler {
    NSLog(@"%@_%@",@"DEMO_",NSStringFromSelector(_cmd));
    [ThinkingAnalyticsSDK application:application continueUserActivity:userActivity restorationHandler:restorationHandler];
    return YES;
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_9_0
// ios(9.0)
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    NSLog(@"%@_%@",@"DEMO_",NSStringFromSelector(_cmd));
    if (@available(iOS 9.0, *)) {
        [ThinkingAnalyticsSDK application:app openURL:url options:options];
    } else {
        // Fallback on earlier versions
    }
    return YES;
}
#endif

#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_9_0
// ios(2.0, 9.0)
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    NSLog(@"%@_%@",@"DEMO_",NSStringFromSelector(_cmd));
    [ThinkingAnalyticsSDK application:application handleOpenURL:url];
    return YES;
}
#endif

#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_9_0
// ios(4.2, 9.0)，共享文件，小于IOS9走这里，大于IOS9走application:openURL:options:
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(nullable NSString *)sourceApplication annotation:(id)annotation {
    /NSLog(@"%@_%@",@"DEMO_",NSStringFromSelector(_cmd));
    [ThinkingAnalyticsSDK application:app openURL:url options:options];
    return YES;
}
#endif

#pragma mark 推送

#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_10_0
// ios(4.0, 10.0)
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    NSLog(@"%@_%@",@"DEMO_",NSStringFromSelector(_cmd));
    [ThinkingAnalyticsSDK application:application didReceiveLocalNotification:notification];
}
#endif

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
// ios(10.0)
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)(void))completionHandler  API_AVAILABLE(ios(10.0)){
    NSLog(@"%@_%@",@"DEMO_",NSStringFromSelector(_cmd));
    if (@available(iOS 10.0, *)) {
        [ThinkingAnalyticsSDK userNotificationCenter:center didReceiveNotificationResponse:response withCompletionHandler:completionHandler];
    } else {
        // Fallback on earlier versions
    }
    completionHandler();
}
#endif

#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_10_0
// ios(3.0, 10.0) 远程推送
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {
    NSLog(@"%@_%@",@"DEMO_",NSStringFromSelector(_cmd));
    [ThinkingAnalyticsSDK application:application didReceiveRemoteNotification:userInfo fetchCompletionHandler:completionHandler];
}
#endif

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
    
    NSLog(@"@@@@@@deviceToken==%@",token);
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"%@_%@_%@",@"DEMO_",NSStringFromSelector(_cmd), error.userInfo);
}

#pragma mark 3d touch
// ios(9.0)
- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler  API_AVAILABLE(ios(9.0)){
    NSLog(@"%@_%@",@"DEMO_",NSStringFromSelector(_cmd));
    
    [ThinkingAnalyticsSDK application:application performActionForShortcutItem:shortcutItem completionHandler:completionHandler];
}

#pragma mark VOIP推送

// Register for VoIP notifications
- (void) voipRegistration {
    if (@available(iOS 8.0, *)) {
        dispatch_queue_t mainQueue = dispatch_get_main_queue();
        PKPushRegistry * voipRegistry = [[PKPushRegistry alloc] initWithQueue: mainQueue];
        voipRegistry.delegate = self;
        if (@available(iOS 9.0, *)) {
            //            voipRegistry.desiredPushTypes = [NSSet setWithObject:PKPushTypeVoIP];
        } else {
            // Fallback on earlier versions
        }
    }
    
}

// Handle updated push credentials
- (void)pushRegistry:(PKPushRegistry *)registry didUpdatePushCredentials:(PKPushCredentials *)credentials forType:(NSString *)type {
    
    // Register VoIP push token (a property of PKPushCredentials) with server
    NSLog(@"didUpdatePushCredentials called");
    
    NSString *token = [[credentials.token description] stringByReplacingOccurrencesOfString:@"<" withString:@""];
    token = [token stringByReplacingOccurrencesOfString:@">" withString:@""];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"voip token:%@",token);
}


- (void)pushRegistry:(PKPushRegistry *)registry didReceiveIncomingPushWithPayload:(PKPushPayload *)payload forType:(NSString *)type {
    // Process the received push
    NSLog(@"%@_%@",@"DEMO_",NSStringFromSelector(_cmd));
}

#pragma mark - location

- (void)addLocation {
    _locationMgr = [[CLLocationManager alloc] init];
    _locationMgr.delegate = self;
    _locationMgr.desiredAccuracy = kCLLocationAccuracyBest;
    _locationMgr.distanceFilter = 10;
    // 主动请求定位授权
    [_locationMgr requestAlwaysAuthorization];
    // 这是iOS9中针对后台定位推出的新属性 不设置的话 可是会出现顶部蓝条的哦(类似热点连接)
    if (@available(iOS 9.0, *)) {
        [_locationMgr setAllowsBackgroundLocationUpdates:YES];
    }
    _locationMgr.pausesLocationUpdatesAutomatically = NO;
    [_locationMgr startMonitoringSignificantLocationChanges];
    [self starMonitorRegion];
}

// 监听的位置
- (NSArray *)locationArr {
    /*
     需求根据对应地图设置坐标
     iOS，原生坐标系为 WGS-84
     高德以及国内坐标系：GCS-02
     百度的偏移坐标系：BD-09
     */
    // 环球港，121.418251,31.238279
    return  @[ @{@"latitude":@"31.238279", @"longitude":@"121.418251"}];
}

// 开始监听
- (void)starMonitorRegion {
    for (CLRegion *monitoredRegion in self.locationMgr.monitoredRegions) {
        NSLog(@"移除: %@", monitoredRegion.identifier);
        [self.locationMgr stopMonitoringForRegion:monitoredRegion];
    }
    
    for (NSDictionary *dict in self.locationArr) {
        CLLocationDegrees latitude = [dict[@"latitude"] doubleValue];
        CLLocationDegrees longitude = [dict[@"longitude"] doubleValue];
        CLLocationCoordinate2D location = CLLocationCoordinate2DMake(latitude, longitude);
        [self regionObserveWithLocation:location];
    }
}

// 设置监听的位置
- (void)regionObserveWithLocation:(CLLocationCoordinate2D)location {
    if (![CLLocationManager locationServicesEnabled]) {
        NSLog(@"您的设备不支持定位");
        return;
    }
    
    // 设置区域半径
    CLLocationDistance radius = 200;
    // 使用前必须判定当前的监听区域半径是否大于最大可被监听的区域半径
    if(radius > self.locationMgr.maximumRegionMonitoringDistance) {
        radius = self.locationMgr.maximumRegionMonitoringDistance;
    }
    // 设置id
    NSString *identifier =
    [NSString stringWithFormat:@"%f , %f", location.latitude, location.longitude];
    // 使用CLCircularRegion创建一个圆形区域，
    CLRegion *fkit = [[CLCircularRegion alloc] initWithCenter:location
                                                       radius:radius
                                                   identifier:identifier];
    // 开始监听fkit区域
    [self.locationMgr startMonitoringForRegion:fkit];
}

// 进入指定区域以后将弹出提示框提示用户
- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    NSLog(@"%@_%@",@"DEMO_",NSStringFromSelector(_cmd));
    NSString *msg = [NSString stringWithFormat:@"进入指定区域 %@", region.identifier];
    [self dealAlertWithStr:msg];
}

// 离开指定区域以后将弹出提示框提示用户
- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    NSLog(@"%@_%@",@"DEMO_",NSStringFromSelector(_cmd));
    NSString *msg = [NSString stringWithFormat:@"离开指定区域 %@", region.identifier];
    [self dealAlertWithStr:msg];
}

-  (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    [self registerNotificationWithMsg:@"didUpdateLocations"];
}

- (void)dealAlertWithStr:(NSString *)msg {
    // 程序在后台
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
        [self registerNotificationWithMsg:msg];
    } else { // 程序在前台
        [self alertWithMsg:msg];
    }
}

// 本地通知
- (void)registerNotificationWithMsg:(NSString *)msg {
    
    if (@available(iOS 10.0, *)) {
        // 使用 UNUserNotificationCenter 来管理通知
        UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
        // 需创建一个包含待通知内容的 UNMutableNotificationContent 对象
        UNMutableNotificationContent* content = [[UNMutableNotificationContent alloc] init];
        content.title = [NSString localizedUserNotificationStringForKey:@"通知"
                                                              arguments:nil];
        content.body = [NSString localizedUserNotificationStringForKey:msg
                                                             arguments:nil];
        content.sound = [UNNotificationSound defaultSound];
        NSInteger alerTime = 1;
        // 在 alertTime 后推送本地推送
        UNTimeIntervalNotificationTrigger *trigger =
        [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:alerTime
                                                           repeats:NO];
        UNNotificationRequest* request =
        [UNNotificationRequest requestWithIdentifier:@"FiveSecond"
                                             content:content
                                             trigger:trigger];
        
        //添加推送成功后的处理！
        [center addNotificationRequest:request withCompletionHandler:^(NSError *error) {
            if (error) {
                NSLog(@"添加推送失败 error : %@", error);
            } else {
                NSLog(@"添加推送成功");
            }
        }];
    }
}

- (void)alertWithMsg:(NSString *)msg {
    UIAlertController *alert =
    [UIAlertController alertControllerWithTitle:@"通知"
                                        message:msg
                                 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"我知道了"
                                                     style:UIAlertActionStyleCancel
                                                   handler:nil];
    [alert addAction:action];
    UIViewController *vc =
    [UIApplication sharedApplication].keyWindow.rootViewController;
    [vc presentViewController:alert animated:YES completion:nil];
}




@end




// 使用 NTP Server 校准时间
//    [ThinkingAnalyticsSDK calibrateTimeWithNtp:@"ntp.aliyun.com"];
// 开启 Log
//    [ThinkingAnalyticsSDK setLogLevel:TDLoggingLevelDebug];
// 初始化
// 配置初始化方法
//    TDConfig *config = [[TDConfig alloc] init];
//    config.launchOptions = launchOptions;
//    config.trackRelaunchedInBackgroundEvents = YES;
//    //    config.debugMode = ThinkingAnalyticsDebugOnly;
//    //    config.debugMode = ThinkingAnalyticsDebug;
//    config.defaultTimeZone = [NSTimeZone timeZoneWithName:@"UTC+0900"];

//    [ThinkingAnalyticsSDK startWithAppId:@"7a055a4bd7ec423fa5294b4a2c1eff28"
//                                 withUrl:@"https://receiver-ta-dev.thinkingdata.cn"
//                              withConfig:config];
//    [ThinkingAnalyticsSDK startWithAppId:@"debug-appid"
//                                 withUrl:@"http://47.112.250.224"
//                             ];
//    [[ThinkingAnalyticsSDK sharedInstance] addWebViewUserAgent];
//    [[ThinkingAnalyticsSDK sharedInstance] enableAutoTrack:ThinkingAnalyticsEventTypeAppEnd];
//    [[ThinkingAnalyticsSDK sharedInstance] timeEvent:@"test"];



// 配置初始化方法
//    TDConfig *config = [[TDConfig alloc] init];
//    config.trackRelaunchedInBackgroundEvents = YES;
//    config.debugMode = ThinkingAnalyticsDebugOnly;
//    config.debugMode = ThinkingAnalyticsDebug;
//    config.defaultTimeZone = [NSTimeZone timeZoneWithName:@"UTC+0900"];
//    ThinkingAnalyticsSDK *instance = [ThinkingAnalyticsSDK startWithAppId:@"APP" withUrl:@"https://sdk.tga.thinkinggame.cn:9443" withConfig:config];

// 自动埋点
//    [[ThinkingAnalyticsSDK sharedInstance] enableAutoTrack:
//     ThinkingAnalyticsEventTypeAppStart |
//     ThinkingAnalyticsEventTypeAppEnd |
//     ThinkingAnalyticsEventTypeAppViewScreen |
//     ThinkingAnalyticsEventTypeAppClick |
//     ThinkingAnalyticsEventTypeAppInstall //|
////     ThinkingAnalyticsEventTypeAppViewCrash
//     ];

// H5 需要打通时                 配置
//    [[ThinkingAnalyticsSDK sharedInstance] addWebViewUserAgent];
