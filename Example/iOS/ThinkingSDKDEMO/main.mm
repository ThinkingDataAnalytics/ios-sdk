//
//  main.m
//  ThinkingSDKDEMO
//
//  Created by syj on 2019/6/24.
//  Copyright © 2019年 thinking. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "pthread.h"


int main(int argc, char * argv[]) {
    @autoreleasepool {
        
        
//        NSString *appid = @" 22e445595b0f4 2bd8c5fe35bc44b88d6 ";
//        NSString *url = @"https://thinkingdata_log.mm.blissgame.net/";
//        TDConfig *config = [TDConfig new];
//        config.appid = appid;
//        config.configureURL = url;
//    //    config.launchOptions = launchOptions;
//        [ThinkingAnalyticsSDK startWithConfig:config];
//        [ThinkingAnalyticsSDK setLogLevel:TDLoggingLevelDebug];
//        [[ThinkingAnalyticsSDK sharedInstance] enableAutoTrack:ThinkingAnalyticsEventTypeAll];
        
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
