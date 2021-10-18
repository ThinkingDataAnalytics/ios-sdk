//
//  TDValidatorTest.m
//  ThinkingSDKTests
//
//  Created by wwango on 2021/10/18.
//  Copyright © 2021 thinkingdata. All rights reserved.
//

#import "TDValidatorTest.h"
#import "TDValidator.h"

@implementation TDValidatorTest

- (void)setUp {
    
}

- (void)tearDown {
    
}


- (void)testJSONObjectRecursive
{
    
}

//// 老数据， 基本数据类型
//NSArray *arr = @[@"sting0", @"value0", @0, [NSNumber numberWithBool:YES], NSDate.date];
//NSDictionary *dic1 = @{@"sting1":@"value1", @"int1":@1, @"bool1":[NSNumber numberWithBool:YES], @"data1": [NSDate dateWithTimeIntervalSince1970:123]};
//NSDictionary *dic2 = @{@"sting2":@"value2", @"int2":@2, @"bool2":[NSNumber numberWithBool:NO], @"data2": NSDate.date, @"arr2": arr};
//
//// 复杂数据， 对象、对象组
//NSArray *arr3 = @[dic1, [dic1 mutableCopy], dic2, [dic2 mutableCopy]];
//NSDictionary *dic3 = @{@"sting3":@"value3", @"int3":@3, @"bool3":[NSNumber numberWithBool:YES], @"data3": dic1 ,@"arr3":arr3};
//NSDictionary *dic4 = @{@"sting4":@"value4", @"int4":@4, @"bool4":[NSNumber numberWithBool:NO], @"data4": dic2 ,@"arr4":arr3};
//
//// 遍历每一个属性，并格式化
//if (dic1) {
//    NSDictionary *propertiesDic1 = [TDValidator td_checkToJSONObjectRecursive:dic1 timeFormatter:_timeFormatter];
//    NSDictionary *propertiesDic2 = [TDValidator td_checkToJSONObjectRecursive:dic2 timeFormatter:_timeFormatter];
//    NSDictionary *propertiesDic3 = [TDValidator td_checkToJSONObjectRecursive:dic3 timeFormatter:_timeFormatter];
//    NSDictionary *propertiesDic4 = [TDValidator td_checkToJSONObjectRecursive:dic4 timeFormatter:_timeFormatter];
//    
//    return nil;
//}

@end
