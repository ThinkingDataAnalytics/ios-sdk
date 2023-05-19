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
//#import "NTPViewController.h"
#import <ThinkingSDK/ThinkingSDK.h>
//#import "NetAssociation.h"
@interface TDOtherVC ()
//@property(strong,nonatomic)NetAssociation *        netAssociation;
@end

@implementation TDOtherVC

- (void)setData
{
    self.commands = [NSMutableArray array];
   
    [self.commands addObject:[[ActionModel alloc]initWithName:@"send data immediately" action:^{
        [ThinkingSDKAPI testFlush];
    }]];
    [self.commands addObject:[[ActionModel alloc]initWithName:@"Enable SDK data reporting" action:^{
        [ThinkingSDKAPI testEnable];
    }]];
    [self.commands addObject:[[ActionModel alloc]initWithName:@"Suspend SDK reporting" action:^{
        [ThinkingSDKAPI testDisEnable];
    }]];
    [self.commands addObject:[[ActionModel alloc]initWithName:@"Stop SDK reporting" action:^{
        [ThinkingSDKAPI optOutTracking];
    }]];
    [self.commands addObject:[[ActionModel alloc]initWithName:@"save only" action:^{
        [ThinkingSDKAPI testSaveonly];
    }]];
    [self.commands addObject:[[ActionModel alloc]initWithName:@"light instance" action:^{
        ThinkingAnalyticsSDK *light = [[ThinkingAnalyticsSDK sharedInstance] createLightInstance];
        [light track:@"lighttest"];
    }]];
    
    __weak typeof(self) weakSelf = self;
    [self.commands addObject:[[ActionModel alloc]initWithName:@"Calibrated Time" action:^{
//        weakSelf.netAssociation = [[NetAssociation alloc] initWithServerName:[NetAssociation ipAddrFromName:@"time.asia.apple.com"]];
//        weakSelf.netAssociation.delegate = self;
//        [weakSelf.netAssociation sendTimeQuery];
    }]];
//    [self.commands addObject:[[ActionModel alloc]initWithName:@"optInTracking" action:^{
//        [ThinkingSDKAPI optInTracking];
//    }]];
    [self.commands addObject:[[ActionModel alloc]initWithName:@"get PresetProperties" action:^{
        TDPresetProperties *presetProperties = [[ThinkingAnalyticsSDK sharedInstance] getPresetProperties];
        NSDictionary * dic = presetProperties.toEventPresetProperties;
        NSData *data =  [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:NULL];
        NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"getPresetProperties: %@", string);
        
    }]];
}

- (void)reportFromDelegate {
//    NSDate *theDate = [[NSDate date] dateByAddingTimeInterval: self.netAssociation.offset];
//    [[ThinkingAnalyticsSDK sharedInstance] track:@"test_event" properties:@{} time:theDate timeZone:[NSTimeZone localTimeZone]];
}
@end
