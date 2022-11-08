//
//  TAAppLifeCycle.m
//  ThinkingSDK
//
//  Created by 杨雄 on 2022/6/28.
//

#import "TAAppLifeCycle.h"
#import "TDAppState.h"

#if TARGET_OS_IOS
#import <UIKit/UIKit.h>
#endif

#if __has_include(<ThinkingSDK/TDLogging.h>)
#import <ThinkingSDK/TDLogging.h>
#else
#import "TDLogging.h"
#endif

NSNotificationName const kTAAppLifeCycleStateWillChangeNotification = @"cn.thinkingdata.TAAppLifeCycleStateWillChange";
NSNotificationName const kTAAppLifeCycleStateDidChangeNotification = @"cn.thinkingdata.TAAppLifeCycleStateDidChange";
NSString * const kTAAppLifeCycleNewStateKey = @"new";
NSString * const kTAAppLifeCycleOldStateKey = @"old";


@interface TAAppLifeCycle ()
/// 状态
@property (nonatomic, assign) TAAppLifeCycleState state;

@end

@implementation TAAppLifeCycle

+ (void)startMonitor {
    [TAAppLifeCycle shareInstance];
}

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    static TAAppLifeCycle *appLifeCycle = nil;
    dispatch_once(&onceToken, ^{
        appLifeCycle = [[TAAppLifeCycle alloc] init];
    });
    return appLifeCycle;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        // 不触发setter事件
        _state = TAAppLifeCycleStateInit;
        [self registerListeners];
        [self setupLaunchedState];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)registerListeners {
    if ([TDAppState runningInAppExtension]) {
        return;
    }

    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
#if TARGET_OS_IOS
    [notificationCenter addObserver:self
                           selector:@selector(applicationDidBecomeActive:)
                               name:UIApplicationDidBecomeActiveNotification
                             object:nil];
    
    [notificationCenter addObserver:self
                           selector:@selector(applicationDidEnterBackground:)
                               name:UIApplicationDidEnterBackgroundNotification
                             object:nil];
    
    [notificationCenter addObserver:self
                           selector:@selector(applicationWillTerminate:)
                               name:UIApplicationWillTerminateNotification
                             object:nil];

#elif TARGET_OS_OSX

//    [notificationCenter addObserver:self
//                           selector:@selector(applicationDidFinishLaunching:)
//                               name:NSApplicationDidFinishLaunchingNotification
//                             object:nil];
//
//    // 聚焦活动状态，和其他 App 之前切换聚焦，和 DidResignActive 通知会频繁调用
//    [notificationCenter addObserver:self
//                           selector:@selector(applicationDidBecomeActive:)
//                               name:NSApplicationDidBecomeActiveNotification
//                             object:nil];
//    // 失焦状态
//    [notificationCenter addObserver:self
//                           selector:@selector(applicationDidResignActive:)
//                               name:NSApplicationDidResignActiveNotification
//                             object:nil];
//
//    [notificationCenter addObserver:self
//                           selector:@selector(applicationWillTerminate:)
//                               name:NSApplicationWillTerminateNotification
//                             object:nil];
#endif
}

- (void)setupLaunchedState {
    if ([TDAppState runningInAppExtension]) {
        return;
    }
    
    dispatch_block_t mainThreadBlock = ^(){
#if TARGET_OS_IOS
        UIApplication *application = [TDAppState sharedApplication];
        BOOL isAppStateBackground = application.applicationState == UIApplicationStateBackground;
#else
        BOOL isAppStateBackground = NO;
#endif
        // 设置 app 是否是在后台自启动
        [TDAppState shareInstance].relaunchInBackground = isAppStateBackground;

        self.state = TAAppLifeCycleStateStart;
    };

    if (@available(iOS 13.0, *)) {
        // iOS 13 及以上在异步主队列的 block 修改状态的原因:+
        // 1. 保证在发送app状态改变的通知之前，SDK的初始化操作都已经完成。这样能保证在自动采集管理类发送app_start事件时公共属性已设置完毕（其实通过监听 UIApplicationDidFinishLaunchingNotification 也可以实现）
        // 2. 在包含有 SceneDelegate 的工程中，延迟获取 applicationState 才是准确的（通过监听 UIApplicationDidFinishLaunchingNotification 获取不准确）
        dispatch_async(dispatch_get_main_queue(), mainThreadBlock);
    } else {
        // iOS 13 以下通过监听 UIApplicationDidFinishLaunchingNotification 的通知来处理后台唤醒和冷启动（非延迟初始化）的情况:
        // 1. iOS 13 以下在后台被唤醒时，异步主队列的 block 不会执行。所以需要同时监听 UIApplicationDidFinishLaunchingNotification
        // 2. iOS 13 以下不会含有 SceneDelegate
#if TARGET_OS_IOS
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidFinishLaunching:)
                                                     name:UIApplicationDidFinishLaunchingNotification
                                                   object:nil];
#endif
        // 处理 iOS 13 以下冷启动，客户延迟初始化的情况。延迟初始化时，已经错过了 UIApplicationDidFinishLaunchingNotification 通知
        dispatch_async(dispatch_get_main_queue(), mainThreadBlock);
    }
}

//MARK: - Notification Action

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
#if TARGET_OS_IOS
    UIApplication *application = [TDAppState sharedApplication];
    BOOL isAppStateBackground = application.applicationState == UIApplicationStateBackground;
#else
    BOOL isAppStateBackground = NO;
#endif
    
    // 设置 app 是否是后台自启动
    [TDAppState shareInstance].relaunchInBackground = isAppStateBackground;
    
    self.state = TAAppLifeCycleStateStart;
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    TDLogDebug(@"application did become active");

#if TARGET_OS_IOS
    // 防止主动触发 UIApplicationDidBecomeActiveNotification
    if (![notification.object isKindOfClass:[UIApplication class]]) {
        return;
    }

    UIApplication *application = (UIApplication *)notification.object;
    if (application.applicationState != UIApplicationStateActive) {
        return;
    }
#elif TARGET_OS_OSX
    if (![notification.object isKindOfClass:[NSApplication class]]) {
        return;
    }

    NSApplication *application = (NSApplication *)notification.object;
    if (!application.isActive) {
        return;
    }
#endif
    
    // 设置 app 是否是后台自启动
    [TDAppState shareInstance].relaunchInBackground = NO;

    self.state = TAAppLifeCycleStateStart;
}

#if TARGET_OS_IOS
- (void)applicationDidEnterBackground:(NSNotification *)notification {
    TDLogDebug(@"application did enter background");

    // 防止主动触发 UIApplicationDidEnterBackgroundNotification
    if (![notification.object isKindOfClass:[UIApplication class]]) {
        return;
    }

    UIApplication *application = (UIApplication *)notification.object;
    if (application.applicationState != UIApplicationStateBackground) {
        return;
    }

    self.state = TAAppLifeCycleStateEnd;
}

#elif TARGET_OS_OSX
- (void)applicationDidResignActive:(NSNotification *)notification {
    TDLogDebug(@"application did resignActive");

    if (![notification.object isKindOfClass:[NSApplication class]]) {
        return;
    }

    NSApplication *application = (NSApplication *)notification.object;
    if (application.isActive) {
        return;
    }
    self.state = TAAppLifeCycleStateEnd;
}
#endif

- (void)applicationWillTerminate:(NSNotification *)notification {
    TDLogDebug(@"application will terminate");

    self.state = TAAppLifeCycleStateTerminate;
}

//MARK: - Setter

- (void)setState:(TAAppLifeCycleState)state {
    // 过滤重复的状态
    if (_state == state) {
        return;
    }
    
    // 设置 app 是否是在前台
    [TDAppState shareInstance].isActive = (state == TAAppLifeCycleStateStart);

    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:2];
    userInfo[kTAAppLifeCycleNewStateKey] = @(state);
    userInfo[kTAAppLifeCycleOldStateKey] = @(_state);

    [[NSNotificationCenter defaultCenter] postNotificationName:kTAAppLifeCycleStateWillChangeNotification object:self userInfo:userInfo];

    _state = state;

    [[NSNotificationCenter defaultCenter] postNotificationName:kTAAppLifeCycleStateDidChangeNotification object:self userInfo:userInfo];
}

@end
