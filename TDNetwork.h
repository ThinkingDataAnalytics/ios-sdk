#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TDNetwork : NSObject

@property (nonatomic, strong) NSURL *serverURL;
@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (atomic, strong) NSDictionary *automaticData;

- (instancetype)initWithServerURL:(NSURL *)serverURL withAutomaticData:(NSDictionary *)automaticData;
- (BOOL)flushEvents:(NSArray<NSString *> *)events withAppid:(NSString *)appid;

@end

NS_ASSUME_NONNULL_END
