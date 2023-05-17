//
//  TDThirdPartyManager.m
//  ThinkingSDK
//
//  Created by wwango on 2022/2/11.
//

#import "TDThirdPartyManager.h"
#import "TDAppsFlyerSyncData.h"
#import "TDIronSourceSyncData.h"

static NSMutableDictionary *_thirdPartyManagerMap;

@implementation TDThirdPartyManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        _thirdPartyManagerMap = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)enableThirdPartySharing:(TDThirdPartyShareType)type instance:(id<TDThinkingTrackProtocol>)instance
{
    [self enableThirdPartySharing:type instance:instance property:@{}];
}

- (void)enableThirdPartySharing:(TDThirdPartyShareType)type instance:(id<TDThinkingTrackProtocol>)instance property:(NSDictionary *)property
{
    
    if ((type & TD_APPS_FLYER) == TD_APPS_FLYER) {
        if (!NSClassFromString(@"AppsFlyerLib")) {
            NSLog(@"AppsFlyer数据同步异常: 未安装AppsFlyer SDK");
            return;
        }
        id<TDThirdPartySyncProtocol> syncData = [_thirdPartyManagerMap objectForKey:@"TDAppsFlyerSyncData"];
        if (!syncData) {
            syncData = [TDAppsFlyerSyncData new];
            [_thirdPartyManagerMap setObject:syncData forKey:@"TDAppsFlyerSyncData"];
        }
        [syncData syncThirdData:instance property:[property copy]];
    }
    
    if ((type & TD_APPS_FLYER) == TD_IRON_SOURCE) {
        if (!NSClassFromString(@"IronSource")) {
            NSLog(@"IronSource数据同步异常: 未安装IronSource SDK");
            return;
        }
        id<TDThirdPartySyncProtocol> syncData = [_thirdPartyManagerMap objectForKey:@"TDIronSourceSyncData"];
        if (!syncData) {
            syncData = [TDAppsFlyerSyncData new];
            [_thirdPartyManagerMap setObject:syncData forKey:@"TDIronSourceSyncData"];
        }
        [syncData syncThirdData:instance];
    }

}

@end
