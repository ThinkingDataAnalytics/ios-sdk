//
//  TEViewNode.h
//  teviewtemplate
//
//  Created by Charles on 25.11.22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class TENodeAttr;
@class TEViewNode;

@interface TEViewNode : NSObject<NSCoding, NSCopying>

@property (nonatomic, strong) NSString* viewClassName;
@property (nonatomic, strong) NSMutableDictionary* layoutProperties;
@property (nonatomic, strong) NSMutableArray<TENodeAttr*>* viewAttrs;
@property (nonatomic, strong) NSMutableArray<TEViewNode*>* children;

+(TEViewNode*)buildNodeWithJson:(NSDictionary *)element;

@end

NS_ASSUME_NONNULL_END
