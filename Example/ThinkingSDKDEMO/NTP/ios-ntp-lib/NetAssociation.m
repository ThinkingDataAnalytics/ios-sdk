#import "NetAssociation.h"

#import <sys/time.h>

#pragma -
#pragma mark                        T i m e • C o n v e r t e r s

static union ntpTime NTP_1970 = {0, JAN_1970};              // network time for 1 January 1970, GMT

static double pollIntervals[18] = {
      2.0,   16.0,   16.0,   16.0,   16.0,    35.0,    72.0,  127.0,     258.0,
    511.0, 1024.0, 2048.0, 4096.0, 8192.0, 16384.0, 32768.0, 65536.0, 131072.0
};

union ntpTime ntp_time_now() {
    struct timeval      now;
    gettimeofday(&now, (struct timezone *)NULL);
    return unix2ntp(&now);
}

union ntpTime unix2ntp(const struct timeval * tv) {
    union ntpTime   ntp1;

    ntp1.partials.wholeSeconds = (uint32_t)(tv->tv_sec + JAN_1970);
    ntp1.partials.fractSeconds = (uint32_t)((double)tv->tv_usec * (1LL<<32) * 1.0e-6);
    return ntp1;
}

double ntpDiffSeconds(union ntpTime * start, union ntpTime * stop) {
    int32_t         a;
    uint32_t        b;
    a = stop->partials.wholeSeconds - start->partials.wholeSeconds;
    if (stop->partials.fractSeconds >= start->partials.fractSeconds) {
        b = stop->partials.fractSeconds - start->partials.fractSeconds;
    }
    else {
        b = start->partials.fractSeconds - stop->partials.fractSeconds;
        b = ~b;
        a -= 1;
    }

    return a + b / 4294967296.0;
}

@interface NetAssociation () {

    GCDAsyncUdpSocket *     socket;                         // NetAssociation UDP Socket

    NSTimer *               repeatingTimer;                 // fires off an ntp request ...
    int                     pollingIntervalIndex;           // index into polling interval table

    union ntpTime           ntpClientSendTime,
                            ntpServerRecvTime,
                            ntpServerSendTime,
                            ntpClientRecvTime,
                            ntpServerBaseTime;

    int                     li, vn, mode, stratum, poll, prec, refid;

    double                  timerWobbleFactor;              // 0.75 .. 1.25

    double                  fifoQueue[8];
    short                   fifoIndex;

}

@property (readonly) double root_delay;                     // milliSeconds
@property (readonly) double dispersion;                     // milliSeconds
@property (readonly) double roundtrip;                      // seconds

@end

#pragma mark -
#pragma mark                        N E T W O R K • A S S O C I A T I O N

@implementation NetAssociation

- (instancetype) initWithServerName:(NSString *) serverName {
    if (self = [super init]) {
        _delegate = self;
        pollingIntervalIndex = 0;                           // ensure the first timer firing is soon
        _active = FALSE;                                    // isn't running till it reports time ...
        _trusty = FALSE;                                    // don't trust this clock to start with ...
        _offset = INFINITY;                                 // start with net clock meaningless
        _server = serverName;

        socket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self
                                               delegateQueue:dispatch_queue_create(
                   [serverName cStringUsingEncoding:NSUTF8StringEncoding], DISPATCH_QUEUE_SERIAL)];

		[self registerObservations];
    }
    return self;
}

- (void) enable {
    for (short i = 0; i < 8; i++) fifoQueue[i] = NAN;   // set fifo to all empty
    fifoIndex = 0;
    
    repeatingTimer = [NSTimer timerWithTimeInterval:MAXFLOAT
                                             target:self selector:@selector(queryTimeServer)
                                           userInfo:nil repeats:YES];
    repeatingTimer.tolerance = 1.0;                     // it can be up to 1 second late
    [[NSRunLoop mainRunLoop] addTimer:repeatingTimer forMode:NSDefaultRunLoopMode];

    timerWobbleFactor = ((float)rand()/(float)RAND_MAX / 2.0) + 0.75;       // 0.75 .. 1.25
    NSTimeInterval  interval = pollIntervals[pollingIntervalIndex] * timerWobbleFactor;
    repeatingTimer.tolerance = 5.0;                     // it can be up to 5 seconds late
    repeatingTimer.fireDate = [NSDate dateWithTimeIntervalSinceNow:interval];

    pollingIntervalIndex = 4;                           // subsequent timers fire at default intervals
}

- (void) queryTimeServer {
    [self sendTimeQuery];
    
    timerWobbleFactor = ((float)rand()/(float)RAND_MAX / 2.0) + 0.75;       // 0.75 .. 1.25
    NSTimeInterval  interval = pollIntervals[pollingIntervalIndex] * timerWobbleFactor;
    repeatingTimer.fireDate = [NSDate dateWithTimeIntervalSinceNow:interval];
}

- (void) sendTimeQuery {
    NSError *   error = nil;

    [socket sendData:[self createPacket] toHost:_server port:123 withTimeout:2.0 tag:0];

    if (![socket beginReceiving:&error]) {
        return;
    }
}

- (void) snooze {
    repeatingTimer.fireDate = [NSDate distantFuture];
    _active = FALSE;
}

- (void) finish {
    [repeatingTimer invalidate];

    _active = FALSE;
}

#pragma mark                        N e t w o r k • T r a n s a c t i o n s
- (NSData *) createPacket {
	uint32_t        wireData[12];

	memset(wireData, 0, sizeof wireData);
	wireData[0] = htonl((0 << 30) |                                         // no Leap Indicator
                        (4 << 27) |                                         // NTP v4
                        (3 << 24) |                                         // mode = client sending
                        (0 << 16) |                                         // stratum (n/a)
                        (4 << 8)  |                                         // polling rate (16 secs)
                        (-6 & 0xff));                                       // precision (~15 mSecs)
	wireData[1] = htonl(1<<16);
	wireData[2] = htonl(1<<16);

    ntpClientSendTime = ntp_time_now();

    wireData[10] = htonl(ntpClientSendTime.partials.wholeSeconds);                   // Transmit Timestamp
	wireData[11] = htonl(ntpClientSendTime.partials.fractSeconds);

    return [NSData dataWithBytes:wireData length:48];
}

- (void) decodePacket:(NSData *) data {
    ntpClientRecvTime = ntp_time_now();

    uint32_t        wireData[12];
    [data getBytes:wireData length:48];

	li      = ntohl(wireData[0]) >> 30 & 0x03;
	vn      = ntohl(wireData[0]) >> 27 & 0x07;
	mode    = ntohl(wireData[0]) >> 24 & 0x07;
	stratum = ntohl(wireData[0]) >> 16 & 0xff;
    poll    = ntohl(wireData[0]) >>  8 & 0xff;
    prec    = ntohl(wireData[0])       & 0xff;
    if (prec & 0x80) prec |= 0xffffff00;                                // -ve byte --> -ve int

    _root_delay = ntohl(wireData[1]) * 0.0152587890625;                 // delay (mS) [1000.0/2**16].
    _dispersion = ntohl(wireData[2]) * 0.0152587890625;                 // error (mS)

    refid   = ntohl(wireData[3]);

    ntpServerBaseTime.partials.wholeSeconds = ntohl(wireData[4]);                // when server clock was wound
    ntpServerBaseTime.partials.fractSeconds = ntohl(wireData[5]);

    if (ntpClientSendTime.partials.wholeSeconds != ntohl(wireData[6]) ||
        ntpClientSendTime.partials.fractSeconds != ntohl(wireData[7])) return;   //  NO;

    ntpServerRecvTime.partials.wholeSeconds = ntohl(wireData[8]);
    ntpServerRecvTime.partials.fractSeconds = ntohl(wireData[9]);
    ntpServerSendTime.partials.wholeSeconds = ntohl(wireData[10]);
    ntpServerSendTime.partials.fractSeconds = ntohl(wireData[11]);

    _offset = INFINITY;                                                 // clock meaningless
    if ((_dispersion < 100.0) &&
        (stratum > 0) &&
        (mode == 4) &&
        (ntpDiffSeconds(&ntpServerBaseTime, &ntpServerSendTime) < 3600.0)) {

        double  t41 = ntpDiffSeconds(&ntpClientSendTime, &ntpClientRecvTime);   // .. (T4-T1)
        double  t32 = ntpDiffSeconds(&ntpServerRecvTime, &ntpServerSendTime);   // .. (T3-T2)

        _roundtrip  = t41 - t32;

        double  t21 = ntpDiffSeconds(&ntpServerSendTime, &ntpClientRecvTime);   // .. (T2-T1)
        double  t34 = ntpDiffSeconds(&ntpServerRecvTime, &ntpClientSendTime);   // .. (T3-T4)

        _offset = (t21 + t34) / 2.0;                                    // calculate offset
        _active = TRUE;
    }

    dispatch_async(dispatch_get_main_queue(), ^{ [self->_delegate reportFromDelegate]; });// tell delegate we're done
}

- (void) reportFromDelegate {
    fifoQueue[fifoIndex++ % 8] = _offset;                           // store offset in seconds
    fifoIndex %= 8;                                                 // rotate index in range

    short           good = 0, fail = 0, none = 0;
    _offset = 0.0;                                                  // reset for averaging

    for (short i = 0; i < 8; i++) {
        if (isnan(fifoQueue[i])) {                                  // fifo slot is unused
            none++;
            continue;
        }
        if (isinf(fifoQueue[i]) || fabs(fifoQueue[i]) < 0.0001) {   // server can't be trusted
            fail++;
            continue;
        }

        good++;
        _offset += fifoQueue[i];                                    // accumulate good times
    }

    double	stdDev = 0.0;
    if (good > 0 || fail > 3) {
        _offset = _offset / good;                                   // average good times

        for (short i = 0; i < 8; i++) {
            if (isnan(fifoQueue[i])) continue;

            if (isinf(fifoQueue[i]) || fabs(fifoQueue[i]) < 0.001) continue;

            stdDev += (fifoQueue[i] - _offset) * (fifoQueue[i] - _offset);
        }
        stdDev = sqrt(stdDev/(float)good);

        _trusty = (good+none > 4) &&                                // four or more 'fails'
                   (fabs(_offset) < .050 ||                         // s.d. < 50 mSec
                   (fabs(_offset) > 2.0 * stdDev));                 // s.d. < offset * 2
    }

    if ((stratum == 1 && pollingIntervalIndex != 6) ||
        (stratum == 2 && pollingIntervalIndex != 5)) {
        pollingIntervalIndex = 7 - stratum;
    }
}

#pragma mark                        N e t w o r k • C a l l b a c k s

- (void) udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag {
}

- (void) udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error {
}

- (void) udpSocket:(GCDAsyncUdpSocket *)sock
    didReceiveData:(NSData *)data
       fromAddress:(NSData *)address
 withFilterContext:(id)filterContext {
    ntpClientRecvTime = ntp_time_now();

    [self decodePacket:data];
}

- (void) udpSocketDidClose:(GCDAsyncUdpSocket *)sock
                 withError:(NSError *)error {
}

#pragma mark                        U t i l i t i e s

- (NSDate *) dateFromNetworkTime:(union ntpTime *) networkTime {
    return [NSDate dateWithTimeIntervalSince1970:ntpDiffSeconds(&NTP_1970, networkTime)];
}

+ (NSString *) ipAddrFromName: (NSString *) domainName {

    CFHostRef ntpHostName = CFHostCreateWithName (nil, (__bridge CFStringRef)domainName);
    if (nil == ntpHostName) {
        return NULL;                                         // couldn't create 'host object' ...
    }

    CFStreamError   nameError;
    if (!CFHostStartInfoResolution (ntpHostName, kCFHostAddresses, &nameError)) {
        CFRelease(ntpHostName);
        return NULL;                                        // couldn't start resolution ...
    }

    Boolean         nameFound;
    NSArray *       ntpHostAddrs = (__bridge NSArray *)(CFHostGetAddressing (ntpHostName, &nameFound));

    if (!nameFound) {
        CFRelease(ntpHostName);
        return NULL;                                        // resolution failed ...
    }

    if (ntpHostAddrs == nil || ntpHostAddrs.count == 0) {
        CFRelease(ntpHostName);
        return NULL;                                        // NO addresses were resolved ...
    }
    CFRelease(ntpHostName);
    return [GCDAsyncUdpSocket hostFromAddress:ntpHostAddrs[0]];
}

#pragma mark                        P r e t t y P r i n t e r s

- (NSString *) prettyPrintPacket {
    NSMutableString *   prettyString = [NSMutableString stringWithFormat:@"prettyPrintPacket [%@]\n\n", _server];

    [prettyString appendFormat:@"  leap indicator: %3d\n  version number: %3d\n"
                                "   protocol mode: %3d\n         stratum: %3d\n"
                                "   poll interval: %3d\n"
                                "   precision exp: %3d\n\n", li, vn, mode, stratum, poll, prec];

    [prettyString appendFormat:@"      root delay: %7.3f (mS)\n"
                                "      dispersion: %7.3f (mS)\n\n", _root_delay, _dispersion];

    [prettyString appendFormat:@"client send time: %010u.%06d (%@)\n",
                        ntpClientSendTime.partials.wholeSeconds,
                        (uint32_t)((double)ntpClientSendTime.partials.fractSeconds / (1LL<<32) * 1.0e6),
                        [self dateFromNetworkTime:&ntpClientSendTime]];

    [prettyString appendFormat:@"server recv time: %010u.%06d (%@)\n",
                        ntpServerRecvTime.partials.wholeSeconds,
                        (uint32_t)((double)ntpServerRecvTime.partials.fractSeconds / (1LL<<32) * 1.0e6),
                        [self dateFromNetworkTime:&ntpServerRecvTime]];

    [prettyString appendFormat:@"server send time: %010u.%06d (%@)\n",
                        ntpServerSendTime.partials.wholeSeconds,
                        (uint32_t)((double)ntpServerSendTime.partials.fractSeconds / (1LL<<32) * 1.0e6),
                        [self dateFromNetworkTime:&ntpServerSendTime]];

    [prettyString appendFormat:@"client recv time: %010u.%06d (%@)\n\n",
                        ntpClientRecvTime.partials.wholeSeconds,
                        (uint32_t)((double)ntpClientRecvTime.partials.fractSeconds / (1LL<<32) * 1.0e6),
                        [self dateFromNetworkTime:&ntpClientRecvTime]];

    [prettyString appendFormat:@"server clock set: %010u.%06d (%@)\n\n",
                        ntpServerBaseTime.partials.wholeSeconds,
                        (uint32_t)((double)ntpServerBaseTime.partials.fractSeconds / (1LL<<32) * 1.0e6),
                        [self dateFromNetworkTime:&ntpServerBaseTime]];

    return prettyString;
}

- (NSString *) prettyPrintTimers {
    NSMutableString *   prettyString = [NSMutableString stringWithFormat:@"prettyPrintTimers\n\n"];

    [prettyString appendFormat:@"time server addr: [%@]\n"
                                " round trip time: %7.3f (mS)\n"
                                "    clock offset: %7.3f (mS)\n\n",
          _server, _roundtrip * 1000.0, _offset * 1000.0];

    return prettyString;
}

- (NSString *) description {
    return [NSString stringWithFormat:@"%@ [%@] stratum=%i; offset=%3.1f±%3.1fmS",
            _trusty ? @"↑" : @"↓", _server, stratum, _offset, _dispersion];
}

#pragma mark                      N o t i f i c a t i o n • T r a p s

- (void)registerObservations {

	[[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidEnterBackgroundNotification
													  object:nil queue:nil
												  usingBlock:^
	 (NSNotification * note) {
		 [self snooze];
	 }];

	[[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillEnterForegroundNotification
													  object:nil queue:nil
												  usingBlock:^
	 (NSNotification * note) {
		 [self enable];
	 }];

    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillTerminateNotification
                                                      object:nil queue:nil
                                                  usingBlock:^ (NSNotification * note) {
         [[NSNotificationCenter defaultCenter] removeObserver:self];
         [self finish];
     }];

	[[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationSignificantTimeChangeNotification
													  object:nil queue:nil
												  usingBlock:^
	 (NSNotification * note) {
		 for (short i = 0; i < 8; i++) self->fifoQueue[i] = NAN;      // set fifo to all empty
		 self->fifoIndex = 0;
	 }];
}

@end
