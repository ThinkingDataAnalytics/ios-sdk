
#import <objc/runtime.h>
#import "UIView+TAYoga.h"
#import "TAYGLayout+Private.h"

static const void* kYGYogaAssociatedKey = &kYGYogaAssociatedKey;

@implementation UIView (YogaKit)

- (TAYGLayout*)ta_yoga {
  TAYGLayout* ta_yoga = objc_getAssociatedObject(self, kYGYogaAssociatedKey);
  if (!ta_yoga) {
    ta_yoga = [[TAYGLayout alloc] initWithView:self];
    objc_setAssociatedObject(
        self, kYGYogaAssociatedKey, ta_yoga, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  }

  return ta_yoga;
}

- (BOOL)isYogaEnabled {
  return objc_getAssociatedObject(self, kYGYogaAssociatedKey) != nil;
}

- (void)configureLayoutWithBlock:(YGLayoutConfigurationBlock)block {
  if (block != nil) {
    block(self.ta_yoga);
  }
}

@end
