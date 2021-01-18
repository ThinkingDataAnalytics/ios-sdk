//
//  ThinkingSDKDEMOUITests.m
//  ThinkingSDKDEMOUITests
//
//  Created by syj on 2019/6/24.
//  Copyright © 2019年 thinking. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <ThinkingSDK/ThinkingSDK.h>
#import "ThinkingAnalyticsSDK+Hook.h"
#import "ThinkingSDKDemoTestCase.m"

@interface ThinkingSDKDEMOUITests : XCTestCase
@property(strong,nonatomic) XCUIApplication* application;
@property(strong,nonatomic)NSMutableArray* data;
@end

@implementation ThinkingSDKDEMOUITests
- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    // In UI tests it is usually best to stop immediately when a failure occurs.
    _application = [[XCUIApplication alloc] init];
    [_application launch];
    
}
- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [_data removeAllObjects];
}
- (void)receiveData:(NSNotification*)notification
{
    NSDictionary* data = notification.userInfo;
    [_data addObject:data];
}
/**
 *track事件设备属性判断
 */
- (void)assertTrackDeviceInfo:(NSDictionary*)properties
{
    XCTAssertNotNil(properties[@"#lib_version"]);
    XCTAssertEqualObjects(properties[@"#lib"],@"iOS");
    XCTAssertEqualObjects(properties[@"#os"],@"iOS");
    XCTAssertNotNil(properties[@"#network_type"]);
    XCTAssertNotNil(properties[@"#device_id"]);
    XCTAssertNotNil(properties[@"#os_version"]);
//    XCTAssertNotNil(properties[@"#carrier"]);
    XCTAssertNotNil(properties[@"#manufacturer"]);
    XCTAssertNotNil(properties[@"#device_model"]);
    XCTAssertNotNil(properties[@"#screen_height"]);
    XCTAssertNotNil(properties[@"#screen_width"]);
}
/**
 * track事件内容和数据结构判断
 */
- (void)assertDefaultTrackContent:(NSDictionary*)data
{
    XCTAssertEqualObjects(data[@"#type"],@"track");
    XCTAssertNotNil(data[@"#time"]);
    XCTAssertEqualObjects(data[@"#distinct_id"],[ThinkingSDKDemoTestCase.instance getDistinctId]);
    XCTAssertNotNil(data[@"#event_name"]);
    NSDictionary* properties = data[@"properties"];
    XCTAssertNotNil(properties);
    [self assertTrackDeviceInfo:properties];
    XCTAssertNotNil(data[@"#uuid"]);
    NSString* account = [ThinkingSDKDemoTestCase.instance valueForKey:@"accountId"];
    if(account != nil)
    {
        XCTAssertEqual(data.allKeys.count, SIZE_OF_EVENT_DATA_LOGIN);
        XCTAssertEqualObjects(data[@"#account_id"], account);
    }else
    {
        XCTAssertEqual(data.allKeys.count, SIZE_OF_EVENT_DATA);
    }
}

/*
 *1.测试启动事件
 **/
//- (void)testAppStart
//{
//    [_instance enableAutoTrack:ThinkingAnalyticsEventTypeAppStart];
//    [NSThread sleepForTimeInterval:WAIT_TIME];
//    NSDictionary* data = _data[0];
//    NSDictionary* propreties = data[@"properties"];
//    [self assertTrackDeviceInfo:propreties];
//    [self assertDefaultTrackContent:data];
//    XCTAssertNotNil(propreties[@"#resume_from_background"]);
//    XCTAssertEqualObjects(data[@"#event_name"],@"ta_app_bg_start");
//}

- (void)testWebView
{
//    [_instance enableAutoTrack:ThinkingAnalyticsEventTypeAppStart];
    XCUIElement* tables =  _application.tables.firstMatch;
    XCUIElement *cell = [tables.cells elementBoundByIndex:0];
    [cell tap];
    
    [_application.buttons[@"点击初始化"] tap];
    tables =  _application.tables.firstMatch;
    cell = [tables.cells elementBoundByIndex:2];
    [cell tap];

    tables =  _application.tables.firstMatch;
    cell = [tables.cells elementBoundByIndex:1];
    [cell tap];
//    [NSThread sleepForTimeInterval:2];
//    [_application.buttons[@"track"] tap];
//    [NSThread sleepForTimeInterval:2];
//    [_application.buttons[@"loginAction"] tap];
//    [_application.buttons[@"logoutAction"] tap];
//    [_application.buttons[@"usersetAction"] tap];
//    [_application.buttons[@"userSetOnceAction"] tap];
//    [_application.buttons[@"userAddAction"] tap];
    
    NSLog(@"%@",_application.debugDescription);
    
    
//    [_application.tabs.cells.staticTexts[@"初始化"] tap];
 
}
//- (void)test01APICell {
//    XCUIApplication *app = [[XCUIApplication alloc] init];
//    [app.tables.cells.staticTexts[@"Track"] tap];
//    [app.tables.cells.staticTexts[@"Track with property"] tap];
//    [app.tables.cells.staticTexts[@"Track With Time"] tap];
//    [app.tables.cells.staticTexts[@"User Set"] tap];
//    [app.tables.cells.staticTexts[@"User Set Once"] tap];
//    [app.tables.cells.staticTexts[@"User Del"] tap];
//    [app.tables.cells.staticTexts[@"User ADD"] tap];
//    [app.tables.cells.staticTexts[@"Login"] tap];
//    [app.tables.cells.staticTexts[@"Logout"] tap];
//    [app.tables.cells.staticTexts[@"Set SuperProperty"] tap];
//    [app.tables.cells.staticTexts[@"Del SuperProperty"] tap];
//    [app.tables.cells.staticTexts[@"Clear SuperProperty"] tap];
//    [app.tables.cells.staticTexts[@"Time Event"] tap];
//    [app.tables.cells.staticTexts[@"Time Event End"] tap];
//    [app.tables.cells.staticTexts[@"Identify"] tap];
//}

//- (void)test02AutoTableViewController {
//    XCUIApplication *app = [[XCUIApplication alloc] init];
//    [app.tables.cells.staticTexts[@"More (AutoTrack)"] tap];
//
//    XCUIElementQuery *tablesQuery = app.tables;
//    [tablesQuery.staticTexts[@"H5 打通 UIWebView"] tap];
//
//    [app.navigationBars[@"ThinkingSDK DEMO"].buttons[@"AutoTrack"] tap];
//    [tablesQuery.staticTexts[@"H5 打通 WKWebView"] tap];
//
//    [app.navigationBars[@"ThinkingSDK DEMO"].buttons[@"AutoTrack"] tap];
//    [tablesQuery.staticTexts[@"autotrack UITableView"] tap];
//    [tablesQuery.staticTexts[@"cell 1"] tap];
//    [tablesQuery.staticTexts[@"cell 2"] tap];
//
//    [app.navigationBars[@"ThinkingSDK DEMO"].buttons[@"AutoTrack"] tap];
//    [tablesQuery.staticTexts[@"autotrack UICollectionView"] tap];
//    [app.collectionViews.cells.staticTexts[@"0"] tap];
//    [app.collectionViews.cells.staticTexts[@"1"] tap];
//
//    [app.navigationBars[@"ThinkingSDK DEMO"].buttons[@"AutoTrack"] tap];
//    [tablesQuery.staticTexts[@"autotrack UIViewControllor"] tap];
//
//    [app.navigationBars[@"ThinkingSDK DEMO"].buttons[@"AutoTrack"] tap];
//    [app.navigationBars[@"AutoTrack"].buttons[@"ThinkingSDK DEMO"] tap];
//}

@end
