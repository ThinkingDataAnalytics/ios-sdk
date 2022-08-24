//
//  TAUserEventUniqueAppend.m
//  ThinkingSDK
//
//  Created by 杨雄 on 2022/7/1.
//

#import "TAUserEventUniqueAppend.h"

@implementation TAUserEventUniqueAppend

- (instancetype)init {
    if (self = [super init]) {
        self.eventType = TAEventTypeUserUniqueAppend;
    }
    return self;
}

@end
