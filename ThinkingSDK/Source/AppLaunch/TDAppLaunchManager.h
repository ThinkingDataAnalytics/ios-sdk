//
//  TDAppLaunchManager.h
//  ThinkingSDK
//
//  Created by wwango on 2021/9/22.
//  Copyright © 2021 thinkingdata. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TDConfig.h"

typedef NS_OPTIONS(NSInteger, TDAppLaunchType) {
    TDAppLaunchTypeUnknown      = 0,
    TDAppLaunchTypeLink       = 1 << 0, // 通过链接打开APP，如scheme、ulink、传文件链接
    TDAppLaunchTypePush         = 1 << 2,// 本地推送、远程推送、VOIP
    TDAppLaunchType3DTouch      = 1 << 3,
};

NS_ASSUME_NONNULL_BEGIN

@interface TDAppLaunchManager : NSObject

@property (nonatomic, assign, readonly) TDAppLaunchType launchType;// 启动类型
@property (nonatomic, strong, readonly) id launchOptions;// 冷启动，didFinishLaunchingWithOptions的启动原因
@property (nonatomic, copy, readonly) NSString *launchLink;
@property (nonatomic, strong, readonly) NSDictionary *launchPush;

+ (nullable TDAppLaunchManager *)sharedInstance;

/// 设置启动参数， 针对冷启动
- (void)setLaunchOptions:(id)launchOptions;

/// 设置启动参数， 针对热启动
- (void)setLaunchOptions:(id)launchOptions launchType:(TDAppLaunchType)launchType;
//- (void)setLaunchOptions:(TDAppLaunchType)launchType launchOptions:(id)items, ...;

/// 获取启动原因
- (nullable NSDictionary *)getLaunchDic;

/// 清除该启动参数
- (void)clearData;

@end

NS_ASSUME_NONNULL_END
