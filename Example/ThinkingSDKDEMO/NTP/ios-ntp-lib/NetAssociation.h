
#import <UIKit/UIKit.h>
#import <CocoaAsyncSocket/CocoaAsyncSocket.h>

#define JAN_1970    		((uint64_t)0x83aa7e80)          // UNIX epoch in NTP's epoch:
                                                            // 1970-1900 (2,208,988,800s)
union ntpTime {

    struct {
        uint32_t    fractSeconds;
        uint32_t    wholeSeconds;
    }           partials;

    uint64_t    floating;

} ;

union ntpTime   ntp_time_now(void);
union ntpTime   unix2ntp(const struct timeval * tv);
double          ntpDiffSeconds(union ntpTime * start, union ntpTime * stop);

@protocol NetAssociationDelegate <NSObject>

- (void) reportFromDelegate;

@end

@protocol GCDAsyncUdpSocketDelegate;

@interface NetAssociation : NSObject <GCDAsyncUdpSocketDelegate, NetAssociationDelegate>

@property (nonatomic, weak) id delegate;

@property (readonly) NSString *         server;             // server address "123.45.67.89"
@property (readonly) BOOL               active;             // is this clock running yet?
@property (readonly) BOOL               trusty;             // is this clock trustworthy
@property (readonly) double             offset;             // offset from device time (secs)

- (instancetype) init NS_UNAVAILABLE;
/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃ create a NetAssociation with the provided server name .. just sitting idle ..                    ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/
- (instancetype) initWithServerName:(NSString *) serverName NS_DESIGNATED_INITIALIZER;

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃ empty the time values fifo and start the timer which queries the association's server ..         ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/
- (void) enable;                                            // ..
/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃ snooze: stop the timer in a way that let's start it again ..                                     ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/
- (void) snooze;                                            // stop the timer but don't delete it
/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃ finish: stop the timer and invalidate it .. it'll die and disappear ..                           ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/
- (void) finish;                                            // ..

- (void) sendTimeQuery;                                     // send one datagram to server ..

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃ utility method converts domain name to numeric dotted address string ..                          ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/
+ (NSString *) ipAddrFromName: (NSString *) domainName;

@end
