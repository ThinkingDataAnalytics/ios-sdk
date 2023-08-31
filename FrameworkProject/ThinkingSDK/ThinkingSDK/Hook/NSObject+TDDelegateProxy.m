
#import "NSObject+TDDelegateProxy.h"
#import <objc/runtime.h>

@implementation NSObject (TDDelegateProxy)

- (NSSet<NSString *> *)thinkingdata_optionalSelectors {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setThinkingdata_optionalSelectors:(NSSet<NSString *> *)thinkingdata_optionalSelectors {
    objc_setAssociatedObject(self, @selector(thinkingdata_optionalSelectors), thinkingdata_optionalSelectors, OBJC_ASSOCIATION_COPY);
}

- (TDDelegateProxyObject *)thinkingdata_delegateObject {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setThinkingdata_delegateObject:(TDDelegateProxyObject *)thinkingdata_delegateObject {
    objc_setAssociatedObject(self, @selector(thinkingdata_delegateObject), thinkingdata_delegateObject, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)thinkingdata_respondsToSelector:(SEL)aSelector {
    if ([self thinkingdata_respondsToSelector:aSelector]) {
        return YES;
    }
    if ([self.thinkingdata_optionalSelectors containsObject:NSStringFromSelector(aSelector)]) {
        return YES;
    }
    return NO;
}

@end

@implementation NSProxy (TDDelegateProxy)

- (NSSet<NSString *> *)thinkingdata_optionalSelectors {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setThinkingdata_optionalSelectors:(NSSet<NSString *> *)thinkingdata_optionalSelectors {
    objc_setAssociatedObject(self, @selector(thinkingdata_optionalSelectors), thinkingdata_optionalSelectors, OBJC_ASSOCIATION_COPY);
}

- (TDDelegateProxyObject *)thinkingdata_delegateObject {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setThinkingdata_delegateObject:(TDDelegateProxyObject *)thinkingdata_delegateObject {
    objc_setAssociatedObject(self, @selector(thinkingdata_delegateObject), thinkingdata_delegateObject, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)thinkingdata_respondsToSelector:(SEL)aSelector {
    if ([self thinkingdata_respondsToSelector:aSelector]) {
        return YES;
    }
    if ([self.thinkingdata_optionalSelectors containsObject:NSStringFromSelector(aSelector)]) {
        return YES;
    }
    return NO;
}

@end
