//
//  ViewController.m
//  iosPerformenceTestDemo
//
//  Created by xiayuwei on 2023/1/11.
//

#import "ViewController.h"
#import <ThinkingSDK/ThinkingAnalyticsSDK.h>
//#import "MoonLight.h"

ThinkingAnalyticsSDK *ins2;
//MoonLight *_moonLight;
NSDictionary *dic;
NSMutableDictionary *performenceData;
NSMutableArray *performenceDataArray;


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSMutableArray *arr1 = [NSMutableArray array];
      NSMutableArray *arr2 = [NSMutableArray array];
      [arr1 addObject:arr2];
      [arr2 addObject:arr1];
    
    NSError *error;
    dic = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:&error];
    performenceDataArray = [[NSMutableArray alloc]init];
    [ThinkingAnalyticsSDK setLogLevel:TDLoggingLevelDebug];
    // Do any additional setup after loading the view.
    [self single_loop_all_api];
//    [self multi_loop_all_api];
//    [self single_loop_track_api];
//    [self multi_loop_track_api];
    
}

// 单个线程轮询所有接口

- (void)single_loop_all_api {
//    _moonLight = [[MoonLight alloc]initWithDelegate:self timeInterval:5];
//    [_moonLight startTimer];
    NSTimeInterval intervalStart = [[NSDate date] timeIntervalSince1970] * 1000;
    NSLog(@"intervalStart:%f", intervalStart);
    NSString *appid1 = @"a746c9f48aae46f69ecb71e0ea4c301b";
    NSString *url1 = @"https://receiver-ta-preview.thinkingdata.cn";
    TDConfig *config1 = [TDConfig new];
    config1.appid = appid1;
    config1.configureURL = url1;
//    config1.debugMode = ThinkingAnalyticsDebug;
    ThinkingAnalyticsSDK *ins1 = [ThinkingAnalyticsSDK startWithConfig:config1];
    
    NSString *event_name = @"MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKC";
    NSString *properties_name = @"MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKC";
    
    dispatch_queue_t queue = dispatch_queue_create("queue", DISPATCH_QUEUE_SERIAL);
    dispatch_async(queue, ^{
        NSTimeInterval interval = [[NSDate date] timeIntervalSince1970] * 1000;
        while ((interval - intervalStart) < 600000*3) {
            interval = [[NSDate date] timeIntervalSince1970] * 1000;

            [ins1 identify:@"pressureTest"];
            [ins1 getDistinctId];
            [ins1 login:@"pressureTestUser"];
            [ins1 logout];
            [ins1 login:@"pressureTestUser"];
            [ins1 setSuperProperties:@{@"Channel": @"ABC", @"isTest": @YES}];
            [ins1 track:event_name properties:@{properties_name: [self random:2048]}];
            [ins1 unsetSuperProperty:@"isTest"];
            [ins1 clearSuperProperties];
            [ins1 currentSuperProperties];
            [ins1 timeEvent:@"product_view"];
            [ins1 track:event_name properties:@{properties_name: [self random:2048]}];
            [ins1 user_set:@{properties_name: [self random:2048]}];
            [ins1 user_setOnce:@{properties_name: [self random:2048]}];
            [ins1 user_add:@{@"TotalRevenue": @1}];
            [ins1 user_unset:properties_name];
            [ins1 user_delete];
            [ins1 getPresetProperties];
            [ins1 user_append:@{properties_name: @[[self random:2048]]}];
            [ins1 user_uniqAppend:@{properties_name: @[[self random:2048]]}];
            [ins1 getDeviceId];
            [NSThread sleepForTimeInterval:0.5];
        }
//        [_moonLight stopTimer];
        NSLog(@"test_over");
        NSLog(@"interval:%f", interval);
        NSLog(@"性能数据 %@", performenceDataArray);
        [self sendPerformenceData:performenceDataArray command:@"single_loop_all_api"];

     });
}

// 多个线程轮询所有接口
-(void)multi_loop_all_api
{
    NSInteger threadNum = 10;
//    _moonLight = [[MoonLight alloc]initWithDelegate:self timeInterval:5];
//    [_moonLight startTimer];
    NSTimeInterval intervalStart = [[NSDate date] timeIntervalSince1970] * 1000;
    NSLog(@"intervalStart:%f", intervalStart);
    NSString *appid1 = @"a746c9f48aae46f69ecb71e0ea4c301b";
    NSString *url1 = @"https://receiver-ta-preview.thinkingdata.cn";
    TDConfig *config1 = [TDConfig new];
    config1.appid = appid1;
    config1.configureURL = url1;
    config1.debugMode = ThinkingAnalyticsDebug;
    ThinkingAnalyticsSDK *ins1 = [ThinkingAnalyticsSDK startWithConfig:config1];
    NSMutableArray *thread_list = [[NSMutableArray alloc]init];

    for (int i = 0; i < threadNum; i++){
        NSString *name = [@"线程" stringByAppendingString: [NSString stringWithFormat:@"%d",i]];
        NSThread  *thread = [[NSThread alloc]initWithTarget:self selector:@selector(loop_all_api:) object:name];
        //为线程设置一个名称
        [thread_list addObject:thread];
        thread.name=name;
        //开启线程
        [thread start];
    }

// 阻塞当前线程，判断线程是否全部执行完毕，否则一直循环等待
    for(int j = 0; j < threadNum; j++) {
        id thread = [[NSThread alloc]init];
        thread = [thread_list objectAtIndex:j];
        NSLog(@"%d", [thread isFinished]);
        while(![thread isFinished]){
            NSLog(@"no finish");
            [NSThread sleepForTimeInterval:10];
        }
        
    }
    NSLog(@"test_over");

//    [_moonLight stopTimer];

    NSLog(@"性能数据 %@", performenceDataArray);
    [self sendPerformenceData:performenceDataArray command:@"multi_loop_all_api"];

}

-(void)loop_all_api:(NSString *)str
{
    NSThread *current=[NSThread currentThread];
    NSLog(@"run---%@---%@",current,str);
    NSString *event_name = @"MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKC";
    NSString *properties_name = @"MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKC";
    NSTimeInterval intervalStart = [[NSDate date] timeIntervalSince1970] * 1000;
    NSTimeInterval interval = [[NSDate date] timeIntervalSince1970] * 1000;
    while ((interval - intervalStart) < 600000*3) {
        interval = [[NSDate date] timeIntervalSince1970] * 1000;

        [[ThinkingAnalyticsSDK sharedInstance] identify:@"pressureTest"];
        [[ThinkingAnalyticsSDK sharedInstance] getDistinctId];
        [[ThinkingAnalyticsSDK sharedInstance] login:@"pressureTestUser"];
        [[ThinkingAnalyticsSDK sharedInstance] logout];
        [[ThinkingAnalyticsSDK sharedInstance] login:@"pressureTestUser"];
        [[ThinkingAnalyticsSDK sharedInstance] setSuperProperties:@{@"Channel": @"ABC", @"isTest": @YES}];
        [[ThinkingAnalyticsSDK sharedInstance] track:event_name properties:@{properties_name: [self random:2048]}];
        [[ThinkingAnalyticsSDK sharedInstance] unsetSuperProperty:@"isTest"];
        [[ThinkingAnalyticsSDK sharedInstance] clearSuperProperties];
        [[ThinkingAnalyticsSDK sharedInstance] currentSuperProperties];
        [[ThinkingAnalyticsSDK sharedInstance] timeEvent:@"product_view"];
        [[ThinkingAnalyticsSDK sharedInstance] track:event_name properties:@{properties_name: [self random:2048]}];
        [[ThinkingAnalyticsSDK sharedInstance] user_set:@{properties_name: [self random:2048]}];
        [[ThinkingAnalyticsSDK sharedInstance] user_setOnce:@{properties_name: [self random:2048]}];
        [[ThinkingAnalyticsSDK sharedInstance] user_add:@{@"TotalRevenue": @1}];
        [[ThinkingAnalyticsSDK sharedInstance] user_unset:properties_name];
        [[ThinkingAnalyticsSDK sharedInstance] user_delete];
        [[ThinkingAnalyticsSDK sharedInstance] getPresetProperties];
        [[ThinkingAnalyticsSDK sharedInstance] user_append:@{properties_name: @[[self random:2048]]}];
        [[ThinkingAnalyticsSDK sharedInstance] user_uniqAppend:@{properties_name: @[[self random:2048]]}];
        [[ThinkingAnalyticsSDK sharedInstance] getDeviceId];
        [NSThread sleepForTimeInterval:0.5];
    }
}

-(void)loop_track_api:(NSString *)str
{
    NSThread *current=[NSThread currentThread];
    NSLog(@"run---%@---%@",current,str);
    NSString *event_name = @"MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKC";
    NSString *properties_name = @"MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKC";
    NSTimeInterval intervalStart = [[NSDate date] timeIntervalSince1970] * 1000;
    NSTimeInterval interval = [[NSDate date] timeIntervalSince1970] * 1000;
    while ((interval - intervalStart) < 600000*3) {
        interval = [[NSDate date] timeIntervalSince1970] * 1000;
        [[ThinkingAnalyticsSDK sharedInstance] track:event_name properties:@{properties_name: [self random:2048]}];
        [NSThread sleepForTimeInterval:0.5];
    }
}

//单线程一直track事件
-(void)single_loop_track_api
{
//    _moonLight = [[MoonLight alloc]initWithDelegate:self timeInterval:5];
//    [_moonLight startTimer];
    NSTimeInterval intervalStart = [[NSDate date] timeIntervalSince1970] * 1000;
    NSLog(@"intervalStart:%f", intervalStart);
    NSString *appid1 = @"a746c9f48aae46f69ecb71e0ea4c301b";
    NSString *url1 = @"https://receiver-ta-preview.thinkingdata.cn";
    TDConfig *config1 = [TDConfig new];
    config1.appid = appid1;
    config1.configureURL = url1;
//    config1.debugMode = ThinkingAnalyticsDebug;
    ThinkingAnalyticsSDK *ins1 = [ThinkingAnalyticsSDK startWithConfig:config1];
    
    NSString *event_name = @"MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKC";
    NSString *properties_name = @"MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKC";
    
    dispatch_queue_t queue = dispatch_queue_create("queue", DISPATCH_QUEUE_SERIAL);
    dispatch_async(queue, ^{
        NSTimeInterval interval = [[NSDate date] timeIntervalSince1970] * 1000;
        while ((interval - intervalStart) < 600000*3) {
            interval = [[NSDate date] timeIntervalSince1970] * 1000;
            [ins1 track:event_name properties:@{properties_name: [self random:2048]}];
            [NSThread sleepForTimeInterval:0.5];
        }
//        [_moonLight stopTimer];
        NSLog(@"test_over");
        NSLog(@"interval:%f", interval);
        NSLog(@"性能数据 %@", performenceDataArray);
        [self sendPerformenceData:performenceDataArray command:@"single_loop_track_api"];

     });
}

// 多个线程轮询track接口
-(void)multi_loop_track_api
{
    NSInteger threadNum = 10;
//    _moonLight = [[MoonLight alloc]initWithDelegate:self timeInterval:5];
//    [_moonLight startTimer];
    NSTimeInterval intervalStart = [[NSDate date] timeIntervalSince1970] * 1000;
    NSLog(@"intervalStart:%f", intervalStart);
    NSString *appid1 = @"a746c9f48aae46f69ecb71e0ea4c301b";
    NSString *url1 = @"https://receiver-ta-preview.thinkingdata.cn";
    TDConfig *config1 = [TDConfig new];
    config1.appid = appid1;
    config1.configureURL = url1;
    config1.debugMode = ThinkingAnalyticsDebug;
    ThinkingAnalyticsSDK *ins1 = [ThinkingAnalyticsSDK startWithConfig:config1];
    NSMutableArray *thread_list = [[NSMutableArray alloc]init];

    for (int i = 0; i < threadNum; i++){
        NSString *name = [@"线程" stringByAppendingString: [NSString stringWithFormat:@"%d",i]];
        NSThread  *thread = [[NSThread alloc]initWithTarget:self selector:@selector(loop_track_api:) object:name];
        //为线程设置一个名称
        [thread_list addObject:thread];
        thread.name=name;
        //开启线程
        [thread start];
    }

// 阻塞当前线程，判断线程是否全部执行完毕，否则一直循环等待
    for(int j = 0; j < threadNum; j++) {
        id thread = [[NSThread alloc]init];
        thread = [thread_list objectAtIndex:j];
        NSLog(@"%d", [thread isFinished]);
        while(![thread isFinished]){
            NSLog(@"no finish");
            [NSThread sleepForTimeInterval:10];
        }
        
    }
    NSLog(@"test_over");

//    [_moonLight stopTimer];

    NSLog(@"性能数据 %@", performenceDataArray);
    [self sendPerformenceData:performenceDataArray command:@"multi_loop_track_api"];

}

- (void)captureOutputAppCPU:(float)appCPU systemCPU:(float)systemCPU appMemory:(float)appMemory gpuUsage:(float)gpuUsage gpuInfo:(NSString *)gpuInfo {
    NSLog(@"appMemory:%f", appMemory);
    NSLog(@"appCPU:%f", appCPU);
    NSLog(@"systemCPU:%f", systemCPU);
    CGFloat SystemFreeSize = 0.0;
    NSNumber *number = [dic objectForKey:NSFileSystemFreeSize];
    SystemFreeSize = [number floatValue] * 1.0/1024.0/1024.0/1024.0;
    NSLog(@"SystemFreeSize:%f", SystemFreeSize);
    performenceData = [NSMutableDictionary dictionary];
    [performenceData setValue:[NSNumber numberWithFloat:appMemory] forKey:@"appMemory"];
    [performenceData setValue:[NSNumber numberWithFloat:appCPU] forKey:@"appCPU"];
    [performenceData setValue:[NSNumber numberWithFloat:systemCPU] forKey:@"systemCPU"];
    [performenceData setValue:[NSNumber numberWithFloat:SystemFreeSize] forKey:@"SystemFreeSize"];

    [performenceDataArray addObject:performenceData];

}

// 将数据上报给性能报告平台后端

- (void)sendPerformenceData:(NSMutableArray*)data command:(NSString*)command{

    
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://10.208.202.53:8080/thinkingdata/sdk/send_performence_data"]
      cachePolicy:NSURLRequestUseProtocolCachePolicy
      timeoutInterval:10.0];
    NSDictionary *headers = @{
      @"Content-Type": @"application/json"
    };
    NSMutableDictionary *performenceData = [[NSMutableDictionary alloc]init];
    [performenceData setValue:[ThinkingAnalyticsSDK getSDKVersion] forKey:@"version"];
    [performenceData setValue:@"iOS" forKey:@"platform"];
    [performenceData setValue:command forKey:@"command"];
    [performenceData setValue:data forKey:@"data"];
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:performenceData
                                                           options:kNilOptions
                                                             error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData
                                                     encoding:NSUTF8StringEncoding];
    [request setAllHTTPHeaderFields:headers];
    NSData *postData = [[NSData alloc] initWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:postData];

    [request setHTTPMethod:@"POST"];

    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
      if (error) {
        NSLog(@"%@", error);
        dispatch_semaphore_signal(sema);
      } else {
          NSString *strdata = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];

          NSLog(@"%@",strdata);

//        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
//        NSError *parseError = nil;
//        NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
//        NSLog(@"%@",responseDictionary);
//        dispatch_semaphore_signal(sema);
      }
    }];
    [dataTask resume];
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
}

- (NSString *)random: (int)len {
    
    char ch[len];
    for (int index=0; index<len; index++) {
        
        int num = arc4random_uniform(75)+48;
        if (num>57 && num<65) { num = num%57+48; }
        else if (num>90 && num<97) { num = num%90+65; }
        ch[index] = num;
    }
    
    return [[NSString alloc] initWithBytes:ch length:len encoding:NSUTF8StringEncoding];
}

@end
