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
- (NSDictionary *)readLocalFile {
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

- (IBAction)thinkingAnalysticsSDKInit:(NSButton *)sender {
    TAInitinalViewController *initVC = [[TAInitinalViewController alloc] init];
    [self presentViewControllerAsSheet:initVC];
}

- (IBAction)thinkingAnalysticsInput:(NSButton *)sender {
    
}

- (IBAction)calibratedTime:(NSButton *)sender {
    [TDAnalytics calibrateTimeWithNtp:@"ntp.aliyun.com"];
}


- (IBAction)trackNormal:(NSButton *)sender {
    NSDictionary *dic = [self readLocalFile];
    [TDAnalytics track:@"asdas" properties:dic];
}


- (IBAction)trackWithCustomProperties:(NSButton *)sender {
    [TDAnalytics track:@"testProperty" properties:@{
        @"properKey":@"properValue",
        @"number":@123.2,
        @"arrKey":@[@1, @2],
        @"event_time":@"2020-10-20 18:00:51.125",
        @"xx":@NO,
        @"level":@"level-1"
    }];
}


- (IBAction)trackWithCustomTime:(NSButton *)sender {
    [TDAnalytics track:@"test" properties:nil time:[NSDate date] timeZone:[NSTimeZone localTimeZone]];
}


- (IBAction)trackWithEventTimeTracker:(NSButton *)sender {
    [TDAnalytics timeEvent:@"ta_time_event"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [TDAnalytics track:@"ta_time_event"];
    });
}


- (IBAction)trackFirst:(NSButton *)sender {
    TDFirstEventModel *uniqueModel = [[TDFirstEventModel alloc] initWithEventName:@"eventName_unique" firstCheckID:@""];
    uniqueModel.properties = @{ @"TestProKey": @"TestProValue"};
    [TDAnalytics trackWithEventModel:uniqueModel];
}


- (IBAction)trackUpdate:(NSButton *)sender {
    TDUpdateEventModel *updateModel = [[TDUpdateEventModel alloc] initWithEventName:@"eventName_edit" eventID:@"eventIDxxx"];
    updateModel.properties = @{ @"eventKeyEdit": @"eventKeyEdit_update", @"eventKeyEdit2": @"eventKeyEdit_update2", @"status":@5 };
    [TDAnalytics trackWithEventModel:updateModel];
}


- (IBAction)trackOverwrite:(NSButton *)sender {
    TDOverwriteEventModel *overwriteModel = [[TDOverwriteEventModel alloc] initWithEventName:@"eventName_edit" eventID:@"eventIDxxx"];
    overwriteModel.properties = @{ @"eventKeyEdit": @"eventKeyEdit_overwrite" , @"price": @5};
    [TDAnalytics trackWithEventModel:overwriteModel];
}


- (IBAction)stopFlushAndClearData:(NSButton *)sender {
    [TDAnalytics setTrackStatus:TDTrackStatusStop];
}


- (IBAction)stopFlush:(NSButton *)sender {
    [TDAnalytics setTrackStatus:TDTrackStatusStop];
}


- (IBAction)pause:(NSButton *)sender {
    [TDAnalytics setTrackStatus:TDTrackStatusPause];
}


- (IBAction)resume:(NSButton *)sender {
    [TDAnalytics setTrackStatus:TDTrackStatusNormal];
}


- (IBAction)setCommonDynamicProperties:(NSButton *)sender {
    [TDAnalytics setDynamicSuperProperties:^NSDictionary<NSString *,id> * _Nonnull{
        return @{
            @"dynamicsuperkey":@"dynamicsupervalue",
            @"level":@"level-2"
        };
    }];
}


- (IBAction)setCommonStaticProperties:(NSButton *)sender {
    [TDAnalytics setSuperProperties:@{
        @"static_common_key_1": @"value_1"
    }];
}


- (IBAction)clearCommonStaticProperties:(NSButton *)sender {
    [TDAnalytics clearSuperProperties];
}


- (IBAction)unsetCommonStaticProperties:(NSButton *)sender {
    [TDAnalytics unsetSuperProperty:@"superkey"];
}

- (IBAction)distincidClick:(id)sender {
    [TDAnalytics setDistinctId:@"user_distincid_id"];
}


- (IBAction)login:(NSButton *)sender {
    [TDAnalytics login:@"user_login_id"];
}


- (IBAction)logout:(NSButton *)sender {
    [TDAnalytics logout];
}


- (IBAction)userAdd:(NSButton *)sender {
    [TDAnalytics userAdd:@{
        @"level": @6
    }];
}


- (IBAction)userDelete:(NSButton *)sender {
    [TDAnalytics userDelete];
}


- (IBAction)userUniqueAppend:(NSButton *)sender {
    [TDAnalytics userUniqAppend:@{
        @"array": @[@"a", @"b"]
    }];
}


- (IBAction)userAppend:(NSButton *)sender {
    [TDAnalytics userAppend:@{
        @"array": @[@"a", @"b"]
    }];
}


- (IBAction)userUnset:(NSButton *)sender {
    [TDAnalytics userUnset:@"key1"];
}


- (IBAction)userSetOnce:(NSButton *)sender {
    [TDAnalytics userSetOnce:@{
        @"once_key_1": @"value"
    }];
}


- (IBAction)userSet:(NSButton *)sender {
    [TDAnalytics userSet:@{
        @"set_key_1": @"value"
    }];
}

@end
