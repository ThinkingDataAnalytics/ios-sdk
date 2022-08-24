//
//  TDAppsFlyerSyncData.m
//  ThinkingSDK
//
//  Created by wwango on 2022/2/14.
//

#import "TDAppsFlyerSyncData.h"
#import <AppsFlyerLib/AppsFlyerLib.h>

@implementation TDAppsFlyerSyncData

- (void)syncThirdData:(id<TDThinkingTrackProtocol>)taInstance property:(NSDictionary *)property {
    
    if (!self.customPropety || [self.customPropety isKindOfClass:[NSDictionary class]]) {
        self.customPropety = @{};
    }
    NSMutableDictionary * datas = [NSMutableDictionary dictionaryWithDictionary:property];
    NSString *accountID = [taInstance getAccountId];
    NSString *distinctId = [taInstance getDistinctId];
    [datas setObject:(accountID ? accountID : @"") forKey:TA_ACCOUNT_ID];
    [datas setObject:distinctId ? distinctId : @"" forKey:TA_DISTINCT_ID];
    [[AppsFlyerLib shared] setAdditionalData:datas];
}

@end
