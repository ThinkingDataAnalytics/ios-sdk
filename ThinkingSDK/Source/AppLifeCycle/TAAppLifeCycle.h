//
//  TAAppLifeCycle.h
//  ThinkingSDK
//
//  Created by 杨雄 on 2022/6/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// SDK 生命周期状态
typedef NS_ENUM(NSUInteger, TAAppLifeCycleState) {
    TAAppLifeCycleStateInit = 1, // 初始状态
    TAAppLifeCycleStateStart,
    TAAppLifeCycleStateEnd,
    TAAppLifeCycleStateTerminate,
};

/// 当生命周期状态将要改变时，会发送这个通知
/// object：对象为当前的生命周期对象
/// userInfo：包含 kTAAppLifeCycleNewStateKey 和 kTAAppLifeCycleOldStateKey 两个 key
extern NSNotificationName const kTAAppLifeCycleStateWillChangeNotification;

/// 当生命周期状态改变时，会发送这个通知
/// object：对象为当前的生命周期对象
/// userInfo：包含 kTAAppLifeCycleNewStateKey 和 kTAAppLifeCycleOldStateKey 两个 key
extern NSNotificationName const kTAAppLifeCycleStateDidChangeNotification;

/// 在状态改变通知中，获取新状态
extern NSString * const kTAAppLifeCycleNewStateKey;
/// 在状态改变通知中，获取改变前的状态
extern NSString * const kTAAppLifeCycleOldStateKey;

@interface TAAppLifeCycle : NSObject

@property (nonatomic, assign, readonly) TAAppLifeCycleState state;

/// 开启生命周期监听
+ (void)startMonitor;

+ (instancetype)shareInstance;

@end

NS_ASSUME_NONNULL_END
