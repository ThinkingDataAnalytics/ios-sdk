//
//  TrackAPIViewController.m
//  ThinkingSDKDEMO
//
//  Created by syj on 2019/6/24.
//  Copyright © 2019年 thinking. All rights reserved.
//

#import "TDHomeVC.h"
#import "APIEntry.h"
#import "TDTrackAPIListCell.h"
#import "ThinkingSDKAPI.h"
#import <ThinkingSDK/ThinkingAnalyticsSDK.h>

#import "ActionModel.h"
#import "TDUtil.h"
#import "TDEventVC.h"
#import "TDUserVC.h"
#import "TDOtherVC.h"
#import "TDInitVC.h"
#import "TDUserIDVC.h"
#import "TDAutoTrackVC.h"
#import "TDH5VC.h"
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
    NSString *homePath = NSHomeDirectory();
    
    NSLog(@"Home目录：%@",homePath);  
}

//- (TrackAPIViewController *)trackAPIVCWithApis:(NSArray *)commands {
//    TrackAPIViewController *apiController = [[TrackAPIViewController alloc] init];
//    [apiController.commands addObjectsFromArray:commands];
//    return apiController;
//}

- (void)setData
{
//    [ThinkingAnalyticsSDK startWithAppId:@"7a055a4bd7ec423fa5294b4a2c1eff28" withUrl:@"https://receiver-ta-dev.thinkingdata.cn"];
//    [ThinkingAnalyticsSDK setLogLevel:TDLoggingLevelDebug];
    self.commands = [NSMutableArray array];
    ActionModel *userModel =[[ActionModel alloc] initWithName:@"用户属性" action:^{
        TDUserVC *VC = [TDUserVC new];
        [[TDUtil jsd_findVisibleViewController].navigationController pushViewController:VC animated:YES];
    }];
    ActionModel *trackModel = [[ActionModel alloc] initWithName:@"发送事件" action:^{
        TDEventVC *VC = [TDEventVC new];
        [[TDUtil jsd_findVisibleViewController].navigationController pushViewController:VC animated:YES];
    }];
    ActionModel *otherModel = [[ActionModel alloc] initWithName:@"其他API" action:^{
        TDOtherVC *VC = [TDOtherVC new];
        [[TDUtil jsd_findVisibleViewController].navigationController pushViewController:VC animated:YES];
    }];
    ActionModel *userIDModel =[[ActionModel alloc] initWithName:@"设置访客ID" action:^{
        TDUserIDVC *VC = [TDUserIDVC new];
        [[TDUtil jsd_findVisibleViewController].navigationController pushViewController:VC animated:YES];
    }];
    ActionModel *autoModel =[[ActionModel alloc] initWithName:@"自动埋点" action:^{
        TDAutoTrackVC *VC = [TDAutoTrackVC new];
        [[TDUtil jsd_findVisibleViewController].navigationController pushViewController:VC animated:YES];
    }];
    ActionModel *h5Model =[[ActionModel alloc] initWithName:@"H5页面埋点" action:^{
        TDH5VC *VC = [TDH5VC new];
        [[TDUtil jsd_findVisibleViewController].navigationController pushViewController:VC animated:YES];
    }];
    ActionModel *initModel = [[ActionModel alloc] initWithName:@"初始化" action:^{
        TDInitVC *VC = [TDInitVC new];
        VC.callback = ^{
            [self.commands removeAllObjects];
            [self.commands addObject:userIDModel];
            [self.commands addObject:userModel];
            [self.commands addObject:trackModel];
            [self.commands addObject:autoModel];
            [self.commands addObject:h5Model];
            [self.commands addObject:otherModel];
            [self.tableView reloadData];
        };
        [TDUtil.currentVC.navigationController pushViewController:VC animated:YES];
        
    }];
    
//    [self.commands addObject:userIDModel];
//    [self.commands addObject:userModel];
//    [self.commands addObject:trackModel];
//    [self.commands addObject:autoModel];
//    [self.commands addObject:h5Model];
//    [self.commands addObject:otherModel];
    
    [self.commands addObject:initModel];
//
    // MARK: track
    
    //    [trackArray addObject:
    //     [APIEntry commandWithName:@"Track"
    //                 accessoryType:UITableViewCellAccessoryNone
    //                         block:^(UIViewController *controller)
    //      {
    //          [ThinkingSDKAPI testTrack];
    //      }]];
    
    
    
    //    [trackArray addObject:
    //     [APIEntry commandWithName:@"Track_DefaultFirstCheckID"
    //                 accessoryType:UITableViewCellAccessoryNone
    //                         block:^(UIViewController *controller)
    //      {
    //          [ThinkingSDKAPI testTrackWithDefaultFirstCheckID];
    //      }]];
    
    //    [trackArray addObject:
    //     [APIEntry commandWithName:@"Track_FirstCheckID"
    //                 accessoryType:UITableViewCellAccessoryNone
    //                         block:^(UIViewController *controller)
    //      {
    //          [ThinkingSDKAPI testTrackWithFirstCheckID];
    //      }]];
    
    //    [trackArray addObject:
    //     [APIEntry commandWithName:@"Track_Update"
    //                 accessoryType:UITableViewCellAccessoryNone
    //                         block:^(UIViewController *controller)
    //      {
    //          [ThinkingSDKAPI testTrackUpdate];
    //      }]];
    
    //    [trackArray addObject:
    //     [APIEntry commandWithName:@"Track_Overwrite"
    //                 accessoryType:UITableViewCellAccessoryNone
    //                         block:^(UIViewController *controller)
    //      {
    //          [ThinkingSDKAPI testTrackOverwrite];
    //      }]];
    
    //    [trackArray addObject:
    //     [APIEntry commandWithName:@"Track with property"
    //                 accessoryType:UITableViewCellAccessoryNone
    //                         block:^(UIViewController *controller)
    //      {
    //          [ThinkingSDKAPI testTrackWithProperty];
    //      }]];
    
    //    [trackArray addObject:
    //     [APIEntry commandWithName:@"Track With Timezone"
    //                 accessoryType:UITableViewCellAccessoryNone
    //                         block:^(UIViewController *controller)
    //      {
    //          [ThinkingSDKAPI testTrackWithTimezone];
    //      }]];
    
    // MARK: user
//    NSMutableArray<ActionModel*> *userArray = [NSMutableArray array];
//    [userArray addObject:[[ActionModel alloc] initWithName:@"User Set" action:^{
//        [ThinkingSDKAPI testUserSet];
//    }]];
//    [userArray addObject:[[ActionModel alloc] initWithName:@"User Unset" action:^{
//        [ThinkingSDKAPI testUserUnset];
//    }]];
//    [userArray addObject:[[ActionModel alloc] initWithName:@"User Set Once" action:^{
//        [ThinkingSDKAPI testUserSetonce];
//    }]];
//    [userArray addObject:[[ActionModel alloc] initWithName:@"User Del" action:^{
//        [ThinkingSDKAPI testUserDel];
//    }]];
//    [userArray addObject:[[ActionModel alloc] initWithName:@"User ADD" action:^{
//        [ThinkingSDKAPI testUserAdd];
//    }]];
//    [userArray addObject:[[ActionModel alloc] initWithName:@"User APPEND" action:^{
//        [ThinkingSDKAPI testUserAppend];
//    }]];
//    [userArray addObject:[[ActionModel alloc] initWithName:@"Login" action:^{
//        [ThinkingSDKAPI testLogin];
//    }]];
//    [userArray addObject:[[ActionModel alloc] initWithName:@"Logout" action:^{
//        [ThinkingSDKAPI testLogin];
//    }]];
    
    //    [userArray addObject:
    //     [APIEntry commandWithName:@"User Set"
    //                 accessoryType:UITableViewCellAccessoryNone
    //                         block:^(UIViewController *controller)
    //      {
    //          [ThinkingSDKAPI testUserSet];
    //      }]];
    //
    //    [userArray addObject:
    //     [APIEntry commandWithName:@"User Unset"
    //                 accessoryType:UITableViewCellAccessoryNone
    //                         block:^(UIViewController *controller)
    //      {
    //          [ThinkingSDKAPI testUserUnset];
    //      }]];
    //
    //    [userArray addObject:
    //     [APIEntry commandWithName:@"User Set Once"
    //                 accessoryType:UITableViewCellAccessoryNone
    //                         block:^(UIViewController *controller)
    //      {
    //          [ThinkingSDKAPI testUserSetonce];
    //      }]];
    
    //    [userArray addObject:
    //     [APIEntry commandWithName:@"User Del"
    //                 accessoryType:UITableViewCellAccessoryNone
    //                         block:^(UIViewController *controller)
    //      {
    //          [ThinkingSDKAPI testUserDel];
    //      }]];
    
    //    [userArray addObject:
    //     [APIEntry commandWithName:@"User ADD"
    //                 accessoryType:UITableViewCellAccessoryNone
    //                         block:^(UIViewController *controller)
    //      {
    //          [ThinkingSDKAPI testUserAdd];
    //      }]];
    
    //    [userArray addObject:
    //     [APIEntry commandWithName:@"User APPEND"
    //                 accessoryType:UITableViewCellAccessoryNone
    //                         block:^(UIViewController *controller)
    //      {
    //          [ThinkingSDKAPI testUserAppend];
    //      }]];
    
    //    [userArray addObject:
    //     [APIEntry commandWithName:@"Login"
    //                 accessoryType:UITableViewCellAccessoryNone
    //                         block:^(UIViewController *controller)
    //      {
    //          [ThinkingSDKAPI testLogin];
    //      }]];
    
    //    [userArray addObject:
    //     [APIEntry commandWithName:@"Logout"
    //                 accessoryType:UITableViewCellAccessoryNone
    //                         block:^(UIViewController *controller)
    //      {
    //          [ThinkingSDKAPI testLogout];
    //      }]];
    
    // MARK: options
    NSMutableArray *optionArray = [NSMutableArray array];
//    [optionArray addObject:[[ActionModel alloc]initWithName:@"Change Customer LibName & LibVersion" action:^{
//        [ThinkingSDKAPI testChangeLibNameAndLibVersion];
//    }]];
//    [optionArray addObject:[[ActionModel alloc]initWithName:@"Set SuperProperty" action:^{
//        [ThinkingSDKAPI testSetsuper];
//    }]];
//    [optionArray addObject:[[ActionModel alloc]initWithName:@"Unset SuperProperty" action:^{
//        [ThinkingSDKAPI testUnsetsuper];
//    }]];
//    [optionArray addObject:[[ActionModel alloc]initWithName:@"Clear SuperProperty" action:^{
//        [ThinkingSDKAPI testClearsuper];
//    }]];
//    [optionArray addObject:[[ActionModel alloc]initWithName:@"Time Event" action:^{
//        [ThinkingSDKAPI testTimedEvent];
//    }]];
//    [optionArray addObject:[[ActionModel alloc]initWithName:@"Time Event End" action:^{
//        [ThinkingSDKAPI testTrackEventEnd];
//    }]];
//    [optionArray addObject:[[ActionModel alloc]initWithName:@"Identify" action:^{
//        [ThinkingSDKAPI testIdentify];
//    }]];
//    [optionArray addObject:[[ActionModel alloc]initWithName:@"Flush" action:^{
//        [ThinkingSDKAPI testFlush];
//    }]];
//    [optionArray addObject:[[ActionModel alloc]initWithName:@"Enable" action:^{
//        [ThinkingSDKAPI testEnable];
//    }]];
//    [optionArray addObject:[[ActionModel alloc]initWithName:@"Disable" action:^{
//        [ThinkingSDKAPI testDisEnable];
//    }]];
//    [optionArray addObject:[[ActionModel alloc]initWithName:@"optOutTracking" action:^{
//        [ThinkingSDKAPI optOutTracking];
//    }]];
//    [optionArray addObject:[[ActionModel alloc]initWithName:@"optOutTrackingAndDeleteUser" action:^{
//        [ThinkingSDKAPI optOutTrackingAndDeleteUser];
//    }]];
//    [optionArray addObject:[[ActionModel alloc]initWithName:@"optInTracking" action:^{
//        [ThinkingSDKAPI optInTracking];
//    }]];
//    [optionArray addObject:[[ActionModel alloc]initWithName:@"More (AutoTrack,h5,轻实例...)" action:^{
//        TDHomeVC *cmdController = [TDHomeVC new];
////        cmdController.getTitleBlock = ^NSString * (__unused UIViewController *controllerInner)
////        {
////            return @"AutoTrack";
////        };
//        [[TDSDKDemoUtil jsd_findVisibleViewController].navigationController pushViewController:cmdController animated:YES];
//    }]];
    
    //    [optionArray addObject:
    //     [APIEntry commandWithName:@"Change Customer LibName & LibVersion"
    //                 accessoryType:UITableViewCellAccessoryNone
    //                         block:^(UIViewController *controller)
    //      {
    //          [ThinkingSDKAPI testChangeLibNameAndLibVersion];
    //      }]];
    //
    //    [optionArray addObject:
    //     [APIEntry commandWithName:@"Set SuperProperty"
    //                 accessoryType:UITableViewCellAccessoryNone
    //                         block:^(UIViewController *controller)
    //      {
    //          [ThinkingSDKAPI testSetsuper];
    //      }]];
    //
    //    [optionArray addObject:
    //     [APIEntry commandWithName:@"Unset SuperProperty"
    //                 accessoryType:UITableViewCellAccessoryNone
    //                         block:^(UIViewController *controller)
    //      {
    //          [ThinkingSDKAPI testUnsetsuper];
    //      }]];
    
    //    [optionArray addObject:
    //     [APIEntry commandWithName:@"Clear SuperProperty"
    //                 accessoryType:UITableViewCellAccessoryNone
    //                         block:^(UIViewController *controller)
    //      {
    //          [ThinkingSDKAPI testClearsuper];
    //      }]];
    
    //    [optionArray addObject:
    //     [APIEntry commandWithName:@"Time Event"
    //                 accessoryType:UITableViewCellAccessoryNone
    //                         block:^(UIViewController *controller)
    //      {
    //          [ThinkingSDKAPI testTimedEvent];
    //      }]];
    
    //    [optionArray addObject:
    //     [APIEntry commandWithName:@"Time Event End"
    //                 accessoryType:UITableViewCellAccessoryNone
    //                         block:^(UIViewController *controller)
    //      {
    //          [ThinkingSDKAPI testTrackEventEnd];
    //      }]];
    
    //    [optionArray addObject:
    //     [APIEntry commandWithName:@"Identify"
    //                 accessoryType:UITableViewCellAccessoryNone
    //                         block:^(UIViewController *controller)
    //      {
    //          [ThinkingSDKAPI testIdentify];
    //      }]];
    
    //    [optionArray addObject:
    //     [APIEntry commandWithName:@"Flush"
    //                 accessoryType:UITableViewCellAccessoryNone
    //                         block:^(UIViewController *controller)
    //      {
    //          [ThinkingSDKAPI testFlush];
    //      }]];
    
    //    [optionArray addObject:
    //     [APIEntry commandWithName:@"Enable"
    //                 accessoryType:UITableViewCellAccessoryNone
    //                         block:^(UIViewController *controller)
    //      {
    //          [ThinkingSDKAPI testEnable];
    //      }]];
    
    //    [optionArray addObject:
    //     [APIEntry commandWithName:@"DisEnable"
    //                 accessoryType:UITableViewCellAccessoryNone
    //                         block:^(UIViewController *controller)
    //      {
    //          [ThinkingSDKAPI testDisEnable];
    //      }]];
    
    //    [optionArray addObject:
    //     [APIEntry commandWithName:@"optOutTracking"
    //                 accessoryType:UITableViewCellAccessoryNone
    //                         block:^(UIViewController *controller)
    //      {
    //          [ThinkingSDKAPI optOutTracking];
    //      }]];
    
    //    [optionArray addObject:
    //     [APIEntry commandWithName:@"optOutTrackingAndDeleteUser"
    //                 accessoryType:UITableViewCellAccessoryNone
    //                         block:^(UIViewController *controller)
    //      {
    //          [ThinkingSDKAPI optOutTrackingAndDeleteUser];
    //      }]];
    
    //    [optionArray addObject:
    //     [APIEntry commandWithName:@"optInTracking"
    //                 accessoryType:UITableViewCellAccessoryNone
    //                         block:^(UIViewController *controller)
    //      {
    //          [ThinkingSDKAPI optInTracking];
    //      }]];
    //
    //    [optionArray addObject:
    //     [APIEntry commandWithName:@"More (AutoTrack,h5,轻实例...)"
    //                 accessoryType:UITableViewCellAccessoryNone
    //                         block:^(UIViewController *controller)
    //      {
    //          TrackAPIViewController *cmdController = [self trackAPIVCWithApis:[self autoTrackAPIs]];
    //          cmdController.getTitleBlock = ^NSString * (__unused UIViewController *controllerInner)
    //          {
    //              return @"AutoTrack";
    //          };
    //          [controller.navigationController pushViewController:cmdController animated:YES];
    //      }]];
    
//    [self.commands addObject:trackArray];
//    [self.commands addObject:userArray];
//    [self.commands addObject:optionArray];
    
}



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
   // [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
   // [self.navigationController setNavigationBarHidden:NO];
}

- (void)setView {
    [super setView];
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0,kTDScreenWidth, kTDScreenHeight) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = UIColor.mainColor;
    [self.view addSubview:self.tableView];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[TDTrackAPIListCell class] forCellReuseIdentifier:kTrackAPIListCellID];
    
    
}

//#pragma mark - Table view data source
//
//- (NSInteger)numberOfSectionsInTableView:(__unused UITableView *)tableView {
//    return self.commands.count;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    NSArray *array = self.commands[section];
//    return array.count;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return 60.;
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    TDTrackAPIListCell *cell = [tableView dequeueReusableCellWithIdentifier:kTrackAPIListCellID];
//    [cell configCellWithModel:self.commands[indexPath.section][indexPath.row]];
//    return cell;
//}
//
//#pragma mark - Table view delegate
//
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    ActionModel *actionModel = self.commands[indexPath.section][indexPath.row];
//    actionModel.action();
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//}

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
