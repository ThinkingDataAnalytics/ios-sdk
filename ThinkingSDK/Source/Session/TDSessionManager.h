//
//  TDSessionManager.h
//  ThinkingSDK
//
//  Tracks the current #session_id using Amplitude's session gap rule.
//  The id is a UUID v7 string. Its first 48 bits are the session start time in milliseconds.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Default gap before a new session starts: 5 minutes, in milliseconds.
FOUNDATION_EXPORT const int64_t TDAnalyticsSessionDefaultTimeoutMillis;

/// Preset property key attached to tracked events.
FOUNDATION_EXPORT NSString * const TDAnalyticsSessionIdProperty;

/**
 Persistence for the current session id and the time of the last tracked event or explicit session boundary.
 */
@protocol TDAnalyticsSessionStoring <NSObject>

- (void)saveSessionId:(nullable NSString *)sessionId lastEventTime:(int64_t)lastEventTime;
- (nullable NSString *)loadSessionId;
- (int64_t)loadLastEventTime;

@end

@interface TDSessionManager : NSObject

/// Current session id, or nil when no session has started.
@property (nonatomic, copy, readonly, nullable) NSString *sessionId;

- (instancetype)initWithStore:(nullable id<TDAnalyticsSessionStoring>)store;

/**
 Returns the session manager for an SDK instance. The first caller supplies persistence;
 later callers with the same key share that instance.
 */
+ (instancetype)managerWithInstanceKey:(NSString *)instanceKey
                                 store:(nullable id<TDAnalyticsSessionStoring>)store;

/**
 Assigns or extends the session for an event processed at `now`.
 Timeout values <= 0 use the 5 minute default.
 */
- (NSString *)onEventAtMillis:(int64_t)now timeoutMillis:(int64_t)timeoutMillis;

/// Starts a new session immediately, regardless of the current inactivity window.
- (NSString *)startNewSessionAtMillis:(int64_t)now;

/// Records a background transition without changing the session or its event timeout window.
- (void)onEnterBackgroundAtMillis:(int64_t)now;

/// Records a foreground transition without changing the session or its event timeout window.
- (nullable NSString *)onEnterForegroundAtMillis:(int64_t)now timeoutMillis:(int64_t)timeoutMillis;

/// Whether Info.plist TDDisPresetProperties contains #session_id.
+ (BOOL)isSessionIdDisabled;

@end

@class TDFile;

@interface TDFileAnalyticsSessionStore : NSObject <TDAnalyticsSessionStoring>

- (instancetype)initWithFile:(TDFile *)file;

@end

NS_ASSUME_NONNULL_END
