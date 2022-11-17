//
//  UIView+ThinkingAnalytics.h
//  ThinkingSDK
//
//  Created by 杨雄 on 2022/7/1.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (ThinkingAnalytics)

/**
设置控件元素 ID
 */
@property (copy,nonatomic) NSString *thinkingAnalyticsViewID;

/**
 配置 APPID 的控件元素 ID
 */
@property (strong,nonatomic) NSDictionary *thinkingAnalyticsViewIDWithAppid;

/**
 忽略某个控件的点击事件
 */
@property (nonatomic,assign) BOOL thinkingAnalyticsIgnoreView;

/**
 配置 APPID 的忽略某个控件的点击事件
 */
@property (strong,nonatomic) NSDictionary *thinkingAnalyticsIgnoreViewWithAppid;

/**
 自定义控件点击事件的属性
 */
@property (strong,nonatomic) NSDictionary *thinkingAnalyticsViewProperties;

/**
 配置 APPID 的自定义控件点击事件的属性
 */
@property (strong,nonatomic) NSDictionary *thinkingAnalyticsViewPropertiesWithAppid;

/**
 thinkingAnalyticsDelegate
 */
@property (nonatomic, weak, nullable) id thinkingAnalyticsDelegate;

@end

NS_ASSUME_NONNULL_END
