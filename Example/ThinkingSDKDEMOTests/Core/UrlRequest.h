//
//  UrlRequest.h
//  ThinkingSDKDEMOUITests
//
//  Created by xiayuwei on 2022/2/26.
//  Copyright © 2022 thinking. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>

@interface UrlRequest : NSObject

- (NSMutableDictionary *)getRequest :  (NSString * _Nullable)urlString;
- (NSDictionary *)postRequest :  (NSString * _Nullable)urlString;
- (NSString *)getTimeStamp;
- (NSString *)convertToJsonData:(NSDictionary *)dict;
- (NSString *)getDate;
- (NSString *)uuidString;
- (NSData *)dataByAes128ECB:(NSData *)data key:(NSString *)key mode:(CCOperation)operation;
@end



