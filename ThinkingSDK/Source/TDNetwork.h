#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^TDFlushConfigBlock)(NSDictionary *result, NSError * _Nullable error);

@interface TDNetwork : NSObject

@property (nonatomic, strong) NSURL *serverURL;
@property (atomic, strong) NSDictionary *automaticData;

- (instancetype)initWithServerURL:(NSURL *)serverURL;
- (BOOL)flushEvents:(NSArray<NSDictionary *> *)events withAppid:(NSString *)appid;
- (void)fetchFlushConfig:(NSString *)appid handler:(TDFlushConfigBlock)handler;

@end

NS_ASSUME_NONNULL_END
