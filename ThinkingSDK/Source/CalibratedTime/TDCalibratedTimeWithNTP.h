#import <Foundation/Foundation.h>

#import "TDCalibratedTime.h"

NS_ASSUME_NONNULL_BEGIN

@interface TDCalibratedTimeWithNTP : TDCalibratedTime

+ (instancetype)sharedInstance;
+ (instancetype)sharedInstanceWithNtpServerHost:(NSArray *)host;

@end

NS_ASSUME_NONNULL_END
