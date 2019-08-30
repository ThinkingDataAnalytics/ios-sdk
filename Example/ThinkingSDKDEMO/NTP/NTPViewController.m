//
//  NTPViewController.m
//  ThinkingSDKDEMO
//
//  Created by syj on 2019/8/16.
//  Copyright © 2019 thinking. All rights reserved.
//

#import "NTPViewController.h"
#import "NetAssociation.h"
#import <ThinkingSDK/ThinkingAnalyticsSDK.h>

@interface NTPViewController () {
     NetAssociation *        netAssociation;
}

@end

@implementation NTPViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self startCalibrateTime];
}

- (void)startCalibrateTime {
    netAssociation = [[NetAssociation alloc] initWithServerName:[NetAssociation ipAddrFromName:@"time.asia.apple.com"]];
    netAssociation.delegate = self;
    [netAssociation sendTimeQuery];
}

- (void)reportFromDelegate {
    NSDate *theDate = [[NSDate date] dateByAddingTimeInterval: -netAssociation.offset];
    [[ThinkingAnalyticsSDK sharedInstance] track:@"test_event" properties:@{} time:theDate];
}

@end
