//
//  TEImageCache.m
//  TEWebImage <https://github.com/ibireme/TEWebImage>
//
//  Created by ibireme on 15/2/15.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "TEImageCache.h"
#import "TEImage.h"
#import "UIImage+TEWebImage.h"

#if __has_include(<TEImage/TEImage.h>)
#import <TEImage/TEImage.h>
#else
#import "TEImage.h"
#endif

#if __has_include(<TECache/TECache.h>)
#import <TECache/TECache.h>
#else
#import "TECache.h"
#endif



static inline dispatch_queue_t TEImageCacheIOQueue() {
    return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
}

static inline dispatch_queue_t TEImageCacheDecodeQueue() {
    return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
}


@interface TEImageCache ()
- (NSUInteger)imageCost:(UIImage *)image;
- (UIImage *)imageFromData:(NSData *)data;
@end


@implementation TEImageCache

- (NSUInteger)imageCost:(UIImage *)image {
    CGImageRef cgImage = image.CGImage;
    if (!cgImage) return 1;
    CGFloat height = CGImageGetHeight(cgImage);
    size_t bytesPerRow = CGImageGetBytesPerRow(cgImage);
    NSUInteger cost = bytesPerRow * height;
    if (cost == 0) cost = 1;
    return cost;
}

- (UIImage *)imageFromData:(NSData *)data {
    NSData *scaleData = [TEDiskCache getExtendedDataFromObject:data];
    CGFloat scale = 0;
    if (scaleData) {
        scale = ((NSNumber *)[NSKeyedUnarchiver unarchiveObjectWithData:scaleData]).doubleValue;
    }
    if (scale <= 0) scale = [UIScreen mainScreen].scale;
    UIImage *image;
    if (_allowAnimatedImage) {
        image = [[TEImage alloc] initWithData:data scale:scale];
        if (_decodeForDisplay) image = [image te_imageByDecoded];
    } else {
        TEImageDecoder *decoder = [TEImageDecoder decoderWithData:data scale:scale];
        image = [decoder frameAtIndex:0 decodeForDisplay:_decodeForDisplay].image;
    }
    return image;
}

#pragma mark Public

+ (instancetype)sharedCache {
    static TEImageCache *cache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory,
                                                                   NSUserDomainMask, YES) firstObject];
        cachePath = [cachePath stringByAppendingPathComponent:@"com.ibireme.yykit"];
        cachePath = [cachePath stringByAppendingPathComponent:@"images"];
        cache = [[self alloc] initWithPath:cachePath];
    });
    return cache;
}

- (instancetype)init {
    @throw [NSException exceptionWithName:@"TEImageCache init error" reason:@"TEImageCache must be initialized with a path. Use 'initWithPath:' instead." userInfo:nil];
    return [self initWithPath:@""];
}

- (instancetype)initWithPath:(NSString *)path {
    TEMemoryCache *memoryCache = [TEMemoryCache new];
    memoryCache.shouldRemoveAllObjectsOnMemoryWarning = YES;
    memoryCache.shouldRemoveAllObjectsWhenEnteringBackground = YES;
    memoryCache.countLimit = NSUIntegerMax;
    memoryCache.costLimit = NSUIntegerMax;
    memoryCache.ageLimit = 12 * 60 * 60;
    
    TEDiskCache *diskCache = [[TEDiskCache alloc] initWithPath:path];
    diskCache.customArchiveBlock = ^(id object) { return (NSData *)object; };
    diskCache.customUnarchiveBlock = ^(NSData *data) { return (id)data; };
    if (!memoryCache || !diskCache) return nil;
    
    self = [super init];
    _memoryCache = memoryCache;
    _diskCache = diskCache;
    _allowAnimatedImage = YES;
    _decodeForDisplay = YES;
    return self;
}

- (void)setImage:(UIImage *)image forKey:(NSString *)key {
    [self setImage:image imageData:nil forKey:key withType:TEImageCacheTypeAll];
}

- (void)setImage:(UIImage *)image imageData:(NSData *)imageData forKey:(NSString *)key withType:(TEImageCacheType)type {
    if (!key || (image == nil && imageData.length == 0)) return;
    
    __weak typeof(self) _self = self;
    if (type & TEImageCacheTypeMemory) { // add to memory cache
        if (image) {
            if (image.te_isDecodedForDisplay) {
                [_memoryCache setObject:image forKey:key withCost:[_self imageCost:image]];
            } else {
                dispatch_async(TEImageCacheDecodeQueue(), ^{
                    __strong typeof(_self) self = _self;
                    if (!self) return;
                    [self.memoryCache setObject:[image te_imageByDecoded] forKey:key withCost:[self imageCost:image]];
                });
            }
        } else if (imageData) {
            dispatch_async(TEImageCacheDecodeQueue(), ^{
                __strong typeof(_self) self = _self;
                if (!self) return;
                UIImage *newImage = [self imageFromData:imageData];
                [self.memoryCache setObject:newImage forKey:key withCost:[self imageCost:newImage]];
            });
        }
    }
    if (type & TEImageCacheTypeDisk) { // add to disk cache
        if (imageData) {
            if (image) {
                [TEDiskCache setExtendedData:[NSKeyedArchiver archivedDataWithRootObject:@(image.scale)] toObject:imageData];
            }
            [_diskCache setObject:imageData forKey:key];
        } else if (image) {
            dispatch_async(TEImageCacheIOQueue(), ^{
                __strong typeof(_self) self = _self;
                if (!self) return;
                NSData *data = [image te_imageDataRepresentation];
                [TEDiskCache setExtendedData:[NSKeyedArchiver archivedDataWithRootObject:@(image.scale)] toObject:data];
                [self.diskCache setObject:data forKey:key];
            });
        }
    }
}

- (void)removeImageForKey:(NSString *)key {
    [self removeImageForKey:key withType:TEImageCacheTypeAll];
}

- (void)removeImageForKey:(NSString *)key withType:(TEImageCacheType)type {
    if (type & TEImageCacheTypeMemory) [_memoryCache removeObjectForKey:key];
    if (type & TEImageCacheTypeDisk) [_diskCache removeObjectForKey:key];
}

- (BOOL)containsImageForKey:(NSString *)key {
    return [self containsImageForKey:key withType:TEImageCacheTypeAll];
}

- (BOOL)containsImageForKey:(NSString *)key withType:(TEImageCacheType)type {
    if (type & TEImageCacheTypeMemory) {
        if ([_memoryCache containsObjectForKey:key]) return YES;
    }
    if (type & TEImageCacheTypeDisk) {
        if ([_diskCache containsObjectForKey:key]) return YES;
    }
    return NO;
}

- (UIImage *)getImageForKey:(NSString *)key {
    return [self getImageForKey:key withType:TEImageCacheTypeAll];
}

- (UIImage *)getImageForKey:(NSString *)key withType:(TEImageCacheType)type {
    if (!key) return nil;
    if (type & TEImageCacheTypeMemory) {
        UIImage *image = [_memoryCache objectForKey:key];
        if (image) return image;
    }
    if (type & TEImageCacheTypeDisk) {
        NSData *data = (id)[_diskCache objectForKey:key];
        UIImage *image = [self imageFromData:data];
        if (image && (type & TEImageCacheTypeMemory)) {
            [_memoryCache setObject:image forKey:key withCost:[self imageCost:image]];
        }
        return image;
    }
    return nil;
}

- (void)getImageForKey:(NSString *)key withType:(TEImageCacheType)type withBlock:(void (^)(UIImage *image, TEImageCacheType type))block {
    if (!block) return;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *image = nil;
        
        if (type & TEImageCacheTypeMemory) {
            image = [_memoryCache objectForKey:key];
            if (image) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    block(image, TEImageCacheTypeMemory);
                });
                return;
            }
        }
        
        if (type & TEImageCacheTypeDisk) {
            NSData *data = (id)[_diskCache objectForKey:key];
            image = [self imageFromData:data];
            if (image) {
                [_memoryCache setObject:image forKey:key];
                dispatch_async(dispatch_get_main_queue(), ^{
                    block(image, TEImageCacheTypeDisk);
                });
                return;
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            block(nil, TEImageCacheTypeNone);
        });
    });
}

- (NSData *)getImageDataForKey:(NSString *)key {
    return (id)[_diskCache objectForKey:key];
}

- (void)getImageDataForKey:(NSString *)key withBlock:(void (^)(NSData *imageData))block {
    if (!block) return;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *data = (id)[_diskCache objectForKey:key];
        dispatch_async(dispatch_get_main_queue(), ^{
            block(data);
        });
    });
}

@end
