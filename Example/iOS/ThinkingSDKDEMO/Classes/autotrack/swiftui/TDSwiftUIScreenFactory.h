#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TDSwiftUIScreenFactory : NSObject

+ (UIViewController *)makeVastRendererHostingController;
+ (NSString *)swiftRootViewName;

@end

NS_ASSUME_NONNULL_END
