#import "ThinkingAnalyticsSDK.h"
#import "ThinkingAnalyticsSDKPrivate.h"
#import "TDSqliteDataQueue.h"
#include <sys/sysctl.h>

#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

#import "TDSDKReachabilityManager.h"
#import "NSData+TDGzip.h"
#import <sys/utsname.h>

#import "TDKeychainItemWrapper.h"
#import <objc/runtime.h>
#import "TDAutoTrackUtils.h"
#import "TDSwizzler.h"
#import "UIViewController+AutoTrack.h"
#import "NSObject+TDSwizzle.h"

#define VERSION @"1.1.0"

static NSString * const APP_START_EVENT = @"ta_app_start";
static NSString * const APP_END_EVENT = @"ta_app_end";
static NSString * const APP_VIEW_SCREEN_EVENT = @"ta_app_view";
static NSString * const RESUME_FROM_BACKGROUND_PROPERTY = @"#resume_from_background";
static NSString * const SCREEN_NAME_PROPERTY = @"#screen_name";
static NSString * const SCREEN_URL_PROPERTY = @"#url";
static NSString * const SCREEN_REFERRER_URL_PROPERTY = @"#referrer";

static NSString * const TA_JS_TRACK_SCHEME = @"thinkinganalytics://trackEvent";
static const NSUInteger kBatchSize = 50;

static ThinkingAnalyticsSDK *sharedInstance = nil;

@interface ThinkingAnalyticsSDK()<NSURLSessionDelegate>
{
}

@property (atomic, copy) NSString *appid;
@property (atomic, copy) NSString *serverURL;
@property (atomic, copy) NSString *configureURL;
@property (atomic, copy) NSString *accountId;
@property (atomic, copy) NSString *uniqueId;
@property (atomic, copy) NSString *deviceId;
@property (atomic, copy) NSString *identifyId;

@property (atomic, strong) NSDictionary *systemProperties;
@property (atomic, strong) NSDictionary *automaticData;
@property (nonatomic, strong) NSMutableDictionary *trackTimer;

@property (nonatomic) dispatch_queue_t serialQueue;
@property (nonatomic) dispatch_queue_t networkQueue;
@property (nonatomic, strong) NSPredicate *regexKey;

@property (atomic, strong) TDSqliteDataQueue *dataQueue;
@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong) NSMutableArray *ignoredViewControllers;
@property (nonatomic, strong) NSMutableArray *ignoredViewTypeList;

@property (nonatomic, assign) UIBackgroundTaskIdentifier taskId;
@property (nonatomic, strong) CTTelephonyNetworkInfo *telephonyInfo;

@property (atomic) BOOL isUploading;

@end

typedef NS_OPTIONS(NSInteger, ThinkingNetworkType) {
    ThinkingNetworkTypeNONE     = 0,
    ThinkingNetworkType2G       = 1 << 0,
    ThinkingNetworkType3G       = 1 << 1,
    ThinkingNetworkType4G       = 1 << 2,
    ThinkingNetworkTypeWIFI     = 1 << 3,
    ThinkingNetworkTypeALL      = 0xFF,
};

@implementation ThinkingAnalyticsSDK{
    NSDateFormatter *_timeFormatter;
    NSInteger _uploadInterval;
    NSInteger _uploadSize;
    ThinkingNetworkType _networkType;
    ThinkingAnalyticsAutoTrackEventType _autoTrackEventType;
    BOOL _applicationWillResignActive;
    BOOL _appRelaunched;
    NSString *_referrerScreenUrl;
    NSDictionary *_lastScreenTrackProperties;
    NSString *_userAgent;
}

+ (ThinkingAnalyticsSDK *)startWithAppId:(NSString *)appId withUrl:(NSString *)url {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] initWithAppkey:appId
                                          withChannel:nil
                                        withServerURL:[NSString stringWithFormat:@"%@/sync",url]
                                      andConfigureURL:[NSString stringWithFormat:@"%@/config",url]];
    });
    return sharedInstance;
}

+ (ThinkingAnalyticsSDK *)sharedInstance {
    return sharedInstance;
}

- (instancetype)initWithAppkey:(NSString *)appid
                   withChannel:(NSString *)channel
                 withServerURL:(NSString *)serverURL
               andConfigureURL:(NSString *)configureURL {
    TDLogInfo(@"Thank you very much for using Thinking Data SDK. We will do our best to provide you with the best service.");
    TDLogInfo(@"Thinking Data SDK version:%@",VERSION);
    
    if (self = [self init]) {
        _networkType = ThinkingNetworkType3G | ThinkingNetworkType4G | ThinkingNetworkTypeWIFI;
        _autoTrackEventType = ThinkingAnalyticsEventTypeNone;
        
        self.serverURL = serverURL;
        self.configureURL = configureURL;
        self.appid = appid;
        self.isUploading = NO;
        
        self.trackTimer = [NSMutableDictionary dictionary];
        _timeFormatter = [[NSDateFormatter alloc]init];
        _timeFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
        NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US@calendar=NSGregorianCalendar"];
        [_timeFormatter setLocale:locale];

        _applicationWillResignActive = NO;
        _referrerScreenUrl = nil;
        _ignoredViewControllers = [[NSMutableArray alloc] init];
        _ignoredViewTypeList = [[NSMutableArray alloc] init];
        _lastScreenTrackProperties = nil;
        
        self.taskId = UIBackgroundTaskInvalid;
        self.telephonyInfo = [[CTTelephonyNetworkInfo alloc] init];
        
        NSString *keyPattern = @"^[a-zA-Z][a-zA-Z\\d_#]{0,49}$";
        self.regexKey = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", keyPattern];
        
        self.dataQueue = [[TDSqliteDataQueue alloc] initWithPath:[self pathForName:@"data"]];
        if (self.dataQueue == nil) {
            TDLogError(@"SqliteException: init SqliteDataQueue failed");
        }
        
        [self getConfig];
        [self updateConfig];
        [self setUpListeners];
        
        self.automaticData = [self getAutomaticData];
        NSString *queuelabel = [NSString stringWithFormat:@"com.Thinkingdata.%p", (void *)self];
        self.serialQueue = dispatch_queue_create([queuelabel UTF8String], DISPATCH_QUEUE_SERIAL);
        NSString *networkLabel = [queuelabel stringByAppendingString:@".network"];
        self.networkQueue = dispatch_queue_create([networkLabel UTF8String], DISPATCH_QUEUE_SERIAL);
    }
    
    TDLogInfo(@"init ThinkingAnalytics SDK with appid: '%@' ", _appid);
    return self;
}

-(void)getConfig {
    [self getSysPro];
    [self getLoginId];
    [self getIdentifyId];
    [self getBatchSizeAndInterval];
}

- (NSString *)getIdentifier {
    NSString *anonymityId = NULL;
    
    if (NSClassFromString(@"UIDevice")) {
        anonymityId = [[UIDevice currentDevice].identifierForVendor UUIDString];
    }
    
    if (!anonymityId) {
        anonymityId = [[NSUUID UUID] UUIDString];
    }
    
    return anonymityId;
}

-(void)updateConfig
{
    void (^block)(NSData*, NSURLResponse*, NSError*) = ^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error || ![response isKindOfClass:[NSHTTPURLResponse class]]) {
            return;
        }

        NSDictionary *ret = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        if ([ret isKindOfClass:[NSDictionary class]] && [[[ret copy] objectForKey:@"code"] isEqual:[NSNumber numberWithInt:0]])
        {
            NSDictionary *dic = [[ret copy] objectForKey:@"data"];
            NSInteger sync_interval = [[[dic copy] objectForKey:@"sync_interval"] unsignedIntegerValue];
            NSInteger sync_batch_size = [[[dic copy] objectForKey:@"sync_batch_size"] unsignedIntegerValue];
            if (sync_interval != self.uploadInterval && sync_interval > 0) {
                self.uploadInterval = sync_interval;
                [[NSUserDefaults standardUserDefaults]setInteger:sync_interval forKey:@"thinkingdata_uploadInterval"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            if (sync_batch_size != self.uploadSize && sync_batch_size > 0) {
                self.uploadSize = sync_batch_size;
                [[NSUserDefaults standardUserDefaults]setInteger:sync_batch_size forKey:@"thinkingdata_uploadSize"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            TDLogDebug(@"uploadBatchSize:%d Interval:%d", sync_batch_size, sync_interval);
        }
        else if( [[[ret copy] objectForKey:@"code"] isEqual:[NSNumber numberWithInt:-2]]) {
            TDLogError(@"APPID is wrong");
        }
        else {
            TDLogError(@"updateBatchSizeAndInterval failed");
        }
    };
    
    NSString *urlStr = [NSString stringWithFormat:@"%@?appid=%@",self.configureURL,self.appid];
    NSURL *URL = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    [request setHTTPMethod:@"Get"];
    NSURLSession * session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:block];
    [task resume];
}

- (void)setNetworkType:(ThinkingAnalyticsNetworkType)type
{
    if (type == TDNetworkTypeDefault) {
        _networkType = ThinkingNetworkTypeWIFI | ThinkingNetworkType3G | ThinkingNetworkType4G;
    } else if (type == TDNetworkTypeOnlyWIFI) {
        _networkType = ThinkingNetworkTypeWIFI;
    } else if (type == TDNetworkTypeALL) {
        _networkType = ThinkingNetworkTypeWIFI | ThinkingNetworkType3G | ThinkingNetworkType4G | ThinkingNetworkType2G;
    }
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
    dispatch_async(self.serialQueue, ^{
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
    dispatch_async(self.serialQueue, ^{
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
        [self autotrack:APP_END_EVENT properties:nil];
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
    
    dispatch_async(self.serialQueue, ^{
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
                                                         }];
        }
        if (_autoTrackEventType & ThinkingAnalyticsEventTypeAppEnd) {
            [self timeEvent:APP_END_EVENT];
        }
    }
    
}

-(void)getBatchSizeAndInterval
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger interval = [userDefaults integerForKey:@"thinkingdata_uploadInterval"];
    if (interval <= 0) {
        self.uploadInterval = 60;
        [userDefaults setInteger:60 forKey:@"thinkingdata_uploadInterval"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        self.uploadInterval = interval;
    }
    NSInteger size = [userDefaults integerForKey:@"thinkingdata_uploadSize"];
    if (size <= 0) {
        self.uploadSize = 100;
        [userDefaults setInteger:100 forKey:@"thinkingdata_uploadSize"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        self.uploadSize = size;
    }
}

- (NSString *)deviceModel {
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char answer[size];
    sysctlbyname("hw.machine", answer, &size, NULL, 0);
    NSString *results = nil;
    if (size) {
        results = @(answer);
    } else {
        TDLogError(@"Failed fetch hw.machine from sysctl.");
    }
    return results;
}

- (NSString *)getlibVersion {
    return VERSION;
}

- (NSString *)getDistinctId{
    if(_identifyId.length == 0)
        return _uniqueId;
    else
        return _identifyId;
}

- (NSString *)getDeviceId {
    return _deviceId;
}

- (void)getDeviceUniqueId {
    NSString *defaultDistinctId = [self getIdentifier];
    NSString *deviceId;
    NSString *uniqueId;
    
    TDKeychainItemWrapper *wrapper = [[TDKeychainItemWrapper alloc] init];
    NSString *deviceIdKeychain = [wrapper readDeviceId];
    NSString *installTimesKeychain = [wrapper readInstallTimes];
    BOOL isNotfirst = [[[NSUserDefaults standardUserDefaults] objectForKey:@"thinking_isfirst"] boolValue];
    
    if(deviceIdKeychain.length == 0 || installTimesKeychain.length == 0)
    {
        [wrapper readOldKeychain];
        deviceIdKeychain = [wrapper getDeviceIdOld];
        installTimesKeychain = [wrapper getInstallTimesOld];
    }
    
    //新客户
    if(deviceIdKeychain.length == 0 || installTimesKeychain.length == 0) {
        deviceId = defaultDistinctId;
        uniqueId = defaultDistinctId;
        
        installTimesKeychain = @"1";
        [wrapper saveInstallTimes:[NSString stringWithFormat:@"1"]];
        [wrapper saveDeviceId:deviceId];
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"thinking_isfirst"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        if(!isNotfirst) {
            int setup_int = [installTimesKeychain intValue];
            setup_int++;
            
            installTimesKeychain = [NSString stringWithFormat:@"%d",setup_int];
            
            deviceId = deviceIdKeychain;
            uniqueId = [NSString stringWithFormat:@"%@_%d",deviceIdKeychain,setup_int];
            
            [wrapper saveInstallTimes:[NSString stringWithFormat:@"%d",setup_int]];
            
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"thinking_isfirst"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        } else {
            deviceId = deviceIdKeychain;
            uniqueId = [NSString stringWithFormat:@"%@_%@",deviceIdKeychain,installTimesKeychain];
        }
    }
    
    [wrapper saveDeviceId:deviceId];
    [wrapper saveInstallTimes:installTimesKeychain];
    
    self.uniqueId = [uniqueId copy];
    self.deviceId = [deviceId copy];
}

- (NSDictionary *)getAutomaticData {
    NSMutableDictionary *p = [NSMutableDictionary dictionary];
    UIDevice *device = [UIDevice currentDevice];
    [p setValue:[[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"] forKey:@"#app_version"];
    
    [self getDeviceUniqueId];
    [p setValue:self.deviceId forKey:@"#device_id"];
    CTCarrier *carrier = [_telephonyInfo subscriberCellularProvider];
    [p setValue:carrier.carrierName forKey:@"#carrier"];
    CGSize size = [UIScreen mainScreen].bounds.size;
    [p addEntriesFromDictionary:@{
                                  @"#lib": @"iOS",
                                  @"#lib_version": [self getlibVersion],
                                  @"#manufacturer": @"Apple",
                                  @"#device_model": [self iphoneType],
                                  @"#os": [device systemName],
                                  @"#os_version": [device systemVersion],
                                  @"#screen_height": @((NSInteger)size.height),
                                  @"#screen_width": @((NSInteger)size.width)
                                  }];
    return [p copy];
}

//TODO
- (NSString *)iphoneType {
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *platform = [NSString stringWithCString:systemInfo.machine encoding:NSASCIIStringEncoding];
    if ([platform isEqualToString:@"iPhone1,1"]) return @"iPhone 2G";
    if ([platform isEqualToString:@"iPhone1,2"]) return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"]) return @"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"]) return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,2"]) return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,3"]) return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone4,1"]) return @"iPhone 4S";
    if ([platform isEqualToString:@"iPhone5,1"]) return @"iPhone 5";
    if ([platform isEqualToString:@"iPhone5,2"]) return @"iPhone 5";
    if ([platform isEqualToString:@"iPhone5,3"]) return @"iPhone 5c";
    if ([platform isEqualToString:@"iPhone5,4"]) return @"iPhone 5c";
    if ([platform isEqualToString:@"iPhone6,1"]) return @"iPhone 5s";
    if ([platform isEqualToString:@"iPhone6,2"]) return @"iPhone 5s";
    if ([platform isEqualToString:@"iPhone7,1"]) return @"iPhone 6 Plus";
    if ([platform isEqualToString:@"iPhone7,2"]) return @"iPhone 6";
    if ([platform isEqualToString:@"iPhone8,1"]) return @"iPhone 6s";
    if ([platform isEqualToString:@"iPhone8,2"]) return @"iPhone 6s Plus";
    if ([platform isEqualToString:@"iPhone8,4"]) return @"iPhone SE";
    if ([platform isEqualToString:@"iPhone9,1"]) return @"iPhone 7";
    if ([platform isEqualToString:@"iPhone9,2"]) return @"iPhone 7 Plus";
    if ([platform isEqualToString:@"iPod1,1"])   return @"iPod Touch 1G";
    if ([platform isEqualToString:@"iPod2,1"])   return @"iPod Touch 2G";
    if ([platform isEqualToString:@"iPod3,1"])   return @"iPod Touch 3G";
    if ([platform isEqualToString:@"iPod4,1"])   return @"iPod Touch 4G";
    if ([platform isEqualToString:@"iPod5,1"])   return @"iPod Touch 5G";
    if ([platform isEqualToString:@"iPad1,1"])   return @"iPad 1G";
    if ([platform isEqualToString:@"iPad2,1"])   return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,2"])   return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,3"])   return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,4"])   return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,5"])   return @"iPad Mini 1G";
    if ([platform isEqualToString:@"iPad2,6"])   return @"iPad Mini 1G";
    if ([platform isEqualToString:@"iPad2,7"])   return @"iPad Mini 1G";
    if ([platform isEqualToString:@"iPad3,1"])   return @"iPad 3";
    if ([platform isEqualToString:@"iPad3,2"])   return @"iPad 3";
    if ([platform isEqualToString:@"iPad3,3"])   return @"iPad 3";
    if ([platform isEqualToString:@"iPad3,4"])   return @"iPad 4";
    if ([platform isEqualToString:@"iPad3,5"])   return @"iPad 4";
    if ([platform isEqualToString:@"iPad3,6"])   return @"iPad 4";
    if ([platform isEqualToString:@"iPad4,1"])   return @"iPad Air";
    if ([platform isEqualToString:@"iPad4,2"])   return @"iPad Air";
    if ([platform isEqualToString:@"iPad4,3"])   return @"iPad Air";
    if ([platform isEqualToString:@"iPad4,4"])   return @"iPad Mini 2G";
    if ([platform isEqualToString:@"iPad4,5"])   return @"iPad Mini 2G";
    if ([platform isEqualToString:@"iPad4,6"])   return @"iPad Mini 2G";
    if ([platform isEqualToString:@"i386"])      return @"iPhone Simulator";
    if ([platform isEqualToString:@"x86_64"])    return @"iPhone Simulator";
    return platform;
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

- (void)saveIdentifyId {
    [[NSUserDefaults standardUserDefaults] setObject:[_identifyId copy] forKey:@"thinkingdata_identifyId"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)getIdentifyId {
    @synchronized (_identifyId) {
        self.identifyId = [[NSUserDefaults standardUserDefaults] objectForKey:@"thinkingdata_identifyId"];
    }
}

- (void)saveLoginId {
    [[NSUserDefaults standardUserDefaults] setObject:[self.accountId copy] forKey:@"thinkingdata_accountId"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)getLoginId {
    @synchronized (_accountId) {
        self.accountId = [[NSUserDefaults standardUserDefaults] objectForKey:@"thinkingdata_accountId"];
    }
}

- (void)saveSysPro {
    [[NSUserDefaults standardUserDefaults] setObject:[self.systemProperties copy] forKey:@"thinkingdata_systemProperties"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)getSysPro {
    self.systemProperties = [[NSUserDefaults standardUserDefaults] objectForKey:@"thinkingdata_systemProperties"];
    if (self.systemProperties == nil) {
        self.systemProperties = [NSDictionary dictionary];
    }
}

- (void)setSuperProperties:(NSDictionary *)properties {
    properties = [properties copy];
    if (properties == nil)
    {
        return;
    }
    
    if (![self checkPropertyTypes:[properties copy] withEventType:nil]) {
        TDLogError(@"%@ propertieDict error.", properties);
        return;
    }
    
    dispatch_async(self.serialQueue, ^{
        NSMutableDictionary *tmp = [NSMutableDictionary dictionaryWithDictionary:self.systemProperties];
        [tmp addEntriesFromDictionary:[properties copy]];
        self.systemProperties = [NSDictionary dictionaryWithDictionary:tmp];
        [self saveSysPro];
    });
}

- (void)unsetSuperProperty:(NSString *)property {
    if(property.length == 0)
        return;
    
    dispatch_async(self.serialQueue, ^{
        NSMutableDictionary *tmp = [NSMutableDictionary dictionaryWithDictionary:self.systemProperties];
        tmp[property] = nil;
        self.systemProperties = [NSDictionary dictionaryWithDictionary:tmp];
        [self saveSysPro];
    });
}

- (void)clearSuperProperties {
    dispatch_async(self.serialQueue, ^{
        self.systemProperties = @{};
        [self saveSysPro];
    });
}

- (NSDictionary *)currentSuperProperties {
    return [_systemProperties copy];
}

- (void)identify:(NSString *)distinctId {
    if (distinctId.length == 0) {
        TDLogError(@"identify cannot null");
        return;
    }
    
    dispatch_async(self.serialQueue, ^{
        @synchronized (self.identifyId) {
            if(self.identifyId != distinctId) {
                self.identifyId = distinctId;
                [self saveIdentifyId];
            }
        }
    });
}

- (void)login:(NSString *)accountId {
    if (accountId.length == 0) {
        TDLogError(@"accountId cannot null", accountId);
        return;
    }
    
    if (![accountId isEqualToString:[self accountId]]) {
        self.accountId = accountId;
        [self saveLoginId];
    }
}

- (void)logout {
    self.accountId = nil;
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
    dispatch_async(self.serialQueue, ^{
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
       properties:(NSDictionary *)propertieDict {
    [self click:event withProperties:propertieDict withType:@"track" withTime:nil isCheckProperties:NO];
}

- (BOOL)isValidName:(NSString *) name {
    @try {
        return [self.regexKey evaluateWithObject:name];
    } @catch (NSException *exception) {
        TDLogError(@"%@: %@", self, exception);
        return NO;
    }
}

- (BOOL)checkProperties:(NSDictionary*)dic {
    return [self checkPropertyTypes:dic withEventType:nil];
}

- (BOOL)checkPropertyTypes:(NSDictionary *)properties withEventType:(NSString *)eventType {
    for (id k in properties) {
        if (![k isKindOfClass: [NSString class]]) {
            NSString *errMsg = @"property Key should by NSString";
            TDLogError(errMsg);
            return NO;
        }
        
        if (![self isValidName: k]) {
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
        
        if ([properties[k] isKindOfClass:[NSString class]]) {
            NSUInteger objLength = [((NSString *)properties[k]) lengthOfBytesUsingEncoding:NSUnicodeStringEncoding];
            if (objLength > 5000) {
                NSString * errMsg = [NSString stringWithFormat:@"The value is too long: %@", (NSString *)properties[k]];
                TDLogError(errMsg);
                return NO;
            }
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
    if ([dataArr isKindOfClass:[NSArray class]])
    {
        NSDictionary *dataInfo = [dataArr objectAtIndex:0];
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
        
        NSDate *destDate= [_timeFormatter dateFromString:time];
        [self click:event_name withProperties:dic withType:type withTime:destDate isCheckProperties:NO];
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
    propertieDict = [propertieDict copy];
    if([type isEqualToString:@"track"]) {
        if (event.length == 0 || ![event isKindOfClass:[NSString class]]) {
            TDLogError(@"track event key is not valid");
            return;
        }
        
        if (![self isValidName: event]) {
            NSString *errMsg = [NSString stringWithFormat:@"property name[%@] is not valid", event];
            TDLogError(@"%@", errMsg);
            return;
        }
    }
     
    if (propertieDict && check) {
        if (![self checkPropertyTypes:[propertieDict copy] withEventType:type]) {
            TDLogError(@"%@ property error.", propertieDict);
            return;
        }
    }
    
    dispatch_async(self.serialQueue, ^{
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
        if(self.identifyId.length == 0 && self.uniqueId > 0) {
            distinct = self.uniqueId;
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
        
        [self saveClickData:type andEvent:dataDic];
        TDLogDebug(@"queueing data:%@", dataDic);
    });
    
    if ([[self dataQueue] count] >= self.uploadSize && !self.isUploading) {
        [self sync];
    }
}

- (void)sync
{
    [self syncWithCompletion:nil];
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
    dispatch_async(self.serialQueue, ^{
        dispatch_async(self.networkQueue, dispatchBlock);
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

- (void)_sync:(BOOL) vacuumAfterFlushing {
    NSString *networkType = [self getNetWorkStates];
    if (!([self convertNetworkType:networkType] & _networkType)) {
        return;
    }
    
    NSArray *recordArray;
    @synchronized (self) {
        recordArray = [self.dataQueue getFirstRecords:kBatchSize];
    }
    
    __block BOOL flushSucc = YES;
    while (recordArray.count > 0 && flushSucc) {
        self.isUploading = YES;
        NSUInteger batchSize = MIN(recordArray.count, kBatchSize);
        
        NSString *postBody;
        NSString *jsonString;
        @try {
            NSMutableArray *dataArr = [NSMutableArray array];
            for (int i = 0; i < recordArray.count; i++) {
                NSData *jsonData = [recordArray[i] dataUsingEncoding:NSUTF8StringEncoding];
                NSError *err;
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                    options:NSJSONReadingMutableContainers
                                                                      error:&err];
                [dataArr addObject:dic];
            }
            
            NSDictionary *e = @{
                                @"data": dataArr,
                                @"automaticData":_automaticData,
                                @"#app_id": _appid,
                                };
            
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:e options:(NSJSONWritingOptions)0 error:nil];
            jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            
            NSData *zippedData = [NSData gzipData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
            postBody = [zippedData base64EncodedStringWithOptions:0];
        } @catch (NSException *exception) {
            return ;
        }
        
        NSURL *URL = [NSURL URLWithString:self.serverURL];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:[postBody dataUsingEncoding:NSUTF8StringEncoding]];
        NSString *contentType = [NSString stringWithFormat:@"text/plain"];
        [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
        [request setTimeoutInterval:60.0];
        
        dispatch_semaphore_t flushSem = dispatch_semaphore_create(0);
        
        void (^block)(NSData*, NSURLResponse*, NSError*) = ^(NSData *data, NSURLResponse *response, NSError *error) {
            if (error || ![response isKindOfClass:[NSHTTPURLResponse class]]) {
                flushSucc = NO;
                TDLogError(@"Networking error");
                dispatch_semaphore_signal(flushSem);
                return;
            }
            
            NSHTTPURLResponse *urlResponse = (NSHTTPURLResponse*)response;
            if([urlResponse statusCode] != 200) {
                flushSucc = NO;
                NSString *urlResponseContent = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSString *errMsg = [NSString stringWithFormat:@"%@ network failure with response '%@'.", self, urlResponseContent];
                TDLogError(@"%@", errMsg);
            } else {
                NSDictionary *ret = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                if([ret isKindOfClass:[NSDictionary class]] && [[[ret copy] objectForKey:@"code"] isEqual:[NSNumber numberWithInt:0]])
                {
                    flushSucc = YES;
                    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
                    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
                    NSString *logingStr=[[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
                    TDLogDebug(@"fluch success :%@", logingStr);
                }
            }
            
            dispatch_semaphore_signal(flushSem);
        };
        
        NSURLSession * session = [NSURLSession sharedSession];
        NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:block];
        [task resume];
        
        dispatch_semaphore_wait(flushSem, DISPATCH_TIME_FOREVER);
        
        if(flushSucc) {
            @synchronized (self) {
                [self.dataQueue removeFirstRecords:batchSize];
            }
        }
    
        @synchronized (self) {
            recordArray = [self.dataQueue getFirstRecords:kBatchSize];
        }
    }
    self.isUploading = NO;
}

- (void)saveClickData:(NSString *)type andEvent:(NSDictionary *)e {
    NSMutableDictionary *event = [[NSMutableDictionary alloc] initWithDictionary:e];
    @synchronized (self) {
        [self.dataQueue addObejct:event];
    }
}

- (NSString *)pathForName:(NSString *)data {
    NSString *filename = [NSString stringWithFormat:@"TDData-%@.plist", data];
    NSString *filepath = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:filename];
    return filepath;
}

- (NSInteger)uploadSize {
    return _uploadSize;
}

- (void)setUploadSize:(NSInteger)bulkSize {
    @synchronized (self) {
        _uploadSize = bulkSize;
    }
}

-(NSInteger)uploadInterval{
    return _uploadInterval;
}

- (void)setUploadInterval:(NSInteger)uploadInterval
{
    @synchronized (self) {
        _uploadInterval = uploadInterval;
    }
    [self startFlushTimer];
}

- (void)startFlushTimer
{
    [self stopFlushTimer];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.uploadInterval > 0) {
            self.timer = [NSTimer scheduledTimerWithTimeInterval:self.uploadInterval
                                                          target:self
                                                        selector:@selector(sync)
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

    if (_autoTrackEventType & ThinkingAnalyticsEventTypeAppStart) {
        [self autotrack:APP_START_EVENT properties:@{
                                                     RESUME_FROM_BACKGROUND_PROPERTY : @(_appRelaunched)
                                                     }];
    }
    if (_autoTrackEventType & ThinkingAnalyticsEventTypeAppEnd) {
        [self timeEvent:APP_END_EVENT];
    }
    [self _enableAutoTrack];
}

- (void)viewControlWillDisappear:(UIViewController*)controller {
    if (_autoTrackEventType & ThinkingAnalyticsEventTypeAppClick) {
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
    if (_autoTrackEventType & ThinkingAnalyticsEventTypeAppViewScreen ||
        _autoTrackEventType & ThinkingAnalyticsEventTypeAppClick) {
        [UIViewController td_swizzleMethod:@selector(viewWillAppear:)
                                withMethod:@selector(td_autotrack_viewWillAppear:)
                                     error:NULL];
    }

    if (_autoTrackEventType & ThinkingAnalyticsEventTypeAppClick) {
        [UIViewController td_swizzleMethod:@selector(viewWillDisappear:)
                                withMethod:@selector(td_autotrack_viewWillDisappear:)
                                     error:NULL];
    }
}

- (BOOL)isAutoTrackEventTypeIgnored:(ThinkingAnalyticsAutoTrackEventType)eventType {
    return !(_autoTrackEventType & eventType);
}

- (void)ignoreViewType:(Class)aClass {
    [_ignoredViewTypeList addObject:aClass];
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

- (BOOL)isViewControllerStringIgnored:(NSString *)viewControllerString {
    if (viewControllerString == nil) {
        return false;
    }
    
    if (_ignoredViewControllers != nil && _ignoredViewControllers.count > 0) {
        if ([_ignoredViewControllers containsObject:viewControllerString]) {
            return true;
        }
    }
    return false;
}

- (void)ignoreAutoTrackEventType:(ThinkingAnalyticsAutoTrackEventType)eventType {
    _autoTrackEventType = _autoTrackEventType ^ eventType;
}

- (void)trackViewAppClick:(UIView *)view {
    [self trackViewAppClick:view withProperties:nil];
}

- (void)trackViewAppClick:(UIView *)view withProperties:(NSDictionary *)property {
    @try {
        if (view == nil) {
            return;
        }
        
        if ([self isAutoTrackEventTypeIgnored:ThinkingAnalyticsEventTypeAppClick]) {
            return;
        }
        
        if ([self isViewTypeIgnored:[view class]]) {
            return;
        }

        if (view.thinkingAnalyticsIgnoreView) {
            return;
        }

        NSMutableDictionary *properties = [[NSMutableDictionary alloc] init];

        UIViewController *viewController = [self currentViewController];
        if (viewController != nil) {
            if ([[ThinkingAnalyticsSDK sharedInstance] isViewControllerIgnored:viewController]) {
                return;
            }

            NSString *screenName = NSStringFromClass([viewController class]);
            [properties setValue:screenName forKey:@"#screen_name"];

            NSString *controllerTitle = viewController.navigationItem.title;
            if (controllerTitle.length > 0) {
                [properties setValue:viewController.navigationItem.title forKey:@"#title"];
            }

            NSString *elementContent = [self getUIViewControllerTitle:viewController];
            if (elementContent.length > 0) {
                elementContent = [elementContent substringWithRange:NSMakeRange(0,[elementContent length] - 1)];
                [properties setValue:elementContent forKey:@"#title"];
            }
        }

        if (view.thinkingAnalyticsViewID.length > 0) {
            [properties setValue:view.thinkingAnalyticsViewID forKey:@"#element_id"];
        }

        [properties setValue:NSStringFromClass([view class]) forKey:@"#element_type"];

        NSString *elementContent = [[NSString alloc] init];
        elementContent = [TDAutoTrackUtils contentFromView:view];
        if (elementContent.length > 0) {
            elementContent = [elementContent substringWithRange:NSMakeRange(0,[elementContent length] - 1)];
            [properties setValue:elementContent forKey:@"#element_content"];
        }

        if (property != nil) {
            [properties addEntriesFromDictionary:property];
        }

        NSDictionary* propDict = view.thinkingAnalyticsViewProperties;
        if (propDict != nil) {
            [properties addEntriesFromDictionary:propDict];
        }
        
        [[ThinkingAnalyticsSDK sharedInstance] autotrack:@"ta_app_click" properties:properties];
        
    } @catch (NSException *exception) {
        TDLogError(@"%@: %@", self, exception);
    }
}

- (NSString *)getUIViewControllerTitle:(UIViewController *)controller {
    @try {
        if (controller == nil) {
            return nil;
        }
        
        UIView *titleView = controller.navigationItem.titleView;
        if (titleView != nil) {
            return [TDAutoTrackUtils contentFromView:titleView];
        }
    } @catch (NSException *exception) {
        TDLogError(@"%@: %@", self, exception);
    }
    return nil;
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

- (void)viewControlWillAppear:(UIViewController *)controller {
    if (_autoTrackEventType & ThinkingAnalyticsEventTypeAppClick) {
        void (^tableViewBlock)(id, SEL, id, id) = ^(id view, SEL command, UITableView *tableView, NSIndexPath *indexPath) {
            [TDAutoTrackUtils trackAppClickWithUITableView:tableView didSelectRowAtIndexPath:indexPath];
        };
        if ([controller respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
            [TDSwizzler swizzleSelector:@selector(tableView:didSelectRowAtIndexPath:) onClass:controller.class withBlock:tableViewBlock named:[NSString stringWithFormat:@"%@_%@", NSStringFromClass(self.class), @"UITableView_AutoTrack"]];
        }

        void (^collectionViewBlock)(id, SEL, id, id) = ^(id view, SEL command, UICollectionView *collectionView, NSIndexPath *indexPath) {
            [TDAutoTrackUtils trackAppClickWithUICollectionView:collectionView didSelectItemAtIndexPath:indexPath];
        };
        if ([controller respondsToSelector:@selector(collectionView:didSelectItemAtIndexPath:)]) {
            [TDSwizzler swizzleSelector:@selector(collectionView:didSelectItemAtIndexPath:) onClass:controller.class withBlock:collectionViewBlock named:[NSString stringWithFormat:@"%@_%@", NSStringFromClass(self.class), @"UICollectionView_AutoTrack"]];
        }
    }
    
    if (!(_autoTrackEventType & ThinkingAnalyticsEventTypeAppViewScreen)) {
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
    
    NSString *screenName = NSStringFromClass(klass);
    if (![self shouldTrackViewContrller:klass]) {
        return;
    }
    
    if (_ignoredViewControllers != nil && _ignoredViewControllers.count > 0) {
        if ([_ignoredViewControllers containsObject:screenName]) {
            return;
        }
    }

    NSMutableDictionary *properties = [[NSMutableDictionary alloc] init];
    [properties setValue:NSStringFromClass(klass) forKey:SCREEN_NAME_PROPERTY];

    @try {
        NSString *controllerTitle = controller.navigationItem.title;
        if (controllerTitle.length > 0) {
            [properties setValue:controllerTitle forKey:@"#title"];
        }

        NSString *elementContent = [self getUIViewControllerTitle:controller];
        if (elementContent.length > 0) {
            elementContent = [elementContent substringWithRange:NSMakeRange(0,[elementContent length] - 1)];
            [properties setValue:elementContent forKey:@"#title"];
        }
    } @catch (NSException *exception) {
        TDLogError(@"%@ failed to get UIViewController's title error: %@", self, exception);
    }

    if ([controller conformsToProtocol:@protocol(TDAutoTracker)]) {
        UIViewController<TDAutoTracker> *autoTrackerController = (UIViewController<TDAutoTracker> *)controller;
        NSDictionary *dic = [autoTrackerController getTrackProperties];
        if(dic)
        {
            if (![self checkPropertyTypes:[dic copy] withEventType:nil]) {
                TDLogError(@"%@ property error.", dic);
                return;
            }
        
            [properties addEntriesFromDictionary:dic];
            _lastScreenTrackProperties = [autoTrackerController getTrackProperties];
        }
    }

    if ([controller conformsToProtocol:@protocol(TDScreenAutoTracker)]) {
        UIViewController<TDScreenAutoTracker> *screenAutoTrackerController = (UIViewController<TDScreenAutoTracker> *)controller;
        NSString *currentScreenUrl = [screenAutoTrackerController getScreenUrl];

        [properties setValue:currentScreenUrl forKey:SCREEN_URL_PROPERTY];
        @synchronized (_referrerScreenUrl) {
            if (_referrerScreenUrl) {
                [properties setValue:_referrerScreenUrl forKey:SCREEN_REFERRER_URL_PROPERTY];
            }
            _referrerScreenUrl = currentScreenUrl;
        }
    }

    [self autotrack:APP_VIEW_SCREEN_EVENT properties:properties];
}

- (void)ignoreAutoTrackViewControllers:(NSArray *)controllers {
    if (controllers == nil || controllers.count == 0) {
        return;
    }
    [_ignoredViewControllers addObjectsFromArray:controllers];
    
    NSSet *set = [NSSet setWithArray:_ignoredViewControllers];
    if (set != nil) {
        _ignoredViewControllers = [NSMutableArray arrayWithArray:[set allObjects]];
    } else{
        _ignoredViewControllers = [[NSMutableArray alloc] init];
    }
}

- (UIViewController *)currentViewController {
    __block UIViewController *currentVC = nil;
    if ([[NSThread currentThread] isMainThread]) {
        @try {
            UIViewController *rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
            if (rootViewController != nil) {
                currentVC = [self getCurrentVCFrom:rootViewController];
            }
        } @catch (NSException *exception) {
            TDLogError(@"%@ error: %@", self, exception);
        }
        return currentVC;
    } else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            @try {
                UIViewController *rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
                if (rootViewController != nil) {
                    currentVC = [self getCurrentVCFrom:rootViewController];
                }
            } @catch (NSException *exception) {
                TDLogError(@"%@ error: %@", self, exception);
            }
        });
        return currentVC;
    }
}

- (UIViewController *)getCurrentVCFrom:(UIViewController *)rootVC {
    @try {
        UIViewController *currentVC;
        if ([rootVC presentedViewController]) {
            rootVC = [self getCurrentVCFrom:rootVC.presentedViewController];
        }
        
        if ([rootVC isKindOfClass:[UITabBarController class]]) {
            currentVC = [self getCurrentVCFrom:[(UITabBarController *)rootVC selectedViewController]];
        } else if ([rootVC isKindOfClass:[UINavigationController class]]){
            currentVC = [self getCurrentVCFrom:[(UINavigationController *)rootVC visibleViewController]];
        } else {
            if ([rootVC respondsToSelector:NSSelectorFromString(@"contentViewController")]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                UIViewController *tempViewController = [rootVC performSelector:NSSelectorFromString(@"contentViewController")];
#pragma clang diagnostic pop
                if (tempViewController) {
                    currentVC = [self getCurrentVCFrom:tempViewController];
                }
            } else {
                currentVC = rootVC;
            }
        }
        
        return currentVC;
    } @catch (NSException *exception) {
        TDLogError(@"%@ error: %@", self, exception);
    }
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

- (void)setLogLevel:(TDLoggingLevel)level
{
    [TDLogging sharedInstance].loggingLevel = level;
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

- (NSDictionary *)thinkingAnalyticsViewProperties {
    return objc_getAssociatedObject(self, @"thinkingAnalyticsViewProperties");
}

- (void)setThinkingAnalyticsViewProperties:(NSDictionary *)thinkingAnalyticsViewProperties {
    objc_setAssociatedObject(self, @"thinkingAnalyticsViewProperties", thinkingAnalyticsViewProperties, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)thinkingAnalyticsDelegate {
    return objc_getAssociatedObject(self, @"thinkingAnalyticsDelegate");
}

- (void)setThinkingAnalyticsDelegate:(id)thinkingAnalyticsDelegate {
    objc_setAssociatedObject(self, @"thinkingAnalyticsDelegate", thinkingAnalyticsDelegate, OBJC_ASSOCIATION_ASSIGN);
}

@end
