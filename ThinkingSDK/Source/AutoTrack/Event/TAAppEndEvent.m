//
//  TAAppEndEvent.m
//  ThinkingSDK
//
//  Created by 杨雄 on 2022/6/17.
//

#import "TAAppEndEvent.h"
#import "TDPresetProperties+TDDisProperties.h"

@implementation TAAppEndEvent

- (NSMutableDictionary *)jsonObject {
    NSMutableDictionary *dict = [super jsonObject];
    
    if (![TDPresetProperties disableScreenName]) {
        // 如果没有页面名字，需要传空字符串
        self.properties[@"#screen_name"] = self.screenName ?: @"";
    }
    
    return dict;
}

@end
