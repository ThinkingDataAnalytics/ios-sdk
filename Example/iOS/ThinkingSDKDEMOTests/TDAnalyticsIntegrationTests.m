//
//  TDAnalyticsIntegrationTests.m
//  ThinkingSDKDEMOTests
//

#import <XCTest/XCTest.h>
#import <ThinkingSDK/ThinkingSDK.h>
#import <ThinkingSDK/TDPublicConfig.h>

@interface TDAnalyticsIntegrationTests : XCTestCase
@property (nonatomic, copy) NSString *testAppId;
@property (nonatomic, copy) NSString *testInstanceName;
@end

@implementation TDAnalyticsIntegrationTests

- (void)setUp {
    [super setUp];
    self.testAppId = [[NSUUID UUID] UUIDString];
    self.testInstanceName = [NSString stringWithFormat:@"Test_%@", self.testAppId];

    TDConfig *config = [[TDConfig alloc] init];
    config.appid = self.testAppId;
    config.serverUrl = @"https://receiver-ta-preview.thinkingdata.cn";
    config.name = self.testInstanceName;
    config.mode = TDModeNormal;
    [TDAnalytics startAnalyticsWithConfig:config];
}

- (void)testSDKVersionIsNonEmpty {
    NSString *version = [TDAnalytics getSDKVersion];
    XCTAssertTrue(version.length > 0);
    XCTAssertEqualObjects(version, TDPublicConfig.version);
}

- (void)testStartAnalyticsWithConfig {
    TDConfig *config = [[TDConfig alloc] init];
    config.appid = [[NSUUID UUID] UUIDString];
    config.serverUrl = @"https://receiver-ta-preview.thinkingdata.cn";
    config.name = [NSString stringWithFormat:@"InitTest_%@", config.appid];
    XCTAssertNoThrow([TDAnalytics startAnalyticsWithConfig:config]);
}

- (void)testTrackEventDoesNotCrash {
    XCTAssertNoThrow([TDAnalytics track:@"integration_test_event" properties:@{@"source": @"ThinkingSDKDEMOTests"}]);
}

- (void)testFlushDoesNotCrash {
    [TDAnalytics track:@"integration_flush_event" properties:@{@"source": @"ThinkingSDKDEMOTests"}];
    XCTAssertNoThrow([TDAnalytics flush]);
}

@end
