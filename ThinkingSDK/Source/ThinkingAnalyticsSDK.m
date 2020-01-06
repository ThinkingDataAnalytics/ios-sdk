#import "ThinkingAnalyticsSDKPrivate.h"

#import "TDAutoTrackManager.h"

#if !__has_feature(objc_arc)
#error The ThinkingSDK library must be compiled with ARC enabled
#endif

@interface ThinkingAnalyticsSDK ()

@property (atomic, strong) TDNetwork *network;
@property (atomic, strong) TDAutoTrackManager *autoTrackManager;

@end

@implementation ThinkingAnalyticsSDK

static ThinkingAnalyticsSDK *sharedInstance = nil;

static NSMutableDictionary *instances;
static NSString *defaultProjectAppid;
static BOOL isWifi;
static NSString *radioInfo;

static dispatch_queue_t serialQueue;
static dispatch_queue_t networkQueue;

+ (nullable ThinkingAnalyticsSDK *)sharedInstance {
    if (instances.count == 0) {
        TDLogError(@"sharedInstance called before creating a Thinking instance");
        return nil;
    }
    
    return instances[defaultProjectAppid];
}

+ (ThinkingAnalyticsSDK *)sharedInstanceWithAppid:(NSString *)appid {
    if (instances[appid]) {
        return instances[appid];
    } else {
        TDLogError(@"sharedInstanceWithAppid called before creating a Thinking instance");
        return nil;
    }
}

+ (ThinkingAnalyticsSDK *)startWithAppId:(NSString *)appId withUrl:(NSString *)url withConfig:(TDConfig *)config {
    if (instances[appId]) {
        return instances[appId];
    } else if (![url isKindOfClass:[NSString class]] || url.length == 0) {
        return nil;
    }
    
    return [[self alloc] initWithAppkey:appId withServerURL:url withConfig:config];
}

+ (ThinkingAnalyticsSDK *)startWithAppId:(NSString *)appId withUrl:(NSString *)url {
    return [ThinkingAnalyticsSDK startWithAppId:appId withUrl:url withConfig:nil];
}

- (instancetype)init:(NSString *)appID {
    if (self = [super init]) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            instances = [NSMutableDictionary dictionary];
            defaultProjectAppid = appID;
        });
    }
    
    return self;
}

+ (void)initialize {
    static dispatch_once_t ThinkingOnceToken;
    dispatch_once(&ThinkingOnceToken, ^{
        NSString *queuelabel = [NSString stringWithFormat:@"com.Thinkingdata.%p", (void *)self];
        serialQueue = dispatch_queue_create([queuelabel UTF8String], DISPATCH_QUEUE_SERIAL);
        NSString *networkLabel = [queuelabel stringByAppendingString:@".network"];
        networkQueue = dispatch_queue_create([networkLabel UTF8String], DISPATCH_QUEUE_SERIAL);
    });
}

+ (dispatch_queue_t)serialQueue {
    return serialQueue;
}

+ (dispatch_queue_t)networkQueue {
    return networkQueue;
}

- (instancetype)initLight:(NSString *)appid withServerURL:(NSString *)serverURL withConfig:(TDConfig *)config {
    if (self = [self init]) {
        _appid = appid;
        _isEnabled = YES;
        _config = [config copy];
        self.deviceInfo = [TDDeviceInfo sharedManager];
        
        self.trackTimer = [NSMutableDictionary dictionary];
        _timeFormatter = [[NSDateFormatter alloc] init];
        _timeFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
        _timeFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        _timeFormatter.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        
        self.telephonyInfo = [[CTTelephonyNetworkInfo alloc] init];
        
        NSString *keyPattern = @"^[a-zA-Z][a-zA-Z\\d_]{0,49}$";
        self.regexKey = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", keyPattern];
        
        self.dataQueue = [TDSqliteDataQueue sharedInstanceWithAppid:appid];
        if (self.dataQueue == nil) {
            TDLogError(@"SqliteException: init SqliteDataQueue failed");
        }
        
        self.debugEventsQueue = [NSMutableArray array];
        
        _network = [[TDNetwork alloc] init];
        _network.debugMode = config.debugMode;
        _network.appid = appid;
        _network.sessionDidReceiveAuthenticationChallenge = config.securityPolicy.sessionDidReceiveAuthenticationChallenge;
        if (config.debugMode == ThinkingAnalyticsDebugOnly || config.debugMode == ThinkingAnalyticsDebug) {
            _network.serverDebugURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/data_debug", serverURL]];
        }
        _network.automaticData = _deviceInfo.automaticData;
        _network.securityPolicy = config.securityPolicy;
    }
    return self;
}

- (instancetype)initWithAppkey:(NSString *)appid withServerURL:(NSString *)serverURL withConfig:(TDConfig *)config {
    if (self = [self init:appid]) {
        self.serverURL = serverURL;
        self.appid = appid;
        
        if (!config) {
            config = TDConfig.defaultTDConfig;
        }
        
        _config = [config copy];
        _config.appid = appid;
        _config.configureURL = [NSString stringWithFormat:@"%@/config",serverURL];
        
        self.deviceInfo = [TDDeviceInfo sharedManager];
        [self retrievePersistedData];
        [_config updateConfig];
        
        self.trackTimer = [NSMutableDictionary dictionary];
        _timeFormatter = [[NSDateFormatter alloc] init];
        _timeFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
        _timeFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        _timeFormatter.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];

        _applicationWillResignActive = NO;
        _ignoredViewControllers = [[NSMutableSet alloc] init];
        _ignoredViewTypeList = [[NSMutableSet alloc] init];
        
        self.taskId = UIBackgroundTaskInvalid;
        self.telephonyInfo = [[CTTelephonyNetworkInfo alloc] init];
        
        NSString *keyPattern = @"^[a-zA-Z][a-zA-Z\\d_]{0,49}$";
        self.regexKey = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", keyPattern];
        NSString *keyAutoTrackPattern = @"^([a-zA-Z][a-zA-Z\\d_]{0,49}|\\#(resume_from_background|app_crashed_reason|screen_name|referrer|title|url|element_id|element_type|element_content|element_position))$";
        self.regexAutoTrackKey = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", keyAutoTrackPattern];
        
        self.dataQueue = [TDSqliteDataQueue sharedInstanceWithAppid:appid];
        if (self.dataQueue == nil) {
            TDLogError(@"SqliteException: init SqliteDataQueue failed");
        }
        
        [self setApplicationListeners];
        [self setNetRadioListeners];
        
        self.autoTrackManager = [TDAutoTrackManager sharedManager];
        self.debugEventsQueue = [NSMutableArray array];

        _network = [[TDNetwork alloc] init];
        _network.debugMode = config.debugMode;
        _network.appid = appid;
        _network.sessionDidReceiveAuthenticationChallenge = config.securityPolicy.sessionDidReceiveAuthenticationChallenge;
        if (config.debugMode == ThinkingAnalyticsDebugOnly || config.debugMode == ThinkingAnalyticsDebug) {
            _network.serverDebugURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/data_debug",serverURL]];
        }
        _network.serverURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/sync",serverURL]];
        _network.automaticData = _deviceInfo.automaticData;
        _network.securityPolicy = config.securityPolicy;
        
        [self sceneSupportSetting];
        
        if (@available(iOS 13.0, *)) {
            if (!_isEnableSceneSupport) {
                [self launchedIntoBackground];
            } else if (config.launchOptions && [config.launchOptions objectForKey:UIApplicationLaunchOptionsLocationKey]) {
                _relaunchInBackGround = YES;
            } else {
                _relaunchInBackGround = NO;
            }
        } else {
            [self launchedIntoBackground];
        }
        
        instances[appid] = self;
        
        if(instances.count == 1) {
            TDLogInfo(@"Thank you very much for using Thinking Data SDK. We will do our best to provide you with the best service.");
            TDLogInfo(@"Thinking Data SDK version:%@, DeviceId:%@", [TDDeviceInfo libVersion], [self getDeviceId]);
        }
    }
    return self;
}

- (void)launchedIntoBackground {
    td_dispatch_main_sync_safe(^{
        UIApplicationState applicationState = [UIApplication sharedApplication].applicationState;
        if (applicationState == UIApplicationStateBackground) {
            self->_relaunchInBackGround = YES;
        }
    });
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<ThinkingAnalyticsSDK: %p - appid: %@ serverUrl: %@>", (void *)self, self.appid, self.serverURL];
}

+ (UIApplication *)sharedUIApplication {
    if ([[UIApplication class] respondsToSelector:@selector(sharedApplication)]) {
        return [[UIApplication class] performSelector:@selector(sharedApplication)];
    }
    return nil;
}

#pragma mark - EnableTracking
- (void)enableTracking:(BOOL)enabled {
    self.isEnabled = enabled;
    
    dispatch_async(serialQueue, ^{
        [self archiveIsEnabled:self.isEnabled];
    });
}

- (BOOL)hasDisabled {
    return !_isEnabled || _isOptOut;
}

- (void)optOutTracking {
    TDLogDebug(@"%@ optOutTracking...", self);
    self.isOptOut = YES;
    
    @synchronized (self.trackTimer) {
        [self.trackTimer removeAllObjects];
    }
    
    @synchronized (self.superProperty) {
        self.superProperty = [NSDictionary new];
    }
    
    @synchronized (self.identifyId) {
        self.identifyId = self.deviceInfo.uniqueId;
    }
    
    @synchronized (self.accountId) {
        self.accountId = nil;
    }
    
    dispatch_async(serialQueue, ^{
        @synchronized (instances) {
            [self.dataQueue deleteAll:self.appid];
        }
        
        [self archiveAccountID:nil];
        [self archiveIdentifyId:nil];
        [self archiveSuperProperties:nil];
        [self archiveOptOut:YES];
    });
}

- (void)optOutTrackingAndDeleteUser {
    TDEventData *eventData = [[TDEventData alloc] init];
    eventData.eventType = TD_EVENT_TYPE_USER_DEL;
    eventData.persist = NO;
    [self tdInternalTrack:eventData];
    [self optOutTracking];
}

- (void)optInTracking {
    TDLogDebug(@"%@ optInTracking...", self);
    self.isOptOut = NO;
    [self archiveOptOut:NO];
}

#pragma mark - LightInstance
- (ThinkingAnalyticsSDK *)createLightInstance {
    ThinkingAnalyticsSDK *lightInstance = [[LightThinkingAnalyticsSDK alloc] initWithAPPID:self.appid withServerURL:self.serverURL withConfig:self.config];
    lightInstance.identifyId = self.deviceInfo.uniqueId;
    lightInstance.relaunchInBackGround = self.relaunchInBackGround;
    lightInstance.isEnableSceneSupport = self.isEnableSceneSupport;
    return lightInstance;
}

#pragma mark - Persistence
- (void)retrievePersistedData {
    [self unarchiveAccountID];
    [self unarchiveSuperProperties];
    [self unarchiveIdentifyID];
    [self unarchiveEnabled];
    [self unarchiveOptOut];
    [self unarchiveUploadSize];
    [self unarchiveUploadInterval];
    
    if (self.identifyId.length == 0) {
        self.identifyId = self.deviceInfo.uniqueId;
    }
    
    // 兼容老版本
    if (self.accountId.length == 0) {
        [self unarchiveOldLoginId];
        [self archiveAccountID:self.accountId];
        [self deleteOldLoginId];
    }
}

- (void)archiveIdentifyId:(NSString *)identifyId {
    NSString *filePath = [self identifyIdFilePath];
    if (![self archiveObject:[identifyId copy] withFilePath:filePath]) {
        TDLogError(@"%@ unable to archive identifyId", self);
    }
}

- (void)unarchiveIdentifyID {
    self.identifyId = (NSString *)[ThinkingAnalyticsSDK unarchiveFromFile:[self identifyIdFilePath] asClass:[NSString class]];
}

- (void)unarchiveAccountID {
    self.accountId = (NSString *)[ThinkingAnalyticsSDK unarchiveFromFile:[self accountIDFilePath] asClass:[NSString class]];
}

- (void)archiveUploadSize:(NSNumber *)uploadSize {
    NSString *filePath = [self uploadSizeFilePath];
    if (![self archiveObject:uploadSize withFilePath:filePath]) {
        TDLogError(@"%@ unable to archive uploadSize", self);
    }
}

- (void)unarchiveUploadSize {
    self.config.uploadSize = (NSNumber *)[ThinkingAnalyticsSDK unarchiveFromFile:[self uploadSizeFilePath] asClass:[NSNumber class]];
    if (!self.config.uploadSize) {
        self.config.uploadSize = [NSNumber numberWithInteger:100];
    }
}

- (void)archiveUploadInterval:(NSNumber *)uploadInterval {
    NSString *filePath = [self uploadIntervalFilePath];
    if (![self archiveObject:uploadInterval withFilePath:filePath]) {
        TDLogError(@"%@ unable to archive uploadInterval", self);
    }
}

- (void)unarchiveUploadInterval {
    self.config.uploadInterval = (NSNumber *)[ThinkingAnalyticsSDK unarchiveFromFile:[self uploadIntervalFilePath] asClass:[NSNumber class]];
    if (!self.config.uploadInterval) {
        self.config.uploadInterval = [NSNumber numberWithInteger:60];
    }
}

- (void)archiveAccountID:(NSString *)accountID {
    NSString *filePath = [self accountIDFilePath];
    if (![self archiveObject:[accountID copy] withFilePath:filePath]) {
        TDLogError(@"%@ unable to archive accountID", self);
    }
}

- (void)archiveSuperProperties:(NSDictionary *)superProperties {
    NSString *filePath = [self superPropertiesFilePath];
    if (![self archiveObject:[superProperties copy] withFilePath:filePath]) {
        TDLogError(@"%@ unable to archive superProperties", self);
    }
}

- (void)unarchiveSuperProperties {
    self.superProperty = (NSDictionary *)[ThinkingAnalyticsSDK unarchiveFromFile:[self superPropertiesFilePath] asClass:[NSDictionary class]];
}

- (void)archiveOptOut:(BOOL)optOut {
    NSString *filePath = [self optOutFilePath];
    if (![self archiveObject:[NSNumber numberWithBool:self.isOptOut] withFilePath:filePath]) {
        TDLogError(@"%@ unable to archive isOptOut", self);
    }
}

- (void)unarchiveOptOut {
    NSNumber *optOut = (NSNumber *)[ThinkingAnalyticsSDK unarchiveFromFile:[self optOutFilePath] asClass:[NSNumber class]];
    self.isOptOut = [optOut boolValue];
}

- (void)archiveIsEnabled:(BOOL)isEnabled {
    NSString *filePath = [self enabledFilePath];
    if (![self archiveObject:[NSNumber numberWithBool:self.isEnabled] withFilePath:filePath]) {
        TDLogError(@"%@ unable to archive isEnabled", self);
    }
}

- (void)unarchiveEnabled {
    NSNumber *enabled = (NSNumber *)[ThinkingAnalyticsSDK unarchiveFromFile:[self enabledFilePath] asClass:[NSNumber class]];
    if (enabled == nil) {
        self.isEnabled = YES;
    } else {
        self.isEnabled = [enabled boolValue];
    }
}

- (BOOL)archiveObject:(id)object withFilePath:(NSString *)filePath {
    @try {
        if (![NSKeyedArchiver archiveRootObject:object toFile:filePath]) {
            return NO;
        }
    } @catch (NSException *exception) {
        TDLogError(@"Got exception: %@, reason: %@. You can only send to Thinking values that inherit from NSObject and implement NSCoding.", exception.name, exception.reason);
        return NO;
    }
    
    [self addSkipBackupAttributeToItemAtPath:filePath];
    return YES;
}

- (BOOL)addSkipBackupAttributeToItemAtPath:(NSString *)filePathString {
    NSURL *URL = [NSURL fileURLWithPath:filePathString];
    assert([[NSFileManager defaultManager] fileExistsAtPath:[URL path]]);
    
    NSError *error = nil;
    BOOL success = [URL setResourceValue:[NSNumber numberWithBool:YES]
                                  forKey:NSURLIsExcludedFromBackupKey error:&error];
    if (!success) {
        TDLogError(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    return success;
}

+ (id)unarchiveFromFile:(NSString *)filePath asClass:(Class)class {
    id unarchivedData = nil;
    @try {
        unarchivedData = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
        if (![unarchivedData isKindOfClass:class]) {
            unarchivedData = nil;
        }
    }
    @catch (NSException *exception) {
        TDLogError(@"%@ unable to unarchive data in %@, starting fresh", self, filePath);
        unarchivedData = nil;
        NSError *error = NULL;
        BOOL removed = [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
        if (!removed) {
            TDLogDebug(@"%@ unable to remove archived file at %@ - %@", self, filePath, error);
        }
    }
    return unarchivedData;
}

- (NSString *)superPropertiesFilePath {
    return [self persistenceFilePath:@"superProperties"];
}

- (NSString *)accountIDFilePath {
    return [self persistenceFilePath:@"accountID"];
}

- (NSString *)uploadSizeFilePath {
    return [self persistenceFilePath:@"uploadSize"];
}

- (NSString *)uploadIntervalFilePath {
    return [self persistenceFilePath:@"uploadInterval"];
}

- (NSString *)identifyIdFilePath {
    return [self persistenceFilePath:@"identifyId"];
}

- (NSString *)enabledFilePath {
    return [self persistenceFilePath:@"isEnabled"];
}

- (NSString *)optOutFilePath {
    return [self persistenceFilePath:@"optOut"];
}

- (NSString *)persistenceFilePath:(NSString *)data {
    NSString *filename = [NSString stringWithFormat:@"thinking-%@-%@.plist", self.appid, data];
    return [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject]
            stringByAppendingPathComponent:filename];
}

// 兼容老版本
- (void)unarchiveOldLoginId {
    self.accountId = [[NSUserDefaults standardUserDefaults] objectForKey:@"thinkingdata_accountId"];
}

// 兼容老版本
- (void)deleteOldLoginId {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"thinkingdata_accountId"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSInteger)saveEventsData:(NSDictionary *)data {
    NSMutableDictionary *event = [[NSMutableDictionary alloc] initWithDictionary:data];
    NSInteger count;
    @synchronized (instances) {
        count = [self.dataQueue addObejct:event withAppid:self.appid];
    }
    return count;
}

- (void)deleteAll {
    dispatch_async(serialQueue, ^{
        @synchronized (instances) {
            [self.dataQueue deleteAll:self.appid];
        }
    });
}

#pragma mark - UIApplication Events
- (void)setApplicationListeners {
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter addObserver:self
                           selector:@selector(applicationWillEnterForeground:)
                               name:UIApplicationWillEnterForegroundNotification
                             object:nil];
    
    [notificationCenter addObserver:self
                           selector:@selector(applicationDidBecomeActive:)
                               name:UIApplicationDidBecomeActiveNotification
                             object:nil];
    
    [notificationCenter addObserver:self
                           selector:@selector(applicationWillResignActive:)
                               name:UIApplicationWillResignActiveNotification
                             object:nil];
    
    [notificationCenter addObserver:self
                           selector:@selector(applicationDidEnterBackground:)
                               name:UIApplicationDidEnterBackgroundNotification
                             object:nil];
    
    [notificationCenter addObserver:self
                           selector:@selector(applicationWillTerminateNotification:)
                               name:UIApplicationWillTerminateNotification
                             object:nil];
}

- (void)setNetRadioListeners {
    if ((_reachability = SCNetworkReachabilityCreateWithName(NULL, "thinkingdata.cn")) != NULL) {
        SCNetworkReachabilityContext context = {0, (__bridge void *)self, NULL, NULL, NULL};
        if (SCNetworkReachabilitySetCallback(_reachability, ThinkingReachabilityCallback, &context)) {
            if (!SCNetworkReachabilitySetDispatchQueue(_reachability, serialQueue)) {
                SCNetworkReachabilitySetCallback(_reachability, NULL, NULL);
            }
        }
    }
    
    [self setCurrentRadio];
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter addObserver:self
                           selector:@selector(setCurrentRadio)
                               name:CTRadioAccessTechnologyDidChangeNotification
                             object:nil];
}

- (void)applicationWillTerminateNotification:(NSNotification *)notification {
    TDLogDebug(@"%@ applicationWillTerminateNotification", self);
    dispatch_sync(serialQueue, ^{});
}

- (void)applicationWillEnterForeground:(NSNotification *)notification {
    TDLogDebug(@"%@ application will enter foreground", self);
    
    if (UIApplication.sharedApplication.applicationState == UIApplicationStateBackground) {
        _relaunchInBackGround = NO;
        _appRelaunched = YES;
        dispatch_async(serialQueue, ^{
            if (self.taskId != UIBackgroundTaskInvalid) {
                [[ThinkingAnalyticsSDK sharedUIApplication] endBackgroundTask:self.taskId];
                self.taskId = UIBackgroundTaskInvalid;
            }
        });
    }
}

- (void)applicationDidEnterBackground:(NSNotification *)notification {
    TDLogDebug(@"%@ application did enter background", self);
    _relaunchInBackGround = NO;
    _applicationWillResignActive = NO;
    
    __block UIBackgroundTaskIdentifier backgroundTask = [[ThinkingAnalyticsSDK sharedUIApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[ThinkingAnalyticsSDK sharedUIApplication] endBackgroundTask:backgroundTask];
        self.taskId = UIBackgroundTaskInvalid;
    }];
    self.taskId = backgroundTask;
    dispatch_group_t bgGroup = dispatch_group_create();

    dispatch_group_enter(bgGroup);
    dispatch_async(serialQueue, ^{
        NSNumber *currentSystemUpTime = @([[NSDate date] timeIntervalSince1970]);
        @synchronized (self.trackTimer) {
            NSArray *keys = [self.trackTimer allKeys];
            for (NSString *key in keys) {
                if ([key isEqualToString:TD_APP_END_EVENT]) {
                    continue;
                }
                NSMutableDictionary *eventTimer = [[NSMutableDictionary alloc] initWithDictionary:self.trackTimer[key]];
                if (eventTimer) {
                    NSNumber *eventBegin = [eventTimer valueForKey:TD_EVENT_START];
                    NSNumber *eventDuration = [eventTimer valueForKey:TD_EVENT_DURATION];
                    double usedTime;
                    if (eventDuration) {
                        usedTime = [currentSystemUpTime doubleValue] - [eventBegin doubleValue] + [eventDuration doubleValue];
                    } else {
                        usedTime = [currentSystemUpTime doubleValue] - [eventBegin doubleValue];
                    }
                    [eventTimer setObject:[NSNumber numberWithDouble:usedTime] forKey:TD_EVENT_DURATION];
                    self.trackTimer[key] = eventTimer;
                }
            }
        }
        dispatch_group_leave(bgGroup);
    });
    
    if (_config.autoTrackEventType & ThinkingAnalyticsEventTypeAppEnd) {
        NSString *screenName = NSStringFromClass([[TDAutoTrackManager topPresentedViewController] class]);
        screenName = (screenName == nil) ? @"" : screenName;
        [self autotrack:TD_APP_END_EVENT properties:@{TD_EVENT_PROPERTY_SCREEN_NAME: screenName} withTime:nil];
    }
    
    dispatch_group_enter(bgGroup);
    [self syncWithCompletion:^{
        dispatch_group_leave(bgGroup);
    }];
    
    dispatch_group_notify(bgGroup, dispatch_get_main_queue(), ^{
        if (self.taskId != UIBackgroundTaskInvalid) {
            [[ThinkingAnalyticsSDK sharedUIApplication] endBackgroundTask:self.taskId];
            self.taskId = UIBackgroundTaskInvalid;
        }
    });
}

- (void)applicationWillResignActive:(NSNotification *)notification {
    TDLogDebug(@"%@ application will resign active", self);
    _applicationWillResignActive = YES;
    [self stopFlushTimer];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    TDLogDebug(@"%@ application did become active", self);
    [self startFlushTimer];
    
    if (_applicationWillResignActive) {
        _applicationWillResignActive = NO;
        return;
    }
    _applicationWillResignActive = NO;
    
    dispatch_async(serialQueue, ^{
        NSNumber *currentTime = @([[NSDate date] timeIntervalSince1970]);
        @synchronized (self.trackTimer) {
            NSArray *keys = [self.trackTimer allKeys];
            for (NSString *key in keys) {
                NSMutableDictionary *eventTimer = [[NSMutableDictionary alloc] initWithDictionary:self.trackTimer[key]];
                if (eventTimer) {
                    [eventTimer setValue:currentTime forKey:TD_EVENT_START];
                    self.trackTimer[key] = eventTimer;
                }
            }
        }
    });
    
    if (_appRelaunched) {
        if (_config.autoTrackEventType & ThinkingAnalyticsEventTypeAppStart) {
            [self autotrack:TD_APP_START_EVENT properties:@{TD_RESUME_FROM_BACKGROUND:@(_appRelaunched)} withTime:nil];
        }
        if (_config.autoTrackEventType & ThinkingAnalyticsEventTypeAppEnd) {
            [self timeEvent:TD_APP_END_EVENT];
        }
    }
}

- (void)sceneSupportSetting {
    NSDictionary *sceneManifest = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"UIApplicationSceneManifest"];
    if (sceneManifest) {
        NSDictionary *sceneConfig = sceneManifest[@"UISceneConfigurations"];
        if (sceneConfig.count > 0) {
            _isEnableSceneSupport = YES;
        } else {
            _isEnableSceneSupport = NO;
        }
    } else {
        _isEnableSceneSupport = NO;
    }
}

- (void)setNetworkType:(ThinkingAnalyticsNetworkType)type {
    if ([self hasDisabled])
        return;
        
    [self.config setNetworkType:type];
}

- (ThinkingNetworkType)convertNetworkType:(NSString *)networkType {
    if ([@"NULL" isEqualToString:networkType]) {
        return ThinkingNetworkTypeNONE;
    } else if ([@"WIFI" isEqualToString:networkType]) {
        return ThinkingNetworkTypeWIFI;
    } else if ([@"2G" isEqualToString:networkType]) {
        return ThinkingNetworkType2G;
    } else if ([@"3G" isEqualToString:networkType]) {
        return ThinkingNetworkType3G;
    } else if ([@"4G" isEqualToString:networkType]) {
        return ThinkingNetworkType4G;
    } else if ([@"UNKNOWN" isEqualToString:networkType]) {
        return ThinkingNetworkType4G;
    }
    return ThinkingNetworkTypeNONE;
}

static void ThinkingReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void *info) {
    ThinkingAnalyticsSDK *thinking = (__bridge ThinkingAnalyticsSDK *)info;
    if (thinking && [thinking isKindOfClass:[ThinkingAnalyticsSDK class]]) {
        [thinking reachabilityChanged:flags];
    }
}

- (void)reachabilityChanged:(SCNetworkReachabilityFlags)flags {
    isWifi = (flags & kSCNetworkReachabilityFlagsReachable) && !(flags & kSCNetworkReachabilityFlagsIsWWAN);
}

- (NSString *)currentRadio {
    NSString *newtworkType = @"NULL";;
    NSString *currentRadioAccessTechnology = _telephonyInfo.currentRadioAccessTechnology;
    
    if ([currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyLTE]) {
        newtworkType = @"4G";
    } else if ([currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyeHRPD]) {
        newtworkType = @"3G";
    } else if ([currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyCDMAEVDORevB]) {
        newtworkType = @"3G";
    } else if ([currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyCDMAEVDORevA]) {
        newtworkType = @"3G";
    } else if ([currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyCDMAEVDORev0]) {
        newtworkType = @"3G";
    } else if ([currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyCDMA1x]) {
        newtworkType = @"3G";
    } else if ([currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyHSUPA]) {
        newtworkType = @"3G";
    } else if ([currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyHSDPA]) {
        newtworkType = @"3G";
    } else if ([currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyWCDMA]) {
        newtworkType = @"3G";
    } else if ([currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyEdge]) {
        newtworkType = @"2G";
    } else if ([currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyGPRS]) {
        newtworkType = @"2G";
    } else if (currentRadioAccessTechnology) {
        newtworkType = @"UNKNOWN";
    }
    return newtworkType;
}

+ (NSString *)getNetWorkStates {
    if (isWifi) {
        return @"WIFI";
    } else {
        return radioInfo;
    }
}

- (void)setCurrentRadio {
    dispatch_async(serialQueue, ^{
        radioInfo = [self currentRadio];
    });
}

#pragma mark - Tracking
- (void)track:(NSString *)event {
    if ([self hasDisabled])
        return;
    [self track:event properties:nil];
}

- (void)track:(NSString *)event properties:(NSDictionary *)propertiesDict {
    if ([self hasDisabled])
        return;
    BOOL isValid = YES;
    propertiesDict = [self processParameters:propertiesDict withType:TD_EVENT_TYPE_TRACK withEventName:event withAutoTrack:NO withH5:NO isValid:&isValid];
    if (isValid) {
        TDEventData *eventData = [[TDEventData alloc] init];
        eventData.eventName = event;
        eventData.properties = [propertiesDict copy];
        eventData.eventType = TD_EVENT_TYPE_TRACK;
        eventData.autotrack = NO;
        eventData.persist = YES;
        [self tdInternalTrack:eventData];
    }
}

//废弃
- (void)track:(NSString *)event properties:(NSDictionary *)propertiesDict time:(NSDate *)time {
    if ([self hasDisabled])
        return;
    BOOL isValid = YES;
    propertiesDict = [self processParameters:propertiesDict withType:TD_EVENT_TYPE_TRACK withEventName:event withAutoTrack:NO withH5:NO isValid:&isValid];
    if (isValid) {
        TDEventData *eventData = [[TDEventData alloc] init];
        eventData.eventName = event;
        eventData.properties = [propertiesDict copy];
        eventData.eventType = TD_EVENT_TYPE_TRACK;
        eventData.autotrack = NO;
        eventData.persist = YES;
        eventData.timeString = [_timeFormatter stringFromDate:time];
        eventData.timeValueType = TDTimeValueTypeTimeOnly;
        [self tdInternalTrack:eventData];
    }
}

- (void)track:(NSString *)event properties:(nullable NSDictionary *)properties time:(NSDate *)time timeZone:(NSTimeZone *)timeZone {
    if ([self hasDisabled])
        return;
    if (timeZone == nil) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [self track:event properties:properties time:time];
#pragma clang diagnostic pop
        return;
    }
    BOOL isValid = YES;
    properties = [self processParameters:properties withType:TD_EVENT_TYPE_TRACK withEventName:event withAutoTrack:NO withH5:NO isValid:&isValid];
    if (isValid) {
        TDEventData *eventData = [[TDEventData alloc] init];
        eventData.eventName = event;
        eventData.properties = [properties copy];
        eventData.eventType = TD_EVENT_TYPE_TRACK;
        eventData.autotrack = NO;
        eventData.persist = YES;
        NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
        timeFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
        timeFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        timeFormatter.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        timeFormatter.timeZone = timeZone;
        eventData.timeString = [timeFormatter stringFromDate:time];
        eventData.zoneOffset = [self getTimezoneOffset:time timeZone:timeZone];
        eventData.timeValueType = TDTimeValueTypeAll;
        [self tdInternalTrack:eventData];
    }
}

- (void)h5track:(NSString *)event properties:(NSDictionary *)propertieDict withType:(NSString *)type withTime:(NSString *)time {
    if ([self hasDisabled])
        return;
    BOOL isValid = YES;
    propertieDict = [self processParameters:propertieDict withType:type withEventName:event withAutoTrack:NO withH5:YES isValid:&isValid];
    if (isValid) {
        TDEventData *eventData = [[TDEventData alloc] init];
        eventData.eventName = event;
        eventData.properties = [propertieDict copy];
        eventData.eventType = type;
        eventData.persist = YES;
        if ([propertieDict objectForKey:@"#zone_offset"]) {
            eventData.zoneOffset = [[propertieDict objectForKey:@"#zone_offset"] doubleValue];
            eventData.timeValueType = TDTimeValueTypeAll;
        } else {
            eventData.timeValueType = TDTimeValueTypeTimeOnly;
        }
        eventData.timeString = time;
        [self tdInternalTrack:eventData];
    }
}

- (void)autotrack:(NSString *)event properties:(NSDictionary *)propertieDict withTime:(NSDate *)time {
    if ([self hasDisabled])
        return;
    BOOL isValid = YES;
    propertieDict = [self processParameters:propertieDict withType:TD_EVENT_TYPE_TRACK withEventName:event withAutoTrack:YES withH5:NO isValid:&isValid];
    if (isValid) {
        TDEventData *eventData = [[TDEventData alloc] init];
        eventData.eventName = event;
        eventData.properties = [propertieDict copy];
        eventData.eventType = TD_EVENT_TYPE_TRACK;
        eventData.autotrack = YES;
        eventData.persist = YES;
        eventData.timeString = [_timeFormatter stringFromDate:time];
        [self tdInternalTrack:eventData];
    }
}

- (double)getTimezoneOffset:(NSDate *)date timeZone:(NSTimeZone *)timeZone {
    NSTimeZone *tz = timeZone ? timeZone : [NSTimeZone localTimeZone];
    NSInteger sourceGMTOffset = [tz secondsFromGMTForDate:date];
    return (double)sourceGMTOffset/3600;
}

// 内部
- (void)track:(NSString *)event withProperties:(NSDictionary *)properties withType:(NSString *)type {
    if ([self hasDisabled])
        return;
    
    BOOL isValid = YES;
    properties = [self processParameters:properties withType:type withEventName:event withAutoTrack:NO withH5:NO isValid:&isValid];
    if (isValid) {
        TDEventData *eventData = [[TDEventData alloc] init];
        eventData.eventName = event;
        eventData.properties = [properties copy];
        eventData.eventType = type;
        eventData.autotrack = NO;
        eventData.persist = YES;
        [self tdInternalTrack:eventData];
    }
}

- (void)user_add:(NSString *)propertyName andPropertyValue:(NSNumber *)propertyValue {
    if ([self hasDisabled])
        return;
    
    if (propertyName && propertyValue) {
        [self track:nil withProperties:@{propertyName:propertyValue} withType:TD_EVENT_TYPE_USER_ADD];
    }
}

- (void)user_add:(NSDictionary *)properties {
    if ([self hasDisabled])
        return;
    
    [self track:nil withProperties:properties withType:TD_EVENT_TYPE_USER_ADD];
}

- (void)user_setOnce:(NSDictionary *)properties {
    if ([self hasDisabled])
        return;
    
    [self track:nil withProperties:properties withType:TD_EVENT_TYPE_USER_SETONCE];
}

- (void)user_set:(NSDictionary *)properties {
    if ([self hasDisabled])
        return;
    
    [self track:nil withProperties:properties withType:TD_EVENT_TYPE_USER_SET];
}

- (void)user_unset:(NSString *)propertyName {
    if ([self hasDisabled])
        return;
    
    if ([propertyName isKindOfClass:[NSString class]] && propertyName.length > 0) {
        NSDictionary* properties = @{propertyName: @0};
        [self track:nil withProperties:properties withType:TD_EVENT_TYPE_USER_UNSET];
    }
}

- (void)user_delete {
    if ([self hasDisabled])
        return;
    
    [self track:nil withProperties:nil withType:TD_EVENT_TYPE_USER_DEL];
}

- (void)user_append:(NSDictionary *)properties {
    if ([self hasDisabled])
        return;
    
    [self track:nil withProperties:properties withType:TD_EVENT_TYPE_USER_APPEND];
}

- (NSString *)getDistinctId {
    return [self.identifyId copy];
}

+ (NSString *)getSDKVersion {
    return [TDDeviceInfo libVersion];
}

- (NSString *)getDeviceId {
    return _deviceInfo.deviceId;
}

- (void)registerDynamicSuperProperties:(NSDictionary<NSString *, id> *(^)(void)) dynamicSuperProperties {
    if ([self hasDisabled])
        return;
    
    self.dynamicSuperProperties = dynamicSuperProperties;
}

- (void)setSuperProperties:(NSDictionary *)properties {
    if ([self hasDisabled])
        return;
    
    if (properties == nil) {
        return;
    }
    properties = [properties copy];
    
    if (![self checkEventProperties:properties withEventType:nil haveAutoTrackEvents:NO]) {
        TDLogError(@"%@ propertieDict error.", properties);
        return;
    }
    
    @synchronized (self.superProperty) {
        NSMutableDictionary *tmp = [NSMutableDictionary dictionaryWithDictionary:self.superProperty];
        [tmp addEntriesFromDictionary:[properties copy]];
        self.superProperty = [NSDictionary dictionaryWithDictionary:tmp];
    }
    
    dispatch_async(serialQueue, ^{
        [self archiveSuperProperties:self.superProperty];
    });
}

- (void)unsetSuperProperty:(NSString *)propertyKey {
    if ([self hasDisabled])
        return;
    
    if (![propertyKey isKindOfClass:[NSString class]] || propertyKey.length == 0)
        return;
    
    @synchronized (self.superProperty) {
        NSMutableDictionary *tmp = [NSMutableDictionary dictionaryWithDictionary:self.superProperty];
        tmp[propertyKey] = nil;
        self.superProperty = [NSDictionary dictionaryWithDictionary:tmp];
    }
    dispatch_async(serialQueue, ^{
        [self archiveSuperProperties:self.superProperty];
    });
}

- (void)clearSuperProperties {
    if ([self hasDisabled])
        return;
    
    @synchronized (self.superProperty) {
        self.superProperty = @{};
    }
    
    dispatch_async(serialQueue, ^{
        [self archiveSuperProperties:self.superProperty];
    });
}

- (NSDictionary *)currentSuperProperties {
    return [self.superProperty copy];
}

- (void)identify:(NSString *)distinctId {
    if ([self hasDisabled])
        return;
        
    if (![distinctId isKindOfClass:[NSString class]] || distinctId.length == 0) {
        TDLogError(@"identify cannot null");
        return;
    }
    
    @synchronized (self.identifyId) {
       self.identifyId = distinctId;
    }
    dispatch_async(serialQueue, ^{
       [self archiveIdentifyId:distinctId];
    });
}

- (void)login:(NSString *)accountId {
    if ([self hasDisabled])
        return;
        
    if (![accountId isKindOfClass:[NSString class]] || accountId.length == 0) {
        TDLogError(@"accountId invald", accountId);
        return;
    }
    
    @synchronized (self.accountId) {
        self.accountId = accountId;
    }
        
    dispatch_async(serialQueue, ^{
        [self archiveAccountID:accountId];
    });
}

- (void)logout {
    if ([self hasDisabled])
        return;
    
    @synchronized (self.accountId) {
        self.accountId = nil;
    }
    dispatch_async(serialQueue, ^{
        [self archiveAccountID:nil];
    });
}

- (void)timeEvent:(NSString *)event {
    if ([self hasDisabled])
        return;
        
    if (![event isKindOfClass:[NSString class]] || event.length == 0 || ![self isValidName:event isAutoTrack:NO]) {
        NSString *errMsg = [NSString stringWithFormat:@"timeEvent parameter[%@] is not valid", event];
        TDLogError(errMsg);
        return ;
    }
    
    NSNumber *eventBegin = @([[NSDate date] timeIntervalSince1970]);
    @synchronized (self.trackTimer) {
        self.trackTimer[event] = @{TD_EVENT_START:eventBegin, TD_EVENT_DURATION:[NSNumber numberWithDouble:0]};
    };
}

- (BOOL)isValidName:(NSString *)name isAutoTrack:(BOOL)isAutoTrack {
    @try {
        if (!isAutoTrack) {
            return [self.regexKey evaluateWithObject:name];
        } else {
            return [self.regexAutoTrackKey evaluateWithObject:name];
        }
    } @catch (NSException *exception) {
        TDLogError(@"%@: %@", self, exception);
        return YES;
    }
}

- (NSString *)limitString:(NSString *)originalString withLength:(NSInteger)length {
    NSStringEncoding encoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingUTF8);
    NSData *originalData = [originalString dataUsingEncoding:encoding];
    NSData *subData = [originalData subdataWithRange:NSMakeRange(0, length)];
    NSString *limitString = [[NSString alloc] initWithData:subData encoding:encoding];
    
    NSInteger index = 1;
    while (index <= 3 && !limitString) {
        if (length > index) {
            subData = [originalData subdataWithRange:NSMakeRange(0, length - index)];
            limitString = [[NSString alloc] initWithData:subData encoding:encoding];
        }
        index ++;
    }
    
    if (!limitString) {
        return originalString;
    }
    return limitString;
}

- (BOOL)checkEventProperties:(NSDictionary *)properties withEventType:(NSString *)eventType haveAutoTrackEvents:(BOOL)haveAutoTrackEvents {
    if (![properties isKindOfClass:[NSDictionary class]]) {
        return NO;
    }
    
    __block BOOL failed = NO;
    NSMutableString *exceptionErrMsg = [[NSMutableString alloc] init];
    [exceptionErrMsg appendString:@"[ThinkingSDKDebug] "];
    [properties enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (![key isKindOfClass:[NSString class]]) {
            NSString *errMsg = [NSString stringWithFormat:@"property key must by NSString. got: %@. ", key];
            TDLogError(errMsg);
            [exceptionErrMsg appendString:errMsg];
            failed = YES;
        }
        
        if (![self isValidName:key isAutoTrack:haveAutoTrackEvents]) {
            NSString *errMsg = [NSString stringWithFormat:@"property key is not valid. got: %@. ", key];
            TDLogError(errMsg);
            [exceptionErrMsg appendString:errMsg];
            failed = YES;
        }
        
        if (![obj isKindOfClass:[NSString class]] &&
            ![obj isKindOfClass:[NSNumber class]] &&
            ![obj isKindOfClass:[NSDate class]] &&
            ![obj isKindOfClass:[NSArray class]]) {
            NSString *errMsg = [NSString stringWithFormat:@"property values must be NSString, NSNumber, NSDate, NSArray. got: %@ %@. ", [obj class], obj];
            TDLogError(errMsg);
            [exceptionErrMsg appendString:errMsg];
            failed = YES;
        }
        
        if (eventType.length > 0 && [eventType isEqualToString:TD_EVENT_TYPE_USER_ADD]) {
            if (![obj isKindOfClass:[NSNumber class]]) {
                NSString *errMsg = [NSString stringWithFormat:@"user_add value must be NSNumber. got: %@ %@. ", [obj class], obj];
                TDLogError(errMsg);
                [exceptionErrMsg appendString:errMsg];
                failed = YES;
            }
        }
        
        if (eventType.length > 0 && [eventType isEqualToString:TD_EVENT_TYPE_USER_APPEND]) {
            if (![obj isKindOfClass:[NSArray class]]) {
                NSString *errMsg = [NSString stringWithFormat:@"user_append value must be NSArray. got: %@ %@. ", [obj class], obj];
                TDLogError(errMsg);
                [exceptionErrMsg appendString:errMsg];
                failed = YES;
            }
        }
        
        if ([obj isKindOfClass:[NSNumber class]]) {
            if ([obj doubleValue] > 9999999999999.999 || [obj doubleValue] < -9999999999999.999) {
                NSString *errMsg = [NSString stringWithFormat:@"property number value is not valid. got: %@. ", obj];
                TDLogError(errMsg);
                [exceptionErrMsg appendString:errMsg];
                failed = YES;
            }
        }
    }];
    if (failed) {
        if (self.config.allowDebug) {
            [NSException raise:@"track data error" format:@"error reason: %@", exceptionErrMsg];
        }
        return NO;
    }
    
    return YES;
}

- (void)clickFromH5:(NSString *)data {
    NSData *jsonData = [data dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *eventDict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                              options:NSJSONReadingMutableContainers
                                                                error:&err];
    NSString *appid = [eventDict[@"#app_id"] isKindOfClass:[NSString class]] ? eventDict[@"#app_id"] : self.appid;
    id dataArr = eventDict[@"data"];
    if (!err && [dataArr isKindOfClass:[NSArray class]]) {
        NSDictionary *dataInfo = [dataArr objectAtIndex:0];
        if (dataInfo != nil) {
            NSString *type = [dataInfo objectForKey:@"#type"];
            NSString *event_name = [dataInfo objectForKey:@"#event_name"];
            NSString *time = [dataInfo objectForKey:@"#time"];
            NSDictionary *properties = [dataInfo objectForKey:@"properties"];
            NSMutableDictionary *dic = [properties mutableCopy];
            [dic removeObjectForKey:@"#account_id"];
            [dic removeObjectForKey:@"#distinct_id"];
            [dic removeObjectForKey:@"#device_id"];
            [dic removeObjectForKey:@"#lib"];
            [dic removeObjectForKey:@"#lib_version"];
            [dic removeObjectForKey:@"#screen_height"];
            [dic removeObjectForKey:@"#screen_width"];
            
            ThinkingAnalyticsSDK *instance = [ThinkingAnalyticsSDK sharedInstanceWithAppid:appid];
            if (instance) {
                dispatch_async(serialQueue, ^{
                    [instance h5track:event_name properties:dic withType:type withTime:time];
                });
            } else {
                dispatch_async(serialQueue, ^{
                    [self h5track:event_name properties:dic withType:type withTime:time];
                });
            }
        }
    }
}

- (void)tdInternalTrack:(TDEventData *)eventData {
    if ([self hasDisabled])
        return;
    
    if (_relaunchInBackGround && !_config.trackRelaunchedInBackgroundEvents) {
        return;
    }
    
    NSDictionary *propertiesDict = eventData.properties;
    NSMutableDictionary<NSString *, id> *properties = [NSMutableDictionary dictionaryWithDictionary:propertiesDict];
    
    NSString *timeString;
    double offset;
    if (eventData.timeValueType == TDTimeValueTypeNone) {
        timeString = [_timeFormatter stringFromDate:[NSDate date]];
        offset = [self getTimezoneOffset:[NSDate date] timeZone:nil];
    } else {
        timeString = eventData.timeString;
        offset = eventData.zoneOffset;
    }
    
    if ([eventData.eventType isEqualToString:TD_EVENT_TYPE_TRACK]) {
        properties[@"#app_version"] = self.deviceInfo.appVersion;
        properties[@"#network_type"] = [[self class] getNetWorkStates];
        
        if (_relaunchInBackGround) {
            properties[@"#relaunched_in_background"] = @YES;
        }
        if (eventData.timeValueType != TDTimeValueTypeTimeOnly) {
            properties[@"#zone_offset"] = @(offset);
        }
    }
    
    NSDictionary *eventTimer;
    @synchronized (self.trackTimer) {
        eventTimer = self.trackTimer[eventData.eventName];
        if (eventTimer) {
            [self.trackTimer removeObjectForKey:eventData.eventName];
        }
    }
    if (eventTimer) {
        NSNumber *eventBegin = [eventTimer valueForKey:TD_EVENT_START];
        NSNumber *eventDuration = [eventTimer valueForKey:TD_EVENT_DURATION];
        
        double usedTime;
        NSNumber *currentSystemUpTime = @([[NSDate date] timeIntervalSince1970]);
        if (eventDuration) {
            usedTime = [currentSystemUpTime doubleValue] - [eventBegin doubleValue] + [eventDuration doubleValue];
        } else {
            usedTime = [currentSystemUpTime doubleValue] - [eventBegin doubleValue];
        }
        
        if (usedTime > 0) {
            properties[@"#duration"] = @([[NSString stringWithFormat:@"%.3f", usedTime] floatValue]);
        }
    }
    
    NSMutableDictionary *dataDic = [NSMutableDictionary dictionary];
    dataDic[@"#time"] = timeString;
    dataDic[@"#type"] = eventData.eventType;
    dataDic[@"#uuid"] = [[NSUUID UUID] UUIDString];
    
    if (self.identifyId) {
        dataDic[@"#distinct_id"] = self.identifyId;
    }
    if (properties) {
        dataDic[@"properties"] = [NSDictionary dictionaryWithDictionary:properties];
    }
    if (eventData.eventName) {
        dataDic[@"#event_name"] = eventData.eventName;
    }
    if (self.accountId) {
        dataDic[@"#account_id"] = self.accountId;
    }
    
    TDLogDebug(@"queueing data:%@", dataDic);
    if (self.config.debugMode == ThinkingAnalyticsDebugOnly || self.config.debugMode == ThinkingAnalyticsDebug) {
        @synchronized (self) {
            [self.debugEventsQueue addObject:dataDic];
            if (self.debugEventsQueue.count > 5000) {
                [self.debugEventsQueue removeObjectAtIndex:0];
            }
        }
        
        [self flushDebugEvent:nil];
        NSInteger count;
        @synchronized (instances) {
            count = [self.dataQueue sqliteCountForAppid:self.appid];
        }
        if (count >= [self.config.uploadSize integerValue]) {
            [self flush];
        }
    } else if (eventData.persist) {
        dispatch_async(serialQueue, ^{
            NSInteger count = [self saveEventsData:dataDic];
            if (count >= [self.config.uploadSize integerValue]) {
                [self flush];
            }
        });
    } else {
        dispatch_async(serialQueue, ^{
            [self flushImmediately:dataDic];
        });
    }
}

- (void)flushImmediately:(NSDictionary *)dataDic {
    [self dispatchOnNetworkQueue:^{
        [self.network flushEvents:@[dataDic]];
    }];
}

- (NSDictionary<NSString *,id> *)processParameters:(NSDictionary<NSString *,id> *)propertiesDict withType:(NSString *)eventType withEventName:(NSString *)eventName withAutoTrack:(BOOL)autotrack withH5:(BOOL)isH5 isValid:(BOOL *)isValid {
    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
    if ([eventType isEqualToString:TD_EVENT_TYPE_TRACK]) {
        [properties addEntriesFromDictionary:self.superProperty];
        NSDictionary *dynamicSuperPropertiesDict = self.dynamicSuperProperties?[self.dynamicSuperProperties() copy]:nil;
        if (dynamicSuperPropertiesDict && [dynamicSuperPropertiesDict isKindOfClass:[NSDictionary class]]) {
            [properties addEntriesFromDictionary:dynamicSuperPropertiesDict];
        }
    }
    if (propertiesDict && [propertiesDict isKindOfClass:[NSDictionary class]]) {
        [properties addEntriesFromDictionary:propertiesDict];
    }
    
    NSMutableString *exceptionErrMsg = [[NSMutableString alloc] init];
    [exceptionErrMsg appendString:@"[ThinkingSDKDebug] "];
    if ([eventType isEqualToString:TD_EVENT_TYPE_TRACK] && !isH5) {
        if (![eventName isKindOfClass:[NSString class]] || eventName.length == 0) {
            NSString *errMsg = [NSString stringWithFormat:@"track event name is not valid. got: %@. ", eventName];
            TDLogError(errMsg);
            [exceptionErrMsg appendString:errMsg];
            *isValid = NO;
        }
        
        if (![self isValidName:eventName isAutoTrack:NO]) {
            NSString *errMsg = [NSString stringWithFormat:@"property name[%@] is not valid", eventName];
            TDLogError(@"%@", errMsg);
            [exceptionErrMsg appendString:errMsg];
            *isValid = NO;
        }
    }
    
    if (*isValid == NO) {
        if (self.config.allowDebug) {
            [NSException raise:@"track data error" format:@"error reason: %@", exceptionErrMsg];
        }
        return nil;
    }
    
    if (properties && !isH5 && ![self checkEventProperties:properties withEventType:eventType haveAutoTrackEvents:autotrack]) {
        TDLogError(@"%@ property error.", properties);
        *isValid = NO;
        return nil;
    }
    
    if (properties) {
        NSMutableDictionary<NSString *, id> *propertiesDic = [NSMutableDictionary dictionaryWithDictionary:properties];
        
        for (NSString *key in [properties keyEnumerator]) {
            if ([properties[key] isKindOfClass:[NSString class]] && [key isEqualToString:TD_CRASH_REASON]) {
                NSString *string = properties[key];
                NSUInteger objLength = [((NSString *)string)lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
                NSUInteger valueMaxLength = TA_PROPERTY_CRASH_LENGTH_LIMIT;
                if (objLength > valueMaxLength) {
                    NSString *errMsg = [NSString stringWithFormat:@"The value is too long: %@", (NSString *)properties[key]];
                    TDLogDebug(errMsg);
                    
                    NSMutableString *fixedStr = [NSMutableString stringWithString:[self limitString:string withLength:valueMaxLength - 1]];
                    propertiesDic[key] = fixedStr;
                }
            } else if ([properties[key] isKindOfClass:[NSDate class]]) {
                NSString *dateStr = [_timeFormatter stringFromDate:(NSDate *)properties[key]];
                propertiesDic[key] = dateStr;
            } else if ([properties[key] isKindOfClass:[NSArray class]]) {
                NSMutableArray *arrayItem = [properties[key] mutableCopy];
                for (int i = 0; i < arrayItem.count ; i++) {
                    if ([arrayItem[i] isKindOfClass:[NSDate class]]) {
                        NSString *dateStr = [_timeFormatter stringFromDate:(NSDate *)arrayItem[i]];
                        arrayItem[i] = dateStr;
                    }
                }
                propertiesDic[key] = arrayItem;
            }
        }
        
        *isValid = YES;
        return [propertiesDic copy];
    }
    
    *isValid = YES;
    return nil;
}

- (void)flush {
    [self syncWithCompletion:nil];
}

- (void)degradeDebugMode {
    self.config.debugMode = ThinkingAnalyticsDebugOff;
    self.network.debugMode = ThinkingAnalyticsDebugOff;
    NSMutableArray *queueCopying;
    @synchronized (self) {
        queueCopying = [self.debugEventsQueue mutableCopy];
        self.debugEventsQueue = [NSMutableArray array];
    }
    if (queueCopying.count > 0) {
        dispatch_async(serialQueue, ^{
            [queueCopying enumerateObjectsUsingBlock:^(NSDictionary *eventDic, NSUInteger idx, BOOL * _Nonnull stop) {
                 [self saveEventsData:eventDic];
            }];
        });
    }
}

- (void)flushDebugEvent:(void (^)(void))handler {
    [self dispatchOnNetworkQueue:^{
        [self _syncDebug];
        if (handler) {
            dispatch_async(dispatch_get_main_queue(), handler);
        }
    }];
}

- (void)syncWithCompletion:(void (^)(void))handler {
    [self dispatchOnNetworkQueue:^{
        [self _sync];
        if (handler) {
            dispatch_async(dispatch_get_main_queue(), handler);
        }
    }];
}

- (void)_syncDebug {
    if (self.config.debugMode == ThinkingAnalyticsDebugOff) {
        return;
    }
    NSMutableArray *queueCopying;
    @synchronized (self) {
        queueCopying = [self.debugEventsQueue mutableCopy];
    }
    int debugResult = 0;
    while (queueCopying.count > 0) {
        NSDictionary *record = [queueCopying firstObject];
        debugResult = [self.network flushDebugEvents:record withAppid:self.appid];
        if (self.config.debugMode == ThinkingAnalyticsDebug) {
            if (debugResult == -1) {
                // 服务器不允许Debug，做降级处理
                [self degradeDebugMode];
                break;
            } else if (debugResult == -2) {
                // 网络异常
                dispatch_async(serialQueue, ^{
                    [self saveEventsData:record];
                });
            }
        }
        if (debugResult == 0 || debugResult == 1 || debugResult == 2) {
            self.config.allowDebug = YES;
        }
        [queueCopying removeObjectAtIndex:0];
        @synchronized (self) {
            [self.debugEventsQueue removeObjectAtIndex:0];
        }
    }
}

- (void)_sync {
    NSString *networkType = [[self class] getNetWorkStates];
    if (!([self convertNetworkType:networkType] & self.config.networkTypePolicy)) {
        return;
    }
    
    NSArray *recordArray;
    
    @synchronized (instances) {
        recordArray = [self.dataQueue getFirstRecords:kBatchSize withAppid:self.appid];
    }
    
    BOOL flushSucc = YES;
    while (recordArray.count > 0 && flushSucc) {
        NSUInteger sendSize = recordArray.count;
        flushSucc = [self.network flushEvents:recordArray];
        if (flushSucc) {
            @synchronized (instances) {
                BOOL ret = [self.dataQueue removeFirstRecords:sendSize withAppid:self.appid];
                if (!ret) {
                    break;
                }
                recordArray = [self.dataQueue getFirstRecords:kBatchSize withAppid:self.appid];
            }
        } else {
            break;
        }
    }
}

- (void)dispatchOnNetworkQueue:(void (^)(void))dispatchBlock {
    dispatch_async(serialQueue, ^{
        dispatch_async(networkQueue, dispatchBlock);
    });
}

#pragma mark - Flush control
- (void)startFlushTimer {
    [self stopFlushTimer];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.config.uploadInterval > 0) {
            self.timer = [NSTimer scheduledTimerWithTimeInterval:[self.config.uploadInterval integerValue]
                                                          target:self
                                                        selector:@selector(flush)
                                                        userInfo:nil
                                                         repeats:YES];
        }
    });
}

- (void)stopFlushTimer {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.timer) {
            [self.timer invalidate];
            self.timer = nil;
        }
    });
}

#pragma mark - Autotracking
- (void)enableAutoTrack:(ThinkingAnalyticsAutoTrackEventType)eventType {
    if ([self hasDisabled])
        return;
    
    _config.autoTrackEventType = eventType;
    if (_deviceInfo.isFirstOpen && (_config.autoTrackEventType & ThinkingAnalyticsEventTypeAppInstall)) {
        [self autotrack:TD_APP_INSTALL_EVENT properties:nil withTime:nil];
    }
    
    if (!_relaunchInBackGround && (_config.autoTrackEventType & ThinkingAnalyticsEventTypeAppEnd)) {
        [self timeEvent:TD_APP_END_EVENT];
    }

    if (_config.autoTrackEventType & ThinkingAnalyticsEventTypeAppStart) {
        NSString *eventName = _relaunchInBackGround?TD_APP_START_BACKGROUND_EVENT:TD_APP_START_EVENT;
        if (@available(iOS 13.0, *)) {
            if (_isEnableSceneSupport) {
                eventName = TD_APP_START_EVENT;
            }
        }
        [self autotrack:eventName properties:@{TD_RESUME_FROM_BACKGROUND:@(_appRelaunched)} withTime:nil];
    }
    
    [_autoTrackManager trackWithAppid:self.appid withOption:eventType];
    
    if (_config.autoTrackEventType & ThinkingAnalyticsEventTypeAppViewCrash) {
        [self trackCrash];
    }
}

- (void)ignoreViewType:(Class)aClass {
    if ([self hasDisabled])
        return;
        
    dispatch_async(serialQueue, ^{
        [self->_ignoredViewTypeList addObject:aClass];
    });
}

- (BOOL)isViewTypeIgnored:(Class)aClass {
    return [_ignoredViewTypeList containsObject:aClass];
}

- (BOOL)isViewControllerIgnored:(UIViewController *)viewController {
    if (viewController == nil) {
        return false;
    }
    NSString *screenName = NSStringFromClass([viewController class]);
    if (_ignoredViewControllers != nil && _ignoredViewControllers.count > 0) {
        if ([_ignoredViewControllers containsObject:screenName]) {
            return true;
        }
    }
    return false;
}

- (BOOL)isAutoTrackEventTypeIgnored:(ThinkingAnalyticsAutoTrackEventType)eventType {
    return !(_config.autoTrackEventType & eventType);
}

- (void)ignoreAutoTrackViewControllers:(NSArray *)controllers {
    if ([self hasDisabled])
        return;
        
    if (controllers == nil || controllers.count == 0) {
        return;
    }
    
    dispatch_async(serialQueue, ^{
        [self->_ignoredViewControllers addObjectsFromArray:controllers];
    });
}

#pragma mark - H5 tracking
- (BOOL)showUpWebView:(id)webView WithRequest:(NSURLRequest *)request {
    if (webView == nil || request == nil || ![request isKindOfClass:NSURLRequest.class]) {
        TDLogInfo(@"showUpWebView request error");
        return NO;
    }
    
    NSString *urlStr = request.URL.absoluteString;
    if (!urlStr) {
        return NO;
    }
    
    if ([urlStr rangeOfString:TA_JS_TRACK_SCHEME].length == 0) {
        return NO;
    }
    
    NSString *query = [[request URL] query];
    NSArray *queryItem = [query componentsSeparatedByString:@"="];
    
    if (queryItem.count != 2)
        return YES;
    
    NSString *queryValue = [queryItem lastObject];
    if ([urlStr rangeOfString:TA_JS_TRACK_SCHEME].length > 0) {
        if ([self hasDisabled])
            return YES;
        
        NSString *eventData = [queryValue stringByRemovingPercentEncoding];
        if (eventData.length > 0)
            [self clickFromH5:eventData];
    }
    return YES;
}

#if THINKING_UIWEBVIEW_SUPPORT
- (NSString *)webViewGetUserAgent {
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectZero];
    return [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
}
#else
- (void)wkWebViewGetUserAgent:(void (^)(NSString *))completion {
    self.wkWebView = [[WKWebView alloc] initWithFrame:CGRectZero];
    [self.wkWebView evaluateJavaScript:@"navigator.userAgent" completionHandler:^(id __nullable userAgent, NSError * __nullable error) {
        completion(userAgent);
    }];
}
#endif

- (void)addWebViewUserAgent {
    if ([self hasDisabled])
        return;
        
    void (^setUserAgent)(NSString *userAgent) = ^void (NSString *userAgent) {
        if ([userAgent rangeOfString:@"td-sdk-ios"].location == NSNotFound) {
            userAgent = [userAgent stringByAppendingString:@" /td-sdk-ios"];
            
            NSDictionary *userAgentDic = [[NSDictionary alloc] initWithObjectsAndKeys:userAgent, @"UserAgent", nil];
            [[NSUserDefaults standardUserDefaults] registerDefaults:userAgentDic];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    };
    
    dispatch_block_t getUABlock = ^() {
        #if THINKING_UIWEBVIEW_SUPPORT
        setUserAgent([self webViewGetUserAgent]);
        #else
        [self wkWebViewGetUserAgent:^(NSString *userAgent) {
            setUserAgent(userAgent);
        }];
        #endif
    };
    
    td_dispatch_main_sync_safe(getUABlock);
}

#pragma mark - Logging
+ (void)setLogLevel:(TDLoggingLevel)level {
    [TDLogging sharedInstance].loggingLevel = level;
}

#pragma mark - Crash tracking
-(void)trackCrash {
    [[ThinkingExceptionHandler sharedHandler] addThinkingInstance:self];
}

@end

@implementation TDEventData

@end

@implementation UIView (ThinkingAnalytics)

- (NSString *)thinkingAnalyticsViewID {
    return objc_getAssociatedObject(self, &TD_AUTOTRACK_VIEW_ID);
}

- (void)setThinkingAnalyticsViewID:(NSString *)thinkingAnalyticsViewID {
    objc_setAssociatedObject(self, &TD_AUTOTRACK_VIEW_ID, thinkingAnalyticsViewID, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL)thinkingAnalyticsIgnoreView {
    return [objc_getAssociatedObject(self, &TD_AUTOTRACK_VIEW_IGNORE) boolValue];
}

- (void)setThinkingAnalyticsIgnoreView:(BOOL)thinkingAnalyticsIgnoreView {
    objc_setAssociatedObject(self, &TD_AUTOTRACK_VIEW_IGNORE, [NSNumber numberWithBool:thinkingAnalyticsIgnoreView], OBJC_ASSOCIATION_ASSIGN);
}

- (NSDictionary *)thinkingAnalyticsIgnoreViewWithAppid {
    return objc_getAssociatedObject(self, &TD_AUTOTRACK_VIEW_IGNORE_APPID);
}

- (void)setThinkingAnalyticsIgnoreViewWithAppid:(NSDictionary *)thinkingAnalyticsViewProperties {
    objc_setAssociatedObject(self, &TD_AUTOTRACK_VIEW_IGNORE_APPID, thinkingAnalyticsViewProperties, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSDictionary *)thinkingAnalyticsViewIDWithAppid {
    return objc_getAssociatedObject(self, &TD_AUTOTRACK_VIEW_ID_APPID);
}

- (void)setThinkingAnalyticsViewIDWithAppid:(NSDictionary *)thinkingAnalyticsViewProperties {
    objc_setAssociatedObject(self, &TD_AUTOTRACK_VIEW_ID_APPID, thinkingAnalyticsViewProperties, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSDictionary *)thinkingAnalyticsViewProperties {
    return objc_getAssociatedObject(self, &TD_AUTOTRACK_VIEW_PROPERTIES);
}

- (void)setThinkingAnalyticsViewProperties:(NSDictionary *)thinkingAnalyticsViewProperties {
    objc_setAssociatedObject(self, &TD_AUTOTRACK_VIEW_PROPERTIES, thinkingAnalyticsViewProperties, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSDictionary *)thinkingAnalyticsViewPropertiesWithAppid {
    return objc_getAssociatedObject(self, &TD_AUTOTRACK_VIEW_PROPERTIES_APPID);
}

- (void)setThinkingAnalyticsViewPropertiesWithAppid:(NSDictionary *)thinkingAnalyticsViewProperties {
    objc_setAssociatedObject(self, &TD_AUTOTRACK_VIEW_PROPERTIES_APPID, thinkingAnalyticsViewProperties, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)thinkingAnalyticsDelegate {
    return objc_getAssociatedObject(self, &TD_AUTOTRACK_VIEW_DELEGATE);
}

- (void)setThinkingAnalyticsDelegate:(id)thinkingAnalyticsDelegate {
    objc_setAssociatedObject(self, &TD_AUTOTRACK_VIEW_DELEGATE, thinkingAnalyticsDelegate, OBJC_ASSOCIATION_ASSIGN);
}

@end
