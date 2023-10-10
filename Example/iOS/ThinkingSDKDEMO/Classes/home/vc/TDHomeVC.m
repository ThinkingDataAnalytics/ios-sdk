//
//  TrackAPIViewController.m
//  ThinkingSDKDEMO
//
//  Created by syj on 2019/6/24.
//  Copyright © 2019 thinking. All rights reserved.
//

#import "TDHomeVC.h"
#import "APIEntry.h"
#import "TDTrackAPIListCell.h"
#import "ThinkingSDKAPI.h"
#import <ThinkingSDK/ThinkingAnalyticsSDK.h>
#import "TDMacro.h"
#import "UIColor+TDUtil.h"

#import "ActionModel.h"
#import "TDUtil.h"
#import "TDEventVC.h"
#import "TDUserVC.h"
#import "TDOtherVC.h"
#import "TDInitVC.h"
#import "TDUserIDVC.h"
#import "TDAutoTrackVC.h"
#import "TDH5VC.h"
#import "TDAPMViewController.h"

static NSString *const kTrackAPIListCellID = @"kTrackAPIListCellID";

@interface TDHomeVC ()<UITableViewDelegate,UITableViewDataSource,TDScreenAutoTracker>



@end

@implementation TDHomeVC
- (NSString*)getScreenUrl
{
    return @"ZZZZ";
}
- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0,kTDScreenWidth, kTDScreenHeight) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = UIColor.mainColor;
    [self.view addSubview:self.tableView];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[TDTrackAPIListCell class] forCellReuseIdentifier:kTrackAPIListCellID];
}

- (NSDictionary *)getTrackPropertiesWithAppid {
    return @{@"instanceName1" : @{@"auto_key1" : @"auto_value1"},
             @"instanceName2" : @{@"auto_key2" : @"auto_value2"},
             @"instanceName3" : @{@"auto_key3" : @"auto_value3"},
             @"22e445595b0f42bd8c5fe35bc44b88d6" : @{@"auto_key" : @"auto_value"},
            };
}

- (void)setData
{
    self.commands = [NSMutableArray array];
    ActionModel *userModel =[[ActionModel alloc] initWithName:@"user property" action:^{
        TDUserVC *VC = [TDUserVC new];
        [[TDUtil jsd_findVisibleViewController].navigationController pushViewController:VC animated:YES];
    }];
    ActionModel *trackModel = [[ActionModel alloc] initWithName:@"track event" action:^{
        TDEventVC *VC = [TDEventVC new];
        [[TDUtil jsd_findVisibleViewController].navigationController pushViewController:VC animated:YES];
    }];
    ActionModel *otherModel = [[ActionModel alloc] initWithName:@"other API" action:^{
        TDOtherVC *VC = [TDOtherVC new];
        [[TDUtil jsd_findVisibleViewController].navigationController pushViewController:VC animated:YES];
    }];
    ActionModel *userIDModel =[[ActionModel alloc] initWithName:@"set distinct ID" action:^{
        TDUserIDVC *VC = [TDUserIDVC new];
        [[TDUtil jsd_findVisibleViewController].navigationController pushViewController:VC animated:YES];
    }];
    ActionModel *autoModel =[[ActionModel alloc] initWithName:@"auto-tracking" action:^{
        TDAutoTrackVC *VC = [TDAutoTrackVC new];
        [[TDUtil jsd_findVisibleViewController].navigationController pushViewController:VC animated:YES];
    }];
    ActionModel *h5Model =[[ActionModel alloc] initWithName:@"H5 auto-tracking of Page" action:^{
        TDH5VC *VC = [TDH5VC new];
        [[TDUtil jsd_findVisibleViewController].navigationController pushViewController:VC animated:YES];
    }];
    
    ActionModel *apmModel =[[ActionModel alloc] initWithName:@"APM of Page" action:^{
        TDAPMViewController *VC = [TDAPMViewController new];
        [[TDUtil jsd_findVisibleViewController].navigationController pushViewController:VC animated:YES];
    }];
    
    __weak typeof(self) weakSelf = self;
    ActionModel *initModel = [[ActionModel alloc] initWithName:@"initialization" action:^{
        TDInitVC *VC = [TDInitVC new];
        VC.callback = ^{
            [weakSelf.commands removeAllObjects];
            [weakSelf.commands addObject:userIDModel];
            [weakSelf.commands addObject:userModel];
            [weakSelf.commands addObject:trackModel];
            [weakSelf.commands addObject:autoModel];
            [weakSelf.commands addObject:h5Model];
            [weakSelf.commands addObject:otherModel];
            [weakSelf.commands addObject:apmModel];
            [weakSelf.tableView reloadData];
        };
        [TDUtil.currentVC.navigationController pushViewController:VC animated:YES];
        
    }];

    [self.commands addObject:initModel];
}

- (void)setView {
    [super setView];
    
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.commands.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TDTrackAPIListCell *cell = [tableView dequeueReusableCellWithIdentifier:kTrackAPIListCellID];
    [cell configCellWithModel:self.commands[indexPath.row]];
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ActionModel *actionModel = self.commands[indexPath.row];
    actionModel.action();
   
}

@end
