//
//  TEST_10000.m
//  ThinkingSDKDEMOUITests
//
//  Created by wwango on 2021/11/11.
//  Copyright © 2021 thinking. All rights reserved.
//

#import "TEST_10000.h"
#import <OCMock/OCMock.h>
#import <ThinkingSDK/ThinkingAnalyticsSDK.h>
#import "TEST_Model.h"
#import "TEST_Helper.h"

@interface TEST_10000 ()

@property(nonatomic, strong) NSMutableArray<TEST_Model *> *models;

@end


@implementation TEST_10000

- (void)setUp {
    self.models = [NSMutableArray arrayWithArray:[TEST_Model getTestDatas:@"TEST_10000"]];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
- (void)tearDown {
    NSMutableDictionary *dic = [ThinkingAnalyticsSDK performSelector:@selector(_getAllInstances)];
    [dic removeAllObjects];
    dic = nil;
    [TEST_Helper deleteNSLibraryDirectory];
}
#pragma clang diagnostic pop

- (void)test_10000 {
    
    // test_10000_1, 验证单个实例的创建
    TEST_Model *model1 = self.models[0];
    TEST_Input_Model *input1 = model1.input;
    ThinkingAnalyticsSDK *ins1 = [ThinkingAnalyticsSDK startWithAppId:input1.appid withUrl:input1.serverURL];
    [ins1 identify:input1.distinctid];
    [ins1 login:input1.accountid];
    [ins1 enableTracking:input1.enable];
    [ins1 setSuperProperties:input1.superProperties];
    
    
//    ThinkingAnalyticsSDK *obj = OCMPartialMock(ins1);
//    OCMStub([obj getDistinctId]).andReturn(@"aaa");
    
    XCTestExpectation* expect1 = [[XCTestExpectation alloc] initWithDescription:@"time out !!"];
    [TEST_Helper checkInstance:ins1
                         input:input1
                    hasInsName:NO
                        result:^(BOOL result) {
        
        XCTAssertTrue(result, @"初始化error");
        [expect1 fulfill];
    }];
    
    // 验证多个实例的创建
    TEST_Model *model2 = self.models[1];
    TEST_Input_Model *input2 = model2.input;
    ThinkingAnalyticsSDK *ins2 = [ThinkingAnalyticsSDK startWithAppId:input2.appid withUrl:input2.serverURL];
    [ins2 identify:input2.distinctid];
    [ins2 login:input2.accountid];
    [ins2 enableTracking:input2.enable];
    [ins2 setSuperProperties:input2.superProperties];
    
    XCTestExpectation* expect2 = [[XCTestExpectation alloc] initWithDescription:@"time out !!"];
    [TEST_Helper checkInstance:ins2
                         input:input2
                    hasInsName:NO
                        result:^(BOOL result) {
        XCTAssertTrue(result, @"初始化error");
        [expect2 fulfill];
    }];

    
    // 实例名称1
    TEST_Model *model3 = self.models[2];
    TEST_Input_Model *input3 = model3.input;
    TDConfig *config3 = [[TDConfig alloc] initWithAppId:input3.appid serverUrl:input3.serverURL];
    config3.name = input3.instanceName;
    ThinkingAnalyticsSDK *ins3 = [ThinkingAnalyticsSDK startWithConfig:config3];
    [ins3 identify:input3.distinctid];
    [ins3 login:input3.accountid];
    [ins3 enableTracking:input3.enable];
    [ins3 setSuperProperties:input3.superProperties];
    
    XCTestExpectation* expect3 = [[XCTestExpectation alloc] initWithDescription:@"time out !!"];
    [TEST_Helper checkInstance:ins3
                         input:input3
                    hasInsName:YES
                        result:^(BOOL result) {
        XCTAssertTrue(result ,@"初始化error");
        [expect3 fulfill];
    }];

    
    TEST_Model *model4 = self.models[3];
    TEST_Input_Model *input4 = model4.input;
    TDConfig *config4 = [[TDConfig alloc] initWithAppId:input4.appid serverUrl:input4.serverURL];
    config4.name = input4.instanceName;
    ThinkingAnalyticsSDK *ins4 = [ThinkingAnalyticsSDK startWithConfig:config4];
    [ins4 identify:input4.distinctid];
    [ins4 login:input4.accountid];
    [ins4 enableTracking:input4.enable];
    [ins4 setSuperProperties:input4.superProperties];
    
    XCTestExpectation* expect4 = [[XCTestExpectation alloc] initWithDescription:@"time out !!"];
    [TEST_Helper checkInstance:ins4
                         input:input4
                    hasInsName:YES
                        result:^(BOOL result) {
        XCTAssertTrue(result ,@"初始化error");
        [expect4 fulfill];
    }];
    
    // 验证数据异常的情况1
    TEST_Input_Model *input5 = self.models[4].input;
    TDConfig *config5 = [[TDConfig alloc] initWithAppId:input5.appid serverUrl:input5.serverURL];
    config5.name = input5.instanceName;
    ThinkingAnalyticsSDK *ins5 = [ThinkingAnalyticsSDK startWithConfig:config5];
    [ins5 identify:input5.distinctid];
    [ins5 login:input5.accountid];
    
    // 验证数据异常的情况2
    TEST_Input_Model *input6 = self.models[4].input;
    ThinkingAnalyticsSDK *ins6 = [ThinkingAnalyticsSDK startWithAppId:input6.appid withUrl:input6.serverURL];
    [ins6 identify:input6.distinctid];
    [ins6 login:input6.accountid];
    
    XCTAssertNil(ins5, @"初始化error");
    XCTAssertNil(ins6, @"初始化error");
    
    // 轻实例
    ThinkingAnalyticsSDK *lightIns = [ins4 createLightInstance];
    XCTAssertNotNil(lightIns, @"轻实例初始化error");
    XCTAssertEqualObjects([lightIns valueForKey:@"appid"], [ins4 valueForKey:@"appid"], @"轻实例初始化error");
    XCTAssertEqualObjects([lightIns valueForKey:@"serverURL"], [ins4 valueForKey:@"serverURL"], @"轻实例初始化error");
    
    // 获取实例
    ThinkingAnalyticsSDK *ins = [ThinkingAnalyticsSDK sharedInstance];
    ThinkingAnalyticsSDK *_ins1 = [ThinkingAnalyticsSDK sharedInstanceWithAppid:self.models[0].input.appid];
    ThinkingAnalyticsSDK *_ins2 = [ThinkingAnalyticsSDK sharedInstanceWithAppid:self.models[1].input.appid];
    ThinkingAnalyticsSDK *_ins3 = [ThinkingAnalyticsSDK sharedInstanceWithAppid:self.models[2].input.instanceName];
    ThinkingAnalyticsSDK *_ins4 = [ThinkingAnalyticsSDK sharedInstanceWithAppid:self.models[3].input.instanceName];
    
    XCTAssertNotNil(ins, @"验证实例的获取error");
    XCTAssertNotNil(ins1, @"验证实例的获取error");
    XCTAssertNotNil(ins2, @"验证实例的获取error");
    XCTAssertNotNil(ins3, @"验证实例的获取error");
    XCTAssertNotNil(ins4, @"验证实例的获取error");
    
    XCTAssertEqualObjects(ins, ins1, @"验证实例的获取error");
    XCTAssertEqualObjects(_ins1, ins1,  @"验证实例的获取error");
    XCTAssertEqualObjects(_ins2, ins2,  @"验证实例的获取error");
    XCTAssertEqualObjects(_ins3, ins3,  @"验证实例的获取error");
    XCTAssertEqualObjects(_ins4, ins4,  @"验证实例的获取error");
    
    XCTAssertEqualObjects(_ins1.description, ins1.description,  @"验证实例的获取error");
    XCTAssertEqualObjects(_ins2.description, ins2.description,  @"验证实例的获取error");
    XCTAssertEqualObjects(_ins3.description, ins3.description,  @"验证实例的获取error");
    XCTAssertEqualObjects(_ins4.description, ins4.description,  @"验证实例的获取error");
    
    // 登出事件
    [ins4 logout];
    XCTestExpectation* expect5 = [[XCTestExpectation alloc] initWithDescription:@"time out !!"];
    [TEST_Helper checkInstance:ins4
                         input:input4
                    hasInsName:YES
                        result:^(BOOL result) {
        XCTAssertTrue(result ,@"初始化error");
        [expect5 fulfill];
    }];

    [self waitForExpectations:@[expect1, expect2,expect3,expect4, expect5] timeout:10];
    
    
}

@end
