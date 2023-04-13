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
    return @"Send Event";
}
- (void)setData
{
    self.commands = [NSMutableArray array];
    [self.commands addObject:[[ActionModel alloc] initWithName:@"Track" action:^{
        [ThinkingSDKAPI testTrack];
    }]];
    [self.commands addObject:[[ActionModel alloc] initWithName:@"First Event" action:^{
        [ThinkingSDKAPI testTrackWithDefaultFirstCheckID];
    }]];
    [self.commands addObject:[[ActionModel alloc] initWithName:@"update Event" action:^{
        [ThinkingSDKAPI testTrackUpdate];
    }]];
    [self.commands addObject:[[ActionModel alloc] initWithName:@"overwrite Event" action:^{
        [ThinkingSDKAPI testTrackOverwrite];
    }]];
    [self.commands addObject:[[ActionModel alloc] initWithName:@"trackWithProperty" action:^{
        [ThinkingSDKAPI testTrackWithProperty];
    }]];
    [self.commands addObject:[[ActionModel alloc] initWithName:@"trackWithTimezone" action:^{
        [ThinkingSDKAPI testTrackWithTimezone];
    }]];
    [self.commands addObject:[[ActionModel alloc]initWithName:@"set static public properties" action:^{
        [ThinkingSDKAPI testSetsuper];
    }]];
    [self.commands addObject:[[ActionModel alloc]initWithName:@"clear one with static public properties" action:^{
        [ThinkingSDKAPI testUnsetsuper];
    }]];
    [self.commands addObject:[[ActionModel alloc]initWithName:@"clear all static public properties" action:^{
        [ThinkingSDKAPI testClearsuper];
    }]];
    [self.commands addObject:[[ActionModel alloc]initWithName:@"set dynamic public properties" action:^{
        [ThinkingSDKAPI testSetDynamicsuper];
    }]];
    
    __weak typeof(self) weakSelf = self;
    [self.commands addObject:[[ActionModel alloc]initWithName:@"event time" action:^{
        [ThinkingSDKAPI testTimedEvent];
        [weakSelf performSelector:@selector(eventEnd) withObject:nil afterDelay:15.];
    }]];
    
}
- (void)eventEnd
{
    [ThinkingSDKAPI testTrackEventEnd];
}


@end
