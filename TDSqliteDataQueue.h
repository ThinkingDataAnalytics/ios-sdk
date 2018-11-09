//
//  TDSqliteDataQueue.h
//  TDAnalyticsSDK
//
//  Created by thinkingdata on 2017/6/22.
//  Copyright © 2017年 thinkingdata. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TDSqliteDataQueue : NSObject

- (id)initWithPath:(NSString*)filePath;

- (void)addObejct:(id)obj;

- (NSArray *) getFirstRecords:(NSUInteger)recordSize;

- (BOOL) removeFirstRecords:(NSUInteger)recordSize;

- (NSUInteger) count;

- (BOOL) vacuum;

@end

