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
#import <ThinkingSDK/TDLogging.h>
#import "TDDemoLocation.h"

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
#import <UserNotifications/UserNotifications.h>
#endif

#import <PushKit/PushKit.h>
#import <CallKit/CallKit.h>
#import <AppsFlyerLib/AppsFlyerLib.h>
#import "IronSource/IronSource.h"
#import "Adjust.h"
#import "Branch/Branch.h"
#import <AnyThinkSDK/AnyThinkSDK.h>

// 目前ReYunFramework、TradPlusAds 的framework，在模拟器上不能运行
#if (TARGET_IPHONE_SIMULATOR == 0)
#import <ReYunFramework/Tracking.h>
#import <TradPlusAds/TradPlus.h>
#endif

// 引入 JPush 功能所需头文件
# import "JPUSHService.h"
// iOS10 注册 APNs 所需头文件
# ifdef NSFoundationVersionNumber_iOS_9_x_Max
# import <UserNotifications/UserNotifications.h>
# endif
// 如果需要使用 idfa 功能所需要引入的头文件（可选）
# import <AdSupport/AdSupport.h>

@interface AppDelegate () <UNUserNotificationCenterDelegate, PKPushRegistryDelegate>

@property(nonatomic, strong) TDDemoLocation *location1;
@property(nonatomic, strong) TDDemoLocation *location2;

@property(nonatomic, strong) ThinkingAnalyticsSDK *instance1;
@property(nonatomic, strong) ThinkingAnalyticsSDK *instance2;
@property(nonatomic, strong) ThinkingAnalyticsSDK *instance3;
@property(nonatomic, strong) ThinkingAnalyticsSDK *instance4;
@property(nonatomic, strong) ThinkingAnalyticsSDK *instance5;

@property(nonatomic, strong)dispatch_queue_t queue1;
@property(nonatomic, strong)dispatch_queue_t queue2;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    NSLog(@" [THINKING] home: %@", NSHomeDirectory());
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [self createRootViewController];
    [self.window makeKeyAndVisible];
    NSLog(@" [THINKING] %@_%@",@"DEMO_",NSStringFromSelector(_cmd));
    
    NSLog(@" [THINKING]  %@", launchOptions);
    
//    [self test_multipleInstance];
    

//    [self test_eventTime];
//    [self test_AppCrash];
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        raise(SIGABRT);
////        raise(SIGPIPE);
//    });
    
    [self testAPPPush:application launchOptions:launchOptions];

//    [self test_thirdParty: launchOptions];
    
//    [self test_trackStatus];

//    [self test_SecretKey];
//    [self test_thirdParty];
//    [self test1:application launchOptions:launchOptions];
//    [self test_autoTrack];

//    [JPUSHService setupWithOption:launchOptions appKey:@"4c03c99227364f137e25e77f"
//                          channel:@""
//                 apsForProduction:NO
//            advertisingIdentifier:@""];

//    [self appLaunchAction:application launchOptions:launchOptions];
    
    
    
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
    
    [instance1 enableAutoTrack:ThinkingAnalyticsEventTypeAll];
    
    [instance1 track:@"ssss"];
    
    [instance1 clearSuperProperties];
    
//    NSString *appid2 = @"";
//    NSString *url2 = @"https://receiver-ta-dev.thinkingdata.cn";
//    TDConfig *config2 = [TDConfig new];
//    config2.appid = appid2;
//    config2.configureURL = url2;
//    config2.debugMode = ThinkingAnalyticsDebug;
//    ThinkingAnalyticsSDK *instance2 = [ThinkingAnalyticsSDK startWithConfig:config2];
//    [instance2 enableAutoTrack:ThinkingAnalyticsEventTypeAll];
}

/// 测试自动埋点
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
    [ThinkingAnalyticsSDK setLogLevel:TDLoggingLevelDebug];
    NSString *appid = @"cf918051b394495ca85d1b7787ad7243";
    NSString *url = @"https://receiver-ta-dev.thinkingdata.cn";
    TDConfig *config = [TDConfig new];
    config.appid = appid;
    config.configureURL = url;
    ThinkingAnalyticsSDK *instance = [ThinkingAnalyticsSDK startWithConfig:config];
    
    [instance timeEvent:@"yxiong"];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    NSLog(@"!!!! 1 %f", [[NSDate date] timeIntervalSince1970]);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"!!!! 2 %f", [[NSDate date] timeIntervalSince1970]);
        dispatch_semaphore_signal(semaphore);
    });
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    NSLog(@"!!!! 3 %f", [[NSDate date] timeIntervalSince1970]);
    
    [instance track:@"yxiong"];
}

- (void)test_AppCrash {
    [ThinkingAnalyticsSDK setLogLevel:TDLoggingLevelDebug];
    NSString *appid = @"cf918051b394495ca85d1b7787ad7243";
    NSString *url = @"https://receiver-ta-dev.thinkingdata.cn";
    TDConfig *config = [TDConfig new];
    config.appid = appid;
    config.configureURL = url;
    ThinkingAnalyticsSDK *instance = [ThinkingAnalyticsSDK startWithConfig:config];
    [instance optInTracking];
    [instance enableAutoTrack:ThinkingAnalyticsEventTypeAll];
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
    [instance track:@"trackStatus_test_event" properties:@{
        @"info": @"测试数据上报状态-track0000000000"
    }];
    [instance user_set:@{
        @"info": @"测试数据上报状态-user00000000000"
    }];
    
    NSString *appid2 = @"22e445595b0f42bd8c5fe35bc44b88d6";
    NSString *url2 = @"https://receiver-ta-dev.thinkingdata.cn";
    TDConfig *config2 = [TDConfig new];
    config2.appid = appid2;
    config2.configureURL = url2;
   ThinkingAnalyticsSDK *instance2 = [ThinkingAnalyticsSDK startWithConfig:config2];
    [instance2 login:@"shpyoucan"];
    [instance2 track:@"trackStatus_test_event" properties:@{
        @"info2": @"测试数据上报状态-track"
    }];
    [instance2 user_set:@{
        @"info2": @"测试数据上报状态-user"
    }];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(50 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //通过之前创建的实例，调用createLightInstance生成轻实例
        ThinkingAnalyticsSDK *lightInstance  = [instance createLightInstance];
        [lightInstance login:@"123ABCabc@thinkingdata.cn"];
        [lightInstance optOutTracking];
        [lightInstance setTrackStatus:TATrackStatusPause];
        [lightInstance track:@"some_event" properties:@{
            @"info": @"轻实例-测试数据上报状态-track"
        }];
        [lightInstance user_set:@{
            @"info": @"轻实例-测试数据上报状态-user"
        }];
        
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
    config.secretKey = [[TDSecretKey alloc] initWithVersion:1 publicKey:@"MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCzAKEGsq67Yd03/RF77VKJ/cQ3\nzfSboK1wzlQfH2E1fr504WCJHHL/UVgjfUGUjMLIN15FNEelp7TXLToqtYlqqMbE\nXCfSc14ulRatKQioYnJ8EzgUhG0HcRlulni6vxGJHR9iq4weDNyJFRaZuwIQSrUz\nIaiVq/3hYijxxhhFqQIDAQAB"];
    [ThinkingAnalyticsSDK startWithConfig:config];
    [[ThinkingAnalyticsSDK sharedInstance] login:@"login1"];
    [[ThinkingAnalyticsSDK sharedInstance] track:@"secret_event" properties:@{@"a":@"asadas",@"b":@"djGNVWOzMC/4D2v/JGN.EsH3uP2stjoZ=+/", @"wangdaji":@"王大吉"}];
    [[ThinkingAnalyticsSDK sharedInstance] user_uniqAppend:@{@"abc":@[@"aaa",@"bbb",@"ccc"]}];
    [[ThinkingAnalyticsSDK sharedInstance] flush];
    
    
    
    [ThinkingAnalyticsSDK setLogLevel:TDLoggingLevelDebug];
    NSString *appid1 = @"22e445595b0f42bd8c5fe35bc44b88d6";
    NSString *url1 = @"https://receiver-ta-dev.thinkingdata.cn";
    TDConfig *config1 = [TDConfig new];
    config1.appid = appid1;
    config1.configureURL = url1;
    config1.enableEncrypt = NO;
    ThinkingAnalyticsSDK *ins = [ThinkingAnalyticsSDK startWithConfig:config1];
    [ins login:@"j9nb91876thmct8"];
    [ins track:@"test_event" properties:@{@"a":@"asadas",@"b":@"djGNVWOzMC/4D2v/JGN.EsH3uP2stjoZ=+/", @"wangdaji":@"王大吉"}];
    [ins user_uniqAppend:@{@"abc":@[@"aaa",@"bbb",@"ccc"]}];
    [ins flush];
}

- (void)test_thirdParty:(NSDictionary *)launchOptions {
    
    [AppsFlyerLib shared].isDebug = 1;
    [[AppsFlyerLib shared] setIsDebug:YES];
    [AppsFlyerLib shared].appsFlyerDevKey = @"FVAvxeH7HPCVZ67QrjQPqQ";
    [AppsFlyerLib shared].appleAppID = @"1562111162";
    [AppsFlyerLib shared].delegate = self;

    
    
    [ThinkingAnalyticsSDK setLogLevel:TDLoggingLevelDebug];
    NSString *appid = @"1b1c1fef65e3482bad5c9d0e6a823356";
    NSString *url = @"http://receiver.ta.thinkingdata.cn/";
    TDConfig *config = [TDConfig new];
    config.appid = appid;
    config.configureURL = url;
    [ThinkingAnalyticsSDK startWithConfig:config];
    [[ThinkingAnalyticsSDK sharedInstance] login:@"j9nb91876thmct8"];
    [[ThinkingAnalyticsSDK sharedInstance] track:@"timeEvent" properties:@{@"a":@"b", @"aa":@{@"a1":@"b1"}}];

    
    //MARK: AF发事件
    [[ThinkingAnalyticsSDK sharedInstance] enableThirdPartySharing: TAThirdPartyShareTypeAPPSFLYER customMap:@{@"ta_data11":@"ta_value11"}];
    [[AppsFlyerLib shared] logEvent:@"af_eventname" withValues:@{@"key":@"value"}];
    [[AppsFlyerLib shared] start];

    //MARK: IRON发事件
    [[ThinkingAnalyticsSDK sharedInstance] enableThirdPartySharing: TAThirdPartyShareTypeIRONSOURCE];

    [IronSource addImpressionDataDelegate:self];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self impressionDataDidSucceed:ISImpressionData.new];
    });
    
    //MARK: Adjust
    [[ThinkingAnalyticsSDK sharedInstance] enableThirdPartySharing:TAThirdPartyShareTypeADJUST];
    NSString *yourAppToken = @"{YourAppToken}";
    NSString *environment = ADJEnvironmentSandbox;
    ADJConfig *adjustConfig = [ADJConfig configWithAppToken:yourAppToken
                                      environment:environment];
    
    [Adjust appDidLaunch:adjustConfig];
    
    //MARK: Branch
    [[ThinkingAnalyticsSDK sharedInstance] enableThirdPartySharing:TAThirdPartyShareTypeBRANCH];
    // if you are using the TEST key
    [Branch setUseTestBranchKey:YES];
    // listener for Branch Deep Link data
    [[Branch getInstance] initSessionWithLaunchOptions:launchOptions andRegisterDeepLinkHandler:^(NSDictionary * _Nonnull params, NSError * _Nullable error) {
      // do stuff with deep link data (nav to page, display content, etc)
      NSLog(@"%@", params);
    }];
    
    //MARK: TopOn
    [[ThinkingAnalyticsSDK sharedInstance] enableThirdPartySharing:TAThirdPartyShareTypeTOPON];
    [ATAPI setLogEnabled:YES];//Turn on debug logs
    [ATAPI integrationChecking];
    [[ATAPI sharedInstance] startWithAppID:@"a5acc73c25fbf5" appKey:@"4f7b9ac17decb9babec83aac078742c7" error:nil];
    
    
    // 目前ReYunFramework、TradPlusAds 的framework，在模拟器上不能运行
#if (TARGET_IPHONE_SIMULATOR == 0)
    //MARK: 热云
    [[ThinkingAnalyticsSDK sharedInstance] enableThirdPartySharing:TAThirdPartyShareTypeTRACKING];
    [Tracking initWithAppKey:@"475938c702f7451a88eaffb524962649"withChannelId:@"_default_"];
    
    
    //MARK: TradPlus
    [[ThinkingAnalyticsSDK sharedInstance] enableThirdPartySharing:TAThirdPartyShareTypeTRADPLUS];
    [TradPlus initSDK:@"tradplus后台的应用对应appid" completionBlock:^(NSError *error){
            if (!error)
            {
                MSLogInfo(@"tradplus sdk init success!");
            }
        }];
#endif
    
}

- (void)impressionDataDidSucceed:(ISImpressionData *)impressionData {
    NSLog(@"IronSource - impressionDataDidSucceed");
}


- (void)testAPPPush:(UIApplication *)application launchOptions:(NSDictionary *)launchOptions {
    [ThinkingAnalyticsSDK setLogLevel:TDLoggingLevelDebug];
    NSString *appid = @"1b1c1fef65e3482bad5c9d0e6a823356";
    NSString *url = @"http://receiver.ta.thinkingdqata.cn121/";
    TDConfig *config = [TDConfig new];
    config.appid = appid;
    config.configureURL = url;
//    config.debugMode = ThinkingAnalyticsDebug;
    config.launchOptions = launchOptions;
    [ThinkingAnalyticsSDK startWithConfig:config];
    
    [[ThinkingAnalyticsSDK sharedInstance] enableAutoTrack:ThinkingAnalyticsEventTypeAll];

    [self registerLocalNotice];
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
  
    
//    for (int j = 30; j>0; j--) {
//        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
//        for (int i = 100; i>0; i--) {
//            [dic setObject:[NSString stringWithFormat:@"很大概率重很大概率重很大概率重很大概率重很大概率重很大概率重很大概率重很大概率重很大概率重很大概率重很大概率重很大概率重很大概率重很大概率重很大概率重很大概率重很大概率重很大概率重很大概率重_%i_新开启执行失败__%i", i, i]
//                    forKey:[NSString stringWithFormat:@"停止上报和很大概率重很大概率重很大概率重很大概率重很大概率重很大概率重很大概率重很大概率重很大概率重很大概率重很大概率重很大概率重很大概率重重_%i_新开启上传同时执行时__%i", i, i]];
//        }
//
//        [[ThinkingAnalyticsSDK sharedInstance] track:@"aaaa" properties:dic];
//    }
//    [[ThinkingAnalyticsSDK sharedInstance] track:@"aaaa"];
   
    
    // 停止上报和重新开启上传同时执行时, 很大概率重新开启执行失败
//    [self testOutTracking];
    
    // 多语言适配
    // 西班牙语作为value，可以正常上传
//    [[ThinkingAnalyticsSDK sharedInstance] track:@"wangdaji_track" properties:@{@"key": @"Español"}];
    // 西班牙语作为key，会提示property的key错误，可以正常上传
//    [[ThinkingAnalyticsSDK sharedInstance] track:@"wangdaji_track" properties:@{@"Español": @"Español"}];
    // 西班牙语作为event name，会提示event name错误，可以正常上传
//    [[ThinkingAnalyticsSDK sharedInstance] track:@"Español" properties:@{@"key": @"value"}];
    
    // 本地推送
//    [self registerLocalNotice];
    // 注册远程推送
    [self registerRemoteNotifications:application];
    // voip
    [self voipRegistration];
    // 添加3D touch
    [self addShortCut:application];
    // 位置
    self.location1 = TDDemoLocation.new;
//    self.location2 = TDDemoLocation.new;

    if (launchOptions && launchOptions[UIApplicationLaunchOptionsLocationKey]) {
        NSString *string = [self td_TDJSONUtil:launchOptions];
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
    
//    [TDToastView1 showInWindow:UIApplication.sharedApplication.keyWindow text:@"1" duration:1];
}

// 停止上报和重新开启上传同时执行时, 很大概率重新开启执行失败
- (void)testOutTracking {
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    for (int i=1000; i>0; i--) {
        [[ThinkingAnalyticsSDK sharedInstance] optOutTracking];
        [[ThinkingAnalyticsSDK sharedInstance] optInTracking];
        // 内存的isOptOut是否正确
        BOOL isOptOut = (BOOL)[[ThinkingAnalyticsSDK sharedInstance] performSelector:@selector(isOptOut)];
        NSAssert(isOptOut == NO, @"isOptOut must equal to NO");
        
        //持久化的isOptOut是否正确
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
        UIMutableApplicationShortcutItem *shortItem1=[[UIMutableApplicationShortcutItem alloc] initWithType:@"UIApplicationShortcutIconTypePlay" localizedTitle:@"动态添加shortcut" localizedSubtitle:@"shortcut" icon:[UIApplicationShortcutIcon iconWithType: UIApplicationShortcutIconTypePlay]userInfo:@{@"firstShortcutKey1":@"fristShorcut"}];
        [arr addObject:shortItem1];
        application.shortcutItems=arr;
    }
}

- (void)registerRemoteNotifications:(UIApplication *)application {

    if (@available(iOS 10, *)) {
        UNUserNotificationCenter *notificationCenter = [UNUserNotificationCenter currentNotificationCenter];
        notificationCenter.delegate = self;
        [notificationCenter requestAuthorizationWithOptions:UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound completionHandler:^(BOOL granted, NSError * _Nullable error) {
            NSLog(@" [THINKING] 申请权限granted = %d", granted);
            if (!error && granted) {
                NSLog(@" [THINKING] 远程通知注册成功");
            } else {
                NSLog(@" [THINKING] 远程通知注册失败error-%@", error);
            }
        }];

        [notificationCenter getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
            NSLog(@" [THINKING] settings = %@", settings);
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
        center.delegate = self;
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
            NSLog(@" [THINKING] 成功添加推送");
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
        
        // iOS8+ 走老的推送
        UIUserNotificationSettings *setting = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:setting];
    }
    // H5 需要打通时  需要配置
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
//    // 事件
////    [self.instance1 track:@"instanceName1_event"];
//    [self.instance2 track:@"instanceName2_event"];
//    [self.instance3 track:@"instanceName3_event"];
//    [self.instance4 track:@"instance4_event"];
    
    // 自动化采集
//    [self.instance1 enableAutoTrack:ThinkingAnalyticsEventTypeAll];
    [_instance2 enableAutoTrack:ThinkingAnalyticsEventTypeAppStart];
    [_instance3 enableAutoTrack:ThinkingAnalyticsEventTypeAppStart];
    [self.instance4 enableAutoTrack:ThinkingAnalyticsEventTypeAppStart];
    
    // 自动化采集多次初始化
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
//    [[AppsFlyerLib shared] start];
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    NSLog(@" [THINKING] %@_%@",@"DEMO_",NSStringFromSelector(_cmd));
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark DeepLink、文件分享

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

// ios(4.2, 9.0)，共享文件，小于IOS9走这里，大于IOS9走application:openURL:options:
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(nullable NSString *)sourceApplication annotation:(id)annotation {
    NSLog(@" [THINKING] %@_%@",@"DEMO_",NSStringFromSelector(_cmd));
    return YES;
}

#pragma mark 推送

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

// ios(3.0, 10.0) 点击远程推送/前台时收到推送
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
    
    /// Required - 注册 DeviceToken
      [JPUSHService registerDeviceToken:deviceToken];
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@" [THINKING] %@_%@_%@",@"DEMO_",NSStringFromSelector(_cmd), error.userInfo);
}

#pragma mark 3d touch
// ios(9.0)
//- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler  API_AVAILABLE(ios(9.0)){
//    NSLog(@" [THINKING] %@_%@",@"DEMO_",NSStringFromSelector(_cmd));
//}

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
    NSLog(@" [THINKING] didUpdatePushCredentials called");
    
    NSString *token = [[credentials.token description] stringByReplacingOccurrencesOfString:@"<" withString:@""];
    token = [token stringByReplacingOccurrencesOfString:@">" withString:@""];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@" [THINKING] voip token:%@",token);
}


- (void)pushRegistry:(PKPushRegistry *)registry didReceiveIncomingPushWithPayload:(PKPushPayload *)payload forType:(NSString *)type {
    // Process the received push
    NSLog(@" [THINKING] %@_%@",@"DEMO_",NSStringFromSelector(_cmd));
}


#pragma mark - 序列化

- (NSString *)td_TDJSONUtil:(NSDictionary *)dic {
    Class cls = NSClassFromString(@"TDJSONUtil");
    SEL selector = NSSelectorFromString(@"JSONStringForObject:");
    IMP imp = [cls methodForSelector:selector];
    NSString * (*func)(id, SEL, id) = (void *)imp;
    NSString *string = func(self, selector, dic);
    return  string;
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



// 配置初始化方法
//    TDConfig *config = [[TDConfig alloc] init];
//    config.trackRelaunchedInBackgroundEvents = YES;
//    config.debugMode = ThinkingAnalyticsDebugOnly;
//    config.debugMode = ThinkingAnalyticsDebug;
//    config.defaultTimeZone = [NSTimeZone timeZoneWithName:@"UTC+0900"];
//    ThinkingAnalyticsSDK *instance = [ThinkingAnalyticsSDK startWithAppId:@"APP" withUrl:@"https://sdk.tga.thinkinggame.cn:9443" withConfig:config];
