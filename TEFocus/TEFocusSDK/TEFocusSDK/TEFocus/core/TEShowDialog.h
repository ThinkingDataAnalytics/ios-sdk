//
//  TEShowDialog.h
//  teviewtemplate
//
//  Created by Charles on 25.11.22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class TETempMode, TADisplayConfig;

@interface TEShowDialog : NSObject

+ (void)showDialog:(TETempMode *)node config:(TADisplayConfig *)config;

+ (void)showDialog:(TETempMode *)node rootVC:(nullable UIViewController *)rootVC config:(TADisplayConfig *)config;

@end

NS_ASSUME_NONNULL_END
