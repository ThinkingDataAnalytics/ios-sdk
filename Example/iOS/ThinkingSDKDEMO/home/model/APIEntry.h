//
//  APIEntry.h
//  ThinkingSDKDEMO
//
//  Created by syj on 2019/6/24.
//  Copyright © 2019 thinking. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface APIEntry : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, copy) void (^block)(UIViewController *controller);
@property (nonatomic, assign) UITableViewCellAccessoryType accessoryType;

+ (APIEntry *)commandWithName:(NSString *)name
                accessoryType:(UITableViewCellAccessoryType)accessoryType
                        block:(void (^)(UIViewController *controller))block;
- (void)executeWithViewController:(UIViewController *)controller;

@end

NS_ASSUME_NONNULL_END
