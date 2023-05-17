//
//  Tracking.h
//  ReYun_Tracking
//
//  Created by jesse on 2018/1/19.
//  Copyright © 2018年 yun. All rights reserved.
//
#define REYUN_TRACKING_VERSION @"1.9.0"
#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN

//deeplink callback 代理
@protocol DeferredDeeplinkCalllback <NSObject>
@required
- (void)onDeferredDeeplinkCalllback:(NSDictionary *)params;
@end

//激活归因回调代理
@protocol OnAttributionCallbackProtocol <NSObject>
@required
- (void)OnAttribution:(nullable NSString *)result status:(NSUInteger)httpStatus;
@end


@interface Tracking : NSObject

//开启打印日志(在initWithAppKey:withChannelId:前调用)
//正式上线包请关掉
+(void) setPrintLog :(BOOL)print;
// 开启数据统计
+ (void)initWithAppKey:(NSString *)appKey withChannelId:(NSString *)channelId;
//注册成功后调用
+ (void)setRegisterWithAccountID:(NSString *)account;
//登陆成功后调用
+ (void)setLoginWithAccountID:(NSString *)account;
//生成订单
+(void)setDD:(NSString *)ryTID hbType:(NSString*)hbType hbAmount:(float)hbAmount;
// 支付完成，付费分析,记录玩家充值的金额（人民币单位是元）
+(void)setRyzf:(NSString *)ryTID ryzfType:(NSString*)ryzfType hbType:(NSString*)hbType hbAmount:(float)hbAmount;
//广告展示时调用 playSuccess 参数调用广告填充成功时传1  不成功时传2
+(void)onAdShow:(NSString *)adPlatform adId:(NSString *)adId isSuccess:(int)playSuccess;
//广告点击时调用
+(void)onAdClick:(NSString *)adPlatform adId:(NSString *)adId;
//页面时长监测
+(void)trackViewName:(NSString *)pageID duration:(long)duration;
//APP使用时长监测
+(void)setTrackAppDuration:(long)duration;
//自定义事件
+(void)setEvent:(NSString *)eventName param:(nullable NSDictionary *)custom_params;
//获取设备信息
+(NSString*)getDeviceId;

@end

@interface Tracking(DeepLink)
//延迟深度链接回调代理设置
+(void)setDeferredDeeplinkCalllbackDelegate:(id<DeferredDeeplinkCalllback>) delegate ;
@end

@interface Tracking(Attribution)
//激活归因回调代理设置
+(void)setAttributionCalllbackDelegate:(id<OnAttributionCallbackProtocol>) delegate ;
@end


NS_ASSUME_NONNULL_END
