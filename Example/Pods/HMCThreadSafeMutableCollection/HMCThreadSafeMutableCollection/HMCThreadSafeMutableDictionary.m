//
//  HMCtsMutableDictionary.m
//  HMCtsMutableDictionary
//
//  Created by chuongh on 8/9/17.
//  Copyright © 2017 Chương M. Huỳnh. All rights reserved.
//

#import "HMCThreadSafeMutableDictionary.h"

@interface HMCThreadSafeMutableDictionary()

@property (strong,nonatomic) NSMutableDictionary *internalDictionary;
@property (nonatomic) dispatch_queue_t tsQueue;

@end

@implementation HMCThreadSafeMutableDictionary

- (instancetype)init {
    
    self = [super init];
    
    _internalDictionary = [[NSMutableDictionary alloc]init];
    _tsQueue = dispatch_queue_create("com.vn.hmchuong.HMCThreadSafeMutableDictionary", NULL);
    
    return self;
}

- (id)objectForKeyedSubscript:(id)key {
    
    NSObject *__block result;
    dispatch_sync(_tsQueue, ^{
        result = _internalDictionary[key];
    });
    
    return result;
}

- (void)setObject:(id)obj forKeyedSubscript:(id<NSCopying>)key {
    
    dispatch_async(_tsQueue, ^{
        _internalDictionary[key] = obj;
    });
}

- (NSDictionary *)toNSDictionary {
    
    NSDictionary *__block result;
    dispatch_sync(_tsQueue, ^{
        result = _internalDictionary;
    });
    
    return result;
}

- (void)removeObjectForkey:(NSString *)key {
    
    dispatch_async(_tsQueue, ^{
        [_internalDictionary removeObjectForKey:key];
    });
}

- (void)removeAllObjects {
    
    dispatch_async(_tsQueue, ^{
        [_internalDictionary removeAllObjects];
    });
}

@end
