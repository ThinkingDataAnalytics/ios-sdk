
#import <UIKit/UIKit.h>
#import "TAYGLayout.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^YGLayoutConfigurationBlock)(TAYGLayout* layout);

@interface UIView (TAYoga)

/**
 The TAYGLayout that is attached to this view. It is lazily created.
 */
@property(nonatomic, readonly, strong) TAYGLayout* ta_yoga;
/**
 Indicates whether or not TAYoga is enabled
 */
@property(nonatomic, readonly, assign) BOOL isYogaEnabled;

/**
 In ObjC land, every time you access `view.ta_yoga.*` you are adding another
 `objc_msgSend` to your code. If you plan on making multiple changes to
 TAYGLayout, it's more performant to use this method, which uses a single
 objc_msgSend call.
 */
- (void)configureLayoutWithBlock:(YGLayoutConfigurationBlock)block
    NS_SWIFT_NAME(configureLayout(block:));

@end

NS_ASSUME_NONNULL_END
