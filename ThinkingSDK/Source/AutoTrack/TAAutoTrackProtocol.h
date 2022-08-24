//
//  TAAutoTrackProtocol.h
//  ThinkingSDK
//
//  Created by 杨雄 on 2022/7/1.
//

#ifndef TAAutoTrackProtocol_h
#define TAAutoTrackProtocol_h

#import <UIKit/UIKit.h>

/**
 自动埋点设置属性
 */
@protocol TDUIViewAutoTrackDelegate

@optional

/**
 UITableView 事件属性

 @return 事件属性
 */
- (NSDictionary *)thinkingAnalytics_tableView:(UITableView *)tableView autoTrackPropertiesAtIndexPath:(NSIndexPath *)indexPath;

/**
 APPID UITableView 事件属性
 
 @return 事件属性
 */
- (NSDictionary *)thinkingAnalyticsWithAppid_tableView:(UITableView *)tableView autoTrackPropertiesAtIndexPath:(NSIndexPath *)indexPath;

@optional

/**
 UICollectionView 事件属性

 @return 事件属性
 */
- (NSDictionary *)thinkingAnalytics_collectionView:(UICollectionView *)collectionView autoTrackPropertiesAtIndexPath:(NSIndexPath *)indexPath;

/**
 APPID UICollectionView 事件属性

 @return 事件属性
 */
- (NSDictionary *)thinkingAnalyticsWithAppid_collectionView:(UICollectionView *)collectionView autoTrackPropertiesAtIndexPath:(NSIndexPath *)indexPath;

@end

/**
 页面自动埋点
 */
@protocol TDAutoTracker

@optional

/**
 自定义页面浏览事件的属性

 @return 事件属性
 */
- (NSDictionary *)getTrackProperties;

/**
 配置 APPID 自定义页面浏览事件的属性

 @return 事件属性
 */
- (NSDictionary *)getTrackPropertiesWithAppid;

@end

/**
 页面自动埋点
 */
@protocol TDScreenAutoTracker <TDAutoTracker>

@optional

/**
 自定义页面浏览事件的属性

 @return 预置属性 #url 的值
 */
- (NSString *)getScreenUrl;

/**
 配置 APPID 自定义页面浏览事件的属性

 @return 预置属性 #url 的值
 */
- (NSDictionary *)getScreenUrlWithAppid;

@end

#endif /* TAAutoTrackProtocol_h */
