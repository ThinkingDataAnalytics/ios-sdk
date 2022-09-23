//
//  ViewController.m
//  ThinkingSDKMac
//
//  Created by 杨雄 on 2022/6/21.
//

#import "ViewController.h"
#import "TAInitinalViewController.h"
#import <ThinkingSDK/ThinkingSDK.h>

@interface ViewController ()
@property (nonatomic, strong) NSWindowController *childWindowController;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (ThinkingAnalyticsSDK *)getInstance {
    ThinkingAnalyticsSDK *instance = [ThinkingAnalyticsSDK sharedInstance];
    if (!instance) {
        NSLog(@"[ThinkingData]: 请初始化SDK");
    }
    return instance;
}

/// 初始化SDK
- (IBAction)thinkingAnalysticsSDKInit:(NSButton *)sender {
    ThinkingAnalyticsSDK *instance = [ThinkingAnalyticsSDK sharedInstance];
    if (!instance) {
        TAInitinalViewController *initVC = [[TAInitinalViewController alloc] init];
        [self presentViewControllerAsSheet:initVC];
    } else {
        NSLog(@"[ThinkingData]: 已经初始化成功SDK");
    }
}

/// 时间校准
- (IBAction)calibratedTime:(NSButton *)sender {
    [ThinkingAnalyticsSDK calibrateTimeWithNtp:@"ntp.aliyun.com"];
}

/// track 普通事件
- (IBAction)trackNormal:(NSButton *)sender {
    [[self getInstance] track:@"a"];
}

/// track 事件，并携带自定义属性
- (IBAction)trackWithCustomProperties:(NSButton *)sender {
    [[self getInstance] track:@"testProperty" properties:@{@"properKey":@"properValue", @"arrKey":@[@1, @2],@"event_time":@"2020-10-20 18:00:51.125",@"xx":@NO,@"level":@"level-1"}];
}

/// track 事件，并使用自定义的时间
- (IBAction)trackWithCustomTime:(NSButton *)sender {
    [[self getInstance] track:@"test" properties:nil time:[NSDate date] timeZone:[NSTimeZone localTimeZone]];
}

/// track 事件，且该事件记录了持续时长
- (IBAction)trackWithEventTimeTracker:(NSButton *)sender {
    [[self getInstance] timeEvent:@"ta_time_event"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[self getInstance] track:@"ta_time_event"];
    });
}

/// 首次事件
- (IBAction)trackFirst:(NSButton *)sender {
    TDFirstEventModel *uniqueModel = [[TDFirstEventModel alloc] initWithEventName:@"eventName_unique" firstCheckID:@"customFirstCheckID"];
    uniqueModel.properties = @{ @"TestProKey": @"TestProValue"};
    [[self getInstance] trackWithEventModel:uniqueModel];
}

/// 可更新事件
- (IBAction)trackUpdate:(NSButton *)sender {
    TDUpdateEventModel *updateModel = [[TDUpdateEventModel alloc] initWithEventName:@"eventName_edit" eventID:@"eventIDxxx"];
    updateModel.properties = @{ @"eventKeyEdit": @"eventKeyEdit_update", @"eventKeyEdit2": @"eventKeyEdit_update2" };
    [[self getInstance] trackWithEventModel:updateModel];
}

/// 可重写事件
- (IBAction)trackOverwrite:(NSButton *)sender {
    TDOverwriteEventModel *overwriteModel = [[TDOverwriteEventModel alloc] initWithEventName:@"eventName_edit" eventID:@"eventIDxxx"];
    overwriteModel.properties = @{ @"eventKeyEdit": @"eventKeyEdit_overwrite" };
    [[self getInstance] trackWithEventModel:overwriteModel];
}

/// 停止上报，并删除用户在TA系统的数据
- (IBAction)stopFlushAndClearData:(NSButton *)sender {
    [[self getInstance] setTrackStatus:TATrackStatusStop];
}

/// 停止上报
- (IBAction)stopFlush:(NSButton *)sender {
    [[self getInstance] setTrackStatus:TATrackStatusStop];
}

/// 暂停上报
- (IBAction)pause:(NSButton *)sender {
    [[self getInstance] setTrackStatus:TATrackStatusPause];
}

/// 继续开启上报
- (IBAction)resume:(NSButton *)sender {
    [[self getInstance] setTrackStatus:TATrackStatusNormal];
}

/// 设置动态公共属性
- (IBAction)setCommonDynamicProperties:(NSButton *)sender {
    [[self getInstance] registerDynamicSuperProperties:^NSDictionary<NSString *,id> * _Nonnull{
        return @{@"dynamicsuperkey":@"dynamicsupervalue",@"level":@"level-2"};
    }];
}

/// 设置公共属性
- (IBAction)setCommonStaticProperties:(NSButton *)sender {
    [[self getInstance] setSuperProperties:@{@"superkey":@"supervalue1",@"superkey2":@"数数科技👍",@"superkey3":@(YES),@"level":@"level-3"}];
}

/// 清空公共属性
- (IBAction)clearCommonStaticProperties:(NSButton *)sender {
    [[self getInstance] clearSuperProperties];
}

/// 删除某个公共属性
- (IBAction)unsetCommonStaticProperties:(NSButton *)sender {
    [[self getInstance] unsetSuperProperty:@"superkey"];
}

/// 登录用户
- (IBAction)login:(NSButton *)sender {
    [[self getInstance] login:@"user_login_id"];
}

/// 登出用户
- (IBAction)logout:(NSButton *)sender {
    [[self getInstance] logout];
}

/// 用户属性，添加。要求属性值必须为NSNumber类型
- (IBAction)userAdd:(NSButton *)sender {
    [[self getInstance] user_add:@"key1" andPropertyValue:[NSNumber numberWithInt:6]];
}

/// 用户属性，删除
- (IBAction)userDelete:(NSButton *)sender {
    [[self getInstance] user_delete];
}

/// 追加用户某个属性值，并会去重。要求属性值必须为NSArray类型
- (IBAction)userUniqueAppend:(NSButton *)sender {
    [[self getInstance] user_uniqAppend:@{@"product_buy": @[@"product_name3", @"product_name3"]}];
}

/// 追加用户某个属性值，要求属性值必须为NSArray类型
- (IBAction)userAppend:(NSButton *)sender {
    [[self getInstance] user_append:@{@"product_buy": @[@"product_name1", @"product_name2"]}];
}

/// 删除某一个用户属性
- (IBAction)userUnset:(NSButton *)sender {
    [[self getInstance] user_unset:@"key1"];
}

/// 设置用户属性，只能设置一次
- (IBAction)userSetOnce:(NSButton *)sender {
    [[self getInstance] user_setOnce:@{@"setOnce":@"setonevalue1"}];
}

/// 设置用户属性
- (IBAction)userSet:(NSButton *)sender {
    [[self getInstance] user_set:@{
        @"UserName":@"TA1",
        @"Age":[NSNumber numberWithInt:20]
    }];
}

@end
