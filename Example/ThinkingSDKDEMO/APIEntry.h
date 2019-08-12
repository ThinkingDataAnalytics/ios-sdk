//
//  APIEntry.h
//  ThinkingSDKDEMO
//
//  Created by syj on 2019/6/24.
//  Copyright © 2019年 thinking. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface APIEntry : NSObject

@property(nonatomic,readwrite,retain) NSString* name;
@property(nonatomic,readwrite,copy) void (^block)(UIViewController* controller);
@property(nonatomic,readwrite,assign) UITableViewCellAccessoryType accessoryType;

+ (APIEntry*) commandWithName:(NSString*) name
                    accessoryType:(UITableViewCellAccessoryType) accessoryType
                            block:(void (^)(UIViewController* controller)) block;
- (void) executeWithViewController:(UIViewController*) controller;

@end

NS_ASSUME_NONNULL_END
