#import "TDLogging.h"

#import <os/log.h>

typedef void (^TDLoggingBlockHandler)(TDLoggingLevel loggingLevel, NSString *message);

@interface TDLogging ()

@property (nonatomic, copy, null_resettable) TDLoggingBlockHandler handler;
- (TDLoggingBlockHandler)handler UNAVAILABLE_ATTRIBUTE;

@end

@implementation TDLogging

+ (instancetype)sharedInstance
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
        ((TDLogging *)sharedInstance).handler = nil;
    });
    return sharedInstance;
}

- (void)setHandler:(void (^)(TDLoggingLevel, NSString *))handler {
    
    if (!handler) {
        _handler = [self defaultBlockHandler];
    } else {
        _handler = handler;
    }
}

- (void)logCallingFunction:(TDLoggingLevel)type format:(id)messageFormat, ...
{
    va_list formatList;
    va_start(formatList, messageFormat);
    NSString *formattedMessage = [[NSString alloc] initWithFormat:messageFormat arguments:formatList];
    va_end(formatList);
    
    _handler(type, formattedMessage);
}

- (TDLoggingBlockHandler)defaultBlockHandler {
    TDLoggingBlockHandler tdHandler = ^(TDLoggingLevel level, NSString *message) {
        NSString *category;
        if (@available(iOS 10.0, *)) {
            static dispatch_once_t once;
            static os_log_t debug_log;
            static os_log_t info_log;
            static os_log_t error_log;
            static os_log_type_t log_types[] = { OS_LOG_TYPE_DEFAULT,
                OS_LOG_TYPE_DEBUG,
                OS_LOG_TYPE_INFO,
                OS_LOG_TYPE_ERROR};
            dispatch_once(&once, ^ {
                debug_log = os_log_create("com.thinkingddata.analytics.log", "THINKING");
                info_log  = os_log_create("com.thinkingddata.analytics.log", "THINKING");
                error_log = os_log_create("com.thinkingddata.analytics.log", "THINKING");
            });
            
            os_log_t td_log;
            switch (level) {
                case TDLoggingLevelDebug:
                    td_log = debug_log;
                    category = @"DEBUG";
                    break;
                case TDLoggingLevelInfo:
                    td_log = info_log;
                    category = @"INFO";
                    break;
                case TDLoggingLevelError:
                    td_log = error_log;
                    category = @"ERROR";
                    break;
                case TDLoggingLevelNone:
                default:
                    break;
            }
            
            os_log_type_t logType = log_types[level];
            os_log_with_type(td_log, logType, "<%@>: %@", category, message);
        } else {
            switch (level) {
                case TDLoggingLevelDebug:
                    category = @"DEBUG";
                    break;
                case TDLoggingLevelInfo:
                    category = @"INFO";
                    break;
                case TDLoggingLevelError:
                    category = @"ERROR";
                    break;
                case TDLoggingLevelNone:
                default:
                    break;
            }

            NSLog(@"[THINKING] <%@>: %@", category, message);
        }
    };
    
    return tdHandler;
}

@end

