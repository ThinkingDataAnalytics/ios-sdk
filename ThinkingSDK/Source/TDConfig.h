
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TDConfig : NSObject <NSCopying>

@property (assign, nonatomic) BOOL trackRelaunchedInBackgroundEvents;
- (void)updateConfig;

@end

NS_ASSUME_NONNULL_END
