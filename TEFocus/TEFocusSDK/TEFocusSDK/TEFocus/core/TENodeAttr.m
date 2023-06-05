//
//  TENodeAttr.m
//  teviewtemplate
//
//  Created by Charles on 25.11.22.
//

#import "TENodeAttr.h"

@implementation TENodeAttr

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    TENodeAttr *node = [TENodeAttr new];
    node.name = self.name;
    node.value = self.value;
    return self;
}

- (id)mutableCopy {
    TENodeAttr *node = [TENodeAttr new];
    node.name = [self.name copy];
    node.value = [self.value copy];
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        _name = [coder decodeObjectForKey:@"name"];
        _value = [coder decodeObjectForKey:@"value"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_name forKey:@"name"];
    [aCoder encodeObject:_value forKey:@"value"];
}

-(BOOL)isValid{
    if ([self.value isKindOfClass:[NSString class]]) {
        return self.name.length>0 && ((NSString *)self.value).length>0;
    } else if ([self.value isKindOfClass:[NSArray class]]) {
        return self.name.length>0 && ((NSArray *)self.value).count>0;
    }  else if ([self.value isKindOfClass:[NSDictionary class]]) {
        return self.name.length>0 && ((NSDictionary *)self.value).allKeys.count>0;
    } else {
        return NO;
    }
}

@end
