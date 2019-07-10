#import "TDLogging.h"

#import <os/log.h>
#import "TDOSLog.h"

@interface TDLogging ()

@end

@implementation TDLogging

+ (instancetype)sharedInstance
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)logCallingFunction:(TDLoggingLevel)type format:(id)messageFormat, ...
{
    if (messageFormat) {
        va_list formatList;
        va_start(formatList, messageFormat);
        NSString *formattedMessage = [[NSString alloc] initWithFormat:messageFormat arguments:formatList];
        va_end(formatList);
        
        if (@available(iOS 10.0, *)) {
            [TDOSLog log:NO message:formattedMessage type:type];
        }
        else {
            [self handle:type withMessage:formattedMessage];
        }
    }
}

-(void)handle:(TDLoggingLevel)level  withMessage:(NSString *)message {
//    NSString *category;
//    switch (level) {
//        case TDLoggingLevelDebug:
//            category = @"DEBUG";
//            break;
//        case TDLoggingLevelInfo:
//            category = @"INFO";
//            break;
//        case TDLoggingLevelError:
//            category = @"ERROR";
//            break;
//        case TDLoggingLevelNone:
//        default:
//            break;
//    }
    
//    NSLog(@"[THINKING] <%@>: %@", category, message);
     NSLog(@"[THINKING] %@", message);
}

@end

