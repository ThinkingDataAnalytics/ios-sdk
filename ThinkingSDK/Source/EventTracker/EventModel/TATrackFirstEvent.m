//
//  TATrackFirstEvent.m
//  ThinkingSDK
//
//  Created by 杨雄 on 2022/6/12.
//

#import "TATrackFirstEvent.h"
#import "TDDeviceInfo.h"

@implementation TATrackFirstEvent

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.eventType = TAEventTypeTrackFirst;
    }
    return self;
}

- (void)validateWithError:(NSError *__autoreleasing  _Nullable *)error {
    [super validateWithError:error];
    if (*error) {
        return;
    }
    if (self.firstCheckId.length <= 0) {
        NSString *errorMsg = @"property 'firstCheckId' cannot be empty which in FirstEvent";
        *error = TAPropertyError(100010, errorMsg);
        return;
    }
}

- (NSMutableDictionary *)jsonObject {
    NSMutableDictionary *dict = [super jsonObject];
    
    // 首次事件，默认firstCheckId为设备id
    dict[@"#first_check_id"] = self.firstCheckId ?: [TDDeviceInfo sharedManager].deviceId;
    
    return dict;
}

@end
