#import <Foundation/Foundation.h>

@interface TDSqliteDataQueue : NSObject

- (id)initWithPath:(NSString*)filePath;

- (void)addObejct:(id)obj;

- (NSArray *) getFirstRecords:(NSUInteger)recordSize;

- (BOOL) removeFirstRecords:(NSUInteger)recordSize;

- (NSInteger) count;

@end

