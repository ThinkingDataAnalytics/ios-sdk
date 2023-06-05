//
//  TEWebImageManager.m
//  TEWebImage <https://github.com/ibireme/TEWebImage>
//
//  Created by ibireme on 15/2/19.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "TEWebImageManager.h"
#import "TEImageCache.h"
#import "TEWebImageOperation.h"
#import "TEImageCoder.h"
#import <objc/runtime.h>

#define kNetworkIndicatorDelay (1/30.0)


/// Returns nil in App Extension.
static UIApplication *_TESharedApplication() {
    static BOOL isAppExtension = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class cls = NSClassFromString(@"UIApplication");
        if(!cls || ![cls respondsToSelector:@selector(sharedApplication)]) isAppExtension = YES;
        if ([[[NSBundle mainBundle] bundlePath] hasSuffix:@".appex"]) isAppExtension = YES;
    });
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    return isAppExtension ? nil : [UIApplication performSelector:@selector(sharedApplication)];
#pragma clang diagnostic pop
}


@interface _TEWebImageApplicationNetworkIndicatorInfo : NSObject
@property (nonatomic, assign) NSInteger count;
@property (nonatomic, strong) NSTimer *timer;
@end
@implementation _TEWebImageApplicationNetworkIndicatorInfo
@end

@implementation TEWebImageManager

+ (instancetype)sharedManager {
    static TEWebImageManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        TEImageCache *cache = [TEImageCache sharedCache];
        NSOperationQueue *queue = [NSOperationQueue new];
        if ([queue respondsToSelector:@selector(setQualityOfService:)]) {
            queue.qualityOfService = NSQualityOfServiceBackground;
        }
        manager = [[self alloc] initWithCache:cache queue:queue];
    });
    return manager;
}

- (instancetype)init {
    @throw [NSException exceptionWithName:@"TEWebImageManager init error" reason:@"Use the designated initializer to init." userInfo:nil];
    return [self initWithCache:nil queue:nil];
}

- (instancetype)initWithCache:(TEImageCache *)cache queue:(NSOperationQueue *)queue{
    self = [super init];
    if (!self) return nil;
    _cache = cache;
    _queue = queue;
    _timeout = 15.0;
    if (TEImageWebPAvailable()) {
        _headers = @{ @"Accept" : @"image/webp,image/*;q=0.8" };
    } else {
        _headers = @{ @"Accept" : @"image/*;q=0.8" };
    }
    return self;
}

- (TEWebImageOperation *)requestImageWithURL:(NSURL *)url
                                     options:(TEWebImageOptions)options
                                    progress:(TEWebImageProgressBlock)progress
                                   transform:(TEWebImageTransformBlock)transform
                                  completion:(TEWebImageCompletionBlock)completion {
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.timeoutInterval = _timeout;
    request.HTTPShouldHandleCookies = (options & TEWebImageOptionHandleCookies) != 0;
    request.allHTTPHeaderFields = [self headersForURL:url];
    request.HTTPShouldUsePipelining = YES;
    request.cachePolicy = (options & TEWebImageOptionUseNSURLCache) ?
        NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData;
    
    TEWebImageOperation *operation = [[TEWebImageOperation alloc] initWithRequest:request
                                                                          options:options
                                                                            cache:_cache
                                                                         cacheKey:[self cacheKeyForURL:url]
                                                                         progress:progress
                                                                        transform:transform ? transform : _sharedTransformBlock
                                                                       completion:completion];

    if (_username && _password) {
        operation.credential = [NSURLCredential credentialWithUser:_username password:_password persistence:NSURLCredentialPersistenceForSession];
    }
    if (operation) {
        NSOperationQueue *queue = _queue;
        if (queue) {
            [queue addOperation:operation];
        } else {
            [operation start];
        }
    }
    return operation;
}

- (NSDictionary *)headersForURL:(NSURL *)url {
    if (!url) return nil;
    return _headersFilter ? _headersFilter(url, _headers) : _headers;
}

- (NSString *)cacheKeyForURL:(NSURL *)url {
    if (!url) return nil;
    return _cacheKeyFilter ? _cacheKeyFilter(url) : url.absoluteString;
}



#pragma mark Network Indicator

+ (_TEWebImageApplicationNetworkIndicatorInfo *)_networkIndicatorInfo {
    return objc_getAssociatedObject(self, @selector(_networkIndicatorInfo));
}

+ (void)_setNetworkIndicatorInfo:(_TEWebImageApplicationNetworkIndicatorInfo *)info {
    objc_setAssociatedObject(self, @selector(_networkIndicatorInfo), info, OBJC_ASSOCIATION_RETAIN);
}

+ (void)_delaySetActivity:(NSTimer *)timer {
    UIApplication *app = _TESharedApplication();
    if (!app) return;
    
    NSNumber *visiable = timer.userInfo;
    if (app.networkActivityIndicatorVisible != visiable.boolValue) {
        [app setNetworkActivityIndicatorVisible:visiable.boolValue];
    }
    [timer invalidate];
}

+ (void)_changeNetworkActivityCount:(NSInteger)delta {
    if (!_TESharedApplication()) return;
    
    void (^block)() = ^{
        _TEWebImageApplicationNetworkIndicatorInfo *info = [self _networkIndicatorInfo];
        if (!info) {
            info = [_TEWebImageApplicationNetworkIndicatorInfo new];
            [self _setNetworkIndicatorInfo:info];
        }
        NSInteger count = info.count;
        count += delta;
        info.count = count;
        [info.timer invalidate];
        info.timer = [NSTimer timerWithTimeInterval:kNetworkIndicatorDelay target:self selector:@selector(_delaySetActivity:) userInfo:@(info.count > 0) repeats:NO];
        [[NSRunLoop mainRunLoop] addTimer:info.timer forMode:NSRunLoopCommonModes];
    };
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

+ (void)incrementNetworkActivityCount {
    [self _changeNetworkActivityCount:1];
}

+ (void)decrementNetworkActivityCount {
    [self _changeNetworkActivityCount:-1];
}

+ (NSInteger)currentNetworkActivityCount {
    _TEWebImageApplicationNetworkIndicatorInfo *info = [self _networkIndicatorInfo];
    return info.count;
}

@end
