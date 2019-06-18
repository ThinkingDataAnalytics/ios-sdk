#import "TDNetwork.h"
#import "ThinkingAnalyticsSDKPrivate.h"
#import "NSData+TDGzip.h"

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

- (instancetype)initWithServerURL:(NSURL *)serverURL withAutomaticData:(NSDictionary *)automaticData {
    self = [super init];
    if (self) {
        self.serverURL = serverURL;
        self.automaticData = automaticData;
    }
    return self;
}

- (BOOL)flushEvents:(NSArray<NSString *> *)recordArray withAppid:(NSString *)appid {
    __block BOOL flushSucc = YES;
    
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
                            @"automaticData": self.automaticData,
                            @"#app_id": appid,
                            };

        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:e options:kNilOptions error:nil];
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

    } @catch (NSException *exception) {
        return NO;
    }
    
    NSMutableURLRequest *request = [self buildFlushRequestWithJSONString:jsonString];
    dispatch_semaphore_t flushSem = dispatch_semaphore_create(0);

    void (^block)(NSData*, NSURLResponse*, NSError*) = ^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error || ![response isKindOfClass:[NSHTTPURLResponse class]]) {
            flushSucc = NO;
            TDLogError(@"Networking error");
            dispatch_semaphore_signal(flushSem);
            return;
        }

        NSHTTPURLResponse *urlResponse = (NSHTTPURLResponse*)response;
        if([urlResponse statusCode] == 200) {
            flushSucc = YES;
            NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
            NSString *logingStr=[[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
            TDLogDebug(@"fluch success :%@", logingStr);
//            NSDictionary *ret = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        } else {
            flushSucc = NO;
            NSString *urlResponseContent = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSString *errMsg = [NSString stringWithFormat:@"%@ network failure with response '%@'.", self, urlResponseContent];
            TDLogError(@"%@", errMsg);
        }

        dispatch_semaphore_signal(flushSem);
    };

//    NSURLSession * session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [[TDNetwork sharedURLSession] dataTaskWithRequest:request completionHandler:block];
    [task resume];

    dispatch_semaphore_wait(flushSem, DISPATCH_TIME_FOREVER);
    return flushSucc;
}

- (NSMutableURLRequest *)buildFlushRequestWithJSONString:(NSString *)jsonString {
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

@end
