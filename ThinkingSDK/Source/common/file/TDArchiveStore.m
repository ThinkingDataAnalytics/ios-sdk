//
//  TDArchiveStore.m
//  ThinkingSDK
//
//  Created by wwango on 2022/1/27.
//

#import "TDArchiveStore.h"
#import "TDLogging.h"

@implementation TDArchiveStore

+ (BOOL)archiveWithFileName:(NSString *)fileName value:(nullable id)value instanceToken:(NSString *)instanceToken {
    if (!fileName) {
        TDLogError(@"key should not be nil for file store");
        return NO;
    }
    NSString *filePath = [TDArchiveStore filePath:fileName instanceToken:instanceToken];
#if TARGET_OS_IOS
    /* 为filePath文件设置保护等级 */
    NSDictionary *protection = [NSDictionary dictionaryWithObject:NSFileProtectionComplete
                                                           forKey:NSFileProtectionKey];
#elif TARGET_OS_OSX
// macOS10.13 不包含 NSFileProtectionComplete
    NSDictionary *protection = [NSDictionary dictionary];
#endif
    
    [[NSFileManager defaultManager] setAttributes:protection
                                     ofItemAtPath:filePath
                                            error:nil];
    if (![NSKeyedArchiver archiveRootObject:value toFile:filePath]) {
        TDLogError(@"%@ unable to archive %@", self, fileName);
        return NO;
    }
    TDLogError(@"%@ archived %@", self, fileName);
    return YES;
}

+ (id)unarchiveWithFileName:(NSString *)fileName instanceToken:(NSString *)instanceToken {
    if (!fileName) {
        TDLogError(@"key should not be nil for file store");
        return nil;
    }
    NSString *filePath = [TDArchiveStore filePath:fileName instanceToken:instanceToken];
    return [TDArchiveStore unarchiveFromFile:filePath instanceToken:instanceToken];
}

+ (id)unarchiveFromFile:(NSString *)filePath instanceToken:(NSString *)instanceToken {
    id unarchivedData = nil;
    @try {
        unarchivedData = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    } @catch (NSException *exception) {
        TDLogError(@"%@ unable to unarchive data in %@, starting fresh", self, filePath);
        unarchivedData = nil;
    }
    return unarchivedData;
}

+ (NSString *)filePath:(NSString *)key instanceToken:(NSString *)instanceToken {
#if TARGET_OS_OSX
    // 兼容老版 mac SDK 的本地数据
    NSString *filename = [NSString stringWithFormat:@"com.thinkingdata.sdk.%@.%@", key, instanceToken];
#else
    NSString *filename = [NSString stringWithFormat:@"com.thinkingdata.sdk.%@.%@", key, instanceToken];
#endif

    NSString *filepath = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject]
            stringByAppendingPathComponent:filename];
    TDLogDebug(@"filepath for %@ is %@", key, filepath);
    return filepath;
}

@end
