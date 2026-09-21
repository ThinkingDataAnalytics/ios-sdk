//
//  TDDelegateProxySelectorTests.m
//  ThinkingSDKDEMOTests
//
//  Reproduces TQA-e454691c: App terminate → AppLovinSDK os_log flatten →
//  swizzled -[NSObject thinkingdata_respondsToSelector:] → NSStringFromSelector
//  on a non-C-string SEL → EXC_CRASH (SIGBUS).
//

#import <XCTest/XCTest.h>
#import <objc/runtime.h>
#import <ThinkingSDK/NSObject+TDDelegateProxy.h>
#import <ThinkingSDK/TDAppDelegateProxyManager.h>

@interface TDDelegateProxySelectorTests : XCTestCase
@end

@implementation TDDelegateProxySelectorTests

- (void)setUp {
    [super setUp];
    [[TDAppDelegateProxyManager defaultManager] proxyNotifications];
}

// Crash register x1 = 0x07e30901ffffffff was the selector name pointer passed
// to _CFStringCreateIndirectASCIITaggedPointerString via NSStringFromSelector.
- (void)testInvalidSelectorDoesNotCrashWhenOptionalSelectorsEmpty {
    NSObject *object = [[NSObject alloc] init];
    SEL invalidSelector = (SEL)(uintptr_t)0x07e30901ffffffffULL;
    BOOL responds = YES;
    XCTAssertNoThrow(responds = [object respondsToSelector:invalidSelector]);
    XCTAssertFalse(responds);
}

- (void)testInvalidSelectorDoesNotCrashWhenOptionalSelectorsPresent {
    NSObject *object = [[NSObject alloc] init];
    object.thinkingdata_optionalSelectors = [NSSet setWithObject:@"application:openURL:options:"];
    SEL invalidSelector = (SEL)(uintptr_t)0x07e30901ffffffffULL;
    BOOL responds = YES;
    XCTAssertNoThrow(responds = [object respondsToSelector:invalidSelector]);
    XCTAssertFalse(responds);
}

- (void)testNonStringOptionalSelectorDoesNotCrash {
    NSObject *object = [[NSObject alloc] init];
    object.thinkingdata_optionalSelectors = (NSSet<NSString *> *)(id)[NSSet setWithObject:NSNull.null];
    SEL selector = NSSelectorFromString(@"application:openURL:options:");
    BOOL responds = YES;
    XCTAssertNoThrow(responds = [object respondsToSelector:selector]);
    XCTAssertFalse(responds);
}

- (void)testOptionalSelectorStillReportsYES {
    NSObject *object = [[NSObject alloc] init];
    SEL optionalSelector = NSSelectorFromString(@"application:openURL:options:");
    XCTAssertFalse([object respondsToSelector:optionalSelector]);

    object.thinkingdata_optionalSelectors = [NSSet setWithObject:@"application:openURL:options:"];
    XCTAssertTrue([object respondsToSelector:optionalSelector]);
}

- (void)testUnlistedOptionalSelectorStillReportsNO {
    NSObject *object = [[NSObject alloc] init];
    object.thinkingdata_optionalSelectors = [NSSet setWithObject:@"application:openURL:options:"];
    XCTAssertFalse([object respondsToSelector:NSSelectorFromString(@"application:handleOpenURL:")]);
}

@end
