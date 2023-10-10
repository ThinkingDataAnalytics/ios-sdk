//
//  TDOtherVC.m
//  ThinkingSDKDEMO
//
//  Created by LiHuanan on 2020/9/7.
//  Copyright © 2020 thinking. All rights reserved.
//

#import "TDOtherVC.h"
#import "ActionModel.h"
#import "ThinkingSDKAPI.h"
#import "TDAutoTrackVC.h"
#import "TDUtil.h"
#import <ThinkingSDK/ThinkingSDK.h>

@interface TDOtherVC ()

@end

@implementation TDOtherVC

- (void)setData
{
    self.commands = [NSMutableArray array];
   
    [self.commands addObject:[[ActionModel alloc]initWithName:@"send data immediately" action:^{
        [ThinkingSDKAPI testFlush];
    }]];
    [self.commands addObject:[[ActionModel alloc]initWithName:@"Enable SDK data reporting" action:^{
        [TDAnalytics setTrackStatus:TDTrackStatusNormal];
    }]];
    [self.commands addObject:[[ActionModel alloc]initWithName:@"Suspend SDK reporting" action:^{
        [TDAnalytics setTrackStatus:TDTrackStatusPause];
    }]];
    [self.commands addObject:[[ActionModel alloc]initWithName:@"Stop SDK reporting" action:^{
        [TDAnalytics setTrackStatus:TDTrackStatusStop];
    }]];
    [self.commands addObject:[[ActionModel alloc]initWithName:@"save only" action:^{
        [TDAnalytics setTrackStatus:TDTrackStatusSaveOnly];
    }]];
    [self.commands addObject:[[ActionModel alloc] initWithName:@"light instance" action:^{
        NSString * const APP_ID = @"6375841cc421410e80a06aaac03dfd88";
        NSString *lightInstanceID = [TDAnalytics lightInstanceIdWithAppId:APP_ID];
        [TDAnalytics track:@"lighttest" withAppId:lightInstanceID];
    }]];
    
    [self.commands addObject:[[ActionModel alloc]initWithName:@"Calibrated Time" action:^{
        [TDAnalytics calibrateTimeWithNtp:@"time.apple.com"];
    }]];

    [self.commands addObject:[[ActionModel alloc]initWithName:@"get PresetProperties" action:^{
        TDPresetProperties *presetProperties = [TDAnalytics getPresetProperties];
        NSDictionary * dic = presetProperties.toEventPresetProperties;
        NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:NULL];
        NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"getPresetProperties: %@", string);
    }]];
}

- (void)reportFromDelegate {
//    NSDate *theDate = [[NSDate date] dateByAddingTimeInterval: self.netAssociation.offset];
//    [[ThinkingAnalyticsSDK sharedInstance] track:@"test_event" properties:@{} time:theDate timeZone:[NSTimeZone localTimeZone]];
}
@end
