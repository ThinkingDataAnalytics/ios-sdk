#import "TDNetwork.h"

#import "NSData+TDGzip.h"
#import "TDJSONUtil.h"
#import "TDLogging.h"

@implementation TDNetwork

+ (NSURLSession *)sharedURLSession
{
    static NSURLSession *sharedSession = nil;
    @synchronized(self) {
        if (sharedSession == nil) {
            NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
            sharedSession = [NSURLSession sessionWithConfiguration:sessionConfig];
        }
    }
    return sharedSession;
}

- (instancetype)initWithServerURL:(NSURL *)serverURL {
    self = [super init];
    if (self) {
        self.serverURL = serverURL;
    }
    return self;
}

- (BOOL)flushEvents:(NSArray<NSDictionary *> *)recordArray withAppid:(NSString *)appid {
    __block BOOL flushSucc = YES;
    
    NSDictionary *flushDic = @{
                    @"data": recordArray,
                    @"automaticData": self.automaticData,
                    @"#app_id": appid,
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
            TDLogDebug(@"fluch success. ret :%@, data :%@", [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil], flushDic);
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

- (void)fetchFlushConfig:(NSString *)appid handler:(TDFlushConfigBlock)handler {
    void (^block)(NSData *, NSURLResponse *, NSError *) = ^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error || ![response isKindOfClass:[NSHTTPURLResponse class]]) {
            TDLogDebug(@"updateBatchSizeAndInterval network failure:%@",error);
            return;
        }
        NSError *err;
        NSDictionary *ret = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&err];
        if (!err && [ret isKindOfClass:[NSDictionary class]] && [ret[@"code"] isEqualToNumber:[NSNumber numberWithInt:0]]) {
            handler([[ret copy] objectForKey:@"data"], error);
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
