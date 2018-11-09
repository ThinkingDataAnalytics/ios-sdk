//
//  TDSqliteDataQueue.m
//  TDAnalyticsSDK
//
//  Created by thinkingdata on 2017/6/22.
//  Copyright © 2017年 thinkingdata. All rights reserved.
//

#import "TDSqliteDataQueue.h"
#import <sqlite3.h>
#define MAX_CACHE_SIZE 10000

@implementation TDSqliteDataQueue {
    sqlite3 *_database;
    NSUInteger _messageCount;
}

- (void) closeDatabase {
    sqlite3_close(_database);
    sqlite3_shutdown();
}

- (void) dealloc {
    [self closeDatabase];
}

- (id)initWithPath:(NSString *)filePath {
    self = [super init];
    if (sqlite3_initialize() != SQLITE_OK) {
        return nil;
    }
    if (sqlite3_open_v2([filePath UTF8String], &_database, SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE, NULL) == SQLITE_OK ) {
        NSString *_sql = @"create table if not exists TDData (id INTEGER PRIMARY KEY AUTOINCREMENT, content TEXT)";
        char *errorMsg;
        if (sqlite3_exec(_database, [_sql UTF8String], NULL, NULL, &errorMsg)==SQLITE_OK) {
        } else {
            return nil;
        }
        _messageCount = [self sqliteCount];
    } else {
        return nil;
    }
    return self;
}

- (void)addObejct:(id)obj {
    NSUInteger maxCacheSize = (NSUInteger)MAX_CACHE_SIZE;
    if (_messageCount >= maxCacheSize) {
        BOOL ret = [self removeFirstRecords:100];
        if (ret) {
            _messageCount = [self sqliteCount];
        } else {
            return;
        }
    }
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:obj options:(NSJSONWritingOptions)0 error:nil];
    NSString* query = @"INSERT INTO TDData(content) values(?)";
    sqlite3_stmt *insertStatement;
    int rc;
    rc = sqlite3_prepare_v2(_database, [query UTF8String],-1, &insertStatement, nil);
    if (rc == SQLITE_OK) {
        @try {
            sqlite3_bind_text(insertStatement, 1, [[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding] UTF8String], -1, SQLITE_TRANSIENT);
        } @catch (NSException *exception) {
            return;
        }
        rc = sqlite3_step(insertStatement);
        if(rc != SQLITE_DONE) {
        } else {
            sqlite3_finalize(insertStatement);
            _messageCount ++;
        }
    } else {
    }
}

- (NSArray *) getFirstRecords:(NSUInteger)recordSize {
    if (_messageCount == 0) {
        return @[];
    }
    
    NSMutableArray* contentArray = [[NSMutableArray alloc] init];
    
    NSString* query = [NSString stringWithFormat:@"SELECT content FROM TDData ORDER BY id ASC LIMIT %lu", (unsigned long)recordSize];

    sqlite3_stmt* stmt = NULL;
    int rc = sqlite3_prepare_v2(_database, [query UTF8String], -1, &stmt, NULL);
    if(rc == SQLITE_OK) {
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            @try {
                [contentArray addObject:[NSString stringWithUTF8String:(char*)sqlite3_column_text(stmt, 0)]];
            } @catch (NSException *exception) {
            }
        }
        sqlite3_finalize(stmt);
    }
    else {
        return nil;
    }
    return [NSArray arrayWithArray:contentArray];
}

- (BOOL) removeFirstRecords:(NSUInteger)recordSize{
    NSUInteger removeSize = MIN(recordSize, _messageCount);
    NSString* query = [NSString stringWithFormat:@"DELETE FROM TDData WHERE id IN (SELECT id FROM TDData ORDER BY id ASC LIMIT %lu);", (unsigned long)removeSize];
    char* errMsg;
    @try {
        if (sqlite3_exec(_database, [query UTF8String], NULL, NULL, &errMsg) != SQLITE_OK) {
            return NO;
        }
    } @catch (NSException *exception) {
        return NO;
    }
    _messageCount = [self sqliteCount];
    return YES;
}

- (NSUInteger) count {
    return _messageCount;
}

- (NSInteger) sqliteCount {
    NSString* query = @"select count(*) from TDData";
    sqlite3_stmt* statement = NULL;
    NSInteger count = -1;
    int rc = sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, NULL);
    if(rc == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            count = sqlite3_column_int(statement, 0);
        }
        sqlite3_finalize(statement);
    }
    else {
    }
    return count;
}

- (BOOL) vacuum {
#ifdef THINKING_ANALYTICS_ENABLE_VACUUM
    @try {
        NSString* query = @"VACUUM";
        char* errMsg;
        if (sqlite3_exec(_database, [query UTF8String], NULL, NULL, &errMsg) != SQLITE_OK) {
            return NO;
        }
        return YES;
    } @catch (NSException *exception) {
        return NO;
    }
#else
    return YES;
#endif
}

@end
