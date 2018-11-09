//
//  NSData+Gzip.h
//  TDAnalyticsSDK
//
//  Created by thinkingdata on 2017/6/27.
//  Copyright © 2017年 thinkingdata. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (TDGzip)

+ (NSData *)gzipData:(NSData *)pUncompressedData;

@end
