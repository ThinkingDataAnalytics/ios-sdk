#import "TDCalibratedTimeWithNTP.h"
#import "TDNTPServer.h"
#import "TDLogging.h"

@interface TDCalibratedTimeWithNTP() {
    dispatch_group_t _ntpGroup;
}
@end

@implementation TDCalibratedTimeWithNTP

@synthesize serverTime = _serverTime;

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] initWithNtpServerHost:nil];
    });
    return sharedInstance;
}

+ (instancetype)sharedInstanceWithNtpServerHost:(NSArray *)host {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] initWithNtpServerHost:host];
    });
    return sharedInstance;
}

- (instancetype)initWithNtpServerHost:(NSArray *)host {
    if (self = [super init]) {
        _ntpGroup = dispatch_group_create();
        NSString *queuelabel = [NSString stringWithFormat:@"cn.Thinkingdata.ntp.%p", (void *)self];
        dispatch_queue_t ntpSerialQueue = dispatch_queue_create([queuelabel UTF8String], DISPATCH_QUEUE_SERIAL);
        
        dispatch_group_async(_ntpGroup, ntpSerialQueue, ^{
            [self startNtp:host];
        });
    }
    return self;
}

- (NSTimeInterval)serverTime {
    long ret = dispatch_group_wait(_ntpGroup, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)));
    if (ret != 0) {
        self.stopCalibrate = YES;
    }
    return _serverTime;
}

- (void)startNtp:(NSArray *)ntpServerHost {
    NSMutableArray *serverHostArr = [NSMutableArray array];
    for (NSString *host in ntpServerHost) {
        if ([host isKindOfClass:[NSString class]] && host.length > 0) {
            [serverHostArr addObject:host];
        }
    }
    NSError *err;
    for (NSString *host in serverHostArr) {
        TDLogDebug(@"ntp host :%@", host);
        err = nil;
        TDNTPServer *server = [[TDNTPServer alloc] initWithHostname:host port:123];
        NSTimeInterval offset = [server dateWithError:&err];
        
        if (err) {
            TDLogDebug(@"ntp failed :%@", err);
        } else {
            self.systemUptime = [[NSProcessInfo processInfo] systemUptime];
            self.serverTime = [[NSDate dateWithTimeIntervalSinceNow:offset] timeIntervalSince1970];
            break;
        }
    }
    
    if (err) {
        TDLogDebug(@"get ntp time failed");
        self.stopCalibrate = YES;
    }
}

@end
