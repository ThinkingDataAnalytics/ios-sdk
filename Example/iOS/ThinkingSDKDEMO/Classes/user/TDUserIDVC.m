//
//  TDUserIDVC.m
//  ThinkingSDKDEMO
//
//  Created by LiHuanan on 2020/9/18.
//  Copyright © 2020 thinking. All rights reserved.
//

#import "TDUserIDVC.h"
#import "ActionModel.h"
#import "ThinkingSDKAPI.h"
@interface TDUserIDVC ()

@end

@implementation TDUserIDVC
- (void)setData
{
    self.commands = [NSMutableArray array];
    [self.commands addObject:[[ActionModel alloc]initWithName:@"Identify" action:^{
        [ThinkingSDKAPI testIdentify];
    }]];
}
- (NSString*)rightTitle
{
    return @"custom distinct ID";
}

@end
