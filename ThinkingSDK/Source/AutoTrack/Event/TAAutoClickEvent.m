//
//  TAAutoClickEvent.m
//  ThinkingSDK
//
//  Created by 杨雄 on 2022/6/15.
//

#import "TAAutoClickEvent.h"

@implementation TAAutoClickEvent

- (NSMutableDictionary *)jsonObject {
    NSMutableDictionary *dict = [super jsonObject];
    self.properties[@"#screen_name"] = self.screenName;
    self.properties[@"#element_id"] = self.elementId;
    self.properties[@"#element_type"] = self.elementType;
    self.properties[@"#element_content"] = self.elementContent;
    self.properties[@"#element_position"] = self.elementPosition;
    self.properties[@"#title"] = self.pageTitle;
    return dict;
}

@end
