//
//  TEFocusViewController.h
//  teviewtemplate
//
//  Created by Charles on 29.11.22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class TETempMode, TADisplayConfig;

@interface TEFocusViewController : UIViewController

@property(nonatomic, strong, readonly) TETempMode *tempNode;

- (instancetype)initWithNode:(TETempMode *)node config:(TADisplayConfig *)config;

@end

NS_ASSUME_NONNULL_END
