//
//  ActionModel.m
//  ThinkingSDKDEMO
//
//  Created by LiHuanan on 2020/9/7.
//  Copyright © 2020 thinking. All rights reserved.
//

#import "ActionModel.h"

@implementation ActionModel
//- (id)initWithName:(NSString *)name
//     accessoryType:(UITableViewCellAccessoryType)accessoryType
//             block:(void (^)(UIViewController *controller))block {
//    if ((self = [super init])) {
//        self.name = name;
//        self.accessoryType = accessoryType;
//        self.block = block;
//    }
//    return self;
//}
- (id)initWithName:(NSString*)name action:(Action)action
{
    self = [super init];
    if(self)
    {
        self.name = name;
        self.action = action;
    }
    return self;
}
@end
