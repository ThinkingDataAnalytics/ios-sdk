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

@property (nonatomic) id mockThinkingInstance;

@end

@implementation ThinkingSDKDEMOTests

- (void)setUp {
    _mockThinkingInstance = OCMPartialMock([ThinkingAnalyticsSDK sharedInstance]);
}

- (void)tearDown {
    [self.mockThinkingInstance stopMocking];
    self.mockThinkingInstance = nil;
}

- (void)waitForThinkingQueues {
    dispatch_sync([ThinkingAnalyticsSDK serialQueue], ^{
        dispatch_sync([ThinkingAnalyticsSDK networkQueue], ^{ return; });
    });
}

- (void)test01doSave {
    OCMExpect([_mockThinkingInstance saveClickData:[OCMArg isNotNil]]);
    [_mockThinkingInstance track:@"test"];
    
    [self waitForThinkingQueues];
    OCMVerifyAll(_mockThinkingInstance);
}

- (void)test02doFlush {
    [_mockThinkingInstance setExpectationOrderMatters:YES];
    OCMExpect([_mockThinkingInstance saveClickData:[OCMArg isNotNil]]);
    OCMExpect([_mockThinkingInstance flush]);
    for (int i = 0; i < 100; i++) {
        [_mockThinkingInstance track:@"test"];
    }
    
    [self waitForThinkingQueues];
    OCMVerifyAll(_mockThinkingInstance);
}

- (void)test03TrackEvent {
    void (^saveClickDataInvocation)(NSInvocation *) = ^(NSInvocation *invocation) {
        __weak NSDictionary *dataDic;
        [invocation getArgument: &dataDic atIndex: 2];
        
        NSLog(@"dataDic:%@",dataDic);
        
        NSString *timeStr = dataDic[@"#time"];
        NSDateFormatter *timeFormatter = [[NSDateFormatter alloc]init];
        timeFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
        NSDate *date = [timeFormatter dateFromString:timeStr];
        NSDictionary *properties = dataDic[@"properties"];
        
        XCTAssertNotNil(date);
        XCTAssertNotNil(dataDic);
        XCTAssertNotNil(dataDic[@"#uuid"]);
        XCTAssertEqualObjects(dataDic[@"#event_name"], @"test");
        XCTAssertEqualObjects(dataDic[@"#type"], @"track");
        XCTAssertNotNil(properties[@"#app_version"]);
        XCTAssertTrue([properties[@"#app_version"] isKindOfClass:[NSString class]]);
        if(properties[@"#network_type"]) {
            NSArray *network = @[@"WIFI", @"UNKNOWN", @"2G", @"3G", @"4G", @"NULL"];
            XCTAssertTrue([network containsObject:properties[@"#network_type"]]);
        }
        XCTAssertTrue([[properties allKeys] count] == 2);
        XCTAssertTrue([date isKindOfClass:[NSDate class]]);
        XCTAssertTrue([[dataDic allKeys] count] == 6);
    };
    OCMStub([_mockThinkingInstance saveClickData:[OCMArg any]]).andDo(saveClickDataInvocation);

    [_mockThinkingInstance track:@"test"];
    [self waitForThinkingQueues];
}

- (void)test04MultiInstance {
    NSString *appid1 = @"kAPPID1";
    NSString *appid2 = @"kAPPID2";
    ThinkingAnalyticsSDK *thinkingSDK1 = [ThinkingAnalyticsSDK startWithAppId:appid1 withUrl:@"kURL1"];
    ThinkingAnalyticsSDK *thinkingSDK2 = [ThinkingAnalyticsSDK startWithAppId:appid2 withUrl:@"kURL2"];
    
    ThinkingAnalyticsSDK *instance1 = [ThinkingAnalyticsSDK sharedInstanceWithAppid:appid1];
    ThinkingAnalyticsSDK *instance2 = [ThinkingAnalyticsSDK sharedInstanceWithAppid:appid2];
    ThinkingAnalyticsSDK *demoInstance = [ThinkingAnalyticsSDK sharedInstanceWithAppid:@"YOUR_APPID"];
    
    XCTAssertNotEqual(thinkingSDK1, thinkingSDK2);
    XCTAssertEqual(demoInstance, [ThinkingAnalyticsSDK sharedInstance]);
    XCTAssertEqual(instance1, thinkingSDK1);
    XCTAssertEqual(instance2, thinkingSDK2);
}

- (void)test05MultithreadTrack {
    NSString *appid1 = @"kAPPID1";
    NSString *appid2 = @"kAPPID2";
    ThinkingAnalyticsSDK *thinkingSDK1 = [ThinkingAnalyticsSDK startWithAppId:appid1 withUrl:@"kURL1"];
    ThinkingAnalyticsSDK *thinkingSDK2 = [ThinkingAnalyticsSDK startWithAppId:appid2 withUrl:@"kURL2"];
    
    id _mockThinking1 = OCMPartialMock(thinkingSDK1);
    id _mockThinking2 = OCMPartialMock(thinkingSDK2);
    
    static int count = 0;
    void (^saveClickDataInvocation)(NSInvocation *) = ^(NSInvocation *invocation) {
        __weak NSDictionary *dataDic;
        [invocation getArgument: &dataDic atIndex: 2];
        count ++;
        XCTAssertEqualObjects(dataDic[@"#event_name"], @"test");
        NSLog(@"count:%d", count);
    };
    OCMStub([_mockThinking1 saveClickData:[OCMArg any]]).andDo(saveClickDataInvocation);
    
    static int count2 = 0;
    void (^saveClickDataInvocation2)(NSInvocation *) = ^(NSInvocation *invocation) {
        __weak NSDictionary *dataDic;
        [invocation getArgument: &dataDic atIndex: 2];
        count2 ++;
        XCTAssertEqualObjects(dataDic[@"#event_name"], @"test2");
        NSLog(@"count2:%d", count2);
    };
    OCMStub([_mockThinking2 saveClickData:[OCMArg any]]).andDo(saveClickDataInvocation2);
    
    dispatch_queue_t queue = dispatch_queue_create("test", DISPATCH_QUEUE_CONCURRENT);
    for (int i = 0; i < 100 ; i++) {
        dispatch_async(queue, ^{
            [_mockThinking1 track:@"test"];
            [_mockThinking2 track:@"test2"];
        });
    }
    
    dispatch_barrier_sync(queue, ^{
        dispatch_sync([ThinkingAnalyticsSDK serialQueue], ^{
            XCTAssertTrue(count == 100);
            XCTAssertTrue(count2 == 100);
        });
    });
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
