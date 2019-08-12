#import "TDFlushConfig.h"

@interface TDFlushConfig ()

@property (atomic, copy) NSString *appid;
@property (atomic, copy) NSString *configureURL;

@end

@implementation TDFlushConfig

+ (TDFlushConfig *)sharedManagerWithAppid:(NSString *)appid withServerURL:(NSString *)url {
    static dispatch_once_t onceToken;
    static TDFlushConfig *manager;
    dispatch_once(&onceToken, ^{
        manager = [[TDFlushConfig alloc] initWithAppid:appid withServerURL:url];
    });
    return manager;
}

- (instancetype)initWithAppid:(NSString *)appid withServerURL:(NSString *)url {
    self = [super init];
    if (self) {
        _appid = appid;
        _configureURL = [NSString stringWithFormat:@"%@/config", url];
        _networkTypePolicy = ThinkingNetworkType3G | ThinkingNetworkType4G | ThinkingNetworkTypeWIFI;
        [self getBatchSizeAndInterval];
        [self updateFlushConfig];
    }
    return self;
}

- (void)setNetworkType:(ThinkingAnalyticsNetworkType)type
{
    if (type == TDNetworkTypeDefault) {
        _networkTypePolicy = ThinkingNetworkTypeWIFI | ThinkingNetworkType3G | ThinkingNetworkType4G;
    } else if (type == TDNetworkTypeOnlyWIFI) {
        _networkTypePolicy = ThinkingNetworkTypeWIFI;
    } else if (type == TDNetworkTypeALL) {
        _networkTypePolicy = ThinkingNetworkTypeWIFI | ThinkingNetworkType3G | ThinkingNetworkType4G | ThinkingNetworkType2G;
    }
}

-(void)getBatchSizeAndInterval
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger interval = [userDefaults integerForKey:@"thinkingdata_uploadInterval"];
    if (interval <= 0) {
        self.uploadInterval = 60;
    } else {
        self.uploadInterval = interval;
    }
    NSInteger size = [userDefaults integerForKey:@"thinkingdata_uploadSize"];
    if (size <= 0) {
        self.uploadSize = 100;
    } else {
        self.uploadSize = size;
    }
}

- (void)updateFlushConfig {
    void (^block)(NSData*, NSURLResponse*, NSError*) = ^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error || ![response isKindOfClass:[NSHTTPURLResponse class]]) {
            TDLogDebug(@"updateBatchSizeAndInterval network failure:%@",error);
            return;
        }
        NSError *err;
        NSDictionary *ret = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&err];
        if (!err && [ret isKindOfClass:[NSDictionary class]] && [ret[@"code"] isEqualToNumber:[NSNumber numberWithInt:0]])
        {
            NSDictionary *dic = [[ret copy] objectForKey:@"data"];
            NSInteger sync_interval = [[[dic copy] objectForKey:@"sync_interval"] unsignedIntegerValue];
            NSInteger sync_batch_size = [[[dic copy] objectForKey:@"sync_batch_size"] unsignedIntegerValue];
            BOOL restart = NO;
            if ((sync_interval != self->_uploadInterval && sync_interval > 0) || (sync_batch_size != self->_uploadSize && sync_batch_size > 0)) {
                restart = YES;
            }
            if (sync_interval != self->_uploadInterval && sync_interval > 0) {
                self->_uploadInterval = sync_interval;
                [[NSUserDefaults standardUserDefaults] setInteger:sync_interval forKey:@"thinkingdata_uploadInterval"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            if (sync_batch_size != self->_uploadSize && sync_batch_size > 0) {
                self->_uploadSize = sync_batch_size;
                [[NSUserDefaults standardUserDefaults] setInteger:sync_batch_size forKey:@"thinkingdata_uploadSize"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            TDLogDebug(@"uploadBatchSize:%d Interval:%d", sync_batch_size, sync_interval);
            if (restart) {
                [ThinkingAnalyticsSDK restartFlushTimer];
            }
        } else if ([[ret objectForKey:@"code"] isEqualToNumber:[NSNumber numberWithInt:-2]]) {
            TDLogError(@"APPID is wrong");
        } else {
            TDLogError(@"updateBatchSizeAndInterval failed");
        }
        TDLogDebug(@"BatchSize:%d Interval:%d", self->_uploadSize, self->_uploadInterval);
    };
    NSString *urlStr = [NSString stringWithFormat:@"%@?appid=%@", self.configureURL, self.appid];
    NSURL *URL = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    [request setHTTPMethod:@"Get"];
    NSURLSession * session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:block];
    [task resume];
}

@end
