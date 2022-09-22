//
//  APIEntry.m
//  ThinkingSDKDEMO
//
//  Created by syj on 2019/6/24.
//  Copyright © 2019年 thinking. All rights reserved.
//

#import "APIEntry.h"

@implementation APIEntry

+ (APIEntry *)commandWithName:(NSString *)name
                accessoryType:(UITableViewCellAccessoryType)accessoryType
                        block:(void (^)(UIViewController *controller))block {
    return [[self alloc] initWithName:name
                        accessoryType:accessoryType
                                block:block];
}

- (id)initWithName:(NSString *)name
     accessoryType:(UITableViewCellAccessoryType)accessoryType
             block:(void (^)(UIViewController *controller))block {
    if ((self = [super init])) {
        self.name = name;
        self.accessoryType = accessoryType;
        self.block = block;
    }
    return self;
}

- (void)executeWithViewController:(UIViewController *)controller {
    self.block(controller);
}

@end
