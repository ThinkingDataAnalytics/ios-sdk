//
//  TDArchiveStore.h
//  ThinkingSDK
//
//  Created by wwango on 2022/1/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TDArchiveStore : NSObject

+ (BOOL)archiveWithFileName:(NSString *)fileName value:(nullable id)value instanceToken:(NSString *)instanceToken;

+ (nullable id)unarchiveWithFileName:(NSString *)fileName instanceToken:(NSString *)instanceToken;

+ (NSString *)filePath:(NSString *)fileName instanceToken:(NSString *)instanceToken;

@end

NS_ASSUME_NONNULL_END
