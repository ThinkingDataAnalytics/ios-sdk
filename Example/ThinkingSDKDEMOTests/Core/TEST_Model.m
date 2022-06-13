//
//  TEST_Model.m
//  ThinkingSDKDEMOUITests
//
//  Created by wwango on 2021/11/11.
//  Copyright © 2021 thinking. All rights reserved.
//

#import "TEST_Model.h"
#import "YYKit.h"

@implementation TEST_Model

+ (NSArray *)getTestDatas:(NSString *)jsonName {
    NSString *path = [[NSBundle bundleForClass:[TEST_Model class]] pathForResource:jsonName ofType:@"json"];
    NSData *data = [[NSData alloc] initWithContentsOfFile:path];
    NSArray *models = [NSArray modelArrayWithClass:[TEST_Model class] json:data];
    return models;
}

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"idd":@"id", @"descriptionn":@"description"};
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
  return @{@"input" : [TEST_Input_Model class]};
}

@end


@implementation TEST_Input_Model

@end
