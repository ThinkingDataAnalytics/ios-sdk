//
//  NSObject+TDSwizzle.h
//  TDAnalyticsSDK
//
//  Created by THINKINGDATA on 2018/5/3.
//  Copyright © 2018年 thinkingdata. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface NSObject (TDSwizzle)

+ (BOOL)td_swizzleMethod:(SEL)origSel_ withMethod:(SEL)altSel_ error:(NSError **)error_;
+ (BOOL)td_swizzleClassMethod:(SEL)origSel_ withClassMethod:(SEL)altSel_ error:(NSError **)error_;

@end
NS_ASSUME_NONNULL_END
