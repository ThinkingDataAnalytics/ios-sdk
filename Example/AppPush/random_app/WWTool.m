//
//  WWTool.m
//  random_app
//
//  Created by Charles on 24.4.23.
//

#import "WWTool.h"
#import <objc/runtime.h>

void taPrintObjectClassInfo(id obj) {
    int level = 0;
    Class cls = object_getClass(obj);
    while (cls) {
        NSMutableString *indent = [NSMutableString stringWithCapacity:level * 2];
        for (int i = 0; i < level; i++) {
            [indent appendString:@"  "];
        }
        NSLog(@"%@Class name: %s", indent, class_getName(cls));
        unsigned int count;
        Method *methods = class_copyMethodList(cls, &count);
        for (unsigned int i = 0; i < count; i++) {
            Method method = methods[i];
            SEL sel = method_getName(method);
            NSLog(@"%@- Method name: %@", indent, NSStringFromSelector(sel));
        }
        free(methods);
        cls = class_getSuperclass(cls);
        level++;
    }
    NSMutableString *indent = [NSMutableString stringWithCapacity:level * 2];
    for (int i = 0; i < level; i++) {
        [indent appendString:@"  "];
    }
    NSLog(@"%@Object's isa pointer: %p", indent, object_getClass(obj));
}


@implementation WWTool

@end
