//
//  ThinkingSDKDEMOTests.m
//  ThinkingSDKDEMOTests
//
//  Created by syj on 2019/6/24.
//  Copyright © 2019年 thinking. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <ThinkingSDK/ThinkingSDK.h>
#import <ThinkingSDK/ThinkingAnalyticsSDKPrivate.h>

@interface ThinkingSDKDEMOTests : XCTestCase

@end

@implementation ThinkingSDKDEMOTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)test01doSave {
    id mockThinkingInstance = OCMPartialMock([ThinkingAnalyticsSDK sharedInstance]);
    OCMExpect([mockThinkingInstance saveClickData:[OCMArg isNotNil]]);
    [mockThinkingInstance track:@"test"];
    dispatch_sync([ThinkingAnalyticsSDK serialQueue], ^{
        dispatch_sync([ThinkingAnalyticsSDK networkQueue], ^{ return; });
    });
    OCMVerifyAll(mockThinkingInstance);
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
