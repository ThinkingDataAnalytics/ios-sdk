//
//  ActionModel.h
//  ThinkingSDKDEMO
//
//  Created by LiHuanan on 2020/9/7.
//  Copyright © 2020 thinking. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void(^Action)(void);
NS_ASSUME_NONNULL_BEGIN

@interface ActionModel : NSObject
- (id)initWithName:(NSString*)name action:(Action)action;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, copy) Action action;
@end

NS_ASSUME_NONNULL_END
