//
//  TADisplayConfig.h
//  teviewtemplate
//
//  Created by Charles on 25.11.22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


typedef NS_ENUM(NSInteger, ThinkingActionModelType) {
    ThinkingActionModelTypeClose,
    ThinkingActionModelTypeOpenLink,
    ThinkingActionModelTypeCopy,
    ThinkingActionModelTypeCustom,
};

@interface ThinkingActionModel : NSObject

@property (nonatomic, assign) ThinkingActionModelType type;
@property (nonatomic, strong) NSString *value;

@end


@interface TADisplayConfig : NSObject

@property(copy, nonatomic) dispatch_block_t loadSuccess;
@property(copy, nonatomic) void(^loadFailed)(int code, NSString *msg);
@property(copy, nonatomic) void(^actionModel)(ThinkingActionModel *model);
@property(copy, nonatomic) dispatch_block_t close;

- (void)popupListener:(dispatch_block_t)loadSuccess
           loadFailed:(void(^)(int code, NSString *msg))loadFailed
                click:(void(^)(ThinkingActionModel *model))actionModel
                close:(dispatch_block_t)close;

@end

NS_ASSUME_NONNULL_END
