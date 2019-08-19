#import "ThinkingAnalyticsSDK.h"
#import "ThinkingAnalyticsSDKPrivate.h"

#import <objc/runtime.h>

#import "TDLogging.h"
#import "ThinkingExceptionHandler.h"

#import "TDNetwork.h"
#import "TDDeviceInfo.h"
#import "TDFlushConfig.h"
#import "TDConfigPrivate.h"
#import "TDSqliteDataQueue.h"
#import "TDAutoTrackManager.h"

#if !__has_feature(objc_arc)
#error The ThinkingSDK library must be compiled with ARC enabled
#endif

static NSString * const TA_JS_TRACK_SCHEME = @"thinkinganalytics://trackEvent";
static const NSUInteger kBatchSize = 50;
static NSUInteger const TA_PROPERTY_LENGTH_LIMITATION = 2048;
static NSUInteger const TA_PROPERTY_CRASH_LENGTH_LIMITATION = 8191*2;

@interface ThinkingAnalyticsSDK()

@property (atomic, strong) TDNetwork *network;
@property (atomic, strong) TDDeviceInfo *deviceInfo;
@property (atomic, strong) TDFlushConfig *flushConfig;
@property (atomic, strong) TDSqliteDataQueue *dataQueue;
@property (atomic, strong) TDAutoTrackManager *autoTrackManager;

@end

@implementation ThinkingAnalyticsSDK{
    NSDateFormatter *_timeFormatter;
    ThinkingAnalyticsAutoTrackEventType _autoTrackEventType;
    BOOL _isTrackRelaunchInBackGroundEvents;
    BOOL _applicationWillResignActive;
    BOOL _appRelaunched;
    BOOL _isWifi;
    NSString *_radio;
}

static ThinkingAnalyticsSDK *sharedInstance = nil;

static NSMutableDictionary *instances;
static NSString *defaultProjectAppid;

static dispatch_queue_t serialQueue;
static dispatch_queue_t networkQueue;

+ (nullable ThinkingAnalyticsSDK *)sharedInstance
{
    if (instances.count == 0) {
        TDLogError(@"sharedInstance called before creating a Thinking instance");
        return nil;
    }
    
    if (instances.count > 1) {
//        TDLogDebug(@"sharedInstance called with multiple thinkingsdk instances. Using (the first) token %@", defaultProjectAppid);
    }
    
    return instances[defaultProjectAppid];
}

+ (ThinkingAnalyticsSDK *)sharedInstanceWithAppid:(NSString *)appid
{
    if (instances[appid]) {
        return instances[appid];
    } else {
        TDLogError(@"sharedInstanceWithAppid called before creating a Thinking instance");
        return nil;
    }
}

+ (ThinkingAnalyticsSDK *)startWithAppId:(NSString *)appId withUrl:(NSString *)url withConfig:(TDConfig*)config {
    if (instances[appId]) {
        return instances[appId];
    } else if ([url isKindOfClass:[NSString class]] && url.length == 0) {
        return nil;
    }
    
    return [[self alloc] initWithAppkey:appId withServerURL:url withConfig:config];
}

+ (ThinkingAnalyticsSDK *)startWithAppId:(NSString *)appId withUrl:(NSString *)url
{
    return [ThinkingAnalyticsSDK startWithAppId:appId withUrl:url withConfig:nil];
}

- (instancetype)init:(NSString *)appID
{
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

- (instancetype)initWithAppkey:(NSString *)appid withServerURL:(NSString *)serverURL withConfig:(TDConfig *)config{
    if (self = [self init:appid]) {
        
        if (!config) {
            config = TDConfig.defaultTDConfig;
        }
        
        _autoTrackEventType = ThinkingAnalyticsEventTypeNone;
        
        self.serverURL = [NSString stringWithFormat:@"%@/sync",serverURL];
        self.appid = appid;
        
        self.trackTimer = [NSMutableDictionary dictionary];
        _timeFormatter = [[NSDateFormatter alloc]init];
        _timeFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
        _timeFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        _timeFormatter.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];

        _applicationWillResignActive = NO;
        _ignoredViewControllers = [[NSMutableSet alloc] init];
        _ignoredViewTypeList = [[NSMutableSet alloc] init];
        
        self.taskId = UIBackgroundTaskInvalid;
        self.telephonyInfo = [[CTTelephonyNetworkInfo alloc] init];
        
        NSString *keyPattern = @"^[a-zA-Z][a-zA-Z\\d_#]{0,49}$";
        self.regexKey = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", keyPattern];
        
        self.dataQueue = [TDSqliteDataQueue sharedInstanceWithAppid:appid];
        if (self.dataQueue == nil) {
            TDLogError(@"SqliteException: init SqliteDataQueue failed");
        }
        
        [self setUpListeners];
        
        self.deviceInfo = [TDDeviceInfo sharedManager];
        self.flushConfig = [TDFlushConfig sharedManagerWithAppid:appid withServerURL:serverURL];
        self.autoTrackManager = [TDAutoTrackManager sharedManager];
        
        [self retrievePersistedData];
        
        _isTrackRelaunchInBackGroundEvents = config.trackRelaunchedInBackgroundEvents;
        _network = [[TDNetwork alloc] initWithServerURL:[NSURL URLWithString:self.serverURL] withAutomaticData:_deviceInfo.automaticData];
        
        td_dispatch_main_sync_safe(^{
            UIApplicationState applicationState = [UIApplication sharedApplication].applicationState;
            if (applicationState == UIApplicationStateBackground) {
                self->_relaunchInBackGround = YES;
            }
        });
        
        instances[appid] = self;
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<ThinkingAnalyticsSDK: %p - appid: %@ serverUrl:%@>", (void *)self, self.appid, self.serverURL];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (_reachability != NULL) {
        if (!SCNetworkReachabilitySetCallback(_reachability, NULL, NULL)) {
        }
        if (!SCNetworkReachabilitySetDispatchQueue(_reachability, NULL)) {
        }
        CFRelease(_reachability);
        _reachability = NULL;
    }
    
    [self stopFlushTimer];
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
    [self archiveIsEnabled:self.isEnabled];
}

- (BOOL)hasDisabled {
    return !_isEnabled || _isOptOut;
}

- (void)optOutTracking {
    TDLogDebug(@"%@ optOutTracking...", self);
    dispatch_async(serialQueue, ^{
        @synchronized (instances) {
            [self.dataQueue deleteAll:self.appid];
        }
        
        [self.trackTimer removeAllObjects];
        self.superPropertie = [NSDictionary new];
        self.identifyId = self.deviceInfo.uniqueId;
        self.accountId = nil;
        
        [self archiveAccountID:nil];
        [self archiveIdentifyId:nil];
        [self archiveSuperProperties:nil];
        
        self.isOptOut = YES;
        [self archiveOptOut:YES];
    });
}

- (void)optInTracking {
    TDLogDebug(@"%@ optInTracking...", self);
    self.isOptOut = NO;
    [self archiveOptOut:NO];
}

#pragma mark - Persistence
- (void)retrievePersistedData {
    [self unarchiveAccountID];
    [self unarchiveSuperProperties];
    [self unarchiveIdentifyID];
    [self unarchiveIsEnabled];
    [self unarchiveOptOut];
    
    if(self.identifyId.length == 0) {
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
    NSString *identifyId = (NSString *)[ThinkingAnalyticsSDK unarchiveFromFile:[self identifyIdFilePath] asClass:[NSString class]];
    self.identifyId = identifyId;
}

- (void)unarchiveAccountID {
    NSString *accountID = (NSString *)[ThinkingAnalyticsSDK unarchiveFromFile:[self accountIDFilePath] asClass:[NSString class]];
    self.accountId = accountID;
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
    NSDictionary *superProperties = (NSDictionary *)[ThinkingAnalyticsSDK unarchiveFromFile:[self superPropertiesFilePath] asClass:[NSDictionary class]];
    self.superPropertie = [superProperties copy];
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

- (void)unarchiveIsEnabled {
    NSNumber *isEnabled = (NSNumber *)[ThinkingAnalyticsSDK unarchiveFromFile:[self enabledFilePath] asClass:[NSNumber class]];
    if(isEnabled == nil)
        self.isEnabled = YES;
    else
        self.isEnabled = [isEnabled boolValue];
}

- (BOOL)archiveObject:(id)object withFilePath:(NSString *)filePath {
    @try {
        if (![NSKeyedArchiver archiveRootObject:object toFile:filePath]) {
            return NO;
        }
    } @catch (NSException* exception) {
        TDLogError(@"Got exception: %@, reason: %@. You can only send to Thinking values that inherit from NSObject and implement NSCoding.", exception.name, exception.reason);
        return NO;
    }
    
    [self addSkipBackupAttributeToItemAtPath:filePath];
    return YES;
}

- (BOOL)addSkipBackupAttributeToItemAtPath:(NSString *)filePathString {
    NSURL *URL = [NSURL fileURLWithPath: filePathString];
    assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
    
    NSError *error = nil;
    BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
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

- (NSInteger)saveClickData:(NSDictionary *)data {
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
- (void)setUpListeners {
    if ((_reachability = SCNetworkReachabilityCreateWithName(NULL, "thinkingdata.cn")) != NULL) {
        SCNetworkReachabilityContext context = {0, (__bridge void*)self, NULL, NULL, NULL};
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

- (void)applicationWillTerminateNotification:(NSNotification *)notification {
    TDLogDebug(@"%@ applicationWillTerminateNotification", self);
    dispatch_sync(serialQueue, ^{});
}

- (void)applicationWillEnterForeground:(NSNotification *)notification {
    TDLogDebug(@"%@ application will enter foreground", self);
    self.relaunchInBackGround = NO;
    
    _appRelaunched = YES;
    dispatch_async(serialQueue, ^{
        if (self.taskId != UIBackgroundTaskInvalid) {
            [[ThinkingAnalyticsSDK sharedUIApplication] endBackgroundTask:self.taskId];
            self.taskId = UIBackgroundTaskInvalid;
        }
    });
}

- (void)applicationDidEnterBackground:(NSNotification *)notification {
    TDLogDebug(@"%@ application did enter background", self);
    self.relaunchInBackGround = NO;
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
        NSArray *keys = [self.trackTimer allKeys];
        for (NSString *key in keys) {
            if ([key isEqualToString:@"ta_app_end"]) {
                continue;
            }
            NSMutableDictionary *eventTimer = [[NSMutableDictionary alloc] initWithDictionary:self.trackTimer[key]];
            if (eventTimer) {
                NSNumber *eventBegin = [eventTimer valueForKey:@"eventBegin"];
                NSNumber *eventAccumulatedDuration = [eventTimer objectForKey:@"eventAccumulatedDuration"];
                double eventDuration;
                if (eventAccumulatedDuration) {
                    eventDuration = [currentSystemUpTime doubleValue] - [eventBegin doubleValue] + [eventAccumulatedDuration doubleValue];
                } else {
                    eventDuration = [currentSystemUpTime doubleValue] - [eventBegin doubleValue];
                }
                [eventTimer setObject:[NSNumber numberWithDouble:eventDuration] forKey:@"eventAccumulatedDuration"];
                self.trackTimer[key] = eventTimer;
            }
        }
        dispatch_group_leave(bgGroup);
    });
    
    if (_autoTrackEventType & ThinkingAnalyticsEventTypeAppEnd) {
        [self autotrack:APP_END_EVENT properties:nil withTime:nil];
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
        NSNumber *currentSystemUpTime = @([[NSDate date] timeIntervalSince1970]);
        NSArray *keys = [self.trackTimer allKeys];
        for (NSString *key in keys) {
            NSMutableDictionary *eventTimer = [[NSMutableDictionary alloc] initWithDictionary:self.trackTimer[key]];
            if (eventTimer) {
                [eventTimer setValue:currentSystemUpTime forKey:@"eventBegin"];
                self.trackTimer[key] = eventTimer;
            }
        }
    });
    
    if (_appRelaunched) {
        if (_autoTrackEventType & ThinkingAnalyticsEventTypeAppStart) {
            [self autotrack:APP_START_EVENT properties:@{
                                                         RESUME_FROM_BACKGROUND_PROPERTY : @(_appRelaunched)
                                                         } withTime:nil];
        }
        if (_autoTrackEventType & ThinkingAnalyticsEventTypeAppEnd) {
            [self timeEvent:APP_END_EVENT];
        }
    }
}

- (void)setNetworkType:(ThinkingAnalyticsNetworkType)type {
    if([self hasDisabled])
        return;
        
    [self.flushConfig setNetworkType:type];
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
    _isWifi = (flags & kSCNetworkReachabilityFlagsReachable) && !(flags & kSCNetworkReachabilityFlagsIsWWAN);
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

- (NSString *)getNetWorkStates {
    if (_isWifi) {
        return @"WIFI";
    } else {
        return _radio;
    }
}

- (void)setCurrentRadio {
    dispatch_async(serialQueue, ^{
        self->_radio = [self currentRadio];
    });
}

#pragma mark - Tracking
- (void)track:(NSString *)event {
    [self track:event withProperties:nil withType:@"track"];
}

- (void)track:(NSString *)event
   properties:(NSDictionary *)propertieDict {
    [self track:event withProperties:propertieDict withType:@"track"];
}

- (void)track:(NSString *)event
   properties:(NSDictionary *)propertieDict
         time:(NSDate *)time {
    [self track:event withProperties:propertieDict withType:@"track" withTime:time isCheckProperties:YES];
}

- (void)autotrack:(NSString *)event
       properties:(NSDictionary *)propertieDict
         withTime:(NSDate *)date {
    [self track:event withProperties:propertieDict withType:@"track" withTime:date isCheckProperties:NO];
}

- (NSString *)getDistinctId{
    __block NSString *distinctId = nil;
    dispatch_sync(serialQueue, ^{
        distinctId = self->_identifyId;
    });
    return distinctId;
}

- (NSString *)getDeviceId {
    return _deviceInfo.deviceId;
}

- (void)registerDynamicSuperProperties:(NSDictionary<NSString *, id> *(^)(void)) dynamicSuperProperties {
    if([self hasDisabled])
        return;
        
    dispatch_async(serialQueue, ^{
        self.dynamicSuperProperties = dynamicSuperProperties;
    });
}

- (void)setSuperProperties:(NSDictionary *)properties {
    if([self hasDisabled])
        return;
        
    properties = [properties copy];
    if (properties == nil) {
        return;
    }
    
    if (![self checkAutoTrackProperties:&properties]) {
        TDLogError(@"%@ propertieDict error.", properties);
        return;
    }
    
    dispatch_async(serialQueue, ^{
        NSMutableDictionary *tmp = [NSMutableDictionary dictionaryWithDictionary:self.superPropertie];
        [tmp addEntriesFromDictionary:[properties copy]];
        self.superPropertie = [NSDictionary dictionaryWithDictionary:tmp];
        [self archiveSuperProperties:self.superPropertie];
    });
}

- (void)unsetSuperProperty:(NSString *)propertyKey {
    if([self hasDisabled])
        return;
        
    if ([propertyKey isKindOfClass:[NSString class]] && propertyKey.length == 0)
        return;
    
    dispatch_async(serialQueue, ^{
        NSMutableDictionary *tmp = [NSMutableDictionary dictionaryWithDictionary:self.superPropertie];
        tmp[propertyKey] = nil;
        self.superPropertie = [NSDictionary dictionaryWithDictionary:tmp];
        [self archiveSuperProperties:self.superPropertie];
    });
}

- (void)clearSuperProperties {
    if([self hasDisabled])
        return;
        
    dispatch_async(serialQueue, ^{
        self.superPropertie = @{};
        [self archiveSuperProperties:nil];
    });
}

- (NSDictionary *)currentSuperProperties {
    __block NSDictionary *currentSuperProperties = nil;
    dispatch_sync(serialQueue, ^{
        currentSuperProperties = [self->_superPropertie copy];
    });
    return currentSuperProperties;
}

- (void)identify:(NSString *)distinctId {
    if([self hasDisabled])
        return;
        
    if ([distinctId isKindOfClass:[NSString class]] && distinctId.length == 0) {
        TDLogError(@"identify cannot null");
        return;
    }
    
    dispatch_async(serialQueue, ^{
        if (self.identifyId != distinctId) {
            self.identifyId = distinctId;
            [self archiveIdentifyId:distinctId];
        }
    });
}

- (void)login:(NSString *)accountId {
    if([self hasDisabled])
        return;
        
    if (![accountId isKindOfClass:[NSString class]] || accountId.length == 0) {
        TDLogError(@"accountId invald", accountId);
        return;
    }
    
    dispatch_async(serialQueue, ^{
        if (![accountId isEqualToString:[self accountId]]) {
            self.accountId = accountId;
            [self archiveAccountID:accountId];
        }
    });
}

- (void)logout {
    if([self hasDisabled])
        return;
    
    dispatch_async(serialQueue, ^{
        self.accountId = nil;
        [self archiveAccountID:nil];
    });
}

- (void)user_add:(NSString *)propertyName andPropertyValue:(NSNumber *)propertyValue {
    if([self hasDisabled])
        return;
        
    NSDictionary *dic = @{[propertyName copy]:[propertyValue copy]};
    [self track:nil withProperties:dic withType:@"user_add"];
}

- (void)user_add:(NSDictionary *)property {
    if([self hasDisabled])
        return;
        
    [self track:nil withProperties:property withType:@"user_add"];
}

- (void)user_setOnce:(NSDictionary *)property {
    if([self hasDisabled])
        return;
        
    [self track:nil withProperties:property withType:@"user_setOnce"];
}

- (void)user_set:(NSDictionary *)property {
    if([self hasDisabled])
        return;
        
    [self track:nil withProperties:property withType:@"user_set"];
}

- (void)user_delete {
    if([self hasDisabled])
        return;
        
    [self track:nil withProperties:@{} withType:@"user_del"];
}

- (void)timeEvent:(NSString *)event {
    if([self hasDisabled])
        return;
        
    if (![event isKindOfClass:[NSString class]] || event.length == 0 || ![self isValidName: event]) {
        NSString *errMsg = [NSString stringWithFormat:@"timeEvent parameter[%@] is not valid", event];
        TDLogError(errMsg);
        return ;
    }
    
    NSNumber *eventBegin = @([[NSDate date] timeIntervalSince1970]);
    dispatch_async(serialQueue, ^{
        self.trackTimer[event] = @{@"eventBegin" : eventBegin, @"eventAccumulatedDuration" : [NSNumber numberWithDouble:0]};
    });
}

- (BOOL)isValidName:(NSString *)name {
    @try {
        return [self.regexKey evaluateWithObject:name];
    } @catch (NSException *exception) {
        TDLogError(@"%@: %@", self, exception);
        return YES;
    }
}

+ (BOOL)checkAutoTrackProperties:(NSDictionary**)dic {
    return [[self sharedInstance] checkProperties:dic withEventType:nil isCheckKey:YES];
}

- (BOOL)checkAutoTrackProperties:(NSDictionary**)dic {
    return [self checkProperties:dic withEventType:nil isCheckKey:YES];
}

- (NSString *)subByteString:(NSString *)originalString byteLength:(NSInteger)length {
    NSStringEncoding encoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingUTF8);
    NSData* originalData = [originalString dataUsingEncoding:encoding];
    NSData* subData = [originalData subdataWithRange:NSMakeRange(0, length)];
    NSString* limitString = [[NSString alloc] initWithData:subData encoding:encoding];
    
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

- (BOOL)checkProperties:(NSDictionary **)propertiesAddress withEventType:(NSString *)eventType isCheckKey:(BOOL)checkKey {
    NSDictionary *properties = *propertiesAddress;
    if (![properties isKindOfClass:[NSDictionary class]]) {
        return NO;
    }
    NSMutableDictionary *newProperties = [NSMutableDictionary dictionaryWithDictionary:properties];
    for (id key in properties) {
        if (![key isKindOfClass:[NSString class]]) {
            NSString *errMsg = @"property Key should by NSString";
            TDLogError(errMsg);
            return NO;
        }
        
        if (![self isValidName: key] && checkKey) {
            NSString *errMsg = [NSString stringWithFormat:@"property name[%@] is not valid", key];
            TDLogError(errMsg);
            return NO;
        }

        if (![properties[key] isKindOfClass:[NSString class]] &&
            ![properties[key] isKindOfClass:[NSNumber class]] &&
            ![properties[key] isKindOfClass:[NSDate class]]) {
            NSString * errMsg = [NSString stringWithFormat:@"property values must be NSString, NSNumber got: %@ %@", [properties[key] class], properties[key]];
            TDLogError(errMsg);
            return NO;
        }
        
        if (eventType.length > 0 && [eventType isEqualToString:@"user_add"]) {
            if (![properties[key] isKindOfClass:[NSNumber class]]) {
                NSString *errMsg = [NSString stringWithFormat:@"user_add value must be NSNumber. got: %@ %@", [properties[key] class], properties[key]];
                TDLogError(errMsg);
                return NO;
            }
        }
       
        if ([properties[key] isKindOfClass:[NSNumber class]]) {
            if ([properties[key] doubleValue] > 9999999999999.999 || [properties[key] doubleValue] < -9999999999999.999) {
                TDLogError(@"number value is not valid.");
                return NO;
            }
        }
        
        if ([properties[key] isKindOfClass:[NSString class]]) {
            NSString *string = properties[key];
            NSUInteger objLength = [((NSString *)string)lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
            NSUInteger valueMaxLength = TA_PROPERTY_LENGTH_LIMITATION;

            if ([key isEqualToString:TD_EVENT_PROPERTY_ELEMENT_ID_CRASH_REASON]) {
                valueMaxLength = TA_PROPERTY_CRASH_LENGTH_LIMITATION;
            }
            if (objLength > valueMaxLength) {
                NSString * errMsg = [NSString stringWithFormat:@"The value is too long: %@", (NSString *)properties[key]];
                TDLogDebug(errMsg);
                
                NSMutableString *newObject = [NSMutableString stringWithString:[self subByteString:string byteLength:valueMaxLength - 1]];
                [newProperties setObject:newObject forKey:key];
            }
        }
    }
    
    if (newProperties) {
        *propertiesAddress = [NSDictionary dictionaryWithDictionary:newProperties];
    }
    
    return YES;
}

- (void)clickFromH5:(NSString *)data {
    NSData *jsonData = [data dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *eventDict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                              options:NSJSONReadingMutableContainers
                                                                error:&err];
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
            
            dispatch_async(serialQueue, ^{
                NSDate *destDate;
                if ([time isKindOfClass:[NSString class]] && time.length > 0) {
                    destDate = [self->_timeFormatter dateFromString:time];
                }
                [self track:event_name withProperties:dic withType:type withTime:destDate isCheckProperties:NO];
            });
        }
    }
}

- (void)track:(NSString *)event
withProperties:(NSDictionary *)propertieDict
     withType:(NSString *)type {
    [self track:event withProperties:propertieDict withType:type withTime:[NSDate date] isCheckProperties:YES];
}

     - (void)track:(NSString *)event
    withProperties:(NSDictionary *)propertieDict
          withType:(NSString *)type
          withTime:(NSDate *)time
 isCheckProperties:(BOOL)check {
    if([self hasDisabled])
        return;
         
    if (_relaunchInBackGround && !_isTrackRelaunchInBackGroundEvents) {
        return;
    }
         
    if ([type isEqualToString:@"track"]) {
        if (![event isKindOfClass:[NSString class]] || event.length == 0) {
            TDLogError(@"track event key is not valid");
            return;
        }
        
        if (![self isValidName: event]) {
            NSString *errMsg = [NSString stringWithFormat:@"property name[%@] is not valid", event];
            TDLogError(@"%@", errMsg);
            return;
        }
    }
     
    if (propertieDict && ![self checkProperties:&propertieDict withEventType:type isCheckKey:check]) {
        TDLogError(@"%@ property error.", propertieDict);
        return;
    }
         
    propertieDict = [propertieDict copy];
    __block NSDictionary *dynamicSuperPropertiesDict = self.dynamicSuperProperties ? self.dynamicSuperProperties() : nil;
    
    dispatch_async(serialQueue, ^{
        NSString *timeStamp;
        if (time == nil) {
            timeStamp = [self->_timeFormatter stringFromDate:[NSDate date]];
        } else {
            timeStamp = [self->_timeFormatter stringFromDate:time];
        }
        
        NSString *networkType = [self getNetWorkStates];
        NSMutableDictionary *propertyDic = [NSMutableDictionary dictionary];
        if ([propertyDic objectForKey:@"#network_type"] == nil && [type isEqualToString:@"track"]) {
            propertyDic[@"#network_type"] = networkType;
        }
        
        if ([type isEqualToString:@"track"]) {
            [propertyDic addEntriesFromDictionary:self.superPropertie];
            propertyDic[@"#app_version"] = self->_deviceInfo.appVersion;
            if (self.relaunchInBackGround) {
                propertyDic[@"#relaunched_in_background"] = @YES;
            }
        }

        if ([self checkAutoTrackProperties:&dynamicSuperPropertiesDict]) {
            [propertyDic addEntriesFromDictionary:dynamicSuperPropertiesDict];
        }
        
        if (propertieDict) {
            NSArray *keys = propertieDict.allKeys;
            for (id key in keys) {
                NSObject *obj = propertieDict[key];
                if ([obj isKindOfClass:[NSDate class]]) {
                    NSString *dateStr = [self->_timeFormatter stringFromDate:(NSDate *)obj];
                    [propertyDic setObject:dateStr forKey:key];
                } else {
                    [propertyDic setObject:obj forKey:key];
                }
            }
        }
        
        NSDictionary *eventTimer = self.trackTimer[event];
        if (eventTimer) {
            [self.trackTimer removeObjectForKey:event];
            NSNumber *eventBegin = [eventTimer valueForKey:@"eventBegin"];
            NSNumber *eventAccumulatedDuration = [eventTimer objectForKey:@"eventAccumulatedDuration"];
          
            double eventDuration;
            NSNumber *currentSystemUpTime = @([[NSDate date] timeIntervalSince1970]);
            if (eventAccumulatedDuration) {
                eventDuration = [currentSystemUpTime doubleValue] - [eventBegin doubleValue] + [eventAccumulatedDuration doubleValue];
            } else {
                eventDuration = [currentSystemUpTime doubleValue] - [eventBegin doubleValue];
            }
            
            if (eventDuration > 0) {
                propertyDic[@"#duration"] = @([[NSString stringWithFormat:@"%.3f", eventDuration] floatValue]);
            }
        }
        
        NSString *loginId = self.accountId;
        
        NSMutableDictionary *dataDic = [NSMutableDictionary dictionary];
        dataDic[@"#time"] = timeStamp;
        dataDic[@"#type"] = type;
        dataDic[@"#uuid"] = [[NSUUID UUID] UUIDString];
        
        if (self.identifyId.length > 0) {
            dataDic[@"#distinct_id"] = self.identifyId;
        }
        if (propertyDic.allKeys.count > 0) {
            dataDic[@"properties"] = propertyDic;
        }
        if (event) {
            dataDic[@"#event_name"] = event;
        }
        if (loginId.length) {
            dataDic[@"#account_id"] = loginId;
        }
        
        NSInteger count = [self saveClickData:dataDic];
        TDLogDebug(@"queueing data:%@",dataDic);
        
        if (count >= self.flushConfig.uploadSize) {
            [self flush];
        }
    });
}

- (void)flush {
    [self syncWithCompletion:nil];
}

- (void)syncWithCompletion:(void (^)(void))handler {
    [self dispatchOnNetworkQueue:^{
        [self _sync:NO];
        if (handler) {
            dispatch_async(dispatch_get_main_queue(), handler);
        }
    }];
}

- (void)_sync:(BOOL)vacuumAfterFlushing {
    NSString *networkType = [self getNetWorkStates];
    if (!([self convertNetworkType:networkType] & self.flushConfig.networkTypePolicy)) {
        return;
    }
    
    NSArray *recordArray;
    
    @synchronized (instances) {
        recordArray = [self.dataQueue getFirstRecords:kBatchSize withAppid:self.appid];
    }
    
    BOOL flushSucc = YES;
    while (recordArray.count > 0 && flushSucc) {
        NSUInteger sendSize = recordArray.count;
        flushSucc = [self.network flushEvents:recordArray withAppid:self.appid];
        if (flushSucc) {
            @synchronized (instances) {
                [self.dataQueue removeFirstRecords:sendSize withAppid:self.appid];
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
+ (void)restartFlushTimer {
    for (NSString *appid in instances) {
        dispatch_async(serialQueue, ^{
            ThinkingAnalyticsSDK *instance = [instances objectForKey:appid];
            [instance startFlushTimer];
        });
    }
}

- (void)startFlushTimer {
    [self stopFlushTimer];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.flushConfig.uploadInterval > 0) {
            self.timer = [NSTimer scheduledTimerWithTimeInterval:self.flushConfig.uploadInterval
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
    if([self hasDisabled])
        return;
        
    _autoTrackEventType = eventType;
    if (_deviceInfo.isFirstOpen && (_autoTrackEventType & ThinkingAnalyticsEventTypeAppInstall)) {
        [self autotrack:APP_INSTALL_EVENT properties:nil withTime:nil];
    }
    
    if (!self.relaunchInBackGround && (_autoTrackEventType & ThinkingAnalyticsEventTypeAppEnd)) {
        [self timeEvent:APP_END_EVENT];
    }

    if (_autoTrackEventType & ThinkingAnalyticsEventTypeAppStart) {
        NSString *eventName = self.relaunchInBackGround ? APP_START_BACKGROUND_EVENT : APP_START_EVENT;
        [self autotrack:eventName properties:@{RESUME_FROM_BACKGROUND_PROPERTY : @(_appRelaunched)} withTime:nil];
    }
    
    [_autoTrackManager trackWithAppid:self.appid withOption:eventType];
    
    if (_autoTrackEventType & ThinkingAnalyticsEventTypeAppViewCrash) {
        [self trackCrash];
    }
}

- (void)ignoreViewType:(Class)aClass {
    if([self hasDisabled])
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
    return !(_autoTrackEventType & eventType);
}

- (void)ignoreAutoTrackViewControllers:(NSArray *)controllers {
    if([self hasDisabled])
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
    NSString *queryKey = [queryItem firstObject];
    NSString *queryValue = [queryItem lastObject];
    
    Class wkWebViewClass = NSClassFromString(@"WKWebView");
    if ([urlStr rangeOfString:TA_JS_TRACK_SCHEME].length > 0) {
        if([self hasDisabled])
            return YES;
        
        if (([queryKey isKindOfClass:[NSString class]] && queryKey.length == 0) || ([queryValue isKindOfClass:[NSString class]] && queryValue.length == 0))
            return YES;
        
        if ([webView isKindOfClass:[UIWebView class]] || (wkWebViewClass && [webView isKindOfClass:wkWebViewClass])) {
            NSString* uploadData = [queryValue stringByRemovingPercentEncoding];
            if (uploadData.length > 0)
                [self clickFromH5:uploadData];
        }
    }
    return YES;
}

- (NSString *)getUserAgent {
    __block NSString *currentUA;
    if (currentUA  == nil)  {
        td_dispatch_main_sync_safe(^{
            UIWebView* webView = [[UIWebView alloc] initWithFrame:CGRectZero];
            currentUA = [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
        });
    }
    return currentUA;
}

- (void)addWebViewUserAgent {
    if([self hasDisabled])
        return;
        
    NSString *userAgent = [self getUserAgent];
    if ([userAgent rangeOfString:@"td-sdk-ios"].location == NSNotFound) {
        userAgent = [userAgent stringByAppendingString:@" /td-sdk-ios"];
    }
    
    NSDictionary *dictionnary = [[NSDictionary alloc] initWithObjectsAndKeys:userAgent, @"UserAgent", nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:dictionnary];
    [[NSUserDefaults standardUserDefaults] synchronize];
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

@implementation UIView (ThinkingAnalytics)

- (NSString *)thinkingAnalyticsViewID {
    return objc_getAssociatedObject(self, @"thinkingAnalyticsViewID");
}

- (void)setThinkingAnalyticsViewID:(NSString *)thinkingAnalyticsViewID {
    objc_setAssociatedObject(self, @"thinkingAnalyticsViewID", thinkingAnalyticsViewID, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL)thinkingAnalyticsIgnoreView {
    return [objc_getAssociatedObject(self, @"thinkingAnalyticsIgnoreView") boolValue];
}

- (void)setThinkingAnalyticsIgnoreView:(BOOL)thinkingAnalyticsIgnoreView {
    objc_setAssociatedObject(self, @"thinkingAnalyticsIgnoreView", [NSNumber numberWithBool:thinkingAnalyticsIgnoreView], OBJC_ASSOCIATION_ASSIGN);
}

- (NSDictionary *)thinkingAnalyticsIgnoreViewWithAppid {
    return objc_getAssociatedObject(self, @"thinkingAnalyticsIgnoreViewWithAppid");
}

- (void)setThinkingAnalyticsIgnoreViewWithAppid:(NSDictionary *)thinkingAnalyticsViewProperties {
    objc_setAssociatedObject(self, @"thinkingAnalyticsIgnoreViewWithAppid", thinkingAnalyticsViewProperties, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSDictionary *)thinkingAnalyticsViewIDWithAppid {
    return objc_getAssociatedObject(self, @"thinkingAnalyticsViewIDWithAppid");
}

- (void)setThinkingAnalyticsViewIDWithAppid:(NSDictionary *)thinkingAnalyticsViewProperties {
    objc_setAssociatedObject(self, @"thinkingAnalyticsViewIDWithAppid", thinkingAnalyticsViewProperties, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSDictionary *)thinkingAnalyticsViewProperties {
    return objc_getAssociatedObject(self, @"thinkingAnalyticsViewProperties");
}

- (void)setThinkingAnalyticsViewProperties:(NSDictionary *)thinkingAnalyticsViewProperties {
    objc_setAssociatedObject(self, @"thinkingAnalyticsViewProperties", thinkingAnalyticsViewProperties, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSDictionary *)thinkingAnalyticsViewPropertiesWithAppid {
    return objc_getAssociatedObject(self, @"thinkingAnalyticsViewPropertiesWithAppid");
}

- (void)setThinkingAnalyticsViewPropertiesWithAppid:(NSDictionary *)thinkingAnalyticsViewProperties {
    objc_setAssociatedObject(self, @"thinkingAnalyticsViewPropertiesWithAppid", thinkingAnalyticsViewProperties, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)thinkingAnalyticsDelegate {
    return objc_getAssociatedObject(self, @"thinkingAnalyticsDelegate");
}

- (void)setThinkingAnalyticsDelegate:(id)thinkingAnalyticsDelegate {
    objc_setAssociatedObject(self, @"thinkingAnalyticsDelegate", thinkingAnalyticsDelegate, OBJC_ASSOCIATION_ASSIGN);
}

@end
