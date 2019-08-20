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
#import <objc/message.h>

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
    
    NSString *distinctId1 = [thinkingSDK1 getDistinctId];
    NSString *distinctId2 = [thinkingSDK2 getDistinctId];
    NSString *device1 = [thinkingSDK1 getDeviceId];
    NSString *device2 = [thinkingSDK2 getDeviceId];
    
    XCTAssertEqual(distinctId1, distinctId2);
    XCTAssertEqual(device1, device2);
    
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

- (BOOL)doCheckProperties:(ThinkingAnalyticsSDK*)thinking properties:(NSDictionary **)properties withEventType:(NSString *)type isCheckKey:(BOOL)isCheckKey {
    BOOL (*custom_msgSend_checkProperties)(id, SEL, NSDictionary **, NSString *, BOOL) = (BOOL(*)(id, SEL, NSDictionary **, NSString *, BOOL))objc_msgSend;
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    return custom_msgSend_checkProperties(thinking, @selector(checkProperties:withEventType:isCheckKey:), properties, type, isCheckKey);
#pragma clang diagnostic pop
}

- (void)test06CheckPropertyies {
    ThinkingAnalyticsSDK *thinkingSDK1 = [ThinkingAnalyticsSDK startWithAppId:@"appid" withUrl:@"url"];
    
    NSDictionary *properties = @{@"key":@"value"};
    BOOL ret = [self doCheckProperties:thinkingSDK1 properties:&properties withEventType:nil isCheckKey:NO];
    NSDictionary *expectDic = @{@"key":@"value"};
    XCTAssertEqualObjects(properties, expectDic);
    XCTAssertTrue(ret);
    
    ret = [self doCheckProperties:thinkingSDK1 properties:&properties withEventType:@"user_add" isCheckKey:NO];
    XCTAssertFalse(ret);

    properties = @{@"key":@{@"key2":@"value"}};
    ret = [self doCheckProperties:thinkingSDK1 properties:&properties withEventType:nil isCheckKey:NO];
    XCTAssertFalse(ret);

    NSString *aString = @"test";
    properties = @{@"key": [aString dataUsingEncoding: NSUTF8StringEncoding]};
    ret = [self doCheckProperties:thinkingSDK1 properties:&properties withEventType:nil isCheckKey:NO];
    XCTAssertFalse(ret);
}

- (void)test07LoginTrack {
    NSMutableArray *dataArrays = [NSMutableArray array];
    void (^saveClickDataInvocation)(NSInvocation *) = ^(NSInvocation *invocation) {
        __weak NSDictionary *dataDic;
        [invocation getArgument: &dataDic atIndex: 2];
        
        XCTAssertNotNil(dataDic);
        [dataArrays addObject:dataDic];
        
        NSInteger count = dataArrays.count;
        switch (count) {
            case 1:
                XCTAssertEqualObjects([dataDic objectForKey:@"#account_id"], @"logintest");
                break;
            case 2:
                XCTAssertEqualObjects([dataDic objectForKey:@"#account_id"], @"logintest2");
                break;
            case 3:
                XCTAssertNil([dataDic objectForKey:@"#account_id"]);
                break;
            default:
                break;
        }
        NSLog(@"dataDic:%@",dataDic);
    };
    OCMStub([_mockThinkingInstance saveClickData:[OCMArg any]]).andDo(saveClickDataInvocation);

    [self.mockThinkingInstance login:@"logintest"];
    [self.mockThinkingInstance track:@"test"];
    
    [self.mockThinkingInstance login:@"logintest2"];
    [self.mockThinkingInstance track:@"test"];
    
    [self.mockThinkingInstance logout];
    [self.mockThinkingInstance track:@"test"];
    
    [self waitForThinkingQueues];
}

- (void)test08Enable {
    [_mockThinkingInstance enableTracking:NO];
    [_mockThinkingInstance track:@"test"];
    OCMReject([_mockThinkingInstance saveClickData:[OCMArg any]]);
    [self waitForThinkingQueues];
    OCMVerifyAll(_mockThinkingInstance);
}

- (void)test09Enable {
    [_mockThinkingInstance enableTracking:YES];
    [_mockThinkingInstance track:@"test"];
    OCMExpect([_mockThinkingInstance saveClickData:[OCMArg any]]);
    [self waitForThinkingQueues];
    OCMVerifyAll(_mockThinkingInstance);
}

- (void)test10OptOut {
    [_mockThinkingInstance track:@"test"];
    [_mockThinkingInstance setSuperProperties:@{@"key": @"value"}];
    [_mockThinkingInstance optOutTracking];
    [_mockThinkingInstance track:@"test"];
    NSDictionary *superProperties = [_mockThinkingInstance currentSuperProperties];
    OCMReject([_mockThinkingInstance saveClickData:[OCMArg any]]);
    XCTAssertEqualObjects(superProperties, @{});
    [self waitForThinkingQueues];
    OCMVerifyAll(_mockThinkingInstance);
}

- (void)test11OptIn {
    [_mockThinkingInstance optInTracking];
    [_mockThinkingInstance track:@"test"];
    [_mockThinkingInstance setSuperProperties:@{@"key2": @"value2"}];
    OCMExpect([_mockThinkingInstance saveClickData:[OCMArg any]]);
    NSDictionary *superProperties = [_mockThinkingInstance currentSuperProperties];
    XCTAssertEqualObjects(superProperties, @{@"key2": @"value2"});
    [self waitForThinkingQueues];
    OCMVerifyAll(_mockThinkingInstance);
}

@end
