//
//  ThinkingAnalyticsDisplayAPI.h
//  teviewtemplate
//
//  Created by Charles on 25.11.22.
//

#import <Foundation/Foundation.h>
#include "TADisplayConfig.h"

NS_ASSUME_NONNULL_BEGIN

@interface ThinkingAnalyticsDisplayAPI : NSObject

+ (instancetype)startWithConfigOptions:(TADisplayConfig *)config;

- (void)showTemplateDialogWithFileName:(NSString *)fileName;
- (void)showTemplateDialogWithJson:(NSDictionary *)json;

@end

NS_ASSUME_NONNULL_END
