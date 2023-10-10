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
@interface TDAutoTrackVC ()<TDUIViewAutoTrackDelegate>

@end

@implementation TDAutoTrackVC

- (NSDictionary *)thinkingAnalytics_tableView:(UITableView *)tableView autoTrackPropertiesAtIndexPath:(NSIndexPath *)indexPath {
    return @{@"auto_tableView_key1": @"name1"};;
}

- (NSString*)rightTitle
{
    return @"auto track";
}


- (void)enableAutoTrackNormal {
    NSDictionary *properties = @{@"auto_key1": @"auto_value1", @"auto_key2": @"auto_value2", @"auto_key3": @"auto_value3", @"auto_key4": @"auto_value4"};
    [TDAnalytics enableAutoTrack:TDAutoTrackEventTypeAll properties:properties];
}


- (void)enableAutoTrackWithCallbackInMainThread {
    
    [TDAnalytics enableAutoTrack:TDAutoTrackEventTypeAll callback:^NSDictionary * _Nonnull(TDAutoTrackEventType eventType, NSDictionary * _Nonnull properties) {
        return @{@"autoTrackCallbackTest": @"test1"};
    }];
}


- (void)enableAutoTrackWithCallbackInChildThread {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [TDAnalytics enableAutoTrack:TDAutoTrackEventTypeAll callback:^NSDictionary * _Nonnull(TDAutoTrackEventType eventType, NSDictionary * _Nonnull properties) {
            return @{@"autoTrackCallbackTest": @"test1"};
        }];
    });
}

- (void)setData
{
    [TDAnalytics setAutoTrackProperties:TDAutoTrackEventTypeAppClick properties: @{@"auto_key1": @"auto_click"}];
    [TDAnalytics setAutoTrackProperties:TDAutoTrackEventTypeAppEnd properties: @{@"auto_key2": @"auto_end"}];
    [TDAnalytics setAutoTrackProperties:TDAutoTrackEventTypeAppStart properties: @{}];
    [TDAnalytics setAutoTrackProperties:TDAutoTrackEventTypeAppViewScreen properties: nil];
    
    
    self.commands = [NSMutableArray array];
    [self.commands addObject:[[ActionModel alloc]initWithName:@"UIViewController auto-tracking" action:^{
        AutoTrackViewController *autoTrackVc = [[AutoTrackViewController alloc] init];
        [TDUtil.jsd_findVisibleViewController.navigationController pushViewController:autoTrackVc animated:YES];
    }]];
    [self.commands addObject:[[ActionModel alloc]initWithName:@"UITableView auto-tracking of button click" action:^{
        AutoTableViewController *autoTrackTVC = [[AutoTableViewController alloc] init];
        [TDUtil.jsd_findVisibleViewController.navigationController pushViewController:autoTrackTVC animated:YES];
    }]];
    [self.commands addObject:[[ActionModel alloc]initWithName:@"UICollectionView auto-tracking of view" action:^{
        AutoCollectionViewController *autoCollectionVC = [[AutoCollectionViewController alloc] init];
        [TDUtil.jsd_findVisibleViewController.navigationController pushViewController:autoCollectionVC animated:YES];
    }]];
    
    
}
- (void)setView
{
    [super setView];
    
    self.tableView.thinkingAnalyticsDelegate = self;
}

@end
