//
//  TDAutoTrackVC.m
//  ThinkingSDKDEMO
//
//  Created by LiHuanan on 2020/9/7.
//  Copyright © 2020 thinking. All rights reserved.
//

#import "TDAutoTrackVC.h"
#import "ActionModel.h"
#import "ThinkingSDKAPI.h"
#import "TDUtil.h"
#import "WEBViewController.h"
#import "WKWebViewController.h"
#import "AutoTrackViewController.h"
#import "AutoTableViewController.h"
#import "AutoCollectionViewController.h"
#import <ThinkingSDK/ThinkingAnalyticsSDK.h>
@interface TDAutoTrackVC ()

@end

@implementation TDAutoTrackVC
- (NSString*)rightTitle
{
    return @"自动埋点";
}

- (void)setData
{
    // 自动化采集自定义属性
    [[ThinkingAnalyticsSDK sharedInstance] enableAutoTrack:ThinkingAnalyticsEventTypeAll
                                                properties:@{@"auto_key1": @"auto_value1", @"auto_key2": @"auto_value2", @"auto_key3": @"auto_value3", @"auto_key4": @"auto_value4"}];
    
    // 更新自动化采集数据自定义属性
    [[ThinkingAnalyticsSDK sharedInstance] setAutoTrackProperties:ThinkingAnalyticsEventTypeAppClick properties: @{@"auto_key1@@@": @"auto_click"}];
    [[ThinkingAnalyticsSDK sharedInstance] setAutoTrackProperties:ThinkingAnalyticsEventTypeAppEnd properties: @{@"auto_key2": @"auto_end"}];
    [[ThinkingAnalyticsSDK sharedInstance] setAutoTrackProperties:ThinkingAnalyticsEventTypeAppStart properties: @{}];
    [[ThinkingAnalyticsSDK sharedInstance] setAutoTrackProperties:ThinkingAnalyticsEventTypeAppViewScreen properties: nil];

    
//    if (@available(iOS 10.0, *)) {
//        [[[NSThread alloc] initWithBlock:^{
//            [[ThinkingAnalyticsSDK sharedInstance] setAutoTrackProperties:ThinkingAnalyticsEventTypeAppClick properties: @{@"auto_key1": @"auto_click11"}];
//        }] start] ;
//
//        [[[NSThread alloc] initWithBlock:^{
//            [[ThinkingAnalyticsSDK sharedInstance] setAutoTrackProperties:ThinkingAnalyticsEventTypeAppEnd properties: @{@"auto_key2": @"auto_end11"}];
//        }] start] ;
//
//        [[[NSThread alloc] initWithBlock:^{
//            [[ThinkingAnalyticsSDK sharedInstance] setAutoTrackProperties:ThinkingAnalyticsEventTypeAppStart properties: @{@"auto_key3": @"auto_start11"}];
//        }] start] ;
//
//        [[[NSThread alloc] initWithBlock:^{
//            [[ThinkingAnalyticsSDK sharedInstance] setAutoTrackProperties:ThinkingAnalyticsEventTypeAppViewScreen properties: @{@"auto_key4": @"auto_view11"}];
//        }] start] ;
//
//
//    } else {
//        // Fallback on earlier versions
//    }
 
    
    
    self.commands = [NSMutableArray array];
    [self.commands addObject:[[ActionModel alloc]initWithName:@"UIViewController自动埋点" action:^{
        AutoTrackViewController *autoTrackVc = [[AutoTrackViewController alloc] init];
        [TDUtil.jsd_findVisibleViewController.navigationController pushViewController:autoTrackVc animated:YES];
    }]];
    [self.commands addObject:[[ActionModel alloc]initWithName:@"UITableView点击事件自动埋点" action:^{
        AutoTableViewController *autoTrackTVC = [[AutoTableViewController alloc] init];
        [TDUtil.jsd_findVisibleViewController.navigationController pushViewController:autoTrackTVC animated:YES];
    }]];
    [self.commands addObject:[[ActionModel alloc]initWithName:@"UICollectionView点击事件自动埋点" action:^{
        AutoCollectionViewController *autoCollectionVC = [[AutoCollectionViewController alloc] init];
        [TDUtil.jsd_findVisibleViewController.navigationController pushViewController:autoCollectionVC animated:YES];
    }]];
    
    
}
- (void)setView
{
    [super setView];
    UIButton* testBtn = [UIButton new];
    [self.view addSubview:testBtn];
    [testBtn setBackgroundColor:kTDColor];
    [testBtn setTitle:@"数数科技_Button" forState:UIControlStateNormal];
    [testBtn setTitleColor:UIColor.tc9 forState:UIControlStateNormal];
    [testBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(50);
        make.left.right.mas_equalTo(self.view);
        make.centerX.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.view).offset(-kTDBottomSafeHeight);
    }];
    [testBtn addTarget:self action:@selector(touchBtn) forControlEvents:UIControlEventTouchUpInside];
    
    
    // 1. 创建一个点击事件，点击时触发labelClick方法
    //    UITapGestureRecognizer *labelTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelTouchUpInside)];
    //    UILabel *label = [[UILabel alloc] init];
    //    label.text = @"数数科技_Label";
    //    label.font = [UIFont systemFontOfSize:kTDFontSize];
    //    label.textColor = UIColor.tc9;
    //    label.backgroundColor = kTDColor;
    //       // 2. 将点击事件添加到label上
    //    [label addGestureRecognizer:labelTapGestureRecognizer];
    //    label.userInteractionEnabled = YES; // 可以理解为设置label可被点击
    //    [self.view addSubview:label];
    //    [label mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.height.left.right.mas_equalTo(testBtn);
    //        make.bottom.mas_equalTo(testBtn.mas_top).offset(-kTDCommonMargin);
    //    }];
}

- (void)touchBtn
{
    
}
@end
