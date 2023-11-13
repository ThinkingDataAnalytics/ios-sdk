//
//  ViewController.m
//  ThinkingSDKMac
//
//  Created by yangxiong on 2022/6/21.
//

#import "ViewController.h"
#import "TAInitinalViewController.h"
#import <ThinkingSDK/ThinkingSDK.h>

@interface ViewController ()
@property (nonatomic, strong) NSWindowController *childWindowController;

@end

@implementation ViewController

// 读取本地JSON文件
+ (NSDictionary *)readLocalFile {
    NSString *name = @"property";
    // 获取文件路径
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"json"];
    // 将文件数据化
    NSData *data = [[NSData alloc] initWithContentsOfFile:path];
    // 对数据进行JSON格式化并返回字典形式
    return [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (ThinkingAnalyticsSDK *)getInstance {
    
    NSString *appid = @"c636fb93fb854ffd961a6eed5316410b";
    NSString *url = @"https://receiver-ta-dev.thinkingdata.cn";

    [ThinkingAnalyticsSDK setLogLevel:TDLoggingLevelDebug];

    TDConfig *config = [TDConfig new];
    config.appid = appid;
    config.configureURL = url;
    [ThinkingAnalyticsSDK startWithConfig:config];
    
    ThinkingAnalyticsSDK *instance = [ThinkingAnalyticsSDK sharedInstance];
    if (!instance) {
        NSLog(@"[ThinkingData]: init SDK");
    }
    return instance;
}


- (IBAction)thinkingAnalysticsSDKInit:(NSButton *)sender {
    ThinkingAnalyticsSDK *instance = [ThinkingAnalyticsSDK sharedInstance];
    if (!instance) {
        TAInitinalViewController *initVC = [[TAInitinalViewController alloc] init];
        [self presentViewControllerAsSheet:initVC];
    } else {
        NSLog(@"[ThinkingData]: has been initialized successfully SDK");
    }
}


- (IBAction)calibratedTime:(NSButton *)sender {
    [ThinkingAnalyticsSDK calibrateTimeWithNtp:@"ntp.aliyun.com"];
}


- (IBAction)trackNormal:(NSButton *)sender {
    NSDictionary *dic = [ViewController readLocalFile];
//
//    NSTimeInterval timer1 = [NSProcessInfo processInfo].systemUptime;
//    [[self getInstance] track:@"a" properties:dic];
//    NSTimeInterval timer2 = [NSProcessInfo processInfo].systemUptime;
//    NSLog(@"@@@@@@@@@trackNormal: %f", (timer2 - timer1)/1000.);
    
    [[self getInstance] track:@"asdas" properties:@{}];
    
    
//    if (json[@"time"] && json[@"timeZone"]) {
//        NSDate *date=[NSDate dateWithTimeIntervalSince1970:([json[@"time"] doubleValue])];
//        NSTimeZone *zone = [NSTimeZone timeZoneWithName:json[@"timeZone"]];
//        [[self getInstance] track:json[@"event_name"] properties:json[@"properties"] time:date timeZone:zone];
//    } else {
//        [[self getInstance] track:json[@"event_name"] properties:json[@"properties"]];
//    }
//
    
}


- (IBAction)trackWithCustomProperties:(NSButton *)sender {
    [[self getInstance] track:@"testProperty" properties:@{@"properKey":@"properValue",@"number":@123.2, @"arrKey":@[@1, @2],@"event_time":@"2020-10-20 18:00:51.125",@"xx":@NO,@"level":@"level-1"}];
}


- (IBAction)trackWithCustomTime:(NSButton *)sender {
    [[self getInstance] track:@"test" properties:nil time:[NSDate date] timeZone:[NSTimeZone localTimeZone]];
}


- (IBAction)trackWithEventTimeTracker:(NSButton *)sender {
    [[self getInstance] timeEvent:@"ta_time_event"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[self getInstance] track:@"ta_time_event"];
    });
}


- (IBAction)trackFirst:(NSButton *)sender {
    TDFirstEventModel *uniqueModel = [[TDFirstEventModel alloc] initWithEventName:@"eventName_unique" firstCheckID:@""];
    uniqueModel.properties = @{ @"TestProKey": @"TestProValue"};
    [[self getInstance] trackWithEventModel:uniqueModel];
}


- (IBAction)trackUpdate:(NSButton *)sender {
    TDUpdateEventModel *updateModel = [[TDUpdateEventModel alloc] initWithEventName:@"eventName_edit" eventID:@"eventIDxxx"];
    updateModel.properties = @{ @"eventKeyEdit": @"eventKeyEdit_update", @"eventKeyEdit2": @"eventKeyEdit_update2", @"status":@5 };
    [[self getInstance] trackWithEventModel:updateModel];
}


- (IBAction)trackOverwrite:(NSButton *)sender {
    TDOverwriteEventModel *overwriteModel = [[TDOverwriteEventModel alloc] initWithEventName:@"eventName_edit" eventID:@"eventIDxxx"];
    overwriteModel.properties = @{ @"eventKeyEdit": @"eventKeyEdit_overwrite" , @"price": @5};
    [[self getInstance] trackWithEventModel:overwriteModel];
}


- (IBAction)stopFlushAndClearData:(NSButton *)sender {
    [[self getInstance] setTrackStatus:TATrackStatusStop];
}


- (IBAction)stopFlush:(NSButton *)sender {
    [[self getInstance] setTrackStatus:TATrackStatusStop];
}


- (IBAction)pause:(NSButton *)sender {
    [[self getInstance] setTrackStatus:TATrackStatusPause];
}


- (IBAction)resume:(NSButton *)sender {
    [[self getInstance] setTrackStatus:TATrackStatusNormal];
}


- (IBAction)setCommonDynamicProperties:(NSButton *)sender {
    [[self getInstance] registerDynamicSuperProperties:^NSDictionary<NSString *,id> * _Nonnull{
        return @{@"dynamicsuperkey":@"dynamicsupervalue",@"level":@"level-2"};
    }];
}


- (IBAction)setCommonStaticProperties:(NSButton *)sender {
    NSDictionary *dic = [ViewController readLocalFile];
    NSTimeInterval timer1 = [NSProcessInfo processInfo].systemUptime;
    [[self getInstance] setSuperProperties:dic];
    NSTimeInterval timer2 = [NSProcessInfo processInfo].systemUptime;
    NSLog(@"@@@@@@@@@setSuperProperties: %f", (timer2 - timer1)/1000.);
    
}


- (IBAction)clearCommonStaticProperties:(NSButton *)sender {
    [[self getInstance] clearSuperProperties];
}


- (IBAction)unsetCommonStaticProperties:(NSButton *)sender {
    [[self getInstance] unsetSuperProperty:@"superkey"];
}

- (IBAction)distincidClick:(id)sender {
    NSTimeInterval timer1 = [NSProcessInfo processInfo].systemUptime;
    [[self getInstance] identify:@"user_distincid_id"];
    NSTimeInterval timer2 = [NSProcessInfo processInfo].systemUptime;
    NSLog(@"@@@@@@@@@identify: %f", (timer2 - timer1)/1000.);
}


- (IBAction)login:(NSButton *)sender {
    NSTimeInterval timer1 = [NSProcessInfo processInfo].systemUptime;
    [[self getInstance] login:@"user_login_id"];
    NSTimeInterval timer2 = [NSProcessInfo processInfo].systemUptime;
    NSLog(@"@@@@@@@@@login: %f", (timer2 - timer1)/1000.);
   
}


- (IBAction)logout:(NSButton *)sender {
    [[self getInstance] logout];
}


- (IBAction)userAdd:(NSButton *)sender {
    NSTimeInterval timer1 = [NSProcessInfo processInfo].systemUptime;
    [[self getInstance] user_add:@"key1" andPropertyValue:[NSNumber numberWithInt:6]];
    NSTimeInterval timer2 = [NSProcessInfo processInfo].systemUptime;
    NSLog(@"@@@@@@@@@userAdd: %f", (timer2 - timer1)/1000.);
//    [[self getInstance] user_add:@"key1" andPropertyValue:[NSNumber numberWithInt:6]];
//    [[self getInstance] user_add:@"key1" andPropertyValue:@(-100)];
}


- (IBAction)userDelete:(NSButton *)sender {
    [[self getInstance] user_delete];
}


- (IBAction)userUniqueAppend:(NSButton *)sender {
    NSDictionary *dic = [ViewController readLocalFile];
    NSTimeInterval timer1 = [NSProcessInfo processInfo].systemUptime;
    [[self getInstance] user_uniqAppend:dic];
    NSTimeInterval timer2 = [NSProcessInfo processInfo].systemUptime;
    NSLog(@"@@@@@@@@@userUniqueAppend: %f", (timer2 - timer1)/1000.);
}


- (IBAction)userAppend:(NSButton *)sender {
    NSDictionary *dic = [ViewController readLocalFile];
    NSTimeInterval timer1 = [NSProcessInfo processInfo].systemUptime;
    [[self getInstance] user_append:dic];
    NSTimeInterval timer2 = [NSProcessInfo processInfo].systemUptime;
    NSLog(@"@@@@@@@@@userAppend: %f", (timer2 - timer1)/1000.);
    
}


- (IBAction)userUnset:(NSButton *)sender {
    [[self getInstance] user_unset:@"key1"];
}


- (IBAction)userSetOnce:(NSButton *)sender {
    NSDictionary *dic = [ViewController readLocalFile];
    NSTimeInterval timer1 = [NSProcessInfo processInfo].systemUptime;
    [[self getInstance] user_setOnce:dic];
    NSTimeInterval timer2 = [NSProcessInfo processInfo].systemUptime;
    NSLog(@"@@@@@@@@@userSetOnce: %f", (timer2 - timer1)/1000.);
   
}


- (IBAction)userSet:(NSButton *)sender {
    
    NSDictionary *dic = [ViewController readLocalFile];
    NSTimeInterval timer1 = [NSProcessInfo processInfo].systemUptime;
    [[self getInstance] user_set:dic];
    NSTimeInterval timer2 = [NSProcessInfo processInfo].systemUptime;
    NSLog(@"@@@@@@@@@userSet: %f", (timer2 - timer1)/1000.);
    
}

@end
