//
//  UrlRequest.m
//  ThinkingSDKDEMO
//
//  Created by xiayuwei on 2022/2/26.
//  Copyright © 2022 thinking. All rights reserved.
//

#import "UrlRequest.h"
#import "Foundation/Foundation.h"
#define  FORMATFUN(...)  [self actionUsePic:__VA_ARGS__]


@implementation UrlRequest


- (NSDictionary *)getRequest: (NSString *)urlString {
    NSDictionary __block *dict;

    //信号量为0是结束等待
    dispatch_semaphore_t disp = dispatch_semaphore_create(0);

    // 1.确定请求路径
    NSURL *url = [NSURL URLWithString:urlString];
    
    // 2.获得会话对象
    NSURLSession *session = [NSURLSession sharedSession];
    
    // 3.根据会话对象创建一个Task(发送请求）
    /*
     第一个参数：请求路径
     第二个参数：completionHandler回调（请求完成【成功|失败】的回调）
               data：响应体信息（期望的数据）
               response：响应头信息，主要是对服务器端的描述
               error：错误信息，如果请求失败，则error有值
     注意：
        1）该方法内部会自动将请求路径包装成一个请求对象，该请求对象默认包含了请求头信息和请求方法（GET）
        2）如果要发送的是POST请求，则不能使用该方法
     */
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        // 5.解析数据
        dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        dispatch_semaphore_signal(disp);
        
    }];
    
    // 4.执行任务
    [dataTask resume];
    dispatch_semaphore_wait(disp, DISPATCH_TIME_FOREVER);
    return dict;

}

- (NSMutableDictionary *)postRequest: (NSString *)urlString {
    NSMutableDictionary  *dict_response = [NSMutableDictionary dictionary];
    NSArray __block *atrributes_value_array;
    NSArray __block *atrributes_key_array;
    NSArray __block *atrributes_array_list;
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
      cachePolicy:NSURLRequestUseProtocolCachePolicy
      timeoutInterval:10.0];

    [request setHTTPMethod:@"POST"];
    [request setValue:@"x-www-form-urlencoded" forHTTPHeaderField:@"application"];

    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
      if (error) {
        NSLog(@"%@", error);
        dispatch_semaphore_signal(sema);
      } else {
          NSString *strdata = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
          NSArray *array = [strdata componentsSeparatedByString:@"\n"];
          NSData *jsonData = [array[0] dataUsingEncoding:NSUTF8StringEncoding];
          NSError *err;
          NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                             options:NSJSONReadingMutableContainers
                                                               error:&err];
         
          
          atrributes_key_array = dic[@"data"][@"headers"];
//          NSLog(@"%@", atrributes_value_array);
          NSLog(@"%@", array[1]);
//
//          NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
//          NSError *parseError = nil;
//          NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
          if(array.count >1) {
//              NSString *atrributes_value_string = [array[1] stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
//              atrributes_value_string = [atrributes_value_string stringByReplacingCharactersInRange:NSMakeRange(atrributes_value_string.length-2, 1) withString:@""];
              NSCharacterSet *cs = [NSCharacterSet characterSetWithCharactersInString:@"\"[]"];
              NSString *atrributes_value_string = [[array[1] componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
              atrributes_value_array = [atrributes_value_string componentsSeparatedByString:@","];
          }

          dispatch_semaphore_signal(sema);
      }
    }];
    [dataTask resume];
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    
    NSLog(@"%lu", (unsigned long)atrributes_value_array.count);
    NSLog(@"%lu", (unsigned long)atrributes_key_array.count);
    if(atrributes_value_array.count >0 & atrributes_value_array.count == atrributes_key_array.count) {
        for(NSInteger i = 0; i < atrributes_key_array.count; i++) {
            [dict_response setObject:atrributes_value_array[i] forKey:atrributes_key_array[i]];
        }
    }
    NSLog(@"%@", dict_response);

    return dict_response;
}

- (NSString *)getTimeStamp {
    NSTimeInterval interval = [[NSDate date] timeIntervalSince1970] * 1000;
    NSInteger time = interval;
    NSString *timestamp = [NSString stringWithFormat:@"%zd",time];
    return timestamp;
}

- (NSString *)getDate
{
    NSDate *date1 = [NSDate date];
    NSDateFormatter *formatter1 = [[NSDateFormatter alloc] init];
    [formatter1 setDateStyle:NSDateFormatterMediumStyle];
    [formatter1 setTimeStyle:NSDateFormatterShortStyle];
    [formatter1 setDateFormat:@"YYYY-MM-dd"];
    NSString *DateTime1 = [formatter1 stringFromDate:date1];
    return DateTime1;
}


- (NSString *)convertToJsonData:(NSDictionary *)dict
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString;

    if (!jsonData) {
        NSLog(@"%@",error);
    } else {
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    }

    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];

    NSRange range = {0,jsonString.length};

    //去掉字符串中的空格
    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];

    NSRange range2 = {0,mutStr.length};

    //去掉字符串中的换行符
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];

    return mutStr;
}

- (NSString *)uuidString
{
    CFUUIDRef uuid_ref = CFUUIDCreate(NULL);
    CFStringRef uuid_string_ref= CFUUIDCreateString(NULL, uuid_ref);
    NSString *uuid = [NSString stringWithString:(__bridge NSString *)uuid_string_ref];
    CFRelease(uuid_ref);
    CFRelease(uuid_string_ref);
    return [uuid lowercaseString];
}

// 加密
- (NSString *)dataByAes128ECB:(NSData *)data key:(NSString *)key mode:(CCOperation)operation {
    char keyPtr[kCCKeySizeAES128 + 1];
    bzero(keyPtr, sizeof(keyPtr));//清零
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];//秘钥key转成cString

    NSUInteger dataLength = [data length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;

    void * buffer = malloc(bufferSize);
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(operation,
                                          kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,//ECB模式
                                          keyPtr,
                                          kCCBlockSizeAES128,
                                          nil,
                                          [data bytes],
                                          dataLength,
                                          buffer,
                                          bufferSize,
                                          &numBytesDecrypted);
    if (cryptStatus == kCCSuccess) {
        NSData *encryptData = [NSData dataWithBytes:buffer length:numBytesDecrypted];
        NSMutableData *ivEncryptData = [NSMutableData data];
        [ivEncryptData appendData:encryptData];
        
        free(buffer);
        
        NSData *base64EncodeData = [ivEncryptData base64EncodedDataWithOptions:NSDataBase64EncodingEndLineWithCarriageReturn];
        NSString *encryptString = [[NSString alloc] initWithData:base64EncodeData encoding:NSUTF8StringEncoding];
        return encryptString;
    } else {
        free(buffer);
//        SALogError(@"AES encrypt data failed, with error Code: %d",(int)cryptStatus);
        return nil;
    }
    
}



@end

