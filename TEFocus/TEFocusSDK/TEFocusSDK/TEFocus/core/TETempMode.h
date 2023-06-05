//
//  TETempMode.h
//  teviewtemplate
//
//  Created by Charles on 25.11.22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class TEViewNode;

@interface TETempMode : NSObject<NSCopying>

@property (nonatomic, strong) NSString* mantleColor;
@property (nonatomic, assign) BOOL mantleCloseEnabled;
@property (nonatomic, strong) TEViewNode* node;

+(TETempMode*)buildNodeWithFileName:(NSString *)fileName;
+(TETempMode*)buildNodeWithJson:(NSDictionary *)element;

@end

NS_ASSUME_NONNULL_END
