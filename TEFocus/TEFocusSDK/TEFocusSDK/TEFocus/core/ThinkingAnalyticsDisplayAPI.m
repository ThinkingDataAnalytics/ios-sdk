//
//  ThinkingAnalyticsDisplayAPI.m
//  teviewtemplate
//
//  Created by Charles on 25.11.22.
//

#import "ThinkingAnalyticsDisplayAPI.h"
#import "TETempMode.h"
#import "TEShowDialog.h"

static ThinkingAnalyticsDisplayAPI *ta_display_instance;


@interface ThinkingAnalyticsDisplayAPI()

@property(nonatomic, strong)TADisplayConfig *config;

@end

@implementation ThinkingAnalyticsDisplayAPI

+ (instancetype)startWithConfigOptions:(TADisplayConfig *)config {
    if (ta_display_instance == nil) {
        @synchronized ([ThinkingAnalyticsDisplayAPI class]) {
            ta_display_instance = [[ThinkingAnalyticsDisplayAPI alloc] init];
            ta_display_instance.config = config;
        }
    }
    return ta_display_instance;
}

- (void)showTemplateDialogWithFileName:(NSString *)fileName {
    TETempMode *node = [TETempMode buildNodeWithFileName:fileName];
    [TEShowDialog showDialog:[node copy] config:self.config];
}

- (void)showTemplateDialogWithJson:(NSDictionary *)json {
    TETempMode *node = [TETempMode buildNodeWithJson:json];
    [TEShowDialog showDialog:node config:self.config];
}

@end
