//
//  TEWebImage.h
//  TEWebImage <https://github.com/ibireme/TEWebImage>
//
//  Created by ibireme on 15/2/23.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import <UIKit/UIKit.h>

#if __has_include(<TEWebImage/TEWebImage.h>)
FOUNDATION_EXPORT double TEWebImageVersionNumber;
FOUNDATION_EXPORT const unsigned char TEWebImageVersionString[];
#import <TEWebImage/TEImageCache.h>
#import <TEWebImage/TEWebImageOperation.h>
#import <TEWebImage/TEWebImageManager.h>
#import <TEWebImage/UIImage+TEWebImage.h>
#import <TEWebImage/UIImageView+TEWebImage.h>
#import <TEWebImage/UIButton+TEWebImage.h>
#import <TEWebImage/CALayer+TEWebImage.h>
#import <TEWebImage/MKAnnotationView+TEWebImage.h>
#else
#import "TEImageCache.h"
#import "TEWebImageOperation.h"
#import "TEWebImageManager.h"
#import "UIImage+TEWebImage.h"
#import "UIImageView+TEWebImage.h"
#import "UIButton+TEWebImage.h"
#import "CALayer+TEWebImage.h"
//#import "MKAnnotationView+TEWebImage.h"
#endif

#if __has_include(<TEImage/TEImage.h>)
#import <TEImage/TEImage.h>
#elif __has_include(<TEWebImage/TEImage.h>)
#import <TEWebImage/TEImage.h>
#import <TEWebImage/TEFrameImage.h>
#import <TEWebImage/TESpriteSheetImage.h>
#import <TEWebImage/TEImageCoder.h>
#import <TEWebImage/TEAnimatedImageView.h>
#else
#import "TEImage.h"
#import "TEFrameImage.h"
#import "TESpriteSheetImage.h"
#import "TEImageCoder.h"
#import "TEAnimatedImageView.h"
#endif

#if __has_include(<TECache/TECache.h>)
#import <TECache/TECache.h>
#elif __has_include(<TEWebImage/TECache.h>)
#import <TEWebImage/TECache.h>
#import <TEWebImage/TEMemoryCache.h>
#import <TEWebImage/TEDiskCache.h>
#import <TEWebImage/TEKVStorage.h>
#else
#import "TECache.h"
#import "TEMemoryCache.h"
#import "TEDiskCache.h"
#import "TEKVStorage.h"
#endif

