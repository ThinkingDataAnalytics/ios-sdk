//
//  TEST_13000.m
//  ThinkingSDKDEMOUITests
//
//  Created by wwango on 2021/12/14.
//  Copyright © 2021 thinking. All rights reserved.
//

#import "TEST_13000.h"



#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"

@implementation TEST_13000

- (void)setUp {
    self.models = [NSMutableArray arrayWithArray:[TEST_Model getTestDatas:@"TEST_11000"]];
}

- (void)tearDown {
//    NSMutableDictionary *dic = [ThinkingAnalyticsSDK performSelector:@selector(_getAllInstances)];
//    [dic removeAllObjects];
//    dic = nil;
//    [TEST_Helper deleteNSLibraryDirectory];
}

@end

@implementation TEST_13000_0

- (void)test_13000_0 {
    
    // start事件
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
    [ins1 aspect_hookSelector:@selector(saveEventsData:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> info, NSDictionary *dataDic){
        
        if ([@"ta_app_start" isEqualToString:dataDic[@"#event_name"]]) {
            // 检查预置属性
            BOOL result1 = [TEST_Helper checkProperties:dataDic];
            XCTAssertTrue(result1);
            // 检查外部属性
            BOOL result2 = [TEST_Helper checkCustomProperties:dataDic
                                               customProperty:nil
                                               staticProperty:input1.superProperties
                                                 dyldProperty:input1.superdyldProperties];
            XCTAssertTrue(result2);
            // 检查外层属性
            BOOL result3 = [input1.accountid isEqualToString:(NSString *)dataDic[@"#account_id"]];
            XCTAssertTrue(result3);
            BOOL result4 = [input1.distinctid isEqualToString:(NSString *)dataDic[@"#distinct_id"]];
            XCTAssertTrue(result4);
            BOOL result5 = [@"ta_app_start" isEqualToString:(NSString *)dataDic[@"#event_name"]];
            XCTAssertTrue(result5);
            BOOL result6 = ((NSString *)dataDic[@"#time"]).length > 0;
            XCTAssertTrue(result6);
            BOOL result7 = ((NSString *)dataDic[@"#uuid"]).length > 0;
            XCTAssertTrue(result7);
            BOOL result8 = [input1.type isEqualToString:(NSString *)dataDic[@"#type"]];
            XCTAssertTrue(result8);
            BOOL result9 = [@"AppStart" isEqualToString:dataDic[@"properties"][@"autoTrackCallback"]];
            XCTAssertTrue(result9);
            NSLog(@"1######");
            XCTAssertTrue(result1 && result2 && result3 && result4 && result5 && result6 && result7 && result8, @"track ERROR");
            [expect1 fulfill];
        }
    } error:nil];
    
    [ins1 enableAutoTrack:ThinkingAnalyticsEventTypeAll callback:^NSDictionary * _Nonnull(ThinkingAnalyticsAutoTrackEventType eventType, NSDictionary * _Nonnull properties) {
        if (eventType == ThinkingAnalyticsEventTypeAppStart) {
            return @{@"autoTrackCallback":@"AppStart"};
        }
        if (eventType == ThinkingAnalyticsEventTypeAppEnd) {
            return @{@"autoTrackCallback":@"AppEnd"};
        }
        if (eventType == ThinkingAnalyticsEventTypeAppClick) {
            return @{@"autoTrackCallback":@"AppClick"};
        }
        if (eventType == ThinkingAnalyticsEventTypeAppViewScreen) {
            return @{@"autoTrackCallback":@"AppViewScreen"};
        }
        if (eventType == ThinkingAnalyticsEventTypeAppInstall) {
            return @{@"autoTrackCallback":@"AppInstall"};
        }
        if (eventType == ThinkingAnalyticsEventTypeAppViewCrash) {
            return @{@"autoTrackCallback":@"AppInstall"};
        }
        return nil;
    }];
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:UIApplicationDidBecomeActiveNotification object:nil];
    [self waitForExpectations:@[expect1] timeout:2];
}

@end

@implementation TEST_13000_1

- (void)test_13000_1 {
    
    // end事件
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
    [ins1 aspect_hookSelector:@selector(saveEventsData:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> info, NSDictionary *dataDic){
        
        if ([@"ta_app_end" isEqualToString:dataDic[@"#event_name"]]) {
            // 检查预置属性
            BOOL result1 = [TEST_Helper checkProperties:dataDic];
            XCTAssertTrue(result1);
            // 检查外部属性
            BOOL result2 = [TEST_Helper checkCustomProperties:dataDic
                                               customProperty:nil
                                               staticProperty:input1.superProperties
                                                 dyldProperty:input1.superdyldProperties];
            XCTAssertTrue(result2);
            // 检查外层属性
            BOOL result3 = [input1.accountid isEqualToString:(NSString *)dataDic[@"#account_id"]];
            XCTAssertTrue(result3);
            BOOL result4 = [input1.distinctid isEqualToString:(NSString *)dataDic[@"#distinct_id"]];
            XCTAssertTrue(result4);
            BOOL result5 = [@"ta_app_end" isEqualToString:(NSString *)dataDic[@"#event_name"]];
            XCTAssertTrue(result5);
            BOOL result6 = ((NSString *)dataDic[@"#time"]).length > 0;
            XCTAssertTrue(result6);
            BOOL result7 = ((NSString *)dataDic[@"#uuid"]).length > 0;
            XCTAssertTrue(result7);
            BOOL result8 = [input1.type isEqualToString:(NSString *)dataDic[@"#type"]];
            XCTAssertTrue(result8);
            BOOL result9 = [@"AppEnd" isEqualToString:dataDic[@"properties"][@"autoTrackCallback"]];
            XCTAssertTrue(result9);
            NSLog(@"1######");
            XCTAssertTrue(result1 && result2 && result3 && result4 && result5 && result6 && result7 && result8, @"track ERROR");
            [expect1 fulfill];
        }
    } error:nil];
    
    [ins1 enableAutoTrack:ThinkingAnalyticsEventTypeAll callback:^NSDictionary * _Nonnull(ThinkingAnalyticsAutoTrackEventType eventType, NSDictionary * _Nonnull properties) {
        if (eventType == ThinkingAnalyticsEventTypeAppStart) {
            return @{@"autoTrackCallback":@"AppStart"};
        }
        if (eventType == ThinkingAnalyticsEventTypeAppEnd) {
            return @{@"autoTrackCallback":@"AppEnd"};
        }
        if (eventType == ThinkingAnalyticsEventTypeAppClick) {
            return @{@"autoTrackCallback":@"AppClick"};
        }
        if (eventType == ThinkingAnalyticsEventTypeAppViewScreen) {
            return @{@"autoTrackCallback":@"AppViewScreen"};
        }
        if (eventType == ThinkingAnalyticsEventTypeAppInstall) {
            return @{@"autoTrackCallback":@"AppInstall"};
        }
        if (eventType == ThinkingAnalyticsEventTypeAppViewCrash) {
            return @{@"autoTrackCallback":@"AppInstall"};
        }
        return nil;
    }];
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:UIApplicationDidEnterBackgroundNotification object:nil];
    [self waitForExpectations:@[expect1] timeout:2];
}

@end

@implementation TEST_13000_2

- (void)setUp {
    [super setUp];
    NSMutableDictionary *dic = [ThinkingAnalyticsSDK performSelector:@selector(_getAllInstances)];
    [dic removeAllObjects];
    dic = nil;
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"thinking_isfirst"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [TEST_Helper deleteNSLibraryDirectory];
}

- (void)test_13000_2 {
    NSLog(@"home: %@", NSHomeDirectory());
    
    // install事件
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
    [ins1 aspect_hookSelector:@selector(saveEventsData:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> info, NSDictionary *dataDic){
        
        if ([@"ta_app_install" isEqualToString:dataDic[@"#event_name"]]) {
            // 检查预置属性
            BOOL result1 = [TEST_Helper checkProperties:dataDic];
            XCTAssertTrue(result1);
            // 检查外部属性
            BOOL result2 = [TEST_Helper checkCustomProperties:dataDic
                                               customProperty:nil
                                               staticProperty:input1.superProperties
                                                 dyldProperty:input1.superdyldProperties];
            XCTAssertTrue(result2);
            // 检查外层属性
            BOOL result3 = [input1.accountid isEqualToString:(NSString *)dataDic[@"#account_id"]];
            XCTAssertTrue(result3);
            BOOL result4 = [input1.distinctid isEqualToString:(NSString *)dataDic[@"#distinct_id"]];
            XCTAssertTrue(result4);
            BOOL result5 = [@"ta_app_install" isEqualToString:(NSString *)dataDic[@"#event_name"]];
            XCTAssertTrue(result5);
            BOOL result6 = ((NSString *)dataDic[@"#time"]).length > 0;
            XCTAssertTrue(result6);
            BOOL result7 = ((NSString *)dataDic[@"#uuid"]).length > 0;
            XCTAssertTrue(result7);
            BOOL result8 = [input1.type isEqualToString:(NSString *)dataDic[@"#type"]];
            XCTAssertTrue(result8);
            BOOL result9 = [@"AppInstall" isEqualToString:dataDic[@"properties"][@"autoTrackCallback"]];
            XCTAssertTrue(result9);
            NSLog(@"1######");
            XCTAssertTrue(result1 && result2 && result3 && result4 && result5 && result6 && result7 && result8, @"track ERROR");
            [expect1 fulfill];
        }
    } error:nil];
    
    [ins1 enableAutoTrack:ThinkingAnalyticsEventTypeAll callback:^NSDictionary * _Nonnull(ThinkingAnalyticsAutoTrackEventType eventType, NSDictionary * _Nonnull properties) {
        if (eventType == ThinkingAnalyticsEventTypeAppStart) {
            return @{@"autoTrackCallback":@"AppStart"};
        }
        if (eventType == ThinkingAnalyticsEventTypeAppEnd) {
            return @{@"autoTrackCallback":@"AppEnd"};
        }
        if (eventType == ThinkingAnalyticsEventTypeAppClick) {
            return @{@"autoTrackCallback":@"AppClick"};
        }
        if (eventType == ThinkingAnalyticsEventTypeAppViewScreen) {
            return @{@"autoTrackCallback":@"AppViewScreen"};
        }
        if (eventType == ThinkingAnalyticsEventTypeAppInstall) {
            return @{@"autoTrackCallback":@"AppInstall"};
        }
        if (eventType == ThinkingAnalyticsEventTypeAppViewCrash) {
            return @{@"autoTrackCallback":@"AppInstall"};
        }
        return nil;
    }];
    
    
    [ins1 flush];
    [self waitForExpectations:@[expect1] timeout:2];
}

@end

@implementation TEST_13000_3

- (void)test_13000_3 {
    
    // install事件
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

    __block BOOL iscalled;
    XCTestExpectation* expect1 = [[XCTestExpectation alloc] initWithDescription:@"time out !!"];
    [ins1 aspect_hookSelector:@selector(saveEventsData:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> info, NSDictionary *dataDic){
        
        if ([@"ta_app_install" isEqualToString:dataDic[@"#event_name"]]) {
            iscalled = YES;
        }
    } error:nil];
    
    [ins1 enableAutoTrack:ThinkingAnalyticsEventTypeAll callback:^NSDictionary * _Nonnull(ThinkingAnalyticsAutoTrackEventType eventType, NSDictionary * _Nonnull properties) {
        if (eventType == ThinkingAnalyticsEventTypeAppStart) {
            return @{@"autoTrackCallback":@"AppStart"};
        }
        if (eventType == ThinkingAnalyticsEventTypeAppEnd) {
            return @{@"autoTrackCallback":@"AppEnd"};
        }
        if (eventType == ThinkingAnalyticsEventTypeAppClick) {
            return @{@"autoTrackCallback":@"AppClick"};
        }
        if (eventType == ThinkingAnalyticsEventTypeAppViewScreen) {
            return @{@"autoTrackCallback":@"AppViewScreen"};
        }
        if (eventType == ThinkingAnalyticsEventTypeAppInstall) {
            return @{@"autoTrackCallback":@"AppInstall"};
        }
        if (eventType == ThinkingAnalyticsEventTypeAppViewCrash) {
            return @{@"autoTrackCallback":@"AppInstall"};
        }
        return nil;
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        XCTAssertFalse(iscalled);
        [expect1 fulfill];
    });
    [self waitForExpectations:@[expect1] timeout:10];
}

@end

#pragma clang diagnostic pop
