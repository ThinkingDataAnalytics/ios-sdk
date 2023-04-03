//
//  TASuperProperty.m
//  ThinkingSDK
//
//  Created by 杨雄 on 2022/6/10.
//

#import "TASuperProperty.h"
#import "TAPropertyValidator.h"
#import "TDLogging.h"
#import "TDFile.h"

@interface TASuperProperty ()
/// 多实例的标识符
@property (nonatomic, copy) NSString *token;
/// 静态公共属性
@property (atomic, strong) NSDictionary *superProperties;
/// 动态公共属性
@property (nonatomic, copy) NSDictionary<NSString *, id> *(^dynamicSuperProperties)(void);
/// 文件存储
@property (nonatomic, strong) TDFile *file;
/// 是否是轻实例
@property (nonatomic, assign) BOOL isLight;

@end

@implementation TASuperProperty

- (instancetype)initWithToken:(NSString *)token isLight:(BOOL)isLight {
    if (self = [super init]) {
        NSAssert(token.length > 0, @"token 不能为空");
        self.token = token;
        self.isLight = isLight;
        if (!isLight) {
            // 非轻实例才需要用到持久化
            self.file = [[TDFile alloc] initWithAppid:token];
            self.superProperties = [self.file unarchiveSuperProperties];
        }
    }
    return self;
}

- (void)registerSuperProperties:(NSDictionary *)properties {
    properties = [properties copy];
    // 验证属性
    properties = [TAPropertyValidator validateProperties:properties];
    if (properties.count <= 0) {
        TDLogError(@"%@ propertieDict error.", properties);
        return;
    }

    // 先获取之前设置的属性
    NSMutableDictionary *tmp = [NSMutableDictionary dictionaryWithDictionary:self.superProperties];
    // 追加新的属性，会覆盖旧的属性
    [tmp addEntriesFromDictionary:properties];
    self.superProperties = [NSDictionary dictionaryWithDictionary:tmp];

    // 持久化
    [self.file archiveSuperProperties:self.superProperties];
}

- (void)unregisterSuperProperty:(NSString *)property {
    NSError *error = nil;
    [TAPropertyValidator validateEventOrPropertyName:property withError:&error];
    if (error) {
        return;
    }

    NSMutableDictionary *tmp = [NSMutableDictionary dictionaryWithDictionary:self.superProperties];
    tmp[property] = nil;
    self.superProperties = [NSDictionary dictionaryWithDictionary:tmp];
    
    [self.file archiveSuperProperties:self.superProperties];
}

- (void)clearSuperProperties {
    self.superProperties = @{};
    [self.file archiveSuperProperties:self.superProperties];
}

- (NSDictionary *)currentSuperProperties {
    if (self.superProperties) {
        return [TAPropertyValidator validateProperties:[self.superProperties copy]];
    } else {
        return @{};
    }
}

- (void)registerDynamicSuperProperties:(NSDictionary<NSString *, id> *(^ _Nullable)(void))dynamicSuperProperties {
    @synchronized (self) {
        self.dynamicSuperProperties = dynamicSuperProperties;
    }
}

/// 获取动态公共属性
- (NSDictionary *)obtainDynamicSuperProperties {
    @synchronized (self) {
        if (self.dynamicSuperProperties) {
            NSDictionary *properties = self.dynamicSuperProperties();
            // 验证属性
            NSDictionary *validProperties = [TAPropertyValidator validateProperties:[properties copy]];
            return validProperties;
        }
        return nil;
    }
}

@end
