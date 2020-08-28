//
//  ThinkingSDKDEMOTests.m
//  ThinkingSDKDEMOTests
//
//  Created by syj on 2019/6/24.
//  Copyright © 2019年 thinking. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "ThinkingAnalyticsSDKPrivate.h"
#import <objc/message.h>
#import "TDJSONUtil.h"
#import "CalibratedTime/TDCalibratedTimeWithNTP.h"

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
    static int count = 0;
    void (^saveEventsDataInvocation)(NSInvocation *) = ^(NSInvocation *invocation) {
        count ++;
    };
    OCMStub([_mockThinkingInstance saveEventsData:[OCMArg any]]).andDo(saveEventsDataInvocation);
    
    [_mockThinkingInstance track:@"test"];
    [_mockThinkingInstance track:@"test" properties:@{@"UserName":@"TA1"}];
    [_mockThinkingInstance track:@"test" properties:@{@"timezone_offset": [NSNumber numberWithInteger:[[NSTimeZone localTimeZone] secondsFromGMTForDate:[NSDate date]]]} time:[NSDate date] timeZone:[NSTimeZone timeZoneWithName:@"UTC+0800"]];
    [_mockThinkingInstance user_set:@{@"UserName":@"TA1", @"Age":[NSNumber numberWithInt:20]}];
    [_mockThinkingInstance user_unset:@"key1"];
    [_mockThinkingInstance user_setOnce:@{@"setOnce":@"setonevalue1"}];
    [_mockThinkingInstance user_delete];
    [_mockThinkingInstance user_add:@{@"key1":[NSNumber numberWithInt:6]}];
    [self waitForThinkingQueues];
    XCTAssertEqualObjects([NSNumber numberWithInteger:count], @8);
}

- (void)test02doFlush {
    OCMExpect([_mockThinkingInstance saveEventsData:[OCMArg isNotNil]]);
    OCMExpect([_mockThinkingInstance flush]);
    for (int i = 0; i <= 100; i++) {
        [_mockThinkingInstance track:@"test"];
    }
    
    [self waitForThinkingQueues];
    OCMVerifyAll(_mockThinkingInstance);
}

- (NSDictionary *)allPropertyTypes {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
    return @{ @"string": @"hello", @"number": @3, @"float": @1.3 , @"bool": @YES };
}

- (void)test03TrackEvent {
    void (^saveEventsDataInvocation)(NSInvocation *) = ^(NSInvocation *invocation) {
        __weak NSDictionary *dataDic;
        [invocation getArgument:&dataDic atIndex:2];
        
        NSString *timeStr = dataDic[@"#time"];
        NSDateFormatter *timeFormatter = [[NSDateFormatter alloc]init];
        timeFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
        NSDate *date = [timeFormatter dateFromString:timeStr];
        NSDictionary *properties = dataDic[@"properties"];
        
        XCTAssertNotNil(date);
        XCTAssertNotNil(timeStr);
        XCTAssertNotNil(dataDic);
        XCTAssertNotNil(dataDic[@"#uuid"]);
        XCTAssertEqualObjects(dataDic[@"#event_name"], @"test");
        XCTAssertEqualObjects(dataDic[@"#type"], @"track");
        XCTAssertTrue([properties allKeys].count == 7);
        
        XCTAssertNotNil(properties[@"#app_version"]);
        XCTAssertTrue([properties[@"#app_version"] isKindOfClass:[NSString class]]);
        if (properties[@"#network_type"]) {
            NSArray *network = @[@"WIFI", @"2G", @"3G", @"4G", @"NULL"];
            XCTAssertTrue([network containsObject:properties[@"#network_type"]]);
        }
        XCTAssertEqualObjects(properties[@"string"], @"hello");
        
        int isBool = strcmp([properties[@"bool"] objCType], [@YES objCType]);
        
        XCTAssertTrue(isBool == 0);
        XCTAssertTrue([properties[@"float"] isKindOfClass:[NSNumber class]]);
        XCTAssertTrue([properties[@"number"] isKindOfClass:[NSNumber class]]);
        
        XCTAssertTrue([date isKindOfClass:[NSDate class]]);
        XCTAssertTrue([[dataDic allKeys] count] == 6);
    };
    OCMStub([_mockThinkingInstance saveEventsData:[OCMArg any]]).andDo(saveEventsDataInvocation);
    [_mockThinkingInstance track:@"test" properties:[self allPropertyTypes]];
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
    void (^saveEventsDataInvocation)(NSInvocation *) = ^(NSInvocation *invocation) {
        __weak NSDictionary *dataDic;
        [invocation getArgument:&dataDic atIndex:2];
        count ++;
        XCTAssertEqualObjects(dataDic[@"#event_name"], @"test");
    };
    OCMStub([_mockThinking1 saveEventsData:[OCMArg any]]).andDo(saveEventsDataInvocation);
    
    static int count2 = 0;
    void (^saveEventsDataInvocation2)(NSInvocation *) = ^(NSInvocation *invocation) {
        __weak NSDictionary *dataDic;
        [invocation getArgument:&dataDic atIndex:2];
        count2 ++;
        XCTAssertEqualObjects(dataDic[@"#event_name"], @"test2");
    };
    OCMStub([_mockThinking2 saveEventsData:[OCMArg any]]).andDo(saveEventsDataInvocation2);
    
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
    XCTAssertEqualObjects(accoundID1, @"logintest");
    
    NSString *accoundID2 = [self getArchiveAccound:thinkingSDK2];
    XCTAssertEqualObjects(accoundID2, @"logintest2");
    
    [thinkingSDK1 login:@"logintestnew1"];
    [thinkingSDK2 login:@"logintestnew2"];
    [self waitForThinkingQueues];
    
    accoundID1 = [self getArchiveAccound:thinkingSDK1];
    XCTAssertEqualObjects(accoundID1, @"logintestnew1");
    
    accoundID2 = [self getArchiveAccound:thinkingSDK2];
    XCTAssertEqualObjects(accoundID2, @"logintestnew2");
    
    [thinkingSDK1 logout];
    [thinkingSDK2 logout];
    [self waitForThinkingQueues];
    
    accoundID1 = [self getArchiveAccound:thinkingSDK1];
    XCTAssertNil(accoundID1);
    
    accoundID2 = [self getArchiveAccound:thinkingSDK2];
    XCTAssertNil(accoundID2);
}

- (void)test07LoginTrack {
    NSMutableArray *dataArrays = [NSMutableArray array];
    void (^saveEventsDataInvocation)(NSInvocation *) = ^(NSInvocation *invocation) {
        __weak NSDictionary *dataDic;
        [invocation getArgument:&dataDic atIndex:2];
        
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
    };
    OCMStub([_mockThinkingInstance saveEventsData:[OCMArg any]]).andDo(saveEventsDataInvocation);

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
    OCMReject([_mockThinkingInstance saveEventsData:[OCMArg any]]);
    XCTAssertEqualObjects(superProperties, @{});
    OCMVerifyAll(_mockThinkingInstance);
}

- (void)test11optOutTrackingAndDeleteUser {
    [_mockThinkingInstance optInTracking];
    void (^flushImmediately)(NSInvocation *) = ^(NSInvocation *invocation) {
        __weak NSDictionary *dataDic;
        [invocation getArgument:&dataDic atIndex:2];
        
        XCTAssertEqualObjects(dataDic[@"#type"], @"user_del");
    };
    OCMStub([_mockThinkingInstance flushImmediately:[OCMArg any]]).andDo(flushImmediately);
    [_mockThinkingInstance optOutTrackingAndDeleteUser];
    [self waitForThinkingQueues];
}

- (void)test12OptIn {
    [_mockThinkingInstance optInTracking];
    OCMExpect([_mockThinkingInstance saveEventsData:[OCMArg any]]);
    [_mockThinkingInstance track:@"test"];
    [_mockThinkingInstance setSuperProperties:@{@"key2": @"value2"}];
    NSDictionary *superProperties = [_mockThinkingInstance currentSuperProperties];
    XCTAssertEqualObjects(superProperties, @{@"key2": @"value2"});
    [self waitForThinkingQueues];
    OCMVerifyAll(_mockThinkingInstance);
}

- (void)test13Identify {
    NSMutableArray *dataArrays = [NSMutableArray array];
    void (^saveEventsDataInvocation)(NSInvocation *) = ^(NSInvocation *invocation) {
        __weak NSDictionary *dataDic;
        [invocation getArgument:&dataDic atIndex:2];
        
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
    };
    OCMStub([_mockThinkingInstance saveEventsData:[OCMArg any]]).andDo(saveEventsDataInvocation);
    
    NSString *distinct1 = [_mockThinkingInstance getDistinctId];
    
    XCTAssertNotNil(distinct1);
    XCTAssertTrue([distinct1 isKindOfClass:[NSString class]] && distinct1.length > 0);
    
    [_mockThinkingInstance identify:@"distinct1"];
    [_mockThinkingInstance track:@"test"];
    distinct1 = [_mockThinkingInstance getDistinctId];
    
    XCTAssertEqualObjects(distinct1, @"distinct1");
    [_mockThinkingInstance identify:@"distinctnew1"];
    [_mockThinkingInstance track:@"test"];
    distinct1 = [_mockThinkingInstance getDistinctId];
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

- (void)test14IdentifyArchive {
    [_mockThinkingInstance identify:@"distinct1"];
    [self waitForThinkingQueues];
    
    NSString *distinct1 = [self getArchiveDistince:_mockThinkingInstance];
    XCTAssertEqualObjects(distinct1, @"distinct1");
    
    [_mockThinkingInstance identify:@"distinctnew1"];
    [self waitForThinkingQueues];
    
    distinct1 = [self getArchiveDistince:_mockThinkingInstance];
    XCTAssertEqualObjects(distinct1, @"distinctnew1");
}

- (void)test15Json {
    NSDictionary *dic = @{@"key":@"value", @"number": @3, @"date": @"2012-06-24 11:28:10.124", @"float": @1.3, @"double": @1.12345678 , @"bool": @YES};
    NSString *jsonStr = [TDJSONUtil JSONStringForObject:dic];
    XCTAssertEqualObjects(@"{\"bool\":true,\"number\":3,\"key\":\"value\",\"float\":1.3,\"double\":1.12345678,\"date\":\"2012-06-24 11:28:10.124\"}", jsonStr);
}

- (void)test16Superproperty {
    NSMutableArray *dataArrays = [NSMutableArray array];
    void (^saveEventsDataInvocation)(NSInvocation *) = ^(NSInvocation *invocation) {
        __weak NSDictionary *dataDic;
        [invocation getArgument:&dataDic atIndex:2];
        
        XCTAssertNotNil(dataDic);
        [dataArrays addObject:dataDic];
        
        NSInteger count = dataArrays.count;
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
    OCMStub([_mockThinkingInstance saveEventsData:[OCMArg any]]).andDo(saveEventsDataInvocation);
    
    [_mockThinkingInstance clearSuperProperties];
    [_mockThinkingInstance setSuperProperties:@{@"supKey":@"supValue"}];
    [_mockThinkingInstance track:@"testSuper"];
    NSDictionary *superPro1 = [_mockThinkingInstance currentSuperProperties];
    
    XCTAssertTrue([superPro1 isKindOfClass:[NSDictionary class]] && superPro1.count == 1);
    XCTAssertEqualObjects(superPro1, @{@"supKey":@"supValue"});
    
    [_mockThinkingInstance setSuperProperties:@{@"supKey":@"supValue2", @"supAddKey":@"supAddValue"}];
    [_mockThinkingInstance track:@"testSuper"];
    superPro1 = [_mockThinkingInstance currentSuperProperties];
    
    XCTAssertTrue(superPro1.count == 2);
    NSDictionary *dic = @{@"supAddKey":@"supAddValue", @"supKey":@"supValue2"};
    XCTAssertTrue([superPro1 isEqualToDictionary:dic]);
    
    [_mockThinkingInstance unsetSuperProperty:@"supAddKey"];
    [_mockThinkingInstance track:@"testSuper"];
    superPro1 = [_mockThinkingInstance currentSuperProperties];
    
    XCTAssertTrue([superPro1 isKindOfClass:[NSDictionary class]] && superPro1.count == 1);
    [_mockThinkingInstance clearSuperProperties];
    [_mockThinkingInstance track:@"testSuper"];
    superPro1 = [_mockThinkingInstance currentSuperProperties];
    
    XCTAssertNotNil(superPro1);
    [self waitForThinkingQueues];
}

- (void)test17DynamicSuperProperties {
    __block int callTimes = 0;
    void (^saveEventsDataInvocation)(NSInvocation *) = ^(NSInvocation *invocation) {
        __weak NSDictionary *dataDic;
        [invocation getArgument:&dataDic atIndex:2];
        
        NSDictionary *properties = dataDic[@"properties"];
        NSString *expectStr = [NSString stringWithFormat:@"testStr%d", callTimes];
        XCTAssertEqualObjects(properties[@"test"], expectStr);
        
        callTimes ++;
    };
    OCMStub([_mockThinkingInstance saveEventsData:[OCMArg any]]).andDo(saveEventsDataInvocation);
    
    static NSString *testStr = @"testStr0";
    [_mockThinkingInstance registerDynamicSuperProperties:^NSDictionary * _Nonnull {
        return @{@"test":testStr};
    }];
    [_mockThinkingInstance track:@"test"];
    [self waitForThinkingQueues];
    
    testStr = @"testStr1";
    [_mockThinkingInstance track:@"test"];
    [self waitForThinkingQueues];
}

- (void)test18LightInstanceMulti {
    NSString *appid1 = @"kAPPID1";
    NSString *appid2 = @"kAPPID2";
    ThinkingAnalyticsSDK *thinkingSDK1 = [ThinkingAnalyticsSDK startWithAppId:appid1 withUrl:@"kURL1"];
    ThinkingAnalyticsSDK *thinkingSDK2 = [ThinkingAnalyticsSDK startWithAppId:appid2 withUrl:@"kURL2"];
    
    ThinkingAnalyticsSDK *lightInstance1 = [thinkingSDK1 createLightInstance];
    ThinkingAnalyticsSDK *lightInstance2 = [thinkingSDK2 createLightInstance];
    
    XCTAssertNotEqual(thinkingSDK1, thinkingSDK2);
    XCTAssertEqual(lightInstance1.appid, thinkingSDK1.appid);
    XCTAssertEqual(lightInstance2.appid, thinkingSDK2.appid);
    XCTAssertEqual(lightInstance1.getDistinctId, lightInstance2.getDistinctId);
    XCTAssertEqual(lightInstance1.getDistinctId, thinkingSDK1.getDistinctId);
    XCTAssertEqual(thinkingSDK1.getDistinctId, thinkingSDK2.getDistinctId);
}

- (void)test19LightInstance {
    ThinkingAnalyticsSDK *thinkingSDK1 = [ThinkingAnalyticsSDK startWithAppId:@"appid" withUrl:@"kURL1"];
    ThinkingAnalyticsSDK *lightInstance1 = [thinkingSDK1 createLightInstance];
    id mockLightInstance = OCMPartialMock(lightInstance1);
    
    static int count = 0;
    void (^saveEventsDataInvocation)(NSInvocation *) = ^(NSInvocation *invocation) {
        __weak NSDictionary *dataDic;
        [invocation getArgument:&dataDic atIndex:2];
        
        NSDictionary *properties = dataDic[@"properties"];
        XCTAssertNotNil([dataDic objectForKey:@"#distinct_id"]);
        NSLog(@"light:%@", dataDic);
        switch (count) {
            case 0:
                XCTAssertNil([dataDic objectForKey:@"#account_id"]);
                break;
            case 1:
                XCTAssertEqualObjects([dataDic objectForKey:@"#account_id"], @"lightacc");
                break;
            case 2:
                XCTAssertEqualObjects([dataDic objectForKey:@"#distinct_id"], @"lightdist");
                break;
            case 3:
                XCTAssertEqualObjects([properties objectForKey:@"lightKey"], @"lightValue");
                XCTAssertEqualObjects([properties objectForKey:@"lightKey2"], @"lightValue2");
                break;
            case 4:
                XCTAssertNil([dataDic objectForKey:@"#account_id"]);
                break;
            case 5:
                XCTAssertEqualObjects([properties objectForKey:@"lightKey"], @"lightValue");
                XCTAssertNil([properties objectForKey:@"lightKey2"]);
                break;
            case 6:
                XCTAssertNil([properties objectForKey:@"lightKey"]);
                XCTAssertNil([properties objectForKey:@"lightKey2"]);
                break;
            case 7:
                XCTAssertEqualObjects([properties objectForKey:@"test"], @"testStr0");
                break;
            case 8:
                XCTAssertEqualObjects([properties objectForKey:@"test"], @"testStr1");
                break;
            default:
                break;
        }
        count ++;
    };
    OCMStub([mockLightInstance saveEventsData:[OCMArg any]]).andDo(saveEventsDataInvocation);
    
    [mockLightInstance track:@"track"];
    
    [mockLightInstance login:@"lightacc"];
    [mockLightInstance track:@"track"];
    
    [mockLightInstance identify:@"lightdist"];
    [mockLightInstance track:@"track"];
    
    [mockLightInstance setSuperProperties:@{@"lightKey":@"lightValue", @"lightKey2":@"lightValue2"}];
    [mockLightInstance track:@"track"];
                                    
    [mockLightInstance logout];
    [mockLightInstance track:@"track"];
                                    
    [mockLightInstance unsetSuperProperty:@"lightKey2"];
    [mockLightInstance track:@"track"];
    
    [mockLightInstance clearSuperProperties];
    [mockLightInstance track:@"track"];
    
    static NSString *testStr = @"testStr0";
    [mockLightInstance registerDynamicSuperProperties:^NSDictionary * _Nonnull {
        return @{@"test":testStr};
    }];
    [mockLightInstance track:@"test"];
    [self waitForThinkingQueues];
    
    testStr = @"testStr1";
    [mockLightInstance track:@"test"];
    
    [self waitForThinkingQueues];
    
    [self.mockThinkingInstance stopMocking];
    self.mockThinkingInstance = nil;
}

- (void)test20TimeZoneOffset {
    __block int index = 0;
    NSDate *date = [NSDate date];
    NSTimeZone *timezone = [NSTimeZone timeZoneWithName:@"America/Chicago"];
    void (^saveEventsDataInvocation)(NSInvocation *) = ^(NSInvocation *invocation) {
        __weak NSDictionary *dataDic;
        [invocation getArgument:&dataDic atIndex:2];
        if (index == 0) {
            NSTimeZone *tz = [NSTimeZone localTimeZone];
            NSInteger sourceGMTOffset = [tz secondsFromGMTForDate:[NSDate date]];
            XCTAssertTrue([[[dataDic objectForKey:@"properties"] objectForKey:@"#zone_offset"] intValue] == (int)sourceGMTOffset/3600);
        } else if (index == 1) {
            NSInteger sourceGMTOffset = [timezone secondsFromGMTForDate:[NSDate date]];
            XCTAssertTrue([[[dataDic objectForKey:@"properties"] objectForKey:@"#zone_offset"] intValue] == (int)sourceGMTOffset/3600);
            NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
            timeFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
            timeFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
            timeFormatter.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            timeFormatter.timeZone = timezone;
            XCTAssertEqualObjects([dataDic objectForKey:@"#time"], [timeFormatter stringFromDate:date]);
        }
        index++;
    };
    OCMStub([_mockThinkingInstance saveEventsData:[OCMArg any]]).andDo(saveEventsDataInvocation);
    [_mockThinkingInstance track:@"test"];
    [_mockThinkingInstance track:@"test" properties:nil time:date timeZone:timezone];
    [self waitForThinkingQueues];
}

- (void)test21User {
    __block int index = 0;
    NSDate *date = [NSDate date];
    NSArray *arr1 = @[@"4", @"3"];
    NSArray *arr2 = @[@"44", @"33"];
    void (^saveEventsDataInvocation)(NSInvocation *) = ^(NSInvocation *invocation) {
        __weak NSDictionary *dataDic;
        [invocation getArgument:&dataDic atIndex:2];

        NSString *timeStr = dataDic[@"#time"];
        NSDateFormatter *timeFormatter = [[NSDateFormatter alloc]init];
        timeFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
        NSDate *date = [timeFormatter dateFromString:timeStr];
        NSDictionary *properties = dataDic[@"properties"];

        XCTAssertNotNil(date);
        XCTAssertNotNil(timeStr);
        XCTAssertNotNil(dataDic);
        XCTAssertNotNil(dataDic[@"#uuid"]);
        if (index == 0) {
            XCTAssertTrue([[properties allKeys] count] == 1);
            XCTAssertEqualObjects(dataDic[@"#type"], @"user_add");
            XCTAssertTrue([properties[@"key1"] intValue] == 6);
        } else if (index == 1) {
            XCTAssertTrue([[properties allKeys] count] == 3);
            XCTAssertEqualObjects(dataDic[@"#type"], @"user_set");
            XCTAssertEqualObjects(properties[@"UserName"], @"UserName");
            NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
            timeFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
            timeFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
            timeFormatter.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            XCTAssertEqualObjects([dataDic objectForKey:@"#time"], [timeFormatter stringFromDate:date]);
        } else if (index == 2) {
            XCTAssertTrue([[properties allKeys] count] == 1);
            XCTAssertEqualObjects(dataDic[@"#type"], @"user_setOnce");
        } else if (index == 3) {
            XCTAssertTrue([[properties allKeys] count] == 0);
            XCTAssertEqualObjects(dataDic[@"#type"], @"user_del");
        } else if (index == 4) {
            XCTAssertTrue([[properties allKeys] count] == 2);
            XCTAssertEqualObjects(dataDic[@"#type"], @"user_append");
            XCTAssertEqualObjects([properties objectForKey:@"arrKey"], arr1);
            XCTAssertEqualObjects([properties objectForKey:@"arrKey2"], arr2);
        }

        index ++;
    };
    OCMStub([_mockThinkingInstance saveEventsData:[OCMArg any]]).andDo(saveEventsDataInvocation);
    [_mockThinkingInstance user_add:@{@"key1":[NSNumber numberWithInt:6]}];
    [_mockThinkingInstance user_set:@{@"UserName":@"UserName", @"Age":[NSNumber numberWithInt:20], @"date":date}];
    [_mockThinkingInstance user_setOnce:@{@"setOnce":@"setonevalue1"}];
    [_mockThinkingInstance user_delete];
    [_mockThinkingInstance user_append:@{@"arrKey": arr1, @"arrKey2": arr2}];
    [self waitForThinkingQueues];
}

- (void)test22CalibrateTime {
    [ThinkingAnalyticsSDK calibrateTime:100];
      void (^saveEventsDataInvocation)(NSInvocation *) = ^(NSInvocation *invocation) {
          __weak NSDictionary *dataDic;
          [invocation getArgument:&dataDic atIndex:2];
          
          NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
          [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
          NSDate *date = [dateFormat dateFromString:[dataDic objectForKey:@"#time"]];
          
          NSTimeInterval time = [date timeIntervalSince1970]*1000;
          XCTAssertGreaterThan(time, 100);
          XCTAssertLessThan(time, 101);
      };
      OCMStub([_mockThinkingInstance saveEventsData:[OCMArg any]]).andDo(saveEventsDataInvocation);
      
      [_mockThinkingInstance track:@"test"];
      [self waitForThinkingQueues];
}

- (void)test23CalibrateTimeWithNtp {
    [[TDCalibratedTimeWithNTP sharedInstance] recalibrationWithNtps:@[@"ntp.aliyun.com"]];
    id _mockCalibrateTime = OCMPartialMock([TDCalibratedTimeWithNTP sharedInstance]);
    void (^serverTimeInvocation)(NSInvocation *) = ^(NSInvocation *invocation) {
        NSTimeInterval value = 100;
        [invocation setReturnValue:&value];
    };
    OCMStub([_mockCalibrateTime serverTime]).andDo(serverTimeInvocation);
    [ThinkingAnalyticsSDK calibrateTimeWithNtp:@"ntp.aliyun.com"];
    [_mockCalibrateTime setStopCalibrate:NO];

    void (^saveEventsDataInvocation)(NSInvocation *) = ^(NSInvocation *invocation) {
        __weak NSDictionary *dataDic;
        [invocation getArgument:&dataDic atIndex:2];

        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        NSDate *date = [dateFormat dateFromString:[dataDic objectForKey:@"#time"]];

        NSTimeInterval time = [date timeIntervalSince1970]*1000;
        XCTAssertGreaterThan(time, 100000);
        XCTAssertLessThan(time, 101000);
    };
    OCMStub([_mockThinkingInstance saveEventsData:[OCMArg any]]).andDo(saveEventsDataInvocation);

    [_mockThinkingInstance track:@"test"];
    [self waitForThinkingQueues];
    
    [_mockCalibrateTime stopMocking];
    _mockCalibrateTime = nil;
}

/**
 track_update
 track_overwrite
 */
- (void)test24SpecialTrackAction {
    void (^saveEventsDataInvocation)(NSInvocation *) = ^(NSInvocation *invocation) {
        __weak NSDictionary *dataDic;
        [invocation getArgument:&dataDic atIndex:2];
        
        NSString *timeStr = dataDic[@"#time"];
        NSDateFormatter *timeFormatter = [[NSDateFormatter alloc]init];
        timeFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
        NSDate *date = [timeFormatter dateFromString:timeStr];
        NSDictionary *properties = dataDic[@"properties"];
        
        XCTAssertNotNil(date);
        XCTAssertNotNil(timeStr);
        XCTAssertNotNil(dataDic);
        XCTAssertNotNil(dataDic[@"#uuid"]);
        
        XCTAssertNotNil(properties[@"#app_version"]);
        XCTAssertTrue([properties[@"#app_version"] isKindOfClass:[NSString class]]);
        if (properties[@"#network_type"]) {
            NSArray *network = @[@"WIFI", @"2G", @"3G", @"4G", @"NULL"];
            XCTAssertTrue([network containsObject:properties[@"#network_type"]]);
        }
        
//        if ([dataDic[@"#event_type"] isEqualToString:@"track_first"]) {
//            XCTAssertNotNil(dataDic[@"#first_check_id"]);
//            XCTAssertEqualObjects(dataDic[@"#first_check_id"], @"test_first_check_id");
//            XCTAssertEqualObjects(dataDic[@"#event_name"], @"test_event_name_first_check_id");
//        } else if ([dataDic[@"#event_type"] isEqualToString:@"track_update"]) {
//            XCTAssertNotNil(dataDic[@"#event_id"]);
//            XCTAssertEqualObjects(dataDic[@"#event_id"], @"test_update_event_id");
//            XCTAssertEqualObjects(dataDic[@"#event_name"], @"test_name_trackUpdate");
//        } else if ([dataDic[@"#event_type"] isEqualToString:@"track_overwrite"]) {
//            XCTAssertNotNil(dataDic[@"#event_id"]);
//            XCTAssertEqualObjects(dataDic[@"#event_id"], @"test_overwrite_event_id");
//            XCTAssertEqualObjects(dataDic[@"#event_name"], @"test_name_trackOverwrite");
//        }
    };
    OCMStub([_mockThinkingInstance saveEventsData:[OCMArg any]]).andDo(saveEventsDataInvocation);
    
    // #first_check_id
    TDFirstEventModel *firstModel = [[TDFirstEventModel alloc] initWithEventName:@"EventName_FirstCheckID" firstCheckID:@"event_first_check_id"];
    firstModel.properties = @{
        @"key_first_check_id": @"value_first_check_id",
    };
    [_mockThinkingInstance trackWithEventModel:firstModel];
    
    // track_update
    TDUpdateEventModel *updateModel = [[TDUpdateEventModel alloc] initWithEventName:@"EventName_Edit" eventID:@"test_event_id"];
    updateModel.properties = @{
        @"custom_edit_key": @"custom_edit_value",
        @"custom_edit_key2": @"custom_edit_value2",
    };
    [_mockThinkingInstance trackWithEventModel:updateModel];
    
    // track_overwrite
    TDOverwriteEventModel *overwriteModel = [[TDOverwriteEventModel alloc] initWithEventName:@"EventName_Edit" eventID:@"test_event_id"];
    overwriteModel.properties = @{
        @"custom_edit_key": @"custom_edit_value_overwrite",
    };
    [_mockThinkingInstance trackWithEventModel:overwriteModel];

    [self waitForThinkingQueues];
}

@end
