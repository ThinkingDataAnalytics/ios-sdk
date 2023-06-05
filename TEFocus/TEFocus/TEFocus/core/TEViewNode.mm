//
//  TEViewNode.m
//  teviewtemplate
//
//  Created by Charles on 25.11.22.
//

#import "TEViewNode.h"
#import "TENodeAttr.h"
#import "TAYoga.h"
#import "UIView+TAYoga.h"
#import "TAYGEnums.h"

#define VIEWCLSNAME     @"viewClsName"
#define NAME            @"name"
#define ONPRESS         @"onPress"
#define CLASSNAMES      @"classNames"
#define LAYOUTPARAM     @"layoutParam"
#define LAYOUTPROPERTIES    @"layoutProperties"
#define VIEWATTRS       @"viewAttrs"
#define CHILDREN        @"children"

BOOL TEFlexIsLayoutAttr(NSString* attrName)
{
    if ([attrName hasPrefix:@"$"]) {
        attrName = [attrName substringFromIndex:1];
    }
    
    static NSSet* layoutAttrs = nil;
    
    if (layoutAttrs == nil) {
        layoutAttrs = [NSSet setWithArray:@[
            @"direction",
            @"flexDirection",
            @"justifyContent",
            @"alignContent",
            @"alignItems",
            @"alignSelf",
            @"position",
            @"flexWrap",
            @"overflow",
            @"display",
            @"flex",
            @"flexGrow",
            @"flexShrink",
            @"flexBasis",
            @"left",
            @"top",
            @"right",
            @"bottom",
            @"start",
            @"end",
            @"marginLeft",
            @"marginTop",
            @"marginRight",
            @"marginBottom",
            @"marginStart",
            @"marginEnd",
            @"marginHorizontal",
            @"marginVertical",
            @"margin",
            @"paddingLeft",
            @"paddingTop",
            @"paddingRight",
            @"paddingBottom",
            @"paddingStart",
            @"paddingEnd",
            @"paddingHorizontal",
            @"paddingVertical",
            @"padding",
            @"width",
            @"height",
            @"minWidth",
            @"minHeight",
            @"maxWidth",
            @"maxHeight",
            @"aspectRatio",
        ]];
    }
    return [layoutAttrs containsObject:attrName];
}


@implementation TEViewNode

- (instancetype)init
{
    self = [super init];
    if (self) {
        //_layoutParams = [NSMutableArray array];
        _layoutProperties = [NSMutableDictionary dictionary];
        _viewAttrs = [NSMutableArray array];
        _children = [NSMutableArray array];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        _viewClassName = [coder decodeObjectForKey:VIEWCLSNAME];
        //_layoutParams = [coder decodeObjectForKey:LAYOUTPARAM];
        _layoutProperties = [coder decodeObjectForKey:LAYOUTPROPERTIES];
        _viewAttrs = [coder decodeObjectForKey:VIEWATTRS];
        _children = [coder decodeObjectForKey:CHILDREN];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_viewClassName forKey:VIEWCLSNAME];
    //[aCoder encodeObject:_layoutParams forKey:LAYOUTPARAM];
    [aCoder encodeObject:_layoutProperties forKey:LAYOUTPROPERTIES];
    [aCoder encodeObject:_viewAttrs forKey:VIEWATTRS];
    [aCoder encodeObject:_children forKey:CHILDREN];
}

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    TEViewNode *node = [TEViewNode new];
    node.viewClassName = self.viewClassName;
//    node.layoutParams = self.viewAttrs;
    node.layoutProperties = self.layoutProperties;
    node.viewAttrs = self.viewAttrs;
    node.children = self.children;
    return self;
}

- (id)mutableCopy {
    TEViewNode *node = [TEViewNode new];
    node.viewClassName = [self.viewClassName copy];
//    if (self.layoutParams && [self.layoutParams isKindOfClass:[NSArray class]] && self.layoutParams.count > 0) {
//        node.layoutParams = [[NSMutableArray array] initWithArray:self.layoutParams copyItems:YES];
//    }
    if (self.layoutProperties && [self.layoutProperties isKindOfClass:[NSMutableDictionary class]] && self.layoutProperties.count > 0) {
        node.layoutProperties = [[NSMutableDictionary dictionary] initWithDictionary:self.layoutProperties copyItems:YES];
    }
    if (self.viewAttrs && [self.viewAttrs isKindOfClass:[NSArray class]] && self.viewAttrs.count > 0) {
        node.viewAttrs = [[NSMutableArray array] initWithArray:self.viewAttrs copyItems:YES];
    }
    if (self.children && [self.children isKindOfClass:[NSArray class]] && self.children.count > 0) {
        node.children = [[NSMutableArray array] initWithArray:self.children copyItems:YES];
    }
    return node;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"FlexNode: %@, %@, %@, %@", self.viewClassName, self.layoutProperties, self.viewAttrs, self.children];
}

+(TEViewNode*)buildNodeWithJson:(NSDictionary *)element
{
    TEViewNode* node = [[TEViewNode alloc]init];
    
    if (!element) return node;
    if (![element isKindOfClass:[NSDictionary class]]) return node;
    
    node.viewClassName = element[@"viewType"];
//    node.layoutParams = [NSMutableArray array];
    node.layoutProperties = [NSMutableDictionary dictionary];
    [element.allKeys enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if(![obj isEqualToString:@"viewType"] && ![obj isEqualToString:@"action"] && ![obj isEqualToString:@"subviews"]){
            TENodeAttr *attr = [[TENodeAttr alloc] init];
            attr.value = element[obj];
            attr.name = obj;
            //[node.layoutParams addObject:attr];
            [node.layoutProperties setValue:element[obj] forKey:obj];
        }
    }];
    NSLog(@"%@",node.layoutProperties);
    NSMutableArray<TENodeAttr *> *viewAttrs = [NSMutableArray array];
    NSDictionary<NSString *, id> *actions = element[@"action"];
    [actions.allKeys enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        TENodeAttr *attr = [[TENodeAttr alloc] init];
        attr.value = actions[obj];
        attr.name = obj;
        [viewAttrs addObject:attr];
    }];
    node.viewAttrs = viewAttrs;
    
    NSArray* children = element[@"subviews"];
    if( children.count > 0 ){
        NSMutableArray<TEViewNode *>* childNodes = [NSMutableArray array] ;
        for(NSDictionary* child in children){
            if(![child isKindOfClass:[NSDictionary class]]){
                continue;
            }
            [childNodes addObject:[TEViewNode buildNodeWithJson:child]];
        }
        node.children = [childNodes copy] ;
    }
    return node;
}

@end
