//
//  TDAgent.m
//  TDAnalyticsSDK
//
//  Created by thinkingdata on 2017/6/22.
//  Copyright © 2017年 thinkingdata. All rights reserved.
//

#import "ThinkingAnalyticsSDK.h"
#import "TDLogger.h"
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

#define VERSION @"1.0.11"
#ifndef    weakify
#if __has_feature(objc_arc)
#define weakify(object) autoreleasepool{} __weak __typeof__(object) weak##_##object = object;
#else
#define weakify(object) autoreleasepool{} __block __typeof__(object) block##_##object = object;
#endif
#endif

#ifndef    strongify
#if __has_feature(objc_arc)
#define strongify(object) try{} @finally{} __typeof__(object) object = weak##_##object;
#else
#define strongify(object) try{} @finally{} __typeof__(object) object = block##_##object;
#endif
#endif

static NSString* const APP_START_EVENT = @"ta_app_start";
static NSString* const APP_END_EVENT = @"ta_app_end";
static NSString* const APP_VIEW_SCREEN_EVENT = @"ta_app_view";
static NSString* const RESUME_FROM_BACKGROUND_PROPERTY = @"#resume_from_background";
static NSString* const SCREEN_NAME_PROPERTY = @"#screen_name";
static NSString* const SCREEN_URL_PROPERTY = @"#url";
static NSString* const SCREEN_REFERRER_URL_PROPERTY = @"#referrer";

static NSString * const kKeychainService = @"ThinkingdataService";
static NSString * const kKeychainAccessGroup = nil;
static ThinkingAnalyticsSDK *sharedInstance = nil;

@interface ThinkingAnalyticsSDK()<NSURLSessionDelegate>
{
}

@property (atomic, copy) NSString *serverURL;
@property (atomic, copy) NSString *configureURL;
@property (atomic, copy) NSString *appid;
@property (atomic, copy) NSString *accountId;
@property (atomic, copy) NSString *uniqueId;
@property (atomic, copy) NSString *deviceId;
@property (atomic, copy) NSString *identifyId;

@property (atomic, strong) NSDictionary *systemProperties;
@property (atomic, strong) NSDictionary *automaticData;
@property (nonatomic, strong) NSMutableDictionary *trackTimer;

@property (nonatomic) dispatch_queue_t serialQueue;
@property (nonatomic, strong) NSPredicate *regexKey;

@property (atomic, strong) TDSqliteDataQueue *dataQueue;
@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong) NSMutableArray *ignoredViewControllers;
@property (nonatomic, strong) NSMutableArray *ignoredViewTypeList;

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
    BOOL _autoTrack;
    BOOL _appRelaunched;
    BOOL _clearReferrerWhenAppEnd;
    NSString *_referrerScreenUrl;
    NSDictionary *_lastScreenTrackProperties;
}

- (id)performSelector:(SEL)aSelector
                  key:(NSString *)key
             andValue:(NSNumber *)andValue
{
    NSMethodSignature *signature = [self methodSignatureForSelector:aSelector];
    if(!signature)
        return nil;
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation setTarget:self];
    [invocation setSelector:aSelector];
    [invocation retainArguments];
    [invocation setArgument:&key atIndex:2];
    [invocation setArgument:&andValue atIndex:3];
    [invocation invoke];
    
    if ([signature methodReturnLength]) {
        id data;
        [invocation getReturnValue:&data];
        return data;
    }
    return nil;
}

- (id)performSelector:(SEL)aSelector
            paramobjs:(NSMutableDictionary *)parameter {
    NSMethodSignature *signature = [self methodSignatureForSelector:aSelector];
    if(!signature)
        return nil;
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation setTarget:self];
    [invocation setSelector:aSelector];
    [invocation retainArguments];
    void *parm = (__bridge void *)(parameter);
    [invocation setArgument:&parm atIndex:2];
    [invocation invoke];
    
    if ([signature methodReturnLength]) {
        id data;
        [invocation getReturnValue:&data];
        return data;
    }
    return nil;
}

- (id)performSelector:(SEL)aSelector
           parameters:(NSArray *)parameter {
    NSMethodSignature *signature = [self methodSignatureForSelector:aSelector];
    NSUInteger length = [signature numberOfArguments];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation setTarget:self];
    [invocation setSelector:aSelector];
    [invocation retainArguments];
    
    NSArray *typeArr = [self getSelType:aSelector];
    for (NSUInteger j = 0; j < length - 2; ++j) {
        NSString *type = [typeArr objectAtIndex:j];
        NSString *str = [[parameter objectAtIndex:j] text];
        
        if([type isEqualToString:@"Double"])
        {
            double arg = [str doubleValue];
            [invocation setArgument:&arg atIndex:j+2];
        }
        else if([type isEqualToString:@"int"])
        {
            long long arg = [str intValue];
            [invocation setArgument:&arg atIndex:j+2];
        }
        else if([type isEqualToString:@"String"])
        {
            [invocation setArgument:&str atIndex:j+2];
        }
        else
        {
            void *parm = (__bridge void *)(str);
            [invocation setArgument:&parm atIndex:j+2];
        }
    }
    
    [invocation invoke];
    
    if ([signature methodReturnLength]) {
        id data;
        [invocation getReturnValue:&data];
        return data;
    }
    return nil;
}

- (NSArray *)getSelType:(SEL)aSelector
{
    NSMethodSignature *signature = [self methodSignatureForSelector:aSelector];
    NSUInteger length = [signature numberOfArguments];
    NSMutableArray *typeArr = [NSMutableArray array];
    for (NSUInteger i = 2 ,j = 0; i < length; ++i,++j) {
        NSString *type = [NSString stringWithUTF8String:[signature getArgumentTypeAtIndex:i]];
        if([type isEqualToString:@"@"])
            [typeArr addObject:@"String"];
        else if([type isEqualToString:@"d"])
            [typeArr addObject:@"Double"];
        else if([type isEqualToString:@"Q"])
            [typeArr addObject:@"int"];
        else if([type isEqualToString:@"i"])
            [typeArr addObject:@"enum"];
    }
    return typeArr;
}

+ (ThinkingAnalyticsSDK *)startWithAppId:(NSString *)appId withUrl:(NSString *)url
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[super alloc] initWithAppkey:appId
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
               andConfigureURL:(NSString *)configureURL
{
    TDSDKDebug(@"Thank you very much for using Thinking Data SDK. We will do our best to provide you with the best service.");
    TDSDKDebug(@"Thinking Data SDK version:%@",VERSION);
    
    if (self = [self init]) {
        _networkType = ThinkingNetworkType3G | ThinkingNetworkType4G | ThinkingNetworkTypeWIFI;
        _autoTrackEventType = ThinkingAnalyticsEventTypeNone;
        
        self.serverURL = serverURL;
        self.configureURL = configureURL;
        self.appid = appid;
        if (appid.length == 0) {
            TDSDKDebug(@"appid is not right");
        }
        
        self.trackTimer = [NSMutableDictionary dictionary];
        _timeFormatter = [[NSDateFormatter alloc]init];
        _timeFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";

        _applicationWillResignActive = NO;
        _autoTrack = NO;
        _clearReferrerWhenAppEnd = NO;
        _referrerScreenUrl = nil;
        self.flushBeforeEnterBackground = YES;
        _ignoredViewControllers = [[NSMutableArray alloc] init];
        _ignoredViewTypeList = [[NSMutableArray alloc] init];
        _lastScreenTrackProperties = nil;
        
        NSString *keyPattern = @"^[a-zA-Z][a-zA-Z\\d_#]{0,49}$";
        self.regexKey = [NSPredicate predicateWithFormat:@"SELF MATCHES[c] %@", keyPattern];
        
        self.dataQueue = [[TDSqliteDataQueue alloc] initWithPath:[self pathForName:@"data"]];
        if (self.dataQueue == nil) {
            TDSDKDebug(@"SqliteException: init SqliteDataQueue failed");
        }
        
        [self getSysPro];
        [self getLoginId];
        [self getIdentifyId];
        [self getConfigFromUserdefault];
        [self updateConfig:appid];
        
        [self setUpListeners];
        
        self.automaticData = [self getAutomaticData];
        NSString *queuelabel = [NSString stringWithFormat:@"com.Thinkingdata.%p", self];
        self.serialQueue = dispatch_queue_create([queuelabel UTF8String], DISPATCH_QUEUE_SERIAL);
    }
    
    TDSDKDebug(@"init ThinkingAnalytics SDK with appid: '%@' ", _appid);
    return self;
}

- (void)clearReferrerWhenAppEnd {
    _clearReferrerWhenAppEnd = YES;
}

+ (NSString *)getUniqueHardwareId:(BOOL *)isReal {
    NSString *anonymityId = NULL;
    
    if (NSClassFromString(@"UIDevice")) {
        anonymityId = [[UIDevice currentDevice].identifierForVendor UUIDString];
        *isReal = YES;
    }
    
    if (!anonymityId) {
        anonymityId = [[NSUUID UUID] UUIDString];
        *isReal = NO;
    }
    
    return anonymityId;
}

-(void)updateConfig:(NSString *)appkey
{
    @weakify(self);
    void (^block)(NSData*, NSURLResponse*, NSError*) = ^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error || ![response isKindOfClass:[NSHTTPURLResponse class]]) {
            return;
        }
        @strongify(self);

        NSDictionary *ret = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
//        NSLog(@"ret1:%@",ret);
        if([ret isKindOfClass:[NSDictionary class]] && [[[ret copy] objectForKey:@"code"] isEqual:[NSNumber numberWithInt:0]])
        {
            NSDictionary *dic = [[ret copy] objectForKey:@"data"];
            NSInteger sync_interval = [[[dic copy] objectForKey:@"sync_interval"] unsignedIntegerValue];
            NSInteger sync_batch_size = [[[dic copy] objectForKey:@"sync_batch_size"] unsignedIntegerValue];
            if(sync_interval != self.uploadInterval && sync_interval > 0)
            {
                self.uploadInterval = sync_interval;
                [[NSUserDefaults standardUserDefaults]setInteger:sync_interval forKey:@"thinkingdata_uploadInterval"];
                [[NSUserDefaults standardUserDefaults]synchronize];
            }
            if(sync_batch_size != self.uploadSize && sync_batch_size > 0)
            {
                self.uploadSize = sync_batch_size;
                [[NSUserDefaults standardUserDefaults]setInteger:sync_batch_size forKey:@"thinkingdata_uploadSize"];
                [[NSUserDefaults standardUserDefaults]synchronize];
            }
        }
        else if( [[[ret copy] objectForKey:@"code"] isEqual:[NSNumber numberWithInt:-2]])
        {
            TDSDKDebug(@"APPID is wrong");
        }
    };
    
    NSString *urlStr = [NSString stringWithFormat:@"%@?appid=%@",self.configureURL,self.appid];
    
    NSURL *URL = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    [request setHTTPMethod:@"Get"];
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    NSURLSession * session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:block];
    [task resume];
    [session finishTasksAndInvalidate];
#else
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:
     ^(NSURLResponse *response, NSData* data, NSError *error) {
         return block(data, response, error);
     }];
#endif

}

#pragma mark -session delegate

//- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
//didFinishCollectingMetrics:(NSURLSessionTaskMetrics *)metrics
//{
//    NSLog(@"metrics:%@",metrics);
//}

-(void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler {

    NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    __block NSURLCredential *credential = nil;

    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust] && [challenge.protectionSpace.host hasSuffix:[[NSURL URLWithString:self.serverURL] host]]) {
        credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        if (credential) {
            disposition = NSURLSessionAuthChallengeUseCredential;
        } else {
            disposition = NSURLSessionAuthChallengePerformDefaultHandling;
        }
    } else {
        disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    }

    if (completionHandler) {
        completionHandler(disposition, credential);
    }
}

-(void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust] &&
        [challenge.protectionSpace.host hasSuffix:[[NSURL URLWithString:self.serverURL] host]])
    {
        [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
    }
    else
    {
        [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
    }
}

- (void)setNetworkType:(ThinkingAnalyticsNetworkType)type
{
    if(type == TDNetworkTypeDefault)
    {
        _networkType = ThinkingNetworkTypeWIFI | ThinkingNetworkType3G | ThinkingNetworkType4G;
    }
    else if(type == TDNetworkTypeOnlyWIFI)
    {
        _networkType = ThinkingNetworkTypeWIFI;
    }
    else if(type == TDNetworkTypeALL)
    {
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

- (void)applicationWillEnterForeground:(NSNotification *)notification {
    TDSDKDebug(@"%@ application will enter foreground", self);
    
    _appRelaunched = YES;
}

+ (UInt64)getSystemUpTime {
    UInt64 time = NSProcessInfo.processInfo.systemUptime * 1000;
    return time;
}

- (NSString *)getLastScreenUrl {
    return _referrerScreenUrl;
}

- (void)applicationDidEnterBackground:(NSNotification *)notification {
    TDSDKDebug(@"%@ application did enter background", self);
    _applicationWillResignActive = NO;
    
    dispatch_async(self.serialQueue, ^{
        NSNumber *currentSystemUpTime = @([[self class] getSystemUpTime]);
        NSArray *keys = [self.trackTimer allKeys];
        NSString *key = nil;
        NSMutableDictionary *eventTimer = nil;
        for (key in keys) {
            if (key != nil) {
                if ([key isEqualToString:@"ta_app_end"]) {
                    continue;
                }
            }
            eventTimer = [[NSMutableDictionary alloc] initWithDictionary:self.trackTimer[key]];
            if (eventTimer) {
                NSNumber *eventBegin = [eventTimer valueForKey:@"eventBegin"];
                NSNumber *eventAccumulatedDuration = [eventTimer objectForKey:@"eventAccumulatedDuration"];
                long eventDuration;
                if (eventAccumulatedDuration) {
                    eventDuration = [currentSystemUpTime longValue] - [eventBegin longValue] + [eventAccumulatedDuration longValue];
                } else {
                    eventDuration = [currentSystemUpTime longValue] - [eventBegin longValue];
                }
                [eventTimer setObject:[NSNumber numberWithLong:eventDuration] forKey:@"eventAccumulatedDuration"];
                [eventTimer setObject:currentSystemUpTime forKey:@"eventBegin"];
                self.trackTimer[key] = eventTimer;
            }
        }
    });
    
    if (_autoTrack) {
        if (_autoTrackEventType & ThinkingAnalyticsEventTypeAppEnd) {
            if (_clearReferrerWhenAppEnd) {
                _referrerScreenUrl = nil;
            }
            [self autotrack:APP_END_EVENT properties:nil];
        }
    }
    
    if (self.flushBeforeEnterBackground) {
        dispatch_async(self.serialQueue, ^{
            [self _sync:YES];
        });
    }
    
}

- (void)applicationWillResignActive:(NSNotification *)notification {
    TDSDKDebug(@"%@ application will resign active", self);
    _applicationWillResignActive = YES;
    [self stopFlushTimer];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    TDSDKDebug(@"%@ application did become active", self);
    
    [self startFlushTimer];
    
    if (_applicationWillResignActive) {
        _applicationWillResignActive = NO;
        return;
    }
    _applicationWillResignActive = NO;
    
    dispatch_async(self.serialQueue, ^{
        NSNumber *currentSystemUpTime = @([[self class] getSystemUpTime]);
        NSArray *keys = [self.trackTimer allKeys];
        NSString *key = nil;
        NSMutableDictionary *eventTimer = nil;
        for (key in keys) {
            eventTimer = [[NSMutableDictionary alloc] initWithDictionary:self.trackTimer[key]];
            if (eventTimer) {
                [eventTimer setValue:currentSystemUpTime forKey:@"eventBegin"];
                self.trackTimer[key] = eventTimer;
            }
        }
    });
    
    if (_autoTrack && _appRelaunched) {
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

-(void)getConfigFromUserdefault
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger interval = [userDefaults integerForKey:@"thinkingdata_uploadInterval"];
    if (interval <= 0)
    {
        self.uploadInterval = 15;
        [userDefaults setInteger:15 forKey:@"thinkingdata_uploadInterval"];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
    else
    {
        self.uploadInterval = interval;
    }
    NSInteger size = [userDefaults integerForKey:@"thinkingdata_uploadSize"];
    if (size <= 0)
    {
        self.uploadSize = 20;
        [userDefaults setInteger:20 forKey:@"thinkingdata_uploadSize"];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
    else
    {
        self.uploadSize = size;
    }
}

- (NSString *)deviceModel {
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char answer[size];
    sysctlbyname("hw.machine", answer, &size, NULL, 0);
    NSString *results = @(answer);
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

- (NSDictionary *)getAutomaticData {
    NSMutableDictionary *p = [NSMutableDictionary dictionary];
    UIDevice *device = [UIDevice currentDevice];
    BOOL isReal;
    [p setValue:[[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"] forKey:@"#app_version"];
    
    NSString *uniId = [[self class] getUniqueHardwareId:&isReal];
    NSString *deviceId;
    NSString *distinctId;
    
    TDKeychainItemWrapper *keychainItem = [[TDKeychainItemWrapper alloc]initWithIdentifier:kKeychainService accessGroup:nil];
    
    NSDictionary *dic = [keychainItem objectForKey:(__bridge id)kSecValueData];
    BOOL isNotfirst = [[[NSUserDefaults standardUserDefaults] objectForKey:@"thinking_isfirst"] boolValue];
    NSNumber *setup_index;
    
    if([dic count] > 0)
    {
        NSString *distinctIdKeychain = [dic objectForKey:@"thinking_distinct_id"];
        if(distinctIdKeychain.length == 0) //老用户  //第一次打开或升级
        {
            setup_index = [NSNumber numberWithInt:1];
            deviceId = [dic objectForKey:@"thinking_device_id"];
            distinctId = uniId;
            
            NSDictionary *saveData = @{
                                       @"thinking_device_id":deviceId,
                                       @"thinking_distinct_id":distinctId,
                                       @"thinking_setup_index":setup_index
                                       };
            [keychainItem setObject:saveData forKey:(__bridge id)kSecValueData];
            
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"thinking_isfirst"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [[NSUserDefaults standardUserDefaults] setObject:deviceId forKey:@"thinking_ud_device_id"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        else
        {
            if(!isNotfirst)//第一次打开
            {
                setup_index = [dic objectForKey:@"thinking_setup_index"];
                int setup_int = [setup_index intValue];
                setup_int++;
                
                deviceId = [dic objectForKey:@"thinking_device_id"];
                distinctId = [NSString stringWithFormat:@"%@_%d",deviceId,setup_int];
                
                NSDictionary *saveData = @{
                                           @"thinking_device_id":deviceId,
                                           @"thinking_distinct_id":distinctId,
                                           @"thinking_setup_index":[NSNumber numberWithInt:setup_int]
                                           };
                [keychainItem setObject:saveData forKey:(__bridge id)kSecValueData];
                
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"thinking_isfirst"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [[NSUserDefaults standardUserDefaults] setObject:deviceId forKey:@"thinking_ud_device_id"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            else
            {
                deviceId = [dic objectForKey:@"thinking_device_id"];
                distinctId = distinctIdKeychain;
            }
        }
    }
    else
    {
        //新客户 没有老版本sdk的 且是第一次运行app
        setup_index = [NSNumber numberWithInt:1];
        
        deviceId = uniId;
        distinctId = uniId;
        
        NSDictionary *saveData = @{
                                   @"thinking_device_id":deviceId,
                                   @"thinking_distinct_id":distinctId,
                                   @"thinking_setup_index":setup_index
                                   };
        [keychainItem setObject:saveData forKey:(__bridge id)kSecValueData];
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"thinking_isfirst"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [[NSUserDefaults standardUserDefaults] setObject:deviceId forKey:@"thinking_ud_device_id"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    self.uniqueId = [distinctId copy];
    self.deviceId = [deviceId copy];
    
    [p setValue:deviceId forKey:@"#device_id"];
    CTCarrier *carrier = [[[CTTelephonyNetworkInfo alloc] init] subscriberCellularProvider];
    if (carrier != nil) {
        NSString *networkCode = [carrier mobileNetworkCode];
        if (networkCode != nil) {
            NSString *carrierName = nil;
            if ([networkCode isEqualToString:@"00"] || [networkCode isEqualToString:@"02"] || [networkCode isEqualToString:@"07"] || [networkCode isEqualToString:@"08"]) {
                carrierName= @"中国移动";
            }
            
            if ([networkCode isEqualToString:@"01"] || [networkCode isEqualToString:@"06"] || [networkCode isEqualToString:@"09"]) {
                carrierName= @"中国联通";
            }
            
            if ([networkCode isEqualToString:@"03"] || [networkCode isEqualToString:@"05"] || [networkCode isEqualToString:@"11"]) {
                carrierName= @"中国电信";
            }
            if (carrierName != nil) {
                [p setValue:carrier.carrierName forKey:@"#carrier"];
            }
        }
    }
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
                                  @"#screen_width": @((NSInteger)size.width),
                                  }];
    return [p copy];
}

- (NSString *) isJailbroken
{
    NSString *jailbroken = @"0";
    NSString *cydiaPath = @"/Applications/Cydia.app";
    NSString *aptPath = @"/private/var/lib/apt/";
    if ([[NSFileManager defaultManager] fileExistsAtPath:cydiaPath])
    {
        jailbroken = @"1";
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:aptPath])
    {
        jailbroken = @"1";
    }
    return jailbroken;
}

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

+ (NSString *)getNetWorkStates {
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    NSString* network = @"NULL";
    @try {
        TDSDKReachabilityManager *reachability = [TDSDKReachabilityManager reachabilityForInternetConnection];
        TDReachabilityStatus status = [reachability currentReachabilityStatus];
        
        if (status == TDReachabilityStatusReachableViaWiFi) {
            network = @"WIFI";
        }
        else if (status == TDReachabilityStatusReachableViaWWAN) {
            CTTelephonyNetworkInfo *netinfo = [[CTTelephonyNetworkInfo alloc] init];
            if ([netinfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyGPRS]) {
                network = @"2G";
            } else if ([netinfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyEdge]) {
                network = @"2G";
            } else if ([netinfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyWCDMA]) {
                network = @"3G";
            } else if ([netinfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyHSDPA]) {
                network = @"3G";
            } else if ([netinfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyHSUPA]) {
                network = @"3G";
            } else if ([netinfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyCDMA1x]) {
                network = @"3G";
            } else if ([netinfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyCDMAEVDORev0]) {
                network = @"3G";
            } else if ([netinfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyCDMAEVDORevA]) {
                network = @"3G";
            } else if ([netinfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyCDMAEVDORevB]) {
                network = @"3G";
            } else if ([netinfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyeHRPD]) {
                network = @"3G";
            } else if ([netinfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyLTE]) {
                network = @"4G";
            }
        }
        
    }
    @catch(NSException *exception) {
    }
    
    return network;
#else
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *children = [[[app valueForKeyPath:@"statusBar"]valueForKeyPath:@"foregroundView"]subviews];
    for (id child in children) {
        if ([child isKindOfClass:NSClassFromString(@"UIStatusBarDataNetworkItemView")]) {
            int netType = [[child valueForKeyPath:@"dataNetworkType"]intValue];
            switch (netType) {
                case 0:
                    return @"NULL"
                case 1:
                    return @"2G";
                case 2:
                    return @"3G";
                case 3:
                    return @"4G";
                case 5:
                    return @"WIFI";
            }
        }
    }
    return @"NULL";
#endif
}

- (void)saveIdentifyId{
    [[NSUserDefaults standardUserDefaults] setObject:[_identifyId copy] forKey:@"thinkingdata_identifyId"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)getIdentifyId{
    @synchronized(_identifyId) {
        self.identifyId = [[NSUserDefaults standardUserDefaults] objectForKey:@"thinkingdata_identifyId"];
    }
}

- (void)saveLoginId{
    [[NSUserDefaults standardUserDefaults] setObject:[self.accountId copy] forKey:@"thinkingdata_accountId"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)getLoginId{
    @synchronized(_accountId) {
        self.accountId = [[NSUserDefaults standardUserDefaults] objectForKey:@"thinkingdata_accountId"];
    }
}

- (void)saveSysPro{
    [[NSUserDefaults standardUserDefaults] setObject:[self.systemProperties copy] forKey:@"thinkingdata_systemProperties"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)getSysPro{
    self.systemProperties = [[NSUserDefaults standardUserDefaults] objectForKey:@"thinkingdata_systemProperties"];
    if (self.systemProperties == nil) {
        self.systemProperties = [NSDictionary dictionary];
    }
}

- (void)setSuperProperties:(NSDictionary *)propertyDict {
    
    if (propertyDict == nil)
    {
        return;
    }
    
    if (![self checkPropertyTypes:[propertyDict copy] withEventType:nil]) {
        TDSDKLog(@"%@ propertieDict error.", propertyDict);
        return;
    }
    
    @weakify(self);
    dispatch_async(self.serialQueue, ^{
        @strongify(self);
        NSMutableDictionary *tmp = [NSMutableDictionary dictionaryWithDictionary:self.systemProperties];
        [tmp addEntriesFromDictionary:[propertyDict copy]];
        self.systemProperties = [NSDictionary dictionaryWithDictionary:tmp];
        [self saveSysPro];
    });
}

- (void)unsetSuperProperty:(NSString *)property {
    if(property.length == 0)
        return;
    @weakify(self);
    dispatch_async(self.serialQueue, ^{
        @strongify(self);
        NSMutableDictionary *tmp = [NSMutableDictionary dictionaryWithDictionary:self.systemProperties];
        if (tmp[property] != nil) {
            [tmp removeObjectForKey:property];
        }
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
        TDSDKLog(@"identify cannot null");
        return;
    }
    
    dispatch_async(self.serialQueue, ^{
        @synchronized(self.identifyId)
        {
            if(self.identifyId != distinctId)
            {
                self.identifyId = distinctId;
                [self saveIdentifyId];
            }
        }
    });
}

- (void)login:(NSString *)accountId{
    if (accountId.length == 0) {
        TDSDKDebug(@"accountId cannot null", accountId);
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

- (void)user_add:(NSString *)propertyName andPropertyValue:(NSNumber *)propertyValue{
    NSDictionary *dic = @{[propertyName copy]:[propertyValue copy]};
    [self click:nil withProperties:dic withType:@"user_add"];
}

- (void)user_add:(NSDictionary *)property{
    if([self checkProperties:property])
    {
        [self click:nil withProperties:property withType:@"user_add"];
    }
}

- (void)user_setOnce:(NSDictionary *)property{
    if([self checkProperties:property])
    {
        [self click:nil withProperties:property withType:@"user_setOnce"];
    }
}

- (void)user_set:(NSDictionary *)property{
    if([self checkProperties:property])
    {
        [self click:nil withProperties:property withType:@"user_set"];
    }
}

- (void)user_delete{
    [self click:nil withProperties:@{} withType:@"user_del"];
}

- (void)timeEvent:(NSString *)event
{
    if (![self isValidName: event]) {
        NSString *errMsg = [NSString stringWithFormat:@"timeEvent parameter[%@] is not valid", event];
        TDSDKLog(errMsg);
        return ;
    }
    
    NSNumber *eventBegin = @([[self class] getSystemUpTime]);
    
    if (event.length == 0) {
        return;
    }
    dispatch_async(self.serialQueue, ^{
         self.trackTimer[event] = @{@"eventBegin" : eventBegin, @"eventAccumulatedDuration" : [NSNumber numberWithLong:0]};
    });
}

- (void)track:(NSString *)event{
    [self click:event withProperties:nil withType:@"track"];
}

-(BOOL)checkProperties:(NSDictionary*)dic{
    for (id __unused k in dic) {
        if (![self isValidName: k]) {
            NSString *errMsg = [NSString stringWithFormat:@"property name[%@] is not valid", k];
            TDSDKLog(errMsg);
            return NO;
        }
    }
    return YES;
}

- (void)track:(NSString *)event
   properties:(NSDictionary *)propertieDict{
    if([self checkProperties:propertieDict])
    {
        [self click:event withProperties:propertieDict withType:@"track"];
    }
}

- (void)track:(NSString *)event
   properties:(NSDictionary *)propertieDict
         time:(NSDate *)time
{
    if([self checkProperties:propertieDict])
    {
        [self click:event withProperties:propertieDict withType:@"track" withTime:time];
    }
}

- (void)autotrack:(NSString *)event
       properties:(NSDictionary *)propertieDict{
    [self click:event withProperties:propertieDict withType:@"track"];
}

- (void)click:(NSString *)event {
    [self click:event withProperties:nil withType:@"track"];
}

- (BOOL)isValidName:(NSString *) name {
    NSString *deviceModel;
    if (deviceModel == nil) {
        deviceModel = [self deviceModel];
    }
    
    NSString *osVersion;
    if (osVersion == nil) {
        UIDevice *device = [UIDevice currentDevice];
        osVersion = [device systemVersion];
    }
    
    if ([osVersion isEqualToString:@"11.0"]) {
        if ([deviceModel isEqualToString:@"iPhone10,1"] ||
            [deviceModel isEqualToString:@"iPhone10,4"] ||
            [deviceModel isEqualToString:@"iPhone10,2"] ||
            [deviceModel isEqualToString:@"iPhone10,5"]) {
            return YES;
        }
    }
    
    return [self.regexKey evaluateWithObject:name];
}

- (BOOL)checkPropertyTypes:(NSDictionary *)properties withEventType:(NSString *)eventType
{
    for (id __unused k in properties) {
        if (![k isKindOfClass: [NSString class]]) {
            NSString *errMsg = @"Property Key should by NSString";
            TDSDKLog(errMsg);
            return NO;
        }

        if(![properties[k] isKindOfClass:[NSString class]] &&
           ![properties[k] isKindOfClass:[NSNumber class]] &&
           ![properties[k] isKindOfClass:[NSDate class]]) {
            NSString * errMsg = [NSString stringWithFormat:@"property values must be NSString, NSNumber got: %@ %@", [properties[k] class], properties[k]];
            TDSDKLog(errMsg);
            return NO;
        }
        
        if ([properties[k] isKindOfClass:[NSString class]]) {
            NSUInteger objLength = [((NSString *)properties[k]) lengthOfBytesUsingEncoding:NSUnicodeStringEncoding];
            if (objLength > 5000) {
                NSString * errMsg = [NSString stringWithFormat:@"The value is too long: %@", (NSString *)properties[k]];
                TDSDKLog(errMsg);
                return NO;
            }
        }
        
        if ([eventType isEqualToString:@"user_add"]) {
            if (![properties[k] isKindOfClass:[NSNumber class]]) {
                NSString *errMsg = [NSString stringWithFormat:@"user_add value must be NSNumber. got: %@ %@", [properties[k] class], properties[k]];
                TDSDKLog(errMsg);
                return NO;
            }
        }
       
        if([properties[k] isKindOfClass:[NSNumber class]])
        {
            if([properties[k] doubleValue] > 9999999999999.999 || [properties[k] doubleValue] < -9999999999999.999)
            {
                TDSDKLog(@"number value is not valid.");
                return NO;
            }
        }
    }
    
    return YES;
}

- (void)click:(NSString *)event
withProperties:(NSDictionary *)propertieDict
     withType:(NSString *)type{
    [self click:event withProperties:propertieDict withType:type withTime:[NSDate date]];
}

 - (void)click:(NSString *)event
withProperties:(NSDictionary *)propertieDict
      withType:(NSString *)type
      withTime:(NSDate *)time
{
    if([type isEqualToString:@"track"])
    {
        if (event == nil || [event length] == 0 || ![event isKindOfClass:[NSString class]]) {
            TDSDKLog(@"event key is not valid");
            return;
        }
        
        if (![self isValidName: event]) {
            NSString *errMsg = [NSString stringWithFormat:@"property name[%@] is not valid", event];
            TDSDKLog(@"%@", errMsg);
            return;
        }
    }
     
     if (propertieDict) {
         if (![self checkPropertyTypes:[propertieDict copy] withEventType:type]) {
             TDSDKLog(@"%@ properties error.", propertieDict);
             return;
         }
     }
    
    dispatch_async(self.serialQueue, ^{
        
        NSString *timeStamp;
        
        if(time == nil)
        {
            timeStamp = [_timeFormatter stringFromDate:[NSDate date]];
        }
        else
        {
            timeStamp = [_timeFormatter stringFromDate:time];
        }
        
        NSString *networkType = [ThinkingAnalyticsSDK getNetWorkStates];
        
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        if([dic objectForKey:@"#network_type"] == nil && [type isEqualToString:@"track"])
        {
            [dic setObject:networkType forKey:@"#network_type"];
        }
        
        if([type isEqualToString:@"track"])
        {
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
          
            float eventDuration;
            NSNumber *currentSystemUpTime = @([[self class] getSystemUpTime]);
            if (eventAccumulatedDuration) {
                eventDuration = [currentSystemUpTime longValue] - [eventBegin longValue] + [eventAccumulatedDuration longValue];
            } else {
                eventDuration = [currentSystemUpTime longValue] - [eventBegin longValue];
            }
            
            if (eventDuration < 0) {
                eventDuration = 0;
            }
            
            if (eventDuration > 0 && eventDuration < 24 * 60 * 60 * 1000) {
                eventDuration = eventDuration / 1000.0;
                dic[@"#duration"] = @([[NSString stringWithFormat:@"%.3f", eventDuration] floatValue]);
            }
        }
        
        NSDictionary *e;
        NSString *loginId = self.accountId;
        
        NSString *distinct;
        if(self.identifyId.length == 0)
            distinct = self.uniqueId;
        else
            distinct = self.identifyId;
        
        e = @{
              @"#time": timeStamp,
              @"#type": type,
              @"#distinct_id":distinct,
              };
        
        NSMutableDictionary *dataDic = [e mutableCopy];
        if(dic.allKeys.count > 0)
        {
            [dataDic setObject:dic forKey:@"properties"];
        }
        
        if(event)
        {
            [dataDic setObject:event forKey:@"#event_name"];
        }
        
        if(loginId.length > 0 && ![loginId isEqualToString:@"null"])
        {
            [dataDic setObject:loginId forKey:@"#account_id"];
        }
        
        [self saveClickData:type andEvent:dataDic];
      
//        NSLog(@"dataDic:%@",dataDic);
        
        if ([[self dataQueue] count] >= self.uploadSize) {
            [self _sync:NO];
        }
        
        dataDic = nil;
    });
}

- (void)sync {
    dispatch_async(self.serialQueue, ^{
        [self _sync:NO];
    });
}

- (ThinkingNetworkType)convertNetworkType:(NSString *)networkType {
    if ([@"NULL" isEqualToString:networkType]) {
        return ThinkingNetworkTypeALL;
    } else if ([@"WIFI" isEqualToString:networkType]) {
        return ThinkingNetworkTypeWIFI;
    } else if ([@"2G" isEqualToString:networkType]) {
        return ThinkingNetworkType2G;
    }   else if ([@"3G" isEqualToString:networkType]) {
        return ThinkingNetworkType3G;
    }   else if ([@"4G" isEqualToString:networkType]) {
        return ThinkingNetworkType4G;
    }
    return ThinkingNetworkTypeNONE;
}

- (void)_sync:(BOOL) vacuumAfterFlushing {
    NSString *networkType = [ThinkingAnalyticsSDK getNetWorkStates];
    if (!([self convertNetworkType:networkType] & _networkType)) {
        return;
    }
    
    NSArray *recordArray = [self.dataQueue getFirstRecords:50];
    
    if ([recordArray count] > 0) {
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
        __block BOOL flushSucc = NO;
        
        @weakify(self);
        void (^block)(NSData*, NSURLResponse*, NSError*) = ^(NSData *data, NSURLResponse *response, NSError *error) {
            if (error || ![response isKindOfClass:[NSHTTPURLResponse class]]) {
                TDSDKError(@"Networking error");
                dispatch_semaphore_signal(flushSem);
                return;
            }
            
            NSHTTPURLResponse *urlResponse = (NSHTTPURLResponse*)response;
            if([urlResponse statusCode] != 200) {
                NSString *urlResponseContent = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSString *errMsg = [NSString stringWithFormat:@"%@ flush failure with response '%@'.", self, urlResponseContent];
                TDSDKError(@"%@", errMsg);
            } else {
                NSDictionary *ret = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                
                TDSDKDebug(@"url ret:%@",ret);
                if([ret isKindOfClass:[NSDictionary class]] && [[[ret copy] objectForKey:@"code"] isEqual:[NSNumber numberWithInt:0]])
                {
                    flushSucc = YES;
                    if(flushSucc)
                    {
                        @strongify(self);
                        [self.dataQueue removeFirstRecords:50];
                        
//                        #ifdef TDSDKLogEnable
//                            @try {
//                                NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
//                                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
//                                NSString *logString=[[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
//
//                                TDSDKDebug(@"data:%@",logString);
//                            } @catch (NSException *exception) {
//                                TDSDKDebug(@"%@: %@", self, exception);
//                            }
//                        #endif
                    }
                }
            }
            
            dispatch_semaphore_signal(flushSem);
        };
        
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession * session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:nil];
        NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:block];
        
        [task resume];
        [session finishTasksAndInvalidate];
#else
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:
         ^(NSURLResponse *response, NSData* data, NSError *error) {
             return block(data, response, error);
         }];
#endif
        dispatch_semaphore_wait(flushSem, DISPATCH_TIME_FOREVER);
    }
}

- (void)saveClickData:(NSString *)type andEvent:(NSDictionary *)e {
    NSMutableDictionary *event = [[NSMutableDictionary alloc] initWithDictionary:e];
    [self.dataQueue addObejct:event];
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
    @synchronized(self) {
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

- (void)stopFlushTimer
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.timer) {
            [self.timer invalidate];
            self.timer = nil;
        }
    });
}

- (void)enableAutoTrack:(ThinkingAnalyticsAutoTrackEventType)eventType {
    _autoTrackEventType = eventType;
    _autoTrack = (_autoTrackEventType != ThinkingAnalyticsEventTypeNone);

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


- (void)trackGestureRecognizerAppClick:(id)target {
    @try {
        if (target == nil) {
            return;
        }
        UIGestureRecognizer *gesture = target;
        if (gesture == nil) {
            return;
        }
        
        if (gesture.state != UIGestureRecognizerStateEnded) {
            return;
        }
        
        UIView *view = gesture.view;
        if (view == nil) {
            return;
        }
        if (![self isAutoTrackEnabled]) {
            return;
        }
        
        if ([self isAutoTrackEventTypeIgnored:ThinkingAnalyticsEventTypeAppClick]) {
            return;
        }
        
        if ([view isKindOfClass:[UILabel class]]) {
            if ([self isViewTypeIgnored:[UILabel class]]) {
                return;
            }
        } else if ([view isKindOfClass:[UIImageView class]]) {
            if ([self isViewTypeIgnored:[UIImageView class]]) {
                return;
            }
        }
        
        if (view.thinkingAnalyticsIgnoreView) {
            return;
        }
        
        UIViewController *viewController = [self currentViewController];
        NSMutableDictionary *properties = [[NSMutableDictionary alloc] init];
        
        if (viewController != nil) {
            if ([[ThinkingAnalyticsSDK sharedInstance] isViewControllerIgnored:viewController]) {
                return;
            }
            
            NSString *screenName = NSStringFromClass([viewController class]);
            [properties setValue:screenName forKey:@"#screen_name"];
            
            NSString *controllerTitle = viewController.navigationItem.title;
            if (controllerTitle != nil) {
                [properties setValue:viewController.navigationItem.title forKey:@"#title"];
            }
            
            NSString *elementContent = [self getUIViewControllerTitle:viewController];
            if (elementContent != nil && [elementContent length] > 0) {
                elementContent = [elementContent substringWithRange:NSMakeRange(0,[elementContent length] - 1)];
                [properties setValue:elementContent forKey:@"#title"];
            }
        }
        
        if (view.thinkingAnalyticsViewID != nil) {
            [properties setValue:view.thinkingAnalyticsViewID forKey:@"#element_id"];
        }
        
        NSDictionary* propDict = view.thinkingAnalyticsViewProperties;
        if (propDict != nil) {
            [properties addEntriesFromDictionary:propDict];
        }
        
        [[ThinkingAnalyticsSDK sharedInstance] autotrack:@"ta_app_click" properties:properties];
    } @catch (NSException *exception) {
        TDSDKError(@"%@ error: %@", self, exception);
    }
}

- (void)_enableAutoTrack {
    void (^unswizzleUITableViewAppClickBlock)(id, SEL, id) = ^(id obj, SEL sel, NSNumber* a) {
        UIViewController *controller = (UIViewController *)obj;
        if (!controller) {
            return;
        }
        
        Class klass = [controller class];
        if (!klass) {
            return;
        }
        
        NSString *screenName = NSStringFromClass(klass);

#ifndef THINKING_ANALYTICS_DISABLE_AUTOTRACK_UITABLEVIEW
        if ([controller respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
            [TDSwizzler unswizzleSelector:@selector(tableView:didSelectRowAtIndexPath:) onClass:klass named:[NSString stringWithFormat:@"%@_%@", screenName, @"UITableView_AutoTrack"]];
        }
#endif

#ifndef THINKING_ANALYTICS_DISABLE_AUTOTRACK_UICOLLECTIONVIEW
        if ([controller respondsToSelector:@selector(collectionView:didSelectItemAtIndexPath:)]) {
            [TDSwizzler unswizzleSelector:@selector(collectionView:didSelectItemAtIndexPath:) onClass:klass named:[NSString stringWithFormat:@"%@_%@", screenName, @"UICollectionView_AutoTrack"]];
        }
#endif
    };
    
    void (^gestureRecognizerAppClickBlock)(id, SEL, id) = ^(id target, SEL command, id arg) {
        @try {
            if ([arg isKindOfClass:[UITapGestureRecognizer class]] ||
                [arg isKindOfClass:[UILongPressGestureRecognizer class]]) {
                [arg addTarget:self action:@selector(trackGestureRecognizerAppClick:)];   
            }
        } @catch (NSException *exception) {
            TDSDKError(@"%@ error: %@", self, exception);
        }
    };
    
    if (_autoTrack) {
        if (_autoTrackEventType & ThinkingAnalyticsEventTypeAppViewScreen ||
            _autoTrackEventType & ThinkingAnalyticsEventTypeAppClick) {
            [UIViewController td_swizzleMethod:@selector(viewWillAppear:) withMethod:@selector(td_autotrack_viewWillAppear:) error:NULL];
        }

        if (_autoTrackEventType & ThinkingAnalyticsEventTypeAppClick) {
#if (!defined THINKING_ANALYTICS_DISABLE_AUTOTRACK_UITABLEVIEW) || (!defined THINKING_ANALYTICS_DISABLE_AUTOTRACK_UICOLLECTIONVIEW)
            [TDSwizzler swizzleBoolSelector:@selector(viewWillDisappear:)
                                    onClass:[UIViewController class]
                                  withBlock:unswizzleUITableViewAppClickBlock
                                      named:@"track_UITableView_UICollectionView_AppClick_viewWillDisappear"];
#endif

#ifndef THINKING_ANALYTICS_DISABLE_AUTOTRACK_GESTURE
#ifndef THINKING_ANALYTICS_DISABLE_AUTOTRACK_UILABEL
            [TDSwizzler swizzleSelector:@selector(addGestureRecognizer:) onClass:[UILabel class] withBlock:gestureRecognizerAppClickBlock named:@"track_UILabel_addGestureRecognizer"];
#endif

#ifndef THINKING_ANALYTICS_DISABLE_AUTOTRACK_UIIMAGEVIEW
            [TDSwizzler swizzleSelector:@selector(addGestureRecognizer:) onClass:[UIImageView class] withBlock:gestureRecognizerAppClickBlock named:@"track_UIImageView_addGestureRecognizer"];
#endif

#endif
            
        }
    }
  
}

- (BOOL)isAutoTrackEnabled {
    return _autoTrack;
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

- (void)trackViewAppClick:(UIView *)view withProperties:(NSDictionary *)p {
    @try {
        if (view == nil) {
            return;
        }
        
        if (![[ThinkingAnalyticsSDK sharedInstance] isAutoTrackEnabled]) {
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
            if (controllerTitle != nil) {
                [properties setValue:viewController.navigationItem.title forKey:@"#title"];
            }

            NSString *elementContent = [self getUIViewControllerTitle:viewController];
            if (elementContent != nil && [elementContent length] > 0) {
                elementContent = [elementContent substringWithRange:NSMakeRange(0,[elementContent length] - 1)];
                [properties setValue:elementContent forKey:@"#title"];
            }
        }

        if (view.thinkingAnalyticsViewID != nil) {
            [properties setValue:view.thinkingAnalyticsViewID forKey:@"#element_id"];
        }

        [properties setValue:NSStringFromClass([view class]) forKey:@"#element_type"];

        NSString *elementContent = [[NSString alloc] init];
        elementContent = [TDAutoTrackUtils contentFromView:view];
        if (elementContent != nil && [elementContent length] > 0) {
            elementContent = [elementContent substringWithRange:NSMakeRange(0,[elementContent length] - 1)];
            [properties setValue:elementContent forKey:@"#element_content"];
        }

        if (p != nil) {
            [properties addEntriesFromDictionary:p];
        }

        NSDictionary* propDict = view.thinkingAnalyticsViewProperties;
        if (propDict != nil) {
            [properties addEntriesFromDictionary:propDict];
        }
        
        [[ThinkingAnalyticsSDK sharedInstance] autotrack:@"ta_app_click" properties:properties];
        
    } @catch (NSException *exception) {
        TDSDKError(@"%@: %@", self, exception);
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
        TDSDKError(@"%@: %@", self, exception);
    }
    return nil;
}

- (void)trackViewScreen:(NSString *)url withProperties:(NSDictionary *)properties {
    if([self checkProperties:properties])
    {
        NSMutableDictionary *trackProperties = [[NSMutableDictionary alloc] init];
        if (properties) {
            [trackProperties addEntriesFromDictionary:properties];
        }
        @synchronized(_lastScreenTrackProperties) {
            _lastScreenTrackProperties = properties;
        }
        
        [trackProperties setValue:url forKey:SCREEN_URL_PROPERTY];
        @synchronized(_referrerScreenUrl) {
            if (_referrerScreenUrl) {
                [trackProperties setValue:_referrerScreenUrl forKey:SCREEN_REFERRER_URL_PROPERTY];
            }
            _referrerScreenUrl = url;
        }
        [self autotrack:APP_VIEW_SCREEN_EVENT properties:trackProperties];
    }
}

- (BOOL)shouldTrackClass:(Class)aClass {
    static NSSet *blacklistedClasses = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray *_blacklistedViewControllerClassNames = @[
          @"SFBrowserRemoteViewController",
          @"SFSafariViewController",
          @"UIAlertController",
          @"UIInputWindowController",
          @"UINavigationController",
          @"UIKeyboardCandidateGridCollectionViewController",
          @"UICompatibilityInputViewController",
          @"UIApplicationRotationFollowingController",
          @"UIApplicationRotationFollowingControllerNoTouches",
          @"AVPlayerViewController",
          @"UIActivityGroupViewController",
          @"UIReferenceLibraryViewController",
          @"UIKeyboardCandidateRowViewController",
          @"UIKeyboardHiddenViewController",
          @"_UIAlertControllerTextFieldViewController",
          @"_UILongDefinitionViewController",
          @"_UIResilientRemoteViewContainerViewController",
          @"_UIShareExtensionRemoteViewController",
          @"_UIRemoteDictionaryViewController",
          @"UISystemKeyboardDockController",
          @"_UINoDefinitionViewController",
          @"UIImagePickerController",
          @"_UIActivityGroupListViewController",
          @"_UIRemoteViewController",
          @"_UIFallbackPresentationViewController",
          @"_UIDocumentPickerRemoteViewController",
          @"_UIAlertShimPresentingViewController",
          @"_UIWaitingForRemoteViewContainerViewController",
          @"UIDocumentMenuViewController",
          @"UIActivityViewController",
          @"_UIActivityUserDefaultsViewController",
          @"_UIActivityViewControllerContentController",
          @"_UIRemoteInputViewController",
          @"UIViewController",
          @"UITableViewController",
          @"_UIUserDefaultsActivityNavigationController",
          @"UISnapshotModalViewController",
          @"WKActionSheet",
          @"DDSafariViewController",
          @"SFAirDropActivityViewController",
          @"CKSMSComposeController",
          @"DDParsecLoadingViewController",
          @"PLUIPrivacyViewController",
          @"PLUICameraViewController",
          @"SLRemoteComposeViewController",
          @"CAMViewfinderViewController",
          @"DDParsecNoDataViewController",
          @"CAMPreviewViewController",
          @"DDParsecCollectionViewController",
          @"SLComposeViewController",
          @"DDParsecRemoteCollectionViewController",
          @"AVFullScreenPlaybackControlsViewController",
          @"PLPhotoTileViewController",
          @"AVFullScreenViewController",
          @"CAMImagePickerCameraViewController",
          @"CKSMSComposeRemoteViewController",
          @"PUPhotoPickerHostViewController",
          @"PUUIAlbumListViewController",
          @"PUUIPhotosAlbumViewController",
          @"SFAppAutoFillPasswordViewController",
          @"PUUIMomentsGridViewController",
          @"SFPasswordRemoteViewController",
          ];
        NSMutableSet *transformedClasses = [NSMutableSet setWithCapacity:_blacklistedViewControllerClassNames.count];
        for (NSString *className in _blacklistedViewControllerClassNames) {
            if (NSClassFromString(className) != nil) {
                [transformedClasses addObject:NSClassFromString(className)];
            }
        }
        blacklistedClasses = [transformedClasses copy];
    });
    
    return ![blacklistedClasses containsObject:aClass];
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
    if (![self shouldTrackClass:klass]) {
        return;
    }
    
    if ([controller isKindOfClass:NSClassFromString(@"UINavigationController")] ||
        [controller isKindOfClass:NSClassFromString(@"UITabBarController")]) {
        return;
    }
    
    if (_ignoredViewControllers != nil && _ignoredViewControllers.count > 0) {
        if ([_ignoredViewControllers containsObject:screenName]) {
            return;
        }
    }
    
    if (_autoTrackEventType & ThinkingAnalyticsEventTypeAppClick) {
#ifndef THINKING_ANALYTICS_DISABLE_AUTOTRACK_UITABLEVIEW
        void (^tableViewBlock)(id, SEL, id, id) = ^(id view, SEL command, UITableView *tableView, NSIndexPath *indexPath) {
            [TDAutoTrackUtils trackAppClickWithUITableView:tableView didSelectRowAtIndexPath:indexPath];
        };
        if ([controller respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
            [TDSwizzler swizzleSelector:@selector(tableView:didSelectRowAtIndexPath:) onClass:klass withBlock:tableViewBlock named:[NSString stringWithFormat:@"%@_%@", screenName, @"UITableView_AutoTrack"]];
        }
#endif

#ifndef THINKING_ANALYTICS_DISABLE_AUTOTRACK_UICOLLECTIONVIEW
        void (^collectionViewBlock)(id, SEL, id, id) = ^(id view, SEL command, UICollectionView *collectionView, NSIndexPath *indexPath) {
            [TDAutoTrackUtils trackAppClickWithUICollectionView:collectionView didSelectItemAtIndexPath:indexPath];
        };
        if ([controller respondsToSelector:@selector(collectionView:didSelectItemAtIndexPath:)]) {
            [TDSwizzler swizzleSelector:@selector(collectionView:didSelectItemAtIndexPath:) onClass:klass withBlock:collectionViewBlock named:[NSString stringWithFormat:@"%@_%@", screenName, @"UICollectionView_AutoTrack"]];
        }
#endif
    }

    if (!(_autoTrackEventType & ThinkingAnalyticsEventTypeAppViewScreen)) {
        return;
    }

    NSMutableDictionary *properties = [[NSMutableDictionary alloc] init];
    [properties setValue:NSStringFromClass(klass) forKey:SCREEN_NAME_PROPERTY];

    @try {
        NSString *controllerTitle = controller.navigationItem.title;
        if (controllerTitle != nil) {
            [properties setValue:controllerTitle forKey:@"#title"];
        }

        NSString *elementContent = [self getUIViewControllerTitle:controller];
        if (elementContent != nil && [elementContent length] > 0) {
            elementContent = [elementContent substringWithRange:NSMakeRange(0,[elementContent length] - 1)];
            [properties setValue:elementContent forKey:@"#title"];
        }
    } @catch (NSException *exception) {
        TDSDKError(@"%@ failed to get UIViewController's title error: %@", self, exception);
    }

    if ([controller conformsToProtocol:@protocol(TDAutoTracker)]) {
        UIViewController<TDAutoTracker> *autoTrackerController = (UIViewController<TDAutoTracker> *)controller;
        NSDictionary *dic = [autoTrackerController getTrackProperties];
        if(dic && [self checkProperties:dic])
        {
            [properties addEntriesFromDictionary:dic];
            _lastScreenTrackProperties = [autoTrackerController getTrackProperties];
        }
    }
    
#ifdef THINKING_ANALYTICS_AUTOTRACT_APPVIEWSCREEN_URL
    [properties setValue:screenName forKey:SCREEN_URL_PROPERTY];
    @synchronized(_referrerScreenUrl) {
        if (_referrerScreenUrl) {
            [properties setValue:_referrerScreenUrl forKey:SCREEN_REFERRER_URL_PROPERTY];
        }
        _referrerScreenUrl = screenName;
    }
#endif

    if ([controller conformsToProtocol:@protocol(TDScreenAutoTracker)]) {
        UIViewController<TDScreenAutoTracker> *screenAutoTrackerController = (UIViewController<TDScreenAutoTracker> *)controller;
        NSString *currentScreenUrl = [screenAutoTrackerController getScreenUrl];

        [properties setValue:currentScreenUrl forKey:SCREEN_URL_PROPERTY];
        @synchronized(_referrerScreenUrl) {
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
    if ([NSThread isMainThread]) {
        @try {
            UIViewController *rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
            if (rootViewController != nil) {
                currentVC = [self getCurrentVCFrom:rootViewController];
            }
        } @catch (NSException *exception) {
            TDSDKError(@"%@ error: %@", self, exception);
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
                TDSDKError(@"%@ error: %@", self, exception);
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
        TDSDKError(@"%@ error: %@", self, exception);
    }
}

@end

@implementation UIView (ThinkingAnalytics)
- (UIViewController *)viewController {
    UIResponder *next = [self nextResponder];
    do {
        if ([next isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)next;
        }
        next = [next nextResponder];
    } while (next != nil);
    return nil;
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

- (BOOL)thinkingAnalyticsAutoTrackAfterSendAction {
    return [objc_getAssociatedObject(self, @"thinkingAnalyticsAutoTrackAfterSendAction") boolValue];
}

- (void)setThinkingAnalyticsAutoTrackAfterSendAction:(BOOL)thinkingAnalyticsAutoTrackAfterSendAction {
    objc_setAssociatedObject(self, @"thinkingAnalyticsAutoTrackAfterSendAction", [NSNumber numberWithBool:thinkingAnalyticsAutoTrackAfterSendAction], OBJC_ASSOCIATION_ASSIGN);
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

@implementation UIImage (ThinkingAnalytics)
- (NSString *)thinkingAnalyticsImageName {
    return objc_getAssociatedObject(self, @"thinkingAnalyticsImageName");
}

- (void)setThinkingAnalyticsImageName:(NSString *)thinkingAnalyticsImageName {
    objc_setAssociatedObject(self, @"thinkingAnalyticsImageName", thinkingAnalyticsImageName, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
@end
