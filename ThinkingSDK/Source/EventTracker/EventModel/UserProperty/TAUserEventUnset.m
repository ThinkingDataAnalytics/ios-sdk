//
//  TAUserEventUnset.m
//  ThinkingSDK
//
//  Created by 杨雄 on 2022/7/1.
//

#import "TAUserEventUnset.h"

@implementation TAUserEventUnset

- (instancetype)init {
    if (self = [super init]) {
        self.eventType = TAEventTypeUserUnset;
    }
    return self;
}

@end
