#import "ThinkingAnalyticsSDK.h"
#import "ThinkingAnalyticsSDKPrivate.h"
#import "TDSqliteDataQueue.h"

#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

#import "TDSDKReachabilityManager.h"
#import "NSData+TDGzip.h"

#import "TDKeychainItemWrapper.h"
#import <objc/runtime.h>
#import "TDSwizzler.h"
#import "UIViewController+AutoTrack.h"
#import "NSObject+TDSwizzle.h"
#import "TDNetwork.h"
#import "TDDeviceInfo.h"
#import "TDFlushConfig.h"

static NSString * const TA_JS_TRACK_SCHEME = @"thinkinganalytics://trackEvent";
static const NSUInteger kBatchSize = 50;
static NSUInteger const TA_PROPERTY_LENGTH_LIMITATION = 2048;
static NSUInteger const TA_PROPERTY_CRASH_LENGTH_LIMITATION = 8191*2;

@interface ThinkingAnalyticsSDK()<NSURLSessionDelegate>

@property (atomic, copy) NSString *appid;
@property (atomic, copy) NSString *serverURL;
@property (atomic, copy) NSString *accountId;
@property (atomic, copy) NSString *identifyId;

@property (atomic, strong) NSDictionary *systemProperties;
@property (nonatomic, strong) NSMutableDictionary *trackTimer;

@property (atomic, strong) NSPredicate *regexKey;

@property (atomic, strong) TDSqliteDataQueue *dataQueue;
@property (atomic, strong) TDDeviceInfo *deviceInfo;
@property (atomic, strong) TDFlushConfig *flushConfig;
@property (atomic, strong) TDNetwork *network;

@property (nonatomic, strong) NSTimer *timer;

@property (atomic, strong) NSMutableSet *ignoredViewControllers;
@property (atomic, strong) NSMutableSet *ignoredViewTypeList;

@property (nonatomic, assign) UIBackgroundTaskIdentifier taskId;
@property (nonatomic, strong) CTTelephonyNetworkInfo *telephonyInfo;

@property (nonatomic, copy) NSDictionary<NSString *, id> *(^dynamicSuperProperties)(void); 

@end

@implementation ThinkingAnalyticsSDK{
    NSDateFormatter *_timeFormatter;
    ThinkingAnalyticsAutoTrackEventType _autoTrackEventType;
    BOOL _applicationWillResignActive;
    BOOL _appRelaunched;
    NSString *_userAgent;
}

static ThinkingAnalyticsSDK *sharedInstance = nil;

static NSMutableDictionary *instances;
static NSString *defaultProjectAppid;

static BOOL isUploading;

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

+ (ThinkingAnalyticsSDK *)startWithAppId:(NSString *)appId withUrl:(NSString *)url
{
    if (instances[appId]) {
        return instances[appId];
    } else if(url.length == 0) {
        return nil;
    }
    
    return [[self alloc] initWithAppkey:appId withServerURL:url];
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
        isUploading = NO;
    });
}

+ (dispatch_queue_t)serialQueue {
    return serialQueue;
}

+ (dispatch_queue_t)networkQueue {
    return networkQueue;
}

- (instancetype)initWithAppkey:(NSString *)appid withServerURL:(NSString *)serverURL {
    if (self = [self init:appid]) {
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
        
        self.deviceInfo = [TDDeviceInfo sharedManager];
        self.flushConfig = [TDFlushConfig sharedManagerWithAppid:appid withServerURL:serverURL];
        
        [self getConfig];
        [self setUpListeners];
        
        _network = [[TDNetwork alloc] initWithServerURL:[NSURL URLWithString:self.serverURL] withAutomaticData:_deviceInfo.automaticData];
        instances[appid] = self;
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<ThinkingAnalyticsSDK: %p - appid: %@ serverUrl:%@>", (void *)self, self.appid, self.serverURL];
}

-(void)getConfig {
    [self unarchiveAccountID];
    [self unarchiveSuperProperties];
    [self unarchiveIdentifyId];
    
    if(self.accountId.length == 0) {
        [self getLoginId];
        [self archiveAccountID:self.accountId];
        [self deleteOldLoginId];
    }
}

- (void)deleteOldLoginId {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"thinkingdata_accountId"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)archiveIdentifyId:(NSString *)identifyId {
    NSString *filePath = [self identifyIdFilePath];
    if (![self archiveObject:[identifyId copy] withFilePath:filePath]) {
        TDLogError(@"%@ unable to archive identifyId", self);
    }
}

-(void)unarchiveIdentifyId {
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
    self.systemProperties = [superProperties copy];
}

- (BOOL)archiveObject:(id)object withFilePath:(NSString *)filePath
{
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

- (BOOL)addSkipBackupAttributeToItemAtPath:(NSString *)filePathString
{
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

+ (id)unarchiveFromFile:(NSString *)filePath asClass:(Class)class
{
    id unarchivedData = nil;
    @try {
        unarchivedData = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
        // this check is inside the try-catch as the unarchivedData may be a non-NSObject, not responding to `isKindOfClass:` or `respondsToSelector:`
        if (![unarchivedData isKindOfClass:class]) {
            unarchivedData = nil;
        }
    }
    @catch (NSException *exception) {
        TDLogError(@"%@ unable to unarchive data in %@, starting fresh", self, filePath);
        // Reset un archived data
        unarchivedData = nil;
        // Remove the (possibly) corrupt data from the disk
        NSError *error = NULL;
        BOOL removed = [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
        if (!removed) {
            TDLogDebug(@"%@ unable to remove archived file at %@ - %@", self, filePath, error);
        }
    }
    return unarchivedData;
}

- (NSString *)superPropertiesFilePath {
    return [self filePathFor:@"superProperties"];
}

- (NSString *)accountIDFilePath
{
    return [self filePathFor:@"accountID"];
}

- (NSString *)eventsFilePath
{
    return [self filePathFor:@"syncConfig"];
}

- (NSString *)identifyIdFilePath {
    return [self filePathFor:@"identifyId"];
}

- (NSString *)filePathFor:(NSString *)data
{
    NSString *filename = [NSString stringWithFormat:@"thinking-%@-%@.plist", self.appid, data];
    return [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject]
            stringByAppendingPathComponent:filename];
}

- (void)setNetworkType:(ThinkingAnalyticsNetworkType)type
{
    [self.flushConfig setNetworkType:type];
}

- (void)setUpListeners {
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
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)applicationWillEnterForeground:(NSNotification *)notification {
    TDLogInfo(@"%@ application will enter foreground", self);
    
    _appRelaunched = YES;
    dispatch_async(serialQueue, ^{
        if (self.taskId != UIBackgroundTaskInvalid) {
            [[ThinkingAnalyticsSDK sharedUIApplication] endBackgroundTask:self.taskId];
            self.taskId = UIBackgroundTaskInvalid;
        }
    });
}

+ (UIApplication *)sharedUIApplication
{
    if ([[UIApplication class] respondsToSelector:@selector(sharedApplication)]) {
        return [[UIApplication class] performSelector:@selector(sharedApplication)];
    }
    return nil;
}

- (void)applicationDidEnterBackground:(NSNotification *)notification {
    TDLogInfo(@"%@ application did enter background", self);
    
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
    TDLogInfo(@"%@ application will resign active", self);
    _applicationWillResignActive = YES;
    [self stopFlushTimer];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    TDLogInfo(@"%@ application did become active", self);
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

- (NSString *)getDistinctId{
    __block NSString *distinctId = nil;
    dispatch_sync(serialQueue, ^{
        if (self->_identifyId.length == 0)
            distinctId = self->_deviceInfo.uniqueId;
        else
            distinctId = self->_identifyId;
    });
    return distinctId;
}

- (NSString *)getDeviceId {
    return _deviceInfo.deviceId;
}

- (NSString *)getNetWorkStates {
    NSString* network = @"NULL";
    @try {
        TDSDKReachabilityManager *reachability = [TDSDKReachabilityManager reachabilityForInternetConnection];
        TDReachabilityStatus status = [reachability currentReachabilityStatus];
        
        if (status == TDReachabilityStatusReachableViaWiFi) {
            network = @"WIFI";
        } else if (status == TDReachabilityStatusReachableViaWWAN) {
            NSString *currentRadioAccessTechnology = _telephonyInfo.currentRadioAccessTechnology;
            if ([currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyGPRS]) {
                network = @"2G";
            } else if ([currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyEdge]) {
                network = @"2G";
            } else if ([currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyWCDMA]) {
                network = @"3G";
            } else if ([currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyHSDPA]) {
                network = @"3G";
            } else if ([currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyHSUPA]) {
                network = @"3G";
            } else if ([currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyCDMA1x]) {
                network = @"3G";
            } else if ([currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyCDMAEVDORev0]) {
                network = @"3G";
            } else if ([currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyCDMAEVDORevA]) {
                network = @"3G";
            } else if ([currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyCDMAEVDORevB]) {
                network = @"3G";
            } else if ([currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyeHRPD]) {
                network = @"3G";
            } else if ([currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyLTE]) {
                network = @"4G";
            } else if (currentRadioAccessTechnology) {
                network = @"UNKNOWN";
            }
        }
    }
    @catch(NSException *exception) {
    }
    return network;
}

- (void)getLoginId {
    self.accountId = [[NSUserDefaults standardUserDefaults] objectForKey:@"thinkingdata_accountId"];
}

- (void)registerDynamicSuperProperties:(NSDictionary<NSString *, id> *(^)(void)) dynamicSuperProperties {
    dispatch_async(serialQueue, ^{
        self.dynamicSuperProperties = dynamicSuperProperties;
    });
}

- (void)setSuperProperties:(NSDictionary *)properties {
    properties = [properties copy];
    if (properties == nil) {
        return;
    }
    
    if (![self checkPropertyTypes:&properties withEventType:nil isCheckKey:YES]) {
        TDLogError(@"%@ propertieDict error.", properties);
        return;
    }
    
    dispatch_async(serialQueue, ^{
        NSMutableDictionary *tmp = [NSMutableDictionary dictionaryWithDictionary:self.systemProperties];
        [tmp addEntriesFromDictionary:[properties copy]];
        self.systemProperties = [NSDictionary dictionaryWithDictionary:tmp];
        [self archiveSuperProperties:self.systemProperties];
    });
}

- (void)unsetSuperProperty:(NSString *)property {
    if(property.length == 0)
        return;
    
    dispatch_async(serialQueue, ^{
        NSMutableDictionary *tmp = [NSMutableDictionary dictionaryWithDictionary:self.systemProperties];
        tmp[property] = nil;
        self.systemProperties = [NSDictionary dictionaryWithDictionary:tmp];
        [self archiveSuperProperties:self.systemProperties];
    });
}

- (void)clearSuperProperties {
    dispatch_async(serialQueue, ^{
        self.systemProperties = @{};
        [self archiveSuperProperties:nil];
    });
}

- (NSDictionary *)currentSuperProperties {
    __block NSDictionary *currentSuperProperties = nil;
    dispatch_sync(serialQueue, ^{
        currentSuperProperties = [self->_systemProperties copy];
    });
    return currentSuperProperties;
}

- (void)identify:(NSString *)distinctId {
    if (distinctId.length == 0) {
        TDLogError(@"identify cannot null");
        return;
    }
    
    dispatch_async(serialQueue, ^{
        if(self.identifyId != distinctId) {
            self.identifyId = distinctId;
            [self archiveIdentifyId:distinctId];
        }
    });
}

- (void)login:(NSString *)accountId {
    if (accountId.length == 0) {
        TDLogError(@"accountId cannot null", accountId);
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
    dispatch_async(serialQueue, ^{
        self.accountId = nil;
        [self archiveAccountID:nil];
    });
}

- (void)user_add:(NSString *)propertyName andPropertyValue:(NSNumber *)propertyValue {
    NSDictionary *dic = @{[propertyName copy]:[propertyValue copy]};
    [self click:nil withProperties:dic withType:@"user_add"];
}

- (void)user_add:(NSDictionary *)property {
    [self click:nil withProperties:property withType:@"user_add"];
}

- (void)user_setOnce:(NSDictionary *)property {
    [self click:nil withProperties:property withType:@"user_setOnce"];
}

- (void)user_set:(NSDictionary *)property {
    [self click:nil withProperties:property withType:@"user_set"];
}

- (void)user_delete {
    [self click:nil withProperties:@{} withType:@"user_del"];
}

- (void)timeEvent:(NSString *)event {
    if (![self isValidName: event]) {
        NSString *errMsg = [NSString stringWithFormat:@"timeEvent parameter[%@] is not valid", event];
        TDLogError(errMsg);
        return ;
    }
    
    NSNumber *eventBegin = @([[NSDate date] timeIntervalSince1970]);
    
    if (event.length == 0) {
        return;
    }
    dispatch_async(serialQueue, ^{
        self.trackTimer[event] = @{@"eventBegin" : eventBegin, @"eventAccumulatedDuration" : [NSNumber numberWithDouble:0]};
    });
}

- (void)track:(NSString *)event {
    [self click:event withProperties:nil withType:@"track"];
}

- (void)track:(NSString *)event
   properties:(NSDictionary *)propertieDict {
    [self click:event withProperties:propertieDict withType:@"track"];
}

- (void)track:(NSString *)event
   properties:(NSDictionary *)propertieDict
         time:(NSDate *)time {
    [self click:event withProperties:propertieDict withType:@"track" withTime:time isCheckProperties:YES];
}

- (void)autotrack:(NSString *)event
       properties:(NSDictionary *)propertieDict
         withTime:(NSDate *)date {
    [self click:event withProperties:propertieDict withType:@"track" withTime:date isCheckProperties:NO];
}

- (BOOL)isValidName:(NSString *) name {
    @try {
        return [self.regexKey evaluateWithObject:name];
    } @catch (NSException *exception) {
        TDLogError(@"%@: %@", self, exception);
        return YES;
    }
}

- (BOOL)checkProperties:(NSDictionary*)dic {
    dic = [dic copy];
    return [self checkPropertyTypes:&dic withEventType:nil isCheckKey:YES];
}

- (NSString *)subByteString:(NSString *)string byteLength:(NSInteger )length {
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingUTF8);
    NSData* data = [string dataUsingEncoding:enc];
    NSData* subData = [data subdataWithRange:NSMakeRange(0, length)];
    NSString* txt = [[NSString alloc] initWithData:subData encoding:enc];
    
    NSInteger index = 1;
    while (index <= 3 && !txt) {
        if (length > index) {
            subData = [data subdataWithRange:NSMakeRange(0, length - index)];
            txt = [[NSString alloc] initWithData:subData encoding:enc];
        }
        index ++;
    }
    
    if (!txt) {
        return string;
    }
    return txt;
}

- (BOOL)checkPropertyTypes:(NSDictionary **)propertiesAddress withEventType:(NSString *)eventType isCheckKey:(BOOL)checkKey{
    NSDictionary *properties = *propertiesAddress;
    NSMutableDictionary *newProperties;
    for (id k in properties) {
        if (![k isKindOfClass: [NSString class]]) {
            NSString *errMsg = @"property Key should by NSString";
            TDLogError(errMsg);
            return NO;
        }
        
        if (![self isValidName: k] && checkKey) {
            NSString *errMsg = [NSString stringWithFormat:@"property name[%@] is not valid", k];
            TDLogError(errMsg);
            return NO;
        }

        if(![properties[k] isKindOfClass:[NSString class]] &&
           ![properties[k] isKindOfClass:[NSNumber class]] &&
           ![properties[k] isKindOfClass:[NSDate class]]) {
            NSString * errMsg = [NSString stringWithFormat:@"property values must be NSString, NSNumber got: %@ %@", [properties[k] class], properties[k]];
            TDLogError(errMsg);
            return NO;
        }
        
        if (eventType.length > 0 && [eventType isEqualToString:@"user_add"]) {
            if (![properties[k] isKindOfClass:[NSNumber class]]) {
                NSString *errMsg = [NSString stringWithFormat:@"user_add value must be NSNumber. got: %@ %@", [properties[k] class], properties[k]];
                TDLogError(errMsg);
                return NO;
            }
        }
       
        if([properties[k] isKindOfClass:[NSNumber class]]) {
            if([properties[k] doubleValue] > 9999999999999.999 || [properties[k] doubleValue] < -9999999999999.999)
            {
                TDLogError(@"number value is not valid.");
                return NO;
            }
        }
        
        if ([properties[k] isKindOfClass:[NSString class]]) {
            NSString *string = properties[k];
            NSUInteger objLength = [((NSString *)string)lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
            NSUInteger valueMaxLength = TA_PROPERTY_LENGTH_LIMITATION;

            if([k isEqualToString:TD_EVENT_PROPERTY_ELEMENT_ID_CRASH_REASON]) {
                valueMaxLength = TA_PROPERTY_CRASH_LENGTH_LIMITATION;
            }
            if (objLength > valueMaxLength) {
                NSString * errMsg = [NSString stringWithFormat:@"The value is too long: %@", (NSString *)properties[k]];
                TDLogDebug(errMsg);
                
                NSMutableString *newObject = [NSMutableString stringWithString:[self subByteString:string byteLength:valueMaxLength - 1]];
                if (!newProperties) {
                    newProperties = [NSMutableDictionary dictionaryWithDictionary:properties];
                }
                [newProperties setObject:newObject forKey:k];
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
    NSMutableDictionary *eventDict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                     options:NSJSONReadingMutableContainers
                                                                       error:&err];
    id dataArr = [eventDict objectForKey:@"data"];
    if ([dataArr isKindOfClass:[NSArray class]]) {
        NSDictionary *dataInfo = [dataArr objectAtIndex:0];
        if(dataInfo != nil) {
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
                if([time isKindOfClass:[NSString class]] && time.length > 0) {
                    destDate = [self->_timeFormatter dateFromString:time];
                }
                [self click:event_name withProperties:dic withType:type withTime:destDate isCheckProperties:NO];
            });
        }
    }
}

- (void)click:(NSString *)event
withProperties:(NSDictionary *)propertieDict
     withType:(NSString *)type {
    [self click:event withProperties:propertieDict withType:type withTime:[NSDate date] isCheckProperties:YES];
}

     - (void)click:(NSString *)event
    withProperties:(NSDictionary *)propertieDict
          withType:(NSString *)type
          withTime:(NSDate *)time
 isCheckProperties:(BOOL)check {
    if([type isEqualToString:@"track"]) {
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
     
    if (propertieDict && ![self checkPropertyTypes:&propertieDict withEventType:type isCheckKey:check]) {
        TDLogError(@"%@ property error.", propertieDict);
        return;
    }
         
    propertieDict = [propertieDict copy];
    __block NSDictionary *dynamicSuperPropertiesDict = self.dynamicSuperProperties ? self.dynamicSuperProperties() : nil;
    
    dispatch_async(serialQueue, ^{
        NSString *timeStamp;
        if(time == nil) {
            timeStamp = [self->_timeFormatter stringFromDate:[NSDate date]];
        } else {
            timeStamp = [self->_timeFormatter stringFromDate:time];
        }
        
        NSString *networkType = [self getNetWorkStates];
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        if([dic objectForKey:@"#network_type"] == nil && [type isEqualToString:@"track"]) {
            [dic setObject:networkType forKey:@"#network_type"];
        }
        
        if([type isEqualToString:@"track"]) {
            [dic addEntriesFromDictionary:self.systemProperties];
            [dic setObject:self->_deviceInfo.appVersion forKey:@"#app_version"];
        }
        
        if (dynamicSuperPropertiesDict && [dynamicSuperPropertiesDict isKindOfClass:NSDictionary.class]) {
            if ([self checkPropertyTypes:&dynamicSuperPropertiesDict withEventType:nil isCheckKey:YES]) {
                [dic addEntriesFromDictionary:dynamicSuperPropertiesDict];
            }
        }
        
        if (propertieDict) {
            NSArray *keys = propertieDict.allKeys;
            for (id key in keys) {
                NSObject *obj = propertieDict[key];
                if ([obj isKindOfClass:[NSDate class]]) {
                    NSString *dateStr = [self->_timeFormatter stringFromDate:(NSDate *)obj];
                    [dic setObject:dateStr forKey:key];
                } else {
                    [dic setObject:obj forKey:key];
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
                dic[@"#duration"] = @([[NSString stringWithFormat:@"%.3f", eventDuration] floatValue]);
            }
        }
        
        NSDictionary *e;
        NSString *loginId = self.accountId;
        
        NSString *distinct;
        if(self.identifyId.length == 0 && self->_deviceInfo.uniqueId > 0) {
            distinct = self->_deviceInfo.uniqueId;
        } else if(self.identifyId.length > 0) {
            distinct = self.identifyId;
        }
        
        e = @{
              @"#time": timeStamp,
              @"#type": type,
              };
        
        NSMutableDictionary *dataDic = [e mutableCopy];
        if(distinct.length > 0) {
            [dataDic setObject:distinct forKey:@"#distinct_id"];
        }
        if(dic.allKeys.count > 0) {
            [dataDic setObject:dic forKey:@"properties"];
        }
        if (event) {
            [dataDic setObject:event forKey:@"#event_name"];
        }
        if (loginId.length) {
            [dataDic setObject:loginId forKey:@"#account_id"];
        }
        
        NSInteger count = [self saveClickData:type andEvent:dataDic];
        TDLogDebug(@"queueing data:%@", dataDic);
        
        if (count >= self.flushConfig.uploadSize && !isUploading) { 
            [self flush];
        }
    });
}

- (void)flush
{
    if(isUploading == NO) {
        [self syncWithCompletion:nil];
    }
}

- (void)syncWithCompletion:(void (^)(void))handler
{
    [self dispatchOnNetworkQueue:^{
        [self _sync:NO];
        if (handler) {
            dispatch_async(dispatch_get_main_queue(), handler);
        }
    }];
}

- (void)dispatchOnNetworkQueue:(void (^)(void))dispatchBlock
{
    dispatch_async(serialQueue, ^{
        dispatch_async(networkQueue, dispatchBlock);
    });
}

- (ThinkingNetworkType)convertNetworkType:(NSString *)networkType {
    if ([@"NULL" isEqualToString:networkType]) {
        return ThinkingNetworkTypeALL;
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
        isUploading = YES;
        NSUInteger sendSize = recordArray.count;
        
        flushSucc = [self.network flushEvents:recordArray withAppid:self.appid];
        
        if(flushSucc) {
            @synchronized (instances) {
                [self.dataQueue removeFirstRecords:sendSize withAppid:self.appid];
                recordArray = [self.dataQueue getFirstRecords:kBatchSize withAppid:self.appid];
            }
        } else {
            break;
        }
    }
    isUploading = NO;
}

- (NSInteger)saveClickData:(NSString *)type andEvent:(NSDictionary *)e {
    NSMutableDictionary *event = [[NSMutableDictionary alloc] initWithDictionary:e];
    NSInteger count;
    @synchronized (instances) {
        count = [self.dataQueue addObejct:event withAppid:self.appid];
    }
    return count;
}

+ (void)restartFlushTimer
{
    for (NSString *appid in instances) {
        dispatch_async(serialQueue, ^{
            ThinkingAnalyticsSDK *instance = [instances objectForKey:appid];
            [instance startFlushTimer];
        });
    }
}

- (void)startFlushTimer
{
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

- (void)enableAutoTrack:(ThinkingAnalyticsAutoTrackEventType)eventType {
    _autoTrackEventType = eventType;
    
    if(_autoTrackEventType & ThinkingAnalyticsEventTypeAppViewCrash) {
        [self trackCrash];
    }

    if(_autoTrackEventType & ThinkingAnalyticsEventTypeAppStart) {
        [self autotrack:APP_START_EVENT properties:@{RESUME_FROM_BACKGROUND_PROPERTY : @(_appRelaunched)} withTime:nil];
    }
    
    if(_autoTrackEventType & ThinkingAnalyticsEventTypeAppEnd) {
        [self timeEvent:APP_END_EVENT];
    }
    
    if(_autoTrackEventType & ThinkingAnalyticsEventTypeAppClick || _autoTrackEventType & ThinkingAnalyticsEventTypeAppViewScreen)
        [self _enableAutoTrack];
}

- (void)viewControlWillDisappear:(UIViewController*)controller {
    if ([ThinkingAnalyticsSDK isAutoTrackEventType:ThinkingAnalyticsEventTypeAppClick]) {
        if (!controller) {
            return;
        }
        
        Class klass = [controller class];
        if (!klass) {
            return;
        }
        
        NSString *screenName = NSStringFromClass(klass);
        
        if ([controller respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
            [TDSwizzler unswizzleSelector:@selector(tableView:didSelectRowAtIndexPath:) onClass:klass named:[NSString stringWithFormat:@"%@_%@", screenName, @"UITableView_AutoTrack"]];
        }

        if ([controller respondsToSelector:@selector(collectionView:didSelectItemAtIndexPath:)]) {
            [TDSwizzler unswizzleSelector:@selector(collectionView:didSelectItemAtIndexPath:) onClass:klass named:[NSString stringWithFormat:@"%@_%@", screenName, @"UICollectionView_AutoTrack"]];
        }
    }
}

- (void)_enableAutoTrack {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [UIViewController td_swizzleMethod:@selector(viewWillAppear:)
                                withMethod:@selector(td_autotrack_viewWillAppear:)
                                     error:NULL];

        [UIViewController td_swizzleMethod:@selector(viewWillDisappear:)
                                withMethod:@selector(td_autotrack_viewWillDisappear:)
                                     error:NULL];

    });
}

- (BOOL)isAutoTrackEventTypeIgnored:(ThinkingAnalyticsAutoTrackEventType)eventType {
    return !(_autoTrackEventType & eventType);
}

- (void)ignoreViewType:(Class)aClass {
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

- (BOOL)shouldTrackViewContrller:(Class)aClass {
    static NSSet *ignoreClasses = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        NSBundle *tdBundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:[ThinkingAnalyticsSDK class]] pathForResource:@"TDAnalyticsSDK" ofType:@"bundle"]];
        NSString *jsonFile = [tdBundle pathForResource:@"td_viewcontroller_ignorelist.json" ofType:nil];
        NSData *jsonData = [NSData dataWithContentsOfFile:jsonFile];
        @try {
            NSArray *ignorelistedArray = [NSJSONSerialization JSONObjectWithData:jsonData  options:NSJSONReadingAllowFragments error:nil];
            ignoreClasses = [NSSet setWithArray:ignorelistedArray];
        } @catch(NSException *exception) {
            TDLogError(@"error:Not import Resources file.");
        }
    });
    
    return ![ignoreClasses containsObject:NSStringFromClass(aClass)];
}

- (void)trackAppClickWithUITableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    @try {
        if (!tableView) {
            return;
        }
        
        UIView *view = (UIView *)tableView;
        if (!view) {
            return;
        }
        
        if (view.thinkingAnalyticsIgnoreView) {
            return;
        }
        
        NSMutableDictionary *properties = [[NSMutableDictionary alloc] init];
        [properties setValue:@"UITableView" forKey:TD_EVENT_PROPERTY_ELEMENT_TYPE];
        
        if (view.thinkingAnalyticsViewID.length > 0) {
            [properties setValue:view.thinkingAnalyticsViewID forKey:TD_EVENT_PROPERTY_ELEMENT_ID];
        }
        
        UIViewController *viewController = [tableView viewController];
        
        if (viewController == nil ||
            [viewController isKindOfClass:UINavigationController.class]) {
            viewController = [self currentViewController];
        }
        if (viewController != nil) {
            NSString *screenName = NSStringFromClass([viewController class]);
            [properties setValue:screenName forKey:TD_EVENT_PROPERTY_SCREEN_NAME];
            
            NSString *controllerTitle = [TDAutoTrackUtils titleFromViewController:viewController];
            if (controllerTitle) {
                [properties setValue:controllerTitle forKey:TD_EVENT_PROPERTY_TITLE];
            }
        }
        
        if (indexPath) {
            [properties setValue:[NSString stringWithFormat: @"%ld:%ld", (unsigned long)indexPath.section,(unsigned long)indexPath.row] forKey:TD_EVENT_PROPERTY_ELEMENT_POSITION];
        }
        
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        NSString *elementContent = [TDAutoTrackUtils contentFromView:cell];
        if (elementContent.length > 0) {
            elementContent = [elementContent substringWithRange:NSMakeRange(0,[elementContent length] - 1)];
            [properties setValue:elementContent forKey:TD_EVENT_PROPERTY_ELEMENT_CONTENT];
        }
        
        NSDictionary* propDict = view.thinkingAnalyticsViewProperties;
        if (propDict != nil && [self checkProperties:propDict]) {
            [properties addEntriesFromDictionary:propDict];
        }
        
        NSDictionary *propertyWithAppid;
        
        @try {
            if ([tableView.thinkingAnalyticsDelegate conformsToProtocol:@protocol(TDUIViewAutoTrackDelegate)]) {
                if ([tableView.thinkingAnalyticsDelegate respondsToSelector:@selector(thinkingAnalytics_tableView:autoTrackPropertiesAtIndexPath:)]) {
                    NSDictionary *dic = [view.thinkingAnalyticsDelegate thinkingAnalytics_tableView:tableView autoTrackPropertiesAtIndexPath:indexPath];
                    if([self checkProperties:dic])
                    {
                        [properties addEntriesFromDictionary:[view.thinkingAnalyticsDelegate thinkingAnalytics_tableView:tableView autoTrackPropertiesAtIndexPath:indexPath]];
                    }
                }
                
                if ([tableView.thinkingAnalyticsDelegate respondsToSelector:@selector(thinkingAnalyticsWithAppid_tableView:autoTrackPropertiesAtIndexPath:)]) {
                    propertyWithAppid = [view.thinkingAnalyticsDelegate thinkingAnalyticsWithAppid_tableView:tableView autoTrackPropertiesAtIndexPath:indexPath];
                }
            }
        } @catch (NSException *exception) {
            TDLogError(@"%@ error: %@", self, exception);
        }
        
        NSDate *trackDate = [NSDate date];
        for (NSString *appid in instances) {
            NSMutableDictionary *trackProperties = [properties mutableCopy];
            ThinkingAnalyticsSDK *instance = [instances objectForKey:appid];
            if ([instance isViewTypeIgnored:[UITableView class]]) {
                continue;
            }
        
            NSDictionary* ignoreViews = view.thinkingAnalyticsIgnoreViewWithAppid;
            if (ignoreViews != nil && [ignoreViews objectForKey:appid]) {
                BOOL ignore = [[ignoreViews objectForKey:appid] boolValue];
                if(ignore)
                    continue;
            }
            
            if ([instance isViewControllerIgnored:viewController]) {
                continue;
            }
            
            NSDictionary* viewIDs = view.thinkingAnalyticsViewIDWithAppid;
            if (viewIDs != nil && [viewIDs objectForKey:appid]) {
                NSString *viewId = [viewIDs objectForKey:appid];
                [trackProperties setValue:viewId forKey:TD_EVENT_PROPERTY_ELEMENT_ID];
            }
            
            NSDictionary* viewProperties = view.thinkingAnalyticsViewPropertiesWithAppid;
            if (viewProperties != nil && [viewProperties objectForKey:appid]) {
                NSDictionary *properties = [viewProperties objectForKey:appid];
                if([self checkProperties:properties]) {
                    [trackProperties addEntriesFromDictionary:properties];
                }
            }
            
            if(propertyWithAppid) {
                NSDictionary *autoTrackproperties = [propertyWithAppid objectForKey:appid];
                if([self checkProperties:autoTrackproperties]) {
                    [trackProperties addEntriesFromDictionary:autoTrackproperties];
                }
            }
            
            if (![instance isAutoTrackEventTypeIgnored:ThinkingAnalyticsEventTypeAppClick]) {
                [instance autotrack:APP_CLICK_EVENT properties:trackProperties withTime:trackDate];
            }
        }
    } @catch (NSException *exception) {
        TDLogError(@"%@ error: %@", self, exception);
    }
}

- (void)trackAppClickWithUICollectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    @try {
        if (!collectionView) {
            return;
        }
        
        UIView *view = (UIView *)collectionView;
        if (!view) {
            return;
        }
        
        if (view.thinkingAnalyticsIgnoreView) {
            return;
        }
        
        NSMutableDictionary *properties = [[NSMutableDictionary alloc] init];
        [properties setValue:@"UICollectionView" forKey:TD_EVENT_PROPERTY_ELEMENT_TYPE];
        
        if (view.thinkingAnalyticsViewID.length > 0) {
            [properties setValue:view.thinkingAnalyticsViewID forKey:TD_EVENT_PROPERTY_ELEMENT_ID];
        }
        
        UIViewController *viewController = [view viewController];
        
        if (viewController == nil ||
            [viewController isKindOfClass:UINavigationController.class]) {
            viewController = [self currentViewController];
        }
        
        if (viewController != nil) {
            NSString *screenName = NSStringFromClass([viewController class]);
            [properties setValue:screenName forKey:TD_EVENT_PROPERTY_SCREEN_NAME];
            
            NSString *controllerTitle = [TDAutoTrackUtils titleFromViewController:viewController];
            if (controllerTitle) {
                [properties setValue:controllerTitle forKey:TD_EVENT_PROPERTY_TITLE];
            }
        }
        
        if (indexPath) {
            [properties setValue:[NSString stringWithFormat:@"%ld:%ld", (unsigned long)indexPath.section,(unsigned long)indexPath.row] forKey:TD_EVENT_PROPERTY_ELEMENT_POSITION];
        }
        
        UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
        NSString *elementContent = [TDAutoTrackUtils contentFromView:cell];
        if (elementContent.length > 0) {
            [properties setValue:elementContent forKey:TD_EVENT_PROPERTY_ELEMENT_CONTENT];
        }
        
        NSDictionary* propDict = view.thinkingAnalyticsViewProperties;
        if (propDict != nil) {
            [properties addEntriesFromDictionary:propDict];
        }
        
        NSDictionary *propertyWithAppid;
        @try {
            if ([collectionView.thinkingAnalyticsDelegate conformsToProtocol:@protocol(TDUIViewAutoTrackDelegate)]) {
                if ([collectionView.thinkingAnalyticsDelegate respondsToSelector:@selector(thinkingAnalytics_collectionView:autoTrackPropertiesAtIndexPath:)]) {
                    [properties addEntriesFromDictionary:[view.thinkingAnalyticsDelegate thinkingAnalytics_collectionView:collectionView autoTrackPropertiesAtIndexPath:indexPath]];
                }
                if ([collectionView.thinkingAnalyticsDelegate respondsToSelector:@selector(thinkingAnalyticsWithAppid_collectionView:autoTrackPropertiesAtIndexPath:)]) {
                    propertyWithAppid = [view.thinkingAnalyticsDelegate thinkingAnalyticsWithAppid_collectionView:collectionView autoTrackPropertiesAtIndexPath:indexPath];
                }
            }
        } @catch (NSException *exception) {
            TDLogError(@"%@ error: %@", self, exception);
        }
        
        NSDate *trackDate = [NSDate date];
        for (NSString *appid in instances) {
            NSMutableDictionary *trackProperties = [properties mutableCopy];
            ThinkingAnalyticsSDK *instance = [instances objectForKey:appid];
            if ([instance isViewTypeIgnored:[UICollectionView class]]) {
                continue;
            }
            
            NSDictionary* ignoreViews = view.thinkingAnalyticsIgnoreViewWithAppid;
            if (ignoreViews != nil && [ignoreViews objectForKey:appid]) {
                BOOL ignore = [[ignoreViews objectForKey:appid] boolValue];
                if(ignore)
                    continue;
            }
            
            if ([instance isViewControllerIgnored:viewController]) {
                continue;
            }
            
            NSDictionary* viewIDs = view.thinkingAnalyticsViewIDWithAppid;
            if (viewIDs != nil && [viewIDs objectForKey:appid]) {
                NSString *viewId = [viewIDs objectForKey:appid];
                [trackProperties setValue:viewId forKey:TD_EVENT_PROPERTY_ELEMENT_ID];
            }
            
            NSDictionary* viewProperties = view.thinkingAnalyticsViewPropertiesWithAppid;
            if (viewProperties != nil && [viewProperties objectForKey:appid]) {
                NSDictionary *properties = [viewProperties objectForKey:appid];
                [trackProperties addEntriesFromDictionary:properties];
            }
            
            if(propertyWithAppid) {
                NSDictionary *autoTrackproperties = [propertyWithAppid objectForKey:appid];
                if([self checkProperties:autoTrackproperties]) {
                    [trackProperties addEntriesFromDictionary:autoTrackproperties];
                }
            }
            
            if (![instance isAutoTrackEventTypeIgnored:ThinkingAnalyticsEventTypeAppClick]) {
                [instance autotrack:APP_CLICK_EVENT properties:trackProperties withTime:trackDate];
            }
        }
    } @catch (NSException *exception) {
        TDLogError(@"%@ error: %@", self, exception);
    }
}

+ (BOOL)isAutoTrackEventType:(ThinkingAnalyticsAutoTrackEventType)type {
    BOOL isIgnored = YES;
    for (NSString *appid in instances) {
        ThinkingAnalyticsSDK *instance = [instances objectForKey:appid];
        isIgnored = [instance isAutoTrackEventTypeIgnored:type];
        if(isIgnored == NO)
            break;
    }
    return !isIgnored;
}

- (void)viewControlWillAppear:(UIViewController *)controller {
    if ([ThinkingAnalyticsSDK isAutoTrackEventType:ThinkingAnalyticsEventTypeAppClick]) {
        void (^tableViewBlock)(id, SEL, id, id) = ^(id view, SEL command, UITableView *tableView, NSIndexPath *indexPath) {
            [self trackAppClickWithUITableView:tableView didSelectRowAtIndexPath:indexPath];
        };
        if ([controller respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
            [TDSwizzler swizzleSelector:@selector(tableView:didSelectRowAtIndexPath:) onClass:controller.class withBlock:tableViewBlock named:[NSString stringWithFormat:@"%@_%@", NSStringFromClass(self.class), @"UITableView_AutoTrack"]];
        }

        void (^collectionViewBlock)(id, SEL, id, id) = ^(id view, SEL command, UICollectionView *collectionView, NSIndexPath *indexPath) {
            [self trackAppClickWithUICollectionView:collectionView didSelectItemAtIndexPath:indexPath];
        };
        if ([controller respondsToSelector:@selector(collectionView:didSelectItemAtIndexPath:)]) {
            [TDSwizzler swizzleSelector:@selector(collectionView:didSelectItemAtIndexPath:) onClass:controller.class withBlock:collectionViewBlock named:[NSString stringWithFormat:@"%@_%@", NSStringFromClass(self.class), @"UICollectionView_AutoTrack"]];
        }
    }
    
    if (!([ThinkingAnalyticsSDK isAutoTrackEventType:ThinkingAnalyticsEventTypeAppViewScreen])) {
        return;
    }
    
    [self trackViewScreen:controller];
}

- (void)trackViewScreen:(UIViewController *)controller {
    if (!controller) {
        return;
    }
    
    Class klass = [controller class];
    if (!klass) {
        return;
    }
    
    if (![self shouldTrackViewContrller:klass]) {
        return;
    }

    NSMutableDictionary *properties = [[NSMutableDictionary alloc] init];
    [properties setValue:NSStringFromClass(klass) forKey:TD_EVENT_PROPERTY_SCREEN_NAME];

    @try {
        NSString *controllerTitle = [TDAutoTrackUtils titleFromViewController:controller];
        if (controllerTitle) {
            [properties setValue:controllerTitle forKey:TD_EVENT_PROPERTY_TITLE];
        }
    } @catch (NSException *exception) {
        TDLogError(@"%@ failed to get UIViewController's title error: %@", self, exception);
    }

    NSDictionary *autoTrackerAppidDic;
    if ([controller conformsToProtocol:@protocol(TDAutoTracker)]) {
        UIViewController<TDAutoTracker> *autoTrackerController = (UIViewController<TDAutoTracker> *)controller;
        NSDictionary *autoTrackerDic;
        if([controller respondsToSelector:@selector(getTrackPropertiesWithAppid)])
            autoTrackerAppidDic = [autoTrackerController getTrackPropertiesWithAppid];
        if([controller respondsToSelector:@selector(getTrackProperties)])
            autoTrackerDic = [autoTrackerController getTrackProperties];
        if(autoTrackerDic) {
            if (![self checkPropertyTypes:&autoTrackerDic withEventType:nil isCheckKey:YES]) {
                TDLogError(@"%@ property error.", autoTrackerDic);
                return;
            }
            [properties addEntriesFromDictionary:autoTrackerDic];
        }
    }

    NSDictionary *screenAutoTrackerAppidDic;
    if ([controller conformsToProtocol:@protocol(TDScreenAutoTracker)]) {
        UIViewController<TDScreenAutoTracker> *screenAutoTrackerController = (UIViewController<TDScreenAutoTracker> *)controller;
        if([screenAutoTrackerController respondsToSelector:@selector(getScreenUrlWithAppid)])
            screenAutoTrackerAppidDic = [screenAutoTrackerController getScreenUrlWithAppid];
        if([screenAutoTrackerController respondsToSelector:@selector(getScreenUrl)]) {
            [properties setValue:[screenAutoTrackerController getScreenUrl] forKey:TD_EVENT_PROPERTY_URL_PROPERTY];
        }
    }

    NSDate *trackDate = [NSDate date];
    for (NSString *appid in instances) {
        NSMutableDictionary *trackProperties = [properties mutableCopy];
        ThinkingAnalyticsSDK *instance = [instances objectForKey:appid];
        if (![instance isAutoTrackEventTypeIgnored:ThinkingAnalyticsEventTypeAppViewScreen]) {
            if([instance isViewControllerIgnored:controller]) {
                continue;
            }
            
            if ([instance isViewTypeIgnored:[controller class]]) {
                continue;
            }
            
            if(autoTrackerAppidDic && [autoTrackerAppidDic objectForKey:appid]) {
                NSDictionary *dic = [autoTrackerAppidDic objectForKey:appid];
                if (![self checkPropertyTypes:&dic withEventType:nil isCheckKey:YES]) {
                    TDLogError(@"%@ property error.", dic);
                    return;
                }
                [trackProperties addEntriesFromDictionary:dic];
            }
            if(screenAutoTrackerAppidDic && [screenAutoTrackerAppidDic objectForKey:appid]) {
                NSString *screenUrl = [screenAutoTrackerAppidDic objectForKey:appid];
                [trackProperties setValue:screenUrl forKey:TD_EVENT_PROPERTY_URL_PROPERTY];
            }
            [instance autotrack:APP_VIEW_SCREEN_EVENT properties:trackProperties withTime:trackDate];
        }
    }
}

- (void)ignoreAutoTrackViewControllers:(NSArray *)controllers {
    if (controllers == nil || controllers.count == 0) {
        return;
    }
    
    dispatch_async(serialQueue, ^{
        [self->_ignoredViewControllers addObjectsFromArray:controllers];
    });
}

- (UIViewController *)currentViewController {
    __block UIViewController *currentVC = nil;
    void (^ block)(void) = ^{
        UIViewController *rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
        currentVC = [self getCurrentVCFrom:rootViewController isRoot:YES];
    };

    if (dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL) == dispatch_queue_get_label(dispatch_get_main_queue())) {
        block();
    } else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
    
    return currentVC;
}

- (UIViewController *)getCurrentVCFrom:(UIViewController *)rootVC isRoot:(BOOL)isRoot{
    UIViewController *currentVC;
    if ([rootVC presentedViewController]) {
        rootVC = [self getCurrentVCFrom:rootVC.presentedViewController isRoot:NO];
    }
    
    if ([rootVC isKindOfClass:[UITabBarController class]]) {
        currentVC = [self getCurrentVCFrom:[(UITabBarController *)rootVC selectedViewController] isRoot:NO];
    } else if ([rootVC isKindOfClass:[UINavigationController class]]){
        currentVC = [self getCurrentVCFrom:[(UINavigationController *)rootVC visibleViewController] isRoot:NO];
    } else {
        if ([rootVC respondsToSelector:NSSelectorFromString(@"contentViewController")]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            UIViewController *tempViewController = [rootVC performSelector:NSSelectorFromString(@"contentViewController")];
#pragma clang diagnostic pop
            if (tempViewController) {
                currentVC = [self getCurrentVCFrom:tempViewController isRoot:NO];
            }
        } else if (rootVC.childViewControllers.count == 1 && isRoot) {
            currentVC = [self getCurrentVCFrom:rootVC.childViewControllers.firstObject isRoot:NO];
        } else {
            currentVC = rootVC;
        }
    }
    return currentVC;
}

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
    
    if([urlStr rangeOfString:TA_JS_TRACK_SCHEME].length > 0) {
        if(queryKey.length == 0 || queryValue.length == 0)
            return YES;
        if ([webView isKindOfClass:[UIWebView class]] || (wkWebViewClass && [webView isKindOfClass:wkWebViewClass])) {
            NSString* uploadData = [queryValue stringByRemovingPercentEncoding];
            if(uploadData.length > 0)
                [self clickFromH5:uploadData];
        }
    }
    return YES;
}

- (NSString *)getUserAgent {
    __block NSString *currentUA = _userAgent;
    if (currentUA  == nil)  {
        if ([[NSThread currentThread] isMainThread]) {
            UIWebView* webView = [[UIWebView alloc] initWithFrame:CGRectZero];
            currentUA = [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
            _userAgent = currentUA;
        } else {
            dispatch_sync(dispatch_get_main_queue(), ^{
                UIWebView* webView = [[UIWebView alloc] initWithFrame:CGRectZero];
                currentUA = [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
                self->_userAgent = currentUA;
            });
        }
    }
    return currentUA;
}

- (void)addWebViewUserAgent {
    NSString *userAgent = [self getUserAgent];
    if ([userAgent rangeOfString:@"td-sdk-ios"].location == NSNotFound) {
        userAgent = [userAgent stringByAppendingString:@" /td-sdk-ios"];
    }
    _userAgent = userAgent;
    
    NSDictionary *dictionnary = [[NSDictionary alloc] initWithObjectsAndKeys:userAgent, @"UserAgent", nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:dictionnary];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)setLogLevel:(TDLoggingLevel)level
{
    [TDLogging sharedInstance].loggingLevel = level;
}

-(void)trackCrash {
    [[ThinkingExceptionHandler sharedHandler] addThinkingInstance:self];
}

@end

@implementation UIView (ThinkingAnalytics)

- (UIViewController *)viewController {
    UIResponder *next = self.nextResponder;
    do {
        if ([next isKindOfClass:UIViewController.class]) {
            UIViewController *vc = (UIViewController *)next;
            if ([vc isKindOfClass:UINavigationController.class]) {
                next = [(UINavigationController *)vc topViewController];
                break;
            } else if([vc isKindOfClass:UITabBarController.class]) {
                next = [(UITabBarController *)vc selectedViewController];
                break;
            }
            UIViewController *parentVC = vc.parentViewController;
            if (parentVC) {
                if ([parentVC isKindOfClass:UINavigationController.class]||
                    [parentVC isKindOfClass:UITabBarController.class]||
                    [parentVC isKindOfClass:UIPageViewController.class]||
                    [parentVC isKindOfClass:UISplitViewController.class]) {
                    break;
                }
            } else {
                break;
            }
        }
    } while ((next = next.nextResponder));
    return [next isKindOfClass:UIViewController.class] ? (UIViewController *)next : nil;
}

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
