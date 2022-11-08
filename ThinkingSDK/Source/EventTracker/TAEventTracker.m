//
//  TAEventTracker.m
//  ThinkingSDK
//
//  Created by 杨雄 on 2022/6/19.
//

#import "TAEventTracker.h"
#import "TANetwork.h"
#import "TAReachability.h"
#import "TDEventRecord.h"

static dispatch_queue_t td_networkQueue;// 网络请求在td_networkQueue中进行

@interface TAEventTracker ()
@property (atomic, strong) TANetwork *network;
@property (atomic, strong) TDConfig *config;
@property (atomic, strong) dispatch_queue_t queue;
@property (nonatomic, strong) TDSqliteDataQueue *dataQueue;

@end

@implementation TAEventTracker

+ (void)initialize {
    static dispatch_once_t ThinkingOnceToken;
    dispatch_once(&ThinkingOnceToken, ^{
        NSString *queuelabel = [NSString stringWithFormat:@"cn.thinkingdata.%p", (void *)self];
        NSString *networkLabel = [queuelabel stringByAppendingString:@".network"];
        td_networkQueue = dispatch_queue_create([networkLabel UTF8String], DISPATCH_QUEUE_SERIAL);
    });
}

+ (dispatch_queue_t)td_networkQueue {
    return td_networkQueue;
}

- (instancetype)initWithQueue:(dispatch_queue_t)queue instanceToken:(nonnull NSString *)instanceToken {
    if (self = [self init]) {
        self.queue = queue;
        self.config = [ThinkingAnalyticsSDK sharedInstanceWithAppid:instanceToken].config;
        self.network = [self generateNetworkWithConfig:self.config];
        self.dataQueue = [TDSqliteDataQueue sharedInstanceWithAppid:[self.config getMapInstanceToken]];
    }
    return self;
}

- (TANetwork *)generateNetworkWithConfig:(TDConfig *)config {
    TANetwork *network = [[TANetwork alloc] init];
    network.debugMode = config.debugMode;
    network.appid = config.appid;
    network.sessionDidReceiveAuthenticationChallenge = config.securityPolicy.sessionDidReceiveAuthenticationChallenge;
    network.serverURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/sync", config.configureURL]];
    network.serverDebugURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/data_debug", config.configureURL]];
    network.securityPolicy = config.securityPolicy;
    return network;
}

//MARK: - Public

- (void)track:(NSDictionary *)event immediately:(BOOL)immediately saveOnly:(BOOL)isSaveOnly {
    ThinkingAnalyticsDebugMode debugMode = self.config.debugMode;
    NSInteger count = 0;
    if (debugMode == ThinkingAnalyticsDebugOnly || debugMode == ThinkingAnalyticsDebug) {
        // 是否暂停上报，只存储
        if (isSaveOnly) {
            return;
        }
        TDLogDebug(@"queueing debug data: %@", event);
        dispatch_async(self.queue, ^{
            dispatch_async(td_networkQueue, ^{
                [self flushDebugEvent:event];
            });
        });
        // ThinkingAnalyticsDebug 模式下发送数据后仍然会存储到本地，所以需要查询数据库数据，判断条数是否满足上传
        @synchronized (TDSqliteDataQueue.class) {
            count = [self.dataQueue sqliteCountForAppid:[self.config getMapInstanceToken]];
        }
    } else {
        if (immediately) {
            // 是否暂停上报，只存储
            if (isSaveOnly) {
                return;
            }
            TDLogDebug(@"queueing data flush immediately:%@", event);
            dispatch_async(self.queue, ^{
                dispatch_async(td_networkQueue, ^{
                    [self flushImmediately:event];
                });
            });
        } else {
            TDLogDebug(@"queueing data:%@", event);
            count = [self saveEventsData:event];
        }
    }
    if (count >= [self.config.uploadSize integerValue]) {
        // 是否暂停上报，只存储
        if (isSaveOnly) {
            return;
        }
        TDLogDebug(@"flush action, count: %ld, uploadSize: %d",count, [self.config.uploadSize integerValue]);
        [self flush];
    }
}

- (void)flushImmediately:(NSDictionary *)event {
    [self.network flushEvents:@[event]];
}

- (NSInteger)saveEventsData:(NSDictionary *)data {
    NSMutableDictionary *event = [[NSMutableDictionary alloc] initWithDictionary:data];
    NSInteger count = 0;
    @synchronized (TDSqliteDataQueue.class) {
        // 加密数据
        if (_config.enableEncrypt) {
#if TARGET_OS_IOS
            NSDictionary *encryptData = [[ThinkingAnalyticsSDK sharedInstanceWithAppid:self.config.appid].encryptManager encryptJSONObject:event];
            if (encryptData == nil) {
                encryptData = event;
            }
            count = [self.dataQueue addObject:encryptData withAppid:[self.config getMapInstanceToken]];
#elif TARGET_OS_OSX
            count = [self.dataQueue addObject:event withAppid:[self.config getMapInstanceToken]];
#endif
        } else {
            count = [self.dataQueue addObject:event withAppid:[self.config getMapInstanceToken]];
        }
    }
    return count;
}

- (void)flushDebugEvent:(NSDictionary *)event {
    if (self.config.debugMode == ThinkingAnalyticsDebug || self.config.debugMode == ThinkingAnalyticsDebugOnly) {
        int debugResult = [self.network flushDebugEvents:event withAppid:self.config.appid];
        if (debugResult == -1) {
            // 降级处理
            if (self.config.debugMode == ThinkingAnalyticsDebug) {
                dispatch_async(self.queue, ^{
                    [self saveEventsData:event];
                });
                
                self.config.debugMode = ThinkingAnalyticsDebugOff;
                self.network.debugMode = ThinkingAnalyticsDebugOff;
            } else if (self.config.debugMode == ThinkingAnalyticsDebugOnly) {
                TDLogDebug(@"The data will be discarded due to this device is not allowed to debug:%@", event);
            }
        }
        else if (debugResult == -2) {
            TDLogDebug(@"Exception occurred when sending message to Server:%@", event);
            if (self.config.debugMode == ThinkingAnalyticsDebug) {
                // 网络异常
                dispatch_async(self.queue, ^{
                    [self saveEventsData:event];
                });
            }
        }
    } else {
        //防止并发事件未降级
        NSInteger count = [self saveEventsData:event];
        if (count >= [self.config.uploadSize integerValue]) {
            [self flush];
        }
    }
}

- (void)flush {
    [self _asyncWithCompletion:^{}];
}

/// 异步同步数据（将本地数据库中的数据同步到TA）
/// 需要将此事件加到serialQueue队列中进行哦
/// 有些场景是事件入库和发送网络请求是同时发生的。事件入库是在serialQueue中进行，上报数据是在networkQueue中进行。如要确保事件入库在先，则需要将上报数据操作添加到serialQueue
- (void)_asyncWithCompletion:(void(^)(void))completion {
    // 在任务队列中异步执行，需要判断当前是否已经在任务队列中，避免重复包装
    void(^block)(void) = ^{
        dispatch_async(td_networkQueue, ^{
            [self _syncWithSize:kBatchSize completion:completion];
        });
    };
    if (dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL) == dispatch_queue_get_label(self.queue)) {
        block();
    } else {
        dispatch_async(self.queue, block);
    }    
}

/// 同步数据（将本地数据库中的数据同步到TA）
/// @param size 每次从数据库中获取的最大条数，默认50条
/// @param completion 同步回调
/// 该方法需要在networkQueue中进行，会持续的发送网络请求直到数据库的数据被发送完
- (void)_syncWithSize:(NSUInteger)size completion:(void(^)(void))completion {
    
    // 判断是否满足发送条件
    NSString *networkType = [[TAReachability shareInstance] networkState];
    if (!([TAReachability convertNetworkType:networkType] & self.config.networkTypePolicy)) {
        if (completion) {
            completion();
        }
        return;
    }
    
    // 获取数据库数据，取前五十条数据，并更新这五十条数据的uuid
    // uuid的作用是数据库待删除数据的标识
    NSArray<NSDictionary *> *recordArray;
    NSArray *recodIds;
    NSArray *uuids;
    @synchronized (TDSqliteDataQueue.class) {
        // 数据库里获取前kBatchSize条数据
        NSArray<TDEventRecord *> *records = [self.dataQueue getFirstRecords:kBatchSize withAppid:[self.config getMapInstanceToken]];
        NSArray<TDEventRecord *> *encryptRecords = [self encryptEventRecords:records];
        NSMutableArray *indexs = [[NSMutableArray alloc] initWithCapacity:encryptRecords.count];
        NSMutableArray *recordContents = [[NSMutableArray alloc] initWithCapacity:encryptRecords.count];
        for (TDEventRecord *record in encryptRecords) {
            [indexs addObject:record.index];
            [recordContents addObject:record.event];
        }
        recodIds = indexs;
        recordArray = recordContents;
        
        // 更新uuid
        uuids = [self.dataQueue upadteRecordIds:recodIds];
    }
     
    // 数据库没有数据了
    if (recordArray.count == 0 || uuids.count == 0) {
        if (completion) {
            completion();
        }
        return;
    }
    
    // 网络情况较好，会在此处持续的将数据库中的数据发送完
    // 1，保证end事件发送成功
    BOOL flushSucc = YES;
    while (recordArray.count > 0 && uuids.count > 0 && flushSucc) {
        flushSucc = [self.network flushEvents:recordArray];
        if (flushSucc) {
            @synchronized (TDSqliteDataQueue.class) {
                BOOL ret = [self.dataQueue removeDataWithuids:uuids];
                if (!ret) {
                    break;
                }
                // 数据库里获取前50条数据
                NSArray<TDEventRecord *> *records = [self.dataQueue getFirstRecords:kBatchSize withAppid:[self.config getMapInstanceToken]];
                NSArray<TDEventRecord *> *encryptRecords = [self encryptEventRecords:records];
                NSMutableArray *indexs = [[NSMutableArray alloc] initWithCapacity:encryptRecords.count];
                NSMutableArray *recordContents = [[NSMutableArray alloc] initWithCapacity:encryptRecords.count];
                for (TDEventRecord *record in encryptRecords) {
                    [indexs addObject:record.index];
                    [recordContents addObject:record.event];
                }
                recodIds = indexs;
                recordArray = recordContents;
                
                // 更新uuid
                uuids = [self.dataQueue upadteRecordIds:recodIds];
            }
        } else {
            break;
        }
    }
    if (completion) {
        completion();
    }
}

/// 开启加密后，上报的数据都需要是加密数据
/// 关闭加密后，上报数据既包含加密数据 也包含非加密数据
- (NSArray<TDEventRecord *> *)encryptEventRecords:(NSArray<TDEventRecord *> *)records {
#if TARGET_OS_IOS
    NSMutableArray *encryptRecords = [NSMutableArray arrayWithCapacity:records.count];
    // 加密工具
    TDEncryptManager *encryptManager = [ThinkingAnalyticsSDK sharedInstanceWithAppid:[self.config getMapInstanceToken]].encryptManager;
    
    if (self.config.enableEncrypt && encryptManager.isValid) {
        for (TDEventRecord *record in records) {
            
            if (record.encrypted) {
                // 数据已经加密
                [encryptRecords addObject:record];
            } else {
                // 缓存数据未加密，再加密
                NSDictionary *obj = [encryptManager encryptJSONObject:record.event];
                if (obj) {
                    [record setSecretObject:obj];
                    [encryptRecords addObject:record];
                } else {
                    [encryptRecords addObject:record];
                }
            }
        }
        return encryptRecords.count == 0 ? records : encryptRecords;
    } else {
        return records;
    }
#elif TARGET_OS_OSX
    return records;
#endif
}

- (void)syncSendAllData {
    dispatch_sync(td_networkQueue, ^{});
}


//MARK: - Setter & Getter


@end
