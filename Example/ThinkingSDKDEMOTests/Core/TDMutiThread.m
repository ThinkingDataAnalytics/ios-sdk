//
//  TDMutiThread.m
//  ThinkingSDKDEMOUITests
//
//  Created by wwango on 2022/1/25.
//  Copyright © 2022 thinking. All rights reserved.
//

#import "TDMutiThread.h"

@implementation TDMutiThread

- (instancetype)init
{
    self = [super init];
    if (self) {
        _group = dispatch_group_create();
        _queue1 = dispatch_queue_create("queue1", DISPATCH_QUEUE_SERIAL);
        _queue2 = dispatch_queue_create("queue2", DISPATCH_QUEUE_SERIAL);
        _queue3 = dispatch_queue_create("queue3", DISPATCH_QUEUE_SERIAL);
        _queue4 = dispatch_queue_create("queue4", DISPATCH_QUEUE_SERIAL);

    }
    return self;
}

- (void)dispatch_group_async1:(dispatch_block_t)block {
    dispatch_group_async(_group, _queue1, ^{
        block();
    });
}

- (void)dispatch_group_async2:(dispatch_block_t)block {
    dispatch_group_async(_group, _queue2, ^{
        block();
    });
}

- (void)dispatch_group_async3:(dispatch_block_t)block {
    dispatch_group_async(_group, _queue3, ^{
        block();
    });
}

- (void)dispatch_group_async4:(dispatch_block_t)block {
    dispatch_group_async(_group, _queue4, ^{
        block();
    });
}

- (void)dispatch_group_notify:(dispatch_block_t)block {
    dispatch_group_notify(_group, dispatch_get_main_queue(), ^{
        block();
    });
        
}


@end
