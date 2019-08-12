#import <Foundation/Foundation.h>

@interface TDSqliteDataQueue : NSObject

+ (TDSqliteDataQueue *)sharedInstanceWithAppid:(NSString *)appid;
- (NSInteger)addObejct:(id)obj withAppid:(NSString *)appid;
- (NSArray *)getFirstRecords:(NSUInteger)recordSize withAppid:(NSString *)appid;
- (void)removeFirstRecords:(NSUInteger)recordSize withAppid:(NSString *)appid;
- (void)deleteAll:(NSString *)appid;

@end

