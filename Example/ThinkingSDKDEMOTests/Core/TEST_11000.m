//
//  TEST_11000.m
//  ThinkingSDKDEMOUITests
//
//  Created by wwango on 2021/12/12.
//  Copyright © 2021 thinking. All rights reserved.
//

#import "TEST_11000.h"


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"

@implementation TEST_11000

- (void)setUp {
//    NSArray *disPresetProperty = @[@"#fps", @"#ram", @"#disk", @"#start_reason", @"#simulator"];
//    id mockPresetProperties = OCMClassMock([TDPresetProperties class]);
//    OCMStub([mockPresetProperties performSelector:@selector(disPresetProperties)]).andReturn(disPresetProperty);
//    _mockPresetProperties = mockPresetProperties;
    self.models = [NSMutableArray arrayWithArray:[TEST_Model getTestDatas:@"TEST_11000"]];
}

- (void)tearDown {
    NSMutableDictionary *dic = [ThinkingAnalyticsSDK performSelector:@selector(_getAllInstances)];
    [dic removeAllObjects];
    dic = nil;
    [TEST_Helper deleteNSLibraryDirectory];
}

- ( unsigned long long )changeTimestampWithFormat:(NSDateFormatter *)format time:(NSString *)time{
    
    NSDate *tempDate = [format dateFromString:time];//将字符串转换为时间对象
    return [tempDate timeIntervalSince1970]*1000;
}


@end


@implementation TEST_11000_0

- (void)test_11000_0 {
    
    TEST_Model *model1 = self.models[0];
    TEST_Input_Model *input1 = model1.input;
    TDConfig *config1 = [[TDConfig alloc] initWithAppId:input1.appid serverUrl:input1.serverURL];
    ThinkingAnalyticsSDK *ins1 = [ThinkingAnalyticsSDK startWithConfig:config1];
    [ins1 setSuperProperties:input1.superProperties];
    [ins1 registerDynamicSuperProperties:^NSDictionary<NSString *,id> * _Nonnull{
        return input1.superdyldProperties;
    }];
    [ins1 identify:input1.distinctid];
    [ins1 login:input1.accountid];
    
    XCTestExpectation* expect1 = [[XCTestExpectation alloc] initWithDescription:@"time out !!"];
    [ins1 aspect_hookSelector:@selector(saveEventsData:) withOptions:AspectOptionAutomaticRemoval usingBlock:^(id<AspectInfo> info, NSDictionary *dataDic){
        // 检查预置属性
        BOOL result1 = [TEST_Helper checkProperties:dataDic];
        XCTAssertTrue(result1);
        // 检查外部属性
        BOOL result2 = [TEST_Helper checkCustomProperties:dataDic
                                           customProperty:input1.proprties
                                           staticProperty:input1.superProperties
                                             dyldProperty:input1.superdyldProperties];
        XCTAssertTrue(result2);
        // 检查外层属性
        BOOL result3 = [input1.accountid isEqualToString:(NSString *)dataDic[@"#account_id"]];
        XCTAssertTrue(result3);
        BOOL result4 = [input1.distinctid isEqualToString:(NSString *)dataDic[@"#distinct_id"]];
        XCTAssertTrue(result4);
        BOOL result5 = [input1.eventName isEqualToString:(NSString *)dataDic[@"#event_name"]];
        XCTAssertTrue(result5);
        BOOL result6 = ((NSString *)dataDic[@"#time"]).length > 0;
        XCTAssertTrue(result6);
        BOOL result7 = ((NSString *)dataDic[@"#uuid"]).length > 0;
        XCTAssertTrue(result7);
        BOOL result8 = [input1.type isEqualToString:(NSString *)dataDic[@"#type"]];
        XCTAssertTrue(result8);
        NSLog(@"1######");
        XCTAssertTrue(result1 && result2 && result3 && result4 && result5 && result6 && result7 && result8, @"track ERROR");
        [expect1 fulfill];
    } error:nil];
    
    [ins1 track:input1.eventName properties:input1.proprties];
    [self waitForExpectations:@[expect1] timeout:2];
}

@end

@implementation TEST_11000_1

// 首次事件
- (void)test_11000_1 {
    
    TEST_Model *model1 = self.models[2];
    TEST_Input_Model *input1 = model1.input;
    TDConfig *config1 = [[TDConfig alloc] initWithAppId:input1.appid serverUrl:input1.serverURL];
    ThinkingAnalyticsSDK *ins1 = [ThinkingAnalyticsSDK startWithConfig:config1];
    [ins1 setSuperProperties:input1.superProperties];
    [ins1 registerDynamicSuperProperties:^NSDictionary<NSString *,id> * _Nonnull{
        return input1.superdyldProperties;
    }];
    [ins1 identify:input1.distinctid];
    [ins1 login:input1.accountid];
    
    XCTestExpectation* expect1 = [[XCTestExpectation alloc] initWithDescription:@"time out !!"];
    [ins1 aspect_hookSelector:@selector(saveEventsData:) withOptions:AspectOptionAutomaticRemoval usingBlock:^(id<AspectInfo> info, NSDictionary *dataDic){
        // 检查预置属性
        BOOL result1 = [TEST_Helper checkProperties:dataDic];
        
        // 检查外部属性
        BOOL result2 = [TEST_Helper checkCustomProperties:dataDic
                                           customProperty:input1.proprties
                                           staticProperty:input1.superProperties
                                             dyldProperty:input1.superdyldProperties];
        
        // 检查外层属性
        BOOL result3 = [input1.accountid isEqualToString:(NSString *)dataDic[@"#account_id"]];
        BOOL result4 = [input1.distinctid isEqualToString:(NSString *)dataDic[@"#distinct_id"]];
        BOOL result5 = [input1.eventName isEqualToString:(NSString *)dataDic[@"#event_name"]];
        BOOL result6 = ((NSString *)dataDic[@"#time"]).length > 0;
        BOOL result7 = ((NSString *)dataDic[@"#uuid"]).length > 0;
        BOOL result8 = [input1.type isEqualToString:(NSString *)dataDic[@"#type"]];
        BOOL result9 = [input1.firstCheckID isEqualToString:(NSString *)dataDic[@"#first_check_id"]];
        NSLog(@"2######");
        XCTAssertTrue(result1);
        XCTAssertTrue(result2);
        XCTAssertTrue(result3);
        XCTAssertTrue(result4);
        XCTAssertTrue(result5);
        XCTAssertTrue(result6);
        XCTAssertTrue(result7);
        XCTAssertTrue(result8);
        XCTAssertTrue(result9);
        
        XCTAssertTrue(result1 && result2 && result3 && result4 && result5 && result6 && result7 && result8 && result9, @"track ERROR");
        [expect1 fulfill];
    } error:nil];
    
    TDFirstEventModel *firstModel = [[TDFirstEventModel alloc] initWithEventName:input1.eventName firstCheckID:input1.firstCheckID];
    firstModel.properties = input1.proprties;
    [ins1 trackWithEventModel:firstModel];
    [self waitForExpectations:@[expect1] timeout:2];
}
@end


@implementation TEST_11000_2

// 更新事件
- (void)test_11000_2 {

    TEST_Model *model1 = self.models[3];
    TEST_Input_Model *input1 = model1.input;
    TDConfig *config1 = [[TDConfig alloc] initWithAppId:input1.appid serverUrl:input1.serverURL];
    ThinkingAnalyticsSDK *ins1 = [ThinkingAnalyticsSDK startWithConfig:config1];
    [ins1 setSuperProperties:input1.superProperties];
    [ins1 registerDynamicSuperProperties:^NSDictionary<NSString *,id> * _Nonnull{
        return input1.superdyldProperties;
    }];
    [ins1 identify:input1.distinctid];
    [ins1 login:input1.accountid];

    XCTestExpectation* expect1 = [[XCTestExpectation alloc] initWithDescription:@"time out !!"];
    [ins1 aspect_hookSelector:@selector(saveEventsData:) withOptions:AspectOptionAutomaticRemoval usingBlock:^(id<AspectInfo> info, NSDictionary *dataDic){
        // 检查预置属性
        BOOL result1 = [TEST_Helper checkProperties:dataDic];
        // 检查外部属性
        BOOL result2 = [TEST_Helper checkCustomProperties:dataDic
                                           customProperty:input1.proprties
                                           staticProperty:input1.superProperties
                                             dyldProperty:input1.superdyldProperties];
        // 检查外层属性
        BOOL result3 = [input1.accountid isEqualToString:(NSString *)dataDic[@"#account_id"]];
        BOOL result4 = [input1.distinctid isEqualToString:(NSString *)dataDic[@"#distinct_id"]];
        BOOL result5 = [input1.eventName isEqualToString:(NSString *)dataDic[@"#event_name"]];
        BOOL result6 = ((NSString *)dataDic[@"#time"]).length > 0;
        BOOL result7 = ((NSString *)dataDic[@"#uuid"]).length > 0;
        BOOL result8 = [input1.type isEqualToString:(NSString *)dataDic[@"#type"]];
        BOOL result9 = [input1.eventID isEqualToString:(NSString *)dataDic[@"#event_id"]];
        NSLog(@"3######");
        XCTAssertTrue(result1);
        XCTAssertTrue(result2);
        XCTAssertTrue(result3);
        XCTAssertTrue(result4);
        XCTAssertTrue(result5);
        XCTAssertTrue(result6);
        XCTAssertTrue(result7);
        XCTAssertTrue(result8);
        XCTAssertTrue(result9);
        
        XCTAssertTrue(result1 && result2 && result3 && result4 && result5 && result6 && result7 && result8 && result9, @"track ERROR");
        [expect1 fulfill];
    } error:nil];

    // 更新事件
    TDUpdateEventModel *updateModel = [[TDUpdateEventModel alloc] initWithEventName:input1.eventName eventID:input1.eventID];
    updateModel.properties = input1.proprties;
    [ins1 trackWithEventModel:updateModel];
    [self waitForExpectations:@[expect1] timeout:2];
}

@end


@implementation TEST_11000_3
// 重写事件
- (void)test_11000_3 {

    TEST_Model *model1 = self.models[4];
    TEST_Input_Model *input1 = model1.input;
    TDConfig *config1 = [[TDConfig alloc] initWithAppId:input1.appid serverUrl:input1.serverURL];
    ThinkingAnalyticsSDK *ins1 = [ThinkingAnalyticsSDK startWithConfig:config1];
    [ins1 setSuperProperties:input1.superProperties];
    [ins1 registerDynamicSuperProperties:^NSDictionary<NSString *,id> * _Nonnull{
        return input1.superdyldProperties;
    }];
    [ins1 identify:input1.distinctid];
    [ins1 login:input1.accountid];

    XCTestExpectation* expect1 = [[XCTestExpectation alloc] initWithDescription:@"time out !!"];
    [ins1 aspect_hookSelector:@selector(saveEventsData:) withOptions:AspectOptionAutomaticRemoval usingBlock:^(id<AspectInfo> info, NSDictionary *dataDic){
        // 检查预置属性
        BOOL result1 = [TEST_Helper checkProperties:dataDic];
        // 检查外部属性
        BOOL result2 = [TEST_Helper checkCustomProperties:dataDic
                                           customProperty:input1.proprties
                                           staticProperty:input1.superProperties
                                             dyldProperty:input1.superdyldProperties];
        // 检查外层属性
        BOOL result3 = [input1.accountid isEqualToString:(NSString *)dataDic[@"#account_id"]];
        BOOL result4 = [input1.distinctid isEqualToString:(NSString *)dataDic[@"#distinct_id"]];
        BOOL result5 = [input1.eventName isEqualToString:(NSString *)dataDic[@"#event_name"]];
        BOOL result6 = ((NSString *)dataDic[@"#time"]).length > 0;
        BOOL result7 = ((NSString *)dataDic[@"#uuid"]).length > 0;
        BOOL result8 = [input1.type isEqualToString:(NSString *)dataDic[@"#type"]];
        BOOL result9 = [input1.eventID isEqualToString:(NSString *)dataDic[@"#event_id"]];
        XCTAssertTrue(result1);
        XCTAssertTrue(result2);
        XCTAssertTrue(result3);
        XCTAssertTrue(result4);
        XCTAssertTrue(result5);
        XCTAssertTrue(result6);
        XCTAssertTrue(result7);
        XCTAssertTrue(result8);
        XCTAssertTrue(result9);
        
        XCTAssertTrue(result1 && result2 && result3 && result4 && result5 && result6 && result7 && result8 && result9, @"track ERROR");
        NSLog(@"4######");
        [expect1 fulfill];
    } error:nil];

    TDOverwriteEventModel *writeModel = [[TDOverwriteEventModel alloc] initWithEventName:input1.eventName eventID:input1.eventID];
    writeModel.properties = input1.proprties;
    [ins1 trackWithEventModel:writeModel];
    [self waitForExpectations:@[expect1] timeout:2];
}

@end

@implementation TEST_11000_4

// 登出
- (void)test_11000_4 {

    TEST_Model *model1 = self.models[0];
    TEST_Input_Model *input1 = model1.input;
    TDConfig *config1 = [[TDConfig alloc] initWithAppId:input1.appid serverUrl:input1.serverURL];
    ThinkingAnalyticsSDK *ins1 = [ThinkingAnalyticsSDK startWithConfig:config1];
    [ins1 setSuperProperties:input1.superProperties];
    [ins1 registerDynamicSuperProperties:^NSDictionary<NSString *,id> * _Nonnull{
        return input1.superdyldProperties;
    }];
    [ins1 identify:input1.distinctid];
    [ins1 login:input1.accountid];

    XCTestExpectation* expect1 = [[XCTestExpectation alloc] initWithDescription:@"time out !!"];
    [ins1 aspect_hookSelector:@selector(saveEventsData:) withOptions:AspectOptionAutomaticRemoval usingBlock:^(id<AspectInfo> info, NSDictionary *dataDic){
        // 检查预置属性
        BOOL result1 = [TEST_Helper checkProperties:dataDic];
        // 检查外部属性
        BOOL result2 = [TEST_Helper checkCustomProperties:dataDic
                                           customProperty:input1.proprties
                                           staticProperty:input1.superProperties
                                             dyldProperty:input1.superdyldProperties];
        // 检查外层属性
        BOOL result3 = ![dataDic.allKeys containsObject:@"#account_id"];
        BOOL result4 = [input1.distinctid isEqualToString:(NSString *)dataDic[@"#distinct_id"]];
        BOOL result5 = [input1.eventName isEqualToString:(NSString *)dataDic[@"#event_name"]];
        BOOL result6 = ((NSString *)dataDic[@"#time"]).length > 0;
        BOOL result7 = ((NSString *)dataDic[@"#uuid"]).length > 0;
        BOOL result8 = [input1.type isEqualToString:(NSString *)dataDic[@"#type"]];
        XCTAssertTrue(result1);
        XCTAssertTrue(result2);
        XCTAssertTrue(result3);
        XCTAssertTrue(result4);
        XCTAssertTrue(result5);
        XCTAssertTrue(result6);
        XCTAssertTrue(result7);
        XCTAssertTrue(result8);
        
        NSLog(@"5######");
        XCTAssertTrue(result1 && result2 && result3 && result4 && result5 && result6 && result7 && result8, @"track ERROR");
        [expect1 fulfill];
    } error:nil];

    [ins1 logout];
    [ins1 track:input1.eventName properties:input1.proprties];
    [self waitForExpectations:@[expect1] timeout:2];
}

@end

@implementation TEST_11000_5

// 清除一条静态公共属性
- (void)test_11000_5 {

    TEST_Model *model1 = self.models[0];
    TEST_Input_Model *input1 = model1.input;
    TDConfig *config1 = [[TDConfig alloc] initWithAppId:input1.appid serverUrl:input1.serverURL];
    ThinkingAnalyticsSDK *ins1 = [ThinkingAnalyticsSDK startWithConfig:config1];
    [ins1 setSuperProperties:input1.superProperties];
    [ins1 registerDynamicSuperProperties:^NSDictionary<NSString *,id> * _Nonnull{
        return input1.superdyldProperties;
    }];
    [ins1 identify:input1.distinctid];
    [ins1 login:input1.accountid];

    NSString *unsetSuperProperty = input1.superProperties.allKeys.firstObject;
    NSMutableDictionary *staticProperty = [NSMutableDictionary dictionaryWithDictionary:input1.superProperties];
    [staticProperty removeObjectForKey:unsetSuperProperty];

    XCTestExpectation* expect1 = [[XCTestExpectation alloc] initWithDescription:@"time out !!"];
    [ins1 aspect_hookSelector:@selector(saveEventsData:) withOptions:AspectOptionAutomaticRemoval usingBlock:^(id<AspectInfo> info, NSDictionary *dataDic){
        // 检查预置属性
        BOOL result1 = [TEST_Helper checkProperties:dataDic];
        // 检查外部属性
        BOOL result2 = [TEST_Helper checkCustomProperties:dataDic
                                           customProperty:input1.proprties
                                           staticProperty:staticProperty
                                             dyldProperty:input1.superdyldProperties];
        // 检查外层属性
        BOOL result3 =  [input1.accountid isEqualToString:(NSString *)dataDic[@"#account_id"]];
        BOOL result4 = [input1.distinctid isEqualToString:(NSString *)dataDic[@"#distinct_id"]];
        BOOL result5 = [input1.eventName isEqualToString:(NSString *)dataDic[@"#event_name"]];
        BOOL result6 = ((NSString *)dataDic[@"#time"]).length > 0;
        BOOL result7 = ((NSString *)dataDic[@"#uuid"]).length > 0;
        BOOL result8 = [input1.type isEqualToString:(NSString *)dataDic[@"#type"]];
        
        XCTAssertTrue(result1);
        XCTAssertTrue(result2);
        XCTAssertTrue(result3);
        XCTAssertTrue(result4);
        XCTAssertTrue(result5);
        XCTAssertTrue(result6);
        XCTAssertTrue(result7);
        XCTAssertTrue(result8);
        
        NSLog(@"6######");
        XCTAssertTrue(result1 && result2 && result3 && result4 && result5 && result6 && result7 && result8, @"track ERROR");
        [expect1 fulfill];
    } error:nil];

    [ins1 unsetSuperProperty:unsetSuperProperty];
    [ins1 track:input1.eventName properties:input1.proprties];
    [self waitForExpectations:@[expect1] timeout:2];
}

@end

@implementation TEST_11000_6

// 清除所有静态公共属性
- (void)test_11000_6 {

    TEST_Model *model1 = self.models[0];
    TEST_Input_Model *input1 = model1.input;
    TDConfig *config1 = [[TDConfig alloc] initWithAppId:input1.appid serverUrl:input1.serverURL];
    ThinkingAnalyticsSDK *ins1 = [ThinkingAnalyticsSDK startWithConfig:config1];
    [ins1 setSuperProperties:input1.superProperties];
    [ins1 registerDynamicSuperProperties:^NSDictionary<NSString *,id> * _Nonnull{
        return input1.superdyldProperties;
    }];
    [ins1 identify:input1.distinctid];
    [ins1 login:input1.accountid];

    XCTestExpectation* expect1 = [[XCTestExpectation alloc] initWithDescription:@"time out !!"];
    [ins1 aspect_hookSelector:@selector(saveEventsData:) withOptions:AspectOptionAutomaticRemoval usingBlock:^(id<AspectInfo> info, NSDictionary *dataDic){
        // 检查预置属性
        BOOL result1 = [TEST_Helper checkProperties:dataDic];
        // 检查外部属性
        BOOL result2 = [TEST_Helper checkCustomProperties:dataDic
                                           customProperty:input1.proprties
                                           staticProperty:nil
                                             dyldProperty:input1.superdyldProperties];
        // 检查外层属性
        BOOL result3 =  [input1.accountid isEqualToString:(NSString *)dataDic[@"#account_id"]];
        BOOL result4 = [input1.distinctid isEqualToString:(NSString *)dataDic[@"#distinct_id"]];
        BOOL result5 = [input1.eventName isEqualToString:(NSString *)dataDic[@"#event_name"]];
        BOOL result6 = ((NSString *)dataDic[@"#time"]).length > 0;
        BOOL result7 = ((NSString *)dataDic[@"#uuid"]).length > 0;
        BOOL result8 = [input1.type isEqualToString:(NSString *)dataDic[@"#type"]];
        
        XCTAssertTrue(result1);
        XCTAssertTrue(result2);
        XCTAssertTrue(result3);
        XCTAssertTrue(result4);
        XCTAssertTrue(result5);
        XCTAssertTrue(result6);
        XCTAssertTrue(result7);
        XCTAssertTrue(result8);
        
        NSLog(@"7######");
        XCTAssertTrue(result1 && result2 && result3 && result4 && result5 && result6 && result7 && result8, @"track ERROR");
        [expect1 fulfill];
    } error:nil];

    [ins1 clearSuperProperties];
    [ins1 track:input1.eventName properties:input1.proprties];
    [self waitForExpectations:@[expect1] timeout:2];
}

@end

@implementation TEST_11000_7

// 关闭track
- (void)test_11000_7 {

    TEST_Model *model1 = self.models[0];
    TEST_Input_Model *input1 = model1.input;
    TDConfig *config1 = [[TDConfig alloc] initWithAppId:input1.appid serverUrl:input1.serverURL];
    ThinkingAnalyticsSDK *ins1 = [ThinkingAnalyticsSDK startWithConfig:config1];
    [ins1 setSuperProperties:input1.superProperties];
    [ins1 registerDynamicSuperProperties:^NSDictionary<NSString *,id> * _Nonnull{
        return input1.superdyldProperties;
    }];
    [ins1 identify:input1.distinctid];
    [ins1 login:input1.accountid];

    __block BOOL isCalled;
    XCTestExpectation* expect1 = [[XCTestExpectation alloc] initWithDescription:@"time out !!"];
    [ins1 aspect_hookSelector:@selector(saveEventsData:) withOptions:AspectOptionAutomaticRemoval usingBlock:^(id<AspectInfo> info, NSDictionary *dataDic){
        isCalled = YES;
    } error:nil];

    [ins1 enableTracking:NO];
    [ins1 track:input1.eventName properties:input1.proprties];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 等五秒，看看方法有木有被调用
        XCTAssertFalse(isCalled, @"关闭track Error");
        NSLog(@"8######");
        [expect1 fulfill];
    });
    [self waitForExpectations:@[expect1] timeout:10];
}

@end

@implementation TEST_11000_8

// 启用track
- (void)test_11000_8 {

    TEST_Model *model1 = self.models[0];
    TEST_Input_Model *input1 = model1.input;
    TDConfig *config1 = [[TDConfig alloc] initWithAppId:input1.appid serverUrl:input1.serverURL];
    ThinkingAnalyticsSDK *ins1 = [ThinkingAnalyticsSDK startWithConfig:config1];
    [ins1 setSuperProperties:input1.superProperties];
    [ins1 registerDynamicSuperProperties:^NSDictionary<NSString *,id> * _Nonnull{
        return input1.superdyldProperties;
    }];
    [ins1 identify:input1.distinctid];
    [ins1 login:input1.accountid];

    __block BOOL isCalled;
    [ins1 aspect_hookSelector:@selector(saveEventsData:) withOptions:AspectOptionAutomaticRemoval usingBlock:^(id<AspectInfo> info){
        isCalled = YES;
    } error:nil];
    XCTestExpectation* expect1 = [[XCTestExpectation alloc] initWithDescription:@"time out !!"];

    [ins1 enableTracking:YES];
    [ins1 track:input1.eventName properties:input1.proprties];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 等五秒，看看方法有木有被调用
        XCTAssertTrue(isCalled, @"启用track Error");
        NSLog(@"9######");
        [expect1 fulfill];
    });
    [self waitForExpectations:@[expect1] timeout:10];
}


@end

@implementation TEST_11000_9

// 禁用
- (void)test_11000_9 {

    TEST_Model *model1 = self.models[0];
    TEST_Input_Model *input1 = model1.input;
    TDConfig *config1 = [[TDConfig alloc] initWithAppId:input1.appid serverUrl:input1.serverURL];
    ThinkingAnalyticsSDK *ins1 = [ThinkingAnalyticsSDK startWithConfig:config1];
    [ins1 setSuperProperties:input1.superProperties];
    [ins1 registerDynamicSuperProperties:^NSDictionary<NSString *,id> * _Nonnull{
        return input1.superdyldProperties;
    }];
    [ins1 identify:input1.distinctid];
    [ins1 login:input1.accountid];

    __block BOOL isCalled;
    [ins1 aspect_hookSelector:@selector(saveEventsData:) withOptions:AspectOptionAutomaticRemoval usingBlock:^(id<AspectInfo> info){
        isCalled = YES;
    } error:nil];
    XCTestExpectation* expect1 = [[XCTestExpectation alloc] initWithDescription:@"time out !!"];

    [ins1 optOutTracking];
    [ins1 track:input1.eventName properties:input1.proprties];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 等五秒，看看方法有木有被调用
        XCTAssertFalse(isCalled, @"禁用track Error");
        NSLog(@"10######");
        [expect1 fulfill];
    });
    [self waitForExpectations:@[expect1] timeout:10];
}


@end

@implementation TEST_11000_10

// 重新开启
- (void)test_11000_10 {

    TEST_Model *model1 = self.models[0];
    TEST_Input_Model *input1 = model1.input;
    TDConfig *config1 = [[TDConfig alloc] initWithAppId:input1.appid serverUrl:input1.serverURL];
    ThinkingAnalyticsSDK *ins1 = [ThinkingAnalyticsSDK startWithConfig:config1];
    [ins1 setSuperProperties:input1.superProperties];
    [ins1 registerDynamicSuperProperties:^NSDictionary<NSString *,id> * _Nonnull{
        return input1.superdyldProperties;
    }];
    [ins1 identify:input1.distinctid];
    [ins1 login:input1.accountid];

    __block BOOL isCalled;
    [ins1 aspect_hookSelector:@selector(saveEventsData:) withOptions:AspectOptionAutomaticRemoval usingBlock:^(id<AspectInfo> info){
        isCalled = YES;
    } error:nil];
    XCTestExpectation* expect1 = [[XCTestExpectation alloc] initWithDescription:@"time out !!"];

    [ins1 optInTracking];
    [ins1 track:input1.eventName properties:input1.proprties];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 等五秒，看看方法有木有被调用
        XCTAssertTrue(isCalled, @"重新开启track Error");
        NSLog(@"11######");
        [expect1 fulfill];
    });
    [self waitForExpectations:@[expect1] timeout:10];
}


@end

@implementation TEST_11000_11

- (void)setUp {
    [super setUp];
//    _mock = OCMClassMock([ThinkingAnalyticsSDK class]);
//    OCMStub([_mock calibrateTime:1585633785954]).andReturn(OCMOCK_VALUE(1585633785954));
}

- (void)tearDown {
    [super tearDown];
//    NSMutableDictionary *dic = [ThinkingAnalyticsSDK performSelector:@selector(_getAllInstances)];
//    [dic removeAllObjects];
//    dic = nil;
//    [TEST_Helper deleteNSLibraryDirectory];
//    [_mock stopMocking];

    [ThinkingAnalyticsSDK performSelector:@selector(_clearCalibratedTime)];

}

// 时间校准，时间戳
- (void)test_11000_11 {

    NSTimeInterval timestamp = 1585633785954;
    [ThinkingAnalyticsSDK calibrateTime:timestamp];

    TEST_Model *model1 = self.models[4];
    TEST_Input_Model *input1 = model1.input;
    TDConfig *config1 = [[TDConfig alloc] initWithAppId:input1.appid serverUrl:input1.serverURL];
    ThinkingAnalyticsSDK *ins1 = [ThinkingAnalyticsSDK startWithConfig:config1];
    [ins1 setSuperProperties:input1.superProperties];
    [ins1 registerDynamicSuperProperties:^NSDictionary<NSString *,id> * _Nonnull{
        return input1.superdyldProperties;
    }];
    [ins1 identify:input1.distinctid];
    [ins1 login:input1.accountid];

    XCTestExpectation* expect1 = [[XCTestExpectation alloc] initWithDescription:@"time out !!"];
    [ins1 aspect_hookSelector:@selector(saveEventsData:) withOptions:AspectOptionAutomaticRemoval usingBlock:^(id<AspectInfo> info, NSDictionary *dataDic){
        // 检查预置属性
        BOOL result1 = [TEST_Helper checkProperties:dataDic];

        // 检查外部属性
        BOOL result2 = [TEST_Helper checkCustomProperties:dataDic
                                           customProperty:input1.proprties
                                           staticProperty:input1.superProperties
                                             dyldProperty:input1.superdyldProperties];
        // 检查外层属性
        
        unsigned long long  times = [self changeTimestampWithFormat:[ins1 valueForKey:@"_timeFormatter"] time:dataDic[@"#time"]];
        unsigned long long  offset = (times - timestamp);
        
        
        BOOL result3 = [input1.accountid isEqualToString:(NSString *)dataDic[@"#account_id"]];
        BOOL result4 = [input1.distinctid isEqualToString:(NSString *)dataDic[@"#distinct_id"]];
        BOOL result5 = [input1.eventName isEqualToString:(NSString *)dataDic[@"#event_name"]];
        BOOL result6 = offset<=100;// 差的不是很离谱就行
        BOOL result7 = ((NSString *)dataDic[@"#uuid"]).length > 0;
        BOOL result8 = [input1.type isEqualToString:(NSString *)dataDic[@"#type"]];
        XCTAssertTrue(result1);
        XCTAssertTrue(result2);
        XCTAssertTrue(result3);
        XCTAssertTrue(result4);
        XCTAssertTrue(result5);
        XCTAssertTrue(result6);
        XCTAssertTrue(result7);
        XCTAssertTrue(result8);
        
        NSLog(@"12######");
        XCTAssertTrue(result1 && result2 && result3 && result4 && result5 && result6 && result7 && result8 , @"track ERROR");
        [expect1 fulfill];
    } error:nil];

    TDOverwriteEventModel *overwrite = [[TDOverwriteEventModel alloc] initWithEventName:input1.eventName eventID:input1.eventID];
    overwrite.properties = input1.proprties;
    [ins1 trackWithEventModel:overwrite];
    [self waitForExpectations:@[expect1] timeout:15];
}



@end

@implementation TEST_11000_12

// track+时间校准
- (void)test_11000_12 {

    TEST_Model *model1 = self.models[0];
    TEST_Input_Model *input1 = model1.input;
    TDConfig *config1 = [[TDConfig alloc] initWithAppId:input1.appid serverUrl:input1.serverURL];
    ThinkingAnalyticsSDK *ins1 = [ThinkingAnalyticsSDK startWithConfig:config1];
    [ins1 setSuperProperties:input1.superProperties];
    [ins1 registerDynamicSuperProperties:^NSDictionary<NSString *,id> * _Nonnull{
        return input1.superdyldProperties;
    }];
    [ins1 identify:input1.distinctid];
    [ins1 login:input1.accountid];

    XCTestExpectation* expect1 = [[XCTestExpectation alloc] initWithDescription:@"time out !!"];
    [ins1 aspect_hookSelector:@selector(saveEventsData:) withOptions:AspectOptionAutomaticRemoval usingBlock:^(id<AspectInfo> info, NSDictionary *dataDic){
        // 检查预置属性
        BOOL result1 = [TEST_Helper checkProperties:dataDic];
        // 检查外部属性
        BOOL result2 = [TEST_Helper checkCustomProperties:dataDic
                                           customProperty:input1.proprties
                                           staticProperty:input1.superProperties
                                             dyldProperty:input1.superdyldProperties];
        // 检查外层属性
        BOOL result3 = [input1.accountid isEqualToString:(NSString *)dataDic[@"#account_id"]];
        BOOL result4 = [input1.distinctid isEqualToString:(NSString *)dataDic[@"#distinct_id"]];
        BOOL result5 = [input1.eventName isEqualToString:(NSString *)dataDic[@"#event_name"]];
        BOOL result6 = ((NSString *)dataDic[@"#time"]).length > 0;
        BOOL result7 = ((NSString *)dataDic[@"#uuid"]).length > 0;
        BOOL result8 = [input1.type isEqualToString:(NSString *)dataDic[@"#type"]];
        BOOL result9 = [input1.timestring isEqualToString:(NSString *)dataDic[@"#time"]];
        BOOL result10 = input1.zone_offset == ((NSString *)dataDic[@"properties"][@"#zone_offset"]).intValue;
        
        XCTAssertTrue(result1);
        XCTAssertTrue(result2);
        XCTAssertTrue(result3);
        XCTAssertTrue(result4);
        XCTAssertTrue(result5);
        XCTAssertTrue(result6);
        XCTAssertTrue(result7);
        XCTAssertTrue(result8);
        XCTAssertTrue(result9);
        XCTAssertTrue(result10);
        
        
        NSLog(@"13######");
        XCTAssertTrue(result1 && result2 && result3 && result4 && result5 && result6 && result7 && result8 && result9 && result10, @"track ERROR");
        [expect1 fulfill];
    } error:nil];

    [ins1 track:input1.eventName
     properties:input1.proprties
           time:[NSDate dateWithTimeIntervalSince1970:input1.time]
       timeZone:[[NSTimeZone alloc] initWithName:input1.timeZone]];
    [self waitForExpectations:@[expect1] timeout:2];
}

@end

@implementation TEST_11000_13

- (void)setUp {
    [super setUp];
    [ThinkingAnalyticsSDK performSelector:@selector(_clearCalibratedTime)];
}

// config设置默认时区
- (void)test_11000_13 {

    TEST_Model *model1 = self.models[0];
    TEST_Input_Model *input1 = model1.input;
    TDConfig *config1 = [[TDConfig alloc] initWithAppId:input1.appid serverUrl:input1.serverURL];
    config1.defaultTimeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    ThinkingAnalyticsSDK *ins1 = [ThinkingAnalyticsSDK startWithConfig:config1];
    [ins1 setSuperProperties:input1.superProperties];
    [ins1 registerDynamicSuperProperties:^NSDictionary<NSString *,id> * _Nonnull{
        return input1.superdyldProperties;
    }];
    [ins1 identify:input1.distinctid];
    [ins1 login:input1.accountid];
    
    // 设定的是0时区，当前时间减掉8小时，
    NSTimeInterval currenttime = [[NSDate date] timeIntervalSince1970] * 1000;
    
    XCTestExpectation* expect1 = [[XCTestExpectation alloc] initWithDescription:@"time out !!"];
    [ins1 aspect_hookSelector:@selector(saveEventsData:) withOptions:AspectOptionAutomaticRemoval usingBlock:^(id<AspectInfo> info, NSDictionary *dataDic){
        // 检查预置属性
        BOOL result1 = [TEST_Helper checkProperties:dataDic];
        XCTAssertTrue(result1);
        // 检查外部属性
        BOOL result2 = [TEST_Helper checkCustomProperties:dataDic
                                           customProperty:input1.proprties
                                           staticProperty:input1.superProperties
                                             dyldProperty:input1.superdyldProperties];
        XCTAssertTrue(result2);
        // 检查外层属性
        BOOL result3 = [input1.accountid isEqualToString:(NSString *)dataDic[@"#account_id"]];
        XCTAssertTrue(result3);
        BOOL result4 = [input1.distinctid isEqualToString:(NSString *)dataDic[@"#distinct_id"]];
        XCTAssertTrue(result4);
        BOOL result5 = [input1.eventName isEqualToString:(NSString *)dataDic[@"#event_name"]];
        XCTAssertTrue(result5);
        BOOL result6 = ((NSString *)dataDic[@"#time"]).length > 0;
        XCTAssertTrue(result6);
        BOOL result7 = ((NSString *)dataDic[@"#uuid"]).length > 0;
        XCTAssertTrue(result7);
        BOOL result8 = [input1.type isEqualToString:(NSString *)dataDic[@"#type"]];
        XCTAssertTrue(result8);
        NSTimeInterval ttime = [self changeTimestampWithFormat:[ins1 valueForKey:@"_timeFormatter"] time:dataDic[@"#time"]];
        BOOL result9 = fabs(currenttime - ttime) <=3;
        XCTAssertTrue(result9);
        BOOL result10 = 0 == ((NSString *)dataDic[@"properties"][@"#zone_offset"]).intValue;
        XCTAssertTrue(result10);
        NSLog(@"13######");
        XCTAssertTrue(result1 && result2 && result3 && result4 && result5 && result6 && result7 && result8 && result9 && result10, @"track ERROR");
        [expect1 fulfill];
    } error:nil];

    [ThinkingAnalyticsSDK performSelector:@selector(_clearCalibratedTime)];
    [ins1 track:input1.eventName properties:input1.proprties];
    [self waitForExpectations:@[expect1] timeout:2];
}

@end



@implementation TEST_11000_14

- (void)setUp {
    [super setUp];
//    [ThinkingAnalyticsSDK performSelector:@selector(_clearCalibratedTime)];
}


// config设置默认时区
- (void)test_11000_14 {

    
    
    TEST_Model *model1 = self.models[0];
    TEST_Input_Model *input1 = model1.input;
    TDConfig *config1 = [[TDConfig alloc] initWithAppId:input1.appid serverUrl:input1.serverURL];
    config1.defaultTimeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    ThinkingAnalyticsSDK *ins1 = [ThinkingAnalyticsSDK startWithConfig:config1];
    [ins1 setSuperProperties:input1.superProperties];
    [ins1 registerDynamicSuperProperties:^NSDictionary<NSString *,id> * _Nonnull{
        return input1.superdyldProperties;
    }];
    [ins1 identify:input1.distinctid];
    [ins1 login:input1.accountid];
    
    [ins1 getPresetProperties];
    
    
    // 设定的是0时区，当前时间减掉8小时，
    NSTimeInterval currenttime = [[NSDate date] timeIntervalSince1970] * 1000;
    
    XCTestExpectation* expect1 = [[XCTestExpectation alloc] initWithDescription:@"time out !!"];
    [ins1 aspect_hookSelector:@selector(saveEventsData:) withOptions:AspectOptionAutomaticRemoval usingBlock:^(id<AspectInfo> info, NSDictionary *dataDic){
        // 检查预置属性
        BOOL result1 = [TEST_Helper checkProperties:dataDic];
        XCTAssertTrue(result1);
        // 检查外部属性
        BOOL result2 = [TEST_Helper checkCustomProperties:dataDic
                                           customProperty:input1.proprties
                                           staticProperty:input1.superProperties
                                             dyldProperty:input1.superdyldProperties];
        XCTAssertTrue(result2);
        // 检查外层属性
        BOOL result3 = [input1.accountid isEqualToString:(NSString *)dataDic[@"#account_id"]];
        XCTAssertTrue(result3);
        BOOL result4 = [input1.distinctid isEqualToString:(NSString *)dataDic[@"#distinct_id"]];
        XCTAssertTrue(result4);
        BOOL result5 = [input1.eventName isEqualToString:(NSString *)dataDic[@"#event_name"]];
        XCTAssertTrue(result5);
        BOOL result6 = ((NSString *)dataDic[@"#time"]).length > 0;
        XCTAssertTrue(result6);
        BOOL result7 = ((NSString *)dataDic[@"#uuid"]).length > 0;
        XCTAssertTrue(result7);
        BOOL result8 = [input1.type isEqualToString:(NSString *)dataDic[@"#type"]];
        XCTAssertTrue(result8);
        NSTimeInterval ttime = [self changeTimestampWithFormat:[ins1 valueForKey:@"_timeFormatter"] time:dataDic[@"#time"]];
        BOOL result9 = fabs(currenttime - ttime) <=3;
        XCTAssertTrue(result9);
        BOOL result10 = 0 == ((NSString *)dataDic[@"properties"][@"#zone_offset"]).intValue;
        XCTAssertTrue(result10);
        NSLog(@"13######");
        XCTAssertTrue(result1 && result2 && result3 && result4 && result5 && result6 && result7 && result8 && result9 && result10, @"track ERROR");
        [expect1 fulfill];
    } error:nil];

    [ThinkingAnalyticsSDK performSelector:@selector(_clearCalibratedTime)];
    [ins1 track:input1.eventName properties:input1.proprties];
    [self waitForExpectations:@[expect1] timeout:2];
}

@end


#pragma clang diagnostic pop
