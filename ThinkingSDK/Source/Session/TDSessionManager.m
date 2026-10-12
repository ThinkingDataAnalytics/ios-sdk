//
//  TDSessionManager.m
//  ThinkingSDK
//

#import "TDSessionManager.h"
#import "TDFile.h"

#import <stdlib.h>

const int64_t TDAnalyticsSessionDefaultTimeoutMillis = 5 * 60 * 1000;
NSString * const TDAnalyticsSessionIdProperty = @"#session_id";

static const int64_t TDAnalyticsSessionNoTime = -1;
static NSString * const TDDisPresetPropertiesKey = @"TDDisPresetProperties";

static NSMutableDictionary<NSString *, TDSessionManager *> *td_sessionManagers;
static NSLock *td_sessionManagersLock;

static NSString *TDUuidV7String(int64_t timestampMillis) {
    uint8_t bytes[16];
    arc4random_buf(bytes, sizeof(bytes));
    uint64_t timestamp = (uint64_t)timestampMillis;
    bytes[0] = (uint8_t)((timestamp >> 40) & 0xff);
    bytes[1] = (uint8_t)((timestamp >> 32) & 0xff);
    bytes[2] = (uint8_t)((timestamp >> 24) & 0xff);
    bytes[3] = (uint8_t)((timestamp >> 16) & 0xff);
    bytes[4] = (uint8_t)((timestamp >> 8) & 0xff);
    bytes[5] = (uint8_t)(timestamp & 0xff);
    bytes[6] = (uint8_t)((bytes[6] & 0x0f) | 0x70);
    bytes[8] = (uint8_t)((bytes[8] & 0x3f) | 0x80);

    static const char hex[] = "0123456789abcdef";
    char chars[37];
    NSUInteger charIndex = 0;
    for (NSUInteger i = 0; i < sizeof(bytes); i++) {
        if (i == 4 || i == 6 || i == 8 || i == 10) {
            chars[charIndex++] = '-';
        }
        chars[charIndex++] = hex[bytes[i] >> 4];
        chars[charIndex++] = hex[bytes[i] & 0x0f];
    }
    chars[charIndex] = '\0';
    return [NSString stringWithUTF8String:chars];
}

static int64_t TDNormalizeSessionTimeout(int64_t timeoutMillis) {
    return timeoutMillis > 0 ? timeoutMillis : TDAnalyticsSessionDefaultTimeoutMillis;
}

@interface TDSessionManager ()
@property (nonatomic, strong) NSLock *lock;
@property (nonatomic, strong, nullable) id<TDAnalyticsSessionStoring> store;
@property (nonatomic, copy, nullable) NSString *sessionId;
@property (nonatomic, assign) int64_t lastEventTime;
@end

@implementation TDSessionManager

+ (void)initialize {
    if (self != [TDSessionManager class]) {
        return;
    }
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        td_sessionManagers = [NSMutableDictionary dictionary];
        td_sessionManagersLock = [[NSLock alloc] init];
    });
}

- (instancetype)initWithStore:(id<TDAnalyticsSessionStoring>)store {
    self = [super init];
    if (self) {
        _lock = [[NSLock alloc] init];
        _store = store;
        _lastEventTime = TDAnalyticsSessionNoTime;
        if (store) {
            NSString *storedId = [store loadSessionId];
            int64_t storedTime = [store loadLastEventTime];
            if (storedId.length > 0 && storedTime >= 0) {
                _sessionId = [storedId copy];
                _lastEventTime = storedTime;
            }
        }
    }
    return self;
}

+ (instancetype)managerWithInstanceKey:(NSString *)instanceKey store:(id<TDAnalyticsSessionStoring>)store {
    NSString *key = instanceKey.length > 0 ? instanceKey : @"";
    [td_sessionManagersLock lock];
    TDSessionManager *existing = td_sessionManagers[key];
    if (existing) {
        [td_sessionManagersLock unlock];
        return existing;
    }
    TDSessionManager *created = [[TDSessionManager alloc] initWithStore:store];
    td_sessionManagers[key] = created;
    [td_sessionManagersLock unlock];
    return created;
}

- (NSString *)onEventAtMillis:(int64_t)now timeoutMillis:(int64_t)timeoutMillis {
    [self.lock lock];
    int64_t timeout = TDNormalizeSessionTimeout(timeoutMillis);
    if (_sessionId.length == 0 || _lastEventTime < 0 || now - _lastEventTime >= timeout) {
        _sessionId = TDUuidV7String(now);
    }
    _lastEventTime = now;
    [self persistLocked];
    NSString *sessionId = _sessionId;
    [self.lock unlock];
    return sessionId;
}

- (NSString *)startNewSessionAtMillis:(int64_t)now {
    [self.lock lock];
    _sessionId = TDUuidV7String(now);
    _lastEventTime = now;
    [self persistLocked];
    NSString *sessionId = _sessionId;
    [self.lock unlock];
    return sessionId;
}

- (void)onEnterBackgroundAtMillis:(int64_t)now {
    (void)now;
}

- (NSString *)onEnterForegroundAtMillis:(int64_t)now timeoutMillis:(int64_t)timeoutMillis {
    (void)now;
    (void)timeoutMillis;
    return self.sessionId;
}

- (NSString *)sessionId {
    [self.lock lock];
    NSString *sessionId = _sessionId;
    [self.lock unlock];
    return sessionId;
}

+ (BOOL)isSessionIdDisabled {
    static BOOL disabled = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray *disabledProperties = [[NSBundle mainBundle] infoDictionary][TDDisPresetPropertiesKey];
        disabled = [disabledProperties isKindOfClass:[NSArray class]] && [disabledProperties containsObject:TDAnalyticsSessionIdProperty];
    });
    return disabled;
}

- (void)persistLocked {
    if (self.store) {
        [self.store saveSessionId:_sessionId lastEventTime:_lastEventTime];
    }
}

@end

@implementation TDFileAnalyticsSessionStore {
    TDFile *_file;
}

- (instancetype)initWithFile:(TDFile *)file {
    self = [super init];
    if (self) {
        _file = file;
    }
    return self;
}

- (void)saveSessionId:(NSString *)sessionId lastEventTime:(int64_t)lastEventTime {
    [_file archiveAnalyticsSessionId:sessionId];
    [_file archiveAnalyticsSessionLastEventTime:@(lastEventTime)];
}

- (NSString *)loadSessionId {
    NSString *sessionId = [_file unarchiveAnalyticsSessionId];
    return sessionId.length > 0 ? sessionId : nil;
}

- (int64_t)loadLastEventTime {
    NSNumber *lastEventTime = [_file unarchiveAnalyticsSessionLastEventTime];
    if (![lastEventTime isKindOfClass:[NSNumber class]]) {
        return TDAnalyticsSessionNoTime;
    }
    return lastEventTime.longLongValue;
}

@end
