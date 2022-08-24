//
//  TAAutoPageViewEvent.m
//  ThinkingSDK
//
//  Created by 杨雄 on 2022/6/15.
//

#import "TAAutoPageViewEvent.h"

@implementation TAAutoPageViewEvent

- (NSMutableDictionary *)jsonObject {
    NSMutableDictionary *dict = [super jsonObject];
    self.properties[@"#screen_name"] = self.screenName;
    self.properties[@"#title"] = self.pageTitle;
    self.properties[@"#url"] = self.pageUrl;
    self.properties[@"#referrer"] = self.referrer;
    return dict;
}

@end
