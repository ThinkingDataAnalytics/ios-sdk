//
//  TEShowDialog.m
//  teviewtemplate
//
//  Created by Charles on 25.11.22.
//

#import "TEShowDialog.h"
#import "TEFocusViewController.h"

BOOL isAppExtension(void) {
    static BOOL isAppExtension = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class cls = NSClassFromString(@"UIApplication");
        if(!cls || ![cls respondsToSelector:@selector(sharedApplication)]) isAppExtension = YES;
        if ([[[NSBundle mainBundle] bundlePath] hasSuffix:@".appex"]) isAppExtension = YES;
    });
    return isAppExtension;
}


UIViewController * ta_getTopViewController(void)
{
  static Class applicationClass = nil;
  if (!isAppExtension()) {
    Class cls = NSClassFromString(@"UIApplication");
    if (cls && [cls respondsToSelector:NSSelectorFromString(@"sharedApplication")]) {
      applicationClass = cls;
    }
  }

  UIViewController *topViewController;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000
  if (@available(iOS 13.0, tvOS 13.0, *)) {
    UIApplication *application = [applicationClass sharedApplication];
    NSSet<UIScene *> *connectedScenes = application.connectedScenes;
    for (UIScene *scene in connectedScenes) {
      if ([scene isKindOfClass:[UIWindowScene class]]) {
        UIWindowScene *windowScene = (UIWindowScene *)scene;
        for (UIWindow *window in windowScene.windows) {
          if (window.isKeyWindow) {
            topViewController = window.rootViewController;
          }
        }
      }
    }
  } else {
    UIApplication *application = [applicationClass sharedApplication];
// iOS 13 deprecation
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    topViewController = application.keyWindow.rootViewController;
#pragma clang diagnostic pop
  }
#else
  UIApplication *application = [applicationClass sharedApplication];
  topViewController = application.keyWindow.rootViewController;
#endif

  while (true) {
    if (topViewController.presentedViewController) {
      topViewController = topViewController.presentedViewController;
    } else if ([topViewController isKindOfClass:[UINavigationController class]]) {
      UINavigationController *nav = (UINavigationController *)topViewController;
      topViewController = nav.topViewController;
    } else if ([topViewController isKindOfClass:[UITabBarController class]]) {
      UITabBarController *tab = (UITabBarController *)topViewController;
      topViewController = tab.selectedViewController;
    } else {
      break;
    }
  }
  return topViewController;
}


@implementation TEShowDialog

+ (void)showDialog:(TETempMode *)node config:(TADisplayConfig *)config {
    [TEShowDialog showDialog:node rootVC:nil config:config];
}

+ (void)showDialog:(TETempMode *)node rootVC:(UIViewController *)rootVC config:(TADisplayConfig *)config {
 
    if (rootVC == nil || ![rootVC isKindOfClass:[UIViewController class]]) {
        rootVC = ta_getTopViewController();
    }
    
    TEFocusViewController *focusVC = [[TEFocusViewController alloc] initWithNode:node config:config];
    //focusVC.modalPresentationStyle = UIModalPresentationFullScreen;
    focusVC.modalPresentationStyle =UIModalPresentationOverCurrentContext;
    [rootVC presentViewController:focusVC animated:NO completion:nil];
}

@end
