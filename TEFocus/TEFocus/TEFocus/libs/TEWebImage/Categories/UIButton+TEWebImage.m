//
//  UIButton+TEWebImage.m
//  TEWebImage <https://github.com/ibireme/TEWebImage>
//
//  Created by ibireme on 15/2/23.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "UIButton+TEWebImage.h"
#import "TEWebImageOperation.h"
#import "_TEWebImageSetter.h"
#import <objc/runtime.h>

// Dummy class for category
@interface UIButton_TEWebImage : NSObject @end
@implementation UIButton_TEWebImage @end

static inline NSNumber *UIControlStateSingle(UIControlState state) {
    if (state & UIControlStateHighlighted) return @(UIControlStateHighlighted);
    if (state & UIControlStateDisabled) return @(UIControlStateDisabled);
    if (state & UIControlStateSelected) return @(UIControlStateSelected);
    return @(UIControlStateNormal);
}

static inline NSArray *UIControlStateMulti(UIControlState state) {
    NSMutableArray *array = [NSMutableArray new];
    if (state & UIControlStateHighlighted) [array addObject:@(UIControlStateHighlighted)];
    if (state & UIControlStateDisabled) [array addObject:@(UIControlStateDisabled)];
    if (state & UIControlStateSelected) [array addObject:@(UIControlStateSelected)];
    if ((state & 0xFF) == 0) [array addObject:@(UIControlStateNormal)];
    return array;
}

static int _TEWebImageSetterKey;
static int _TEWebImageBackgroundSetterKey;


@interface _TEWebImageSetterDicForButton : NSObject
- (_TEWebImageSetter *)setterForState:(NSNumber *)state;
- (_TEWebImageSetter *)lazySetterForState:(NSNumber *)state;
@end

@implementation _TEWebImageSetterDicForButton {
    NSMutableDictionary *_dic;
    dispatch_semaphore_t _lock;
}
- (instancetype)init {
    self = [super init];
    _lock = dispatch_semaphore_create(1);
    _dic = [NSMutableDictionary new];
    return self;
}
- (_TEWebImageSetter *)setterForState:(NSNumber *)state {
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    _TEWebImageSetter *setter = _dic[state];
    dispatch_semaphore_signal(_lock);
    return setter;
    
}
- (_TEWebImageSetter *)lazySetterForState:(NSNumber *)state {
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    _TEWebImageSetter *setter = _dic[state];
    if (!setter) {
        setter = [_TEWebImageSetter new];
        _dic[state] = setter;
    }
    dispatch_semaphore_signal(_lock);
    return setter;
}
@end


@implementation UIButton (TEWebImage)

#pragma mark - image

- (void)_te_setImageWithURL:(NSURL *)imageURL
             forSingleState:(NSNumber *)state
                placeholder:(UIImage *)placeholder
                    options:(TEWebImageOptions)options
                    manager:(TEWebImageManager *)manager
                   progress:(TEWebImageProgressBlock)progress
                  transform:(TEWebImageTransformBlock)transform
                 completion:(TEWebImageCompletionBlock)completion {
    if ([imageURL isKindOfClass:[NSString class]]) imageURL = [NSURL URLWithString:(id)imageURL];
    manager = manager ? manager : [TEWebImageManager sharedManager];
    
    _TEWebImageSetterDicForButton *dic = objc_getAssociatedObject(self, &_TEWebImageSetterKey);
    if (!dic) {
        dic = [_TEWebImageSetterDicForButton new];
        objc_setAssociatedObject(self, &_TEWebImageSetterKey, dic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    _TEWebImageSetter *setter = [dic lazySetterForState:state];
    int32_t sentinel = [setter cancelWithNewURL:imageURL];
    
    _te_dispatch_sync_on_main_queue(^{
        if (!imageURL) {
            if (!(options & TEWebImageOptionIgnorePlaceHolder)) {
                [self setImage:placeholder forState:state.integerValue];
            }
            return;
        }
        
        // get the image from memory as quickly as possible
        UIImage *imageFromMemory = nil;
        if (manager.cache &&
            !(options & TEWebImageOptionUseNSURLCache) &&
            !(options & TEWebImageOptionRefreshImageCache)) {
            imageFromMemory = [manager.cache getImageForKey:[manager cacheKeyForURL:imageURL] withType:TEImageCacheTypeMemory];
        }
        if (imageFromMemory) {
            if (!(options & TEWebImageOptionAvoidSetImage)) {
                [self setImage:imageFromMemory forState:state.integerValue];
            }
            if(completion) completion(imageFromMemory, imageURL, TEWebImageFromMemoryCacheFast, TEWebImageStageFinished, nil);
            return;
        }
        
        
        if (!(options & TEWebImageOptionIgnorePlaceHolder)) {
            [self setImage:placeholder forState:state.integerValue];
        }
        
        __weak typeof(self) _self = self;
        dispatch_async([_TEWebImageSetter setterQueue], ^{
            TEWebImageProgressBlock _progress = nil;
            if (progress) _progress = ^(NSInteger receivedSize, NSInteger expectedSize) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    progress(receivedSize, expectedSize);
                });
            };
            
            __block int32_t newSentinel = 0;
            __block __weak typeof(setter) weakSetter = nil;
            TEWebImageCompletionBlock _completion = ^(UIImage *image, NSURL *url, TEWebImageFromType from, TEWebImageStage stage, NSError *error) {
                __strong typeof(_self) self = _self;
                BOOL setImage = (stage == TEWebImageStageFinished || stage == TEWebImageStageProgress) && image && !(options & TEWebImageOptionAvoidSetImage);
                dispatch_async(dispatch_get_main_queue(), ^{
                    BOOL sentinelChanged = weakSetter && weakSetter.sentinel != newSentinel;
                    if (setImage && self && !sentinelChanged) {
                        [self setImage:image forState:state.integerValue];
                    }
                    if (completion) {
                        if (sentinelChanged) {
                            completion(nil, url, TEWebImageFromNone, TEWebImageStageCancelled, nil);
                        } else {
                            completion(image, url, from, stage, error);
                        }
                    }
                });
            };
            
            newSentinel = [setter setOperationWithSentinel:sentinel url:imageURL options:options manager:manager progress:_progress transform:transform completion:_completion];
            weakSetter = setter;
        });
    });
}

- (void)_te_cancelImageRequestForSingleState:(NSNumber *)state {
    _TEWebImageSetterDicForButton *dic = objc_getAssociatedObject(self, &_TEWebImageSetterKey);
    _TEWebImageSetter *setter = [dic setterForState:state];
    if (setter) [setter cancel];
}

- (NSURL *)te_imageURLForState:(UIControlState)state {
    _TEWebImageSetterDicForButton *dic = objc_getAssociatedObject(self, &_TEWebImageSetterKey);
    _TEWebImageSetter *setter = [dic setterForState:UIControlStateSingle(state)];
    return setter.imageURL;
}

- (void)te_setImageWithURL:(NSURL *)imageURL
                  forState:(UIControlState)state
               placeholder:(UIImage *)placeholder {
    [self te_setImageWithURL:imageURL
                 forState:state
              placeholder:placeholder
                  options:kNilOptions
                  manager:nil
                 progress:nil
                transform:nil
               completion:nil];
}

- (void)te_setImageWithURL:(NSURL *)imageURL
                  forState:(UIControlState)state
                   options:(TEWebImageOptions)options {
    [self te_setImageWithURL:imageURL
                    forState:state
                 placeholder:nil
                     options:options
                     manager:nil
                    progress:nil
                   transform:nil
                  completion:nil];
}

- (void)te_setImageWithURL:(NSURL *)imageURL
                  forState:(UIControlState)state
               placeholder:(UIImage *)placeholder
                   options:(TEWebImageOptions)options
                completion:(TEWebImageCompletionBlock)completion {
    [self te_setImageWithURL:imageURL
                    forState:state
                 placeholder:placeholder
                     options:options
                     manager:nil
                    progress:nil
                   transform:nil
                  completion:completion];
}

- (void)te_setImageWithURL:(NSURL *)imageURL
                  forState:(UIControlState)state
               placeholder:(UIImage *)placeholder
                   options:(TEWebImageOptions)options
                  progress:(TEWebImageProgressBlock)progress
                 transform:(TEWebImageTransformBlock)transform
                completion:(TEWebImageCompletionBlock)completion {
    [self te_setImageWithURL:imageURL
                    forState:state
                 placeholder:placeholder
                     options:options
                     manager:nil
                    progress:progress
                   transform:transform
                  completion:completion];
}

- (void)te_setImageWithURL:(NSURL *)imageURL
                  forState:(UIControlState)state
               placeholder:(UIImage *)placeholder
                   options:(TEWebImageOptions)options
                   manager:(TEWebImageManager *)manager
                  progress:(TEWebImageProgressBlock)progress
                 transform:(TEWebImageTransformBlock)transform
                completion:(TEWebImageCompletionBlock)completion {
    for (NSNumber *num in UIControlStateMulti(state)) {
        [self _te_setImageWithURL:imageURL
                   forSingleState:num
                      placeholder:placeholder
                          options:options
                          manager:manager
                         progress:progress
                        transform:transform
                       completion:completion];
    }
}

- (void)te_cancelImageRequestForState:(UIControlState)state {
    for (NSNumber *num in UIControlStateMulti(state)) {
        [self _te_cancelImageRequestForSingleState:num];
    }
}


#pragma mark - background image

- (void)_te_setBackgroundImageWithURL:(NSURL *)imageURL
                       forSingleState:(NSNumber *)state
                          placeholder:(UIImage *)placeholder
                              options:(TEWebImageOptions)options
                              manager:(TEWebImageManager *)manager
                             progress:(TEWebImageProgressBlock)progress
                            transform:(TEWebImageTransformBlock)transform
                           completion:(TEWebImageCompletionBlock)completion {
    if ([imageURL isKindOfClass:[NSString class]]) imageURL = [NSURL URLWithString:(id)imageURL];
    manager = manager ? manager : [TEWebImageManager sharedManager];
    
    _TEWebImageSetterDicForButton *dic = objc_getAssociatedObject(self, &_TEWebImageBackgroundSetterKey);
    if (!dic) {
        dic = [_TEWebImageSetterDicForButton new];
        objc_setAssociatedObject(self, &_TEWebImageBackgroundSetterKey, dic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    _TEWebImageSetter *setter = [dic lazySetterForState:state];
    int32_t sentinel = [setter cancelWithNewURL:imageURL];
    
    _te_dispatch_sync_on_main_queue(^{
        if (!imageURL) {
            if (!(options & TEWebImageOptionIgnorePlaceHolder)) {
                [self setBackgroundImage:placeholder forState:state.integerValue];
            }
            return;
        }
        
        // get the image from memory as quickly as possible
        UIImage *imageFromMemory = nil;
        if (manager.cache &&
            !(options & TEWebImageOptionUseNSURLCache) &&
            !(options & TEWebImageOptionRefreshImageCache)) {
            imageFromMemory = [manager.cache getImageForKey:[manager cacheKeyForURL:imageURL] withType:TEImageCacheTypeMemory];
        }
        if (imageFromMemory) {
            if (!(options & TEWebImageOptionAvoidSetImage)) {
                [self setBackgroundImage:imageFromMemory forState:state.integerValue];
            }
            if(completion) completion(imageFromMemory, imageURL, TEWebImageFromMemoryCacheFast, TEWebImageStageFinished, nil);
            return;
        }
        
        
        if (!(options & TEWebImageOptionIgnorePlaceHolder)) {
            [self setBackgroundImage:placeholder forState:state.integerValue];
        }
        
        __weak typeof(self) _self = self;
        dispatch_async([_TEWebImageSetter setterQueue], ^{
            TEWebImageProgressBlock _progress = nil;
            if (progress) _progress = ^(NSInteger receivedSize, NSInteger expectedSize) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    progress(receivedSize, expectedSize);
                });
            };
            
            __block int32_t newSentinel = 0;
            __block __weak typeof(setter) weakSetter = nil;
            TEWebImageCompletionBlock _completion = ^(UIImage *image, NSURL *url, TEWebImageFromType from, TEWebImageStage stage, NSError *error) {
                __strong typeof(_self) self = _self;
                BOOL setImage = (stage == TEWebImageStageFinished || stage == TEWebImageStageProgress) && image && !(options & TEWebImageOptionAvoidSetImage);
                dispatch_async(dispatch_get_main_queue(), ^{
                    BOOL sentinelChanged = weakSetter && weakSetter.sentinel != newSentinel;
                    if (setImage && self && !sentinelChanged) {
                        [self setBackgroundImage:image forState:state.integerValue];
                    }
                    if (completion) {
                        if (sentinelChanged) {
                            completion(nil, url, TEWebImageFromNone, TEWebImageStageCancelled, nil);
                        } else {
                            completion(image, url, from, stage, error);
                        }
                    }
                });
            };
            
            newSentinel = [setter setOperationWithSentinel:sentinel url:imageURL options:options manager:manager progress:_progress transform:transform completion:_completion];
            weakSetter = setter;
        });
    });
}

- (void)_te_cancelBackgroundImageRequestForSingleState:(NSNumber *)state {
    _TEWebImageSetterDicForButton *dic = objc_getAssociatedObject(self, &_TEWebImageBackgroundSetterKey);
    _TEWebImageSetter *setter = [dic setterForState:state];
    if (setter) [setter cancel];
}

- (NSURL *)te_backgroundImageURLForState:(UIControlState)state {
    _TEWebImageSetterDicForButton *dic = objc_getAssociatedObject(self, &_TEWebImageBackgroundSetterKey);
    _TEWebImageSetter *setter = [dic setterForState:UIControlStateSingle(state)];
    return setter.imageURL;
}

- (void)te_setBackgroundImageWithURL:(NSURL *)imageURL
                            forState:(UIControlState)state
                         placeholder:(UIImage *)placeholder {
    [self te_setBackgroundImageWithURL:imageURL
                              forState:state
                           placeholder:placeholder
                               options:kNilOptions
                               manager:nil
                              progress:nil
                             transform:nil
                            completion:nil];
}

- (void)te_setBackgroundImageWithURL:(NSURL *)imageURL
                            forState:(UIControlState)state
                             options:(TEWebImageOptions)options {
    [self te_setBackgroundImageWithURL:imageURL
                              forState:state
                           placeholder:nil
                               options:options
                               manager:nil
                              progress:nil
                             transform:nil
                            completion:nil];
}

- (void)te_setBackgroundImageWithURL:(NSURL *)imageURL
                            forState:(UIControlState)state
                         placeholder:(UIImage *)placeholder
                             options:(TEWebImageOptions)options
                          completion:(TEWebImageCompletionBlock)completion {
    [self te_setBackgroundImageWithURL:imageURL
                              forState:state
                           placeholder:placeholder
                               options:options
                               manager:nil
                              progress:nil
                             transform:nil
                            completion:completion];
}

- (void)te_setBackgroundImageWithURL:(NSURL *)imageURL
                            forState:(UIControlState)state
                         placeholder:(UIImage *)placeholder
                             options:(TEWebImageOptions)options
                            progress:(TEWebImageProgressBlock)progress
                           transform:(TEWebImageTransformBlock)transform
                          completion:(TEWebImageCompletionBlock)completion {
    [self te_setBackgroundImageWithURL:imageURL
                              forState:state
                           placeholder:placeholder
                               options:options
                               manager:nil
                              progress:progress
                             transform:transform
                            completion:completion];
}

- (void)te_setBackgroundImageWithURL:(NSURL *)imageURL
                            forState:(UIControlState)state
                         placeholder:(UIImage *)placeholder
                             options:(TEWebImageOptions)options
                             manager:(TEWebImageManager *)manager
                            progress:(TEWebImageProgressBlock)progress
                           transform:(TEWebImageTransformBlock)transform
                          completion:(TEWebImageCompletionBlock)completion {
    for (NSNumber *num in UIControlStateMulti(state)) {
        [self _te_setBackgroundImageWithURL:imageURL
                             forSingleState:num
                                placeholder:placeholder
                                    options:options
                                    manager:manager
                                   progress:progress
                                  transform:transform
                                 completion:completion];
    }
}

- (void)te_cancelBackgroundImageRequestForState:(UIControlState)state {
    for (NSNumber *num in UIControlStateMulti(state)) {
        [self _te_cancelBackgroundImageRequestForSingleState:num];
    }
}

@end
