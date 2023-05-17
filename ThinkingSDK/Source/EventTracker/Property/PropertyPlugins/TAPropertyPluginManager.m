//
//  TAPropertyPluginManager.m
//  ThinkingSDK
//
//  Created by 杨雄 on 2022/6/12.
//

#import "TAPropertyPluginManager.h"

@interface TAPropertyPluginManager ()
@property (nonatomic, strong) NSMutableArray<id<TAPropertyPluginProtocol>> *plugins;

@end


@implementation TAPropertyPluginManager

//MARK: - Public Methods

- (instancetype)init {
    self = [super init];
    if (self) {
        self.plugins = [NSMutableArray array];
    }
    return self;
}

- (void)registerPropertyPlugin:(id<TAPropertyPluginProtocol>)plugin {
    BOOL isResponds = [plugin respondsToSelector:@selector(properties)];
    NSAssert(isResponds, @"properties plugin must implement `- properties` method!");
    if (!isResponds) {
        return;
    }

    // 删除旧的plugin
    for (id<TAPropertyPluginProtocol> object in self.plugins) {
        if (object.class == plugin.class) {
            [self.plugins removeObject:object];
            break;
        }
    }
    [self.plugins addObject:plugin];

    // 采集属性
    if ([plugin respondsToSelector:@selector(start)]) {
        [plugin start];
    }
}

- (NSMutableDictionary<NSString *,id> *)currentPropertiesForPluginClasses:(NSArray<Class> *)classes {
    NSArray *plugins = [self.plugins copy];
    NSMutableArray<id<TAPropertyPluginProtocol>> *matchResult = [NSMutableArray array];
    // 遍历插件
    for (id<TAPropertyPluginProtocol> obj in plugins) {
        // 遍历筛选目标class
        for (Class cla in classes) {
            if ([obj isKindOfClass:cla]) {
                [matchResult addObject:obj];
                break;
            }
        }
    }
    // 获取属性插件采集的属性
    NSMutableDictionary *pluginProperties = [self propertiesWithPlugins:matchResult];

    return pluginProperties;
}

- (NSMutableDictionary<NSString *,id> *)propertiesWithEventType:(TAEventType)type {
    // 根据事件类型找到对应的plugin
    NSArray *plugins = [self.plugins copy];
    NSMutableArray<id<TAPropertyPluginProtocol>> *matchResult = [NSMutableArray array];
    for (id<TAPropertyPluginProtocol> obj in plugins) {
        if ([self isMatchedWithPlugin:obj eventType:type]) {
            [matchResult addObject:obj];
        }
    }
    return [self propertiesWithPlugins:matchResult];
}

//MARK: - Private Methods

- (NSMutableDictionary *)propertiesWithPlugins:(NSArray<id<TAPropertyPluginProtocol>> *)plugins {
    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
    // 获取匹配的插件属性
    dispatch_semaphore_t semaphore;
    for (id<TAPropertyPluginProtocol> plugin in plugins) {
        if ([plugin respondsToSelector:@selector(asyncGetPropertyCompletion:)]) {
            // 如果插件需要异步获取属性，那么用信号量来进行线程同步
            semaphore = dispatch_semaphore_create(0);
            [plugin asyncGetPropertyCompletion:^(NSDictionary<NSString *,id> * _Nonnull dict) {
                [properties addEntriesFromDictionary:dict];
                dispatch_semaphore_signal(semaphore);
            }];
        }
        // 普通方式获取属性
        NSDictionary *pluginProperties = [plugin respondsToSelector:@selector(properties)] ? plugin.properties : nil;
        if (pluginProperties) {
            [properties addEntriesFromDictionary:pluginProperties];
        }
        if (semaphore) {
            // 等待0.5s，让插件异步采集完成
            dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)));
        }
        // 将信号量置空
        semaphore = nil;
    }
    return properties;
}

- (BOOL)isMatchedWithPlugin:(id<TAPropertyPluginProtocol>)plugin eventType:(TAEventType)type {
    TAEventType eventTypeFilter;

    if (![plugin respondsToSelector:@selector(eventTypeFilter)]) {
        // 如果插件没有实现类型筛选方法，则默认只为track类型数据添加，包括首次事件、可更新事件、可重写事件。除了用户属性事件
        eventTypeFilter = TAEventTypeTrack | TAEventTypeTrackFirst | TAEventTypeTrackUpdate | TAEventTypeTrackOverwrite;
    } else {
        eventTypeFilter = plugin.eventTypeFilter;
    }
    
    if ((eventTypeFilter & type) == type) {
        return YES;
    }
    return NO;
}

@end
