//
//  NSDictionary+TEST.m
//  ThinkingSDKDEMOUITests
//
//  Created by wwango on 2021/12/14.
//  Copyright © 2021 thinking. All rights reserved.
//

#import "NSDictionary+TEST.h"

@implementation NSMutableDictionary (TEST)

- (void)handleDatas {
    [self removeObjectsForKeys:@[@"#uuid", @"#type", @"#time"]];
    NSMutableDictionary *properties = [self[@"properties"] mutableCopy];
    [properties removeObjectsForKeys:@[@"#app_version",
                                       @"#bundle_id",
                                       @"#device_id",
                                       @"#device_model",
                                       @"#disk",
                                       @"#fps",
                                       @"#install_time",
                                       @"#lib",
                                       @"#lib_version",
                                       @"#manufacturer",
                                       @"#network_type",
                                       @"#os",
                                       @"#os_version",
                                       @"#ram",
                                       @"#screen_height",
                                       @"#screen_width",
                                       @"#simulator",
                                       @"#system_language",
                                       @"#zone_offset",
                                       @"#carrier"]];
    self[@"properties"] = properties;
}

@end
