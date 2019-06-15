#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TDAutoTrackUtils : NSObject

+ (NSString *)contentFromView:(UIView *)rootView;
+ (NSString *)titleFromViewController:(UIViewController *)viewController;

@end

NS_ASSUME_NONNULL_END
