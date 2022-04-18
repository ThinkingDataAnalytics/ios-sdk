//
//  TEST_Fakes.m
//  ThinkingSDKDEMOUITests
//
//  Created by wwango on 2021/11/11.
//  Copyright © 2021 thinking. All rights reserved.
//

#import "TEST_Fakes.h"
#import "Aspects.h"

static NSMutableDictionary *_fakesInstances;

@implementation TEST_Fakes

+ (NSMutableDictionary *)fakeAllInstances {
    if (!_fakesInstances) {
        _fakesInstances = [NSMutableDictionary dictionary];
    }
    return _fakesInstances;
}

+ (void)setFakeAllInstances:(NSMutableDictionary *)fakeAllInstances {
    
}


@end
