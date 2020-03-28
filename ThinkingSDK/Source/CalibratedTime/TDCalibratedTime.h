#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TDCalibratedTime : NSObject

+ (instancetype)sharedInstance;
+ (instancetype)sharedInstanceWithTimeInterval:(NSTimeInterval)timeInterval;
@property (nonatomic, assign) NSTimeInterval systemUptime;
@property (nonatomic, assign) NSTimeInterval serverTime;
@property (nonatomic, assign) BOOL stopCalibrate;

@end

NS_ASSUME_NONNULL_END
