//
//  TrackAPIViewController.h
//  ThinkingSDKDEMO
//
//  Created by syj on 2019/6/24.
//  Copyright © 2019年 thinking. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TDBaseVC.h"
NS_ASSUME_NONNULL_BEGIN

@interface TDHomeVC:TDBaseVC
@property(strong,nonatomic) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *commands;

@end

NS_ASSUME_NONNULL_END
