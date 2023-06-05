//
//  TADisplayConfig.m
//  teviewtemplate
//
//  Created by Charles on 25.11.22.
//

#import "TADisplayConfig.h"

@implementation ThinkingActionModel

@end

@interface TADisplayConfig ()

@end


@implementation TADisplayConfig

- (void)popupListener:(dispatch_block_t)loadSuccess
           loadFailed:(void(^)(int , NSString *))loadFailed
                click:(void(^)(ThinkingActionModel *))actionModel
                close:(dispatch_block_t)close {
    self.loadSuccess=loadSuccess;
    self.loadFailed =loadFailed;
    self.actionModel =actionModel;
    self.close =close;
    
}

@end
