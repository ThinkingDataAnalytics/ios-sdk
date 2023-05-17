//
//  TDIronSourceSyncData.m
//  ThinkingSDK
//
//  Created by wwango on 2022/2/16.
//

#import "TDIronSourceSyncData.h"
#import <IronSource/IronSource.h>
#import <ThinkingSDK/ThinkingAnalyticsSDK.h>

@implementation TDIronSourceSyncData

- (void)syncThirdData:(id<TDThinkingTrackProtocol>)taInstance {
    
    [super syncThirdData:taInstance];
    
    if (self.isSwizzleMethod) return;
    
    Class class = NSClassFromString(@"IronSource");
    NSString *oriSELString = @"addImpressionDataDelegate:";
    SEL newSel = NSSelectorFromString([NSString stringWithFormat:@"td_%@", oriSELString]);
    IMP newIMP = imp_implementationWithBlock(^(id _self, id delegate) {
        if ([_self respondsToSelector:newSel]) {
            [_self performSelector:newSel withObject:delegate];
        }
        
        id class1 = delegate;
        NSString *oriSELString1 = @"impressionDataDidSucceed:";
        SEL newSel1 = NSSelectorFromString([NSString stringWithFormat:@"td_%@", oriSELString1]);
        IMP newIMP1 = imp_implementationWithBlock(^(id _self1, ISImpressionData *impressionData) {
            if ([_self1 respondsToSelector:newSel1]) {
                [_self1 performSelector:newSel1 withObject:impressionData];
            }

            NSLog(@"@@@@@@@@@: ironSource_sdk_postbacks");
            NSLog(@"@@@@@@@@@ data: %@", [impressionData all_data]);
            [self.taInstance track:@"ta_ironSource_callback" properties:[impressionData all_data]];
        });
        __td_td_swizzleWithOriSELStr(class1, oriSELString1, newSel1, newIMP1);
    });
    
    __td_td_swizzleWithOriSELStr(class, oriSELString, newSel, newIMP);
    
    self.isSwizzleMethod = YES;
}



@end

