//
//  CALayer+TEWebImage.m
//  TEWebImage <https://github.com/ibireme/TEWebImage>
//
//  Created by ibireme on 15/2/23.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "CALayer+TEWebImage.h"
#import "TEWebImageOperation.h"
#import "_TEWebImageSetter.h"
#import <objc/runtime.h>

// Dummy class for category
@interface CALayer_TEWebImage : NSObject @end
@implementation CALayer_TEWebImage @end


static int _TEWebImageSetterKey;

@implementation CALayer (TEWebImage)

- (NSURL *)te_imageURL {
    _TEWebImageSetter *setter = objc_getAssociatedObject(self, &_TEWebImageSetterKey);
    return setter.imageURL;
}

- (void)setTe_imageURL:(NSURL *)imageURL {
    [self te_setImageWithURL:imageURL
              placeholder:nil
                  options:kNilOptions
                  manager:nil
                 progress:nil
                transform:nil
               completion:nil];
}

- (void)te_setImageWithURL:(NSURL *)imageURL placeholder:(UIImage *)placeholder {
    [self te_setImageWithURL:imageURL
                 placeholder:placeholder
                     options:kNilOptions
                     manager:nil
                    progress:nil
                   transform:nil
                  completion:nil];
}

- (void)te_setImageWithURL:(NSURL *)imageURL options:(TEWebImageOptions)options {
    [self te_setImageWithURL:imageURL
                 placeholder:nil
                     options:options
                     manager:nil
                    progress:nil
                   transform:nil
                  completion:nil];
}

- (void)te_setImageWithURL:(NSURL *)imageURL
               placeholder:(UIImage *)placeholder
                   options:(TEWebImageOptions)options
                completion:(TEWebImageCompletionBlock)completion {
    [self te_setImageWithURL:imageURL
                 placeholder:placeholder
                     options:options
                     manager:nil
                    progress:nil
                   transform:nil
                  completion:completion];
}

- (void)te_setImageWithURL:(NSURL *)imageURL
               placeholder:(UIImage *)placeholder
                   options:(TEWebImageOptions)options
                  progress:(TEWebImageProgressBlock)progress
                 transform:(TEWebImageTransformBlock)transform
                completion:(TEWebImageCompletionBlock)completion {
    [self te_setImageWithURL:imageURL
                 placeholder:placeholder
                     options:options
                     manager:nil
                    progress:progress
                   transform:transform
                  completion:completion];
}

- (void)te_setImageWithURL:(NSURL *)imageURL
               placeholder:(UIImage *)placeholder
                   options:(TEWebImageOptions)options
                   manager:(TEWebImageManager *)manager
                  progress:(TEWebImageProgressBlock)progress
                 transform:(TEWebImageTransformBlock)transform
                completion:(TEWebImageCompletionBlock)completion {
    if ([imageURL isKindOfClass:[NSString class]]) imageURL = [NSURL URLWithString:(id)imageURL];
    manager = manager ? manager : [TEWebImageManager sharedManager];
    
    
    _TEWebImageSetter *setter = objc_getAssociatedObject(self, &_TEWebImageSetterKey);
    if (!setter) {
        setter = [_TEWebImageSetter new];
        objc_setAssociatedObject(self, &_TEWebImageSetterKey, setter, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    int32_t sentinel = [setter cancelWithNewURL:imageURL];
    
    _te_dispatch_sync_on_main_queue(^{
        if ((options & TEWebImageOptionSetImageWithFadeAnimation) &&
            !(options & TEWebImageOptionAvoidSetImage)) {
            [self removeAnimationForKey:_TEWebImageFadeAnimationKey];
        }
        
        if (!imageURL) {
            if (!(options & TEWebImageOptionIgnorePlaceHolder)) {
                self.contents = (id)placeholder.CGImage;
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
                self.contents = (id)imageFromMemory.CGImage;
            }
            if(completion) completion(imageFromMemory, imageURL, TEWebImageFromMemoryCacheFast, TEWebImageStageFinished, nil);
            return;
        }
        
        if (!(options & TEWebImageOptionIgnorePlaceHolder)) {
            self.contents = (id)placeholder.CGImage;
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
                BOOL showFade = (options & TEWebImageOptionSetImageWithFadeAnimation);
                dispatch_async(dispatch_get_main_queue(), ^{
                    BOOL sentinelChanged = weakSetter && weakSetter.sentinel != newSentinel;
                    if (setImage && self && !sentinelChanged) {
                        if (showFade) {
                            CATransition *transition = [CATransition animation];
                            transition.duration = stage == TEWebImageStageFinished ? _TEWebImageFadeTime : _TEWebImageProgressiveFadeTime;
                            transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                            transition.type = kCATransitionFade;
                            [self addAnimation:transition forKey:_TEWebImageFadeAnimationKey];
                        }
                        self.contents = (id)image.CGImage;
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

- (void)te_cancelCurrentImageRequest {
    _TEWebImageSetter *setter = objc_getAssociatedObject(self, &_TEWebImageSetterKey);
    if (setter) [setter cancel];
}

@end
