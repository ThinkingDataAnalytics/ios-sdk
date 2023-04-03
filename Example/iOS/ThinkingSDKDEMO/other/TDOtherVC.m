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
//    [self.commands addObject:[[ActionModel alloc]initWithName:@"更新库名称和库版本号" action:^{
//        [ThinkingSDKAPI testChangeLibNameAndLibVersion];
//    }]];
   
    [self.commands addObject:[[ActionModel alloc]initWithName:@"立即发送数据" action:^{
        [ThinkingSDKAPI testFlush];
    }]];
    [self.commands addObject:[[ActionModel alloc]initWithName:@"启用SDK数据上报" action:^{
        [ThinkingSDKAPI testEnable];
    }]];
    [self.commands addObject:[[ActionModel alloc]initWithName:@"暂停SDK上报" action:^{
        [ThinkingSDKAPI testDisEnable];
    }]];
    [self.commands addObject:[[ActionModel alloc]initWithName:@"停止SDK上报" action:^{
        [ThinkingSDKAPI optOutTracking];
    }]];
    [self.commands addObject:[[ActionModel alloc]initWithName:@"仅保存" action:^{
        [ThinkingSDKAPI testSaveonly];
    }]];
    [self.commands addObject:[[ActionModel alloc]initWithName:@"轻实例" action:^{
        ThinkingAnalyticsSDK *light = [[ThinkingAnalyticsSDK sharedInstance] createLightInstance];
        [light track:@"lighttest"];
    }]];
    __weak typeof(self) weakSelf = self;
    [self.commands addObject:[[ActionModel alloc]initWithName:@"校准时间" action:^{
//        weakSelf.netAssociation = [[NetAssociation alloc] initWithServerName:[NetAssociation ipAddrFromName:@"time.asia.apple.com"]];
//        weakSelf.netAssociation.delegate = self;
//        [weakSelf.netAssociation sendTimeQuery];
    }]];
//    [self.commands addObject:[[ActionModel alloc]initWithName:@"optInTracking" action:^{
//        [ThinkingSDKAPI optInTracking];
//    }]];
}

- (void)reportFromDelegate {
//    NSDate *theDate = [[NSDate date] dateByAddingTimeInterval: self.netAssociation.offset];
//    [[ThinkingAnalyticsSDK sharedInstance] track:@"test_event" properties:@{} time:theDate timeZone:[NSTimeZone localTimeZone]];
}
@end
