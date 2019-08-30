//
//  TrackAPIVC.h
//  ThinkingSDKDEMO
//
//  Created by syj on 2019/6/24.
//  Copyright © 2019年 thinking. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TrackAPIVC : UITableViewController

@property (nonatomic, readonly, strong) NSMutableArray *apis;
@property (nonatomic, copy) NSString * (^getTitleBlock)(UIViewController *controller);

@end

NS_ASSUME_NONNULL_END
