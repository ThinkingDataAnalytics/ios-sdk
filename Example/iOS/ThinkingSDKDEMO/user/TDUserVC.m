//
//  TDUserVC.m
//  ThinkingSDKDEMO
//
//  Created by LiHuanan on 2020/9/7.
//  Copyright © 2020 thinking. All rights reserved.
//

#import "TDUserVC.h"
#import "ActionModel.h"
#import "ThinkingSDKAPI.h"
#import<ThinkingSDK/ThinkingSDK.h>
@interface TDUserVC ()<TDScreenAutoTracker>

@end

@implementation TDUserVC
- (NSString*)getScreenUrl
{
    return @"XXX";
}
- (void)setData
{
    self.commands = [NSMutableArray array];
    [self.commands addObject:[[ActionModel alloc] initWithName:@"User_Set" action:^{
        [ThinkingSDKAPI testUserSet];
    }]];
    [self.commands addObject:[[ActionModel alloc] initWithName:@"User_Unset" action:^{
        [ThinkingSDKAPI testUserUnset];
    }]];
    [self.commands addObject:[[ActionModel alloc] initWithName:@"User_SetOnce" action:^{
        [ThinkingSDKAPI testUserSetonce];
    }]];
    [self.commands addObject:[[ActionModel alloc] initWithName:@"User_Del" action:^{
        [ThinkingSDKAPI testUserDel];
    }]];
    [self.commands addObject:[[ActionModel alloc] initWithName:@"User_ADD" action:^{
        [ThinkingSDKAPI testUserAdd];
    }]];
    [self.commands addObject:[[ActionModel alloc] initWithName:@"User_APPEND" action:^{
        [ThinkingSDKAPI testUserAppend];
    }]];
    [self.commands addObject:[[ActionModel alloc] initWithName:@"Login" action:^{
        [ThinkingSDKAPI testLogin];
    }]];
    [self.commands addObject:[[ActionModel alloc] initWithName:@"Logout" action:^{
        [ThinkingSDKAPI testLogin];
    }]];
}
- (NSString*)rightTitle
{
    return @"user property";
}


@end
