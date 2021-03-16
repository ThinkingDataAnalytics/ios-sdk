//
//  ThinkingSDKTests.m
//  ThinkingSDKTests
//
//  Created by syj on 2019/8/12.
//  Copyright © 2019 thinkingdata. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OCMock.h"
//#import <ThinkingSDK/ThinkingSDK.h>
#import "ThinkingSDK.h"
#import "ThinkingAnalyticsSDKPrivate.h"
#import "TDDeviceInfo.h"
#import "TDPublicConfig.h"
#import "TDNetwork.h"
typedef NS_ENUM(NSInteger, EventType) {
    FIRST_EVENT = 1,UPDATE_EVENT,OVERRIDE_EVENT
};

NSString* TA_APP_ID = @"b2a61feb9e56472c90c5bcb320dfb4ef";
NSString* TA_APP_ID1 = @"debug-appid";
NSString* TA_SERVER_URL = @"https://sdk.tga.thinkinggame.cn";
NSString* EVENT_NAME = @"test";
int FLUSH_INTERVAL = 5000;
int FLUSH_BULK_SIZE = 5;

int SIZE_OF_EVENT_DATA = 6;
int SIZE_OF_EVENT_DATA_LOGIN = 7;
int SIZE_OF_USER_DATA = 5;
int SIZE_OF_USER_DATA_LOGIN = 6;
int SIZE_OF_SYSTEM_PROPERTY = 12;
int WAIT_TIME = 1;
NSString* mVersionName = @"1.0";
NSMutableDictionary* data;
typedef void(^MHandle)(NSInvocation *);
@interface ThinkingSDKTests : XCTestCase
@property(strong,nonatomic) TDConfig *mConfig;
@property(assign,nonatomic)dispatch_semaphore_t semaphore;
@property(assign,nonatomic)dispatch_queue_t queue;
@property(strong,nonatomic)id mock;
@property(strong,nonatomic)id lightMock;
@property(assign,nonatomic)MHandle handle;
@end

@implementation ThinkingSDKTests

- (void)setUp {
    _mConfig = [TDConfig new];
    _mConfig.appid = TA_APP_ID;
    _mConfig.configureURL = TA_SERVER_URL;
    _queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    ThinkingAnalyticsSDK *instance = [ThinkingAnalyticsSDK startWithAppId:TA_APP_ID withUrl:TA_SERVER_URL];
    data = [NSMutableDictionary new];
    _mock = OCMPartialMock(instance);
    [ThinkingAnalyticsSDK setLogLevel:TDLoggingLevelDebug];
    _handle = ^(NSInvocation *invocation) {
        NSDictionary *dic;
        [data removeAllObjects];
        [invocation getArgument:&dic atIndex:2];
        [data addEntriesFromDictionary:dic];
        NSLog(@"OK");
    };
     OCMStub([_mock saveEventsData:[OCMArg any]]).andDo(_handle);
}
- (void)tearDown {
    
    [_mock logout];
    [_mock stopMocking];
    if(_lightMock != nil)
    {
        [_lightMock logout];
        [_lightMock stopMocking];
    }
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}
/**
 *track事件设备属性判断
 */
- (void)assertTrackDeviceInfo:(NSDictionary*)properties
{
    TDDeviceInfo *info = [TDDeviceInfo sharedManager];
    NSDictionary* deviceInfo = [info collectAutomaticProperties];
    XCTAssertEqualObjects(properties[@"#lib_version"], [TDPublicConfig version]);
    XCTAssertEqualObjects(properties[@"#lib"],@"iOS");
    XCTAssertEqualObjects(properties[@"#os"],@"iOS");
    XCTAssertTrue(properties[@"#network_type"] != nil);
    XCTAssertEqualObjects(properties[@"#device_id"], info.deviceId);
    XCTAssertEqualObjects(properties[@"#os_version"],deviceInfo[@"#os_version"]);
    XCTAssertEqualObjects(properties[@"#carrier"],deviceInfo[@"#carrier"]);
    XCTAssertEqualObjects(properties[@"#manufacturer"],deviceInfo[@"#manufacturer"]);
    XCTAssertEqualObjects(properties[@"#device_model"],deviceInfo[@"#device_model"]);
    XCTAssertEqualObjects(properties[@"#screen_height"],deviceInfo[@"#screen_height"]);
    XCTAssertEqualObjects(properties[@"#screen_width"],deviceInfo[@"#screen_width"]);
}
/**
 * track事件内容和数据结构判断
 */
- (void)assertDefaultTrackContent:(NSDictionary*)data mock:(id)mock
{
    XCTAssertEqualObjects(data[@"#type"],@"track");
    XCTAssertNotNil(data[@"#time"]);
    XCTAssertEqualObjects(data[@"#distinct_id"],[mock getDistinctId]);
    XCTAssertNotNil(data[@"#event_name"]);
    NSDictionary* properties = data[@"properties"];
     XCTAssertNotNil(properties);
    [self assertTrackDeviceInfo:properties];
    XCTAssertNotNil(data[@"#uuid"]);
    if([mock accountId] != nil)
    {
        XCTAssertEqual(data.allKeys.count, SIZE_OF_EVENT_DATA_LOGIN);
        XCTAssertEqualObjects(data[@"#account_id"],[mock accountId]);
    }else
    {
        XCTAssertEqual(data.allKeys.count, SIZE_OF_EVENT_DATA);
    }
}
/**
 *首次,更新,可重写事件数据完整性判断
 */
- (void)assertDefaultTrackContent:(NSDictionary*)data mock:(id)mock length:(int)length
{
    XCTAssertNotNil(data[@"#type"]);
    XCTAssertNotNil(data[@"#time"]);
    XCTAssertEqualObjects(data[@"#distinct_id"],[mock getDistinctId]);
    XCTAssertNotNil(data[@"#event_name"]);
    NSDictionary* properties = data[@"properties"];
    XCTAssertNotNil(properties);
    [self assertTrackDeviceInfo:properties];
    XCTAssertNotNil(data[@"#uuid"]);
    XCTAssertEqual(data.allKeys.count, length);
    if([mock accountId] != nil)
    {
        XCTAssertEqualObjects(data[@"#account_id"],[mock accountId]);
    }
}

- (void)assertTrackProperty:(NSDictionary*)event instance:(id)mock date:(NSDate*)date
{
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.dateFormat = kDefaultTimeFormat;
    NSDictionary* property = event[@"properties"];
    XCTAssertEqualObjects(property[@"ta_string"], @"TA_Str");
    XCTAssertEqualObjects(property[@"ta_int"], @(123));
    XCTAssertEqualObjects(property[@"ta_bool"], @(false));
    XCTAssertEqualObjects(property[@"ta_date"], [formatter stringFromDate:date]);
    NSArray* resultPropArr = property[@"ta_jsonArr"];
    XCTAssertEqual(resultPropArr.count, 1);
    XCTAssertEqualObjects(resultPropArr[0], [formatter stringFromDate:date]);
}


/**
 * 验证用户属性数据是否完整
 */
- (void)assertUser:(NSDictionary*)data mock:(id)mock type:(NSString*)type
{
    XCTAssertEqualObjects(data[@"#type"], type);
    XCTAssertNotNil(data[@"#time"]);
    XCTAssertEqualObjects(data[@"#distinct_id"], [mock getDistinctId]);
    XCTAssertNil(data[@"#event_name"]);
    NSDictionary* properties = data[@"properties"];
    XCTAssertNotNil(properties);
    XCTAssertNotNil(data[@"#uuid"]);
    
    NSString* accountId = [mock accountId];
    if([mock accountId] != nil)
    {
        XCTAssertEqual(data.allKeys.count, SIZE_OF_USER_DATA_LOGIN);
        XCTAssertEqualObjects(data[@"#account_id"],[mock accountId]);
    }else
    {
        XCTAssertEqual(data.allKeys.count, SIZE_OF_USER_DATA);
    }
    XCTAssertFalse([properties.allKeys containsObject:@"#lib_version"]);
    XCTAssertFalse([properties.allKeys containsObject:@"#lib"]);
    XCTAssertFalse([properties.allKeys containsObject:@"#os"]);
    XCTAssertFalse([properties.allKeys containsObject:@"#app_version"]);
    XCTAssertFalse([properties.allKeys containsObject:@"#network_type"]);
    XCTAssertFalse([properties.allKeys containsObject:@"#app_version"]);
    XCTAssertFalse([properties.allKeys containsObject:@"#network_type"]);
    XCTAssertFalse([properties.allKeys containsObject:@"#device_id"]);
    XCTAssertFalse([properties.allKeys containsObject:@"#os_version"]);
    XCTAssertFalse([properties.allKeys containsObject:@"#carrier"]);
    XCTAssertFalse([properties.allKeys containsObject:@"#manufacturer"]);
    XCTAssertFalse([properties.allKeys containsObject:@"#device_model"]);
    XCTAssertFalse([properties.allKeys containsObject:@"#screen_height"]);
    XCTAssertFalse([properties.allKeys containsObject:@"#screen_width"]);
    XCTAssertFalse([properties.allKeys containsObject:@"#system_language"]);
    XCTAssertFalse([properties.allKeys containsObject:@"#zone_offset"]);
}
/*
 *用户属性API发送数据验证
 */
- (void)sendUserProperty:(id)mock properties:(NSDictionary*)properties
{
    [mock user_set:properties];
    [NSThread sleepForTimeInterval:WAIT_TIME];
    NSString *str = [self dicToStr:data];
    [self assertUser:data mock:mock type:@"user_set"];
    NSDictionary* properDic = data[@"properties"];
    XCTAssertEqual(properDic.allKeys.count,properties.allKeys.count);
    
    [mock user_setOnce:properties];
    [NSThread sleepForTimeInterval:WAIT_TIME];
    str = [self dicToStr:data];
    [self assertUser:data mock:mock type:@"user_setOnce"];
    properDic = data[@"properties"];
    XCTAssertEqual(properDic.allKeys.count,properties.allKeys.count);
    
    [mock user_add:properties];
    [NSThread sleepForTimeInterval:WAIT_TIME];
    [self assertUser:data mock:mock type:@"user_add"];
    str = [self dicToStr:data];
    properDic = data[@"properties"];
    XCTAssertEqual(properDic.allKeys.count,properties.allKeys.count);
    
    [mock user_unset:@"X"];
    [NSThread sleepForTimeInterval:WAIT_TIME];
    [self assertUser:data mock:mock type:@"user_unset"];
    str = [self dicToStr:data];
    properDic = data[@"properties"];
    XCTAssertEqual(properDic.allKeys.count,properties.allKeys.count+1);
    
    [mock user_delete];
    [NSThread sleepForTimeInterval:WAIT_TIME];
    str = [self dicToStr:data];
    NSLog(@"Data=%@",str);
    [self assertUser:data mock:mock type:@"user_del"];
    properDic = data[@"properties"];
    XCTAssertEqual(properDic.allKeys.count,properties.allKeys.count);
    
    [mock user_append:properties];
   
    [NSThread sleepForTimeInterval:WAIT_TIME];
     str = [self dicToStr:data];
    [self assertUser:data mock:mock type:@"user_append"];
    properDic = data[@"properties"];
    XCTAssertEqual(properDic.allKeys.count,properties.allKeys.count);
    
}
- (TDEventModel*)createEvent:(EventType)eventType date:(NSDate*)date eventID:(NSString*)eventID
{
    TDEventModel *event = nil;
    NSMutableDictionary* property= [NSMutableDictionary new];
    NSMutableArray* propertyArr = [NSMutableArray new];
    propertyArr[0] = date;
    property[@"ta_string"] = @"TA_Str";
    property[@"ta_int"] = @(123);
    property[@"ta_bool"]= @(false);
    property[@"ta_date"]= date;
    property[@"ta_jsonArr"] = propertyArr;
    switch (eventType) {
        case FIRST_EVENT:
            event = [[TDFirstEventModel alloc] initWithEventName:EVENT_NAME firstCheckID:eventID];
            break;
        case UPDATE_EVENT:
            event = [[TDUpdateEventModel alloc] initWithEventName:EVENT_NAME eventID:eventID];
            break;
        case OVERRIDE_EVENT:
            event = [[TDOverwriteEventModel alloc]initWithEventName:EVENT_NAME eventID:eventID];
            break;
        default:
            break;
    }
    [event setProperties:property];
    return event;
}


/**
 * 1.是否可以正确获取包名
 */
- (void)testPackage
{
    XCTAssertEqualObjects(TDDeviceInfo.bundleId, @"com.apple.dt.xctest.tool");
}
/**
 * 2.验证设备信息是否收集完整
 */
- (void)testDeviceInfo
{
   TDDeviceInfo *info = [TDDeviceInfo sharedManager];
   NSMutableDictionary* deviceInfo = [[info collectAutomaticProperties] mutableCopy];
//   [deviceInfo setObject:info.appVersion forKey:@"#app_version"];
   [deviceInfo setObject:@"WIFI" forKey:@"#network_type"];
   [self assertTrackDeviceInfo:deviceInfo];
}

/**
 * 3.验证Track事件发送的数据是否完整
 */
- (void)testTrackBasic
{
    //未登录
    [_mock track:EVENT_NAME];
    [NSThread sleepForTimeInterval:1];
    XCTAssertNotNil(data);
    [self assertDefaultTrackContent:data mock:_mock];
    
    //已登录
    [_mock login:@"123"];
    [_mock track:EVENT_NAME];
    [NSThread sleepForTimeInterval:1];
    XCTAssertNotNil(data);
    [self assertDefaultTrackContent:data mock:_mock];
    XCTAssertEqualObjects(data[@"#account_id"], @"123");

}
/*
 *4.验证用户属性上报的数据是否完整
 */
- (void)testUser
{
    NSDictionary* dic = [NSDictionary new];
    [self sendUserProperty:_mock properties:dic];
}
/**
 * 5.测试propertykey 是否有效
 */
- (void)testPropertyKey
{
    NSString *propertyKey = @"?";
    NSString *propertyKey1 = @"!";
    NSString *propertyKey2 = @"=";
    NSString *propertyKey3 = @"#";
    NSString *propertyKey4 = @"$";
    NSString *propertyKey5 = @"%";
    NSString *propertyKey6 = @"^";
    NSString *propertyKey7 = @"&";
    NSString *propertyKey8 = @"*";
    NSString *propertyKey9 = @"(";
    NSString *propertyKey10= @")";
    NSString *propertyKey11 = @"-";
    NSString *propertyKey12 = @"+";
    NSString *propertyKey13 = @"y_";
    NSString *propertyKey14 = @"_y";
    XCTAssertFalse([_mock isValidName:propertyKey isAutoTrack:false]);
    XCTAssertFalse([_mock isValidName:propertyKey1 isAutoTrack:false]);
    XCTAssertFalse([_mock isValidName:propertyKey2 isAutoTrack:false]);
    XCTAssertFalse([_mock isValidName:propertyKey3 isAutoTrack:false]);
    XCTAssertFalse([_mock isValidName:propertyKey4 isAutoTrack:false]);
    XCTAssertFalse([_mock isValidName:propertyKey5 isAutoTrack:false]);
    XCTAssertFalse([_mock isValidName:propertyKey6 isAutoTrack:false]);
    XCTAssertFalse([_mock isValidName:propertyKey7 isAutoTrack:false]);
    XCTAssertFalse([_mock isValidName:propertyKey8 isAutoTrack:false]);
    XCTAssertFalse([_mock isValidName:propertyKey9 isAutoTrack:false]);
    XCTAssertFalse([_mock isValidName:propertyKey10 isAutoTrack:false]);
    XCTAssertFalse([_mock isValidName:propertyKey11 isAutoTrack:false]);
    XCTAssertFalse([_mock isValidName:propertyKey12 isAutoTrack:false]);
    XCTAssertTrue([_mock isValidName:propertyKey13 isAutoTrack:false]);
    XCTAssertFalse([_mock isValidName:propertyKey14 isAutoTrack:false]);
}
/**
 * 6.测试propertyValue是否合法
 */
- (void)testPropertyValue
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    NSMutableArray *arr = [NSMutableArray array];
    dic[@"a"] = @"a";
    dic[@"b"] = @(100);
    dic[@"c"] = [NSDate new];
    dic[@"d"] = arr;
    dic[@"e"] = @(true);
    XCTAssertTrue([_mock checkEventProperties:dic withEventType:@"track" haveAutoTrackEvents:false]);
    
    dic[@"f"] = [NSDictionary dictionary];
    XCTAssertFalse([_mock checkEventProperties:dic withEventType:@"track" haveAutoTrackEvents:false]);
}
/***
 *7.Track事件自定义合法属性是否采集成功
 */
- (void)testTrackWithLegalProperties
{
    NSDateFormatter *formate = [NSDateFormatter new];
    formate.dateFormat = kDefaultTimeFormat;
    NSDate *date = [NSDate new];
    NSMutableDictionary *property = [NSMutableDictionary new];
    NSMutableArray*propertyArr = [NSMutableArray new];
    propertyArr[0] = date;
    property[@"ta_string"] = @"TA_Str";
    property[@"ta_int"] = @(123);
    property[@"ta_bool"] = @(false);
    property[@"ta_date"] = date;
    property[@"ta_jsonArr"] = propertyArr;
    [_mock track:EVENT_NAME properties:property];
    [NSThread sleepForTimeInterval:WAIT_TIME];
    [self assertDefaultTrackContent:data mock:_mock];
    NSDictionary *resultPro = data[@"properties"];
    XCTAssertEqualObjects(resultPro[@"ta_string"], @"TA_Str");
    XCTAssertEqualObjects(resultPro[@"ta_int"], @(123));
    XCTAssertEqualObjects(resultPro[@"ta_bool"], @(false));
    XCTAssertEqualObjects(resultPro[@"ta_date"],[formate stringFromDate:date]);
    NSArray* arr = resultPro[@"ta_jsonArr"];
    XCTAssertEqual(arr.count, 1);
    XCTAssertEqualObjects(arr[0],[formate stringFromDate:date]);
}
/***
 *8.Track事件自定义非法属性是否采集成功
 * 非法属性会上报成功,客户端会有日志提示属性设置错误
 */
- (void)testTrackWithIllegalProperties
{
    NSMutableDictionary* property = [NSMutableDictionary new];
    property[@"_ta_string"]=@"TA_Str";
    [data removeAllObjects];
    [_mock track:EVENT_NAME properties:property];
    [NSThread sleepForTimeInterval:WAIT_TIME];
    XCTAssertTrue(data.allKeys.count>0);
}
/**
 * 9验证设置公共属性方法是否有效
 * 设置公共属性,测试track事件的数据中是否包含公共属性
 * */
- (void)testTrackWithSuperProperties
{
    NSMutableDictionary* superProperties = [NSMutableDictionary new];
    NSDate* date = [NSDate new];
    superProperties[@"SUPER_KEY_STRING"] = @"super string value";
    superProperties[@"SUPER_KEY_DATE"]   = date;
    superProperties[@"SUPER_KEY_INT"]    = @(0);
    superProperties[@"SUPER_KEY_BOOLEAN"]= @(false);
    [_mock setSuperProperty:superProperties];
    NSDateFormatter *formate = [NSDateFormatter new];
    formate.dateFormat = kDefaultTimeFormat;
    [_mock track:EVENT_NAME];
    [NSThread sleepForTimeInterval:WAIT_TIME];
    [self assertDefaultTrackContent:data mock:_mock];
    NSDictionary* property = data[@"properties"];
    XCTAssertEqualObjects(property[@"SUPER_KEY_STRING"],@"super string value");
    XCTAssertEqualObjects(property[@"SUPER_KEY_INT"],@(0));
    XCTAssertEqualObjects(property[@"SUPER_KEY_DATE"],[formate stringFromDate:date]);
    XCTAssertEqualObjects(property[@"SUPER_KEY_BOOLEAN"],@(false));
    [_mock clearSuperProperties];
}

/**
 * 10.验证清空公共属性方法是否有效
 */
- (void)testClearSupperProperties
{
    NSMutableDictionary* superProperties = [NSMutableDictionary new];
    NSDate* date = [NSDate new];
    superProperties[@"SUPER_KEY_STRING"] = @"super string value";
    superProperties[@"SUPER_KEY_DATE"]   = date;
    superProperties[@"SUPER_KEY_INT"]    = @(0);
    superProperties[@"SUPER_KEY_BOOLEAN"]= @(false);
    [_mock setSuperProperty:superProperties];
    [_mock clearSuperProperties];
    [_mock track:EVENT_NAME];
    [NSThread sleepForTimeInterval:WAIT_TIME];
    [self assertDefaultTrackContent:data mock:_mock];
    NSDictionary* property = data[@"properties"];
    XCTAssertTrue(property[@"SUPER_KEY_STRING"] == nil);
    XCTAssertTrue(property[@"SUPER_KEY_INT"] == nil);
    XCTAssertTrue(property[@"SUPER_KEY_DATE"] == nil);
    XCTAssertTrue(property[@"SUPER_KEY_BOOLEAN"] == nil);
}
/**
 * 11.验证多次设置公共属性,相同属性是否会被覆盖,不同属性是否累加
 * */
- (void)testTrackWithSameSuperPropertyKey
{
    NSMutableDictionary* superProperties = [NSMutableDictionary new];
    superProperties[@"SUPER_KEY_STRING"] = @"super string new";
    [_mock setSuperProperty:superProperties];
    [_mock track:EVENT_NAME];
    [NSThread sleepForTimeInterval:WAIT_TIME];
    [self assertDefaultTrackContent:data mock:_mock];
    NSDictionary* properties = data[@"properties"];
    XCTAssertEqualObjects(properties[@"SUPER_KEY_STRING"],@"super string new");
    
    NSMutableDictionary* superProperties1 = [NSMutableDictionary new];
    superProperties1[@"SUPER_KEY_STRING"] = @"super string update";
    superProperties1[@"SUPER_KEY_XX"] = @"SUPER_X";
    [_mock setSuperProperty:superProperties1];
    [_mock track:EVENT_NAME];
    [NSThread sleepForTimeInterval:WAIT_TIME];
    [self assertDefaultTrackContent:data mock:_mock];
    properties = data[@"properties"];
    XCTAssertEqualObjects(properties[@"SUPER_KEY_STRING"],@"super string update");
    XCTAssertEqualObjects(properties[@"SUPER_KEY_XX"],@"SUPER_X");
}
/**
 * 12.设置公共属性且自定义属性中包含公共属性的部分Key,验证属性的Value是否会被自定义属性覆盖
 *
 * */
- (void)testTrackWithSamePropertyKey
{
    NSDictionary* superProperties = @{@"SUPER_KEY_STRING":@"super string new"};
    [_mock setSuperProperty:superProperties];
    // test setSuperProperties with same key as event properties
    NSDictionary* properties = @{@"SUPER_KEY_STRING":@"super key in event property"};
    [_mock track:EVENT_NAME properties:properties];
    [NSThread sleepForTimeInterval:WAIT_TIME];
    [self assertDefaultTrackContent:data mock:_mock];
    NSDictionary* pro = data[@"properties"];
    XCTAssertEqualObjects(pro[@"SUPER_KEY_STRING"], @"super key in event property");
    [_mock clearSuperProperties];
}
/***
 * 13 验证清空部分公共属性方法是否有有效
 */
- (void) testUnsetSuperProperties {
    NSDictionary* superProperties = @{
                                      @"SUPER_KEY_STRING":@"super string new",
                                      @"SUPER_KEY_XX":@"SUPER_XX"
                                      };
    [_mock setSuperProperty:superProperties];
    [_mock unsetSuperProperty:@"SUPER_KEY_STRING"];
    [_mock track:EVENT_NAME];
    [NSThread sleepForTimeInterval:WAIT_TIME];
    [self assertDefaultTrackContent:data mock:_mock];
    NSDictionary* pro = data[@"properties"];
    XCTAssertNil(pro[@"SUPER_KEY_STRING"]);
    XCTAssertEqualObjects(pro[@"SUPER_KEY_XX"], @"SUPER_XX");
    XCTAssertEqual(pro.allKeys.count, SIZE_OF_SYSTEM_PROPERTY + 1);
    [_mock clearSuperProperties];
}
/***
 * 14.验证动态公共属性方法是否有效
 */
- (void)testDynamicProperties
{
    __block int i =0;
    [_mock setDynamicSuperProperties:^NSDictionary<NSString *,id> * _Nonnull{
        return @{@"num":@(++i)};
    }];
    [_mock track:EVENT_NAME];
    [NSThread sleepForTimeInterval:WAIT_TIME];
    NSDictionary* pro = data[@"properties"];
    XCTAssertEqual(pro.allKeys.count, SIZE_OF_SYSTEM_PROPERTY + 1);
    XCTAssertEqualObjects(pro[@"num"], @(1));
    [_mock clearSuperProperties];
    [_mock setDynamicSuperProperties:^NSDictionary<NSString *,id> * _Nonnull{
        return @{};
    }];
}
/***
 * 15 设置动态公共属性和公共属性,验证用户属性上报是否包含公共属性和设备信息
 */
- (void)testUserSuperProperties
{
    NSDictionary *superProperties = @{@"SUPER_KEY_STRING":@"super string new"};
    [_mock setSuperProperty:superProperties];
    __block int i =0;
    [_mock setDynamicSuperProperties:^NSDictionary<NSString *,id> * _Nonnull{
        return @{@"num":@(++i)};
    }];
    [self sendUserProperty:_mock properties:@{}];
    [_mock clearSuperProperties];
}
/**
 *16.验证访客ID设置是否有效
 */
- (void)testDistinctId
{
    NSString* distinctId = [_mock getDistinctId];
    XCTAssertNotNil(distinctId);
    NSString* distinctId1 = @"TA_001";
    [_mock identify:distinctId1];
    XCTAssertEqualObjects([_mock getDistinctId], distinctId1);
    [_mock track:EVENT_NAME];
    [NSThread sleepForTimeInterval:WAIT_TIME];
    [self assertDefaultTrackContent:data mock:_mock];
    XCTAssertEqualObjects(data[@"#distinct_id"], distinctId1);
}
/**
 *17 验证设置账号ID方法是否有效
 */
- (void)testLogin
{
    NSString* accountId = @"TA_001";
    [_mock login:accountId];
    [_mock track:EVENT_NAME];
    [NSThread sleepForTimeInterval:WAIT_TIME];
    [self assertDefaultTrackContent:data mock:_mock];
    XCTAssertEqual(data[@"#account_id"], accountId);
}
/**
 *18 验证清除账号ID方法是否有效
 */
- (void)testLogout
{
    NSString* accountId = @"TA_001";
    [_mock login:accountId];
    [_mock logout];
    [_mock track:EVENT_NAME];
    [NSThread sleepForTimeInterval:WAIT_TIME];
    [self assertDefaultTrackContent:data mock:_mock];
    XCTAssertNil(data[@"#account_id"]);
}
- (NSString*)dicToStr:(NSDictionary*)dic
{
    NSError *parseError;
    NSDictionary *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    if (parseError) {
        //解析出错
    }
    NSString * str = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return str;
}
/**
 * 19 验证首次事件上报数据是否正确
 */
- (void)testUniqueEvent
{
    NSDate *date = [NSDate new];
    TDEventModel *firstEvent = [self createEvent:FIRST_EVENT date:date eventID:@"ABC"];
    [_mock trackWithEventModel:firstEvent];
    [NSThread sleepForTimeInterval:WAIT_TIME];
    
    [self assertDefaultTrackContent:data mock:_mock length:SIZE_OF_EVENT_DATA+1];
    [self assertTrackProperty:data instance:_mock date:date];
    XCTAssertEqualObjects(data[@"#event_name"], EVENT_NAME);
    XCTAssertEqualObjects(data[@"#first_check_id"], @"ABC");
    
    
    TDEventModel *firstEvent1 = [self createEvent:FIRST_EVENT date:date eventID:nil];
    [_mock trackWithEventModel:firstEvent1];
    [NSThread sleepForTimeInterval:WAIT_TIME];
    [self assertDefaultTrackContent:data mock:_mock length:SIZE_OF_EVENT_DATA+1];
    [self assertTrackProperty:data instance:_mock date:date];
    XCTAssertEqualObjects(data[@"#event_name"], EVENT_NAME);
    XCTAssertEqualObjects(data[@"#first_check_id"], [_mock getDeviceId]);
    
    
    TDEventModel *firstEvent2 = [self createEvent:FIRST_EVENT date:date eventID:@""];
    [_mock trackWithEventModel:firstEvent2];
    [NSThread sleepForTimeInterval:WAIT_TIME];
    [self assertDefaultTrackContent:data mock:_mock length:SIZE_OF_EVENT_DATA+1];
    [self assertTrackProperty:data instance:_mock date:date];
    XCTAssertEqualObjects(data[@"#event_name"], EVENT_NAME);
    XCTAssertEqualObjects(data[@"#first_check_id"], [_mock getDeviceId]);
    
    
}
/**
 * 20 验证可重写事件上报是否正确
 */
- (void)testOverWritableEvent
{
    NSDate *date = [NSDate new];
    TDEventModel *overWritableEvent = [self createEvent:OVERRIDE_EVENT date:date eventID:@"1213"];
    [_mock trackWithEventModel:overWritableEvent];
    [NSThread sleepForTimeInterval:WAIT_TIME];
    NSLog(@"Data=%@",[self dicToStr:data]);
    [self assertDefaultTrackContent:data mock:_mock length:SIZE_OF_EVENT_DATA+1];
    [self assertTrackProperty:data instance:_mock date:date];
    XCTAssertEqualObjects(data[@"#type"], @"track_overwrite");
    XCTAssertEqualObjects(data[@"#event_name"], EVENT_NAME);
    XCTAssertNotNil(data[@"#event_id"]);
    [self assertTrackProperty:data instance:_mock date:date];
    
    
    TDEventModel *overWritableEvent1 = [self createEvent:OVERRIDE_EVENT date:date eventID:@"123"];
    [_mock trackWithEventModel:overWritableEvent1];
    [NSThread sleepForTimeInterval:WAIT_TIME];
    [self assertDefaultTrackContent:data mock:_mock length:SIZE_OF_EVENT_DATA+1];
    [self assertTrackProperty:data instance:_mock date:date];
    XCTAssertEqualObjects(data[@"#type"], @"track_overwrite");
    XCTAssertEqualObjects(data[@"#event_name"], EVENT_NAME);
    XCTAssertEqualObjects(data[@"#event_id"],@"123");
    [self assertTrackProperty:data instance:_mock date:date];
    
}


/**
 * 21 验证可更新事件上报是否正确
 */
- (void)testUpdatableEvent
{
    NSDate *date = [NSDate new];
    TDEventModel *overWritableEvent = [self createEvent:UPDATE_EVENT date:date eventID:@"XXYY"];
    [_mock trackWithEventModel:overWritableEvent];
    [NSThread sleepForTimeInterval:WAIT_TIME];
   NSLog(@"Data=%@",[self dicToStr:data]);
    [self assertDefaultTrackContent:data mock:_mock length:SIZE_OF_EVENT_DATA+1];
    [self assertTrackProperty:data instance:_mock date:date];
    XCTAssertEqualObjects(data[@"#type"], @"track_update");
    XCTAssertEqualObjects(data[@"#event_name"], EVENT_NAME);
    XCTAssertNotNil(data[@"#event_id"]);
    [self assertTrackProperty:data instance:_mock date:date];
    
    
    TDEventModel *overWritableEvent1 = [self createEvent:UPDATE_EVENT date:date eventID:@"123"];
    [_mock trackWithEventModel:overWritableEvent1];
    [NSThread sleepForTimeInterval:WAIT_TIME];
    [self assertDefaultTrackContent:data mock:_mock length:SIZE_OF_EVENT_DATA+1];
    [self assertTrackProperty:data instance:_mock date:date];
    XCTAssertEqualObjects(data[@"#type"], @"track_update");
    XCTAssertEqualObjects(data[@"#event_name"], EVENT_NAME);
    XCTAssertEqualObjects(data[@"#event_id"],@"123");
    [self assertTrackProperty:data instance:_mock date:date];
    
}
/**
 * 22.验证时区偏移是否正确
 */
- (void)testZoneOffset
{
    
    NSTimeZone *tz= [[NSTimeZone alloc] initWithName:@"America/Los_Angeles"];
    NSDate *date = [NSDate new];
    [_mock track:EVENT_NAME properties:@{} time:date timeZone:tz];
    [NSThread sleepForTimeInterval:WAIT_TIME];
    [self assertDefaultTrackContent:data mock:_mock];
    XCTAssertEqualObjects(data[@"properties"][@"#zone_offset"],@([_mock getTimezoneOffset:date timeZone:tz]));
    
    TDConfig *config= [TDConfig new];
    config.appid = TA_APP_ID;
    config.configureURL = TA_SERVER_URL;
    config.defaultTimeZone = tz;
    ThinkingAnalyticsSDK *instance = [ThinkingAnalyticsSDK new];
    id mock = OCMPartialMock(instance);
    OCMStub([mock saveEventsData:[OCMArg any]]).andDo(_handle);
    [mock track:EVENT_NAME properties:@{} time:date timeZone:tz];
    [NSThread sleepForTimeInterval:WAIT_TIME];
    [self assertDefaultTrackContent:data mock:_mock];
    XCTAssertEqualObjects(data[@"properties"][@"#zone_offset"],@([mock getTimezoneOffset:date timeZone:tz]));
}
/**
 * 23.事件上报只传入时间,不传入时区,判断时区偏移是否存在
 */
- (void)testTrackWithTime
{
    NSDate *date = [NSDate new];
    [_mock track:EVENT_NAME properties:@{} time:date timeZone:nil];
    [NSThread sleepForTimeInterval:WAIT_TIME];
    [self assertDefaultTrackContent:data mock:_mock];
    XCTAssertNil(data[@"properties"][@"#zone_offset"]);
}

/**
 * 24 验证时间戳校准
 */
- (void)testCalibrateTime
{
    NSTimeInterval time = 1554687000000;
    [ThinkingAnalyticsSDK calibrateTime:time];
    
}
- (void)assertTime:(id)mock time:(NSTimeInterval)timeInterval
{
    int DEFAULT_INTERVAL = 1;
    NSDateFormatter *formater = [NSDateFormatter new];
    formater.dateFormat = kDefaultTimeFormat;
    
    [_mock track:EVENT_NAME];
    [NSThread sleepForTimeInterval:WAIT_TIME];
    NSString* timeStr = data[@"#time"];
    NSDate *eventDate = [formater dateFromString:timeStr];
    XCTAssertTrue((eventDate.timeIntervalSince1970 - timeInterval)<(WAIT_TIME+DEFAULT_INTERVAL));
    
    [_mock user_set:@{}];
    [NSThread sleepForTimeInterval:WAIT_TIME];
    timeStr = data[@"#time"];
    eventDate = [formater dateFromString:timeStr];
    XCTAssertTrue((eventDate.timeIntervalSince1970 - timeInterval)< 2* (WAIT_TIME+DEFAULT_INTERVAL));
    
    [_mock user_setOnce:@{}];
    [NSThread sleepForTimeInterval:WAIT_TIME];
    timeStr = data[@"#time"];
    eventDate = [formater dateFromString:timeStr];
    XCTAssertTrue((eventDate.timeIntervalSince1970 - timeInterval)<3 *(WAIT_TIME+DEFAULT_INTERVAL));
    
    [_mock user_add:@{}];
    [NSThread sleepForTimeInterval:WAIT_TIME];
    timeStr = data[@"#time"];
    eventDate = [formater dateFromString:timeStr];
    XCTAssertTrue((eventDate.timeIntervalSince1970 - timeInterval)<4 *(WAIT_TIME+DEFAULT_INTERVAL));
    
    [_mock user_append:@{}];
    [NSThread sleepForTimeInterval:WAIT_TIME];
    timeStr = data[@"#time"];
    eventDate = [formater dateFromString:timeStr];
    XCTAssertTrue((eventDate.timeIntervalSince1970 - timeInterval)<5 *(WAIT_TIME+DEFAULT_INTERVAL));
    
    [_mock user_unset:@"A"];
    [NSThread sleepForTimeInterval:WAIT_TIME];
    timeStr = data[@"#time"];
    eventDate = [formater dateFromString:timeStr];
    XCTAssertTrue((eventDate.timeIntervalSince1970 - timeInterval)<6 *(WAIT_TIME+DEFAULT_INTERVAL));
    
    [_mock user_delete];
    [NSThread sleepForTimeInterval:WAIT_TIME];
    timeStr = data[@"#time"];
    eventDate = [formater dateFromString:timeStr];
    XCTAssertTrue((eventDate.timeIntervalSince1970 - timeInterval)<7 *(WAIT_TIME+DEFAULT_INTERVAL));
    
}
/**
 * 25 验证暂停,恢复数据上报方法是否有效
 */
- (void)testEnableTracking
{
//    .enableTracking(false);
    [data removeAllObjects];
    [_mock enableTracking:false];
    [_mock track:EVENT_NAME];
    [NSThread sleepForTimeInterval:WAIT_TIME];
    XCTAssertTrue(data.allKeys.count == 0);
    [_mock enableTracking:true];
    [_mock track:EVENT_NAME];
    [NSThread sleepForTimeInterval:WAIT_TIME];
    XCTAssertTrue(data.allKeys.count > 0);
}

/**
 * 26 验证开始,停止数据上报方法是否有效
 */
- (void)testOptOutIn
{
    [data removeAllObjects];
    [_mock identify:@"XXX"];
    [_mock login:@"YYY"];
    [_mock optOutTracking];
    [_mock track:EVENT_NAME];
    [NSThread sleepForTimeInterval:WAIT_TIME];
    XCTAssertTrue(data.allKeys.count == 0);
    XCTAssertNil([_mock accountId]);
    XCTAssertEqualObjects([_mock getDistinctId],[_mock getDeviceId]);
    [_mock optInTracking];
    [_mock track:EVENT_NAME];
    [NSThread sleepForTimeInterval:WAIT_TIME];
    XCTAssertTrue(data.allKeys.count > 0);
}
/**
 * 27 验证统计事件时长功能是否有效
 */
- (void)testTimeEvent
{
    [_mock timeEvent:EVENT_NAME];
    [NSThread sleepForTimeInterval:3.0];
    [_mock track:EVENT_NAME];
    [NSThread sleepForTimeInterval:WAIT_TIME];
    NSDictionary* property = data[@"properties"];
    double duration = [property[@"#duration"] doubleValue];
    XCTAssertTrue(abs(duration-3) < 1.0);
}

/**
 * 28.验证上报间隔设置是否有效 to-do
 */
//- (void)testFlushInterval
//{
//    TDConfig *config = [TDConfig new];
//    id configMock = OCMPartialMock(config);
//    ThinkingAnalyticsSDK *instance;
//    MHandle configHandle = ^(NSInvocation *invocation) {
//        [configMock setUploadInterval:@(3)];
//        [[ThinkingAnalyticsSDK sharedInstanceWithAppid:TA_APP_ID1] startFlushTimer];
//        NSLog(@"OK");
//    };
//    OCMStub([configMock updateConfig]).andDo(configHandle);
//    OCMStub([configMock copy]).andReturn(configMock);
////    OCMStub([configMock retrievePersistedData]).andDo(configHandle);
//    instance = [ThinkingAnalyticsSDK startWithAppId:TA_APP_ID1 withUrl:TA_SERVER_URL withConfig:configMock];
//    TDNetwork *network = [TDNetwork new];
//    id mockNetWork = OCMPartialMock(network);
//    NSArray *result;
//    MHandle handle = ^(NSInvocation *invocation) {
//        [invocation getArgument:&result atIndex:2];
////        [data addEntriesFromDictionary:dic];
//        NSLog(@"OK");
//    };
//    OCMStub([mockNetWork flushEvents:[OCMArg any]]).andDo(handle);
//    [instance setValue:mockNetWork forKey:@"network"];
//    [instance track:EVENT_NAME];
//
//}
/**
 * 29.验证数据条数上限设置是否有效
 */
- (void)testFlushBulkSize
{
    TDConfig *config = [TDConfig new];
    id configMock = OCMPartialMock(config);
    MHandle configHandle = ^(NSInvocation *invocation) {
        [configMock setUploadSize:@(FLUSH_BULK_SIZE)];
        NSLog(@"OK");
    };
    OCMStub([configMock updateConfig]).andDo(configHandle);
    OCMStub([configMock copy]).andReturn(configMock);
    
    ThinkingAnalyticsSDK *instance = [ThinkingAnalyticsSDK startWithAppId:TA_APP_ID1 withUrl:TA_SERVER_URL withConfig:configMock];
    TDNetwork *network = [TDNetwork new];
    id mockNetWork = OCMPartialMock(network);
    MHandle handle = ^(NSInvocation *invocation) {
        NSArray* array;
        [data removeAllObjects];
        [invocation getArgument:&array atIndex:2];
        NSArray* subArr = [array subarrayWithRange:NSMakeRange(0,FLUSH_BULK_SIZE)];
        for(int i=0;i < FLUSH_BULK_SIZE ; i++){
            NSDictionary* event = subArr[i];
            NSString* eventName = [NSString stringWithFormat:@"test_flush_bulk%i",i];
            XCTAssertEqualObjects(event[@"#event_name"],eventName);
            [self assertDefaultTrackContent:event mock:instance];
            [instance.dataQueue deleteAll:TA_APP_ID1];
        }
    };
    OCMStub([mockNetWork flushEvents:[OCMArg any]]).andDo(handle).andReturn(true);
    [instance setValue:mockNetWork forKey:@"network"];
    for(int i = 0; i < FLUSH_BULK_SIZE; i++) {
        [instance track:[NSString stringWithFormat:@"test_flush_bulk%i",i]];
    }
}
/**
 * 30.多实例测试
 */
- (void)testTrackMultiAppid
{
    NSString* appid = @"123";
    NSString* appid1 = @"234";
    ThinkingAnalyticsSDK *instance = [ThinkingAnalyticsSDK startWithAppId:appid withUrl:TA_SERVER_URL];
    ThinkingAnalyticsSDK *instance1 = [ThinkingAnalyticsSDK startWithAppId:appid1 withUrl:TA_SERVER_URL];
    [data removeAllObjects];
    id mock = OCMPartialMock(instance);
    id mock1= OCMPartialMock(instance1);
    __block int i =0;
    MHandle handle = ^(NSInvocation *invocation) {
        NSDictionary *dic;
        [invocation getArgument:&dic atIndex:2];
        XCTAssertEqualObjects(dic[@"#account_id"],@"123");
        XCTAssertEqualObjects(dic[@"#distinct_id"],@"xxyy");
        [self assertDefaultTrackContent:dic mock:instance];
    };
    MHandle handle1 = ^(NSInvocation *invocation) {
        NSDictionary *dic;
        [invocation getArgument:&dic atIndex:2];
        XCTAssertEqualObjects(dic[@"#account_id"],@"234");
        XCTAssertEqualObjects(dic[@"#distinct_id"],@"qqww");
        [self assertDefaultTrackContent:dic mock:instance1];
    };
    OCMStub([mock saveEventsData:[OCMArg any]]).andDo(handle);
    OCMStub([mock1 saveEventsData:[OCMArg any]]).andDo(handle1);
    [mock login:@"123"];
    [mock identify:@"xxyy"];
    [mock1 login:@"234"];
    [mock1 identify:@"qqww"];
    [mock track:EVENT_NAME];
    [mock1 track:EVENT_NAME];
    [mock flush];
    [mock1 flush];
}
/**
 * 31.使用已有实例生成轻实例测试
 */

- (void) testLightInstance
{
    NSDictionary* property = @{@"TA":@"XX"};
    [_mock setSuperProperty:property];
    ThinkingAnalyticsSDK *lightInstance = [_mock createLightInstance];
    XCTAssertEqualObjects([lightInstance getDistinctId],[lightInstance getDeviceId]);
    XCTAssertEqualObjects([lightInstance appid],[_mock appid]);
    XCTAssertEqualObjects([lightInstance serverURL],[_mock serverURL]);
    XCTAssertTrue([lightInstance superProperty].count == 0);
    
    [_mock identify:@"XXYY"];
    [_mock login:@"TA_001"];
    [_mock setSuperProperty:@{@"TA":@"XX"}];
    lightInstance = [_mock createLightInstance];
    XCTAssertEqualObjects([lightInstance getDistinctId],[lightInstance getDeviceId]);
    XCTAssertNotEqualObjects([lightInstance getDistinctId],[_mock getDistinctId]);
    XCTAssertTrue([lightInstance accountId] == nil);
    XCTAssertEqualObjects([lightInstance appid],[_mock appid]);
    XCTAssertEqualObjects([lightInstance serverURL],[_mock serverURL]);
    XCTAssertTrue([lightInstance superProperty].count == 0);
    
    [_mock clearSuperProperties];
}
/**
 * 32.轻实例上报数据测试
 */
- (void)testLightInstanceSendData
{
    NSDictionary* property = @{@"TA":@"XX"};
    [_mock setSuperProperty:property];
    ThinkingAnalyticsSDK *lightInstance = [_mock createLightInstance];
    _lightMock= OCMPartialMock(lightInstance);
    MHandle handle = ^(NSInvocation *invocation) {
        NSDictionary *dic;
        [data removeAllObjects];
        [invocation getArgument:&dic atIndex:2];
        [data addEntriesFromDictionary:dic];
        NSLog(@"OK");
    };
    OCMStub([_lightMock saveEventsData:[OCMArg any]]).andDo(handle);
    [NSThread sleepForTimeInterval:WAIT_TIME];
    [self sendUserProperty:_lightMock properties:@{}];
    [_lightMock track:EVENT_NAME];
    [NSThread sleepForTimeInterval:WAIT_TIME];
    [self assertDefaultTrackContent:data mock:_lightMock];
    
    [_mock clearSuperProperties];
    
}



@end
