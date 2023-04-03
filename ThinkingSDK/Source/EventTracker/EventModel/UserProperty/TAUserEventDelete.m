//
//  TAUserEventDelete.m
//  ThinkingSDK
//
//  Created by 杨雄 on 2022/7/1.
//

#import "TAUserEventDelete.h"

@implementation TAUserEventDelete

- (instancetype)init {
    if (self = [super init]) {
        self.eventType = TAEventTypeUserDel;
    }
    return self;
}

@end
