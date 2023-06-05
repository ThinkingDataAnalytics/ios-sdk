//
//  TENodeAttr.h
//  teviewtemplate
//
//  Created by Charles on 25.11.22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TENodeAttr : NSObject<NSCoding, NSCopying>

@property(nonatomic,strong) NSString* name ;
@property(nonatomic,strong) id value ;

-(BOOL)isValid;

@end

NS_ASSUME_NONNULL_END
