#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^TDFlushConfigBlock)(NSDictionary *result, NSError * _Nullable error);

@interface TDNetwork : NSObject

@property (nonatomic, strong) NSURL *serverURL;
@property (atomic, strong) NSDictionary *automaticData;

- (instancetype)initWithServerURL:(NSURL *)serverURL withAutomaticData:(NSDictionary *)automaticData;
- (BOOL)flushEvents:(NSArray<NSString *> *)events withAppid:(NSString *)appid;
- (void)fetchFlushConfig:(NSString *)appid handler:(TDFlushConfigBlock)handler;

@end

NS_ASSUME_NONNULL_END
