//
//  ThinkingSDKDEMOUITests.m
//  ThinkingSDKDEMOUITests
//
//  Created by syj on 2019/6/24.
//  Copyright © 2019年 thinking. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface ThinkingSDKDEMOUITests : XCTestCase

@end

@implementation ThinkingSDKDEMOUITests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.

    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = NO;

    // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
    [[[XCUIApplication alloc] init] launch];

    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)test01APICell {
    XCUIApplication *app = [[XCUIApplication alloc] init];
    [app.tables.cells.staticTexts[@"Track"] tap];
    [app.tables.cells.staticTexts[@"Track with property"] tap];
    [app.tables.cells.staticTexts[@"Track With Time"] tap];
    [app.tables.cells.staticTexts[@"User Set"] tap];
    [app.tables.cells.staticTexts[@"User Set Once"] tap];
    [app.tables.cells.staticTexts[@"User Del"] tap];
    [app.tables.cells.staticTexts[@"User ADD"] tap];
    [app.tables.cells.staticTexts[@"Login"] tap];
    [app.tables.cells.staticTexts[@"Logout"] tap];
    [app.tables.cells.staticTexts[@"Set SuperProperty"] tap];
    [app.tables.cells.staticTexts[@"Del SuperProperty"] tap];
    [app.tables.cells.staticTexts[@"Clear SuperProperty"] tap];
    [app.tables.cells.staticTexts[@"Time Event"] tap];
    [app.tables.cells.staticTexts[@"Time Event End"] tap];
    [app.tables.cells.staticTexts[@"Identify"] tap];
}

- (void)test02AutoTableViewController {
    XCUIApplication *app = [[XCUIApplication alloc] init];
    [app.tables.cells.staticTexts[@"More (AutoTrack)"] tap];
   
    XCUIElementQuery *tablesQuery = app.tables;
    [tablesQuery.staticTexts[@"H5 打通 UIWebView"] tap];
    
    [app.navigationBars[@"ThinkingSDK DEMO"].buttons[@"AutoTrack"] tap];
    [tablesQuery.staticTexts[@"H5 打通 WKWebView"] tap];
    
    [app.navigationBars[@"ThinkingSDK DEMO"].buttons[@"AutoTrack"] tap];
    [tablesQuery.staticTexts[@"autotrack UITableView"] tap];
    [tablesQuery.staticTexts[@"cell 1"] tap];
    [tablesQuery.staticTexts[@"cell 2"] tap];
    
    [app.navigationBars[@"ThinkingSDK DEMO"].buttons[@"AutoTrack"] tap];
    [tablesQuery.staticTexts[@"autotrack UICollectionView"] tap];
    [app.collectionViews.cells.staticTexts[@"0"] tap];
    [app.collectionViews.cells.staticTexts[@"1"] tap];
    
    [app.navigationBars[@"ThinkingSDK DEMO"].buttons[@"AutoTrack"] tap];
    [tablesQuery.staticTexts[@"autotrack UIViewControllor"] tap];
    
    [app.navigationBars[@"ThinkingSDK DEMO"].buttons[@"AutoTrack"] tap];
    [app.navigationBars[@"AutoTrack"].buttons[@"ThinkingSDK DEMO"] tap];
}

@end
