//
//  TEST_Model.h
//  ThinkingSDKDEMOUITests
//
//  Created by wwango on 2021/12/11.
//  Copyright © 2021 thinking. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class TEST_Input_Model, ThinkingAnalyticsSDK;

@interface TEST_Model : NSObject

@property NSInteger plan;
@property NSInteger platform;
@property NSString *platform_description;
@property NSInteger type;
@property NSInteger target;
@property NSString *target_description;
@property NSString *idd;
@property NSString *name;
@property TEST_Input_Model *input;
@property NSString *output;
@property NSString *step;
@property NSString *expect;
@property NSString *descriptionn;
@property NSString *sdk_version;
@property BOOL result;



+ (NSArray *)getTestDatas:(NSString *)jsonName;

@end



@interface TEST_Input_Model : NSObject

@property NSString *appid;
@property NSString *distinctid;
@property NSString *accountid;
@property NSString *serverURL;
@property NSString *instanceName;
@property NSString *eventName;
@property NSDictionary *proprties;
@property NSString *firstCheckID;
@property NSString *eventID;
@property double duration;
@property NSString *distinctId;
@property NSString *accountId;
@property NSDictionary *superProperties;
@property NSString *removesuperkey;
@property NSDictionary * superdyldProperties;
@property NSString *networkType;
@property int ableNetworkType;
@property NSString *timeZone;
@property NSTimeInterval time;
@property NSString * timestring;
@property int zone_offset;
@property BOOL enable;
@property BOOL optOut;
@property NSTimeInterval timestamp;
@property NSDictionary * userSetProperties;
@property NSString *type;
@property NSString *removeUserSetkey;
@property NSDictionary *onceEventProperties;
@property NSDictionary *userAddProperties;
@property NSDictionary *userAppendProperties;

@end


NS_ASSUME_NONNULL_END
