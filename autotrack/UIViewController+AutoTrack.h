//
//  UIViewController+AutoTrack.h
//  TDAnalyticsSDK
//
//  Created by THINKINGDATA on 2018/5/3.
//  Copyright © 2018年 thinkingdata. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (AutoTrack)
- (void)td_autotrack_viewWillAppear:(BOOL)animated;
@end
