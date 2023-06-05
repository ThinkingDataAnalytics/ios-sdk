//
//  TETempMode.m
//  teviewtemplate
//
//  Created by Charles on 25.11.22.
//

#import "TETempMode.h"
#import "TEViewNode.h"

@implementation TETempMode

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    TETempMode *node = [TETempMode new];
    node.mantleColor = self.mantleColor;
    node.mantleCloseEnabled = self.mantleCloseEnabled;
    node.node = self.node;
    return node;
}

- (id)mutableCopy {
    TETempMode *node = [TETempMode new];
    node.mantleColor = [self.mantleColor copy];
    node.mantleCloseEnabled = self.mantleCloseEnabled;
    node.node = [self.node mutableCopy];
    return node;
}

+(TETempMode*)buildNodeWithFileName:(NSString *)fileName {
    NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:@"json"];
    NSData *data = [[NSData alloc] initWithContentsOfFile:path];
    NSDictionary *obj = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    return [self buildNodeWithJson:obj];
}

+(TETempMode*)buildNodeWithJson:(NSDictionary *)element
{
    TETempMode* node = [[TETempMode alloc]init];
    if (!element) return node;
    if (![element isKindOfClass:[NSDictionary class]]) return node;
    node.mantleColor = element[@"mantle"][@"mantleColor"];
    NSNumber* mantleCloseEnabled = element[@"mantle"][@"mantleCloseEnabled"];
    node.mantleCloseEnabled = [mantleCloseEnabled boolValue];
    node.node = [TEViewNode buildNodeWithJson:element[@"template"]];
    return node;
}

@end
