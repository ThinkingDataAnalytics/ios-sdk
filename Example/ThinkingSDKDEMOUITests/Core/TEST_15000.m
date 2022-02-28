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
//#import "UrlRequest.h"

@interface TEST_15000 ()

@property(nonatomic, strong) NSMutableArray<TEST_Model *> *models;

@end


@implementation TEST_15000

- (void)setUp {
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

//@implementation TEST_15000_2
//
//
//- (void)test_15000_2 {
//    UrlRequest *request = [UrlRequest new];
//    NSDictionary *response = [request getRequest:@"http://dev-ta1:8992/open/get-virtual-event-by-name?token=9KTApCa69a1Pt21ClKeG2RhL1nQFugZIMlf10M0VZn6ToYw4UX2DruD14THSqDH4&projectId=2780&eventName=secret_event_xyw_01"];
//    NSLog(@"%@", [self convertToJsonData:response]);
//}
//
//- (NSString *)convertToJsonData:(NSDictionary *)dict
//{
//    NSError *error;
//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
//    NSString *jsonString;
//
//    if (!jsonData) {
//        NSLog(@"%@",error);
//    } else {
//        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
//    }
//
//    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
//
//    NSRange range = {0,jsonString.length};
//
//    //去掉字符串中的空格
//    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
//
//    NSRange range2 = {0,mutStr.length};
//
//    //去掉字符串中的换行符
//    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
//
//    return mutStr;
//}
//
//@end

@implementation TEST_15000_1

- (void)test_15000_1 {
//
    [ThinkingAnalyticsSDK setLogLevel:TDLoggingLevelDebug];
    NSString *appid = @"cf918051b394495ca85d1b7787ad7243";
    NSString *url = @"https://receiver-ta-dev.thinkingdata.cn";
    TDConfig *config = [TDConfig new];
    config.appid = appid;
    config.configureURL = url;
    config.enableEncrypt = YES;
    config.secretKey = [[TDSecretKey alloc] initWithVersion:1 publicKey:@"MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCzAKEGsq67Yd03/RF77VKJ/cQ3\nzfSboK1wzlQfH2E1fr504WCJHHL/UVgjfUGUjMLIN15FNEelp7TXLToqtYlqqMbE\nXCfSc14ulRatKQioYnJ8EzgUhG0HcRlulni6vxGJHR9iq4weDNyJFRaZuwIQSrUz\nIaiVq/3hYijxxhhFqQIDAQAB"];
    [ThinkingAnalyticsSDK startWithConfig:config];
    [[ThinkingAnalyticsSDK sharedInstance] login:@"qa_login_secretKey"];
    [[ThinkingAnalyticsSDK sharedInstance] track:@"test_15000" properties:@{@"xyw_properties_secretKey_01":@"xyw_atrributes_secretKey_01",@"xyw_properties_secretKey_02":@"xyw_atrributes_secretKey_02", @"xyw_properties_secretKey_03":@"xyw_atrributes_secretKey_03"}];
//    [[ThinkingAnalyticsSDK sharedInstance] user_uniq_append:@{@"abc":@[@"aaa",@"bbb",@"ccc"]}];
//    [[ThinkingAnalyticsSDK sharedInstance] flush];



    [ThinkingAnalyticsSDK setLogLevel:TDLoggingLevelDebug];
    NSString *appid1 = @"cf918051b394495ca85d1b7787ad7243";
    NSString *url1 = @"https://receiver-ta-dev.thinkingdata.cn";
    TDConfig *config1 = [TDConfig new];
    config1.appid = appid1;
    config1.configureURL = url1;
    config1.enableEncrypt = NO;
    ThinkingAnalyticsSDK *ins = [ThinkingAnalyticsSDK startWithConfig:config1];
    [ins login:@"qa_login_nomarl"];
    [ins track:@"test_event" properties:@{@"xyw_properties_secretKey_01":@"xyw_atrributes_secretKey_01",@"xyw_properties_secretKey_02":@"xyw_atrributes_secretKey_02", @"xyw_properties_secretKey_03":@"xyw_atrributes_secretKey_03"}];
    [ins user_uniq_append:@{@"abc":@[@"aaa",@"bbb",@"ccc"]}];
    [ins flush];
    
}

@end

