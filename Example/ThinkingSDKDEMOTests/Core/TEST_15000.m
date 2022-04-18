//
//  TEST_15000.m
//  ThinkingSDKDEMOUITests
//
//  Created by xiayuwei on 2022/2/25.
//  Copyright © 2022 thinking. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TEST_15000.h"
#import <OCMock/OCMock.h>
#import <ThinkingSDK/ThinkingAnalyticsSDK.h>
#import "TEST_Model.h"
#import "TEST_Helper.h"
#import "UrlRequest.h"
#import <ThinkingSDK/TDSqliteDataQueue.h>


@interface TEST_15000 ()

@property(nonatomic, strong) NSMutableArray<TEST_Model *> *models;

@end


@implementation TEST_15000

- (void)setUp {
    [TEST_Helper deleteNSLibraryDirectory];
    self.models = [NSMutableArray arrayWithArray:[TEST_Model getTestDatas:@"TEST_15000"]];
//    XCUIApplication *app = [[XCUIApplication alloc] init];
//    [app launch];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
- (void)tearDown {
    //    NSMutableDictionary *dic = [ThinkingAnalyticsSDK performSelector:@selector(_getAllInstances)];
    //    [dic removeAllObjects];
    //    dic = nil;
    //    [TEST_Helper deleteNSLibraryDirectory];
}
#pragma clang diagnostic pop

@end

@implementation TEST_15000_1

- (void)setUp {
    [TEST_Helper deleteNSLibraryDirectory];
    self.models = [NSMutableArray arrayWithArray:[TEST_Model getTestDatas:@"TEST_15000"]];
    //    XCUIApplication *app = [[XCUIApplication alloc] init];
    //    [app launch];
    
}

//实例一加密，track，查看上报，实例二不加密，track，查看上报
- (void)test_15000_1 {
    XCTestExpectation* expect = [self expectationWithDescription:@"Oh, timeout!"];
    
    UrlRequest *request = [UrlRequest new];
    [ThinkingAnalyticsSDK setLogLevel:TDLoggingLevelDebug];
    NSString *appid = @"872c6dd5bd5643bdb9442e0fe4eac802";
    NSString *url = @"http://39.101.207.185:44491";
    NSString *eventName = @"test_15000_1_secret";
    
    TDConfig *config = [TDConfig new];
    config.appid = appid;
    config.configureURL = url;
    config.enableEncrypt = YES;
    config.secretKey = [[TDSecretKey alloc] initWithVersion:1 publicKey:@"MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAti6FnWGv7Lggzg/R8hQa\n4GEtd2ucfntqo6Xkf1sPwCIfndr2u6KGPhWQ24bFUKgtNLDuKnUAg1C/OEEL8uON\nJBdbX9XpckO67tRPSPrY3ufNIxsCJ9td557XxUsnebkOZ+oC1Duk8/ENx1pRvU6S\n4c+UYd6PH8wxw1agD61oJ0ju3CW0aZNZ2xKcWBcIU9KgYTeUtawrmGU5flod88Cq\nZc8VKB1+nY0tav023jvxwkM3zgQ6vBWIU9/aViGECB98YEzJfZjcOTD6zvqsZc/W\nRnUNhBHFPGEwc8ueMvzZNI+FP0pUFLVRwVoYbj/tffKbxGExaRFIcgP73BIW6/6n\nQwIDAQAB"];
    ThinkingAnalyticsSDK *ins1 = [ThinkingAnalyticsSDK startWithConfig:config];
    [ins1 login:eventName];

    NSString *secretAttribute1 = [NSString stringWithFormat:@"%@%@", @"test_15000_1_secretAtrribute_01_", [request getTimeStamp]];
    NSString *secretAttribute2 = [NSString stringWithFormat:@"%@%@", @"test_15000_1_secretAtrribute_02_", [request getTimeStamp]];
    NSString *secretAttribute3 = [NSString stringWithFormat:@"%@%@", @"test_15000_1_secretAtrribute_03_", [request getTimeStamp]];
    [ins1 track:eventName properties:@{@"test_15000_1_01_secrect1":secretAttribute1,@"test_15000_1_02_secrect2":secretAttribute2, @"test_15000_1_03_secrect3":secretAttribute3}];
    [ins1 flush];
    
    
    [ThinkingAnalyticsSDK setLogLevel:TDLoggingLevelDebug];
    NSString *appid1 = @"e4761373b13441e9a339e9c3fcbfa2f4";
    NSString *url1 = @"http://39.101.207.185:44491";
    TDConfig *config1 = [TDConfig new];
    config1.appid = appid1;
    config1.configureURL = url1;
    config1.enableEncrypt = NO;
    ThinkingAnalyticsSDK *ins = [ThinkingAnalyticsSDK startWithConfig:config1];
    NSString *eventName1 = @"test_15000_1_normal";
    [ins login:eventName1];
    NSString *normalAttribute1 = [NSString stringWithFormat:@"%@%@", @"test_15000_1_normalAtrribute_01_", [request getTimeStamp]];
    NSString *normalAttribute2 = [NSString stringWithFormat:@"%@%@", @"test_15000_1_normalAtrribute_02_", [request getTimeStamp]];
    NSString *normalAttribute3 = [NSString stringWithFormat:@"%@%@", @"test_15000_1_normalAtrribute_03_", [request getTimeStamp]];
    [ins track:eventName1 properties:@{@"test_15000_1_01_normal1":normalAttribute1,@"test_15000_1_02_normal2":normalAttribute2, @"test_15000_1_03_normal3":normalAttribute3}];
    [ins flush];
    
    
    [TEST_Helper dispatchQueue:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            long count = 2;
            __unsafe_unretained NSArray *arr;
            NSMethodSignature*signature = [[[ins1 valueForKey:@"dataQueue"] class] instanceMethodSignatureForSelector:@selector(getFirstRecords:withAppid:)];
            NSInvocation*invocation = [NSInvocation invocationWithMethodSignature:signature];
            [invocation setTarget:[ins1 valueForKey:@"dataQueue"] ];

            invocation.selector = @selector(getFirstRecords:withAppid:);
            [invocation setArgument:&count atIndex:2];
            [invocation setArgument:&appid atIndex:3];
            [invocation invoke];
            [invocation getReturnValue:&arr];


            NSMutableArray *eventDic = [NSMutableArray array];
            [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [eventDic addObject:[obj valueForKey:@"_event"]];
            }];
//            NSLog(@"@@@@@@%@", eventDic);
//            NSLog(@"****%d****", [eventDic[0] isEqual: eventDic[1]]);
//            NSInteger equalRequest = [eventDic[0] isEqual: eventDic[1]];
//            if (equalRequest == 0) {
//                [expect fulfill];
//            }
            [expect fulfill];

        });
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
//        等待10秒，若该测试未结束（未收到 fulfill方法）则测试结果为失败
//        Do something when time out
    }];
    
    //验证加密数据是否成功上报到TA
    NSString *urlString = @"http://39.101.207.185:44492/querySql?token=BT004tK74eCQAUd1N33ZPlzLdeFsL1uJHFc517epTEipKu9jqAPjQP0ZsRna75qP&format=json&timeoutSecond=10&sql=select%20*%20from%20v_event_3%20where%20%22$part_event%22=";
    urlString = [urlString stringByAppendingFormat: @"%@%@%@%@%@%@%@",@"'",eventName,@"'",@"%20and%20%20%22$part_date%22=",@"'",[request getDate],@"'"];
    urlString = [urlString stringByAppendingFormat: @"%@", @"%20order%20by%20%22%23server_time%22%20desc"];

    Boolean endWhile = true;
    NSMutableDictionary *response;
    NSInteger whileCount = 0;
    while (endWhile) {
        whileCount += 1;
        response = [request postRequest:urlString];
        NSLog(@"%@", response[@"test_15000_1_01_secrect1"]);
        NSString *actualAttr = response[@"test_15000_1_01_secrect1"];
        if([actualAttr isEqualToString: secretAttribute1] | (whileCount >= 6)){
            endWhile = false;
//            NSLog(@"%@", response);
        }
        [NSThread sleepForTimeInterval:30];
    }
    XCTAssertEqualObjects(response[@"test_15000_1_01_secrect1"], secretAttribute1);
    XCTAssertEqualObjects(response[@"test_15000_1_02_secrect2"], secretAttribute2);
    XCTAssertEqualObjects(response[@"test_15000_1_03_secrect3"], secretAttribute3);
    
    //验证不开启加密的instance是否成功上报到TA
    urlString = @"http://39.101.207.185:44492/querySql?token=13ArcgInTAPSA8BlG5PAy7A85xQj9gVju8AGltHBIMA1L3EFC4lBQ4261UN92aIg&format=json&timeoutSecond=10&sql=select%20*%20from%20v_event_4%20where%20%22$part_event%22=";
    urlString = [urlString stringByAppendingFormat: @"%@%@%@%@%@%@%@",@"'",eventName1,@"'",@"%20and%20%20%22$part_date%22=",@"'",[request getDate],@"'"];
    urlString = [urlString stringByAppendingFormat: @"%@", @"%20order%20by%20%22%23server_time%22%20desc"];

    endWhile = true;
    whileCount = 0;
    NSMutableDictionary *response1;
    while (endWhile) {
        whileCount += 1;
        response1 = [request postRequest:urlString];
        NSString *actualAttr = response1[@"test_15000_1_01_normal1"];
        if([actualAttr isEqualToString: normalAttribute1] | (whileCount >= 6)){
            endWhile = false;
            NSLog(@"%@", response1);
        }
        [NSThread sleepForTimeInterval:30];
    }
    XCTAssertEqualObjects(response1[@"test_15000_1_01_normal1"], normalAttribute1);
    XCTAssertEqualObjects(response1[@"test_15000_1_02_normal2"], normalAttribute2);
    XCTAssertEqualObjects(response1[@"test_15000_1_03_normal3"], normalAttribute3);
    
}

@end

// 远程密钥没有值,落入错误数据（数据库密钥一列无法为空，私钥赋值为“”）第一期暂不校验该场景
@implementation TEST_15000_2


- (void)test_15000_2 {
    XCTestExpectation* expect = [self expectationWithDescription:@"Oh, timeout!"];

    UrlRequest *request = [UrlRequest new];
    [ThinkingAnalyticsSDK setLogLevel:TDLoggingLevelDebug];
    NSString *appid = @"872c6dd5bd5643bdb9442e0fe4eac802";
    NSString *url = @"http://39.101.207.185:44491";
    NSString *eventName =@"test_15000_2_secret";
    TDConfig *config = [TDConfig new];
    
    config.appid = appid;
    config.configureURL = url;
    config.enableEncrypt = YES;
    config.secretKey = [[TDSecretKey alloc] initWithVersion:3 publicKey:@"MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAp2ofw+q0+lYC9S2156hd\n7CcNSmGOx0lMv+XIhalT6mF4ISOtY/WwsN/MzWsJwxt2svA/K4dDG0MdXa3d9k1P\n1bKJiVkUjLTeiMnlIma3rkum0a0lW+VcWnKTmjsR+q24zAlI9yugSdw9ULXIhn0d\nOQhgqmMCN0AFVqxG9s/z4ifVMrYNRqlHC/D9/t61MKNWmhi6PPbO3C/5of3QoOnn\nC2P6UUsHDfxXUN/FYDQIEFM8UAx3PxLJFVtga28CINOriRFbv9irGwfRZ18H7LeM\n6VVhsIb2+kd1WX2/SlsT/GthPeAjwAylCHvq/k0To+4N92YD6v/LAJ03Of8cfHb1\nkwIDAQAB"];
    
    
    ThinkingAnalyticsSDK *ins1 = [ThinkingAnalyticsSDK startWithConfig:config];
    [ins1 login:@"qa_login_secretKey_02"];

    [ins1 track:eventName properties:@{@"xyw_properties_secretKey_01":@"xyw_atrributes_secretKey_01",@"xyw_properties_secretKey_02":@"xyw_atrributes_secretKey_02", @"xyw_properties_secretKey_03":@"xyw_atrributes_secretKey_03"}];
    [ins1 flush];
    
    
    [TEST_Helper dispatchQueue:^{

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [expect fulfill];
        });
    }];

    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
//        等待10秒，若该测试未结束（未收到 fulfill方法）则测试结果为失败
//        Do something when time out
    }];
}


@end


//更新密钥1
@implementation TEST_15000_3


- (void)test_15000_3 {
    XCTestExpectation* expect = [self expectationWithDescription:@"Oh, timeout!"];

    UrlRequest *request = [UrlRequest new];
    [ThinkingAnalyticsSDK setLogLevel:TDLoggingLevelDebug];
    NSString *appid = @"872c6dd5bd5643bdb9442e0fe4eac802";
    NSString *url = @"http://39.101.207.185:44491";
    NSString *eventName = @"test_15000_3";
    TDConfig *config = [TDConfig new];
    config.appid = appid;
    config.configureURL = url;
    config.enableEncrypt = YES;
    config.secretKey = [[TDSecretKey alloc] initWithVersion:2 publicKey:@"MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAp2ofw+q0+lYC9S2156hd\n7CcNSmGOx0lMv+XIhalT6mF4ISOtY/WwsN/MzWsJwxt2svA/K4dDG0MdXa3d9k1P\n1bKJiVkUjLTeiMnlIma3rkum0a0lW+VcWnKTmjsR+q24zAlI9yugSdw9ULXIhn0d\nOQhgqmMCN0AFVqxG9s/z4ifVMrYNRqlHC/D9/t61MKNWmhi6PPbO3C/5of3QoOnn\nC2P6UUsHDfxXUN/FYDQIEFM8UAx3PxLJFVtga28CINOriRFbv9irGwfRZ18H7LeM\n6VVhsIb2+kd1WX2/SlsT/GthPeAjwAylCHvq/k0To+4N92YD6v/LAJ03Of8cfHb1\nkwIDAQAB"];
    ThinkingAnalyticsSDK *ins1 = [ThinkingAnalyticsSDK startWithConfig:config];
    [ins1 login:@"qa_login_secretKey_test_15000_3"];

    NSString *secretAttribute1 = [NSString stringWithFormat:@"%@_%@", @"test_15000_3_secretAtrribute_01", [request getTimeStamp]];
    NSString *secretAttribute2 = [NSString stringWithFormat:@"%@_%@", @"test_15000_3_secretAtrribute_02", [request getTimeStamp]];
    NSString *secretAttribute3 = [NSString stringWithFormat:@"%@_%@", @"test_15000_3_secretAtrribute_03", [request getTimeStamp]];
    [ins1 track:eventName properties:@{@"test_15000_3_01_secrect1":secretAttribute1,@"test_15000_3_02_secrect2":secretAttribute2, @"test_15000_3_03_secrect3":secretAttribute3}];
    [ins1 flush];
    

    [TEST_Helper dispatchQueue:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [expect fulfill];
        });
    }];

    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
//        等待10秒，若该测试未结束（未收到 fulfill方法）则测试结果为失败
//        Do something when time out
    }];
    
    //验证加密数据是否成功上报到TA
    NSString *urlString = @"http://39.101.207.185:44492/querySql?token=BT004tK74eCQAUd1N33ZPlzLdeFsL1uJHFc517epTEipKu9jqAPjQP0ZsRna75qP&format=json&timeoutSecond=10&sql=select%20*%20from%20v_event_3%20where%20%22$part_event%22=";
    urlString = [urlString stringByAppendingFormat: @"%@%@%@%@%@%@%@",@"'",eventName,@"'",@"%20and%20%20%22$part_date%22=",@"'",[request getDate],@"'"];
    urlString = [urlString stringByAppendingFormat: @"%@", @"%20order%20by%20%22%23server_time%22%20desc"];

    Boolean endWhile = true;
    NSMutableDictionary *response;
    NSInteger whileCount = 0;
    while (endWhile) {
        whileCount += 1;
        response = [request postRequest:urlString];
        NSLog(@"%@", response[@"test_15000_3_01_secrect1"]);
        NSString *actualAttr = response[@"test_15000_3_01_secrect1"];
        if([actualAttr isEqualToString: secretAttribute1] | (whileCount >= 6)){
            endWhile = false;
//            NSLog(@"%@", response);
        }
        [NSThread sleepForTimeInterval:30];
    }
    XCTAssertEqualObjects(response[@"test_15000_3_01_secrect1"], secretAttribute1);
    XCTAssertEqualObjects(response[@"test_15000_3_02_secrect2"], secretAttribute2);
    XCTAssertEqualObjects(response[@"test_15000_3_03_secrect3"], secretAttribute3);
}

@end

//开启发送十条，关闭加密发送十条，再次开启发送十条
@implementation TEST_15000_4


- (void)test_15000_4 {
    XCTestExpectation* expect = [self expectationWithDescription:@"Oh, timeout!"];

    UrlRequest *request = [UrlRequest new];
    [ThinkingAnalyticsSDK setLogLevel:TDLoggingLevelDebug];
    NSString *appid = @"872c6dd5bd5643bdb9442e0fe4eac802";
    NSString *url = @"http://39.101.207.185:44491";
    NSString *secretAttribute1;
    NSString *secretAttribute2;
    NSString *secretAttribute3;
    NSMutableDictionary *eventDic = [NSMutableDictionary dictionary];
    TDConfig *config = [TDConfig new];
    config.appid = appid;
    config.configureURL = url;
    config.enableEncrypt = YES;
    config.secretKey = [[TDSecretKey alloc] initWithVersion:2 publicKey:@"MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAp2ofw+q0+lYC9S2156hd\n7CcNSmGOx0lMv+XIhalT6mF4ISOtY/WwsN/MzWsJwxt2svA/K4dDG0MdXa3d9k1P\n1bKJiVkUjLTeiMnlIma3rkum0a0lW+VcWnKTmjsR+q24zAlI9yugSdw9ULXIhn0d\nOQhgqmMCN0AFVqxG9s/z4ifVMrYNRqlHC/D9/t61MKNWmhi6PPbO3C/5of3QoOnn\nC2P6UUsHDfxXUN/FYDQIEFM8UAx3PxLJFVtga28CINOriRFbv9irGwfRZ18H7LeM\n6VVhsIb2+kd1WX2/SlsT/GthPeAjwAylCHvq/k0To+4N92YD6v/LAJ03Of8cfHb1\nkwIDAQAB"];
    ThinkingAnalyticsSDK *ins1 = [ThinkingAnalyticsSDK startWithConfig:config];
    [ins1 login:@"qa_login_secretKey_test_15000_4"];

    for (NSInteger i = 0; i < 10; i++) {
        NSString *eventName = [NSString stringWithFormat:@"%@_%@", @"test_15000_4", [NSString stringWithFormat: @"%ld", (long)i]];
        secretAttribute1 = [NSString stringWithFormat:@"%@_%@", @"test_15000_4_secretAtrribute_01", [request getTimeStamp]];
        secretAttribute2 = [NSString stringWithFormat:@"%@_%@", @"test_15000_4_secretAtrribute_02", [request getTimeStamp]];
        secretAttribute3 = [NSString stringWithFormat:@"%@_%@", @"test_15000_4_secretAtrribute_03", [request getTimeStamp]];
        NSMutableDictionary *properties = @{@"test_15000_4_01_secrect1":secretAttribute1,@"test_15000_4_02_secrect2":secretAttribute2, @"test_15000_4_02_secrect3":secretAttribute3};
        [ins1 track:eventName properties: properties];
        [eventDic setObject:properties forKey:eventName];
    }

    [ins1 flush];
    

    [TEST_Helper dispatchQueue:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [expect fulfill];
        });
    }];

    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
//        等待10秒，若该测试未结束（未收到 fulfill方法）则测试结果为失败
//        Do something when time out
    }];
    
    //验证加密数据是否成功上报到TA
    for(id eventNameKey in eventDic){
        NSString *urlString = @"http://39.101.207.185:44492/querySql?token=BT004tK74eCQAUd1N33ZPlzLdeFsL1uJHFc517epTEipKu9jqAPjQP0ZsRna75qP&format=json&timeoutSecond=10&sql=select%20*%20from%20v_event_3%20where%20%22$part_event%22=";
        urlString = [urlString stringByAppendingFormat: @"%@%@%@%@%@%@%@",@"'",eventNameKey,@"'",@"%20and%20%20%22$part_date%22=",@"'",[request getDate],@"'"];
        urlString = [urlString stringByAppendingFormat: @"%@", @"%20order%20by%20%22%23server_time%22%20desc"];

        Boolean endWhile = true;
        NSMutableDictionary *response;
        NSInteger whileCount = 0;
        while (endWhile) {
            whileCount += 1;
            response = [request postRequest:urlString];
            NSLog(@"%@", response[@"test_15000_4_01_secrect1"]);
            NSString *actualAttr = response[@"test_15000_4_01_secrect1"];
            NSString *exceptAttr = eventDic[eventNameKey][@"test_15000_4_01_secrect1"];
            if([actualAttr isEqualToString: exceptAttr] | (whileCount >= 6)){
                endWhile = false;
    //            NSLog(@"%@", response);
            }
            [NSThread sleepForTimeInterval:30];
        }
        XCTAssertEqualObjects(response[@"test_15000_4_01_secrect1"], eventDic[eventNameKey][@"test_15000_4_01_secrect1"]);
        XCTAssertEqualObjects(response[@"test_15000_4_02_secrect2"], eventDic[eventNameKey][@"test_15000_4_02_secrect2"]);
        XCTAssertEqualObjects(response[@"test_15000_4_03_secrect3"], eventDic[eventNameKey][@"test_15000_4_03_secrect3"]);
    }
    
    
}
@end


// 关闭加密连续发十条,紧接上一条
@implementation TEST_15000_4_1

- (void)test_15000_4_1 {
    XCTestExpectation* expect = [self expectationWithDescription:@"Oh, timeout!"];

    UrlRequest *request = [UrlRequest new];
    [ThinkingAnalyticsSDK setLogLevel:TDLoggingLevelDebug];
    NSString *appid = @"872c6dd5bd5643bdb9442e0fe4eac802";
    NSString *url = @"http://39.101.207.185:44491";
    NSString *secretAttribute1;
    NSString *secretAttribute2;
    NSString *secretAttribute3;
    NSMutableDictionary *eventDic = [NSMutableDictionary dictionary];
    TDConfig *config = [TDConfig new];
    config.appid = appid;
    config.configureURL = url;
    config.enableEncrypt = NO;

    ThinkingAnalyticsSDK *ins1 = [ThinkingAnalyticsSDK startWithConfig:config];
    [ins1 login:@"qa_login_secretKey_test_15000_4_1"];

    for (NSInteger i = 0; i < 10; i++) {
        NSString *eventName = [NSString stringWithFormat:@"%@_%@", @"test_15000_4_1", [NSString stringWithFormat: @"%ld", (long)i]];
        secretAttribute1 = [NSString stringWithFormat:@"%@_%@", @"test_15000_4_1_secretAtrribute_01", [request getTimeStamp]];
        secretAttribute2 = [NSString stringWithFormat:@"%@_%@", @"test_15000_4_1_secretAtrribute_02", [request getTimeStamp]];
        secretAttribute3 = [NSString stringWithFormat:@"%@_%@", @"test_15000_4_1_secretAtrribute_03", [request getTimeStamp]];
        NSMutableDictionary *properties = @{@"test_15000_4_1_01_secrect1":secretAttribute1,@"test_15000_4_1_02_secrect2":secretAttribute2, @"test_15000_4_1_02_secrect3":secretAttribute3};
        [ins1 track:eventName properties: properties];
        [eventDic setObject:properties forKey:eventName];
    }

    [ins1 flush];
    

    [TEST_Helper dispatchQueue:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [expect fulfill];
        });
    }];

    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
//        等待10秒，若该测试未结束（未收到 fulfill方法）则测试结果为失败
//        Do something when time out
    }];
    
    //验证加密数据是否成功上报到TA
    for(id eventNameKey in eventDic){
        NSString *urlString = @"http://39.101.207.185:44492/querySql?token=BT004tK74eCQAUd1N33ZPlzLdeFsL1uJHFc517epTEipKu9jqAPjQP0ZsRna75qP&format=json&timeoutSecond=10&sql=select%20*%20from%20v_event_3%20where%20%22$part_event%22=";
        urlString = [urlString stringByAppendingFormat: @"%@%@%@%@%@%@%@",@"'",eventNameKey,@"'",@"%20and%20%20%22$part_date%22=",@"'",[request getDate],@"'"];
        urlString = [urlString stringByAppendingFormat: @"%@", @"%20order%20by%20%22%23server_time%22%20desc"];

        Boolean endWhile = true;
        NSMutableDictionary *response;
        NSInteger whileCount = 0;
        while (endWhile) {
            whileCount += 1;
            response = [request postRequest:urlString];
            NSLog(@"%@", response[@"test_15000_4_1_01_secrect1"]);
            NSString *actualAttr = response[@"test_15000_4_1_01_secrect1"];
            NSString *exceptAttr = eventDic[eventNameKey][@"test_15000_4_1_01_secrect1"];
            if([actualAttr isEqualToString: exceptAttr] | (whileCount >= 6)){
                endWhile = false;
    //            NSLog(@"%@", response);
            }
            [NSThread sleepForTimeInterval:30];
        }
        XCTAssertEqualObjects(response[@"test_15000_4_1_01_secrect1"], eventDic[eventNameKey][@"test_15000_4_1_01_secrect1"]);
        XCTAssertEqualObjects(response[@"test_15000_4_1_02_secrect2"], eventDic[eventNameKey][@"test_15000_4_1_02_secrect2"]);
        XCTAssertEqualObjects(response[@"test_15000_4_1_03_secrect3"], eventDic[eventNameKey][@"test_15000_4_1_03_secrect3"]);
    }
}
@end


// version正确，公钥非法，落入错误数据， version错误，公钥合法，落入错误数据，第一期暂不校验该场景
@implementation TEST_15000_5


- (void)test_15000_5 {
    XCTestExpectation* expect = [self expectationWithDescription:@"Oh, timeout!"];


    UrlRequest *request = [UrlRequest new];
    [ThinkingAnalyticsSDK setLogLevel:TDLoggingLevelDebug];
    NSString *appid = @"4e06aac882b84fa5bf97a7d8c67d2333";
    NSString *url = @"http://ta_test_debug.receiver.thinkingdata.cn:9080";
    TDConfig *config = [TDConfig new];
    config.appid = appid;
    config.configureURL = url;
    config.enableEncrypt = YES;
    config.secretKey = [[TDSecretKey alloc] initWithVersion:2 publicKey:@"MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAp2ofw+q0+lYC9S2156hd\n7CcNSmGOx0lMv+XIhalT6mF4ISOtY/WwsN/MzWsJwxt2svA/K4dDG0MdXa3d9k1P\n1bKJiVkUjLTeiMnlIma3rkum0a0lW+VcWnKTmjsR+q24zAlI9yugSdw9ULXIhn0d\nOQhgqmMCN0AFVqxG9s/z4ifVMrYNRqlHC/D9/t61MKNWmhi6PPbO3C/5of3QoOnn\nC2P6UUsHDfxXUN/FYDQIEFM8UAx3PxLJFVtga28CINOriRFbv9irGwfRZ18H7LeM\n6VVhsIb2+kd1WX2/SlsT/GthPeAjwAylCHvq/k0To+4N92YD6v/LAJ03Of8cfHb1\nkwIDAQAB1111111"];
    ThinkingAnalyticsSDK *ins = [ThinkingAnalyticsSDK startWithConfig:config];
    [ins login:@"qa_login_secretKey_test_15000_3"];
    NSString *eventName = @"test_15000_5";
    [ins track:eventName properties:@{@"xyw_properties_secretKey_01":@"xyw_atrributes_secretKey_01_test_15000_5_1",@"xyw_properties_secretKey_02":@"xyw_atrributes_secretKey_02_test_15000_5_1", @"xyw_properties_secretKey_03":@"xyw_atrributes_secretKey_03_test_15000_5_1"}];

//    [ins1 flush];
    
    
    NSString *appid1 = @"4e06aac882b84fa5bf97a7d8c67d2333";
    TDConfig *config1 = [TDConfig new];
    config1.appid = appid1;
    config1.configureURL = url;
    config1.enableEncrypt = YES;
    config1.secretKey = [[TDSecretKey alloc] initWithVersion:3 publicKey:@"MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAp2ofw+q0+lYC9S2156hd\n7CcNSmGOx0lMv+XIhalT6mF4ISOtY/WwsN/MzWsJwxt2svA/K4dDG0MdXa3d9k1P\n1bKJiVkUjLTeiMnlIma3rkum0a0lW+VcWnKTmjsR+q24zAlI9yugSdw9ULXIhn0d\nOQhgqmMCN0AFVqxG9s/z4ifVMrYNRqlHC/D9/t61MKNWmhi6PPbO3C/5of3QoOnn\nC2P6UUsHDfxXUN/FYDQIEFM8UAx3PxLJFVtga28CINOriRFbv9irGwfRZ18H7LeM\n6VVhsIb2+kd1WX2/SlsT/GthPeAjwAylCHvq/k0To+4N92YD6v/LAJ03Of8cfHb1\nkwIDAQAB"];
    ThinkingAnalyticsSDK *ins1 = [ThinkingAnalyticsSDK startWithConfig:config];
    [ins1 login:@"qa_login_secretKey_test_15000_3"];
    eventName =  @"test_15000_5";
    [ins1 track:eventName properties:@{@"xyw_properties_secretKey_01":@"xyw_atrributes_secretKey_01_test_15000_5",@"xyw_properties_secretKey_02":@"xyw_atrributes_secretKey_02_test_15000_5", @"xyw_properties_secretKey_03":@"xyw_atrributes_secretKey_03_test_15000_5"}];


//    [ins1 flush];
    

    [TEST_Helper dispatchQueue:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [expect fulfill];
        });
    }];

    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
//        等待10秒，若该测试未结束（未收到 fulfill方法）则测试结果为失败
//        Do something when time out
    }];
    
    [ins1 flush];
}
@end

//开启加密后，需要将未加密的数据加密上报，数据库中先写入未加密的数据
@implementation TEST_15000_6

- (void)test_15000_6 {
    XCTestExpectation* expect = [self expectationWithDescription:@"Oh, timeout!"];
    
    UrlRequest *request = [UrlRequest new];
    [ThinkingAnalyticsSDK setLogLevel:TDLoggingLevelDebug];
    NSString *appid = @"872c6dd5bd5643bdb9442e0fe4eac802";
    NSString *url = @"http://39.101.207.185:44491";
    
    NSString *normalAttribute1 = [NSString stringWithFormat:@"%@_%@", @"test_15000_6_1_normalAtrribute_01", [request getTimeStamp]];
    NSString *uuid = [request uuidString];
    NSString *noSecrestEventName = @"test_15000_6_1_no_secret";
    // 数据库先写入未加密数据
    TDSqliteDataQueue *dataQueue = [TDSqliteDataQueue sharedInstanceWithAppid:appid];
    NSDictionary *properties =  @{@"#account_id":@"qa_login_secretKey_test_15000_6",@"#time":@"2022-03-01 18:31:07.965",@"#uuid":uuid,@"#distinct_id":@"6F33C257-BDE9-43DF-B727-4CF2ECF01E85_14",@"#event_name":noSecrestEventName,@"#type":@"track",@"properties":@{@"#lib_version":@"2.7.5",@"#carrier":@"",@"#zone_offset":@8,@"#os":@"iOS",@"#ram":@"3.8/16.0",@"#device_id":@"6F33C257-BDE9-43DF-B727-4CF2ECF01E85",@"#data_source":@"Native_SDK",@"#screen_height":@844,@"#bundle_id":@"cn.thinking.thinkingdata",@"#system_language":@"en",@"#screen_width":@390,@"#device_model":@"arm64",@"#network_type":@"WIFI",@"#install_time":@"2022-03-01 12:33:37.421",@"#simulator":@1,@"#lib":@"iOS",@"test_15000_6_1_no_secret_01":normalAttribute1,@"#app_version":@"1.0",@"#os_version":@"15.2"}};
    [dataQueue addObject:properties withAppid:appid];
    
    TDConfig *config = [TDConfig new];
    config.appid = appid;
    config.configureURL = url;
    config.enableEncrypt = YES;
    config.secretKey = [[TDSecretKey alloc] initWithVersion:1 publicKey:@"MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAti6FnWGv7Lggzg/R8hQa\n4GEtd2ucfntqo6Xkf1sPwCIfndr2u6KGPhWQ24bFUKgtNLDuKnUAg1C/OEEL8uON\nJBdbX9XpckO67tRPSPrY3ufNIxsCJ9td557XxUsnebkOZ+oC1Duk8/ENx1pRvU6S\n4c+UYd6PH8wxw1agD61oJ0ju3CW0aZNZ2xKcWBcIU9KgYTeUtawrmGU5flod88Cq\nZc8VKB1+nY0tav023jvxwkM3zgQ6vBWIU9/aViGECB98YEzJfZjcOTD6zvqsZc/W\nRnUNhBHFPGEwc8ueMvzZNI+FP0pUFLVRwVoYbj/tffKbxGExaRFIcgP73BIW6/6n\nQwIDAQAB"];
    ThinkingAnalyticsSDK *ins1 = [ThinkingAnalyticsSDK startWithConfig:config];
    
    [ins1 login:@"qa_login_secretKey_test_15000_6"];

    NSString *eventName = @"test_15000_6_1";
    NSString *secretAttribute1 = [NSString stringWithFormat:@"%@_%@", @"test_15000_6_secretAtrribute_01", [request getTimeStamp]];
    NSString *secretAttribute2 = [NSString stringWithFormat:@"%@_%@", @"test_15000_6_secretAtrribute_02", [request getTimeStamp]];
    NSString *secretAttribute3 = [NSString stringWithFormat:@"%@_%@", @"test_15000_6_secretAtrribute_03", [request getTimeStamp]];
    [ins1 track:eventName properties:@{@"test_15000_6_01_secrect1":secretAttribute1,@"test_15000_6_02_secrect2":secretAttribute2, @"test_15000_6_03_secrect3":secretAttribute3}];

 
    [ins1 flush];
    
    [TEST_Helper dispatchQueue:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [expect fulfill];
        });
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
//        等待10秒，若该测试未结束（未收到 fulfill方法）则测试结果为失败
//        Do something when time out
    }];
    
    //校验未加密的是否成功上报
    NSString *urlString = @"http://39.101.207.185:44492/querySql?token=BT004tK74eCQAUd1N33ZPlzLdeFsL1uJHFc517epTEipKu9jqAPjQP0ZsRna75qP&format=json&timeoutSecond=10&sql=select%20*%20from%20v_event_3%20where%20%22$part_event%22=";
    urlString = [urlString stringByAppendingFormat: @"%@%@%@%@%@%@%@",@"'",noSecrestEventName,@"'",@"%20and%20%20%22$part_date%22=",@"'",@"2022-03-01",@"'"];
    urlString = [urlString stringByAppendingFormat: @"%@", @"%20order%20by%20%22%23server_time%22%20desc"];

    Boolean endWhile = true;
    NSMutableDictionary *response;
    NSInteger whileCount = 0;
    while (endWhile) {
        whileCount += 1;
        response = [request postRequest:urlString];
        NSLog(@"%@", response[@"test_15000_6_1_no_secret_01"]);
        NSString *actualAttr = response[@"test_15000_6_1_no_secret_01"];
        if([actualAttr isEqualToString: normalAttribute1] | (whileCount >= 6)){
            endWhile = false;
//            NSLog(@"%@", response);
        }
        [NSThread sleepForTimeInterval:30];
    }
    XCTAssertEqualObjects(response[@"test_15000_6_1_no_secret_01"], normalAttribute1);

    //校验加密的是否成功上报
    urlString = @"http://39.101.207.185:44492/querySql?token=BT004tK74eCQAUd1N33ZPlzLdeFsL1uJHFc517epTEipKu9jqAPjQP0ZsRna75qP&format=json&timeoutSecond=10&sql=select%20*%20from%20v_event_3%20where%20%22$part_event%22=";
    urlString = [urlString stringByAppendingFormat: @"%@%@%@%@%@%@%@",@"'",eventName,@"'",@"%20and%20%20%22$part_date%22=",@"'",[request getDate],@"'"];
    urlString = [urlString stringByAppendingFormat: @"%@", @"%20order%20by%20%22%23server_time%22%20desc"];

    endWhile = true;
    whileCount = 0;
    NSMutableDictionary *response1;
    while (endWhile) {
        whileCount += 1;
        response1 = [request postRequest:urlString];
        NSString *actualAttr = response1[@"test_15000_6_01_secrect1"];
        if([actualAttr isEqualToString: secretAttribute1] | (whileCount >= 6)){
            endWhile = false;
            NSLog(@"%@", response1);
        }
        [NSThread sleepForTimeInterval:30];
    }
    XCTAssertEqualObjects(response1[@"test_15000_6_01_secrect1"], secretAttribute1);
    XCTAssertEqualObjects(response1[@"test_15000_6_02_secrect2"], secretAttribute2);
    XCTAssertEqualObjects(response1[@"test_15000_6_03_secrect3"], secretAttribute3);
}
@end

//关闭加密后，数据库里面有加密数据，上报数据需要将加密数据和新的未加密数据上报,数据库中先写入已经加密的数据
@implementation TEST_15000_7

- (void)test_15000_7 {
    XCTestExpectation* expect = [self expectationWithDescription:@"Oh, timeout!"];

    UrlRequest *request = [UrlRequest new];
    [ThinkingAnalyticsSDK setLogLevel:TDLoggingLevelDebug];
    NSString *appid = @"872c6dd5bd5643bdb9442e0fe4eac802";
    NSString *url = @"http://39.101.207.185:44491";
    NSString *secretAttribute1 = [NSString stringWithFormat:@"%@_%@", @"test_15000_7_secretAtrribute_01", [request getTimeStamp]];
    NSString *uuid = [request uuidString];
    NSString *secrestEventName = @"test_15000_7_secret";
    TDSqliteDataQueue *dataQueue = [TDSqliteDataQueue sharedInstanceWithAppid:appid];
    
    NSDictionary *propertiesSecret =  @{@"#account_id":@"qa_login_secretKey_test_15000_6",@"#time":@"2022-03-02 18:31:07.965",@"#uuid":uuid,@"#distinct_id":@"6F33C257-BDE9-43DF-B727-4CF2ECF01E85_14",@"#event_name":secrestEventName,@"#type":@"track",@"properties":@{@"#lib_version":@"2.7.5",@"#carrier":@"",@"#zone_offset":@8,@"#os":@"iOS",@"#ram":@"3.8/16.0",@"#device_id":@"6F33C257-BDE9-43DF-B727-4CF2ECF01E85",@"#data_source":@"Native_SDK",@"#screen_height":@844,@"#bundle_id":@"cn.thinking.thinkingdata",@"#system_language":@"en",@"#screen_width":@390,@"#device_model":@"arm64",@"#network_type":@"WIFI",@"#install_time":@"2022-03-01 12:33:37.421",@"#simulator":@1,@"#lib":@"iOS",@"test_15000_7_secret_01":secretAttribute1,@"#app_version":@"1.0",@"#os_version":@"15.2"}};
    NSData *data = [NSJSONSerialization dataWithJSONObject:propertiesSecret options:NSJSONWritingPrettyPrinted error:nil];

    // payload进行加密
    NSString *propertiesPayload = [request dataByAes128ECB:data key:@"dMBTfERDHg9l7aaR" mode:kCCEncrypt];

    NSDictionary *properties = @{@"pkv" : @1,
                                 @"payload":propertiesPayload,
                                 @"ekey" : @"WeNw1LP0nEA0Mm+VyuI1G7wTUppSOi4B27TJaM3PKTuxc54s2DfzdxIIzWi6jTxxl5aKy2u9jV8uWrhEAXgBty1iUFUO8wqkHAO0mLPVjbZKcrziZLAcZN1VGR/2w99N7TagW1zbgG/Zonh/+9PtMYb7Rsn/BzqDBYuqZaAYqDKeDsLYkFnD8z2gaQz1NVIg8hQRiYIRTGd4zxC7TgK6ZXIERixVVzgHi6lTP3r36hlqd1iu2kmG2HUp4gEjbjGqdOzGuhcMCaT4ZrXUTtlLImW8ux1OO2LRCTrBeCFmPVzy8MgBD5B9opUVVq/6HOKhUcxiKSnWHK3xGFZAs4XLNg=="};
    [dataQueue addObject:properties withAppid:appid];
//
    TDConfig *config = [TDConfig new];
    config.appid = appid;
    config.configureURL = url;
    config.enableEncrypt = NO;
    ThinkingAnalyticsSDK *ins1 = [ThinkingAnalyticsSDK startWithConfig:config];
    [ins1 login:@"qa_login_secretKey_test_15000_7"];

    NSString *eventName = @"test_15000_7";
    NSString *normalAttribute1 = [NSString stringWithFormat:@"%@_%@", @"test_15000_7_normalAtrribute_01", [request getTimeStamp]];
    NSString *normalAttribute2 = [NSString stringWithFormat:@"%@_%@", @"test_15000_7_normalAtrribute_02", [request getTimeStamp]];
    NSString *normalAttribute3 = [NSString stringWithFormat:@"%@_%@", @"test_15000_7_normalAtrribute_03", [request getTimeStamp]];
    [ins1 track:eventName properties:@{@"test_15000_7_01_normal1":normalAttribute1,@"test_15000_7_02_normal2":normalAttribute2, @"test_15000_7_03_normal3":normalAttribute3}];

    [ins1 flush];


    [TEST_Helper dispatchQueue:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [expect fulfill];
        });
    }];

    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
//        等待10秒，若该测试未结束（未收到 fulfill方法）则测试结果为失败
//        Do something when time out
    }];
    
    // 确认加密数据是否已经上报
    NSString *urlString = @"http://39.101.207.185:44492/querySql?token=BT004tK74eCQAUd1N33ZPlzLdeFsL1uJHFc517epTEipKu9jqAPjQP0ZsRna75qP&format=json&timeoutSecond=10&sql=select%20*%20from%20v_event_3%20where%20%22$part_event%22=";
    urlString = [urlString stringByAppendingFormat: @"%@%@%@%@%@%@%@",@"'",secrestEventName,@"'",@"%20and%20%20%22$part_date%22=",@"'",@"2022-03-02",@"'"];
    urlString = [urlString stringByAppendingFormat: @"%@", @"%20order%20by%20%22%23server_time%22%20desc"];
    Boolean endWhile = true;
    NSInteger whileCount = 0;
    NSMutableDictionary *response;
    while (endWhile) {
        whileCount += 1;
        response = [request postRequest:urlString];
        NSString *actualAttr = response[@"test_15000_7_secret_01"];
        if([actualAttr isEqualToString: secretAttribute1] | (whileCount >= 6)){
            endWhile = false;
            NSLog(@"%@", response);
        }
        [NSThread sleepForTimeInterval:30];
    }
    XCTAssertEqualObjects(response[@"test_15000_7_secret_01"], secretAttribute1);

    // 确认非加密数据也已经上报
    urlString = @"http://39.101.207.185:44492/querySql?token=BT004tK74eCQAUd1N33ZPlzLdeFsL1uJHFc517epTEipKu9jqAPjQP0ZsRna75qP&format=json&timeoutSecond=10&sql=select%20*%20from%20v_event_3%20where%20%22$part_event%22=";
    urlString = [urlString stringByAppendingFormat: @"%@%@%@%@%@%@%@",@"'",eventName,@"'",@"%20and%20%20%22$part_date%22=",@"'",[request getDate],@"'"];
    urlString = [urlString stringByAppendingFormat: @"%@", @"%20order%20by%20%22%23server_time%22%20desc"];

    endWhile = true;
    whileCount = 0;
    NSMutableDictionary *response1;
    while (endWhile) {
        whileCount += 1;
        response1 = [request postRequest:urlString];
        NSString *actualAttr = response1[@"test_15000_7_01_normal1"];
        if([actualAttr isEqualToString: normalAttribute1] | (whileCount >= 6)){
            endWhile = false;
            NSLog(@"%@", response1);
        }
        [NSThread sleepForTimeInterval:30];
    }
    XCTAssertEqualObjects(response1[@"test_15000_7_01_normal1"], normalAttribute1);
    XCTAssertEqualObjects(response1[@"test_15000_7_02_normal2"], normalAttribute2);
    XCTAssertEqualObjects(response1[@"test_15000_7_03_normal3"], normalAttribute3);
    
}
@end
