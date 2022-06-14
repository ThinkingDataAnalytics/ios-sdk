//
//  TDEventVC.m
//  ThinkingSDKDEMO
//
//  Created by LiHuanan on 2020/9/7.
//  Copyright © 2020 thinking. All rights reserved.
//

#import "TDEventVC.h"
#import "ActionModel.h"
#import "ThinkingSDKAPI.h"
@interface TDEventVC ()

@end

@implementation TDEventVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[ThinkingAnalyticsSDK sharedInstance] track:@"yxiong"];
}

- (NSString*)rightTitle
{
    return @"事件发送功能";
}
- (void)setData
{
    self.commands = [NSMutableArray array];
    [self.commands addObject:[[ActionModel alloc] initWithName:@"Track" action:^{
        [ThinkingSDKAPI testTrack];
    }]];
    [self.commands addObject:[[ActionModel alloc] initWithName:@"首次事件" action:^{
        [ThinkingSDKAPI testTrackWithDefaultFirstCheckID];
    }]];
    [self.commands addObject:[[ActionModel alloc] initWithName:@"可更新事件" action:^{
        [ThinkingSDKAPI testTrackUpdate];
    }]];
    [self.commands addObject:[[ActionModel alloc] initWithName:@"可重写事件" action:^{
        [ThinkingSDKAPI testTrackOverwrite];
    }]];
    [self.commands addObject:[[ActionModel alloc] initWithName:@"TrackWithProperty" action:^{
        [ThinkingSDKAPI testTrackWithProperty];
    }]];
    [self.commands addObject:[[ActionModel alloc] initWithName:@"TrackWithTimezone" action:^{
        [ThinkingSDKAPI testTrackWithTimezone];
    }]];
    [self.commands addObject:[[ActionModel alloc]initWithName:@"设置公共事件属性" action:^{
        [ThinkingSDKAPI testSetsuper];
    }]];
    [self.commands addObject:[[ActionModel alloc]initWithName:@"清除指定的公共事件属性" action:^{
        [ThinkingSDKAPI testUnsetsuper];
    }]];
    [self.commands addObject:[[ActionModel alloc]initWithName:@"清空所有公共事件属性" action:^{
        [ThinkingSDKAPI testClearsuper];
    }]];
    [self.commands addObject:[[ActionModel alloc]initWithName:@"设置动态公共事件属性" action:^{
        [ThinkingSDKAPI testSetDynamicsuper];
    }]];
    
    __weak typeof(self) weakSelf = self;
    [self.commands addObject:[[ActionModel alloc]initWithName:@"记录事件时长" action:^{
        [ThinkingSDKAPI testTimedEvent];
        [weakSelf performSelector:@selector(eventEnd) withObject:nil afterDelay:15.];
    }]];
    
}
- (void)eventEnd
{
    [ThinkingSDKAPI testTrackEventEnd];
}


@end
