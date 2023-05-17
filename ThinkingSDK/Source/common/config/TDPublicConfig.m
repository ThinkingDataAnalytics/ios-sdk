//
//  TDPublicConfig.m
//  ThinkingSDK
//
//  Created by LiHuanan on 2020/9/8.
//  Copyright © 2020 thinkingdata. All rights reserved.
//

#import "TDPublicConfig.h"
static TDPublicConfig* config;

@implementation TDPublicConfig
+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        config = [TDPublicConfig new];
    });
}
- (instancetype)init
{
    self = [super init];
    if(self)
    {
        self.controllers = @[];
    }
    return self;
}
+ (NSArray*)controllers
{
    return config.controllers;
}
+ (NSString*)version
{
    return @"2.7.3";
}
@end
