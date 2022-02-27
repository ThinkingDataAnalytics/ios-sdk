//
//  HMCThreadSafeMutableArray.m
//  HMCThreadSafeMutableArray
//
//  Created by hmchuong on 7/24/17.
//  Copyright © 2017 Chương M. Huỳnh. All rights reserved.
//

#import "HMCThreadSafeMutableArray.h"

@interface HMCThreadSafeMutableArray()

@property (strong,nonatomic) NSMutableArray *internalArray;
@property (nonatomic) dispatch_queue_t tsQueue;

@end

@implementation HMCThreadSafeMutableArray

- (instancetype)init {
    self = [super init];
    
    _internalArray = [[NSMutableArray alloc]init];
    _tsQueue = dispatch_queue_create("com.vn.hmchuong.HMCThreadSafeMutableArray", NULL);
    
    return self;
}

- (instancetype)initWithArray:(NSArray *)array {
    self = [super init];
    if (array == nil || [array count] == 0) {
        NSLog(@"Array must be nonnull and nonempty");
        _internalArray = [[NSMutableArray alloc]init];
    } else {
        _internalArray = [[NSMutableArray alloc] initWithArray:array copyItems:NO];
    }
    _tsQueue = dispatch_queue_create("com.hmchuong.HMCThreadSafeMutableArray", NULL);
    
    return self;
}

- (void)addObject:(NSObject *)object {
    // Valid input object
    if (object == nil) {
        NSLog(@"Object must be nonnull");
        return;
    }
    
    // Add to array
    dispatch_async(_tsQueue, ^{
        [_internalArray addObject:object];
    });
}


- (void)addObjectsFromArray:(NSArray *)array {
    // Valid input array
    if (array == nil) {
        NSLog(@"Array must be nonnull");
        return;
    }
    
    if ([array count] == 0) {
        NSLog(@"Array must be not empty");
        return;
    }
    
    // Add objects from array
    dispatch_async(_tsQueue, ^{
        [_internalArray addObjectsFromArray:array];
    });
}


- (void)insertObject:(NSObject *)object
             atIndex:(NSUInteger)index {
    // Valid input object
    if (object == nil) {
        NSLog(@"Object must be nonnull");
        return;
    }
    
    // Valid input index
    NSUInteger numberOfElements = [self count];
    if (index > numberOfElements) {
        NSLog(@"Index %lu is out of range [0..%lu]",(unsigned long)index,(unsigned long)numberOfElements);
        return;
    }
    
    // Insert to array
    dispatch_async(_tsQueue, ^{
        [_internalArray insertObject:object atIndex:index];
    });
}

- (void)removeObject:(NSObject *)object {
    // Valid input object
    if (object == nil) {
        NSLog(@"Object must be nonnull");
        return;
    }
    
    // Remove object from array
    dispatch_async(_tsQueue, ^{
        [_internalArray removeObject:object];
    });
}

- (void)removeObjectAtIndex:(NSUInteger)index {
    // Valid input index
    NSUInteger numberOfElements = [self count];
    if (index >= numberOfElements) {
        NSLog(@"Index is out of range");
        return;
    }
    
    // Remove object at index from array
    dispatch_async(_tsQueue, ^{
        [_internalArray removeObjectAtIndex:index];
    });
}

- (void)removeAllObjects {
    // Check nonempty array
    NSUInteger numberOfElements = [self count];
    if (numberOfElements == 0) {
        NSLog(@"Array is empty");
        return;
    }
    
    // Remove all objects from array
    dispatch_async(_tsQueue, ^{
        [_internalArray removeAllObjects];
    });
}

- (id)objectAtIndex:(NSUInteger)index {
    // Valid input index
    NSUInteger numberOfElements = [self count];
    if (index >= numberOfElements) {
        NSLog(@"Index %lu is out of range [0..%lu]",(unsigned long)index,(unsigned long)numberOfElements);
        return nil;
    }
    
    // Return object at index in array
    id __block object;
    dispatch_sync(_tsQueue, ^{
        object = [_internalArray objectAtIndex:index];
    });
    return object;
}

- (NSUInteger) count {
    NSUInteger __block count;
    dispatch_sync(_tsQueue, ^{
        count = [_internalArray count];
    });
    return count;
}

- (NSArray *) filteredArrayUsingPredicate:(NSPredicate *)predicate {
    
    NSArray __block *result;
    dispatch_sync(_tsQueue, ^{
        result = [_internalArray filteredArrayUsingPredicate:predicate];
    });
    return result;
}

- (NSInteger)indexOfObject: (NSObject *)object {
    
    NSInteger __block result;
    dispatch_sync(_tsQueue, ^{
        result = [_internalArray indexOfObject:object];
    });
    return result;
}

- (BOOL)containsObject: (id)object {
    
    BOOL __block result;
    dispatch_sync(_tsQueue, ^{
        result = [_internalArray containsObject:object];
    });
    return result;
}

- (NSArray *)toNSArray {
    
    NSArray __block *array;
    dispatch_sync(_tsQueue, ^{
        array = [[NSArray alloc] initWithArray:_internalArray];
    });
    return array;
}

@end
