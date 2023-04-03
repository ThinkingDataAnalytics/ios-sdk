//
//  TATrackOverwriteEvent.h
//  ThinkingSDK
//
//  Created by 杨雄 on 2022/6/12.
//

#import "TATrackEvent.h"

NS_ASSUME_NONNULL_BEGIN

@interface TATrackOverwriteEvent : TATrackEvent
/// 事件id
@property (nonatomic, copy) NSString *eventId;

@end

NS_ASSUME_NONNULL_END
