//
//  TATrackFirstEvent.h
//  ThinkingSDK
//
//  Created by 杨雄 on 2022/6/12.
//

#import "TATrackEvent.h"

NS_ASSUME_NONNULL_BEGIN

@interface TATrackFirstEvent : TATrackEvent
/// 首次事件的id
@property (nonatomic, copy) NSString *firstCheckId;

@end

NS_ASSUME_NONNULL_END
