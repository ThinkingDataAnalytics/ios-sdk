//
//  ViewController.m
//  ThinkingSDKMac
//
//  Created by yangxiong on 2022/6/21.
//

#import "ViewController.h"
#import "TAInitinalViewController.h"
#import "TAInputViewController.h"
#import <ThinkingSDK/ThinkingSDK.h>
#import <MJExtension/MJExtension.h>

@interface ViewController ()

@property (nonatomic, strong) NSWindowController *childWindowController;
@property (nonatomic, copy) NSString *____String_you_;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (ThinkingAnalyticsSDK *)getInstance {
    ThinkingAnalyticsSDK *instance = [ThinkingAnalyticsSDK sharedInstance];
    if (!instance) {
        NSLog(@"[ThinkingData]: init SDK");
    }
    return instance;
}


- (IBAction)thinkingAnalysticsSDKInit:(NSButton *)sender {
    
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[((NSString *)_____String_you_) dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    [ThinkingAnalyticsSDK setLogLevel:TDLoggingLevelDebug];
    NSString *appid = json[@"appId"];
    NSString *url = json[@"serverUrl"];
    NSString *timeZone = json[@"timeZone"];
    TDConfig *config = [TDConfig new];
    config.appid = appid;
    config.configureURL = url;
    if (timeZone && timeZone.length>0)
        config.defaultTimeZone = [NSTimeZone timeZoneWithName:timeZone];
    [ThinkingAnalyticsSDK startWithConfig:config];
    
}


- (IBAction)thinkingAnalysticsInput:(NSButton *)sender {
    TAInputViewController *initVC = [[TAInputViewController alloc] init];
    initVC.txtView.string = @"";
    __weak __typeof(self)weakSelf = self;
    initVC.backText = ^(NSString *txt) {
        weakSelf.____String_you_ = txt;
    };
    [self presentViewControllerAsSheet:initVC];
}

- (IBAction)calibratedTime:(NSButton *)sender {
    [ThinkingAnalyticsSDK calibrateTimeWithNtp:@"ntp.aliyun.com"];
}

- (IBAction)trackNormal:(NSButton *)sender {
    
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[((NSString *)_____String_you_) dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    
    if (json[@"time"] && json[@"timeZone"]) {
        NSDate *date=[NSDate dateWithTimeIntervalSince1970:([json[@"time"] doubleValue])];
        NSTimeZone *zone = [NSTimeZone timeZoneWithName:json[@"timeZone"]];
        [[self getInstance] track:json[@"event_name"] properties:json[@"properties"] time:date timeZone:zone];
    } else {
        [[self getInstance] track:json[@"event_name"] properties:json[@"properties"]];
    }
       
    
}

- (IBAction)trackWithCustomProperties:(NSButton *)sender {
    
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[((NSString *)_____String_you_) dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    
    if (json[@"time"] && json[@"timeZone"]) {
        NSDate *date=[NSDate dateWithTimeIntervalSince1970:([json[@"time"] doubleValue])];
        NSTimeZone *zone = [NSTimeZone timeZoneWithName:json[@"timeZone"]];
        [[self getInstance] track:json[@"event_name"] properties:json[@"properties"] time:date timeZone:zone];
    } else {
        [[self getInstance] track:json[@"event_name"] properties:json[@"properties"]];
    }
}


- (IBAction)trackWithCustomTime:(NSButton *)sender {
    
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[((NSString *)_____String_you_) dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    
    if (json[@"time"] && json[@"timeZone"]) {
        NSDate *date=[NSDate dateWithTimeIntervalSince1970:([json[@"time"] doubleValue])];
        NSTimeZone *zone = [NSTimeZone timeZoneWithName:json[@"timeZone"]];
        [[self getInstance] track:json[@"event_name"] properties:json[@"properties"] time:date timeZone:zone];
    } else {
        [[self getInstance] track:json[@"event_name"] properties:json[@"properties"]];
    }
    
}


- (IBAction)trackWithEventTimeTracker:(NSButton *)sender {
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[((NSString *)_____String_you_) dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    
    [[self getInstance] timeEvent:json[@"event_name"]];

}


- (IBAction)trackFirst:(NSButton *)sender {
    
    
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[((NSString *)_____String_you_) dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    
    TDFirstEventModel *uniqueModel = [[TDFirstEventModel alloc] initWithEventName:json[@"event_name"] firstCheckID:json[@"event_id"]];
    uniqueModel.properties = json[@"properties"];
    [[self getInstance] trackWithEventModel:uniqueModel];
}


- (IBAction)trackUpdate:(NSButton *)sender {
    
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[((NSString *)_____String_you_) dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    
    TDUpdateEventModel *updateModel = [[TDUpdateEventModel alloc] initWithEventName:json[@"event_name"] eventID:json[@"event_id"]];
    updateModel.properties = json[@"properties"];
    [[self getInstance] trackWithEventModel:updateModel];
}


- (IBAction)trackOverwrite:(NSButton *)sender {
    
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[((NSString *)_____String_you_) dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    
    TDOverwriteEventModel *overwriteModel = [[TDOverwriteEventModel alloc] initWithEventName:json[@"event_name"] eventID:json[@"event_id"]];
    overwriteModel.properties =  json[@"properties"];
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
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[((NSString *)_____String_you_) dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
        return json[@"properties"];
    }];
}


- (IBAction)setCommonStaticProperties:(NSButton *)sender {
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[((NSString *)_____String_you_) dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    [[self getInstance] setSuperProperties:json[@"properties"]];
}


- (IBAction)clearCommonStaticProperties:(NSButton *)sender {
    [[self getInstance] clearSuperProperties];
}


- (IBAction)unsetCommonStaticProperties:(NSButton *)sender {
    [[self getInstance] unsetSuperProperty:@"superkey"];
}


- (IBAction)login:(NSButton *)sender {
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[((NSString *)_____String_you_) dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    [[self getInstance] login:json[@"name"]];
}
- (IBAction)distinciddd:(id)sender {
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[((NSString *)_____String_you_) dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    [[self getInstance] identify:json[@"name"]];
}


- (IBAction)logout:(NSButton *)sender {
    [[self getInstance] logout];
}


- (IBAction)userAdd:(NSButton *)sender {
    
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[((NSString *)_____String_you_) dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    
    for (NSString *key in json.allKeys) {
        [[self getInstance] user_add:key andPropertyValue:@([json[key] doubleValue])];
    }
    
    
}


- (IBAction)userDelete:(NSButton *)sender {
    [[self getInstance] user_delete];
}


- (IBAction)userUniqueAppend:(NSButton *)sender {
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[((NSString *)_____String_you_) dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    [[self getInstance] user_uniqAppend:json[@"properties"]];
}


- (IBAction)userAppend:(NSButton *)sender {
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[((NSString *)_____String_you_) dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    [[self getInstance] user_append:json[@"properties"]];
}


- (IBAction)userUnset:(NSButton *)sender {
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[((NSString *)_____String_you_) dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    
    [[self getInstance] user_unset:json[@"properties"]];
}


- (IBAction)userSetOnce:(NSButton *)sender {
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[((NSString *)_____String_you_) dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    [[self getInstance] user_setOnce:json[@"properties"]];
}


- (IBAction)userSet:(NSButton *)sender {
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[((NSString *)_____String_you_) dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    
    [[self getInstance] user_set:json[@"properties"]];
}

@end
