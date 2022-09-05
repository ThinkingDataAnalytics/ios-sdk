//
//  TDSDKDemoUtil.h
//  ThinkingSDKDEMO
//
//  Created by LiHuanan on 2020/9/7.
//  Copyright © 2020 thinking. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface TDUtil : NSObject
+ (UIViewController *)jsd_findVisibleViewController;
+ (UIViewController *)currentVC;
+ (float)screenPer;
@end

NS_ASSUME_NONNULL_END
