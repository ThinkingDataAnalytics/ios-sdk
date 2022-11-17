//
//  TAPresetPropertyPlugin.m
//  ThinkingSDK
//
//  Created by 杨雄 on 2022/6/12.
//

#import "TAPresetPropertyPlugin.h"
#import "TDPresetProperties.h"
#import "TDPresetProperties+TDDisProperties.h"
#import "TDDeviceInfo.h"
#import "TAReachability.h"

@interface TAPresetPropertyPlugin ()
@property (nonatomic, strong) NSMutableDictionary<NSString *, id> *properties;

@end

@implementation TAPresetPropertyPlugin

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.properties = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)start {
    if (![TDPresetProperties disableAppVersion]) {
        self.properties[@"#app_version"] = [TDDeviceInfo sharedManager].appVersion;
    }
    if (![TDPresetProperties disableBundleId]) {
        self.properties[@"#bundle_id"] = [TDDeviceInfo bundleId];
    }
        
    if (![TDPresetProperties disableInstallTime]) {
        self.properties[@"#install_time"] = [TDDeviceInfo td_getInstallTime];
    }
}

- (void)asyncGetPropertyCompletion:(TAPropertyPluginCompletion)completion {
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    
    [mutableDict addEntriesFromDictionary:[[TDDeviceInfo sharedManager] getAutomaticData]];
    
    if (![TDPresetProperties disableNetworkType]) {
        mutableDict[@"#network_type"] = [[TAReachability shareInstance] networkState];
    }
    
    if (completion) {
        completion(mutableDict);
    }
}

@end
