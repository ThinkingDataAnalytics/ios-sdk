#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TDSwiftUIScreenFactory : NSObject

+ (UIViewController *)makeVastRendererHostingController;
/// NavigationLink 多层跳转 screen_name 验证，含有/无 navigationTitle 的对比页面
+ (UIViewController *)makeNavLinkDemoHostingController;
+ (NSString *)swiftRootViewName;

@end

NS_ASSUME_NONNULL_END
