//
//  TEST_Helper.h
//  ThinkingSDKDEMOUITests
//
//  Created by wwango on 2021/12/11.
//  Copyright © 2021 thinking. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TEST_Model.h"
#import <ThinkingSDK/ThinkingAnalyticsSDK.h>
//#import "YYKit.h"

NS_ASSUME_NONNULL_BEGIN

@interface TEST_Helper : NSObject

+ (void)deleteNSLibraryDirectory;

+ (void)dispatchQueue:(dispatch_block_t)block;

+ (void)checkInstance:(ThinkingAnalyticsSDK *)ins
                input:(TEST_Input_Model *)input
           hasInsName:(BOOL)hasInsName
               result:(void(^)(BOOL result))result;

+ (void)syncCheckInstance:(ThinkingAnalyticsSDK *)ins
                input:(TEST_Input_Model *)input
           hasInsName:(BOOL)hasInsName
               result:(void(^)(BOOL result))result;


// 检查预置属性
+ (BOOL)checkProperties:(NSDictionary *)dataSource;

// 检查外设属性
+ (BOOL)checkCustomProperties:(NSDictionary *)dataSource
               customProperty:(NSDictionary *)customProperty
               staticProperty:(NSDictionary *)staticProperty
                 dyldProperty:(NSDictionary *)dyldProperty;

@end

NS_ASSUME_NONNULL_END
