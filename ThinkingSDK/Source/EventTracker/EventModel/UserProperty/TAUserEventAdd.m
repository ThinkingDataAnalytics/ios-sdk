//
//  TAUserEventAdd.m
//  ThinkingSDK
//
//  Created by 杨雄 on 2022/7/1.
//

#import "TAUserEventAdd.h"

@implementation TAUserEventAdd

- (instancetype)init {
    if (self = [super init]) {
        self.eventType = TAEventTypeUserAdd;
    }
    return self;
}

- (void)validateWithError:(NSError *__autoreleasing  _Nullable *)error {
    // 可以在此处添加验证条件
}

//MARK: - Delegate

- (void)ta_validateKey:(NSString *)key value:(id)value error:(NSError *__autoreleasing  _Nullable *)error {
    [super ta_validateKey:key value:value error:error];
    if (*error) {
        return;
    }
    if (![value isKindOfClass:NSNumber.class]) {
        NSString *errMsg = [NSString stringWithFormat:@"Property value must be type NSNumber. got: %@ %@. ", [value class], value];
        *error = TAPropertyError(10008, errMsg);
    }
}

@end
