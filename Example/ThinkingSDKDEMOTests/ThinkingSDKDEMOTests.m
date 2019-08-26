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
#import "TDJSONUtil.h"

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
    [_mockThinkingInstance track:@"test"];
    OCMExpect([_mockThinkingInstance saveEventsData:[OCMArg isNotNil]]);
    
    [self waitForThinkingQueues];
    OCMVerifyAll(_mockThinkingInstance);
}

- (void)test02doFlush {
    [_mockThinkingInstance setExpectationOrderMatters:YES];
    OCMExpect([_mockThinkingInstance saveEventsData:[OCMArg isNotNil]]);
    OCMExpect([_mockThinkingInstance flush]);
    for (int i = 0; i < 100; i++) {
        [_mockThinkingInstance track:@"test"];
    }
    
    [self waitForThinkingQueues];
    OCMVerifyAll(_mockThinkingInstance);
}

- (NSDictionary *)allPropertyTypes {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss zzz";
    NSDate *date = [dateFormatter dateFromString:@"2012-09-24 11:28:10 PDT"];
    return @{ @"string": @"hello", @"number": @3, @"date": date, @"float": @1.3 , @"bool": @YES };
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
        XCTAssertTrue([[properties allKeys] count] == 7);
        
        XCTAssertNotNil(properties[@"#app_version"]);
        XCTAssertTrue([properties[@"#app_version"] isKindOfClass:[NSString class]]);
        if (properties[@"#network_type"]) {
            NSArray *network = @[@"WIFI", @"UNKNOWN", @"2G", @"3G", @"4G", @"NULL"];
            XCTAssertTrue([network containsObject:properties[@"#network_type"]]);
        }
        XCTAssertEqualObjects(properties[@"date"], @"2012-09-25 02:28:10.000");
        XCTAssertEqualObjects(properties[@"string"], @"hello");
        
        int isBool = strcmp([properties[@"bool"] objCType], [@YES objCType]);
        
        XCTAssertTrue(isBool == 0);
        XCTAssertTrue([properties[@"float"] isKindOfClass:[NSNumber class]]);
        XCTAssertTrue([properties[@"number"] isKindOfClass:[NSNumber class]]);
        
        XCTAssertTrue([date isKindOfClass:[NSDate class]]);
        XCTAssertEqualObjects(timeStr, @"2012-06-24 11:28:10.000");
        XCTAssertTrue([[dataDic allKeys] count] == 6);
    };
    OCMStub([_mockThinkingInstance saveEventsData:[OCMArg any]]).andDo(saveClickDataInvocation);

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSDate *date = [dateFormatter dateFromString:@"2012-06-24 11:28:10"];
    [_mockThinkingInstance track:@"test" properties:[self allPropertyTypes] time:date];
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
    OCMStub([_mockThinking1 saveEventsData:[OCMArg any]]).andDo(saveClickDataInvocation);
    
    static int count2 = 0;
    void (^saveClickDataInvocation2)(NSInvocation *) = ^(NSInvocation *invocation) {
        __weak NSDictionary *dataDic;
        [invocation getArgument: &dataDic atIndex: 2];
        count2 ++;
        XCTAssertEqualObjects(dataDic[@"#event_name"], @"test2");
    };
    OCMStub([_mockThinking2 saveEventsData:[OCMArg any]]).andDo(saveClickDataInvocation2);
    
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

- (NSString *)getArchiveAccound:(ThinkingAnalyticsSDK *)thinkingSDK {
    id (*custom_msgSend)(id, SEL) = (id(*)(id, SEL))objc_msgSend;
    id (*custom_msgSend2)(id, SEL, id, id) = (id(*)(id, SEL, id, id))objc_msgSend;
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    NSString *accoundIDPath = custom_msgSend(thinkingSDK, @selector(accountIDFilePath));
    return custom_msgSend2([ThinkingAnalyticsSDK class], @selector(unarchiveFromFile: asClass:), accoundIDPath, [NSString class]);
#pragma clang diagnostic pop
    
}

- (void)test06LoginArchive {
    NSString *appid1 = @"kAPPID1";
    NSString *appid2 = @"kAPPID2";
    ThinkingAnalyticsSDK *thinkingSDK1 = [ThinkingAnalyticsSDK startWithAppId:appid1 withUrl:@"kURL1"];
    ThinkingAnalyticsSDK *thinkingSDK2 = [ThinkingAnalyticsSDK startWithAppId:appid2 withUrl:@"kURL2"];
    
    [thinkingSDK1 login:@"logintest"];
    [thinkingSDK2 login:@"logintest2"];
    [self waitForThinkingQueues];
    
    NSString *accoundID1 = [self getArchiveAccound:thinkingSDK1];
    NSLog(@"ret:%@", accoundID1);
    XCTAssertEqualObjects(accoundID1, @"logintest");
    
    NSString *accoundID2 = [self getArchiveAccound:thinkingSDK2];
    NSLog(@"ret2:%@", accoundID2);
    XCTAssertEqualObjects(accoundID2, @"logintest2");
    
    [thinkingSDK1 login:@"logintestnew1"];
    [thinkingSDK2 login:@"logintestnew2"];
    [self waitForThinkingQueues];
    
    accoundID1 = [self getArchiveAccound:thinkingSDK1];
    NSLog(@"ret:%@", accoundID1);
    XCTAssertEqualObjects(accoundID1, @"logintestnew1");
    
    accoundID2 = [self getArchiveAccound:thinkingSDK2];
    NSLog(@"ret2:%@", accoundID2);
    XCTAssertEqualObjects(accoundID2, @"logintestnew2");
    
    [thinkingSDK1 logout];
    [thinkingSDK2 logout];
    [self waitForThinkingQueues];
    
    accoundID1 = [self getArchiveAccound:thinkingSDK1];
    NSLog(@"ret:%@", accoundID1);
    XCTAssertNil(accoundID1);
    
    accoundID2 = [self getArchiveAccound:thinkingSDK2];
    NSLog(@"ret2:%@", accoundID2);
    XCTAssertNil(accoundID2);
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
    OCMStub([_mockThinkingInstance saveEventsData:[OCMArg any]]).andDo(saveClickDataInvocation);

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
    OCMReject([_mockThinkingInstance saveEventsData:[OCMArg any]]);
    [self waitForThinkingQueues];
    OCMVerifyAll(_mockThinkingInstance);
}

- (void)test09DisEnable {
    [self waitForThinkingQueues];
    [_mockThinkingInstance enableTracking:YES];
    OCMExpect([_mockThinkingInstance saveEventsData:[OCMArg any]]);
    [_mockThinkingInstance track:@"test"];
    [self waitForThinkingQueues];
    OCMVerifyAll(_mockThinkingInstance);
}

- (void)test10OptOut {
    [self waitForThinkingQueues];
    [_mockThinkingInstance clearSuperProperties];
    [_mockThinkingInstance setSuperProperties:@{@"key": @"value"}];
    [_mockThinkingInstance optOutTracking];
    [_mockThinkingInstance track:@"test"];
    [self waitForThinkingQueues];
    NSDictionary *superProperties = [_mockThinkingInstance currentSuperProperties];
    NSLog(@"superProperties:%@", superProperties);
    OCMReject([_mockThinkingInstance saveEventsData:[OCMArg any]]);
    XCTAssertEqualObjects(superProperties, @{});
    OCMVerifyAll(_mockThinkingInstance);
}

- (void)test11 {
    [_mockThinkingInstance optInTracking];
    void (^flushImmediately)(NSInvocation *) = ^(NSInvocation *invocation) {
        __weak NSDictionary *dataDic;
        [invocation getArgument: &dataDic atIndex: 2];
        
        NSLog(@"dataDic:%@",dataDic);
        XCTAssertEqualObjects(dataDic[@"#type"], @"user_del");
    };
    OCMStub([_mockThinkingInstance flushImmediately:[OCMArg any]]).andDo(flushImmediately);
    [_mockThinkingInstance optOutTrackingAndDeleteUser];
    [self waitForThinkingQueues];
}

- (void)test11OptIn {
    [_mockThinkingInstance optInTracking];
    [_mockThinkingInstance track:@"test"];
    [_mockThinkingInstance setSuperProperties:@{@"key2": @"value2"}];
    OCMExpect([_mockThinkingInstance saveEventsData:[OCMArg any]]);
    NSDictionary *superProperties = [_mockThinkingInstance currentSuperProperties];
    XCTAssertEqualObjects(superProperties, @{@"key2": @"value2"});
    [self waitForThinkingQueues];
    OCMVerifyAll(_mockThinkingInstance);
}

- (void)test12Identify {
    
    NSMutableArray *dataArrays = [NSMutableArray array];
    void (^saveClickDataInvocation)(NSInvocation *) = ^(NSInvocation *invocation) {
        __weak NSDictionary *dataDic;
        [invocation getArgument: &dataDic atIndex: 2];
        
        XCTAssertNotNil(dataDic);
        [dataArrays addObject:dataDic];
        
        NSInteger count = dataArrays.count;
        switch (count) {
            case 1:
                XCTAssertEqualObjects([dataDic objectForKey:@"#distinct_id"], @"distinct1");
                break;
            case 2:
                XCTAssertEqualObjects([dataDic objectForKey:@"#distinct_id"], @"distinctnew1");
                break;
            default:
                break;
        }
        NSLog(@"dataDic:%@",dataDic);
    };
    OCMStub([_mockThinkingInstance saveEventsData:[OCMArg any]]).andDo(saveClickDataInvocation);
    
    NSString *distinct1 = [_mockThinkingInstance getDistinctId];
    NSLog(@"distinct1:%@", distinct1);
    
    XCTAssertNotNil(distinct1);
    XCTAssertTrue([distinct1 isKindOfClass:[NSString class]] && distinct1.length > 0);
    
    [_mockThinkingInstance identify:@"distinct1"];
    [_mockThinkingInstance track:@"test"];
    distinct1 = [_mockThinkingInstance getDistinctId];
    NSLog(@"distinct1:%@", distinct1);
    
    XCTAssertEqualObjects(distinct1, @"distinct1");
    [_mockThinkingInstance identify:@"distinctnew1"];
    [_mockThinkingInstance track:@"test"];
    distinct1 = [_mockThinkingInstance getDistinctId];
    NSLog(@"distinct1:%@", distinct1);
    XCTAssertEqualObjects(distinct1, @"distinctnew1");
    [self waitForThinkingQueues];
}

- (NSString *)getArchiveDistince:(ThinkingAnalyticsSDK *)thinkingSDK {
    id (*custom_msgSend)(id, SEL) = (id(*)(id, SEL))objc_msgSend;
    id (*custom_msgSend2)(id, SEL, id, id) = (id(*)(id, SEL, id, id))objc_msgSend;
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    NSString *identifyPath = custom_msgSend(thinkingSDK, @selector(identifyIdFilePath));
    return custom_msgSend2([ThinkingAnalyticsSDK class], @selector(unarchiveFromFile: asClass:), identifyPath, [NSString class]);
#pragma clang diagnostic pop
    
}

- (void)test13IdentifyArchive {
    [_mockThinkingInstance identify:@"distinct1"];
    [self waitForThinkingQueues];
    
    NSString *distinct1 = [self getArchiveDistince:_mockThinkingInstance];
    NSLog(@"ret:%@", distinct1);
    XCTAssertEqualObjects(distinct1, @"distinct1");
    
    [_mockThinkingInstance identify:@"distinctnew1"];
    [self waitForThinkingQueues];
    
    distinct1 = [self getArchiveDistince:_mockThinkingInstance];
    NSLog(@"ret:%@", distinct1);
    XCTAssertEqualObjects(distinct1, @"distinctnew1");
}

- (void)test14Json {
    NSDictionary *dic = @{@"key":@"value", @"number": @3, @"date": @"2012-06-24 11:28:10.124", @"float": @1.3, @"double": @1.12345678 , @"bool": @YES};
    NSString *jsonStr = [TDJSONUtil JSONStringForObject:dic];
    NSLog(@"jsonStr:%@", jsonStr);
   XCTAssertEqualObjects(@"{\"bool\":true,\"number\":3,\"key\":\"value\",\"float\":1.3,\"double\":1.12345678,\"date\":\"2012-06-24 11:28:10.124\"}", jsonStr);
}

- (void)test15Superproperty {
    
    NSMutableArray *dataArrays = [NSMutableArray array];
    void (^saveClickDataInvocation)(NSInvocation *) = ^(NSInvocation *invocation) {
        __weak NSDictionary *dataDic;
        [invocation getArgument: &dataDic atIndex: 2];
        
        XCTAssertNotNil(dataDic);
        [dataArrays addObject:dataDic];
        
        NSInteger count = dataArrays.count;
        NSLog(@"dataDic:%@",dataDic);
        switch (count) {
            case 1:
                XCTAssertEqualObjects([[dataDic objectForKey:@"properties"] objectForKey:@"supKey"], @"supValue");
                break;
            case 2:
                XCTAssertEqualObjects([[dataDic objectForKey:@"properties"] objectForKey:@"supKey"], @"supValue2");
                XCTAssertEqualObjects([[dataDic objectForKey:@"properties"] objectForKey:@"supAddKey"], @"supAddValue");
                break;
            case 3:
                XCTAssertNil([[dataDic objectForKey:@"properties"] objectForKey:@"supAddKey"]);
                break;
            case 4:
                XCTAssertNil([[dataDic objectForKey:@"properties"] objectForKey:@"supKey"]);
                break;
            default:
                break;
        }
    };
    OCMStub([_mockThinkingInstance saveEventsData:[OCMArg any]]).andDo(saveClickDataInvocation);
    
    [_mockThinkingInstance clearSuperProperties];
    [_mockThinkingInstance setSuperProperties:@{@"supKey":@"supValue"}];
    [_mockThinkingInstance track:@"testSuper"];
    NSDictionary *superPro1 = [_mockThinkingInstance currentSuperProperties];
    NSLog(@"superPro1:%@", superPro1);
    
    XCTAssertTrue([superPro1 isKindOfClass:[NSDictionary class]] && superPro1.count == 1);
    XCTAssertEqualObjects(superPro1, @{@"supKey":@"supValue"});
    
    [_mockThinkingInstance setSuperProperties:@{@"supKey":@"supValue2", @"supAddKey":@"supAddValue"}];
    [_mockThinkingInstance track:@"testSuper"];
    superPro1 = [_mockThinkingInstance currentSuperProperties];
    NSLog(@"superPro1:%@", superPro1);
    
    XCTAssertTrue(superPro1.count == 2);
    NSDictionary *dic = @{@"supAddKey":@"supAddValue", @"supKey":@"supValue2"};
    XCTAssertTrue([superPro1 isEqualToDictionary:dic]);
    
    [_mockThinkingInstance unsetSuperProperty:@"supAddKey"];
    [_mockThinkingInstance track:@"testSuper"];
    superPro1 = [_mockThinkingInstance currentSuperProperties];
    NSLog(@"superPro1:%@", superPro1);
    
    XCTAssertTrue([superPro1 isKindOfClass:[NSDictionary class]] && superPro1.count == 1);
    [_mockThinkingInstance clearSuperProperties];
    [_mockThinkingInstance track:@"testSuper"];
    superPro1 = [_mockThinkingInstance currentSuperProperties];
    NSLog(@"superPro1:%@", superPro1);
    
    XCTAssertNotNil(superPro1);
    [self waitForThinkingQueues];
}

- (void)test16DynamicSuperProperties {
    __block int callTimes = 0;
    void (^saveClickDataInvocation)(NSInvocation *) = ^(NSInvocation *invocation) {
        __weak NSDictionary *dataDic;
        [invocation getArgument: &dataDic atIndex: 2];
        
        NSLog(@"dataDic:%@",dataDic);
        NSDictionary *properties = dataDic[@"properties"];
        NSString *expectStr = [NSString stringWithFormat:@"testStr%d", callTimes];
        XCTAssertEqualObjects(properties[@"test"], expectStr);
        
        callTimes ++;
    };
    OCMStub([_mockThinkingInstance saveEventsData:[OCMArg any]]).andDo(saveClickDataInvocation);
    
    static NSString *testStr = @"testStr0";
    [_mockThinkingInstance registerDynamicSuperProperties:^NSDictionary * _Nonnull{
        return @{@"test":testStr};
    }];
    [_mockThinkingInstance track:@"test"];
    [self waitForThinkingQueues];
    
    testStr = @"testStr1";
    [_mockThinkingInstance track:@"test"];
    [self waitForThinkingQueues];
}

@end
