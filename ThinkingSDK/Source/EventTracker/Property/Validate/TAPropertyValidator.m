//
//  TAPropertyValidator.m
//  Adjust
//
//  Created by 杨雄 on 2022/6/10.
//

#import "TAPropertyValidator.h"
#import "NSString+TAProperty.h"
#import "TAPropertyDefaultValidator.h"

@implementation TAPropertyValidator

/// 自定义属性名字格式验证
static NSString *const kTANormalTrackProperNameValidateRegularExpression = @"^[a-zA-Z][a-zA-Z\\d_]*$";
/// 自定义属性名字正则
static NSRegularExpression *_regexForNormalTrackValidateKey;

/// 自动采集，自定义属性名字格式验证。所有自动采集自定义属性，需要满足如下正则
static NSString *const kTAAutoTrackProperNameValidateRegularExpression = @"^([a-zA-Z][a-zA-Z\\d_]{0,49}|\\#(resume_from_background|app_crashed_reason|screen_name|referrer|title|url|element_id|element_type|element_content|element_position|background_duration|start_reason))$";
/// 自动采集，自定义属性名字正则
static NSRegularExpression *_regexForAutoTrackValidateKey;

+ (void)validateEventOrPropertyName:(NSString *)name withError:(NSError *__autoreleasing  _Nullable *)error {
    if (!name) {
        NSString *errorMsg = @"Property key or Event name is empty";
        TDLogError(errorMsg);
        *error = TAPropertyError(10003, errorMsg);
        return;
    }
    if (![name isKindOfClass:NSString.class]) {
        NSString *errorMsg = [NSString stringWithFormat:@"Property key or Event name is not NSString: [%@]", name];
        TDLogError(errorMsg);
        *error = TAPropertyError(10007, errorMsg);
        return;
    }
    // 满足属性名字一样的验证格式
    [name ta_validatePropertyKeyWithError:error];
}

+ (void)validateBaseEventPropertyKey:(NSString *)key value:(NSString *)value error:(NSError **)error {
    // 验证 key
    if (![key conformsToProtocol:@protocol(TAPropertyKeyValidating)]) {
        NSString *errMsg = [NSString stringWithFormat:@"The property KEY must be NSString. got: %@ %@", [key class], key];
        TDLogError(errMsg);
        *error = TAPropertyError(10001, errMsg);
        return;
    }
    [(id <TAPropertyKeyValidating>)key ta_validatePropertyKeyWithError:error];
    if (*error) {
        return;
    }

    // 验证 value
    if (![value conformsToProtocol:@protocol(TAPropertyValueValidating)]) {
        NSString *errMsg = [NSString stringWithFormat:@"Property value must be type NSString, NSNumber, NSDate, NSDictionary or NSArray. got: %@ %@. ", [value class], value];
        TDLogError(errMsg);
        *error = TAPropertyError(10002, errMsg);
        return;
    }
    [(id <TAPropertyValueValidating>)value ta_validatePropertyValueWithError:error];
}

+ (void)validateNormalTrackEventPropertyKey:(NSString *)key value:(NSString *)value error:(NSError **)error {
    [self validateBaseEventPropertyKey:key value:value error:error];
    if (*error) {
        return;
    }
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _regexForNormalTrackValidateKey = [NSRegularExpression regularExpressionWithPattern:kTANormalTrackProperNameValidateRegularExpression options:NSRegularExpressionCaseInsensitive error:nil];
    });
    if (!_regexForNormalTrackValidateKey) {
        NSString *errorMsg = @"Property Key validate regular expression init failed";
        TDLogError(errorMsg);
        *error = TAPropertyError(10004, errorMsg);
        return;
    }
    NSRange range = NSMakeRange(0, key.length);
    if ([_regexForNormalTrackValidateKey numberOfMatchesInString:key options:0 range:range] < 1) {
        NSString *errorMsg = [NSString stringWithFormat:@"Property Key or Event name: [%@] is invalid.", key];
        TDLogError(errorMsg);
        *error = TAPropertyError(10005, errorMsg);
        return;
    }
}

+ (void)validateAutoTrackEventPropertyKey:(NSString *)key value:(NSString *)value error:(NSError **)error {
    [self validateBaseEventPropertyKey:key value:value error:error];
    if (*error) {
        return;
    }
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _regexForAutoTrackValidateKey = [NSRegularExpression regularExpressionWithPattern:kTAAutoTrackProperNameValidateRegularExpression options:NSRegularExpressionCaseInsensitive error:nil];
    });
    if (!_regexForAutoTrackValidateKey) {
        NSString *errorMsg = @"Property Key validate regular expression init failed";
        TDLogError(errorMsg);
        *error = TAPropertyError(10004, errorMsg);
        return;
    }
    NSRange range = NSMakeRange(0, key.length);
    if ([_regexForAutoTrackValidateKey numberOfMatchesInString:key options:0 range:range] < 1) {
        NSString *errorMsg = [NSString stringWithFormat:@"Property Key or Event name: [%@] is invalid.", key];
        TDLogError(errorMsg);
        *error = TAPropertyError(10005, errorMsg);
        return;
    }
}

/// 验证属性
/// @param properties 属性
+ (NSMutableDictionary *)validateProperties:(NSDictionary *)properties {
    return [self validateProperties:properties validator:[[TAPropertyDefaultValidator alloc] init]];
}

/// 验证属性，提供一个自定义的验证器
/// @param properties 属性
/// @param validator 验证器
+ (NSMutableDictionary *)validateProperties:(NSDictionary *)properties validator:(id<TAEventPropertyValidating>)validator {
    if (![properties isKindOfClass:[NSDictionary class]] || ![validator conformsToProtocol:@protocol(TAEventPropertyValidating)]) {
        return nil;
    }
    
    for (id key in properties) {
        NSError *error = nil;
        id value = properties[key];
        
        // 验证key-value，只做报错提示
        [validator ta_validateKey:key value:value error:&error];
    }
    return [properties copy];
}

@end
