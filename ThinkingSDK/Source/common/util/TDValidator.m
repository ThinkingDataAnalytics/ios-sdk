//
//  TDValidator.m
//  ThinkingSDK
//
//  Created by wwango on 2021/9/10.
//  Copyright © 2021 thinkingdata. All rights reserved.
//

#import "TDValidator.h"
#import "TDLogging.h"

@implementation TDValidator

+ (NSString *)td_checkToAppid:(NSString *)appid {
    if (TD_Valid_NSString(appid)) {
        NSString *string = [appid stringByReplacingOccurrencesOfString:@" " withString:@""];
        string = [string stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        string = [string stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        return string;
    } else {
        TDLogError(@"appid  must be NSString and cannot null");
        return @"";
    }
}

+ (NSDictionary *)td_checkToJSONObjectRecursive:(NSDictionary *)properties timeFormatter:(NSDateFormatter *)timeFormatter {
    return (NSDictionary *)[self td_checkToObjectRecursive:properties timeFormatter:timeFormatter];
}

+ (NSObject *)td_checkToObjectRecursive:(NSObject *)properties timeFormatter:(NSDateFormatter *)timeFormatter {
    if (TD_CHECK_NIL(properties)) {
        return properties;
    } else if (TD_CHECK_CLASS_NSDictionary(properties)) {
        NSDictionary *propertyDic = [(NSDictionary *)properties copy];
        NSMutableDictionary<NSString *, id> *propertiesDic = [NSMutableDictionary dictionaryWithDictionary:propertyDic];
        for (NSString *key in [propertyDic keyEnumerator]) {
            NSObject *newValue = [self td_checkToJSONObjectRecursive:propertyDic[key] timeFormatter:timeFormatter];
            propertiesDic[key] = newValue;
        }
        return propertiesDic;
    } else if (TD_CHECK_CLASS_NSArray(properties)) {
        NSMutableArray *arrayItem = [(NSArray *)properties mutableCopy];
        for (int i = 0; i < arrayItem.count ; i++) {
            [self td_checkToJSONObjectRecursive:arrayItem[i] timeFormatter:timeFormatter];
        }
        return arrayItem;
    } else if (TD_CHECK_CLASS_NSDate(properties)) {
        NSString *dateStr = [timeFormatter stringFromDate:(NSDate *)properties];
        return dateStr;
    } else {
        return properties;
    }
}

+ (NSDictionary *)td_checkToJSONObject:(NSDictionary *)properties timeFormatter:(NSDateFormatter *)timeFormatter {
    NSMutableDictionary<NSString *, id> *propertiesDic = [NSMutableDictionary dictionaryWithDictionary:properties];
    for (NSString *key in [properties keyEnumerator]) {
        if ([properties[key] isKindOfClass:[NSDate class]]) {
            NSString *dateStr = [timeFormatter stringFromDate:(NSDate *)properties[key]];
            propertiesDic[key] = dateStr;
        } else if ([properties[key] isKindOfClass:[NSArray class]]) {
            NSMutableArray *arrayItem = [properties[key] mutableCopy];
            for (int i = 0; i < arrayItem.count ; i++) {
                if ([arrayItem[i] isKindOfClass:[NSDate class]]) {
                    NSString *dateStr = [timeFormatter stringFromDate:(NSDate *)arrayItem[i]];
                    arrayItem[i] = dateStr;
                } else if ([arrayItem[i] isKindOfClass:[NSDictionary class]]) {
                    // 对象数组
                    arrayItem[i] = _td_old_checkToJSONObject(arrayItem[i], timeFormatter);
                }
            }
            propertiesDic[key] = arrayItem;
        } else if ([properties[key] isKindOfClass:[NSDictionary class]]) {
            // 对象
            return _td_old_checkToJSONObject(properties[key], timeFormatter);
        }
    }
    return propertiesDic;
}

// 老方法，解析基本数据类型
inline static NSDictionary *_td_old_checkToJSONObject(NSDictionary *properties, NSDateFormatter *timeFormatter) {
    NSMutableDictionary<NSString *, id> *propertiesDic = [NSMutableDictionary dictionaryWithDictionary:properties];
    for (NSString *key in [properties keyEnumerator]) {
        if ([properties[key] isKindOfClass:[NSDate class]]) {
            NSString *dateStr = [timeFormatter stringFromDate:(NSDate *)properties[key]];
            propertiesDic[key] = dateStr;
        } else if ([properties[key] isKindOfClass:[NSArray class]]) {
            NSMutableArray *arrayItem = [properties[key] mutableCopy];
            for (int i = 0; i < arrayItem.count ; i++) {
                if ([arrayItem[i] isKindOfClass:[NSDate class]]) {
                    NSString *dateStr = [timeFormatter stringFromDate:(NSDate *)arrayItem[i]];
                    arrayItem[i] = dateStr;
                }
            }
            propertiesDic[key] = arrayItem;
        }
    }
    return propertiesDic;
}


@end
