//
//  TDMutiThread.h
//  ThinkingSDKDEMOUITests
//
//  Created by wwango on 2022/1/25.
//  Copyright © 2022 thinking. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TDMutiThread : NSObject

@property(nonatomic, strong)dispatch_group_t group;

@property(nonatomic, strong)dispatch_queue_t queue1;
@property(nonatomic, strong)dispatch_queue_t queue2;
@property(nonatomic, strong)dispatch_queue_t queue3;
@property(nonatomic, strong)dispatch_queue_t queue4;

- (void)dispatch_group_async1:(dispatch_block_t)block;

- (void)dispatch_group_async2:(dispatch_block_t)block;

- (void)dispatch_group_async3:(dispatch_block_t)block;

- (void)dispatch_group_async4:(dispatch_block_t)block;

- (void)dispatch_group_notify:(dispatch_block_t)block;

@end

NS_ASSUME_NONNULL_END
