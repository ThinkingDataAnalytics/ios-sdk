#import "TDNetwork.h"

#import "NSData+TDGzip.h"
#import "TDJSONUtil.h"
#import "TDLogging.h"
#import "TDToastView.h"

@implementation TDNetwork

+ (NSURLSession *)sharedURLSession {
    static NSURLSession *sharedSession = nil;
    @synchronized(self) {
        if (sharedSession == nil) {
            NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
            sharedSession = [NSURLSession sessionWithConfiguration:sessionConfig];
        }
    }
    return sharedSession;
}

- (NSString *)URLEncode:(NSString *)string {
    return [string stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
}

- (int)flushDebugEvents:(NSDictionary *)record withAppid:(NSString *)appid {
    __block int debugResult = -1;
    NSMutableDictionary *recordDic = [record mutableCopy];
    NSMutableDictionary *properties = [[recordDic objectForKey:@"properties"] mutableCopy];
    [properties addEntriesFromDictionary:self.automaticData];
    [recordDic setObject:properties forKey:@"properties"];
    NSString *jsonString = [TDJSONUtil JSONStringForObject:recordDic];
    NSMutableURLRequest *request = [self buildDebugRequestWithJSONString:jsonString withAppid:appid withDeviceId:[properties objectForKey:@"#device_id"]];
    dispatch_semaphore_t flushSem = dispatch_semaphore_create(0);

    void (^block)(NSData *, NSURLResponse *, NSError *) = ^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error || ![response isKindOfClass:[NSHTTPURLResponse class]]) {
            debugResult = -2;
            TDLogError(@"Debug Networking error");
            dispatch_semaphore_signal(flushSem);
            return;
        }

        NSHTTPURLResponse *urlResponse = (NSHTTPURLResponse *)response;
        if ([urlResponse statusCode] == 200) {
            NSError *err;
            NSDictionary *retDic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&err];
            if (err) {
                TDLogError(@"Debug data error:%@", err);
                debugResult = -2;
            } else if ([[retDic objectForKey:@"errorLevel"] isEqualToNumber:[NSNumber numberWithInt:1]] || [[retDic objectForKey:@"errorLevel"] isEqualToNumber:[NSNumber numberWithInt:2]]) {
                TDLogError(@"Debug data error:%@", [retDic objectForKey:@"errorReasons"]);
                [NSException raise:@"Debug data error" format:@"errorReasons: %@", [retDic objectForKey:@"errorReasons"]];
            } else if ([[retDic objectForKey:@"errorLevel"] isEqualToNumber:[NSNumber numberWithInt:0]]) {
                debugResult = 0;
                TDLogDebug(@"Verify data success.");
            } else if ([[retDic objectForKey:@"errorLevel"] isEqualToNumber:[NSNumber numberWithInt:-1]]) {
                debugResult = -1;
                TDLogDebug(@"Debug mode forced degrade.");
            }
            
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                if (debugResult == 0 || debugResult == 1 || debugResult == 2) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIWindow *window = [UIApplication sharedApplication].keyWindow;
                        [TDToastView showInWindow:window text:[NSString stringWithFormat:@"当前模式为:%@", self.debugMode == ThinkingAnalyticsDebugOnly ? @"DebugOnly(数据不入库)" : @"Debug"] duration:2.0];
                    });
                }
            });
        } else {
            debugResult = -2;
            NSString *urlResponse = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            TDLogError(@"%@", [NSString stringWithFormat:@"Debug %@ network failure with response '%@'.", self, urlResponse]);
        }
        dispatch_semaphore_signal(flushSem);
    };

    NSURLSessionDataTask *task = [[TDNetwork sharedURLSession] dataTaskWithRequest:request completionHandler:block];
    [task resume];

    dispatch_semaphore_wait(flushSem, DISPATCH_TIME_FOREVER);
    return debugResult;
}

- (BOOL)flushEvents:(NSArray<NSDictionary *> *)recordArray {
    __block BOOL flushSucc = YES;
    
    NSDictionary *flushDic = @{
                    @"data": recordArray,
                    @"automaticData": self.automaticData,
                    @"#app_id": self.appid,
                    };
    
    NSString *jsonString = [TDJSONUtil JSONStringForObject:flushDic];
    NSMutableURLRequest *request = [self buildRequestWithJSONString:jsonString];
    dispatch_semaphore_t flushSem = dispatch_semaphore_create(0);

    void (^block)(NSData *, NSURLResponse *, NSError *) = ^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error || ![response isKindOfClass:[NSHTTPURLResponse class]]) {
            flushSucc = NO;
            TDLogError(@"Networking error");
            dispatch_semaphore_signal(flushSem);
            return;
        }

        NSHTTPURLResponse *urlResponse = (NSHTTPURLResponse *)response;
        if ([urlResponse statusCode] == 200) {
            flushSucc = YES;
            TDLogDebug(@"flush success. ret :%@, data :%@", [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil], flushDic);
        } else {
            flushSucc = NO;
            NSString *urlResponse = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            TDLogError(@"%@", [NSString stringWithFormat:@"%@ network failure with response '%@'.", self, urlResponse]);
        }

        dispatch_semaphore_signal(flushSem);
    };

    NSURLSessionDataTask *task = [[TDNetwork sharedURLSession] dataTaskWithRequest:request completionHandler:block];
    [task resume];

    dispatch_semaphore_wait(flushSem, DISPATCH_TIME_FOREVER);
    return flushSucc;
}

- (NSMutableURLRequest *)buildRequestWithJSONString:(NSString *)jsonString {
    NSData *zippedData = [NSData gzipData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    NSString *postBody = [zippedData base64EncodedStringWithOptions:0];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.serverURL];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[postBody dataUsingEncoding:NSUTF8StringEncoding]];
    NSString *contentType = [NSString stringWithFormat:@"text/plain"];
    [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
    [request setTimeoutInterval:60.0];
    return request;
}

- (NSMutableURLRequest *)buildDebugRequestWithJSONString:(NSString *)jsonString withAppid:(NSString *)appid withDeviceId:(NSString *)deviceId {
    // dryRun=0，如果校验通过就会入库。 dryRun=1，不会入库
    int dryRun = 0;
    if (_debugMode == ThinkingAnalyticsDebugOnly) {
        dryRun = 1;
    } else if (_debugMode == ThinkingAnalyticsDebug) {
        dryRun = 0;
    }
    NSString *postData = [NSString stringWithFormat:@"appid=%@&source=client&dryRun=%d&deviceId=%@&data=%@", appid, dryRun, deviceId, [self URLEncode:jsonString]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.serverDebugURL];
    [request setHTTPMethod:@"POST"];
    request.HTTPBody = [postData dataUsingEncoding:NSUTF8StringEncoding];
    return request;
}

- (void)fetchFlushConfig:(NSString *)appid handler:(TDFlushConfigBlock)handler {
    void (^block)(NSData *, NSURLResponse *, NSError *) = ^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error || ![response isKindOfClass:[NSHTTPURLResponse class]]) {
            TDLogDebug(@"updateBatchSizeAndInterval network failure:%@",error);
            return;
        }
        NSError *err;
        NSDictionary *ret = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&err];
        if (err) {
            TDLogError(@"update batchSize interval failed:%@", err);
        } else if ([ret isKindOfClass:[NSDictionary class]] && [ret[@"code"] isEqualToNumber:[NSNumber numberWithInt:0]]) {
            handler([ret objectForKey:@"data"], error);
        } else if ([[ret objectForKey:@"code"] isEqualToNumber:[NSNumber numberWithInt:-2]]) {
            TDLogError(@"APPID is wrong.");
        } else {
            TDLogError(@"update batchSize interval failed");
        }
    };
    NSString *urlStr = [NSString stringWithFormat:@"%@?appid=%@", self.serverURL, appid];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    [request setHTTPMethod:@"Get"];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:block];
    [task resume];
}

@end
