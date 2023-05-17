//
//  TEST_Helper.m
//  ThinkingSDKDEMOUITests
//
//  Created by wwango on 2021/12/11.
//  Copyright © 2021 thinking. All rights reserved.
//

#import "TEST_Helper.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"

@implementation TEST_Helper


+ (void)dispatchQueue:(dispatch_block_t)block {
    dispatch_queue_t queue = [ThinkingAnalyticsSDK performSelector:@selector(td_trackQueue)];
    dispatch_async(queue, block);
}



+ (void)checkInstance:(ThinkingAnalyticsSDK *)ins
                input:(TEST_Input_Model *)input
           hasInsName:(BOOL)hasInsName
               result:(void(^)(BOOL result))result {
    [self _checkInstance:ins input:input hasInsName:hasInsName sync:NO result:result];
}

+ (void)syncCheckInstance:(ThinkingAnalyticsSDK *)ins
                    input:(TEST_Input_Model *)input
               hasInsName:(BOOL)hasInsName
                   result:(void(^)(BOOL result))result {
    [self _checkInstance:ins input:input hasInsName:hasInsName sync:YES result:result];
}


+ (void)_checkInstance:(ThinkingAnalyticsSDK *)ins
                 input:(TEST_Input_Model *)input
            hasInsName:(BOOL)hasInsName
                  sync:(BOOL)sync
                result:(void(^)(BOOL result))result
{
    
    NSString *insName = input.instanceName;
    NSString *distinctId = input.distinctid;
    NSString *accountId = input.accountid;
    NSString *appid = input.appid;
    NSString *serverURL = input.serverURL;
    NSDictionary *superProperty = input.superProperties;
    BOOL enable = input.enable;
    
    __block NSString *appid1 = [self td_trim:appid];
    dispatch_block_t action = ^{
        if (!ins) {
            result(NO);
        }
        
        // instance
        NSString *ins_appid = (NSString *)[ins valueForKey:@"appid"];
        if (![ins_appid isEqualToString:appid1]) {
            result(NO);
        }
        
        NSString *ins_serverURL = (NSString *)[ins valueForKey:@"serverURL"];
        if (![ins_serverURL isEqualToString:serverURL]) {
            result(NO);
        }
        
        NSString *ins_distinctId = (NSString *)[ins valueForKey:@"identifyId"];
        if (![ins_distinctId isEqualToString:distinctId]) {
            result(NO);
        }
        
        NSString *ins_get_distinctId = (NSString *)[ins getDistinctId];
        if (![ins_get_distinctId isEqualToString:distinctId]) {
            result(NO);
        }
        
        NSString *ins_accountId = (NSString *)[ins valueForKey:@"accountId"];
        if (accountId == nil && ins_accountId == nil) {
            
        } else if (![ins_accountId isEqualToString:accountId]) {
            result(NO);
        }
        
        // file
        id file = [ins valueForKey:@"file"];
        
        //        NSString *file_desc = [file performSelector:@selector(description)];
        
        if (!file) {
            result(NO);
        }
        
        if (hasInsName) {
            NSString *file_insName = [file performSelector:@selector(appid)];
            if (![file_insName isEqualToString:insName]) {
                result(NO);
            }
        } else {
            NSString *file_appid = [file performSelector:@selector(appid)];
            if (![file_appid isEqualToString:appid1]) {
                result(NO);
            }
        }
        
        NSString *file_distincid = [file performSelector:@selector(unarchiveIdentifyID)];
        if (![file_distincid isEqualToString:distinctId]) {
            result(NO);
        }
        
        NSString *file_accountid = [file performSelector:@selector(unarchiveAccountID)];
        if (file_accountid == nil && accountId == nil) {
            
        } else if (![file_accountid isEqualToString:accountId]) {
            result(NO);
        }
        
//        NSDictionary *file_SuperProperties = [file performSelector:@selector(unarchiveSuperProperties)];
//        if (file_SuperProperties == nil && superProperty == nil) {
//            
//        } else if (![file_SuperProperties isEqualToDictionary:superProperty]) {
//            result(NO);
//        }
        
        
        SEL selector = NSSelectorFromString(@"unarchiveEnabled");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:
                                    [[file class] instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:file];
        [invocation invoke];
        BOOL file_enable;
        [invocation getReturnValue:&file_enable];
        
        if (file_enable != enable) {
            result(NO);
        }
        
        result(YES);
    };
    
    if (sync) {
        action();
    } else {
        [TEST_Helper dispatchQueue:action];
    }
}


+ (BOOL)checkPresentProperties:(NSDictionary *)properties
{
    NSMutableArray *allkeys = [NSMutableArray arrayWithArray:properties.allKeys];
    NSMutableArray *allProperties = [NSMutableArray arrayWithArray:@[@"#lib",
                                                                     @"#lib_version",
                                                                     @"#system_language",
                                                                     @"#zone_offset",
                                                                     @"#device_id",
                                                                     @"#app_version",
                                                                     @"#os",
                                                                     @"#screen_width",
                                                                     @"#network_type",
                                                                     @"#bundle_id",
                                                                     @"#screen_height",
                                                                     @"#manufacturer",
                                                                     @"#os_version",
                                                                     @"#disk",
                                                                     @"#fps",
                                                                     @"#install_time",
                                                                     @"#ram",
                                                                     @"#simulator"]];
    NSMutableArray *disPresetProperty = [NSMutableArray arrayWithArray:[TDPresetProperties performSelector:@selector(disPresetProperties)]];
    [disPresetProperty enumerateObjectsUsingBlock:^(NSString*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [allProperties removeObject:obj];
    }];
    
    NSMutableSet *set1 = [NSMutableSet setWithArray:allkeys];
    NSMutableSet *set2 = [NSMutableSet setWithArray:allProperties];
    [set1 intersectSet:set2];
    return [set1 isEqualToSet:set2];
}

+ (BOOL)checkDisPresetProperties:(NSDictionary *)properties eventName:(NSString *)eventName {
    
    NSArray *allkeys = properties.allKeys;
    NSArray *disPresetProperty = [TDPresetProperties performSelector:@selector(disPresetProperties)];
    NSMutableSet *set1 = [NSMutableSet setWithArray:allkeys];
    NSMutableSet *set2 = [NSMutableSet setWithArray:disPresetProperty];
    
    // 不是启动事件 需要将#start_reason字段去掉
    if (![eventName isEqualToString:@"ta_app_start"]) {
        [set2 removeObject:@"#start_reason"];
    }
    
    [set1 intersectSet:set2];
    return !set1.allObjects.count;
}

+ (BOOL)checkProperties:(NSDictionary *)dataSource
{
    NSString *eventName = dataSource[@"#event_name"];
    NSDictionary *properties = dataSource[@"properties"];
    BOOL checkPresentProperty = [self checkPresentProperties:properties];
    BOOL checkDisPresetProperty = [self checkDisPresetProperties:properties eventName:eventName];
    return checkPresentProperty && checkDisPresetProperty;
}

+ (BOOL)checkCustomProperties:(NSDictionary *)dataSource
               customProperty:(NSDictionary *)customProperty
               staticProperty:(NSDictionary *)staticProperty
                 dyldProperty:(NSDictionary *)dyldProperty
            {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    if (staticProperty) {
        [dic addEntriesFromDictionary:staticProperty];
    }
    if (dyldProperty) {
        [dic addEntriesFromDictionary:dyldProperty];
    }
    if (customProperty) {
        [dic addEntriesFromDictionary:customProperty];
    }
    return [self checkCustomProperties:dataSource customProperty:dic];
}


+ (BOOL)checkCustomProperties:(NSDictionary *)dataSource
               customProperty:(NSDictionary *)customProperty
{    
    NSDictionary *properties = [NSMutableDictionary dictionaryWithDictionary:dataSource[@"properties"]];
    NSArray *allkeys = properties.allKeys;
    NSArray *customAllkeys = customProperty.allKeys;
    
    // 字段比较
    NSMutableSet *set1 = [NSMutableSet setWithArray:allkeys];
    NSMutableSet *set2 = [NSMutableSet setWithArray:customAllkeys];
    [set1 intersectSet:set2];
    BOOL iscontain = [set1 isEqualToSet:set2];
    
    if (!iscontain) {
        return NO;
    }
    return [set1 isEqualToSet:set2];
}

+ (NSString *)td_trim:(NSString *)string {
    NSString *str = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    return str;
}


+ (void)deleteNSLibraryDirectory {

    NSString *fileDir = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
    
    NSArray *subPathArr = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:fileDir error:nil];

    NSString *filePath = nil;

    NSError *error = nil;

    for (NSString *subPath in subPathArr)
    {
        filePath = [fileDir stringByAppendingPathComponent:subPath];
        //删除子文件夹
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
        if (error) {
            NSLog(@"删除失败");
        }
    }
}

@end

#pragma clang diagnostic pop
